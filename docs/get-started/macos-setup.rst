**************************************
为 Mac OS 设置标准工具链
**************************************

安装前提
=====================

- install pip::

    sudo easy_install pip

- install pyserial::

    sudo pip install pyserial


工具链的设置
===============

macOS 版的 ESP32 工具链可以从 Espressif 的网站下载：

https://dl.espressif.com/dl/xtensa-esp32-elf-osx-1.22.0-61-gab8375a-5.2.0.tar.gz

下载完成后，将它解压到 ``~/esp`` 目录 ::

    mkdir -p ~/esp
    cd ~/esp
    tar -xzf ~/Downloads/xtensa-esp32-elf-osx-1.22.0-61-gab8375a-5.2.0.tar.gz

.. _setup-macos-toolchain-add-it-to-path:

工具链将会被解压到 ``~/esp/xtensa-esp32-elf/`` 目录。

要使用工具链，你还需要在 ``~/.profile`` 文件中更新环境变量 ``PATH``。要使 ``xtensa-esp32-elf`` 在所有的终端会话中有效，需要将下面这一行代码添加到你的 ``~/.profile`` 文件中 ::

    export PATH=$PATH:$HOME/esp/xtensa-esp32-elf/bin

可选地，你也可以给上面的命令创建一个别名。这样的好处是，你只在需要使用它的时候才获取工具链。你只需要将下面这行代码添加到 ``~/.profile`` 文件中即可 ::

    alias get_esp32="export PATH=$PATH:$HOME/esp/xtensa-esp32-elf/bin"

然后，当你需要使用工具链时，在命令行输入 ``get_esp32``，然后工具链会自动添加到你的 ``PATH``中。

后续步骤
==========

要继续设置开发环境，请参考 :ref:`get-started-get-esp-idf` 一节。


相关文档
=================

.. toctree::
    :maxdepth: 1

    macos-setup-scratch
