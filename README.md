# *cbuild*

cbuild is a simple build process for C/C++ projects that is controlled by a JSON project file.
See sample.json for a JSON with comments containing a sample of the available options for the
cbuild process.

Available tasks:
* clean - Clean the build directory
* build - Build the target executable
* build:<mode> - Build the specified target mode
* analyze - Build the target with static analysis
* analyze:<mode> - Build the specified target mode with static analysis
* test - Execute the project unit test suites
* test[<test>(,<test>...)] - Execute the project unit test suites for the specified suites
* tasks - Print the build tasks list
* --filename=<filename> or -f=<filename> - Use <filename> for the build project properties
* --deps=<filename> or -d=<filename> - Use <filename> for the project dependencies
* --verbose or -v - Enable verbose output

The default project configuration filename is 'build.json' when not specified.
The default target compilation mode is 'release' when not specified.

cbuild requires ruby 3.4+ with the 'fileutils', 'find', and 'json' standard library packages.

Copyright (c) 2019-2026 DarkMatter Software, all rights reserved.
