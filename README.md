*cbuild*
===

cbuild is a simple build process for C/C++ projects that is controlled by a JSON project file.
See sample.json for a JSON with comments containing a sample of the available options for the
cbuild process.

Available tasks:
* clean - Clean the build directory
* build - Build the target executable
* build:<mode> - Build the specified target mode
* tasks - Print the build tasks list
* -f=<filename> - Use <filename> for the build project properties
* -verbose - Enable verbose output

The default project configuration filename is 'build.json' when not specified.
The default target compilation mode is 'release' when not specified.

cbuild requires ruby 2.6+ with the 'fileutils', 'find', and 'json' standard library packages.

Copyright (c) 2019 DarkMatter Software, all rights reserved.
