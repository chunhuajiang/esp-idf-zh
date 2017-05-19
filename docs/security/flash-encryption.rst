Flash 加密
================

Flash 加密功能可用于加密 ESP32 所连接的 SPI flash 上面的内容。当 flash 加密被使能后，从 SPI flash 上面读出的数据不足以用于恢复 flash 上面所存储的大多数内容。

Falsh 加密是与 :doc:`安全启动 <secure-boot>` 相独立的另一个功能，你可以在不使能安全加密的情况下单独使用 flash 加密功能。不过，为了有一个更加安全的环境，我们推荐同时使用这两种技术。

**IMPORTANT: 使能 flash 加密将会限制你今后可以对 ESP32 进行更新的次数。请确保仔细阅读本文档（包括 :ref:`flash-encryption-limitations`）并充分理解使能 flash 加密的含义。 **


背景
----------

- flash 的内容使用秘钥长度为 256 比特的 AES 进行加密。flash 的加密密钥存储在芯片内部的 efuse 中，且（默认）被保护，以免软件访问呢。

- 通过 ESP32 的 flash cache 映射功能对 flash 的访问是透明的 - 读取时，所有被映射到这段地址空间的 flash 区域都会被透明地解密。

- 加密是通过给 ESP32 烧写明码文本数据、然后由 bootloader 在第一次启动准备就绪后对这些数据进行加密完成的（如果加密被使能）。

- 不是所有的 flash 都会被加密。下列 flash 数据不会被加密：

  - Bootloader
  - 安全启动 bootloader digest （如果安全启动被使能）
  - 分区表
  - 所有的 "app" 类型的分区
  - 在分区表中所有标记了 "encrypt" 的分区

为了易于访问，或者为了使用 flash 友好的更新算法（数据加密后对算法有影响），有时候需要某些数据分区不被加密。非易失型存储器的 "NVS" 分区不能被加密。

- flash 的加密秘钥存储在 ESP32 芯片内部的 efuse 密钥块 1 中。默认情况下，这个密钥是读/写保护的，因此软件不能访问或者修改它。

- `flash 加密算法` 使用的是 AES-256，其密钥是通过 flash 的 32 字节的块的偏移地址进行调整的。这意味着，每 32 字节的块（两个连续的 16 字节 AES 块）是通过由 flash 加密密钥推断出来的唯一的密钥（unique key）进行加密的。

- 尽管运行在芯片上的软件可以透明地对 flash 上面的内容进行解密，但是当 falsh 加密被使能后，UART bootloader（默认）不能对数据进行加密/解密。

- 如果 flash 加密被使能，当程序员在 :ref:`使用加密的 flash <using-encrypted-flash>` 写代码时必须进行更加周详的考虑。

.. _flash-encryption-initialisation:

Flash 加密的初始化
-------------------------------

这里描述的是 flash 加密初始化的默认（且推荐）过程。如果需要实现特殊的功能，也可以自定义该过程，具体细节请参考 :ref:`flash-encryption-advanced-features`。

**IMPORTANT: 一旦在某次启动时使能 flash 加密后，随后通过串口对 flash 重新烧写最多只有三次机会。** 且需要执行特殊的步骤（参考文档 :ref:`updating-encrypted-flash-serial`）才能进行烧写。

- 如果安全启动被使用，则再也不能在物理上进行重新烧写。
- OTA 可以用于更新 flash 上面的内容，没有受到这种限制。
- 当在开发过程中使能 flash 加密时，使用 `预生成的 flash 加密密钥` 可以在物理上对预加密的数据进行无数次的重新烧写。**

使能 flash 加密的过程：

- bootloader 在被编译时必须使能 flash 加密功能。在 ``make menuconfig``中，进入 "Security Features" 并给 "Enable flash encryption on boot" 选择 "Yes"。

- 如果同时还使能了安全启动，最好同时也选上这些选项。请先参考文档 :doc:`安全启动 <secure-boot>`。

- 像常规方法一样编译和烧写 bootloader、分区表和工厂 app。这些分区在初次被写入 flash 时是未被加密的。

- 第一次启动时，bootloader 将会看到 :ref:`FLASH_CRYPT_CNT` 被设置为 0（工厂默认），然后它会使用硬件随机数发生器生成一个 falsh 加密密钥。这个密钥会被存储在 efuse 中，且具有软件读/写保护的功能。

