以太网
========

应用程序示例
-------------------

以太网示例 :example:`ethernet/ethernet`.

API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`ethernet/include/esp_eth.h`
    * :component_file:`ethernet/include/phy/phy.h`

PHY 接口
^^^^^^^^^^^^^^

PHY 模块通过配置所给 PHY 的结构体 eth_config_t 进行配置。

头部包含一个默认的配置结构体。这些默认配置中的某些成员在被用于一个特殊的 PHY 硬件配置之前需要被覆盖或重置。查看以太网的示例代码可以了解这是如何完成的。

  * :component_file:`ethernet/include/phy/phy_tlk110.h`
  * :component_file:`ethernet/include/phy/phy_lan8720.h`

类型定义
^^^^^^^^^^^^^^^^

.. doxygentypedef:: eth_phy_check_link_func
.. doxygentypedef:: eth_phy_check_init_func
.. doxygentypedef:: eth_phy_get_speed_mode_func
.. doxygentypedef:: eth_phy_get_duplex_mode_func
.. doxygentypedef:: eth_phy_func
.. doxygentypedef:: eth_tcpip_input_func
.. doxygentypedef:: eth_gpio_config_func
.. doxygentypedef:: eth_phy_get_partner_pause_enable_func

枚举
^^^^^^^^^^^^

.. doxygenenum:: eth_mode_t
.. doxygenenum:: eth_speed_mode_t
.. doxygenenum:: eth_duplex_mode_t
.. doxygenenum:: eth_phy_base_t

结构体
^^^^^^^^^^

.. doxygenstruct:: eth_config_t
    :members:


函数
^^^^^^^^^

.. doxygenfunction:: esp_eth_init
.. doxygenfunction:: esp_eth_tx
.. doxygenfunction:: esp_eth_enable
.. doxygenfunction:: esp_eth_disable
.. doxygenfunction:: esp_eth_get_mac
.. doxygenfunction:: esp_eth_smi_write
.. doxygenfunction:: esp_eth_smi_read
.. doxygenfunction:: esp_eth_smi_wait_value
.. doxygenfunction:: esp_eth_smi_wait_set
.. doxygenfunction:: esp_eth_free_rx_buf


PHY 配置常量
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. doxygenvariable:: phy_tlk110_default_ethernet_config
.. doxygenvariable:: phy_lan8720_default_ethernet_config
