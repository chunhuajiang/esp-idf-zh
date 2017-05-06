.. include:: ../../../components/spi_flash/README.rst

其它
--------

- :doc:`分区表文档 <../../api-guides/partition-tables>`
- :doc:`空中升级（OTA）API <../system/ota>` 提供了更新存储在 flash 中的应用程序的顶层 API。
- :doc:`非易变存储器(NVS) API <nvs_flash>` 提供了在 SPI flash 中存储小数据项的结构化 API。

API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`spi_flash/include/esp_spi_flash.h`
  * :component_file:`spi_flash/include/esp_partition.h`
  * :component_file:`bootloader_support/include/esp_flash_encrypt.h`

宏
^^^^^^

.. doxygendefine:: ESP_ERR_FLASH_BASE
.. doxygendefine:: ESP_ERR_FLASH_OP_FAIL
.. doxygendefine:: ESP_ERR_FLASH_OP_TIMEOUT
.. doxygendefine:: SPI_FLASH_SEC_SIZE
.. doxygendefine:: SPI_FLASH_MMU_PAGE_SIZE
.. doxygendefine:: ESP_PARTITION_SUBTYPE_OTA
.. doxygendefine:: SPI_FLASH_CACHE2PHYS_FAIL

类型定义
^^^^^^^^^^^^^^^^

.. doxygentypedef:: spi_flash_mmap_handle_t
.. doxygentypedef:: esp_partition_iterator_t

枚举
^^^^^^^^^^^^

.. doxygenenum:: spi_flash_mmap_memory_t
.. doxygenenum:: esp_partition_type_t
.. doxygenenum:: esp_partition_subtype_t

结构体
^^^^^^^^^^

.. doxygenstruct:: esp_partition_t

函数
^^^^^^^^^

.. doxygenfunction:: spi_flash_init
.. doxygenfunction:: spi_flash_get_chip_size
.. doxygenfunction:: spi_flash_erase_sector
.. doxygenfunction:: spi_flash_erase_range
.. doxygenfunction:: spi_flash_write
.. doxygenfunction:: spi_flash_write_encrypted
.. doxygenfunction:: spi_flash_read
.. doxygenfunction:: spi_flash_read_encrypted
.. doxygenfunction:: spi_flash_mmap
.. doxygenfunction:: spi_flash_munmap
.. doxygenfunction:: spi_flash_mmap_dump
.. doxygenfunction:: spi_flash_cache2phys
.. doxygenfunction:: spi_flash_phys2cache
.. doxygenfunction:: spi_flash_cache_enabled
.. doxygenfunction:: esp_partition_find
.. doxygenfunction:: esp_partition_find_first
.. doxygenfunction:: esp_partition_get
.. doxygenfunction:: esp_partition_next
.. doxygenfunction:: esp_partition_iterator_release
.. doxygenfunction:: esp_partition_read
.. doxygenfunction:: esp_partition_write
.. doxygenfunction:: esp_partition_erase_range
.. doxygenfunction:: esp_partition_mmap
.. doxygenfunction:: esp_flash_encryption_enabled

.. _spi-flash-implementation-details:

实现细节
----------------------

为了执行某些 flash 操作，我们需要确保两个 CPU 在 flash 操作期间都没有从 flash 运行任何代码。在单核中，这非常简单：禁止中断/调度器，然后执行 flash 操作。在双核中，所谓有点复杂。我们需要确保其它 CPU 没有从 flash 上面运行任何代码。

当 SPI flahs  API 在 CPU A（可以是 PRO 或者 APP）上被调用，我们使用 API esp_ipc_call 在 CPU B 上启动函数 spi_flash_op_block_func。这个 API 会唤醒 CPU B 上的高优先级任务，告诉它取执行所给函数，即 spi_flash_op_block_func。该函数子啊 CPU B 上
When SPI flash API is called on CPU A (can be PRO or APP), we start
spi_flash_op_block_func function on CPU B using esp_ipc_call API. This API
wakes up high priority task on CPU B and tells it to execute given function,
in this case spi_flash_op_block_func. This function disables cache on CPU B and
signals that cache is disabled by setting s_flash_op_can_start flag.
Then the task on CPU A disables cache as well, and proceeds to execute flash
operation.

While flash operation is running, interrupts can still run on CPUs A and B.
We assume that all interrupt code is placed into RAM. Once interrupt allocation
API is added, we should add a flag to request interrupt to be disabled for
the duration of flash operations.

Once flash operation is complete, function on CPU A sets another flag,
s_flash_op_complete, to let the task on CPU B know that it can re-enable
cache and release the CPU. Then the function on CPU A re-enables the cache on
CPU A as well and returns control to the calling code.

Additionally, all API functions are protected with a mutex (s_flash_op_mutex).

In a single core environment (CONFIG_FREERTOS_UNICORE enabled), we simply
disable both caches, no inter-CPU communication takes place.
