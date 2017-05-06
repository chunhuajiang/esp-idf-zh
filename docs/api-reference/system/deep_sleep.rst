深度睡眠
==========

概述
--------

ESP32 具有深度睡眠节电功能。在这种模式下，CPU、大多数的 RAM 和所有的由时钟 APB_CLK 驱动的数字外设都会被断电。芯片中还继续处于供电状态的部分包括：RTC 控制器、RTC 外设（包括 ULP 协处理器）、RTC 内存（慢速和快速）。

从深度睡眠中唤醒可以使用几种源。这些源可以组合在一起，此时，任何一种源都可以触发唤醒。可以通过 API ``esp_deep_sleep_enable_X_wakeup`` 来使能唤醒源。下一节将描述这些 API 的细节。你可以在系统进入深度睡眠前的任何时刻配置唤醒源。

此外，应用程序可以使用 API ``esp_deep_sleep_pd_config`` 让 RTC 外设和 RTC 内存强制断电。

唤醒源被配置后，应用程序可以使用 API ``esp_deep_sleep_start`` 进入深度睡眠。从这一点看，硬件将会根据所请求的唤醒源来配置，RTC 控制器将给 CPU 和数字外设断电。

唤醒源
--------------

定时器
^^^^^^^^

RTC controller has a built in timer which can be used to wake up the chip after a predefined amount of time. Time is specified at microsecond precision, but the actual resolution depends on the clock source selected for RTC SLOW_CLK. See chapter "Reset and Clock" of the ESP32 Technical Reference Manual for details about RTC clock options. 

This wakeup mode doesn't require RTC peripherals or RTC memories to be powered on during deep sleep.

The following function can be used to enable deep sleep wakeup using a timer.

.. doxygenfunction:: esp_deep_sleep_enable_timer_wakeup

触摸板
^^^^^^^^^

RTC IO module contains logic to trigger wakeup when a touch sensor interrupt occurs. You need to configure the touch pad interrupt before the chip starts deep sleep.

Revisions 0 and 1 of the ESP32 only support this wakeup mode when RTC peripherals are not forced to be powered on (i.e. ESP_PD_DOMAIN_RTC_PERIPH should be set to ESP_PD_OPTION_AUTO).

.. doxygenfunction:: esp_deep_sleep_enable_touchpad_wakeup


外部唤醒(ext0)
^^^^^^^^^^^^^^^^^^^^^^

RTC IO module contains logic to trigger wakeup when one of RTC GPIOs is set to a predefined logic level. RTC IO is part of RTC peripherals power domain, so RTC peripherals will be kept powered on during deep sleep if this wakeup source is requested. 

Because RTC IO module is enabled in this mode, internal pullup or pulldown resistors can also be used. They need to be configured by the application using ``rtc_gpio_pullup_en`` and ``rtc_gpio_pulldown_en`` functions, before calling ``esp_deep_sleep_start``.

In revisions 0 and 1 of the ESP32, this wakeup source is incompatible with ULP and touch wakeup sources.

.. warning:: After wake up from deep sleep, IO pad used for wakeup will be configured as RTC IO. Before using this pad as digital GPIO, reconfigure it using ``rtc_gpio_deinit(gpio_num)`` function.

.. doxygenfunction:: esp_deep_sleep_enable_ext0_wakeup

外部唤醒(ext1)
^^^^^^^^^^^^^^^^^^^^^^

RTC controller contains logic to trigger wakeup using multiple RTC GPIOs. One of the two logic functions can be used to trigger wakeup:

    - wake up if any of the selected pins is high (``ESP_EXT1_WAKEUP_ANY_HIGH``)
    - wake up if all the selected pins are low (``ESP_EXT1_WAKEUP_ALL_LOW``)

This wakeup source is implemented by the RTC controller. As such, RTC peripherals and RTC memories can be powered off in this mode. However, if RTC peripherals are powered down, internal pullup and pulldown resistors will be disabled. To use internal pullup or pulldown resistors, request RTC peripherals power domain to be kept on during deep sleep, and configure pullup/pulldown resistors using ``rtc_gpio_`` functions, before entering deep sleep::

    esp_deep_sleep_pd_config(ESP_PD_DOMAIN_RTC_PERIPH, ESP_PD_OPTION_ON);
    gpio_pullup_dis(gpio_num);
    gpio_pulldown_en(gpio_num);

.. warning:: After wake up from deep sleep, IO pad(s) used for wakeup will be configured as RTC IO. Before using these pads as digital GPIOs, reconfigure them using ``rtc_gpio_deinit(gpio_num)`` function.
    
The following function can be used to enable this wakeup mode:

.. doxygenfunction:: esp_deep_sleep_enable_ext1_wakeup

.. doxygenenum:: esp_ext1_wakeup_mode_t


ULP 协处理器唤醒
^^^^^^^^^^^^^^^^^^^^^^

ULP coprocessor can run while the chip is in deep sleep, and may be used to poll sensors, monitor ADC or touch sensor values, and wake up the chip when a specific event is detected. ULP coprocessor is part of RTC peripherals power domain, and it runs the program stored in RTC slow memeory. RTC slow memory will be powered on during deep sleep if this wakeup mode is requested. RTC peripherals will be automatically powered on before ULP coprocessor starts running the program; once the program stops running, RTC peripherals are automatically powered down again.

Revisions 0 and 1 of the ESP32 only support this wakeup mode when RTC peripherals are not forced to be powered on (i.e. ESP_PD_DOMAIN_RTC_PERIPH should be set to ESP_PD_OPTION_AUTO).

The following function can be used to enable this wakeup mode:

.. doxygenfunction:: esp_deep_sleep_enable_ulp_wakeup

RTC 外设和内存断电
------------------------------------------

By default, ``esp_deep_sleep_start`` function will power down all RTC power domains which are not needed by the enabled wakeup sources. To override this behaviour, the following function is provided:

Note: in revision 0 of the ESP32, RTC fast memory will always be kept enabled in deep sleep, so that the deep sleep stub can run after reset. This can be overriden, if the application doesn't need clean reset behaviour after deep sleep.

If some variables in the program are placed into RTC slow memory (for example, using ``RTC_DATA_ATTR`` attribute), RTC slow memory will be kept powered on by default. This can be overriden using ``esp_deep_sleep_pd_config`` function, if desired.

.. doxygenfunction:: esp_deep_sleep_pd_config
.. doxygenenum:: esp_deep_sleep_pd_domain_t
.. doxygenenum:: esp_deep_sleep_pd_option_t


进入深度睡眠
-------------------

The following function can be used to enter deep sleep once wakeup sources are configured. It is also possible to go into deep sleep with no wakeup sources configured, in this case the chip will be in deep sleep mode indefinetly, until external reset is applied.

.. doxygenfunction:: esp_deep_sleep_start

检查深度睡眠唤醒原因
--------------------------------

The following function can be used to check which wakeup source has triggered wakeup from deep sleep mode. For touch pad and ext1 wakeup sources, it is possible to identify pin or touch pad which has caused wakeup.

.. doxygenfunction:: esp_deep_sleep_get_wakeup_cause
.. doxygenenum:: esp_deep_sleep_wakeup_cause_t
.. doxygenfunction:: esp_deep_sleep_get_touchpad_wakeup_status
.. doxygenfunction:: esp_deep_sleep_get_ext1_wakeup_status


应用程序示例
-------------------
 
Implementation of basic functionality of deep sleep is shown in :example:`protocols/sntp` example, where ESP module is periodically waken up to retrive time from NTP server.

More extensive example in :example:`system/deep_sleep` illustrates usage of various deep sleep wakeup triggers and ULP coprocessor programming.
