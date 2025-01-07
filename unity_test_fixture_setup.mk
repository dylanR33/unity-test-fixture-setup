ifeq ($(OS),Windows_NT)
  ifeq ($(shell uname -s),) # not in a bash-like shell
	UTFS_CLEANUP = del /F /Q
	UTFS_MKDIR = mkdir
  else # in a bash-like shell, like msys
	UTFS_CLEANUP = rm -f
	UTFS_MKDIR = mkdir -p
  endif
	UTFS_TARGET_EXTENSION=exe
else
	UTFS_CLEANUP = rm -f
	UTFS_MKDIR = mkdir -p
	UTFS_TARGET_EXTENSION=out
endif

# Paths that should be defined
# UTFS_MODULE_DIRS : directory containing CUT's
# UTFS_TEST_DIR : test source file directory
# UTFS_BUILD_DIR : top level build directory
#
# Ensure these are defined, else exit
ifndef UTFS_MODULE_DIRS
  $(error UTFS_MODULE_DIRS not defined)
endif
ifndef UTFS_TEST_DIR
  $(error UTFS_TEST_DIR not defined)
endif
ifndef UTFS_BUILD_DIR
  $(error UTFS_BUILD_DIR not defined)
endif

# Directory where this makefile is located
UTFS_THIS_MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Unity paths
UTFS_PATHU = $(UTFS_THIS_MAKEFILE_DIR)Unity/src
UTFS_PATHUFIX = $(UTFS_THIS_MAKEFILE_DIR)Unity/extras/fixture/src

# Source code paths
UTFS_PATHS = $(UTFS_MODULE_DIRS)
UTFS_PATHT = $(UTFS_TEST_DIR)
UTFS_PATHTRUN = $(UTFS_PATHT)/test_runners

# Build paths
UTFS_PATHB = $(UTFS_BUILD_DIR)/unity_build
UTFS_PATHO = $(UTFS_PATHB)/objs
UTFS_PATHO_MODULES = $(addprefix $(UTFS_PATHO)/,$(UTFS_PATHS) $(UTFS_PATHT) $(UTFS_PATHTRUN) unity)
UTFS_PATHR = $(UTFS_PATHB)/result
UTFS_BUILD_PATHS = $(UTFS_PATHB) $(UTFS_PATHO) $(UTFS_PATHO_MODULES) $(UTFS_PATHR)

# User source files and corresponding object files and dependancy files
UTFS_USR_SRCS = $(foreach utfs_dir, $(UTFS_PATHS) $(UTFS_PATHT) $(UTFS_PATHTRUN), $(wildcard $(utfs_dir)/*.c))
UTFS_USR_OBJS = $(patsubst %.c, $(UTFS_PATHO)/%.o, $(UTFS_USR_SRCS))
UTFS_USR_DEPS = $(patsubst %.c, $(UTFS_PATHO)/%.d, $(UTFS_USR_SRCS))

# Compilation variables
UTFS_CC = gcc
UTFS_USR_INC_PATHS = $(addprefix -I, $(UTFS_PATHS))
UTFS_CPPFLAGS = -MMD -MP -I$(UTFS_PATHU) -I$(UTFS_PATHUFIX) $(UTFS_USR_INC_PATHS) -DUNITY_FIXTURE_NO_EXTRAS

# Test results
UTFS_RESULT_TXT = $(UTFS_PATHR)/AllTests.txt
UTFS_RESULT_OUT = $(patsubst $(UTFS_PATHR)/%.txt, $(UTFS_PATHB)/%.$(UTFS_TARGET_EXTENSION), $(UTFS_RESULT_TXT))

# Results parsing
UTFS_PASSED = `grep -s PASS $(UTFS_RESULT_TXT)`
UTFS_FAIL = `grep -s FAIL $(UTFS_RESULT_TXT)`
UTFS_IGNORE = `grep -s IGNORE $(UTFS_RESULT_TXT)`
UTFS_SUMMARY = `grep -s -A 1 -E '\w+ Tests \w+ Failures \w+ Ignored' $(UTFS_RESULT_TXT)`

test: $(UTFS_RESULT_TXT) | $(UTFS_BUILD_PATHS) 
	@echo "-----------------------IGNORES-----------------------"
	@echo "$(UTFS_IGNORE)"
	@echo "-----------------------FAILURES----------------------"
	@echo "$(UTFS_FAIL)"
	@echo "-----------------------PASSED------------------------"
	@echo "$(UTFS_PASSED)"
	@echo "-----------------------------------------------------"
	@echo "$(UTFS_SUMMARY)"

$(UTFS_RESULT_TXT): $(UTFS_RESULT_OUT) | $(UTFS_BUILD_PATHS)
	-./$< -v > $@ 2>&1

$(UTFS_RESULT_OUT): $(UTFS_USR_OBJS) $(UTFS_PATHO)/unity/unity.o $(UTFS_PATHO)/unity/unity_fixture.o | $(UTFS_BUILD_PATHS)
	$(UTFS_CC) -o $@ $^

$(UTFS_PATHO)/%.o: %.c | $(UTFS_BUILD_PATHS)
	$(UTFS_CC) $(UTFS_CPPFLAGS) -c $< -o $@

$(UTFS_PATHO)/unity/unity.o: $(UTFS_PATHU)/unity.c | $(UTFS_BUILD_PATHS)
	$(UTFS_CC) $(UTFS_CPPFLAGS) -c $< -o $@

$(UTFS_PATHO)/unity/unity_fixture.o: $(UTFS_PATHUFIX)/unity_fixture.c | $(UTFS_BUILD_PATHS)
	$(UTFS_CC) $(UTFS_CPPFLAGS) -c $< -o $@

$(UTFS_BUILD_PATHS):
	$(UTFS_MKDIR) $@

-include $(UTFS_USR_DEPS)

.PHONY: test

