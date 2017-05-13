日志库
===============

概述
--------

日志库有两种方式管理日志的可见性：编译时和运行时。编译时是通过配置菜单实现的；运行时是通过函数 ``esp_log_level_set`` 实现的。

在编译时，日志的过滤是通过配置菜单的宏 ``CONFIG_LOG_DEFAULT_LEVEL`` 完成的。所有日志级别大于 ``CONFIG_LOG_DEFAULT_LEVEL`` 的语句都会被预处理器移除。

在运行时，级别在 ``CONFIG_LOG_DEFAULT_LEVEL`` 以下的日志默认都被使能。函数 ``esp_log_level_set`` 可以用于设置每个模块的日志级别。模块通过它们的标签（tags）进行标识。标签是人类可识别的以 '\0' 作为结尾的字符串。

如何使用日志库
-----------------------

在每个需要使用日志功能的 C 源文件中，按照类似下面的这种方式定义 TAG 变量：

.. code-block:: c

   static const char* TAG = "MyModule";

然后使用以下其中一个宏来产生输出，例如：

.. code-block:: c

   ESP_LOGW(TAG, "Baud rate error %.1f%%. Requested: %d baud, actual: %d baud", error * 100, baud_req, baud_real);

下面的几个宏可用于输出不同的日志级别：

* ``ESP_LOGE`` - 错误/error
* ``ESP_LOGW`` - 警告/warning
* ``ESP_LOGI`` - 信息/info
* ``ESP_LOGD`` - 调试/debug
* ``ESP_LOGV`` - 啰嗦/verbose

此外，上面的每一种宏还存在一种 _EARLY_ 变种，例如 ``ESP_EARLY_LOGE``。这些变种可以运行在启动代码中，在堆分配器和 syscall 被初始化之前。在编译 bootloader 时，常规的宏 ``ESP_LOGx`` 将会退化为对应的宏 ``ESP_EARLY_LOGx``。因此，需要明确使用 ``ESP_EARLY_LOGx`` 的地方是早起的启动代码，例如堆分配器的初始化代码。


（注意，如果我们在 ROM 中有 ``ets_vprintf`` 函数，则不需要进行这样的区分，可以直接将 _EARLY_ 版的宏切换为普通版的宏。不幸的是，ROM 中的 ``ets_vprintf`` 会被编译器内链为 ``ets_printf``，因此在外部不可访问）


如果想在文件或者组件内覆盖默认的可视级别，可以在文件或组件内定义一个 ``LOG_LOCAL_LEVEL`` 宏。如果是在文件内，该宏的定义需要在包含头文件 ``esp_log.h`` 之前，例如：

.. code-block:: c

   #define LOG_LOCAL_LEVEL ESP_LOG_VERBOSE
   #include "esp_log.h"

如果是在组件内，则需要在组件的 makefile 中定义：

.. code-block:: make

   CFLAGS += -D LOG_LOCAL_LEVEL=ESP_LOG_DEBUG

如果需要在运行时为每个模块配置日志输出，则直接调用函数 ``esp_log_level_set`` ：

.. code-block:: c

   esp_log_level_set("*", ESP_LOG_ERROR);        // set all components to ERROR level
   esp_log_level_set("wifi", ESP_LOG_WARN);      // enable WARN logs from WiFi stack
   esp_log_level_set("dhcpc", ESP_LOG_INFO);     // enable INFO logs from DHCP client

通过 JTAG 将日志输出到主机
^^^^^^^^^^^^^^^^^^^^^^^^

默认情况下，日志库会使用类 vprintf 函数将格式化消息输出到专用的 UART 中。通常，这会涉及到以下步骤：

1. 解释格式化字符串，以获取每个参数的类型。
2. 根据每个参数的类型，将其转换成字符串形式。
3. 格式化字符串和转换后的参数被发送到 UART。

尽管类 vprintf 函数的实现可以被优化到一定的级别，但是在所有情形下都需要执行上面到步骤，且每个步骤（尤其是第三项）都需要花一定的时间。
So it is frequent situation when addition of extra logging to the program to diagnose some problem changes its behaviour and problem dissapears。或者在最差的情形，程序最终可能会发送错误以致完全不能工作，甚至直接挂起。克服这个问题的可用的办法是使用一个更快的 UART 波特率（或者使用另一个更快的接口）和/或将将字符串格式化过程转移到主机上。ESP IDF 有一个 `应用程序跟踪（Application Tracing）` 功能，它允许通过 JTAG 将任意的应用程序数据发送到主机。这个功能也可哟通过使用函数 ``esp_apptrace_vprintf`` 将日志信息传输到主机。这个函数不会对格式化字符串和参数执行完整的解释，相反，它仅仅计算传递的参数的数量，并将其与格式话字符串的地址一起发送到主机。在主机上，日志数据会被一个特俗的 Python 脚本处理并打印。

配置选项和依赖
"""""""""""""""""""""""""""""""

使用这个功能依赖于两个组件：

1.主机侧： 应用程序跟踪是由 JTAG 完成的，所以需要在主机上配置并运行 OpenOCD。关于如何配置的指令，请阅读 :idf:`为 ESP32 设置 OpenOCD` 一节。**NOTE:** `为了达到更高的数据速率，你需要在 OpenOCD 的配置文件中修改 JTAG 适配器的工作频率。经测试，最大的稳定速度是 26MHz，因此你需要在你的配置文件中使用` ``adapter_khz 26000`` `替换默认的` ``adapter_khz 200``。 `JTAG 的实际的最大稳定频率依赖于主机系统的配置。`
2. 目标侧：应用程序跟踪功能可以在配置菜单中通过宏 ``CONFIG_ESP32_APPTRACE_ENABLE`` 进行使能。该选项会使能该模块，并让 ``esp_apptrace_vprintf`` 对所有用户有效。

