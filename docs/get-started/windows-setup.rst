***************************************
Windows 平台工具链的标准设置
***************************************

引言
============

Windows 没有内置的 "make" 环境，因此如果要安装工具链，你需要一个 GNU-兼容 环境。我们这里使用 MSYS2_ 来提供该环境。你可能不需要一直使用这个环境（你可以使用 :doc:`Eclipse <eclipse-setup>` 或其它前段工具），但是它在你的屏幕后面隐藏着。


工具链的设置
===============

快速设置的方法是从 dl.espressif.com 下载集成在一起的工具链 & MSYS zip 压缩文件：

https://dl.espressif.com/dl/esp32_win32_msys2_environment_and_toolchain-20170330.zip

将 zip 压缩文件解压到 ``C:\`` (或其它路径，但是这里假设解压缩到 ``C:\``)，它会使用预先准备的环境创建一个 ``msys32`` 目录。

检出
============

运行 ``C:\msys32\mingw32.exe`` 可以打开 MSYS2 的终端窗口。该窗口的环境是一个 bash shell。

.. figure:: ../_static/msys2-terminal-window.png
    :align: center
    :alt: MSYS2 terminal window
    :figclass: align-center

    MSYS2 终端窗口

后续步骤将会使用这个窗口来为 ESP32 设置开发环境。

后续步骤
==========

要继续设置开发环境，请参考 :ref:`get-started-get-esp-idf` 一节。


相关文档
=================

.. toctree::
    :maxdepth: 1

    windows-setup-scratch


.. _MSYS2: https://msys2.github.io/
