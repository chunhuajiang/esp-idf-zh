内存(Memory)分配
====================

.. Hint:: 

  译注：本节以及后面 `深度睡眠` 一节中的 Memory 都翻译为内存的，但是实际情况可能是指的存储器，其中细节请自己体会。
  
概述
--------

ESP32 有多种 RAM。本质上，它包含 IRAM、DRAM 和可以同时用于这两者的 RAM。此外，还可以将外部 SPI flash 连接到 ESP32；可以使用 flash cache 将它的内存集成到 ESP32 的内存映射中。

为了利用这些所有的内存，esp-idf 包含了一个内存分配器。基本上，如果你想要内存具有某一属性（例如，DMA-capable、被某个特定的 PID 访问、或者执行代码的能力），你可以创建一个所需功能 OR 掩码并将它传递给 pvPortMallocCaps。例如，内部分配内存的常规 malloc 代码使用 ```pvPortMallocCaps(size, MALLOC_CAP_8BIT)```，这样就可以以字节为单位获取内存数据。

因为 malloc 也是使用的这个分配系统，所以使用 pvPortMallocCaps 分配的内存也可以通过调用标准函数 ```free()``` 进行释放。

本质上，这个分配器被分为两部分。FreeRTOS 目录中的分配器可以从标记的（tagged）区域分配内存：一个标记（tag）是一个整数值，空闲内存的每个区域都有一个标记。esp32 相关的代码使用一些特殊的标记来初始化这些区域，并且包含一些逻辑，这些逻辑可以根据用户所给的功能选择对应功能的标记。尽管这些 API 是公共的，但是还这些标记只能用于这两部分直接通信，而不能直接使用。

Special Uses
------------

如果某个内存结构只能以 32 比特为单位进行访问（例如整数数组或指针数组），则在分配是可以使用 MALLOC_CAP_32BIT 标志。这允许分配器分发 IRAM 内存；一些在常规 malloc() 中不能做的事儿会被调用。这样有助于是哟个 ESP32 中的所有有效内存。


API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`esp32/include/esp_heap_alloc_caps.h`
  * :component_file:`freertos/include/freertos/heap_regions.h`


宏
^^^^^^

.. doxygendefine:: MALLOC_CAP_EXEC
.. doxygendefine:: MALLOC_CAP_32BIT
.. doxygendefine:: MALLOC_CAP_8BIT
.. doxygendefine:: MALLOC_CAP_DMA
.. doxygendefine:: MALLOC_CAP_PID2
.. doxygendefine:: MALLOC_CAP_PID3
.. doxygendefine:: MALLOC_CAP_PID4
.. doxygendefine:: MALLOC_CAP_PID5
.. doxygendefine:: MALLOC_CAP_PID6
.. doxygendefine:: MALLOC_CAP_PID7
.. doxygendefine:: MALLOC_CAP_SPISRAM
.. doxygendefine:: MALLOC_CAP_INVALID

类型定义
^^^^^^^^^^^^^^^^

.. doxygentypedef:: HeapRegionTagged_t


函数
^^^^^^^^^

.. doxygenfunction:: heap_alloc_caps_init
.. doxygenfunction:: pvPortMallocCaps
.. doxygenfunction:: xPortGetFreeHeapSizeCaps
.. doxygenfunction:: xPortGetMinimumEverFreeHeapSizeCaps
.. doxygenfunction:: vPortDefineHeapRegionsTagged
.. doxygenfunction:: pvPortMallocTagged
.. doxygenfunction:: vPortFreeTagged
.. doxygenfunction:: xPortGetMinimumEverFreeHeapSizeTagged
.. doxygenfunction:: xPortGetFreeHeapSizeTagged