- 所有的加密分区然后被 bootloader 加密。加密需要一段时间（大分区最多会需要一分钟）。

**IMPORTANT: 当第一次启动在进行加密时，不要中断对 ESP32 的供电。如果供电被中断，flash 中的内容将会被破坏，然后需要使用未加密的数据进行重新烧写。这种重新烧写不会影响烧写次数限制。**

- 当烧写完成后，efuses 会在 UART bootloader 运行期间禁止对加密 flash 的访问。请查看 :ref:`uart-bootloader-encryption`  以了解高级特性。

- efuse ``FLASH_CRYPT_CONFIG`` 被烧写为最大值（``0xF``），以得到一个位数最大的密钥（在 flash 算法中被调整）。请查看 ref:`setting-flash-crypt-config` 以了解高级特性。

- 最后，:ref:`FLASH_CRYPT_CNT` 被烧写为一个初始值 1。就是这个 efuse 激活了 flash 透明加密层并限制了随后可重新烧写的次数。关于 :ref:`FLASH_CRYPT_CNT` 的更多细节请参考章节 :ref:`updating-encrypted-flash`。

- bootloader 自身复位，并从新的被加密的 flash 重启。

.. _using-encrypted-flash:

使用加密的 Flash
---------------------

ESP32 应用程序代码可以通过调用 :func:`esp_flash_encryption_enabled` 来检查当前是否使能了 flash 加密功能。

当 flash 加密被使能后， 从代码中访问 flash 上面的内容时需要考虑一些额外的东西。

Flash 加密的范围
^^^^^^^^^^^^^^^^^^^^^^^^^

无论什么时候，只要 :ref:`FLASH_CRYPT_CNT` 被设置了一个新的奇数比特位，所有通过 MMU cache 访问的 flash 内容都会被透明地解密。这包括：

- flash 上面的应用程序可执行代码（IROM）
- 存储在 flash 中的所有只读数据（DROM）
- 所有通过 :func:`esp_spi_flash_mmap` 访问的数据
- 正在被 ROM bootloader 读取的软件 bootloader 镜像

**IMPORTANT: MMU flash cache 会无条件地解码所有数据。在 flash 中存储的未加密数据会通过 flash cache 被透明地解密，然后对软件来说就是垃圾数据。**

读取加密的 Flash
^^^^^^^^^^^^^^^^^^^^^^^

如果要在读取数据时不使用 flash cache MMU 映射，我们推荐使用分区读取函数 :func:`esp_partition_read`。当使用这个函数时，只有从加密分区中读取的数据会被解密，其它分区读取的数据不会被解密。通过这种方法，软件可以以同一种方法访问加密和未加密的 falsh。

以其它 SPI 读 API 所读取的数据不会被解密：

- 通过 :func:`esp_spi_flash_read` 读取的数据不被解密。
- 通过 ROM 函数  :func:`SPIRead` 读取的数据不被解密（该函数不支持 esp-idf 应用程序）。
- 使用非易失性存储器 (NVS) API 存储的数据总是以解密形式进行存储/读取。


写加密的 Flash
^^^^^^^^^^^^^^^^^^^^^^^

只要可能，我们都推荐使用分区写函数 ``esp_partition_write``。当使用该函数时，只有往加密分区中写的数据会被加密，往其它分区写的数据不会被加密。通过这种方法，软件可以以同一种方法访问加密和未加密的 falsh。

当参数 write_encrypted 设置为 true 时，函数 ``esp_spi_flash_write`` 将以加密的形式写数据，否则则会以未加密的形式写数据。


ROM 函数 ``esp_rom_spiflash_write_encrypted`` 将会写加密数据到 flash，ROM 函数 ``SPIWrite`` 将会写未加密数据到 flash 中（这些函数不支持 esp-idf 应用程序）。

未加密数据的最小写尺寸是 4 字节（且是 4 字节对齐的）。由于数据加密是以块为单位的，加密数据的最小写尺寸是 16 字节（且是以 16 字节对齐的）。

.. _updating-encrypted-flash:

更新加密的 Flash
------------------------

.. _updating-encrypted-flash-ota:

OTA 更新
^^^^^^^^^^^

对加密分区进行 OTA 更新时，只要使用的函数是 ``esp_partition_write``，该分区就会被自动以加密的形式进行写。

.. _updating-encrypted-flash-serial:

串口烧写
^^^^^^^^^^^^^^^

