.. _chirc-installing:

Installing, Building, and Running chirc
=======================================

The source code for chirc can be found in the following GitHub repository:

    https://github.com/uchicago-cs/chirc

To work on the assignments, all you need to do is clone this repository. However,
please note that your instructor may give you more specific instructions on how
to get the chirc code.

Software Requirements
---------------------



Building
--------

Once you have the :math:`\chi` code, you can build it simply by running
Make:

make

This will generate an executable called ``chirc`` that accepts two
parameters: ``-p`` and ``-o``. The former is used to specify the port on
which the server will listen, and the latter to specify the “operator
password”. You need to run the executable with at least the ``-o``
option, although this option will not be relevant until Project 1c. For
example:

./chirc -o foobar

The provided code, however, doesn’t do anything other that process the
command-line parameters. You should nonetheless verify that it builds
and runs correctly.

To modify the code, you should *only* add files to the ``src/``
directory. Take into account that, if you add additional ``.c`` files,
you will need to modify the ``src/Makefile`` file so they will be
included in the build (more specifically, you will need to include a new
object file in the ``OBJS`` variable).


Running
-------



