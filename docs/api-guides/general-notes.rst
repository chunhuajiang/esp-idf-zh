关于 ESP-IDF 编程的通用说明
=======================================

应用程序启动流程
------------------------

本文档解释了在 ESP-IDF 应用程序的 ``app_main`` 被调用前的各个步骤。

启动过程的顶层视图如下：

1. 在 ROM 中的第一阶段的 bootloader 从 flash 偏移地址 0x1000 处加载第二阶段的 bootloader 到 RAM 中。
2. 第二阶段的 bootloader 从 flash 上面加载分区表和主应用程序镜像。主应用程序包含 RAM 段和通过 flash cacha 映射的只读段。
3. 主应用程序镜像开始执行。此时，第二个 CPU 以及 RTOS 调度器开始启动。

下面将详细介绍这个过程。

第一阶段的 bootloader
^^^^^^^^^^^^^^^^^^^^^^

SoC 复位后，PRO CPU 将会立即运行，并执行复位向量代码；此时 APP CPU 将会保持在复位状态。在启动过程中，PRO CPU 将会完成所有的初始化工作。APP CPU 由应用程序启动代码中的函数 ``call_start_cpu0`` 解除复位。复位向量表位于 ESP32 芯片的 mask ROM 中的地址 0x40000400 处，且不能被修改。

启动代码会被复位代码调用，然后通过检查寄存器 ``GPIO_STRAP_REG``（bootstrap 引脚状态）来判断启动模式。根据复位原因的不同，可能会发生如下的行为：

1. 从深度睡眠中复位：如果在 ``RTC_CNTL_STORE6_REG`` 中的值非零，且在 ``RTC_CNTL_STORE7_REG`` 中的 RTC 内存中的 CRC 值是有效的，则使用 ``RTC_CNTL_STORE6_REG`` 作为入口点地址，并立即跳转到该地址。如果 ``RTC_CNTL_STORE6_REG`` 是零，或者 ``RTC_CNTL_STORE7_REG`` 包含无效的 CRC，或者通过 ``RTC_CNTL_STORE6_REG`` 调用的代码立即返回了，则将这次启动作为上电复位启动。
**Note**: 如果要在此时运行自定义的代码，可以使用所提供的深度睡眠 stub 机制。具体细节请参考文档 :doc:`深度睡眠 <deep-sleep-stub>` 。

2. 对于上电复位，软件 SoC 复位，以及看门狗 SoC 复位：如果请求了 UART 或 SDIO 下载模式，则检查寄存器 ``GPIO_STRAP_REG``。对于这种情形，会配置 UART 或者 SDIO，并等待下载代码。否则，将这次启动作为软件 CPU 复位。

3. 对于软件 CPU 复位和看门狗 CPU 复位：基于 EFUSE 的值配置 SPI，并尝试从 flash 中加载代码。这一步的更多细节将在下一段中进行描述。如果从 flash 中加载代码失败，则将基本的解释器解压缩到 RAM 中并启动它。注意，此时 RTC 看门狗依然是使能的，所以除非从解释器中接收到输入，否则看门狗将会在几百毫秒后复位 SoC，然后重复整个过程。如果解释器从 UART 接收到了输入，则它会禁止看门狗。

应用程序镜像被加载到 flash 的地址 0x10000 处。flash 的前 4 KB 扇区用于存储安全启动 IV 和应用程序镜像签名。更多细节请参考安全启动文档。

.. TODO: 描述应用程序镜像格式，描述可选 flash 配置命令。

第二阶段的 bootloader
^^^^^^^^^^^^^^^^^^^^^^^

在 ESP-IDF 中，flash 的地址 0x1000 处存储的二进制镜像就是第二阶段的 bootloader。第二阶段的 bootloader 源代码位于 ESP-IDF 的 components/bootloader 目录下。注意，这种做法只是 ESP32 芯片的一种实现方法，你也可以直接将一个具有完整功能的应用程序镜像烧写到地址 0x1000 处，不过这超出了本文当的讨论范围。ESP-IDF 使用第二阶段的 bootloader 的好处是可以实现灵活地添加 flash 布局（使用分区表），允许实现与 flash 加密相关的各种流程、安全启动以及空中升级（OTA）。

