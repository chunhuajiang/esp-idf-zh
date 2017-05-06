中断分配
====================

概述
--------

ESP32 有两个核（core），每个核有 32 个中断。每个中断有一个确定的优先级，大多数（而非全部）中断被连接到中断复用矩阵中。由于中断源的数量大于中断的数量，因此在必要时可以在多个驱动程序中共享同一个中断。ESP-IDF 中提供了一个 esp_intr_alloc 抽象，它的作用就是隐藏这些实现细节。

驱动程序可以调用 esp_intr_alloc（或 esp_intr_alloc_sintrstatus）为某个外设分配一个中断。它可以通过一个传递给该函数的标志设置所分配中断的类型，指明指定的等级或者触发方法。然后中断分配代码会知道一个可用的中断，使用中断复用矩阵将它与外设挂在一起，并安装驱动程序传递给它的中断 hander 和 ISR。

该代码有两种处理方式不同的中断：共享中断和非共享中断。二者中最简单的是非共享中断：一个独立的中断会在调用 esp_intr_alloc 时被分配，且该中断仅能用于附着到它上面的外设，仅由一个 ISR 会被调用。共享中断可以被多个外设触发，当附着到它上面的某一个外设发送中断信号时，多个 ISR 都会被调用。因此，共享中断的 ISR 应当检查它们所服务的外设的中断状态，以查看是否需要执行任何动作。

非共享中断即可以由电平触发，也可以是边沿触发。共享中断仅能被电平触发（因为使用边沿触发时可能错过中断）。（它内部的逻辑是这样的：设备 A 和设备 B 共享一个中断。设备 B 发出一个中断信号。中断线为高。ISR handler 调用设备 A 的代码 -> 什么也不做。ISR handler 调用设备 B 的代码，但是在此期间，设备 A 发送了一个信号。设备 B 完成处理，清除设备 B 的中断，退出中断代码。现在，设备 A 的中断处于 pending 状态，但是由于中断线没有变为低（即使设备 B 的中断被清除了，设备 A 仍然保持为高），中断永远不会被服务）

多核问题
----------------

可以产生中断的外设可以被分为两类：

  - 外部外设，在 ESP32 上面但是在 Xtensa 核外面。大多数 ESP32 外设都是这种类型。
  - 内部外设，属于 Xtensa CPU 核自身的设备。
  
这两种外设的中断处理有一点点区别。

内部外设中断
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

每个 Xtensa CPU 核都有六个内部外设：

  - 三个 timer 比较器（comparator）
  - 一个性能监视器（monitor）
  - 两个软件中断

内部中断源在 esp_intr_alloc.h 中定义为 ``ETS_INTERNAL_*_INTR_SOURCE``。

这些外设只能由它们所关联的核进行配置。当产生中断时，中断是通过硬连线（hard-wire）连接到它所关联的核；一个核中的中断源（例如内部 timer 比较器）不能在另一个核中产生中断。这就是为什么只能被运行在该核上面的某个任务管理。内部中断源仍然是使用 esp_intr_alloc 进行分配的，但是它们不能进行共享，且总是具有一个固定的中断等级。

外部外设中断
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

剩下的中断源来自外部设备，它们在 soc/soc.h 中定义为 ``ETS_*_INTR_SOURCE``。

两个 CPU 核的非内部中断槽被连接到一个中断复用器上面。中断复用器可以将任何外部中断源引导到它上面的任意中断槽。

- 分配外部中断时总是会将它分配到对它进行分配的那个核上面。
- 释放外部中断时必须发送在它所分配的同一个核上面。
- 可以从另一个核使能/禁止外部中断。
- 多个外部中断源可以通过将 ``ESP_INTR_FLAG_SHARED`` 作为标志参数传递给 esp_intr_alloc() 来共享一个中断槽。

从某个没有固定到一个具体核的任务中调用 esp_intr_alloc() 将不会有效果。在任务切换期时，这些任务可能会在两个核之间迁移。因此，它不能辨别中断被分配到哪个 CPU 上了，从而导致很难释放中断处理，且可能让调试变得更加困难。建议在创建需要分配中断的任务时，使用 xTaskCreatePinnedToCore() 函数，且指定一个参数 CoreID。在内部中断源的时候，这也是需要的。

IRAM-Safe 中断 Handler
----------------------------

使用 ``ESP_INTR_FLAG_IRAM`` 标志注册的中断 handler 将移植在 IRAM 中运行（从 DRAM 中读取它的所有数据），因此不需要在 flash 

这对于那些需要保证最小执行延迟的中断来说是非常有用的，因为 falsh 的写和擦除操作可能比较慢（擦除可能哟啊花几十或几百微秒才能完成）。

如果中断 handler 的调用非常频繁，可以将它放到 IRAM 中，从而避免 flash cache 的遗漏。

更多细节请cake :ref:`SPI flash API 文档 <iram-safe-interrupt-handlers>`。

应用程序示例
-------------------

API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`esp32/include/esp_intr_alloc.h`


宏
^^^^^^

.. doxygendefine:: ESP_INTR_FLAG_LEVEL1
.. doxygendefine:: ESP_INTR_FLAG_LEVEL2
.. doxygendefine:: ESP_INTR_FLAG_LEVEL3
.. doxygendefine:: ESP_INTR_FLAG_LEVEL4
.. doxygendefine:: ESP_INTR_FLAG_LEVEL5
.. doxygendefine:: ESP_INTR_FLAG_LEVEL6
.. doxygendefine:: ESP_INTR_FLAG_NMI
.. doxygendefine:: ESP_INTR_FLAG_LOWMED
.. doxygendefine:: ESP_INTR_FLAG_HIGH
.. doxygendefine:: ESP_INTR_FLAG_SHARED
.. doxygendefine:: ESP_INTR_FLAG_EDGE
.. doxygendefine:: ESP_INTR_FLAG_IRAM
.. doxygendefine:: ESP_INTR_FLAG_INTRDISABLED

函数
^^^^^^^^^

.. doxygenfunction:: esp_intr_mark_shared
.. doxygenfunction:: esp_intr_reserve
.. doxygenfunction:: esp_intr_alloc
.. doxygenfunction:: esp_intr_alloc_intrstatus
.. doxygenfunction:: esp_intr_free
.. doxygenfunction:: esp_intr_get_cpu
.. doxygenfunction:: esp_intr_get_intno
.. doxygenfunction:: esp_intr_disable
.. doxygenfunction:: esp_intr_enable
.. doxygenfunction:: esp_intr_noniram_disable
.. doxygenfunction:: esp_intr_noniram_enable
