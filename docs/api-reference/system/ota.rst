空中升级(OTA)
==========================

OTA 过程概述
^^^^^^^^^^^^^^^^^^^^

OTA 升级机制允许常规固件在运行时基于它所接收的数据对设备进行升级（通过 WiFI 或者蓝牙）。

OTA 需要配置设备的 :doc:`Partition Table <../../api-guides/partition-tables>`，且至少需要两个 "OTA app" 分区（即 `ota_0` 和 `ota_1`）和一个 "OTA 数据分区"。

OTA 会将新的 app 固件镜像写到当前未用于启动程序的那个 OTA app 分区。当镜像校验完成后，OTA 数据分区会被更新，表示下一次启动时将使用该镜像。


.. _ota_data_partition:

OTA 数据分区
^^^^^^^^^^^^^^^^^^

使用 OTA 功能的产品必须在 :doc:`Partition Table <../../api-guides/partition-tables>` 中包含一个 OTA 数据分区。

对于工厂启动设置，OTA 数据分区应当不包含数据（所有的字节被擦除为 0xFF）。在这种情况下，如果分区表中存在工厂 app，esp-idf 软件的 bootloader 会启动工厂 app。如果分区表中不存在工厂 app，则会启动第一个有效的 OTA 分区（通常是 ``ota_0``）。

当第一次 OTA 更新后，OTA 数据分区将会被更新，表示表示下一次启动时将使用哪个 OTA app 分区。

OTA 数据分期是两个 flash 扇区（0x2000 字节），以消除正在写时供电失败的问题。如果没有计数字段表明哪个扇区在最近被写过，则两个扇区会被独立擦除并写入匹配的数据。

See Also
--------

* :doc:`分区表文档 <../../api-guides/partition-tables>`
* :doc:`底层 SPI Flash/分区 API <../storage/spi_flash>`

应用程序示例
-------------------

端到端的 OTA 固件升级流程请你参考： :example:`system/ota`。

API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`app_update/include/esp_ota_ops.h`

宏
^^^^^^

.. doxygendefine:: ESP_ERR_OTA_BASE
.. doxygendefine:: ESP_ERR_OTA_PARTITION_CONFLICT
.. doxygendefine:: ESP_ERR_OTA_SELECT_INFO_INVALID
.. doxygendefine:: ESP_ERR_OTA_VALIDATE_FAILED
.. doxygendefine:: OTA_SIZE_UNKNOWN

类型定义
^^^^^^^^^^^^^^^^

.. doxygentypedef:: esp_ota_handle_t

函数
^^^^^^^^^

.. doxygenfunction:: esp_ota_begin
.. doxygenfunction:: esp_ota_write
.. doxygenfunction:: esp_ota_end
.. doxygenfunction:: esp_ota_get_running_partition
.. doxygenfunction:: esp_ota_set_boot_partition
.. doxygenfunction:: esp_ota_get_boot_partition
.. doxygenfunction:: esp_ota_get_next_update_partition
