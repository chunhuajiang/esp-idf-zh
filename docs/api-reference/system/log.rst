.. include:: ../../../components/log/README.rst

应用程序示例
-------------------

Log library is commonly used by most of esp-idf components and examples. For demonstration of log functionality check :idf:`examples` folder of `espressif/esp-idf <https://github.com/espressif/esp-idf>`_ repository, that among others, contains the following examples:
 
* :example:`system/ota` 
* :example:`storage/sd_card` 
* :example:`protocols/https_request` 

API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`log/include/esp_log.h`

宏
^^^^^^

.. doxygendefine:: LOG_COLOR_E
.. doxygendefine:: LOG_COLOR_W
.. doxygendefine:: LOG_COLOR_I
.. doxygendefine:: LOG_COLOR_D
.. doxygendefine:: LOG_COLOR_V
.. doxygendefine:: LOG_RESET_COLOR
.. doxygendefine:: LOG_FORMAT
.. doxygendefine:: LOG_LOCAL_LEVEL
.. doxygendefine:: ESP_EARLY_LOGE
.. doxygendefine:: ESP_EARLY_LOGW
.. doxygendefine:: ESP_EARLY_LOGI
.. doxygendefine:: ESP_EARLY_LOGD
.. doxygendefine:: ESP_EARLY_LOGV
.. doxygendefine:: ESP_LOGE
.. doxygendefine:: ESP_LOGW
.. doxygendefine:: ESP_LOGI
.. doxygendefine:: ESP_LOGD
.. doxygendefine:: ESP_LOGV

类型定义
^^^^^^^^^^^^^^^^

.. doxygentypedef:: vprintf_like_t

枚举
^^^^^^^^^^^^

.. doxygenenum:: esp_log_level_t

函数
^^^^^^^^^

.. doxygenfunction:: esp_log_level_set
.. doxygenfunction:: esp_log_set_vprintf
.. doxygenfunction:: esp_log_timestamp
.. doxygenfunction:: esp_log_write










