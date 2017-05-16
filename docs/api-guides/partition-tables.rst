分区表
================

概述
--------

单个 ESP32 flash 可以包含多个应用程序，以及多种数据（校验数据、文件系统、参数存储器等）。基于这个原因，在 flash 的偏移地址 0x8000 处烧写了一个分区比表。

分区表的长度是 0xC00 字节（最多 95 个分区表条目）。如果分区表由于 `安全启动` 被签名，则签名会追加到表格的数据后面。

分区表的每个条目都包含名字(标签)、类型（app、data 等）、子类型以及在 flash 中的偏移量（分区表被加载的地址）。

使用分区表最简单的方法是使用 `make menuconfig`，然后选择一个简单的预定义的分区表：

* "Single factory app, no OTA"
* "Factory app, two OTA definitions"

在这两种情况下，工厂应用程序都会被烧写到偏移量 0x10000 处。如果你运行 `make partition_table`，控制台则会打印出分配表的情况。

内置分区表
-------------------------

下面是配置 "Single factory app, no OTA" 所打印出的信息 ::

  # Espressif ESP32 Partition Table
  # Name,   Type, SubType, Offset,  Size
  nvs,      data, nvs,     0x9000,  0x6000
  phy_init, data, phy,     0xf000,  0x1000
  factory,  app,  factory, 0x10000, 1M

* flash 的偏移地址 0x10000 (64KB) 处是标记为 "factory" 的应用程序。bootloader 默认会运行这里的应用程序。
* 分区表中还定义了连个数据区域，用于存储 NVS 库分区和 PHY 初始化数据。


下面是配置 "Factory app, two OTA definitions" 所打印出的信息 ::

  # Espressif ESP32 Partition Table
  # Name,   Type, SubType, Offset,  Size
  nvs,      data, nvs,     0x9000,  0x4000
  otadata,  data, ota,     0xd000,  0x2000
  phy_init, data, phy,     0xf000,  0x1000
  factory,  0,    0,       0x10000, 1M
  ota_0,    0,    ota_0,   ,        1M
  ota_1,    0,    ota_1,   ,        1M

* 存在三个应用程序分区的定义。
* 这三个的类型都是 "app"，但是子类型不同，工厂 app 位于 0x10000 处，剩余两个是 "OTA" app。
* 这里还有一个新的 "ota data"，它用于保存 OTA 更新的一些信息。bootloader 会使用这些数据来判断指定哪个应用程序。如果 "ota data" 是空的，它会执行工厂应用程序。

创建自定义分区表
----------------------

如果你在配置菜单中选择 "Custom partition table CSV"，你需要输入用于保存你的分区表的 CSV 文件的名字（在工程目录中）。CSV 可以根据你的需要描述任意数量的定义。

CVS 的格式与上面所打印的信息的格式是类似的。不过，不是所有的字段都需要。例如，这是一个 OTA 分区表的 "input" CSV ::

  # Name,   Type, SubType, Offset,   Size
  nvs,      data, nvs,     0x9000,  0x4000
  otadata,  data, ota,     0xd000,  0x2000
  phy_init, data, phy,     0xf000,  0x1000
  factory,  app,  factory, 0x10000,  1M
  ota_0,    app,  ota_0,   ,         1M
  ota_1,    app,  ota_1,   ,         1M

* 字段间的空格会被忽略，以 # 开始的行（注释）也会被忽略。
* CSV 文件的每个非注释行都是一个分区定义。
* 只提供了第一个分区的偏移量。工具 gen_esp32part.py 会自动根据前一个分区的参数来填充偏移量。

名字(Name)字段
~~~~~~~~~~~~~~~~~~~~

名字字段可以是任意有意义的名字。这对 ESP32 是无关紧要的。长度大于 16 个字符的名字将会被截断。

Type 字段
~~~~~~~~~~~~~~~~~~~~

分区类型字段可以指定为 app（0）或者 data（1）。它也可以是 0-254（0x00-0xFE）之间的数字。类型 0x00-0x3F 被保留用于 esp-idf 的核心功能。

如果你的应用程序需要存储数据，请添加一个类型在 0x40-0xFE 范围的自定义分区。

bootloader 会忽略所有类型不是 app（0） & data（1） 的分区。

子类型
~~~~~~~~~~~~~~~~~

8 比特的子类型字段与所给的分区类型相关。

esp-idf 当前只指定了 "app" 和 "data" 分区的子类型字段。

App 子类型
~~~~~~~~~~~~~~~~~~~~~~

当类型是 "app" 时，子类型可以是 factory (0), ota_0 (0x10) ... ota_15 (0x1F) 或 test (0x20)。

