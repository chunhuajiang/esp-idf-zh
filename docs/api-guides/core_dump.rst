ESP32 的 Core Dump
====================

ESP-IDF 支持在遇到不可恢复的软件错误时产生 core dump。这项有用的技术允许发生错误后再分析软件的状态。程序一旦崩溃，系统将进入 panic 状态，打印一些信息并挂起或者重启系统（依赖于配置）。用户可以选择产生 core dump 文件，从而可以在随后在 PC 上分析失败的原因。Core dump 中包含失败的那一刻系统中所有任务的快照。快照包括导致系统崩溃的线程的调用栈（callstack）。 ESP-IDF 提供了一个特殊的脚本 `espcoredump.py` 用于帮助用户恢复和分析 core dump。该工具提供了两个用于分析 core dump 的命令：

* info_corefile - 打印崩溃任务的寄存器、调用栈、系统有效任务列、内存区域以及存储在 core dump 中的内存中的内容（任务控制块 TCB 和栈）。
* dbg_corefile - 创建 core dump ELF 文件，并使用这个文件运行 GDB 调试会话。用户可以人工检查内存、变量和任务状态。需要注意的是，由于不是所有的内容都存放在 cour dump 中，只有分配到栈上的变量值才有意义。

配置
-------------

存在许多与 core dump 相关的配置选项，用户可以在应用程序的配置菜单中进行选择（`make menuconfig`）。

1. Core dump 数据目的地 (`Components -> ESP32-specific config -> Core dump destination`):

* 禁止产生 core dump
* 将 core dump 保存到 flash
* 将 core dump 打印到 UART

2. core dump 模块的日志级别 (`Components -> ESP32-specific config -> Core dump module logging level`)。该值是一个从 0（无输出）到 5（最多输出）之间的一个数字。

3. 将 core dump 打印到 UART 之前的延迟 (`Components -> ESP32-specific config -> Core dump print to UART delay`)。该值以 ms 为单位。


保存 core dump 到 flash
-----------------------

当该值被选择时，core dump 会被保存到 flash 上面的某个特殊分区。当使用 ESP-IDF 提供的默认分区表文件时，它将在 flash 上面自动分配所需空间。但是如果用户希望使用自己的带有 core dump 功能的布局文件，则应当像下面这样定义独立的分区表 ::

  # Name,   Type, SubType, Offset,  Size
  # Note: if you change the phy_init or app partition offset, make sure to change the offset in Kconfig.projbuild
  nvs,      data, nvs,     0x9000,  0x6000
  phy_init, data, phy,     0xf000,  0x1000
  factory,  app,  factory, 0x10000, 1M
  coredump, data, coredump,,        64K

分区表名没有特殊的需求，它可以根据用户应用程序的需要进行选择，但是分区表类型应当选择为 'data'，子类型应当选择为 'coredump'。此外，选择分区表大小的时候需要注意，core dump 的数据结构会引进一些额外的开销，包括固定 20 字节加上每个任务 12 字节。这个开销不包括每个任务的 TCB 大小和栈空间。因此，分区表的大小应当至少为 20 + 最大任务数量 x (12 + TCB 大小 + 任务最大栈大小) 字节。

从 flash 上面分析 core dump 的常用命令是： `espcoredump.py -p </path/to/serial/port> info_corefile </path/to/program/elf/file>`
或者 `espcoredump.py -p </path/to/serial/port> dbg_corefile </path/to/program/elf/file>`

打印 core dump 到 UART
-----------------------

当该选项被选择时，系统 panic 时会将按照 base64 编码的 core dump 打印到 UART 上。在这种情况下，用户需要手工将这些 core dump 文本的 body 保存到某个文件中，然后运行如下的目录： `espcoredump.py info_corefile -t b64 -c </path/to/saved/base64/text> </path/to/program/elf/file>`
或者 `espcoredump.py dbg_corefile -t b64 -c </path/to/saved/base64/text> </path/to/program/elf/file>`

按照 base64 编码的 core dump 的 body 位于下面的头部和尾部之间 ::

 ================= CORE DUMP START =================
 <body of base64-encoded core dump, save it to file on disk>
 ================= CORE DUMP END ===================

运行 'espcoredump.py'
------------------------------------

命令的常用语法：

`espcoredump.py [options] command [args]`

:Script Options:
    * --chip,-c {auto,esp32}. 目标芯片类型。支持的值包括 `auto` 和 `esp32`。
    * --port,-p PORT. 串口设备。
    * --baud,-b BAUD. 当 flashing/reading 时的串口波特率。
:Commands:
    * info_corefile. 恢复 core dump 并打印有用的信息。
    * dbg_corefile. 恢复 core dump 并使用它启动 GDB 会话。
:Command Arguments:
    * --gdb,-g GDB.                 用于恢复数据的 gdb 的路径。
    * --core,-c CORE.               待使用的 core dump 文件的路径（如果省略，则会从 flash 上面读取 core dmup）。
    * --core-format,-t CORE_FORMAT. 指定通过 "-c" 参数传递的文件是 ELF ("elf") 格式，还是 dump 原始二进制格式 ("raw")，还是按照 base64 编码的("b64") 格式。
    * --off,-o OFF.                 coredump 分区在 flash 中的偏移（输入 "make partition_table" 可以直接查看）。
    * --save-core,-s SAVE_CORE.     将 core 保存到文件中，否则临时的 core 文件将会被删除。Ignored with "-c".
    * --print-mem,-m                打印内存 dump。值在 "info_corefile" 时有用。
