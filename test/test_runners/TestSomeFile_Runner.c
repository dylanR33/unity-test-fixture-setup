#include "unity.h"
#include "unity_fixture.h"

TEST_GROUP_RUNNER(SomeFile)
{
    RUN_TEST_CASE(SomeFile, SomeFunc_ShouldReturnZero);
}
