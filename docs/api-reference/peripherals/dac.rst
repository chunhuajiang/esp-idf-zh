Digital To Analog Converter
===========================

概述
--------

ESP32 has two 8-bit DAC (digital to analog converter) channels, connected to GPIO25 (Channel 1) and GPIO26 (Channel 2).

The DAC driver allows these channels to be set to arbitrary voltages.

The DAC channels can also be driven with DMA-style written sample data, via the :doc:`I2S driver <i2s>` when using the "built-in DAC mode".

For other analog output options, see the :doc:`Sigma-delta Modulation module <sigmadelta>` and the :doc:`LED Control module <ledc>`. Both these modules produce high frequency PWM output, which can be hardware low-pass filtered in order to generate a lower frequency analog output.


应用程序示例
-------------------

Setting DAC channel 1 (GPIO 25) voltage to approx 0.78 of VDD_A voltage (VDD * 200 / 255). For VDD_A 3.3V, this is 2.59V::

  #include <driver/dac.h>

  ...

      dac_out_voltage(DAC_CHANNEL_1, 200);

API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * `components/driver/include/driver/dac.h`

枚举
^^^^^^^^^^^^

  .. doxygenenum:: dac_channel_t

函数
^^^^^^^^^

  .. doxygenfunction:: dac_out_voltage


