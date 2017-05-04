将 IDF_PATH 添加到 User Profile
================================

要使环境变量 ``IDF_PATH`` 在系统重启后依然有效，需要将它添加到用户 profile，具体方法请参考下面的指令。


.. _add-idf_path-to-profile-windows:

Windows
-------

用户 profile 脚本位于 ``C:/msys32/etc/profile.d/`` 目录，它会在你每次打开一个新的 MSYS2 窗口时被执行。

#. 在 ``C:/msys32/etc/profile.d/`` 目录创建一个新的脚本文件，将将其命名为 ``export_idf_path.sh``。

#. 指定 ESP-IDF 目录所在路径。这与你的系统配置相关，比如你的路径可能是 ``C:\msys32\home\Krzysztof\esp\esp-idf``。

#. 向脚本文件中添加 ``export`` 命令，例如 ::

       export IDF_PATH="C:/msys32/home/Krzysztof/esp/esp-idf"

   记得在原始 Windows 路径中将反斜线替换为斜线。
   
#. 保存脚本文件。

#. 关闭 MSYS2 窗口后重新打开。检查 ``IDF_PATH`` 是否被设置了，输入 ::

       printenv IDF_PATH

   之前在脚本文件中输入的路劲会被打印出来。
   
如果你不希望将 ``IDF_PATH`` 永久设置到 user profile 中，你需要在每次重新打开 MSYS2 窗口时手工输入下面的命令 ::

    export IDF_PATH="C:/msys32/home/Krzysztof/esp/esp-idf"

如果你是从 :ref:`get-started-setup-path` 一节中进入本页的，可以直接点击 :ref:`get-started-start-project` 跳转回去。


.. _add-idf_path-to-profile-linux-macos:

Linux 和 MacOS
---------------

直接将下面一行代码添加到 ``~/.bash`` 文件就能设置 ``IDF_PATH``  ::

    export IDF_PATH=~/esp/esp-idf

注销并重新登录后，修改将生效。

如果你不希望永久设置 ``IDF_PATH``，你需要在每次重新打开终端窗口后手工输入上面的代码。

运行下面的命令可以检查 ``IDF_PATH`` 是否设置正确 ::

    printenv IDF_PATH

之前在 ``~/.bash`` 文件中输入（或者手工输入）的路径将会被打印出来。

如果你是从 :ref:`get-started-setup-path` 一节中进入本页的，可以直接点击 :ref:`get-started-start-project` 跳转回去。
