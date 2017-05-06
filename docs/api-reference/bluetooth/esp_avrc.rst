BT AVRCP API
=============

概述
--------

蓝牙 AVRCP 参考 API。

`Instructions`_

应用程序示例
-------------------

`Instructions`_

.. _Instructions: ../template.html


API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`bt/bluedroid/api/include/esp_avrc_api.h`


宏
^^^^^^


类型定义
^^^^^^^^^^^^^^^^

.. doxygentypedef:: esp_avrc_ct_cb_t

枚举
^^^^^^^^^^^^

.. doxygenenum:: esp_avrc_features_t
.. doxygenenum:: esp_avrc_pt_cmd_t
.. doxygenenum:: esp_avrc_pt_cmd_state_t
.. doxygenenum:: esp_avrc_ct_cb_event_t

结构体
^^^^^^^^^^

.. doxygenstruct:: esp_avrc_ct_cb_param_t
    :members:

.. doxygenstruct:: esp_avrc_ct_cb_param_t::avrc_ct_conn_stat_param
    :members:

.. doxygenstruct:: esp_avrc_ct_cb_param_t::avrc_ct_psth_rsp_param
    :members:


函数
^^^^^^^^^

.. doxygenfunction:: esp_avrc_ct_register_callback
.. doxygenfunction:: esp_avrc_ct_init
.. doxygenfunction:: esp_avrc_ct_deinit
.. doxygenfunction:: esp_avrc_ct_send_passthrough_cmd

