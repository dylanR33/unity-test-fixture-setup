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
# PATHS : source file folder
# PATHT : test source file folder
# BUILD_DIR : top level build directory

THIS_MAKEFILE_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

PATHU = $(THIS_MAKEFILE_DIR)Unity/src
PATHUFIX = $(THIS_MAKEFILE_DIR)Unity/extras/fixture/src

PATHTRUN = $(PATHT)/test_runners

PATHB = $(BUILD_DIR)/unity_build
PATHD = $(PATHB)/depends
PATHO = $(PATHB)/objs
PATHR = $(PATHB)/results

BUILD_PATHS = $(PATHB) $(PATHD) $(PATHO) $(PATHR)

SRCT = $(wildcard $(PATHT)/*.c)

COMPILE=gcc -c
LINK=gcc
DEPEND=gcc -MM -MG -MF
CFLAGS=-I. -I$(PATHU) -I$(PATHUFIX) -I$(PATHS) -DUNITY_FIXTURE_NO_EXTRAS

RESULTS = $(patsubst $(PATHT)/Test%.c,$(PATHR)/Test%.txt,$(SRCT) )

PASSED = `grep -s PASS $(PATHR)/*.txt`
FAIL = `grep -s FAIL $(PATHR)/*.txt`
IGNORE = `grep -s IGNORE $(PATHR)/*.txt`

SUMMARY = `grep -s -A 1 -E '\w+ Tests \w+ Failures \w+ Ignored' $(PATHR)/*.txt`

test: $(BUILD_PATHS) $(RESULTS)
	@echo "-----------------------\nIGNORES:\n-----------------------"
	@echo "$(IGNORE)"
	@echo "-----------------------\nFAILURES:\n----------------------"
	@echo "$(FAIL)"
	@echo "-----------------------\nPASSED:\n------------------------"
	@echo "$(PASSED)"
	@echo "----------------------------------------------------------"
	@echo "$(SUMMARY)"

$(PATHR)/%.txt: $(PATHB)/%.$(TARGET_EXTENSION)
	-./$< -v > $@ 2>&1

$(PATHB)/Test%.$(TARGET_EXTENSION): $(PATHO)/AllTests.o $(PATHO)/Test%Runner.o $(PATHO)/Test%.o $(PATHO)/%.o $(PATHO)/unity.o $(PATHO)/unity_fixture.o #$(PATHD)/Test%.d
	$(LINK) -o $@ $^

$(PATHO)/%.o:: $(PATHT)/%.c
	$(COMPILE) $(CFLAGS) $< -o $@

$(PATHO)/%.o:: $(PATHTRUN)/%.c
	$(COMPILE) $(CFLAGS) $< -o $@

$(PATHO)/%.o:: $(PATHS)/%.c
	$(COMPILE) $(CFLAGS) $< -o $@

$(PATHO)/%.o:: $(PATHU)/%.c $(PATHU)/%.h
	$(COMPILE) $(CFLAGS) $< -o $@

$(PATHO)/%.o:: $(PATHUFIX)/%.c $(PATHUFIX)/%.h
	$(COMPILE) $(CFLAGS) $< -o $@

$(PATHD)/%.d:: $(PATHT)/%.c
	$(DEPEND) $@ $<

$(PATHB):
	$(MKDIR) $(PATHB)

$(PATHD):
	$(MKDIR) $(PATHD)

$(PATHO):
	$(MKDIR) $(PATHO)

$(PATHR):
	$(MKDIR) $(PATHR)


.PRECIOUS: $(PATHB)/Test%.$(TARGET_EXTENSION)
.PRECIOUS: $(PATHD)/%.d
.PRECIOUS: $(PATHO)/%.o
.PRECIOUS: $(PATHR)/%.txt
