深度睡眠唤醒桩
=====================

ESP32 支持从深度睡眠中醒来后运行 "深度睡眠唤醒桩(stub)"，该函数会在芯片唤醒后立即执行 —— 在运行其它任何常规初始化、bootloader、ESP-IDF 代码之前。唤醒桩运行完成后，SoC 可以重新深度睡眠，或者继续正确启动 ESP-IDF。

深度睡眠唤醒桩的代码被加载到 "RTC 快速内存中"，它所使用的所有数据都必须被加载到 RTC 内存中。RTC 内存区域会在深度睡眠期间保留其内容。

唤醒桩的规则
--------------------

编写唤醒桩代码时必须非常小心：

* 由于 SoC 才刚刚从睡眠中唤醒，大多数外设都处于复位状态。SPI flash 也未被映射。

* 唤醒桩代码只能调用在 ROM 中实现的函数或者被加载到 RTC 快速内存中的函数。

* 唤醒桩代码只能访问加载到 RTC 内存中的数据。其它的所有 RAM 都是未初始化的，其内容是随机的。唤醒桩可以使用其它 RAM 作为临时存储，但是其内容会在 SoC 重新睡眠或者启动 ESP-IDF 后被覆盖。

* RTC 内存必须包含桩所使用的所有只读数据（.rodata）。

* RTC 内存中的数据会在除从深度睡眠唤醒之外的其它所有 SoC 重启的时候被初始化。从深度睡眠唤醒时，之前存在的值在深度睡眠期间会继续保持不变。

* 唤醒桩代码是主 esp-idf 应用程序的一部分。在运行 esp-idf 期间，函数可以向常规程序一样调用唤醒桩函数/访问 RTC 内存。

桩的实现
-------------------

Esp-idf 中的桩叫做 ``esp_wake_deep_sleep()``。SoC 每次从深度睡眠唤醒后都会运行该函数。esp-idf 默认实现了该函数，但是这个默认函数是一个虚链接函数，因此如果你的应用层中包含一个叫做 ``esp_wake_deep_sleep()`` 的函数的话，它将会覆盖这个默认函数。

如果要实现一个自定义的唤醒桩，需要做的第一件事应当是调用 ``esp_default_wake_deep_sleep()``。

如果只是为了实现深度睡眠，你不需要在你的应用程序中实现 ``esp_wake_deep_sleep()``。只有当你希望在唤醒后立即做一些特殊行为时才有需要。

如果你希望运行时交换两个不同的深度睡眠桩，你可以调用函数 ``esp_set_deep_sleep_wake_stub()``。如果你只使用了默认的 ``esp_wake_deep_sleep()`` 函数，则不需要。

上面这些函数定义在组件 components/esp32 的头文件 ``esp_deepsleep.h`` 中。

将代码加到 RTC 内存
----------------------------

唤醒桩代码必须位于 RTC 快速内存中。这可以通过两种方法实现。

第一种方法是使用属性 ``RTC_IRAM_ATTR`` 将一个函数放到 RTC 内存中 ::

    void RTC_IRAM_ATTR esp_wake_deep_sleep(void) {
        esp_default_wake_deep_sleep();
        // Add additional functionality here
    }

第二种方法是将函数放到任意的名字以 ``rtc_wake_stub`` 开始的源代码中。以 ``rtc_wake_stub*`` 为名字的文件中的内容会被链接器自动放到 RTC 内存中。

第一种方法适用于非常简短的代码或者你想混合使用 "常规" 代码和 "RTC" 代码的源文件。第二种方法适用于比较长的 RTC 代码。

将数据加载到 RTC 内存
----------------------------

桩代码使用的数据必须存放到 RTC 慢速内存中。该内存也会被 ULP 使用。

指定这种数据也有两种方法：

第一种方法是是使用 ``RTC_DATA_ATTR`` 和 ``RTC_RODATA_ATTR`` 来指定需要加载到 RTC 慢速内存中的数据（分别对应于可写、只读数据） ::

    RTC_DATA_ATTR int wake_count;

    void RTC_IRAM_ATTR esp_wake_deep_sleep(void) {
        esp_default_wake_deep_sleep();
        static RTC_RODATA_ATTR const char fmt_str[] = "Wake count %d\n";
        ets_printf(fmt_str, wake_count++);
    }

不幸的是，按这种方法使用的字符串常量必须被申明为数组，且使用 RTC_RODATA_ATTR 进行标记，正如上面的例子中展示的那样。

第二种方法是将数据放到任意的以 ``rtc_wake_stub`` 开始的源代码中。

例如，同一个例子在 ``rtc_wake_stub_counter.c`` 中则是 ::

    int wake_count;

    void RTC_IRAM_ATTR esp_wake_deep_sleep(void) {
        esp_default_wake_deep_sleep();
        ets_printf("Wake count %d\n", wake_count++);
    }

如果你想要使用字符串或者写一些复杂的代码，推荐使用第二种方法。