如果没有使用安全启动，:ref:`FLASH_CRYPT_CNT` 允许通过串口烧写的方式（或其它物理方式）对 flash 进行更新，但最多有三次额外的机会。

该过程涉及烧写明码文本数据、更改（bump）:ref:`FLASH_CRYPT_CNT` 的值，从而引起 bootloader 对该数据进行重新加密。


有限的更新
~~~~~~~~~~~~~~~

这种情况下只有 4 次串口烧写机会，其中还包括初始加密 flash 在内的那次机会。

当第四次加密被禁止后，:ref:`FLASH_CRYPT_CNT` 将拥有一个最大值 `0xFF`，加密被永久禁止。

使用 :ref:`updating-encrypted-flash-ota` 或 :ref:`pregenerated-flash-encryption-key` 可以绕过这种限制。

串口烧写的注意事项
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- 当使用串口重新烧写时，需要重新烧写所有使用明码文本初始化的分区（包括 bootloader），但是可以跳过非 "当前所选择" 的那个 OTA 分区（除非在上面发现了明码文本应用程序镜像，否则不会待其进行重新加密）。不过，所有有 "加密" 标记的分区会被无条件地重新加密，这也意味着已被加密的数据会被再次加密而被破坏。

  - 使用 ``make flash`` 会烧写所有需要烧写的分区。

- 如果安全启动被使能，除非你的安全启动使用了 "重新烧写" 选项并烧写了预生成的密钥（参考 :doc:`Secure Boot <secure-boot>` 文档），否则你不能使用串口进行串行烧写。在这种情况下，你可以在偏移地址 0x0 处重新烧写一个明码文本的安全启动 digest 和 bootloader 镜像。在烧写其它明码文本数据之前，必须要先烧写这个 digest。

串口重新烧写的过程
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- 像平常一样编译应用程序。

- 像平常一样给设备烧写明码文本数据（``make flash`` 或 ``esptool.py`` 命令），烧写之前的所有加密分区（包括 bootloader）。

- 此时，设备将不能启动（提示消息 ``flash read err, 1000``），这是因为它期望看到的是一个加密的 bootloader，而实际上却是一个明码文本。

- 使用命令 ``espefuse.py burn_efuse FLASH_CRYPT_CNT`` 烧写 :ref:`FLASH_CRYPT_CNT`。espefuse.py 会自动给计数比特加 1，并禁止加密。

- 复位设备，然后设备会重新加密明码文本分区，然后再次烧写 :ref:`FLASH_CRYPT_CNT` 以重新使能加密功能。

禁止串口更新
~~~~~~~~~~~~~~~~~~~~~~~~

如果需要阻止今后使用串口更新明码文本，可以在 flash 加密被使能后（即第一次启动完成后）使用  espefuse.py 写保护 :ref:`FLASH_CRYPT_CNT` ::

    espefuse.py --port PORT write_protect_efuse FLASH_CRYPT_CNT

这将会禁止今后做任何改动，以禁止/重新使能 flash 加密。

.. _pregenerated-flash-encryption-key:

通过预生成的 Flash 加密密钥重新烧写
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

你也可以在 PC 上面预生成一个 flash 加密密钥，然后将它烧写到 ESP32 的 efuse 密钥块中。这样做的好处是可以在主机对数据预加密，然后将加密后的数据烧写到 ESP32 上面，从而不需要明码文本烧写更新。

这在开发过程中是很有用的，因为它没有 4 次重烧的限制。此外，即使安全启动被使能，也可以无限次地重新烧写，因为 bootloader 不需要每次都被烧写。

**IMPORTANT 这种方法只是为了方便开发，不要用于实际的产品设备。如果要为产品生成 flash 加密数据，请确保使用一个高质量的随机数源产生加密密钥，且不要在多个设备之间共享同一个 flash 加密密钥。**

预生成 Flash 加密密钥
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Flash 加密密钥是一个 32 字节的随机数。你可以使用 espsecure.py 生成一个随机密钥 ::

  espsecure.py generate_flash_encryption_key my_flash_encryption_key.bin

(随机数的质量与 OS 以及 Python 所安装的随机数源相关。)

另外，如果你正在使用 :doc:`安全启动 <secure-boot>`，且有一个安全启动签名密钥，你可以生成一个安全启动私有签名密钥的 SHA-256 digest，并使用它作为 flash 加密密钥 ::

  espsecure.py digest_private-key --keyfile secure_boot_signing_key.pem my_flash_encryption_key.bin