当第一阶段的 bootloader 完成后，ESP32 会检查并加载第二阶段的 bootloader，跳转到在二进制镜像头部中找到的第二阶段 bootloader 的入口点。

第二阶段的 bootloader 会阅读位于偏移量 0x8000 处的分区表。更多信息请参考 :doc:`分区表 <partition-tables>`。bootloader 会找到工厂分区和 OTA 分区，然后基于 *OTA info* 分区中的信息判断启动哪个分区。

对于所选择的分区，第二阶段的 bootloader 会将数据段和映射到 IRAM/DRAM 中的代码段拷贝到它们对应的加载地址。对于加载地址在 IRAM/DROM 范围内的段，ESP32 会通过所提供的正确的映射来配置 flash MMU。需要注意的是，第二阶段的 bootloader 会同时为 PRO CPU 和 APP CPU 同时配置 flash MMU，但是只会使能 PRO CPU 的 flash MMU。这样做的原因是第二阶段的 bootloader 代码被加载到了由 APP CPU cache 所使用的内存范围内了。使能 APP CPU cache 的任务被移交给应用程序了。当代码被加载、flash MMU 被设置后，第二阶段的 bootloader 会跳转到由二进制镜像头部中指定的应用程序入口点。

当前不能向 bootloader 中添加由应用程序指定的钩子，因此不能自定义应用程序的分区选择逻辑。但是这可能是需要的，例如，根据某个 GPIO 的状态来加载不同的应用程序镜像。今后会将这种自定义功能添加到 ESP-IDF 中。目前为止，如果你需要自定义 bootloader，可以将 bootloader 组件拷贝懂啊应用程序目录，然后做相应的修改。对于这种情况，ESP-IDF 的编译系统会在应用程序目录编译该组件，而不会在 ESP-IDF 的组件目录中编译它。

应用程序启动
^^^^^^^^^^^^^^^^^^^

ESP-IDF 应用程序的入口点是 ``components/esp32/cpu_start.c`` 中的函数 ``call_start_cpu0``。该函数主要做了两件事儿：使能堆分配器以及让 APP CPU 跳转到它的入口点 ``call_start_cpu1``。在 PRO CPU 上面的代码会设置 APP CPU 的入口点，激活 APP CPU 的复位，并等待由 APP CPU 中的代码设置一个表示它已启动的全局标志。完成后，PRO CPU 会跳转到函数 ``start_cpu0``，APP CPU 会跳转到函数 ``start_cpu1``。

``start_cpu0`` 和 ``start_cpu1`` 都是虚函数。这意味着，如果应用程序需要改变初始化序列，可以直接在应用程序中覆盖这两个函数。``start_cpu0`` 默认会根据 ``menuconfig`` 中的选项使能/初始化对应的组件。具体请在 ``components/esp32/cpu_start.c`` 中参考该函数的实现。注意，应用程序中的所有 C++ 全局构造器都会在这个阶段被调用。当所有必要组件都初始化后，会创建 *主任务（main task）* 并启动 FreeRTOS 的调度器。

当 PRO CPU 在函数 ``start_cpu0`` 中执行初始化时，APP CPU 会在函数 ``start_cpu1`` 中自旋，等待 PRO CPU 启动调度器。当 PRO CPU 启动调度器后，在 APP CPU 上面的代码也会启动调度器。

主任务就是运行函数 ``app_main`` 的任务。主任务的栈大小和优先级都可以通过 ``menuconfig`` 配置。应用程序可以利用这个任务做一些应用程序相关的初始化，例如启动其它任务。应用程序也可以使用主任务做事件循环以及其它的通过工作。如果函数 ``app_main`` 返回了，主任务会被删除。

.. _memory-layout:

应用程序内存布局
-------------------------

ESP32 芯片具有灵活的内存映射功能。本节描述 ESP-IDF 在默认情况下是如何使用这些功能的。

在 ESP-IDF 中的应用程序代码可以放到下列的内存区域内。

IRAM (指令 RAM)
^^^^^^^^^^^^^^^^^^^^^^

ESP-IDF 从 `Internal SRAM0`（在技术参考手册中定义的） 中分配了部分区域作为指令 RAM。除前 64 kB 块用于 PRO 和 APP CPU cache 之外，这段内存的剩余部分（即从 ``0x40080000`` 到 ``0x400A0000``）用于存储需要直接从 RAM 中运行的应用程序。

