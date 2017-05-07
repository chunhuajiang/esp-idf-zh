非易失性存储器(NVS)库
============================

简介
------------

非易失性存储器（Non-volatile storage，NVS）库被设计用于在 flash 中存储键值对。本节介绍一些在 NVS 中所使用的概念。

Underlying storage
^^^^^^^^^^^^^^^^^^

当前，NVS 通过 ``spi_flash_{read|write|erase}`` API 使用了一部分主 flash 存储器。该库使用第一个分区 —— 其类型是 ``data``，子类型是 ``nvs``。

该库将来可能会添加其它的存储器后端，让数据可以保存在另一个 flash（I2C 或者 SPI）芯片、RTC、FRAM 等中。

.. note:: 如果 NVS 分区被截断了（例如分区表布局文件被修改），它上面的内容必修被擦除。ESP-IDF 构建系统提供了一个 ``make erase_flash`` 目标来擦除 flash 芯片上的所有内容。

键和值
^^^^^^^^^^^^^^^

NVS 操作的对象是键值对。键是 ASCII 字符串，当前的最大键长度是 15 个字符。值可以是下面某一种类型：

-  整数值 ``uint8_t``, ``int8_t``, ``uint16_t``, ``int16_t``, ``uint32_t``, ``int32_t``, ``uint64_t``, ``int64_t``
-  以零结尾的字符串
-  长度可变的二进制数据 (blob)

在今后也可能支持其它类型，例如 ``float`` 和 ``double``。

键必须是唯一的。向一个已存在的键写值时的行为如下：

-  如果新值与就指类型相同，则将值更新
-  如果新值与就指类型相同，则返回一个错误

读取值时会执行能够数据类型检查。如果读操作的数据类型与值的数据类型不匹配，则返回一个错误。


命名空间
^^^^^^^^^^

