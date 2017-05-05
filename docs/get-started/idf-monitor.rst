***********
IDF Monitor
***********

idf_monitor 是一个用 Python 编写的工具程序。当你在 IDF 中调用 ``make monitor`` 目标时，该程序会被执行。

idf_monitor 的主要功能是进行串口通信，将串行数据转发到目标设备的串行端口或者或者获取端口中传递出来的数据。此外，它还有一些其它的与 IDF 相关的功能。

与 idf_monitor 交互
============================

- ``Ctrl-]`` 将退出 monitor。
- ``Ctrl-T Ctrl-H`` 将显示一个带有键盘快捷键的帮助菜单。
- 除 ``Ctrl-]`` 和 ``Ctrl-T`` 之外的其它键都会通过串行端口发送出去。

对地址自动解码
================================

在任何时候，只要 esp-idf 打印出类似于 ``0x4_______`` 形式的十六进制代码时，idf_monitor 都会使用 addr2line_ 来查看源代码的位置和函数名。

.. highlight:: none

当 esp-idf 的应用程序 crash 或者 panic 时，将会产生一个像下面这样的寄存器 dump 和 backtrace ::

    Guru Meditation Error of type StoreProhibited occurred on core  0. Exception was unhandled.
    Register dump:
    PC      : 0x400f360d  PS      : 0x00060330  A0      : 0x800dbf56  A1      : 0x3ffb7e00
    A2      : 0x3ffb136c  A3      : 0x00000005  A4      : 0x00000000  A5      : 0x00000000
    A6      : 0x00000000  A7      : 0x00000080  A8      : 0x00000000  A9      : 0x3ffb7dd0
    A10     : 0x00000003  A11     : 0x00060f23  A12     : 0x00060f20  A13     : 0x3ffba6d0
    A14     : 0x00000047  A15     : 0x0000000f  SAR     : 0x00000019  EXCCAUSE: 0x0000001d
    EXCVADDR: 0x00000000  LBEG    : 0x4000c46c  LEND    : 0x4000c477  LCOUNT  : 0x00000000

    Backtrace: 0x400f360d:0x3ffb7e00 0x400dbf56:0x3ffb7e20 0x400dbf5e:0x3ffb7e40 0x400dbf82:0x3ffb7e60 0x400d071d:0x3ffb7e90

idf_monitor 将会增加 dump ::

    Guru Meditation Error of type StoreProhibited occurred on core  0. Exception was unhandled.
    Register dump:
    PC      : 0x400f360d  PS      : 0x00060330  A0      : 0x800dbf56  A1      : 0x3ffb7e00
    0x400f360d: do_something_to_crash at /home/gus/esp/32/idf/examples/get-started/hello_world/main/./hello_world_main.c:57
    (inlined by) inner_dont_crash at /home/gus/esp/32/idf/examples/get-started/hello_world/main/./hello_world_main.c:52
    A2      : 0x3ffb136c  A3      : 0x00000005  A4      : 0x00000000  A5      : 0x00000000
    A6      : 0x00000000  A7      : 0x00000080  A8      : 0x00000000  A9      : 0x3ffb7dd0
    A10     : 0x00000003  A11     : 0x00060f23  A12     : 0x00060f20  A13     : 0x3ffba6d0
    A14     : 0x00000047  A15     : 0x0000000f  SAR     : 0x00000019  EXCCAUSE: 0x0000001d
    EXCVADDR: 0x00000000  LBEG    : 0x4000c46c  LEND    : 0x4000c477  LCOUNT  : 0x00000000

    Backtrace: 0x400f360d:0x3ffb7e00 0x400dbf56:0x3ffb7e20 0x400dbf5e:0x3ffb7e40 0x400dbf82:0x3ffb7e60 0x400d071d:0x3ffb7e90
    0x400f360d: do_something_to_crash at /home/gus/esp/32/idf/examples/get-started/hello_world/main/./hello_world_main.c:57
    (inlined by) inner_dont_crash at /home/gus/esp/32/idf/examples/get-started/hello_world/main/./hello_world_main.c:52
    0x400dbf56: still_dont_crash at /home/gus/esp/32/idf/examples/get-started/hello_world/main/./hello_world_main.c:47
    0x400dbf5e: dont_crash at /home/gus/esp/32/idf/examples/get-started/hello_world/main/./hello_world_main.c:42
    0x400dbf82: app_main at /home/gus/esp/32/idf/examples/get-started/hello_world/main/./hello_world_main.c:33
    0x400d071d: main_task at /home/gus/esp/32/idf/components/esp32/./cpu_start.c:254

