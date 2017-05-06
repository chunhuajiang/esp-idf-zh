控制器 && VHCI
==================

概述
--------

`Instructions`_

.. _Instructions: ../template.html

应用程序示例
-------------------

请检查 ESP-IDF 示例中的 :example:`bluetooth` 文件夹，它包含如下示例：

:example:`bluetooth/ble_adv`

  这是一个带有虚拟 HCI 接口的 BLE 广播 demo。BLE 广播时发送 Reset/ADV_PARAM/ADV_DATA/ADV_ENABLE HCI 命令。

API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`bt/include/bt.h`

类型定义
^^^^^^^^^^^^^^^^

.. doxygentypedef:: esp_vhci_host_callback_t

枚举
^^^^^^^^^^^^

.. doxygenenum:: esp_bt_mode_t

结构体
^^^^^^^^^^

.. doxygenstruct:: esp_bt_controller_config_t
    :members:

.. doxygenstruct:: esp_vhci_host_callback
    :members:

函数
^^^^^^^^^

.. doxygenfunction:: esp_bt_controller_init
.. doxygenfunction:: esp_bt_controller_deinit
.. doxygenfunction:: esp_bt_controller_enable
.. doxygenfunction:: esp_bt_controller_disable
.. doxygenfunction:: esp_bt_controller_get_status
.. doxygenfunction:: esp_vhci_host_check_send_available
.. doxygenfunction:: esp_vhci_host_send_packet
.. doxygenfunction:: esp_vhci_host_register_callback

