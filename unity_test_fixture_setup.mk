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

.PHONY: clean
.PHONY: test

# Paths that should be defined
# MODULE_DIRS : folders containing CUT's
# TEST_DIR : test source file folder.
# BUILD_DIR : top level build directory

THIS_MAKEFILE_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

PATHU = $(THIS_MAKEFILE_DIR)Unity/src
PATHUFIX = $(THIS_MAKEFILE_DIR)Unity/extras/fixture/src

PATHS = $(MODULE_DIRS)
PATHT = $(TEST_DIR)
PATHTRUN = $(PATHT)/test_runners
PATHB = $(BUILD_DIR)/unity_build
PATHD = $(PATHB)/depends
PATHO = $(PATHB)/objs
PATHR = $(PATHB)/result

BUILD_PATHS = $(PATHB) $(PATHD) $(PATHO) $(PATHR)

SRC = $(foreach dir, $(PATHS) $(PATHT) $(PATHTRUN), $(wildcard $(dir)/*.c))
OBJS = $(patsubst %.c, $(PATHO)/%.o, $(notdir $(SRC)))

INC_PATHS = $(addprefix -I, $(PATHS))

COMPILE=gcc -c
LINK=gcc
DEPEND=gcc -MM -MG -MF
CFLAGS=-I. -I$(PATHU) -I$(PATHUFIX) $(INC_PATHS) -DUNITY_FIXTURE_NO_EXTRAS

RESULT_TXT = $(PATHR)/AllTests.txt
RESULT_OUT = $(patsubst $(PATHR)/%.txt, $(PATHB)/%.$(TARGET_EXTENSION), $(RESULT_TXT))

PASSED = `grep -s PASS $(PATHR)/*.txt`
FAIL = `grep -s FAIL $(PATHR)/*.txt`
IGNORE = `grep -s IGNORE $(PATHR)/*.txt`

SUMMARY = `grep -s -A 1 -E '\w+ Tests \w+ Failures \w+ Ignored' $(PATHR)/*.txt`

vpath %.c $(PATHT) $(PATHTRUN) $(PATHS) $(PATHU) $(PATHUFIX)

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

$(RESULT_OUT): $(OBJS) $(PATHO)/unity.o $(PATHO)/unity_fixture.o #$(PATHD)/Test%.d
	$(LINK) -o $@ $^

$(PATHO)/%.o: %.c
	$(COMPILE) $(CFLAGS) $< -o $@


$(PATHD)/%.d: $(PATHT)/%.c
	$(DEPEND) $@ $<

$(PATHB):
	$(MKDIR) $(PATHB)

$(PATHD):
	$(MKDIR) $(PATHD)

$(PATHO):
	$(MKDIR) $(PATHO)

$(PATHR):
	$(MKDIR) $(PATHR)

