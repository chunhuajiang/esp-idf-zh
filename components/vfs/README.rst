虚拟文件系统(VFS)组件
============================

概述
--------

虚拟文件系统（VFS）组件为驱动程序提供了统一的接口，可以执行类似文件对象的操作。这既可以是一个真实文件系统（FAT、SPIFFS 等），也可以是暴露了类似文件接口的设备驱动程序。

该组件允许 C 库函数（例如 fopen、fprintf）与文件系统驱动程序一起工作。在顶层，每个文件系统驱动程序都关联了某些路径前缀。当某个 C 库函数需要打开文件时，VFS 组件会查找与文件的路径相关的文件系统驱动，然后将调用转给那个驱动。


例如，你可以通过前缀 ``/fat`` 注册一个 FAT 文件系统，然后调用 ``fopen("/fat/file.txt", "w")``。VFS 组件将会调用 FAT 驱动 ``open`` 函数，并将参数 ``/file.txt`` （以及一些 mode 标志）传递给它。随后对返回的 ``FILE*`` 文件流进行调用的 C 库函数也会被转给 FAT 驱动。

FS 注册
---------------

要注册一个 FS 驱动，应用程序需要定义一个 esp_vfs_t 结构体的实例，并初始化它里面的函数指针 ::

    esp_vfs_t myfs = {
        .fd_offset = 0,
        .flags = ESP_VFS_FLAG_DEFAULT,
        .write = &myfs_write,
        .open = &myfs_open,
        .fstat = &myfs_fstat,
        .close = &myfs_close,
        .read = &myfs_read,
    };

    ESP_ERROR_CHECK(esp_vfs_register("/data", &myfs, NULL));

你可以使用的 API 依赖于 FS 驱动程序申明 API 的方式，例如 ``read``, ``write``, 等, 或 ``read_p``, ``write_p``等。

情形 1: API 函数定义时没有额外的上下文指针 (FS driver is a singleton)::

    size_t myfs_write(int fd, const void * data, size_t size);

    // In definition of esp_vfs_t:
        .flags = ESP_VFS_FLAG_DEFAULT,
        .write = &myfs_write,
    // ... other members initialized
    
    // 当注册 FS 时，上下文指针(第三个参数)是 NULL:
    ESP_ERROR_CHECK(esp_vfs_register("/data", &myfs, NULL));

情形 2: API 函数定义时有额外的上下文指针 (FS 驱动支持多个实例)::

    size_t myfs_write(myfs_t* fs, int fd, const void * data, size_t size);

    // In definition of esp_vfs_t:
        .flags = ESP_VFS_FLAG_CONTEXT_PTR,
        .write_p = &myfs_write,
    // ... other members initialized
    
    // 当注册 FS 时，FS 上下文指针传递给了第三个参数
    // (hypothetical myfs_mount function is used for illustrative purposes)
    myfs_t* myfs_inst1 = myfs_mount(partition1->offset, partition1->size);
    ESP_ERROR_CHECK(esp_vfs_register("/data1", &myfs, myfs_inst1));

    // 可以注册另外的实例
    myfs_t* myfs_inst2 = myfs_mount(partition2->offset, partition2->size);
    ESP_ERROR_CHECK(esp_vfs_register("/data2", &myfs, myfs_inst2));

路径
-----

每个注册的 FS 都有一个相关的前缀。这个前缀可以被看成是一个该分区的“挂载点”。

在已有的挂载点上注册另一个挂载点是不被支持的，其结果是未定义的。例如，下面是正确、支持的：

- FS 1 on /data/fs1
- FS 2 on /data/fs2

下面这种方法 **不会正确工作**：

- FS 1 on /data
- FS 2 on /data/fs2

打开文件时，FS 驱动只会收到文件的相对路径，例如：

- ``myfs`` 注册时的路径前缀是 ``/data``
- 应用程序调用 ``fopen("/data/config.json", ...)``
- 然后 VFS 组件将调用 ``myfs_open("/config.json", ...)``
- ``myfs`` 驱动将打开文件 ``/config.json``

VFS 不会限制文件路径的总长度，但是会限制文件路径前缀的长度，即最多为 ``ESP_VFS_PATH_MAX`` 个字符。另外，FS 驱动可能自己会对文件名长度有限制。

文件描述符
----------------


It is suggested that filesystem drivers should use small positive integers as file descriptors. VFS component assumes that ``CONFIG_MAX_FD_BITS`` bits (12 by default) are sufficient to represent a file descriptor.