对于上面到结果，idf_monitor 其实在后台运行了下面的命令来对每个地址进行解码的 ::

  xtensa-esp32-elf-addr2line -pfia -e build/PROJECT.elf ADDRESS

为 GDBStub 加载 GDB
======================

默认情况下，如果 esp-idf 应用程序崩溃（crash）了，panic handler 会打印像上面展示的寄存器和栈 dump 消息，然后复位。

可选地，panic handler 可以被配置为去运行一个串行 “gdb stub”。“gdb stub” 可以与 gdb_ 调试程序通信，从而对内存进行读取，对变量和栈帧进行检查等等。这种功能虽然不如 JTAG 那样强大，但是不需要额外的硬件即可完成。

要使能 gdbstub，请运行 ``make menuconfig`` 并进入 ``Component config`` -> ``ESP32-specific`` -> ``Panic handler behaviour``，然后将其设为 ``Invoke GDBStub``。

如果该选项被使能且 idf_monitor 能看到 gdb stub，则它会暂停监视串口并使用正确的参数运行 GDB。当 GDB 退出后，板子会通过 RST 串行线复位（如果连接了该线）。

在这北湖，idf_monitor 运行了如下目录 ::

  xtensa-esp32-elf-gdb -ex "set serial baud BAUD" -ex "target remote PORT" -ex interrupt build/PROJECT.elf


快速编译和烧写
=======================

键盘快捷键 ``Ctrl-T Ctrl-F`` 会暂停 idf_monitor 并运行 ``make flash`` 目标，然后恢复 idf_monitor。任何有改动的源文件都会在重新烧写前被重新编译。

键盘快捷键 ``Ctrl-T Ctrl-A`` 会暂停 idf-monitor 鳖你个运行 ``make app-flash`` 目标，然后恢复 idf_monitor。.这与 ``make flash`` 很相似，但是只会编译和重新烧写 main app。

快速复位
===========

键盘快捷键 ``Ctrl-T Ctrl-R`` 会通过 RTS 线对开发板进行复位（如果连接了该线）。


Simple Monitor
==============

早期版本的 ESP-IDF 使用 pySerial_ 命令行程序 miniterm_ 作为串口控制台程序。

这个程序选择任然可以运行，通过 ``make simple_monitor`` 命令。

idf_monitor 是基于 miniterm 的，它共享了相同的键盘快捷键。


idf_monitor 的已知问题
=============================

在 Windows 上看到的问题
~~~~~~~~~~~~~~~~~~~~~~~~~~

- 如果你在使用 Windows 环境且接收到了错误 "winpty: command not found"，需要运行 ``pacman -S winpty`` 来修复该错误。
- 方向键或者一些其它的特殊键在 gdb 中不工作，这是又有 Windows 控制台的限制。
- 有时候，当 "make" 退出时，它可能最高暂停 30 秒才能恢复 idf_monitor。
- 有时候，当 "gdb" 运行时，它可能会暂停一会儿才能与 gdbstub 通信。

.. _addr2line: https://sourceware.org/binutils/docs/binutils/addr2line.html
.. _gdb: https://sourceware.org/gdb/download/onlinedocs/
.. _pySerial: https://github.com/pyserial/pyserial
.. _miniterm: http://pyserial.readthedocs.org/en/latest/tools.html#module-serial.tools.miniterm
