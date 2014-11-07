Node.js Portable Runtime
========================

Node.js Portable Runtime is a set of scripts that provides access to the
Node.js runtime on Windows without needing installation or adminstrator
privileges. It can also be used to carry Node.js projects on a thumbdrive
or an external hard disk.

Usage
=====

Simply double click on `bootstrap.bat`. Node.js and npm will be downloaded
and extracted into a directory called `.runtime`.

For web development usage, `grunt-cli` and `bower` are installed by default.
To customize this, see `bootstrap.bat`.

Global installs via `npm install -g` are also supported. These are installed
into the `.runtime` directory.

Pre-Requisites
==============

 * Windows PowerShell 2.0 or later (comes with Windows 7 or later)
 * An internet connection