- factory (0) 是默认的 app 分区。如果这里没有 data/ota 类型的分区，它会默认执行工厂 app，否则会读取该分区来判断启动哪个 OTA 镜像。

  - OTA 永远不会更新工厂分区。
  - 如果你想在 OTA 工程中保护 flash 的使用，你可以移除工厂分区并使用 ota_0 代替。
- ota_0 (0x10) ... ota_15 (0x1F) 是 OTA 应用程序插槽（slot）。更多细节请参考 :doc:`OTA 文档 <../api-reference/system/ota>`，然后使用 OTA 数据分区来配置让给 bootloader 启动哪个插槽。如果使用 OTA，应用程序应当至少包括两个 OTA 应用程序插槽（ota_0 & ota_1）。更多细节请参考 :doc:`OTA 文档 <../api-reference/system/ota>`。
- test (0x2) 是用于工厂测试过程的保留子类型。esp-idf bootloader 当前不支持这种子类型。

Data 子类型
~~~~~~~~~~~~~~~~~~~~~~~

当类型是 "data"时，子类型可以是 ota (0), phy (1), nvs (2)。

- ota (0) 是 :ref:`OTA 数据分区 <ota_data_partition>`，用于存储当前所选择的 OTA 应用程序的信息。这个分区的大小固定为 0x2000 字节。更多细节请参考 :ref:`OTA 文档 <ota_data_partition>`。
- phy (1) 用于存储 PHY 初始化数据。这样可以为每个设备（而不是在固件中）配置 PHY。

  - 在默认的配置中，phy partition 未被使用，PHY 初始化数据被编译到应用程序自身中。对于这种过情况，可以将这个分区从分区表中移除，以节约空间。
  - 要从这个分区表中加载 PHY 数据，运行 ``make menuconfig`` 并使能 "Component Config" -> "PHY" -> "Use a partition to store PHY init data"。你还需要给你的设备烧写 phy 初始化数据，因为 esp-idf 的编译系统默认不会自动完成该操作。
- nvs (2) 用于 :doc:`非易失性存储器 (NVS) API <../api-reference/storage/nvs_flash>`。

  - NVS 用于存储每个设备的 PHY 校验数据（与初始化数据不同）。
  - NVS 用于存储 Wifi 数据（如果使用了 :doc:`esp_wifi_set_storage(WIFI_STORAGE_FLASH) <../api-reference/wifi/esp_wifi>` 初始函数）。
  - NVS 也可以用于其它应用程序数据。
  - 强烈建议在你的工程中包含一个大于 0x3000 字节的 NVS 分区。
  - 如果想要使用 NVS API 来存储大量数据，请增加 NVS 分区表的大小（默认是 0x6000 字节）。

其它数据子类型保留。

偏移量 & 大小
~~~~~~~~~~~~~~~~~~~~~~~

只有第一个偏移字段是需要的（我们推荐使用 0x10000）。偏移量为空白的分区将会自动跟在前一个分区的后面。

应用程序分区必须对齐到 0x10000 (64K)。如果它的偏移量字段为空白，工具将会自动让给分区对齐。如果你指定了一个未对齐的偏移量，工具将会返回一个错误。

大小和偏移量可以以十进制形式指定，也可以以 0x 为前缀的十六进制形式指定，或者以 K 或 M 作为单位指定（分别是 1024 和 1024*1024 字节）。

产生二进制分区表
------------------------------

烧写到 ESP32 中的分区表是二进制格式的，而不是 CSV。工具 :component_file:`partition_table/gen_esp32part.py` 可用于将分区表在 CSV 和二进制格式之间进行转化。

如果你在``make menuconfig`` 中配置了 CSV 名字，然后 ``make partition_table``，则在编译过程会自动进行转化。

手工将 CSV 转化为二进制格式 ::

  python gen_esp32part.py --verify input_partitions.csv binary_partitions.bin

将二进制转换回 CSV ::

  python gen_esp32part.py --verify binary_partitions.bin input_partitions.csv

如果需要在标志输出中显示二进制分区表的内容（这就是运行 `make partition_table` 时所产生的信息） ::

  python gen_esp32part.py binary_partitions.bin

``gen_esp32part.py`` 有一个可选参数 ``--verify``，它会在转化期间校验分区表（检查重叠分区、为对齐分区等）。

烧写分区表
--------------------------

* ``make partition_table-flash``: 将会使用 esptool.py 烧写分区表。
* ``make flash``: 将会烧写包括分区表在内的所有东西。
 
``make partition_table`` 时也会打印手工烧写命令。

注意，更新分区表不会擦除老的分区表所存储的数据。你可以使用命令 ``make erase_flash`` (或 ``esptool.py erase_flash``) 擦除整个 flash 的内容。

.. _secure boot: security/secure-boot.rst
