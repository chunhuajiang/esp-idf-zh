ESP-IDF GATT SECURITY SERVICE 示例
================================================

本示例用于向用户演示如何使用 ESP BLE security API 与对端设备建立连接 & 通信。

1.在初始化阶段应当使用 API esp_ble_gap_set_security_param 给 BLE 协议栈设置安全修改参数。
2.使用 API esp_ble_set_encryption API 开始加密；如果对端设备主动加密，则应当在接收到 ESP_GAP_BLE_SEC_REQ_EVT 时使用 API esp_ble_gap_security_rsp 发送响应消息。
3.当加密完成后，会收到事件 ESP_GAP_BLE_AUTH_CMPL_EVT。


