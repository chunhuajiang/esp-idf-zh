深度睡眠
==========

概述
--------

ESP32 具有深度睡眠节电功能。在这种模式下，CPU、大多数的 RAM 和所有的由时钟 APB_CLK 驱动的数字外设都会被断电。芯片中还继续处于供电状态的部分包括：RTC 控制器、RTC 外设（包括 ULP 协处理器）、RTC 内存（低速和快速）。

从深度睡眠中唤醒可以使用几种源。这些源可以组合在一起，此时，任何一种源都可以触发唤醒。可以通过 API ``esp_deep_sleep_enable_X_wakeup`` 来使能唤醒源。下一节将描述这些 API 的细节。你可以在系统进入深度睡眠前的任何时刻配置唤醒源。

此外，应用程序可以使用 API ``esp_deep_sleep_pd_config`` 让 RTC 外设和 RTC 内存强制断电。

唤醒源被配置后，应用程序可以使用 API ``esp_deep_sleep_start`` 进入深度睡眠。从这一点看，硬件将会根据所请求的唤醒源来配置，RTC 控制器将给 CPU 和数字外设断电。

唤醒源
--------------

定时器
^^^^^^^^

RTC 控制器中有一个内置的定时器，可用于在预定义的时间到达后唤醒芯片。时间的精度是微秒，但是实际的分辨率依赖于为 RTC SLOW_CLK 所选择的时钟源。关于 RTC 时钟选项的更多细节请参考 ESP32 技术参考手册的 "Reset and Clock" 一章。

这种唤醒模式不需要 RTC 外设或内存在深度睡眠器件供电。

下面的函数可以用于使能使用定时器深度睡眠唤醒。

.. doxygenfunction:: esp_deep_sleep_enable_timer_wakeup

触摸板
^^^^^^^^^

RTC IO 模块中包含这样一个逻辑：当发生触摸传感器中断时触发唤醒。你需要在芯片进入深度睡眠前配置触摸屏的中断。

ESP32 的修订版 0 和 1 仅在 RTC 外设没有被强制供电时支持该唤醒（即 ESP_PD_DOMAIN_RTC_PERIPH 被设置为 ESP_PD_OPTION_AUTO）。

.. doxygenfunction:: esp_deep_sleep_enable_touchpad_wakeup


外部唤醒(ext0)
^^^^^^^^^^^^^^^^^^^^^^

RTC IO 模块中包含这样一个逻辑，当某个 RTC GPIO 被设置为预定义的逻辑值时触发唤醒。RTC IO 是 RTC 外设电源域的一部分，因此如果该唤醒源被请求的话，RTC 外设将在深度睡眠期间保持供电。

因为 RTC IO 模块在这个模式被使能，因此也可以使用内部上拉或下拉电阻。它们需要应用程序在调用 ``esp_deep_sleep_start`` 前使用先调用函数 ``rtc_gpio_pullup_en`` 或 ``rtc_gpio_pulldown_en``。

在 ESP32 的修订版 0 和 1 中，这个唤醒源与 ULP 和触摸唤醒源都不兼容。

.. warning:: 从深度睡眠中唤醒后，用于唤醒的 IO Pad 将被配置为 RTC IO，因此在将该 pad 用作数字 IO 前，需要使用函数 ``rtc_gpio_deinit(gpio_num)`` 对它进行重新配置。

.. doxygenfunction:: esp_deep_sleep_enable_ext0_wakeup

外部唤醒(ext1)
^^^^^^^^^^^^^^^^^^^^^^

RTC 控制器包含使用多个 RTC GPIO 触发唤醒的逻辑。下面其中一个逻辑功能可以用于触发唤醒：

    - 当任意一个所选引脚为高电平时唤醒 (``ESP_EXT1_WAKEUP_ANY_HIGH``)
    - 当所有所选引脚为低电平时唤醒 (``ESP_EXT1_WAKEUP_ALL_LOW``)

