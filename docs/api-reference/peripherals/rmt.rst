RMT
========

概述
--------

The RMT (Remote Control) module driver can be used to send and receive infrared remote control signals. Due to flexibility of RMT module, the driver can also be used to generate many other types of signals.

应用程序示例
-------------------

NEC remote control TX and RX example: :example:`peripherals/rmt_nec_tx_rx`.

API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`driver/include/driver/rmt.h`

宏
^^^^^^

.. doxygendefine:: RMT_MEM_BLOCK_BYTE_NUM
.. doxygendefine:: RMT_MEM_ITEM_NUM

枚举
^^^^^^^^^^^^

.. doxygenenum:: rmt_channel_t
.. doxygenenum:: rmt_mem_owner_t
.. doxygenenum:: rmt_source_clk_t
.. doxygenenum:: rmt_data_mode_t
.. doxygenenum:: rmt_mode_t
.. doxygenenum:: rmt_idle_level_t
.. doxygenenum:: rmt_carrier_level_t

结构体
^^^^^^^^^^

.. doxygenstruct:: rmt_tx_config_t
    :members:

.. doxygenstruct:: rmt_rx_config_t
    :members:

.. doxygenstruct:: rmt_config_t
    :members:


函数
^^^^^^^^^

.. doxygenfunction:: rmt_set_clk_div
.. doxygenfunction:: rmt_get_clk_div
.. doxygenfunction:: rmt_set_rx_idle_thresh
.. doxygenfunction:: rmt_get_rx_idle_thresh
.. doxygenfunction:: rmt_set_mem_block_num
.. doxygenfunction:: rmt_get_mem_block_num
.. doxygenfunction:: rmt_set_tx_carrier
.. doxygenfunction:: rmt_set_mem_pd
.. doxygenfunction:: rmt_get_mem_pd
.. doxygenfunction:: rmt_tx_start
.. doxygenfunction:: rmt_tx_stop
.. doxygenfunction:: rmt_rx_start
.. doxygenfunction:: rmt_rx_stop
.. doxygenfunction:: rmt_memory_rw_rst
.. doxygenfunction:: rmt_set_memory_owner
.. doxygenfunction:: rmt_get_memory_owner
.. doxygenfunction:: rmt_set_tx_loop_mode
.. doxygenfunction:: rmt_get_tx_loop_mode
.. doxygenfunction:: rmt_set_rx_filter
.. doxygenfunction:: rmt_set_source_clk
.. doxygenfunction:: rmt_get_source_clk
.. doxygenfunction:: rmt_set_idle_level
.. doxygenfunction:: rmt_get_status
.. doxygenfunction:: rmt_set_intr_enable_mask
.. doxygenfunction:: rmt_clr_intr_enable_mask
.. doxygenfunction:: rmt_set_rx_intr_en
.. doxygenfunction:: rmt_set_err_intr_en
.. doxygenfunction:: rmt_set_tx_intr_en
.. doxygenfunction:: rmt_set_evt_intr_en
.. doxygenfunction:: rmt_set_pin
.. doxygenfunction:: rmt_config
.. doxygenfunction:: rmt_isr_register
.. doxygenfunction:: rmt_fill_tx_items
.. doxygenfunction:: rmt_driver_install
.. doxygenfunction:: rmt_driver_uninstall
.. doxygenfunction:: rmt_write_items
.. doxygenfunction:: rmt_wait_tx_done
.. doxygenfunction:: rmt_get_ringbuf_handler

