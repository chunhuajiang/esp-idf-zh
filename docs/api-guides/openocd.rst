调试
=========

为 ESP32 设置 OpenOCD
-----------------------

ESP321 和 ESP32 带有两个功能强劲的 Xtensa 核，支持大量的程序架构。ESP-IDF 中的 FreeRTOS 具有多核抢占式多线程功能，支持以最直观的方式编写代码。

当然这也带来一个弊端，即当没有合适的工具时，程序的调试变得更加艰难：如果一个 bug 是由两个线程引起的，这两个线程可能会同时运行在两个 CPU 核上，如果你所仅能使用 printf 语句，则调试过程可能会花费你的大量时间。调试这种问题的更好的以及更快速（大多数情形下）的方法是使用一个调试器，将它连接到处理器的调试端口。

乐鑫已经将 OpenOCD 和多核 FreeRTOS 移植到 ESP32 处理器上，并添加了一些 OpenOCD 原生并未支持的有用功能。这些都是免费的，本文档就是用于描述如何安装并使用它们。


JTAG 适配器硬件
---------------------

你需要一个电压值既兼容 ESP32 又兼容 OpenOCD 软件的 JTAG 适配器。ESP32 上面的 JTAG 端口是一个工业级的没有（也不需要）TRST 引脚的 JTAG 端口。JTAG 的 I/O 引脚都通过 VDD_3P3_RTC 引脚进行供电（通常是 3.3 V），因此 JTAG 适配器和 JTAG 引脚应该能在该电压范围内正常工作。在软件方面，OpenOCD 支持大量的 JTAG 适配器，具体的适配器列表（不是太完整）请查阅 http://openocd.org/doc/html/Debug-Adapter-Hardware.html。 该页面也列举了 SWD 兼容的适配器；需要说明的是，ESP32 不支持 SWD。

在乐鑫，我们已经测试了 TIAO USB Multi-protocol 适配器电路板以及 Flyswatter2，这二者都是 USB2.0 的高速设备，具有良好的吞吐量。我们还测试了 J-Link 兼容的适配器以及 EasyOpenJTAG 适配器，它们都能正常工作，不过速度有点慢。

JTAG 工作所需要的最少信号线包括 TDI、TDO、TCK、TMS 和 Gnd。某些 JTAG 适配器还需要将 ESP32 的电源线连接到一根叫做 Vtar 的信号线上，以提供工作电压。另外，还可以将 SRST 可选地连接到 ESP32 的 CH_PD 引脚，OpenOCD 中很少使用该信号线。

安装 OpenOCD
------------------

ESP32 的变体版 OpenOCD 的源码位于 `Espressifs Github <https://github.com/espressif/openocd-esp32>`_，你可以使用下面的命令下载该源码 ::

    git clone --recursive https://github.com/espressif/openocd-esp32.git
    cd openocd-esp32

具体的编译步骤请参考 openocd-esp32 目录下的 README、README.OSX 和 README.Windows。当然，你也可以跳过 ``make install`` 这一步。

在 OpenOCD 中配置 ESP32 目标
---------------------------------------

当 OpenOCD 编译（以及可选地安装）完，JTAG 适配器连接到 ESP32 开发板后，使用 OpenOCD 就以及基本准备就绪了。此外，OpenOCD 还需要知道使用的是什么 JTAG 适配器，以及适配器所连接的是什么开发板和处理器。实现该目的的最简单的方式是使用一个配置文件。在本文档的同一目录下包含一个配置文件模板，你可以这样使用它：

- 将 esp32.cfg 拷贝到 openocd-esp32 目录。
- 编辑所拷贝的文件 esp32.cfg。最重要的是修改 ``source [find interface/ftdi/tumpa.cfg]`` 这一行，它用于说明所连接的物理 JTAG 适配器。
- 打开一个终端，``cd`` 到 openocd-esp32 目录。
- 运行 ``./src/openocd -s ./tcl -f ./esp32.cfg`` 启动 OpenOCD。