ESP-IDF 中的少量组件和部分 WiFi 协议栈就是通过链接脚本放置到这个区域的。

如果某些应用程序的代码需要放置到 IRAM，可以使用 ``IRAM_ATTR`` 进行定义 ::

	#include "esp_attr.h"
	
	void IRAM_ATTR gpio_isr_handler(void* arg)
	{
		// ...		
	}

下面是一些应用程序可能需要放置到 IRAM 中的例子。

- ISR handler 必须被放置到 IRAM。更进一步说，ISR handler 智只能调用放到 IRAM 中的函数和 ROM 中的函数。 *Note 1:* 当前所有的 FreeRTOS API 都是放置到 IRAM 中的，所以可以被 ISR handler 安全调用。*Note 2:* ISR handler 所使用的常量数据（包括但不限于 ``const char``）以及被 ISR 调用的函数都必须通过 ``DRAM_ATTR`` 放到 DRAM 中。

- 某些对时间敏感的代码需要放知道 IRAM 中，这样可以减小从 flash 加载代码的时间。ESP32 通过一个 32 kB 的 cache 读取代码和数据。在某些情况下，将函数放到 IRAM 中可以减小 cache 缺失所造成的延迟。

IROM (从 Flash 执行的代码)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

如果函数没有被明确指明需要放到 IRAM 或者 RTC 内存中，则它会被默认放到 flash 中。 关于使用 flash MMU 来允许从 flash 中执行代码的机制请查阅技术参考手册。ESP-IDF 将需要从 flash 中执行的代码放到 ``0x400D0000 — 0x40400000`` 范围内。启动的时候，第二阶段的 bootloader 会初始化 flash MMU，将 flahs 中代码所处的位置映射到这段区域的起始处。对这段范围的访问将会被显示地缓存到 ``0x40070000`` — ``0x40080000`` 范围内的两个 32kB 块。

注意，位于 ``0x40000000 — 0x40400000`` 范围之外的代码不可由 Window ABI ``CALLx`` 指令获得，因此，如果应用程序使用了  ``0x40400000 — 0x40800000`` 或 ``0x40800000 — 0x40C00000`` 范围，需要特别注意。ESP-IDF 默认不会使用这些区域。

RTC 快速内存
^^^^^^^^^^^^^^^

需要在从深度睡眠唤醒时执行的代码必须被放置到 RTC 内存中，具体细节请参考文档 :doc:`深度睡眠 <deep-sleep-stub>`。

DRAM (数据 RAM)
^^^^^^^^^^^^^^^

非常量静态数据和以 0 初始化的数据别链接器放到一个 256 kB 的范围 ``0x3FFB0000 — 0x3FFF0000`` 内。注意，如果使用了蓝牙协议栈，则则个范围会被缩减到 64 kB（通过将起始位置移位到 ``0x3FFC0000``），如果使用了内存跟踪技术，这个范围的长度会被进一步缩减到 16 kB 或者 32 kB。放置静态数据后所剩余的所有空间将被用于运行时的堆空间。

常量数据也可以被放置到 DRAM 中，例如如果它用于 ISR handler 中（参考上面的 IRAM 章节）。要达到此目的，需要使用 ``DRAM_ATTR`` 进行定义 ::

	DRAM_ATTR const char[] format_string = "%p %x";
	char buffer[64];
	sprintf(buffer, format_string, ptr, val);

不言而喻的是，不用在 ISR handler 中使用 ``printf`` 和其它输出函数。如果需要调试，可以在 ISR 中使用宏 ``ESP_EARLY_LOGx`` 来记录日志。在这种情况下，请确保将 ``TAG`` 和格式化字符串都放入 ``DRAM`` 中。

DROM (存储在 Flash 中的数据)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

默认情况下，常量数据会被链接器放到一个 4 MB（``0x3F400000 — 0x3F800000``） 的范围内，ESP32 通过 Flash MMU 和 cache 在该范围内访问外部 flash。字面量常数是一个例外，它们会被编译器内嵌到应用程序的代码中。

RTC 低速内存
^^^^^^^^^^^^^^^

在 RTC 内存中运行的代码的全局和静态变量必须放到 RTC 慢速内存中，具体细节请查阅文档 :doc:`深度睡眠 <deep-sleep-stub>`。




