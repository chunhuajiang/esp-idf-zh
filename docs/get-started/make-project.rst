使用 Make 进行编译和烧写
=========================


找一个工程
-----------------

除 `esp-idf-template <https://github.com/espressif/esp-idf-template>`_ 工程之外，ESP-IDF 还在 :idf:`examples` 目录下附带了若干示例工程。

找到你想要使用的工程后，进入该目录，然后你就可以对它进行配置、编译。

配置你的工程
------------------------

::

    make menuconfig


编译你的工程
----------------------

::

    make all

... 将会编译 app、bootloader 和一个基于配置所产生的分区表。


烧写你的工程
---------------------

当 ``make all`` 完成后，它会打印一行命令，提示使用 esptool.py 来烧写芯片。不过，你也可以直接运行如下命令来烧写 ::

    make flash

该命令将会烧写整个工程（app、bootloader 和分区表）到芯片中。用于烧写程序的串行端口可以使用 `make menuconfig` 进行配置。

你不需要在运行 ``make flash`` 前运行 ``make all``，因为 ``make flash`` 会自动重新编译它所需要的任何文件。


仅编译 & 烧写 APP
---------------------------------

完成第一次烧写后，你可以只编译和烧写应用程序，而不需要 bootloader 和分区表：

* ``make app`` - 仅编译应用程序
* ``make app-flash`` - 仅烧写应用程序

``make app-flash`` 会自动重新编译它所需要的任何文件。

如果 bootloader 和分区表没有改动，则不需要重新烧写。

分区表
-------------------

工程编译完成后，"build" 目录下将会产生一个名字类似于 "my_app.bin" 的二进制文件，这是可以被 ESP32 bootloader 加载的二进制镜像。

一片 ESP32 flash 上面可以包含多个 app 和多种数据（校正数据、文件系统、参数存储器等）。因此，一个分区表被烧写到 flash 的地址 0x8000 处。

分区表的每个入口都有一个名字（label）、类型（app、数据或其它一些类型）、子类型和分区表被加载时在 flash 中的偏移。

使用分区表最简单的方法是运行 `make menuconfig` 并选择一个预定义的分区表：

* "Single factory app, no OTA"
* "Factory app, two OTA definitions"

在这两个情况下，工厂 app 都会被烧写到偏移地址 0x10000 处。如果你输入 如果你输入 `make partition_table` 命令，它将会打印分区表的参数。

关于 :doc:`分区表 <../api-guides/partition-tables>` 和如何创建自定义变量的更多细节，请参考 :doc:`此文档 <../api-guides/partition-tables>`。