(如果你在安全启动中使能了 :ref:`可重新烧写模式<secure-boot-reflashable>`，则这 32 字节的数据还将作为安全启动 digest 密钥。)

通过这种从全球启动签名密钥生成 flash 加密密钥的方式意味着你只需要存储一个密钥文件。不过，这种方法 **完全不适用于** 实际产品中的设备。

烧写 Flash 加密密钥
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

生成 flash 加密密钥后，你还需要将它烧写到 ESP32 的 efuse 密钥块中。**这必须在加密启动前完成**，否则 ESP32 将会产生一个随机密钥，导致软件不能访问/修改 flash 上的内容。

将密钥烧写到设备（只需要一次） ::

  espefuse.py --port PORT burn_key flash_encryption my_flash_encryption_key.bin

使用预生成的密钥第一次烧写
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

烧写完密钥后，按照默认 :ref:`flash-encryption-initialisation` 步骤进行操作，并为第一次启动烧写一个明码文本镜像。bootloader将会使用预先烧写的密钥使能 flash 加密并加密所有分区。

使用预生成的密钥重新烧写
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

当第一次启动使能加密后，重新烧写加密的镜像需要一步额外的手工步骤，即预加密我们需要烧写到 flash 中的数据。

假设这是你用于烧写明码文本数据的命令 ::

  esptool.py --port /dev/ttyUSB0 --baud 115200 write_flash 0x10000 build/my-app.bin

二进制应用程序镜像 ``build/my-app.bin`` 被烧写到偏移地址 ``0x10000`` 处。这里的文件名和偏移地址要用于加密数据 ::

  espsecure.py encrypt_flash_data --keyfile my_flash_encryption_key.bin --address 0x10000 -o build/my-app-encrypted.bin build/my-app.bin

上面这条命令会使用所提供的密钥加密 ``my-app.bin``，并产生一个加密文件 ``my-app-encrypted.bin``。请确保这里的地址参数与你将要烧写二进制镜像的地址相匹配。

然后，使用 esptool.py 烧写加密后的二进制文件 ::

    esptool.py --port /dev/ttyUSB0 --baud 115200 write_flash 0x10000 build/my-app-encrypted.bin

至此，已经不需要其它的步骤了，因为数据已经被加密并烧写完成了。

禁止 Flash 加密
--------------------------

如果你由于某些原因意外地把 flash 加密功能使能了， the next flash of plaintext data will soft-brick the ESP32 （设备将会连续重启，并打印错误 ``flash read err, 1000``）。

你可以通过写 :ref:`FLASH_CRYPT_CNT` 再次禁止 flash 加密：

- 首先，运行 ``make menuconfig`` 并取消 "Security Features" 下面的复选框 "Enable flash encryption boot"。
- 退出配置菜单并保存新的配置。
- 再次运行 ``make menuconfig`` ，再次检查是否真的禁止了该选项！*如果该选项被使能，bootloader 启动时会立即再次重新加密*。
- 运行 ``make flash`` to 编译并烧写 flash 加密未被使能的 bootloader 和应用程序。
- 运行 ``espefuse.py`` (在 ``components/esptool_py/esptool`` 下面) 禁止 :ref:`FLASH_CRYPT_CNT`)::
    espefuse.py burn_efuse FLASH_CRYPT_CNT

给 ESP32 复位，此时 flash 加密功能会被禁止，bootloader 会像平常一样启动。

.. _flash-encryption-limitations:

Flash 加密的限制
-------------------------------

Flash 加密功能可以阻止读取加密的 flash 的内容，保护固件，使其不会在未授权时被读取和修改。如果打算使用 flash 加密系统，则非常有必要理解它的限制：

- Flash 加密的安全性完全由密钥决定。因此，我们推荐在设备第一次启动时由设备产生密钥（这是默认的行为）。如果密钥是在设备外产生的，请确保其过程的正确性。

- 不是所有的数据都会被加密存储。如果需要在 flash 上存储数据，请先检查你所使用的方法（库、API 等）是否支持 flash 加密。

- Flash 加密不能阻止知道 flash 顶层布局的攻击者。这是因为每一对相邻的 16 字节 AES 块使用的是同样的 AES 密钥。当这些相邻的 16 字节块包含相同的内容（例如空区域或填充(pading)区域）时，这些块将会加密生成匹配的加密块对，攻击者可以在加密设备间进行顶层比较（例如判断两个设备运行的固件是否是同一版本）。

