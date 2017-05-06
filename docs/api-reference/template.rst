API 文档模板
==========================

.. note::

   *INSTRUCTIONS*

   1. Use this file as a template to document API.
   2. Change the file name to the name of the header file that represents documented API.
   3. Include respective files with descriptions from the API folder using ``..include::``

     * README.rst
     * example.rst

   4. Optionally provide description right in this file.
   5. Once done, remove all instructions like this one and any superfluous headers.

概述
--------

.. note::

   *INSTRUCTIONS*

   1. Provide overview where and how this API may be used. 
   2. Where applicable include code snippets to illustrate functionality of particular functions.
   3. To distinguish between sections, use the following `heading levels <http://www.sphinx-doc.org/en/stable/rest.html#sections>`_:

     * ``#`` with overline, for parts
     * ``*`` with overline, for chapters
     * ``=``, for sections
     * ``-``, for subsections
     * ``^``, for subsubsections
     * ``"``, for paragraphs

应用程序示例
-------------------

.. note::

   *INSTRUCTIONS*

   1. Prepare one or more practical examples to demonstrate functionality of this API.
   2. Each example should follow pattern of projects located in ``esp-idf/examples/`` folder.
   3. Place example in this folder complete with ``README.md`` file.
   4. Provide overview of demonstrated functionality in ``README.md``.
   5. With good overview reader should be able to understand what example does without opening the source code.
   6. Depending on complexity of example, break down description of code into parts and provide overview of functionality of each part.
   7. Include flow diagram and screenshots of application output if applicable.
   8. Finally add in this section synopsis of each example together with link to respective folder in ``esp-idf/examples/``.
  
API 参考手册
-------------

.. note::

   *INSTRUCTIONS*
 
   1. Specify the names of header files used to generate this reference. Each name should be linked to the source on `espressif/esp-idf <https://github.com/espressif/esp-idf>`_ repository.
   2. Provide list of API members divided into sections. 
   3. Use corresponding ``.. doxygen..`` directives, so member documentation is auto updated.

     * Data 结构体 -``.. doxygenstruct::`` together with ``:members:``
     * 宏 - ``.. doxygendefine::``
     * 类型定义 - ``.. doxygentypedef::``
     * 枚举 - ``.. doxygenenum::``
     * 函数 - ``.. doxygenfunction::``

     See `Breathe documentation <https://breathe.readthedocs.io/en/latest/directives.html>`_ for additional information. 

   4. Once done remove superfluous headers.
   5. When changes are committed and documentation is build, check how this section rendered. :doc:`Correct annotations <../contribute/documenting-code>` in respective header files, if required.

头文件
^^^^^^^^^^^^

  * `path/header-file.h`

Data 结构体
^^^^^^^^^^^^^^^

::

  .. doxygenstruct:: name_of_structure
     :members:

宏
^^^^^^

::

  .. doxygendefine:: name_of_macro

类型定义
^^^^^^^^^^^^^^^^

::

  .. doxygentypedef:: name_of_type

枚举
^^^^^^^^^^^^

::

  .. doxygenenum:: name_of_enumeration

函数
^^^^^^^^^

::

  .. doxygenfunction:: name_of_function