If filesystem is configured with an option to offset all file descriptors by a constant value, such value should be passed to ``fd_offset`` field of ``esp_vfs_t`` structure. VFS component will then remove this offset when working with FDs of that specific FS, bringing them into the range of small positive integers.

While file descriptors returned by VFS component to newlib library are rarely seen by the application, the following details may be useful for debugging purposes. File descriptors returned by VFS component are composed of two parts: FS driver ID, and the actual file descriptor. Because newlib stores file descriptors as 16-bit integers, VFS component is also limited by 16 bits to store both parts. 

Lower ``CONFIG_MAX_FD_BITS`` bits are used to store zero-based file descriptor. If FS driver has a non-zero ``fd_offset`` field, this ``fd_offset`` is subtracted FDs obtained from the FS ``open`` call, and the result is stored in the lower bits of the FD. Higher bits are used to save the index of FS in the internal table of registered filesystems.

When VFS component receives a call from newlib which has a file descriptor, this file descriptor is translated back to the FS-specific file descriptor. First, higher bits of FD are used to identify the FS. Then ``fd_offset`` field of the FS is added to the lower ``CONFIG_MAX_FD_BITS`` bits of the fd, and resulting FD is passed to the FS driver.

::

       FD as seen by newlib                                    FD as seen by FS driver
                                                  +-----+
    +-------+---------------+                     |     |    +------------------------+
    | FS id | Zero—based FD |     +---------------> sum +---->                        |
    +---+---+------+--------+     |               |     |    +------------------------+
        |          |              |               +--^--+
        |          +--------------+                  |
        |                                            |
        |       +-------------+                      |
        |       | Table of    |                      |
        |       | registered  |                      |
        |       | filesystems |                      |
        |       +-------------+    +-------------+   |
        +------->  entry      +----> esp_vfs_t   |   |
        index   +-------------+    | structure   |   |
                |             |    |             |   |
                |             |    | + fd_offset +---+
                +-------------+    |             |
                                   +-------------+


标准 IO 流 (stdin, stdout, stderr)
-------------------------------------------

If "UART for console output" menuconfig option is not set to "None", then ``stdin``, ``stdout``, and ``stderr`` are configured to read from, and write to, a UART. It is possible to use UART0 or UART1 for standard IO. By default, UART0 is used, with 115200 baud rate, TX pin is GPIO1 and RX pin is GPIO3. These parameters can be changed in menuconfig.

Writing to ``stdout`` or ``stderr`` will send characters to the UART transmit FIFO. Reading from ``stdin`` will retrieve characters from the UART receive FIFO.

Note that while writing to ``stdout`` or ``stderr`` will block until all characters are put into the FIFO, reading from ``stdin`` is non-blocking. The function which reads from UART will get all the characters present in the FIFO (if any), and return. I.e. doing ``fscanf("%d\n", &var);`` may not have desired results. This is a temporary limitation which will be removed once ``fcntl`` is added to the VFS interface.

标准流和 FreeRTOS 任务
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``FILE`` objects for ``stdin``, ``stdout``, and ``stderr`` are shared between all FreeRTOS tasks, but the pointers to these objects are are stored in per-task ``struct _reent``. The following code::

    fprintf(stderr, "42\n");

actually is translated to to this (by the preprocessor):

    fprintf(__getreent()->_stderr, "42\n");

where the ``__getreent()`` function returns a per-task pointer to ``struct _reent`` (:component_file:`newlib/include/sys/reent.h#L370-L417>`). This structure is allocated on the TCB of each task. When a task is initialized, ``_stdin``, ``_stdout`` and ``_stderr`` members of ``struct _reent`` are set to the values of ``_stdin``, ``_stdout`` and ``_stderr`` of ``_GLOBAL_REENT`` (i.e. the structure which is used before FreeRTOS is started).

Such a design has the following consequences:

- It is possible to set ``stdin``, ``stdout``, and ``stderr`` for any given task without affecting other tasks, e.g. by doing ``stdin = fopen("/dev/uart/1", "r")``.
- Closing default ``stdin``, ``stdout``, or ``stderr`` using ``fclose`` will close the ``FILE`` stream object — this will affect all other tasks.
- To change the default ``stdin``, ``stdout``, ``stderr`` streams for new tasks, modify ``_GLOBAL_REENT->_stdin`` (``_stdout``, ``_stderr``) before creating the task.

