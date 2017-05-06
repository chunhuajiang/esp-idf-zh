mDNS 服务
============

概述
--------

mDNS 是一个多播 UDP 服务，它用于提供本地网络服务和发现主机。

mDNS 在大多数操作系统中都已默认安装，或者可以用于独立的软件包。在 ``Mac OS`` 上面，它默认已被安装，且被叫做 ``Bonjour``。苹果发布了一个 ``Windows`` 的安装器，可以在 `on Apple's support page <https://support.apple.com/downloads/bonjour%2520for%2520windows>`_ 上面找到。在 ``Linux`` 上，mDNS 由 `avahi <https://github.com/lathiat/avahi>`_ 提供，且通常都已默认安装。

mDNS 属性
^^^^^^^^^^^^^^^

    * ``主机名（hostname）``: 设备将要相应的主机名。如果没设置，``主机名`` 将会从接口中读取。例如: ``my-esp32`` 会被解析为 ``my-esp32.local``。
    * ``默认实例（default_instance）``: 设备的友好名字，例如 ``Jhon's ESP32 Thing``。如果未被设置，默认使用 ``主机名``。

为 STA 接口启动 mDNS 并设置 ``hostname`` 和 ``default_instance`` 的示例：

  ::

    mdns_server_t * mdns = NULL;
    
    void start_mdns_service()
    {
        //initialize mDNS service on STA interface
        esp_err_t err = mdns_init(TCPIP_ADAPTER_IF_STA, &mdns);
        if (err) {
            printf("MDNS Init failed: %d\n", err);
            return;
        }
    
        //set hostname
        mdns_set_hostname(mdns, "my-esp32");
        //set default instance
        mdns_set_instance(mdns, "Jhon's ESP32 Thing");
    }

mDNS 服务
^^^^^^^^^^^^^

mDNS 可以广播你的设备所提供给的网络服务。每个服务通过一些属性定义。

    * ``服务（service）``: 所需的服务类型，使用下划线作为前缀。一些通过类型可以在 `这里 <http://www.dns-sd.org/serviceTypes.html>`_ 找到。
    * ``协议（proto）``: 服务运行所需的协议，以下划线作为前缀，例如： ``_tcp`` 或者 ``_udp`` 。
    * ``端口（port）``: 服务运行所需的端口。
    * ``实例（instance）``: 服务的友好名字，例如 ``Jhon's ESP32 Web Server``。如果未定义，则使用 ``默认实例``。
    * ``文本（txt）``: ``var=val`` 类型的字符串数组，用于为你的服务定义属性。

添加服务和不同属性的示例：

  ::

    void add_mdns_services()
    {
        //add our services
        mdns_service_add(mdns, "_http", "_tcp", 80);
        mdns_service_add(mdns, "_arduino", "_tcp", 3232);
        mdns_service_add(mdns, "_myservice", "_udp", 1234);
        
        //NOTE: services must be added before their properties can be set
        //use custom instance for the web server
        mdns_service_instance_set(mdns, "_http", "_tcp", "Jhon's ESP32 Web Server");

        const char * arduTxtData[4] = {
                "board=esp32",
                "tcp_check=no",
                "ssh_upload=no",
                "auth_upload=no"
        };
        //set txt data for service (will free and replace current data)
        mdns_service_txt_set(mdns, "_arduino", "_tcp", 4, arduTxtData);
        
        //change service port
        mdns_service_port_set(mdns, "_myservice", "_udp", 4321);
    }

mDNS 查询
^^^^^^^^^^

mDNS 提供了浏览服务和解析主机 IP/IPv6 地址的方法。
    
    结果用过一个链表对象 ``mdns_result_t`` 返回。如果结果是来自主机查询，则只包含 ``addr`` 和 ``addrv6``（如果找到）。服务查询将存在于所找到的结构的所有字段。
    
解析主机 IP 的示例：

  ::

    void resolve_mdns_host(const char * hostname)
    {
        printf("mDNS Host Lookup: %s.local\n", hostname);
        //run search for 1000 ms
        if (mdns_query(mdns, hostname, NULL, 1000)) {
            //results were found
            const mdns_result_t * results = mdns_result_get(mdns, 0);
            //itterate through all results
            size_t i = 1;
            while(results) {
                //print result information
                printf("  %u: IP:" IPSTR ", IPv6:" IPV6STR "\n", i++
                    IP2STR(&results->addr), IPV62STR(results->addrv6));
                //load next result. Will be NULL if this was the last one
                results = results->next;
            }
            //free the results from memory
            mdns_result_free(mdns);
        } else {
            //host was not found
            printf("  Host Not Found\n");
        }
    }

解析本地服务的示例：

  ::

    void find_mdns_service(const char * service, const char * proto)
    {
        printf("mDNS Service Lookup: %s.%s\n", service, proto);
        //run search for 1000 ms
        if (mdns_query(mdns, service, proto, 1000)) {
            //results were found
            const mdns_result_t * results = mdns_result_get(mdns, 0);
            //itterate through all results
            size_t i = 1;
            while(results) {
                //print result information
                printf("  %u: hostname:%s, instance:\"%s\", IP:" IPSTR ", IPv6:" IPV6STR ", port:%u, txt:%s\n", i++,
                    (results->host)?results->host:"NULL", (results->instance)?results->instance:"NULL",
                    IP2STR(&results->addr), IPV62STR(results->addrv6),
                    results->port, (results->txt)?results->txt:"\r");
                //load next result. Will be NULL if this was the last one
                results = results->next;
            }
            //free the results from memory
            mdns_result_free(mdns);
        } else {
            //service was not found
            printf("  Service Not Found\n");
        }
    }

使用上面的方法的示例：

  ::

    void my_app_some_method(){
        //search for esp32-mdns.local
        resolve_mdns_host("esp32-mdns");
        
        //search for HTTP servers
        find_mdns_service("_http", "_tcp");
        //or file servers
        find_mdns_service("_smb", "_tcp"); //windows sharing
        find_mdns_service("_afpovertcp", "_tcp"); //apple sharing
        find_mdns_service("_nfs", "_tcp"); //NFS server
        find_mdns_service("_ftp", "_tcp"); //FTP server
        //or networked printer
        find_mdns_service("_printer", "_tcp");
        find_mdns_service("_ipp", "_tcp");
    }

应用程序示例
-------------------

mDNS 的服务器/扫描示例程序： :example:`protocols/mdns`.

API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`mdns/include/mdns.h`

宏
^^^^^^


类型定义
^^^^^^^^^^^^^^^^

.. doxygentypedef:: mdns_server_t
.. doxygentypedef:: mdns_result_t

枚举
^^^^^^^^^^^^


结构体
^^^^^^^^^^

.. doxygenstruct:: mdns_result_s
    :members:


函数
^^^^^^^^^

.. doxygenfunction:: mdns_init
.. doxygenfunction:: mdns_free
.. doxygenfunction:: mdns_set_hostname
.. doxygenfunction:: mdns_set_instance
.. doxygenfunction:: mdns_service_add
.. doxygenfunction:: mdns_service_remove
.. doxygenfunction:: mdns_service_instance_set
.. doxygenfunction:: mdns_service_txt_set
.. doxygenfunction:: mdns_service_port_set
.. doxygenfunction:: mdns_service_remove_all
.. doxygenfunction:: mdns_query
.. doxygenfunction:: mdns_query_end
.. doxygenfunction:: mdns_result_get_count
.. doxygenfunction:: mdns_result_get
.. doxygenfunction:: mdns_result_free

