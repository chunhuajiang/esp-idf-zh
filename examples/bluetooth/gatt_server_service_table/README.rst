ESP-IDF GATT SERVER 创建属性表格示例
===============================================

该示例用于向用户演示如何使用 ESP_API 创建 GATT Server 属性表格。使用该表格无需使用函数 "attribute create" 就能很方便地创建 GATT server 服务数据库 。实际上，有两种方法可用于创建服务器服务和特征。其中一种是使用 esp_gatts_create_service 或者 esp_ble_gatts_add_char 等。另一种是使用 esp_ble_gatts_create_attr_tab。 要注意的是：这两种方法不能用于同一种服务，可以用于不同的服务中。