- 同样的理由，攻击者还可以判断两个相连的 16 字节块（32 字节对齐的）是否包含相同的内容。因此一定要记住，如果你想在 flash 上面存储敏感的数据，需要对你的存储方法进行进行一定的设计，确保不会发生这样的事（每 16 个字节使用一个字节的计数器或者其它某些不同的值是足够的）。

- 仅使用 Flash 加密功能不能阻止攻击者修改设备的固件。如果要阻止设备运行未被授权的固件，需要结合使用 flash 加密功能和 :doc:`安全启动 <secure-boot>` 功能。

.. _flash-encryption-advanced-features:

Flash 加密高级功能
----------------------------------

下列信息用于描述 flash 加密的高级功能：

加密分区标志
^^^^^^^^^^^^^^^^^^^^^^^^

某些分区默认被加密。否则，可以将任何分区标记为需要加密：


在描述 :doc:`分区表 <../api-guides/partition-tables>` 的 CSV 文件中，存在一个标志字段。该字段通常是空的。如果你在这个字段中写上 "encrypted"，则这个分区将会在分区表中被标记为"加密的"，写到这里的数据也被当当做加密的（与应用程序分区相同）::

   # Name,   Type, SubType, Offset,  Size, Flags
   nvs,      data, nvs,     0x9000,  0x6000
   phy_init, data, phy,     0xf000,  0x1000
   factory,  app,  factory, 0x10000, 1M
   secret_data, 0x40, 0x01, 0x20000, 256K, encrypted

- 默认的分区表不包含任何加密数据分区。

- "app" 分区不需要被标记为 "encrypted"，因为它们总是被当做加密的。

- 如果 flash 加密功能未被使能，则 "encrypted" 标志不会起任何作用。

- 如果你希望从物理上阻止访问/修改带有 ``phy_init`` 数据的 ``phy`` 分区，你也可以将该分区标记为 "encrypted"。

- ``nvs`` 分区不能被标记为 "encrypted"。

.. _uart-bootloader-encryption:

使能 UART Bootloader 加密/解密
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

默认情况下，在第一次启动时，flash 加密过程会烧写 efuses ``DISABLE_DL_ENCRYPT``、``DISABLE_DL_DECRYPT`` 和 ``DISABLE_DL_CACHE``:

- ``DISABLE_DL_ENCRYPT``，当运行在 UART bootloader 模式时，禁止 flash 加密功能。
- ``DISABLE_DL_DECRYPT``，当运行在 UART bootloader 模式时，即使 :ref:`FLASH_CRYPT_CNT` 被设置为以正常操作使能 flash 透明解密，也禁止 flash 透明解密。 
- ``DISABLE_DL_CACHE``，当运行在 UART bootloader 模式时，禁止整个 MMU flash cache。

可以只烧写其中一部分 efuses，让其它 efuses 在第一次启动前写保护（将其值复原为 0），例如 ::

  espefuse.py --port PORT burn_efuse DISABLE_DL_DECRYPT
  espefuse.py --port PORT write_protect_efuse DISABLE_DL_ENCRYPT

(注意，通过一次写保护，这三个 efuses 都会被禁止。因此，有必要在写保护前设置所有的比特。)

**IMPORTANT**: 当前，对这些 efuses 写保护使其复原不是很有用，因为 ``esptool.py`` 不支持读/写加密的 flash。

**IMPORTANT**: 如果 ``DISABLE_DL_DECRYPT`` 被复原（0），这会使 flash 加密不起作用，因为进行物理访问的攻击者可以使用 UART bootloader 模式（使用自定义的桩代码）读出 flash 中的内容。

.. _setting-flash-crypt-config:

设置 FLASH_CRYPT_CONFIG
^^^^^^^^^^^^^^^^^^^^^^^^^^

efuse ``FLASH_CRYPT_CONFIG`` 用于判断 flash 加密密钥的比特数，具体细节请参考 :ref:`flash-encryption-algorithm`。

bootloader 在第一次启动时总是会将这个值设为最大值 `0xF`。

可以在第一次启动前对该 efuse 进行手工写，使其写保护，以选择不同的调整值。不过不推荐这样做。

