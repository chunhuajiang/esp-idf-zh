***********************************
在 Windows 上设置 Eclipse IDE
***********************************

在 Windows 上面配置 Eclipse 需要一些不同的步骤，下面将展示完整的配置步骤。

（对于 OS X 和 Linux 上面的指令，请参考 :doc:`Eclipse IDE page <eclipse-setup>`）

安装 Eclipse IDE
======================

请按照 :ref:`安装 Eclipse IDE <eclipse-install-steps>` 中的步骤安装 Eclipse。

.. _eclipse-windows-setup:

在 Windows 上设置 Eclipse
=============================

当你的 Eclipse 安装完成后，你需要完成这些步骤：

导入新工程 Project
------------------

* Eclipse 会借助 ESP-IDF 中的 Makefile。这意味着，你需要先创建一个 ESP-IDF 工程。你可以使用 github 上面的 idf-template 工程，也可以使用在 esp-idf examples 子目录下的工程。

* Eclipse 启动后，依次选择 File -> Import...

* 在弹出的对话框中，选择 "C/C++" -> "Existing Code as Makefile Project"，然后点击 Next。

* 在下一页中，将 "Existing Code Location" 设置为你的 IDF 工程所在路径。这里不要把路径设置为 ESP-IDF 的根目录了（随后会设置）。你所指定的目录中应当包含一个名为 "Makefile" 的文件，即工程 Makefile。

* 在同一页中，在 "Toolchain for Indexer Settings" 下面取消复选框 "Show only available toolchains that support this platform"。

* 在出现的扩展列表中，选择 "Cygwin GCC"，然后点击 Finish。

*Note: 你可能会在 UI 上面看到警告“Cygwin GCC Toolchain could not be found”。没关系，我们将会重新配置 Eclipse，让其能够找打工具链。

工程属性
------------------

* 工程浏览器（Project Explorer）中将会出现新工程。右击工程，并在弹出的菜单中选择属性（Properties）。

* 点击 "C/C++ Build" 属性也（顶层）：

  * 取消勾选 "Use default build command"，并输入自定义编译命令： ``python ${IDF_PATH}/tools/windows/eclipse_make.py``。

* 在 "C/C++ Build" 下面点击 "Environment" 属性页：

  * 点击 "Add..."，输入名字（name）``BATCH_BUILD`` 和值（value） ``1``。

  * 再次点击 "Add..."，输入名字（name） ``IDF_PATH``。值（value）应当填写为 ESP-IDF 的完整安装路径。IDF_PATH 路径应当用斜线而不要用反斜线，即使用 *C:/Users/MyUser/Development/esp-idf*。

  * 编辑环境变量 PATH。删除已存在的值，并用 ``C:\msys32\usr\bin;C:\msys32\mingw32\bin;C:\msys32\opt\xtensa-esp32-elf\bin`` 替代（如果你将 msys32 安装到其它目录了，则需要修改对应的路径）。
  
* 点击 "C/C++ General" -> "Preprocessor Include Paths, Macros, etc." 属性页：

  * 点击 "Providers" 标签

     * 在 providers 列表中，点击 "CDT GCC Built-in Compiler Settings Cygwin"。在 "Command to get compiler specs" 下面，用 ``xtensa-esp32-elf-gcc`` 将该行开始处的文本 ``${COMMAND}`` 替换到。即完整的 "Command to get compiler specs" 应当是 ``xtensa-esp32-elf-gcc ${FLAGS} -E -P -v -dD "${INPUTS}"``。
     
     * 在 providers 列表中，点击 "CDT GCC Build Output Parser"，在编译器命令行模式（Compiler command pattern）的开始处输入 ``xtensa-esp32-elf-``。即编译器目录模式的完整路径是 ``xtensa-esp32-elf-(g?cc)|([gc]\+\+)|(clang)``。
     

在 Eclipse 中编译
-------------------

请按照 :ref:`在 Eclipse 中编译 <eclipse-build-project>` 中的步骤进行编译。

技术细节
=================

**仅争对 Windows 专家和好奇心比较重的小伙伴**

Explanations of the technical reasons for some of these steps. You don't need to know this to use esp-idf with Eclipse on Windows,
 but it may be helpful background knowledge if you plan to do dig into the Eclipse support:

* The xtensa-esp32-elf-gcc cross-compiler is *not* a Cygwin toolchain, even though we tell Eclipse that it is one. 
This is because msys2 uses Cygwin and supports Cygwin paths (of the type ``/c/blah`` instead of ``c:/blah`` or ``c:\\blah``). 
In particular, xtensa-esp32-elf-gcc reports to the Eclipse "built-in compiler settings" function that its built-in include directories 
are all under ``/usr/``, which is a Unix/Cygwin-style path that Eclipse otherwise can't resolve. By telling Eclipse the compiler is Cygwin,
 it resolves these paths internally using the ``cygpath`` utility.

* The same problem occurs when parsing make output from esp-idf. Eclipse parses this output to find header directories,
 but it can't resolve include directories of the form ``/c/blah`` without using ``cygpath``. There is a heuristic that
  Eclipse Build Output Parser uses to determine whether it should call ``cygpath``, but for currently unknown reasons the
   esp-idf configuration doesn't trigger it. For this reason, the ``eclipse_make.py`` wrapper script is used to call ``make`` 
   and then use ``cygpath`` to process the output for Eclipse.
