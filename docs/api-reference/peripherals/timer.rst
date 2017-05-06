TIMER
========

概述
--------

ESP32 chip contains two hardware timer groups, each containing two general-purpose hardware timers. 

They are all 64-bit generic timers based on 16-bit prescalers and 64-bit auto-reload-capable up/down counters.


应用程序示例
-------------------

64-bit hardware timer example: :example:`peripherals/timer_group`.

API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`driver/include/driver/timer.h`

宏
^^^^^^

.. doxygendefine:: TIMER_BASE_CLK

类型定义
^^^^^^^^^^^^^^^^


枚举
^^^^^^^^^^^^

.. doxygenenum:: timer_group_t
.. doxygenenum:: timer_idx_t
.. doxygenenum:: timer_count_dir_t
.. doxygenenum:: timer_start_t
.. doxygenenum:: timer_alarm_t
.. doxygenenum:: timer_intr_mode_t
.. doxygenenum:: timer_autoreload_t

结构体
^^^^^^^^^^

.. doxygenstruct:: timer_config_t
    :members:


函数
^^^^^^^^^

.. doxygenfunction:: timer_get_counter_value
.. doxygenfunction:: timer_get_counter_time_sec
.. doxygenfunction:: timer_set_counter_value
.. doxygenfunction:: timer_start
.. doxygenfunction:: timer_pause
.. doxygenfunction:: timer_set_counter_mode
.. doxygenfunction:: timer_set_auto_reload
.. doxygenfunction:: timer_set_divider
.. doxygenfunction:: timer_set_alarm_value
.. doxygenfunction:: timer_get_alarm_value
.. doxygenfunction:: timer_set_alarm
.. doxygenfunction:: timer_isr_register
.. doxygenfunction:: timer_init
.. doxygenfunction:: timer_get_config
.. doxygenfunction:: timer_group_intr_enable
.. doxygenfunction:: timer_group_intr_disable
.. doxygenfunction:: timer_enable_intr
.. doxygenfunction:: timer_disable_intr

