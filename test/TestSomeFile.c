#include "SomeFile.h"

#include "unity.h"
#include "unity_fixture.h"


TEST_GROUP(SomeFile);


TEST_SETUP(SomeFile)
{
}

TEST_TEAR_DOWN(SomeFile)
{
}

TEST(SomeFile, SomeFunc_ShouldReturnZero)
{
    TEST_ASSERT_EQUAL(0, SomeFunc());
    // TEST_ASSERT...
}

