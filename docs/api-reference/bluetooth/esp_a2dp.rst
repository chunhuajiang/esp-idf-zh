Bluetooth A2DP API
==================

概述
--------

`Instructions`_

.. _Instructions: ../template.html


应用程序示例
-------------------

请检查 ESP-IDF 示例中的 :example:`bluetooth` 文件夹，它包含如下示例：

:example:`bluetooth/a2dp_sink`

  这是一个 A2DP sink 客户端 demo。该 demo 可以被 A2DP 设备发现和连接，从远程设备接收音频数据。

API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`bt/bluedroid/api/include/esp_a2dp_api.h`

宏
^^^^^^

.. doxygendefine:: ESP_A2D_MCT_SBC
.. doxygendefine:: ESP_A2D_MCT_M12
.. doxygendefine:: ESP_A2D_MCT_M24
.. doxygendefine:: ESP_A2D_MCT_ATRAC
.. doxygendefine:: ESP_A2D_MCT_NON_A2DP
.. doxygendefine:: ESP_A2D_CIE_LEN_SBC
.. doxygendefine:: ESP_A2D_CIE_LEN_M12
.. doxygendefine:: ESP_A2D_CIE_LEN_M24
.. doxygendefine:: ESP_A2D_CIE_LEN_ATRAC

类型定义
^^^^^^^^^^^^^^^^

.. doxygentypedef:: esp_a2d_mct_t
.. doxygentypedef:: esp_a2d_cb_t
.. doxygentypedef:: esp_a2d_data_cb_t

枚举
^^^^^^^^^^^^

.. doxygenenum:: esp_a2d_connection_state_t
.. doxygenenum:: esp_a2d_disc_rsn_t
.. doxygenenum:: esp_a2d_audio_state_t
.. doxygenenum:: esp_a2d_cb_event_t

结构体
^^^^^^^^^^

.. doxygenstruct:: esp_a2d_cb_param_t
    :members:

.. doxygenstruct:: esp_a2d_cb_param_t::a2d_conn_stat_param
    :members:

.. doxygenstruct:: esp_a2d_cb_param_t::a2d_audio_stat_param
    :members:

.. doxygenstruct:: esp_a2d_cb_param_t::a2d_audio_cfg_param
    :members:


函数
^^^^^^^^^

.. doxygenfunction:: esp_a2d_register_callback
.. doxygenfunction:: esp_a2d_register_data_callback
.. doxygenfunction:: esp_a2d_sink_init
.. doxygenfunction:: esp_a2d_sink_deinit
.. doxygenfunction:: esp_a2d_sink_connect
.. doxygenfunction:: esp_a2d_sink_disconnect

