.. include:: ../../../components/vfs/README.rst

应用程序示例
-------------------

`Instructions`_

.. _Instructions: ../template.html

API 参考手册
-------------

头文件
^^^^^^^^^^^^

  * :component_file:`vfs/include/esp_vfs.h`
  * :component_file:`vfs/include/esp_vfs_dev.h`

宏
^^^^^^

.. doxygendefine:: ESP_VFS_PATH_MAX
.. doxygendefine:: ESP_VFS_FLAG_DEFAULT
.. doxygendefine:: ESP_VFS_FLAG_CONTEXT_PTR

结构体
^^^^^^^^^^

.. doxygenstruct:: esp_vfs_t
   :members:

函数
^^^^^^^^^

.. doxygenfunction:: esp_vfs_register
.. doxygenfunction:: esp_vfs_unregister
.. doxygenfunction:: esp_vfs_write
.. doxygenfunction:: esp_vfs_lseek
.. doxygenfunction:: esp_vfs_read
.. doxygenfunction:: esp_vfs_open
.. doxygenfunction:: esp_vfs_close
.. doxygenfunction:: esp_vfs_fstat
.. doxygenfunction:: esp_vfs_stat
.. doxygenfunction:: esp_vfs_link
.. doxygenfunction:: esp_vfs_unlink
.. doxygenfunction:: esp_vfs_rename
.. doxygenfunction:: esp_vfs_dev_uart_register
