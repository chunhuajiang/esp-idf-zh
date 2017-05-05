********************************
使用 Eclipse IDE 编译和烧写
********************************

.. _eclipse-install-steps:

安装 Eclipse IDE
======================

Eclipse 提供了一个可用于编写、编译和调试 ESP-IDF 工程的图形化集成开发环境。

* 请先在你的平台上按照好 esp-idf。

* 我们建议先使用命令行编译一个工程，感受一下整个过程是如何工作的。此外，你也需要使用命令行通过（ ``make menuconfig``）来配置你的 esp-idf 工程，因为当前并不支持在 Eclipse 里面进行配置。

* 从 eclipse.org_ 下载适合你的平台的安装器（Installer）。

* 运行 Eclipse 安装器，选择 "Eclipse for C/C++ Development" （在其它某些地方也将它叫做 CDT）。

Windows 用户
=============

在 Windows 上使用 Eclipse 来编译 ESP-IDF 的配置步骤略有不同，请参考 :ref:`Windows Eclipse IDE 指南 <eclipse-windows-setup>`.

设置 Eclipse
==================

当你的 Eclipse 安装完成后，你需要完成这些步骤：


导入新工程 Project
------------------

* Eclipse 会借助 ESP-IDF 中的 Makefile。这意味着，你需要先创建一个 ESP-IDF 工程。你可以使用 github 上面的 idf-template 工程，也可以使用在 esp-idf examples 子目录下的工程。

* Eclipse 启动后，依次选择 File -> Import...

* 在弹出的对话框中，选择 "C/C++" -> "Existing Code as Makefile Project"，然后点击 Next。

* 在下一页中，将 "Existing Code Location" 设置为你的 IDF 工程所在路径。这里不要把路径设置为 ESP-IDF 的根目录了（随后会设置）。你所指定的目录中应当包含一个名为 "Makefile" 的文件，即工程 Makefile。


* 在同一页中，在 "Toolchain for Indexer Settings" 下面选择 "Cross GCC"，然后点击 Finish。


工程属性
------------------

* 工程浏览器（Project Explorer）中将会出现新工程。右击工程，并在弹出的菜单中选择属性（Properties）。

* 在 "C/C++ Build" 下面点击 "Environment" 属性页。点击 "Add..." ，并输入名字（name）``BATCH_BUILD`` 和值（value）``1``。

* 再次点击 "Add..."，输入名字（name） ``IDF_PATH``。值（value）应当填写为 ESP-IDF 的完整安装路径。

* 编辑环境变量 PATH。保持当前值不变，将路径追加到 Xtensa 工具链(``something/xtensa-esp32-elf/bin``) 后面。

* On macOS, add a ``PYTHONPATH`` environment variable and set it to ``/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages``. This is so that the system Python, which has pyserial installed as part of the setup steps, overrides any built-in Eclipse Python.

点击 "C/C++ General" -> "Preprocessor Include Paths" 属性页：

* 点击 "Providers" 标签

* 在 providers 列表中，点击 "CDT Cross GCC Built-in Compiler Settings"。在 "Command to get compiler specs" 下面，用 ``xtensa-esp32-elf-gcc`` 将该行开始处的文本 ``${COMMAND}`` 替换到。即完整的 "Command to get compiler specs" 应当是 ``xtensa-esp32-elf-gcc ${FLAGS} -E -P -v -dD "${INPUTS}"``。

* 在 providers 列表中，点击 "CDT GCC Build Output Parser"，在编译器命令行模式（Compiler command pattern）的开始处输入 ``xtensa-esp32-elf-``。即编译器目录模式的完整路径是 ``xtensa-esp32-elf-(g?cc)|([gc]\+\+)|(clang)``。

.. _eclipse-build-project:

在 Eclipse 中编译
-------------------

你的工程在第一次编译之前，Eclipse 可能会显示许多关于未定义值的错误和警告，这是因为某些源文件是由 esp-idf 编译过程中自动生成的。当你编译完工程后，这些错误和警告就会消失。

* 在 Eclipse 中点击 OK 按钮关闭属性对话框。

* 在 Eclipse 外面，打开一个命令行提示符，进入工程所在目录，运行命令 ``make menuconfig`` 来配置你的工程的 esp-idf 设置。目前，这一步必须在 Eclipse 外面运行。

* 如果你编译之前没有运行配置步骤，esp-idf 会在命令行提示你进行配置，但是 Eclipse 不能处理这样的消息，因此编译过程将会挂起或者失败。

* 回到 Eclipse，选择 Project -> Build 来编译你的工程。

**TIP**: 如果你的工程已在 Eclipse 外面编译过，你可能需要执行 Project -> Clean before choosing Project -> Build 操作，这样 Eclipse 就能看到所有源文件的编译器参数。它使用这些参数来判断头文件的包含路径。

从 Eclipse 烧写
------------------

你可以将 "make flash" 目标集成到你的 Eclipse 工程中，然后通过 Eclipse UI 调用 esptool.py 来完成烧写操作：

* 在工程浏览器（Project Explorer）中右键你的工程（一定要确保你选择的是一个工程，而不是工程中的某个目录，否则 Eclipse 不能找到正确的 Makefile 文件）。

* 从弹出的菜单中选择 Make Targets -> Create 。

* 在目标名（target name）中输入 "flash"，保持其它选项默认不变。

* 现在，你可以使用 Project -> Make Target -> Build (Shift+F9) 来编译预定义的自定义 flash 目标，它会编译和烧写工程。

注意，你需要使用 "make menuconfig" 来设置串口和与烧写相关的其它配置项。"make menuconfig" 任然需要在命令行终端中执行，详细相信请参考你的平台所对应的文档。

如果有需要，你可以按照相同的步骤添加 ``bootloader`` 和 ``partition_table`` 目标。

相关文档
-----------------

.. toctree::
    :maxdepth: 1

    eclipse-setup-windows


.. _eclipse.org: http://www.eclipse.org/