强烈推荐当 ``FLASH_CRYPT_CONFIG`` 的值被设置为零时不要使其写保护。如果它被设置零，flash 加密密钥中没有比特会被调整，flash 加密算法与 AES ECB 模式相同。

技术细节
-----------------

下面的章节将介绍 flash 加密操作的一些参考信息。

.. _FLASH_CRYPT_CNT:

FLASH_CRYPT_CNT efuse
^^^^^^^^^^^^^^^^^^^^^

``FLASH_CRYPT_CNT`` 是一个 8 比特的字段，用于控制 flash 加密。Flash 加密的使能/禁止就是基于该 efuse 中被设置为 "1" 的比特的数量。

- 当偶数比特(0,2,4,6,8)被设置时：Flash 加密被禁止，所有加密的数据将不能被解密。

  - 如果在编译 bootloader 时选择了 "Enable flash encryption on boot"，则 bootloader 遇到的就是这种情形，它会立即对所找都的所有为加密数据进行加密，将 efuse 中的其它比特设置为 '1'，表示当前奇数比特被设置了。
  
    1. 第一次明码文本启动时，比特计数值是 0，bootloader 会将其修改为 1（值 0x1）。
    2. 在下一次明码文本更新后，比特计数值被手工设置 2（值 0x3）。重新加密后，bootloader 会将比特计数值改为 3（值 0x7）。
    3. 在下一次明码文本更新后，比特计数值被手工设置 4（值 0x0F）。重新加密后，bootloader 会将比特计数值改为 5（值 0x1F）。
    4. 在下一次明码文本更新后，比特计数值被手工设置 6（值 0x3F）。重新加密后，bootloader 会将比特计数值改为 7（值 0x7F）。

- 当奇数比特(1,3,5,7)被设置时：透明读取加密 flash 被使能。

- 当所有的 8 比特（efuse 值 0xFF）被设置后：透明地读加密 flash 被禁止，所有的加密数据将永久不可访问。bootloader 会检测到这个条件，然后挂起。如果要绕过这种状态来加载为授权的代码，必须使用安全启动或 :ref:`FLASH_CRYPT_CNT` 被写保护。

.. _flash-encryption-algorithm:

Flash 加密算法
^^^^^^^^^^^^^^^^^^^^^^^^^^

- AES-256 操作在数据的 16 字节块之上。flash 加密引擎以 32 字节块（两个 AES 块）加密/解密数据。

- AES 算法被用于逆向 falsh 加密，因此 flash 加密的加密操作就是 AES 的解密，解密操作就是 AES 加密。这样做是性能的原因，且不会改变算法的性能。

- 主 flash 加密密钥存储在 efuse (BLK2) 中，且默认具有写保护和软件读保护。

- 每 32 字节块（两个相连的 16 字节 AES 块）使用一个唯一的密钥进行加密。该密钥由 efuse 中的主 flash 加密密钥推断（与 flash 中该块的偏移量异或，这个偏移量又叫做 "密钥调整值"）而来。

- 还需要根据 efuse ``FLASH_CRYPT_CONFIG`` 的值进行特殊调整。这是一个 4 比特的 efuse，其中每个比特都需要与密钥的某个范围内的比特进行异或：。 

  - 比特 1 与密钥的比特 0-66 进行异或。
  - 比特 2 与密钥的比特 67-131 进行异或。
  - 比特 3 与密钥的比特 132-194 进行异或。
  - 比特 4 与密钥的比特 195-256 进行异或。

推荐将 ``FLASH_CRYPT_CONFIG`` 保持为默认值 `0xF`，这样所有的比特都是直接与块的偏移量进行异或的。具体细节请查看 :ref:`setting-flash-crypt-config`。

- 块偏移量的高 19 比特（比特 5 ~ 比特 23）被用于与主 flash 加密密钥进行异或。选择这个比特范围有两个原因： flash 的最大容量是 16 MB（24 个比特）；每个块是 32 字节的，因此最低 5 比特总是零。

- 19 比特的块偏移量与 flash 加密密钥之间存在一个特殊的映射，用于判断哪个比特是用于异或的。关于完整的映射关系，请查看 espsecure.py 源文件中的变量 ``_FLASH_ENCRYPTION_TWEAK_PATTERN``。

- 如果想要查看用 Python 语言写的完整的 flash 加密算法，请参考 espsecure.py 源文件中的函数 `_flash_encryption_operation()`。

