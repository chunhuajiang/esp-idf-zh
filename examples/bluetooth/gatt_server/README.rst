ESP-IDF GATT SERVER 示例
========================

本示例用于向用户演示如何使用 ESP_API 创建 GATT Server。

选项设置步骤：
    1. make menuconfig.
    2. 进入配置菜单 "Component config".
    3. 进入配置菜单 "Example 'GATT SERVER' Config".
    4. 选择其它配置

更新说明
===========和 


2017-01-19:
    1. 使用新的 API 设置原始广播数据和原始扫描响应数据。
    2. 可以使用宏 CONFIG_SET_RAW_ADV_DATA（通过配置菜单）来配置使用原值广播/扫描响应，或者使用结构体自动配置。宏 CONFIG_SET_RAW_ADV 对广播数据和扫描响应数据都有效。
    
