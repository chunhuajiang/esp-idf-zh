**********************************
Scratch 设置 Linux 工具链
**********************************

下列指令是可选的，用于从 Espressif 网站下载二进制工具链。如果需呀快速设置工具链，而不是自己编译，请回到 :doc:`linux-setup` 一节。


安装前提
=====================

要编译 ESP-IDF，你需要先安装如下的软件包。

- Ubuntu and Debian::

    sudo apt-get install git wget make libncurses-dev flex bison gperf python python-serial

- Arch::

    sudo pacman -S --needed gcc git make ncurses flex bison gperf python2-pyserial


从源码编译工具链
=================================

- 安装依赖:

  - CentOS 7::

        sudo yum install gawk gperf grep gettext ncurses-devel python python-devel automake bison flex texinfo help2man libtool

  - Ubuntu pre-16.04::

        sudo apt-get install gawk gperf grep gettext libncurses-dev python python-dev automake bison flex texinfo help2man libtool

  - Ubuntu 16.04::

        sudo apt-get install gawk gperf grep gettext python python-dev automake bison flex texinfo help2man libtool libtool-bin

  - Debian::

        TODO

  - Arch::

        TODO

下载 ``crosstool-NG`` 并编译 ::

    cd ~/esp
    git clone -b xtensa-1.22.x https://github.com/espressif/crosstool-NG.git
    cd crosstool-NG
    ./bootstrap && ./configure --enable-local && make install

编译工具链 ::

    ./ct-ng xtensa-esp32-elf
    ./ct-ng build
    chmod -R u+w builds/xtensa-esp32-elf

工具链将会被编译到 ``~/esp/crosstool-NG/builds/xtensa-esp32-elf``。请参考 :ref:`标准设置指令 <setup-linux-toolchain-add-it-to-path>` 将工具链添加到你的 ``PATH``中。


后续步骤
==========

要继续设置开发环境，请参考 :ref:`get-started-get-esp-idf` 一节。