为了减小不同组件间命令冲突的可能性，NVS 将每个键值对分配到一个命名空间中。命名空间的名字与键名的规则相同，即最长 15 个字符。命名空间的名字在执行 ``nvs_open`` 调用时指定。这个调用会返回一个不透明的句柄，这个句柄在随后调用函数 `nvs_read_*``、``nvs_write_*`` 和 ``nvs_commit`` 时使用。这样，句柄与命名空间相关联，键名就不会与其它组件具有相同名字的键冲突。

安全、篡改和鲁棒性
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

NVS 库没有实现篡改预防策略。任何可以在物理上访问芯片的代码都可以更改、擦除或添加新的键值对。

NVS 与 ESP32 的 flash 加密系统是兼容的，它可以以加密形式存储键值对。一些元数据，例如页状态、私立入口（individual entries）的写/擦除标志，不能被加密，因为因为它们表示为有效访问和操作 flash 存储器的比特。Flash 加密可以阻止某些形式的修改：

- 使用任意值替换键或值
- 改变值的数据类型

下列形式的修改即使在使用了 flash 加密依然可以：

- 完整地擦除页，移除该页中擦除的所有键值对
- 破坏（corrupting）页中的数据，发生这种情况将会造成页被自动擦除
- 回滚 flash 存储器的状态到某个早期快照
- 合并 flash 存储器的两个快照，回滚一些键值对到某个早起状态（即使当前的设计还不支持 — TODO）

当 flash 存储器处于非一致性状态时，库会尝试取从这些条件中恢复。特别的，你可以在任何时间、任何点将设备断电再上电，除了新键值对（即该键值对正在写时断电了），这一般不会造成数据丢失。库能够能够使用 flash 存储器中的任何随机数进行恰当地初始化。


内部
---------

键值对的记录
^^^^^^^^^^^^^^^^^^^^^^

NVS 按顺序存储键值对，新的键值对被添加到末尾。当任意所给键的值被更新时，新的键值对别添加到记录（log）的默认，旧的键值对被标记未已擦除。

页和条目
^^^^^^^^^^^^^^^^^

NVS 库在操作时主要使用了两种实体：页（page）和条目（entry）。页是一个存储整个记录中一部分内容的逻辑结构。逻辑页对应一个 flash 存储器的扇区。正在使用的页有一个与之绑定咋一起的 *序列号（sequence number）*。序列号反映了也的顺序。序列号越大表示页创建的时间越晚。每个页可以处于下列的某种状态：


空/未初始化（Empty/uninitialized）
    页的 flash 存储器是空的，即所有的字节都是``0xff``。在这种状态时，页不能用于存储任何数据，也没有序列号。
    
有效（Active）
    Flash 存储器被初始化了，页的头部被写到 flash 中，且页有一个序列号。页有一些可以被写入的空的条目和数据。大多数时候，页都处于这种状态。

满（Full）
    Flash 存储器处于一个一致性转台，且被写满了键值对。向该页新写的键值对将失败。此时仍然可以将某些键值对标记为已擦除。
    
擦除中（Erasing）
    未被标记未已擦除的键值对正在被移动到另一页，然后该也就可以被擦除。这是一个临时状态，即当任何 API 调用返回时页都不会处于该状态。如果遇到突然断电，移动-擦除操作将在下一次上电后继续。
    
被破坏（Corrupted）
    页的头部包含无效的数据，对页数据的解析将会取消。之前写入该页的任何数据都不可访问。相应的 flash 扇区不会立即擦除，将会保持为 *未初始化* 状态，以供今后使用。这有助于进行调试。

从 flash 扇区到逻辑页的映射没有任何特殊的顺序。库将会检查每个 flash 扇区中的页序列号，然后基于这些数字将页按照形成一个链表。

::

    +--------+     +--------+     +--------+     +--------+
    | Page 1 |     | Page 2 |     | Page 3 |     | Page 4 |
    | Full   +---> | Full   +---> | Active |     | Empty  |   <- states
    | #11    |     | #12    |     | #14    |     |        |   <- sequence numbers
    +---+----+     +----+---+     +----+---+     +---+----+
        |               |              |             |
        |               |              |             |
        |               |              |             |
    +---v------+  +-----v----+  +------v---+  +------v---+
    | Sector 3 |  | Sector 0 |  | Sector 2 |  | Sector 1 |    <- physical sectors
    +----------+  +----------+  +----------+  +----------+

页的结构
^^^^^^^^^^^^^^^^^^^

现在我们假设 flash 扇区的大小是 4096 字节，且 ESP32 的 flash 加密硬件是以 32 字节块为单位进行操作的。为了适应扇区大小不相同的 flash 芯片，可以在编译时（例如通过配置菜单）引入一些可配置的设置（尽管不清楚系统其它组件，例如 SPI flash 驱动和 SPI flash cache，是否可以支持其它的大小）。

页由三部分组成：头部、条目状态位映射（bitmap）和条目自身。为了与 ESP32 的 flash 加密兼容，条目的大小是 32 字节。对于整数类型，条目拥有一个键值对。对于字符串和块（blob），条目拥有部分键值对（更多的在条目的结构体描述符中）。


下列框图描述了页的结构。原括号中的数字表示每部分的大小（以字节为单位）。 ::

    +-----------+--------------+-------------+-----------+
    | State (4) | Seq. no. (4) | Unused (20) | CRC32 (4) | Header (32)
    +-----------+--------------+-------------+-----------+
    |                Entry state bitmap (32)             |
    +----------------------------------------------------+
    |                       Entry 0 (32)                 |
    +----------------------------------------------------+
    |                       Entry 1 (32)                 |
    +----------------------------------------------------+
    /                                                    /
    /                                                    /
    +----------------------------------------------------+
    |                       Entry 125 (32)               |
    +----------------------------------------------------+

页的头部和条目状态位映射通常被写到 flash 的未加密部分。如果使用了 ESP32 的 flash 加密功能，条目会被加密。


页的状态是这样定义的：向某些比特写 0 可以改变状态。因此，一般没有必要通过擦除页来改变页的状态，除非要改变的状态是 *已擦除* 状态。


头部中计算的 CRC32 值不包括状态值（底 4 ～ 28 字节）。未使用部分当前使用 ``0xff`` 填充。今后的库可能会在这里存储格式化版本。

下面的章节描述了条目状态位映射和条目自身的结构。

条目和条目状态位映射
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

每个条目可以处于一下三个状态之一。每个状态都由条目状态位映射中的两个比特表示。位映射中的最后四个比特（256 - 2 * 126）未被使用。

空 Empty (2'b11)
    所指定的条目还没有写入任何东西。这是一个未初始化状态（所有的字节都是 ``0xff``）。

已写入 Written (2'b10)
    一个键值对（或者跨越多个条目的键值对的一部分）已被写入到条目。

已擦除 Erased (2'b00)
    该条目中的键值对被丢弃。该条目中的内容将不会被解析。


条目的结构
^^^^^^^^^^^^^^^^^^

For values of primitive types (currently integers from 1 to 8 bytes long), entry holds one key-value pair. For string and blob types, entry holds part of the whole key-value pair. In case when a key-value pair spans multiple entries, all entries are stored in the same page.

::

    +--------+----------+----------+---------+-----------+---------------+----------+
    | NS (1) | Type (1) | Span (1) | Rsv (1) | CRC32 (4) |    Key (16)   | Data (8) |
    +--------+----------+----------+---------+-----------+---------------+----------+

                                                   +--------------------------------+
                             +->    Fixed length:  | Data (8)                       |
                             |                     +--------------------------------+
              Data format ---+
                             |                     +----------+---------+-----------+
                             +-> Variable length:  | Size (2) | Rsv (2) | CRC32 (4) |
                                                   +----------+---------+-----------+


Individual fields in entry structure have the following meanings:

NS
    Namespace index for this entry. See section on namespaces implementation for explanation of this value.

Type
    One byte indicating data type of value. See ``ItemType`` enumeration in ``nvs_types.h`` for possible values.

Span
    Number of entries used by this key-value pair. For integer types, this is equal to 1. For strings and blobs this depends on value length.

Rsv
    Unused field, should be ``0xff``.

CRC32
    Checksum calculated over all the bytes in this entry, except for the CRC32 field itself.

Key
    Zero-terminated ASCII string containing key name. Maximum string length is 15 bytes, excluding zero terminator.

Data
    For integer types, this field contains the value itself. If the value itself is shorter than 8 bytes it is padded to the right, with unused bytes filled with ``0xff``. For string and blob values, these 8 bytes hold additional data about the value, described next:

Size
    (Only for strings and blobs.) Size, in bytes, of actual data. For strings, this includes zero terminator.

CRC32
    (Only for strings and blobs.) Checksum calculated over all bytes of data.

Variable length values (strings and blobs) are written into subsequent entries, 32 bytes per entry. `Span` field of the first entry indicates how many entries are used.


命名空间
^^^^^^^^^^

As mentioned above, each key-value pair belongs to one of the namespaces. Namespaces identifiers (strings) are stored as keys of key-value pairs in namespace with index 0. Values corresponding to these keys are indexes of these namespaces. 

::

    +-------------------------------------------+
    | NS=0 Type=uint8_t Key="wifi" Value=1      |   Entry describing namespace "wifi"
    +-------------------------------------------+
    | NS=1 Type=uint32_t Key="channel" Value=6  |   Key "channel" in namespace "wifi"
    +-------------------------------------------+
    | NS=0 Type=uint8_t Key="pwm" Value=2       |   Entry describing namespace "pwm"
    +-------------------------------------------+
    | NS=2 Type=uint16_t Key="channel" Value=20 |   Key "channel" in namespace "pwm"
    +-------------------------------------------+


Item 哈希链表
^^^^^^^^^^^^^^

To reduce the number of reads performed from flash memory, each member of Page class maintains a list of pairs: (item index; item hash). This list makes searches much quicker. Instead of iterating over all entries, reading them from flash one at a time, ``Page::findItem`` first performs search for item hash in the hash list. This gives the item index within the page, if such an item exists. Due to a hash collision it is possible that a different item will be found. This is handled by falling back to iteration over items in flash.

Each node in hash list contains a 24-bit hash and 8-bit item index. Hash is calculated based on item namespace and key name. CRC32 is used for calculation, result is truncated to 24 bits. To reduce overhead of storing 32-bit entries in a linked list, list is implemented as a doubly-linked list of arrays. Each array holds 29 entries, for the total size of 128 bytes, together with linked list pointers and 32-bit count field. Minimal amount of extra RAM useage per page is therefore 128 bytes, maximum is 640 bytes.

