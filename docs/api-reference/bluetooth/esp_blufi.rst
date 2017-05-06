BLUFI API
=========

Over概述view
--------
BLUFI 是一个基于 GATT 的属性，用于配置 ESP32 WIFI 与 AP 的连接/断开连接，或者设置 softap 等。在使用时应当关注如下两点：

1. 从 profile 发送的事件。你需要根据事件的指示完成某些工作。
2. 安全引用。你可以自己写安全函数，例如对称加密/解密、校验和等函数。你甚至可以定义 "Key Exchange/Negotiation" 过程。

应用程序示例
-------------------

请检查 ESP-IDF 示例中的 :example:`bluetooth` 文件夹，它包含如下示例：

:example:`bluetooth/blufi` 

  这是一个 BLUFI demo。该 demo 可以设置 ESP32 的 wifi 为 softap/station/softap&station 模式，并且可以配置 wifi 连接。
  

API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`bt/bluedroid/api/include/esp_blufi_api.h`

宏
^^^^^^


类型定义
^^^^^^^^^^^^^^^^

.. doxygentypedef:: esp_blufi_event_cb_t
.. doxygentypedef:: esp_blufi_negotiate_data_handler_t
.. doxygentypedef:: esp_blufi_encrypt_func_t
.. doxygentypedef:: esp_blufi_decrypt_func_t
.. doxygentypedef:: esp_blufi_checksum_func_t

枚举
^^^^^^^^^^^^

.. doxygenenum:: esp_blufi_cb_event_t
.. doxygenenum:: esp_blufi_sta_conn_state_t
.. doxygenenum:: esp_blufi_init_state_t
.. doxygenenum:: esp_blufi_deinit_state_t

结构体
^^^^^^^^^^

.. doxygenstruct:: esp_blufi_extra_info_t
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_init_finish_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_deinit_finish_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_set_wifi_mode_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_connect_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_disconnect_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_recv_sta_bssid_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_recv_sta_ssid_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_recv_sta_passwd_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_recv_softap_ssid_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_recv_softap_passwd_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_recv_softap_max_conn_num_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_recv_softap_auth_mode_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_recv_softap_channel_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_recv_username_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_recv_ca_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_recv_client_cert_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_recv_server_cert_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_recv_client_pkey_evt_param
    :members:

.. doxygenstruct:: esp_blufi_cb_param_t::blufi_recv_server_pkey_evt_param
    :members:

.. doxygenstruct:: esp_blufi_callbacks_t
    :members:


函数
^^^^^^^^^

.. doxygenfunction:: esp_blufi_register_callbacks
.. doxygenfunction:: esp_blufi_profile_init
.. doxygenfunction:: esp_blufi_profile_deinit
.. doxygenfunction:: esp_blufi_send_wifi_conn_report
.. doxygenfunction:: esp_blufi_get_version

