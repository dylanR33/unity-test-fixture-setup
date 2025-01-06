ifeq ($(OS),Windows_NT)
  ifeq ($(shell uname -s),) # not in a bash-like shell
	CLEANUP = del /F /Q
	MKDIR = mkdir
  else # in a bash-like shell, like msys
	CLEANUP = rm -f
	MKDIR = mkdir -p
  endif
	TARGET_EXTENSION=exe
else
	CLEANUP = rm -f
	MKDIR = mkdir -p
	TARGET_EXTENSION=out
endif

# Paths that should be defined
# MODULE_DIRS : directory containing CUT's
# TEST_DIR : test source file directory
# BUILD_DIR : top level build directory
#
# Ensure these are defined, else exit
ifndef MODULE_DIRS
  $(error MODULE_DIRS not defined)
endif
ifndef TEST_DIR
  $(error TEST_DIR not defined)
endif
ifndef BUILD_DIR
  $(error BUILD_DIR not defined)
endif

# Directory where this makefile is located
THIS_MAKEFILE_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Unity paths
PATHU = $(THIS_MAKEFILE_DIR)Unity/src
PATHUFIX = $(THIS_MAKEFILE_DIR)Unity/extras/fixture/src

# Source code paths
PATHS = $(MODULE_DIRS)
PATHT = $(TEST_DIR)
PATHTRUN = $(PATHT)/test_runners

# User source files and corresponding object files
USR_SRC = $(foreach dir, $(PATHS) $(PATHT) $(PATHTRUN), $(wildcard $(dir)/*.c))
USR_OBJS = $(patsubst %.c, $(PATHO)/%.o, $(USR_SRC))

# Build paths
PATHB = $(BUILD_DIR)/unity_build
PATHD = $(PATHB)/depends
PATHO = $(PATHB)/objs
PATHO_MODULES = $(addprefix $(PATHO)/,$(PATHS) $(PATHT) $(PATHTRUN) unity)
PATHR = $(PATHB)/result
BUILD_PATHS = $(PATHB) $(PATHD) $(PATHO) $(PATHO_MODULES) $(PATHR)

# Compilation variables
COMPILE=gcc -c
LINK=gcc
DEPEND=gcc -MM -MG -MF
INC_PATHS = $(addprefix -I, $(PATHS))
CFLAGS=-I$(PATHU) -I$(PATHUFIX) $(INC_PATHS) -DUNITY_FIXTURE_NO_EXTRAS

# Test results
RESULT_TXT = $(PATHR)/AllTests.txt
RESULT_OUT = $(patsubst $(PATHR)/%.txt, $(PATHB)/%.$(TARGET_EXTENSION), $(RESULT_TXT))

# Results parsing
PASSED = `grep -s PASS $(RESULT_TXT)`
FAIL = `grep -s FAIL $(RESULT_TXT)`
IGNORE = `grep -s IGNORE $(RESULT_TXT)`
SUMMARY = `grep -s -A 1 -E '\w+ Tests \w+ Failures \w+ Ignored' $(RESULT_TXT)`

test: $(BUILD_PATHS) $(RESULT_TXT)
	@echo "-----------------------\nIGNORES:\n-----------------------"
	@echo "$(IGNORE)"
	@echo "-----------------------\nFAILURES:\n----------------------"
	@echo "$(FAIL)"
	@echo "-----------------------\nPASSED:\n------------------------"
	@echo "$(PASSED)"
	@echo "----------------------------------------------------------"
	@echo "$(SUMMARY)"

$(RESULT_TXT): $(RESULT_OUT)
	-./$< -v > $@ 2>&1

$(RESULT_OUT): $(USR_OBJS) $(PATHO)/unity/unity.o $(PATHO)/unity/unity_fixture.o #$(PATHD)/Test%.d
	$(LINK) -o $@ $^

$(PATHO)/%.o: %.c
	$(COMPILE) $(CFLAGS) $< -o $@

$(PATHO)/unity/unity.o: $(PATHU)/unity.c
	$(COMPILE) $(CFLAGS) $< -o $@

$(PATHO)/unity/unity_fixture.o: $(PATHUFIX)/unity_fixture.c
	$(COMPILE) $(CFLAGS) $< -o $@

$(PATHD)/%.d: $(PATHT)/%.c
	$(DEPEND) $@ $<

$(BUILD_PATHS):
	$(MKDIR) $@


.PHONY: test