这个唤醒源由 RTC 控制器实现。这种模式下的 RTC 外设和 RTC 内存可以被断电。不过，如果 RTC 外设被断电，内部上拉和下拉电阻将被禁止。为了使用内部上拉和下拉电阻，需要 RTC 外设电源域在睡眠期间保持开启，并在进入深度睡眠前使用函数 ``rtc_gpio_`` 配置上拉/下拉电阻 ::


    esp_deep_sleep_pd_config(ESP_PD_DOMAIN_RTC_PERIPH, ESP_PD_OPTION_ON);
    gpio_pullup_dis(gpio_num);
    gpio_pulldown_en(gpio_num);

.. warning:: 从深度睡眠中唤醒后，用于唤醒的 IO Pad 将被配置为 RTC IO，因此在将该 pad 用作数字 IO 前，需要使用函数 ``rtc_gpio_deinit(gpio_num)`` 对它进行重新配置。

下列函数可以用于使能这个唤醒模式：    

.. doxygenfunction:: esp_deep_sleep_enable_ext1_wakeup

.. doxygenenum:: esp_ext1_wakeup_mode_t


ULP 协处理器唤醒
^^^^^^^^^^^^^^^^^^^^^^

当芯片处于深度睡眠时，ULP 协处理器能够运行，可以用于轮询传感器、监视器 ADC 或者触摸板传感器的值，并在检查到某个特殊事件时唤醒芯片。ULP 协处理器是 RTC 外设电源域的一部分，它运行存储在 RTC 低速内存中的程序。如果请求了这种唤醒模式，则 RTC 低速内存将会在深度睡眠期间保持供电状态。RTC 外设会在 ULP 协处理器开始运行程序前自动上电；一旦程序停止运行，RTC 外设会再次自动断电。

ESP32 的修订版 0 和 1 仅在 RTC 外设没有被强制供电时支持该唤醒（即 ESP_PD_DOMAIN_RTC_PERIPH 被设置为 ESP_PD_OPTION_AUTO）。

下列函数可以用于使能这个唤醒模式：    

.. doxygenfunction:: esp_deep_sleep_enable_ulp_wakeup

RTC 外设和内存断电
------------------------------------------

默认情况下，函数 ``esp_deep_sleep_start`` 将会关掉被使能的唤醒源不需要的所有 RTC 电源域。如果向修改这个默认行为，可以使用下面的函数：

Note: 在 ESP32 的修订版 1 中，RTC 快速内存在深度睡眠期间将总是保持使能，因此深度睡眠桩（stub）可以在复位后运行。如果应用程序在深度睡眠后不需要清除复位行为，也可以对其进行修改。

如果程序中的某些值被if昂懂啊 RTC 低速内存中（例如，使用 ``RTC_DATA_ATTR`` 属性），RTC 低速内存将默认保持供电。如果有需要，也可以使用函数 ``esp_deep_sleep_pd_config`` 对其进行修改。

.. doxygenfunction:: esp_deep_sleep_pd_config
.. doxygenenum:: esp_deep_sleep_pd_domain_t
.. doxygenenum:: esp_deep_sleep_pd_option_t


进入深度睡眠
-------------------

唤醒源配置后，下面函数可以用于进入深度睡眠。在没有配置唤醒源时也可以进入深度睡眠，在这种情形下，芯片将确切地处于深度睡眠模式，知道接收到外部复位。

.. doxygenfunction:: esp_deep_sleep_start

检查深度睡眠唤醒原因
--------------------------------

下面的函数可用于检测是何种唤醒源在深度睡眠期间被触发了。对于触摸板和 ext1 唤醒源，可以确定造成唤醒的引脚或触摸 pad。

.. doxygenfunction:: esp_deep_sleep_get_wakeup_cause
.. doxygenenum:: esp_deep_sleep_wakeup_cause_t
.. doxygenfunction:: esp_deep_sleep_get_touchpad_wakeup_status
.. doxygenfunction:: esp_deep_sleep_get_ext1_wakeup_status


应用程序示例
-------------------
 
深度睡眠的基本示例程序是 :example:`protocols/sntp`，它会让 ESP 模块周期性地唤醒，以从 NTP 服务器获取时间。

更多扩展示例请参考 :example:`system/deep_sleep`，它描述了各种深度睡眠触发器和 ULP 协处理器编程的方法。
