GATT SERVER API
===============

概述
--------

`Instructions`_

.. _Instructions: ../template.html

应用程序示例
-------------------

请检查 ESP-IDF 示例中的 :example:`bluetooth` 文件夹，它包含如下示例：

:example:`bluetooth/gatt_server` 

  这是一个 GATT 服务器 demo。使用 GATT API 创建一个发送广播 GATT 服务器。这个 GATT 服务器可以被连接，服务可以被发现。
  
API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`bt/bluedroid/api/include/esp_gatts_api.h`

宏
^^^^^^

.. doxygendefine:: ESP_GATT_PREP_WRITE_CANCEL
.. doxygendefine:: ESP_GATT_PREP_WRITE_EXEC

类型定义
^^^^^^^^^^^^^^^^

.. doxygentypedef:: esp_gatts_cb_t

枚举
^^^^^^^^^^^^

.. doxygenenum:: esp_gatts_cb_event_t

结构体
^^^^^^^^^^

.. doxygenstruct:: esp_ble_gatts_cb_param_t
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_reg_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_read_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_write_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_exec_write_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_mtu_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_conf_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_create_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_add_incl_srvc_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_add_char_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_add_char_descr_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_delete_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_start_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_stop_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_connect_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_disconnect_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_congest_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_rsp_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_add_attr_tab_evt_param
    :members:

.. doxygenstruct:: esp_ble_gatts_cb_param_t::gatts_set_attr_val_evt_param
    :members:


函数
^^^^^^^^^

.. doxygenfunction:: esp_ble_gatts_register_callback
.. doxygenfunction:: esp_ble_gatts_app_register
.. doxygenfunction:: esp_ble_gatts_app_unregister
.. doxygenfunction:: esp_ble_gatts_create_service
.. doxygenfunction:: esp_ble_gatts_create_attr_tab
.. doxygenfunction:: esp_ble_gatts_add_included_service
.. doxygenfunction:: esp_ble_gatts_add_char
.. doxygenfunction:: esp_ble_gatts_add_char_descr
.. doxygenfunction:: esp_ble_gatts_delete_service
.. doxygenfunction:: esp_ble_gatts_start_service
.. doxygenfunction:: esp_ble_gatts_stop_service
.. doxygenfunction:: esp_ble_gatts_send_indicate
.. doxygenfunction:: esp_ble_gatts_send_response
.. doxygenfunction:: esp_ble_gatts_set_attr_value
.. doxygenfunction:: esp_ble_gatts_get_attr_value
.. doxygenfunction:: esp_ble_gatts_open
.. doxygenfunction:: esp_ble_gatts_close

