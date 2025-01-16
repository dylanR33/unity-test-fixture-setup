# unity-test-fixture-setup

## Incorperation Into Project
This repository serves as a drop in setup into a C project for the use of Unity's 
test fixture features. The idea here is to add this repository as a submodule into
your project. This repository is self-contained in that it contains Unity as a 
submodule itself so no other repositories need to be cloned externally.

Use the following command to add this repository as a git submodule of your project:
```
git submodule add https://github.com/dylanR33/unity-test-fixture-setup.git
```

Use the following command to clone this repository into your project:
```
git clone --recurse-submodules https://github.com/dylanR33/unity-test-fixture-setup.git
```


## Usage
Before continuing ensure you have read the sections "Necessary Variable Definitions" 
and "Expected Test Directory Structure" below.

Your project should contain a makefile of its own which needs to contain two things

1. Definitions for the necessary variables outlined in the section "Necessary Variable 
Definitions"

2. Inclusion of the makefile 'unity_test_fixture_setup.mk' found within this repository

For example:
```
UTFS_MODULE_DIRS = path_to/module1 path_to/module2 
UTFS_TEST_DIR = path_to/test_dir
UTFS_BUILD_DIR = path_to/build_dir

include path_to/unity-test-fixture-setup/unity_test_fixture_setup.mk
```

The makefile 'unity_test_fixture_setup.mk' contains the necessary rules to build your
source files, their corresponding test files, as well as Unity. The main rule you will 
use is 'test', to invoke this run the following from the directory containing your own 
makefile.
```
make test
```


## Necessary Variable Definitions
The following paths should be defined for the makefile to work correctly.

UTFS_MODULE_DIRS: directories containing the source code modules to be tested

UTFS_TEST_DIR: directory containing test code and the test_runner directory

UTFS_BUILD_DIR: your projects build directory


## Expected Test Directory Structure
The test directory defined by the variable UTFS_TEST_DIR should have the following
structure.

Within the first layer of the directory should be the individual test files defining 
each test group and its corresponding tests. Also within this first layer should be a 
directory called 'test_runner'. Within test_runner should be each TEST_GROUP_RUNNER 
definition for each of the respective test groups defined previously as well as a file 
containing the main() function which calls UnityMain(). An example of this setup can 
be found within the 'example' directory of this repository.

For example:

```
test/ 
     SomeFileTest.c 
     OtherFileTest.c 
     ...Test.c 
     test_runner/ 
                 SomeFileTestRunner.c 
                 OtherFileTestRunner.c 
                 ...TestRunner.c 
                 AllTests.c 
```


## Template and Example
The directory 'test_template' contains a basic structure of a test directory. Feel 
free to copy this folder to your project and rename it and its files as you find 
necessary, however DO NOT rename the test_runners directory (however the files within 
it can be renamed).

The directory 'example' contains a minimal example of how to incorperate this repository 
into a project. From within this directory simply run `make test` and observe the output.


## Suggested Test File Naming Convention
A convenient and easy to manage convention to name the files within your test directory
is the following.

Test Files: use the same name as the corresponding source file postfixed with 'Test'

Test Runner Files: use the same name as the corresponding source file postfixed with 'TestRunner'

