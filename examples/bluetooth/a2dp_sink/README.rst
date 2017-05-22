ESP-IDF A2DP-SINK 示例
======================

A2DP audio sink 角色的示例。

本示例为用户演示如何使用 ESP_API 创建一个 GATT Server。

选项设置步骤：
    1. make menuconfig.
    2. 进入菜单 "Component config", 选择 "Bluetooth"
    3. 进入 Bluetooth 菜单，选择 "Classic Bluetooth"，并不要选择 "Release DRAM from Classic BT controller"
    4. 选择你自己的其它选项

程序启动后，其它的蓝牙设备，例如智能手机，可以发现这个命名为 "ESP_SPEAKER" 的设备。当建立连接后，就可以传输音频数据，板子会打印所传输的音频数据报文。
