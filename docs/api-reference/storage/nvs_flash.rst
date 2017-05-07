.. include:: ../../../components/nvs_flash/README.rst

应用程序示例
-------------------

下面这两个示例是在  ESP-IDF 示例的 :example:`storage` 目录提供的：

:example:`storage/nvs_rw_value`

  演示了如何使用 NVS 读写一个整数值。
  
  该值记录了 ESP32 模块重启的次数。由于它是写到 NVS 中的，因此重启后该值还保留着。
  
  示例还演示了如何检查读/写操作是否成功，或者某个值在 NVS 中是否被初始化了。 提供的诊断消息可用于帮助跟踪程序流、采集问题。
  
:example:`storage/nvs_rw_blob`

  演示了如何使用 NVS 读/写一个整数值和一块数据（二进制大对象，blob），让它们在 ESP32 模块重启后依然保存着。
  
    * 值 - 跟踪 ESP32 模块软件/硬件重启的次数.
    * 块（blob） - 包含一个记录模块运行时间的表格。程序会将表格由 NVS 读取到动态分配的 RAM。每次手工触发软件复位时，新的运行时间被添加到表格中，并被写回 NVS。触发是通过下拉 GPIO0 完成的。
    
  示例还演示了如何检查读/写操作是否成功。


API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`nvs_flash/include/nvs_flash.h`
  * :component_file:`nvs_flash/include/nvs.h`

宏
^^^^^^

.. doxygendefine:: ESP_ERR_NVS_BASE
.. doxygendefine:: ESP_ERR_NVS_NOT_INITIALIZED
.. doxygendefine:: ESP_ERR_NVS_NOT_FOUND
.. doxygendefine:: ESP_ERR_NVS_TYPE_MISMATCH
.. doxygendefine:: ESP_ERR_NVS_READ_ONLY
.. doxygendefine:: ESP_ERR_NVS_NOT_ENOUGH_SPACE
.. doxygendefine:: ESP_ERR_NVS_INVALID_NAME
.. doxygendefine:: ESP_ERR_NVS_INVALID_HANDLE
.. doxygendefine:: ESP_ERR_NVS_REMOVE_FAILED
.. doxygendefine:: ESP_ERR_NVS_KEY_TOO_LONG
.. doxygendefine:: ESP_ERR_NVS_PAGE_FULL
.. doxygendefine:: ESP_ERR_NVS_INVALID_STATE
.. doxygendefine:: ESP_ERR_NVS_INVALID_LENGTH
.. doxygendefine:: ESP_ERR_NVS_NO_FREE_PAGES

类型定义
^^^^^^^^^^^^^^^^

.. doxygentypedef:: nvs_handle

枚举
^^^^^^^^^^^^

.. doxygenenum:: nvs_open_mode

函数
^^^^^^^^^
.. doxygenfunction:: nvs_flash_init
.. doxygenfunction:: nvs_open
.. doxygenfunction:: nvs_set_i8
.. doxygenfunction:: nvs_set_u8
.. doxygenfunction:: nvs_set_i16
.. doxygenfunction:: nvs_set_u16
.. doxygenfunction:: nvs_set_i32
.. doxygenfunction:: nvs_set_u32
.. doxygenfunction:: nvs_set_i64
.. doxygenfunction:: nvs_set_u64
.. doxygenfunction:: nvs_set_str
.. doxygenfunction:: nvs_set_blob
.. doxygenfunction:: nvs_get_i8
.. doxygenfunction:: nvs_get_u8
.. doxygenfunction:: nvs_get_i16
.. doxygenfunction:: nvs_get_u16
.. doxygenfunction:: nvs_get_i32
.. doxygenfunction:: nvs_get_u32
.. doxygenfunction:: nvs_get_i64
.. doxygenfunction:: nvs_get_u64
.. doxygenfunction:: nvs_get_str
.. doxygenfunction:: nvs_get_blob
.. doxygenfunction:: nvs_erase_key
.. doxygenfunction:: nvs_erase_all
.. doxygenfunction:: nvs_commit
.. doxygenfunction:: nvs_close