限制
"""""""""""

当前，通过 JTAG 打印日志消息有如下几点限制：

1. 不支持对 ``ESP_EARLY_LOGx`` 宏的跟踪。
2. 不支持参数（例如 ``double`` 和 ``uint64_t``）超过 4 个字节的 printf。
3. 仅支持 .rodata 段中的字符串用过格式化字符串和参数。
4. printf 参数的最大数量是 256。

如何使用
""""""""""""

要使用 JTAG 输出日志，你需要执行以下步骤：

1. 在目标侧，需要安装特定的类 vprintf 函数。正如之前提到的，这个函数是 ``esp_apptrace_vprintf``。它会通过 JTAG 向主机发送日志数据。示例代码如下：

.. code-block:: c

    #include "esp_app_trace.h"
    ...
    void app_main()
    {
        // set log vprintf handler
        esp_log_set_vprintf(esp_apptrace_vprintf);
        ...
        // user code using ESP_LOGx starts here
        // all data passed to ESP_LOGx are sent to host
        ...
        // restore log vprintf handler
        esp_log_set_vprintf(vprintf);
        // flush last data to host
        esp_apptrace_flush(ESP_APPTRACE_DEST_TRAX, 100000 /*tmo in us*/);
        ESP_LOGI(TAG, "Tracing is finished."); // this will be printed out to UART
        while (1);
    }

2. 按照 :idf:`Developing With the ESP-IDF` 一节中的方法编译应用程序镜像并将其下载到目标板中。
3. 运行 OpenOCD （参考 :idf:`OpenOCD setup for ESP32` 一节）。
4. 连接到 OpenOCD telnet 服务器。在 Linux 上，你可以在终端中使用命令 ``telnet <oocd_host> 4444``。如果运行 telnet 会话的主机就是你运行 OpenOCD 的同一个主机，你可以在该命令中直接使用 `localhost` 作为 `<oocd_host>`。
5. 在 OpenOCD telnet 会话中运行如下命令： ``esp108 apptrace start /path/to/trace/file -1 -1 0 0 1``。这个命令会等待板子复位，并以最高的速率传输跟踪数据。
6. 将开发板复位。日志会自动发送到主机。
7. 使用上面参数的命令 ``esp108 apptrace`` 永远不会返回（参考下面的命令选项），因此你必须手动停止，可以通过复位开发板或者在 OpenOCD 窗口（不是运行 telnet 会话的窗口）按下 CTRL+C。
8. 当调试完成后（例如对于上面的示例代码，指的是当 `"Tracing is finished."` 出现在 UART 后），将开发板复位，或者在 OpenOCD 窗口不是运行 telnet 会话的窗口）按下  CTRL+C。 
9. 如果要打印所采集的日志记录，在终端中运行如下命令： ``$IDF_PATH/tools/esp_app_trace/logtrace_proc.py /path/to/trace/file /path/to/program/elf/file``。

OpenOCD 应用程序跟踪命令的选项
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

命令的用法：
``esp108 apptrace [start <outfile> [options] | [stop] | [status] | [dump <outfile>]``

子命令：
  * ``start``.  启动跟踪 (continuous streaming).
  * ``stop``.   停止跟踪
  * ``status``. 获取跟踪状态
  * ``dump``.   Dump 尽量多的数据，不需要等待跟踪内存块切换 (post-mortem dump).

启动命令的语法：
  ``start <outfile> [trace_size [stop_tmo [skip_size [poll_period [wait4halt]]]]]``

  .. list-table::
    :widths: 20 80
    :header-rows: 1

    * - 参数
      - 描述
    * - outfile
      - 用于保存数据的日志跟踪文件的路径
    * - trace_size
      - 最大的数据大小（以字节为单位）。当接收到指定数量的数据后，跟踪会自动停止。默认是 -1（跟踪停止触发器被禁止）
    * - stop_tmo
      - 空转超时（以 ms 为单位）Idle。如果在指定的时间内没有接收到数据，跟踪会自动停止。默认是 10s（-1 用于禁止跟踪停止触发器）
    * - skip_size
      - 在开始需要跳过的字节数。默认是 0。
    * - poll_period
      - 数据轮询周期（以 ms 为单位）。如果大于 0，该命令会以非阻塞模式运行，否则除非跟踪停止，程序会一直占据命令行。默认是 1 ms。
    * - wait4halt
      - 如果是 0，立即跟踪，否则，该命令会等待目标板挂起（复位后，断电等），然后自动恢复并开始跟踪。默认是 0。
       0.    

日志跟踪处理命令的选项
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

命令的用法：
``logtrace_proc.py [-h] [--no-errors] <trace_file> <elf_file>``

必选参数：

  .. list-table::
    :widths: 20 80
    :header-rows: 1

    * - 参数
      - 描述
    * - trace_file
      - 日志跟踪文件的路径
    * - elf_file
      - 程序 ELF 文件的路径

可选参数：

  .. list-table::
    :widths: 20 80
    :header-rows: 1

    * - 参数
      - 描述
    * - -h, --help
      - 显示本帮助信息并退出
    * - --no-errors, -n
      - 不打印错误

