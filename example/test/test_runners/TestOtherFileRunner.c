#include "unity.h"
#include "unity_fixture.h"

TEST_GROUP_RUNNER(OtherFile)
{
    RUN_TEST_CASE(OtherFile, OtherFunc_ShouldReturnOne);
}
