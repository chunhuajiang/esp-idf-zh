看门狗
=========

概述
--------

Esp-idf 支持两种类型的看门狗：任务看门狗和中断看门狗。二者都可以通过使用 ``make menuconfig`` 进行配置和选择恰当的选项。

中断看门狗
^^^^^^^^^^^^^^^^^^

中断看门狗可以确保 FreeRTOS 任务切换中断不会被阻塞太长时间。否则这是非常糟糕的，因为没有其它任务（包括相当重要的任务，比如 WiFi 任务和空转任务）能够获取到任何 CPU 时间。如果在中断被禁止时，程序运行到了无线循环，或者程序在中断中被挂起，则任务切换将会阻塞。

中断看门狗的默认行为是调用 panic handler。产生寄存器 dump 可以帮助程序员（使用 OpenOCD 或者 gdbstub）查看代码的问题。也可以通过配置 panic handler，让它直接对 CPU 进行复位，这更适合于实际产品环境。

中断看门狗被编译到定时器组 1 的赢硬件看门狗中。如果该看门狗由于某些原因例如 IRAM 被垃圾数据覆盖）不能执行调用 panic handler 的 NMI handler，它它将对 SoC 进行硬复位。

任务看门狗
^^^^^^^^^^^^^

任何任务都可以被任务看门狗看守。如果这个任务没有在任务看门狗所指定的超时时间（可以通过 ``make menuconfig`` 配置）内喂狗，看门狗将会打印警告消息 —— 哪些任务正在 ESP32 CPU 上面运行，哪些任务没有喂狗。

默认情况下，任务看门狗会看守空转（idle）任务。空转任务没有喂狗的原因通常是某个高优先级任务在处理循环，没有退出到低优先级任务，这可以作为有害代码（外设的 spinloop 或者陷入无线循环的任务）的指示器。

其它任务可以通过调用 ``esp_task_wdt_feed()`` 让该任务别任务看门狗看守。第一次调用这个函数时会将该任务注册到任务看门狗中；后续的调用会喂狗。如果任务不想再被看守（例如任务完成了，即将调用 ``vTaskDelete()``），则可以调用 ``esp_task_wdt_delete()``。

看门狗任务被编译到定时器组 0 的赢硬件看门狗中。如果这个看门狗由于某些原因（例如 IRAM 被垃圾数据覆盖、中断被完全禁止等）不能执行用于打印任务数据的中断 handler，它将对 SoC 进行硬复位。

JTAG 和看门狗
^^^^^^^^^^^^^^^^^^

在使用 OpenOCD 进行调试时，如果 CPU 被挂起，看门狗会继续运行，最终会复位 CPU。这导致调试代码变得非常困难；这也是为什么 OpenOCD 配置会在启动时禁止所有看门狗的原因。也就是说，当 ESP32 通过 JTAG 连接到 OpenOCD 时，你不会看到由任务看门狗或中断看门狗打印的如何警告和 panic。

API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`esp32/include/esp_int_wdt.h`
  * :component_file:`esp32/include/esp_task_wdt.h`


函数
---------

.. doxygenfunction:: esp_int_wdt_init
.. doxygenfunction:: esp_task_wdt_init
.. doxygenfunction:: esp_task_wdt_feed
.. doxygenfunction:: esp_task_wdt_delete