然后你将看到类似下面的输出 ::

    user@machine:~/esp32/openocd-esp32$ ./src/openocd -s ./tcl/ -f ../openocd-esp32-tools/esp32.cfg 
    Open On-Chip Debugger 0.10.0-dev-00446-g6e13a97-dirty (2016-08-23-16:36)
    Licensed under GNU GPL v2
    For bug reports, read
    http://openocd.org/doc/doxygen/bugs.html
    none separate
    adapter speed: 200 kHz
    Info : clock speed 200 kHz
    Info : JTAG tap: esp32.cpu0 tap/device found: 0x120034e5 (mfg: 0x272 (Tensilica), part: 0x2003, ver: 0x1)
    Info : JTAG tap: esp32.cpu1 tap/device found: 0x120034e5 (mfg: 0x272 (Tensilica), part: 0x2003, ver: 0x1)
    Info : esp32.cpu0: Debug controller was reset (pwrstat=0x5F, after clear 0x0F).
    Info : esp32.cpu0: Core was reset (pwrstat=0x5F, after clear 0x0F).


- 如果你碰到了关于权限的问题，请查阅 OpenOCD README 文档中的 'Permissions delegation'。
- 如果你碰到了错误 (...all ones/...all zeroes)，请检查你的连线，并确实是否已上电。

将调试器连接到 OpenOCD
--------------------------------

OpenOCD 现在已经准备接受 gdb 连接了。如果你使用 Crosstool-NG 编译好了 ESP32 的工具链，或者从乐鑫官方下载了预编译的工具链，则该工具链中已包含 xtensa-esp32-elf-gdb，你可以直接用该 gdb 进行调试。首先，确保你的想要调试的工程已经被编译并烧写到 ESP32 的 SPI flahs 中了。然后，在另一个控制台（而非运行 OpenOCD 的控制台）中运行 gdb。例如，对于 template app ::

    cd esp-idf-template
    xtensa-esp32-elf-gdb -ex 'target remote localhost:3333' ./build/app-template.elf 

然后它应该会显示 gdb 提示符。

FreeRTOS 的支持
----------------

OpenOCD 已经明确地支持 ESP-IDF FreeRTOS 了；可以在 esp32.conf 中禁止 FreeRTOS 检测。如果使能了 FreeRTOS 检测，gdb 则会将 FreeRTOS 任务当做线程处理。查看这些线程可以使用 gdb 命令 ``i threads``，切换到某个线程可以使用命令 ``thread x``，其中 x 是线程的数字。可以切换到除了正在另一个 CPU 上运行的线程之前的其它所有线程，更多信息请参考 ``ESP32 quirks``。


ESP32 quirks
------------

常规的 gdb 断点（``b myFunction``）只能设置在 IRAM 中，因为这段内存是可写的。在 flash 中的代码中设置这种类型的代码是无效的。它还可以支持两个观察点，因此可以使用 gdb 命令 ``watch myVariable`` 来观察/读取两个变量的改动。


你可以通过改变端口号将 gdb 连接到 APP CPU 或者 PRO CPU。``target remote localhost:3333`` 可以连接到 PRO CPU，``target remote localhost:3334`` 可以连接到 APP CPU。硬件方面，当某个 CPU 由于调试原因被挂起时，另一个 CPU 也会被挂起；恢复也是同时发生的。

由于 gdb 只能看到以所选 CPU 的视角所对应的系统，只有挂起的任务和正在 gdb 所连接的 CPU 上面运行的任务会被正确地显示。另一个 cpu 上面的活动的任务也可以被查看，不过它的状态可能非常不连续。

ESP-IDF 针对 OpenOCD 的各种功能提供了对应的编译选项：可以在第一个线程启动后停止执行执行；当抛出 panic 或者未处理异常后打断系统。这两个选项默认都是使能的，但是可以使用 esp-idf 配置选项对其进行禁止，更多细节请参考 ``make menuconfig`` 菜单。

正常情况下，在 OpenOCD 下面，可以通过向 ddb 中输入 'mon reset' 或 'mon reset halt' 对开发板进行复位。对于 ESP32，这些功能基本都能工作，但是有一些负面影响。首先，OpenoCD 复位只会复位 CPU 核，不会复位外设，因此如果软件依赖了外设复位后的状态，则可能导致产生未定的行为。其次，'mon reset halt' 会在 freeRTOS 初始化前停止，而 OpenOCD 会假设 FreeRTOS 正在运行（默认情况，你也可以编辑 esp32.cfg 进行修改），然后它会变得混淆。


