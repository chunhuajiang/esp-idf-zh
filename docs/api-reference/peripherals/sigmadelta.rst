Sigma-delta Modulation
======================

概述
--------

ESP32 has a second-order sigma-delta modulation module.
This driver configures the channels of the sigma-delta module.

应用程序示例
-------------------

Sigma-delta Modulation example: :example:`peripherals/sigmadelta`.

API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`driver/include/driver/sigmadelta.h`


宏
^^^^^^


类型定义
^^^^^^^^^^^^^^^^


枚举
^^^^^^^^^^^^

.. doxygenenum:: sigmadelta_channel_t

结构体
^^^^^^^^^^

.. doxygenstruct:: sigmadelta_config_t
    :members:


函数
^^^^^^^^^

.. doxygenfunction:: sigmadelta_config
.. doxygenfunction:: sigmadelta_set_duty
.. doxygenfunction:: sigmadelta_set_prescale
.. doxygenfunction:: sigmadelta_set_pin

