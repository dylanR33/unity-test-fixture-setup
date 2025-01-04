#include "OtherFile.h"

#include "unity.h"
#include "unity_fixture.h"


TEST_GROUP(OtherFile);


TEST_SETUP(OtherFile)
{
}

TEST_TEAR_DOWN(OtherFile)
{
}

TEST(OtherFile, OtherFunc_ShouldReturnOne)
{
    TEST_ASSERT_EQUAL(1, OtherFunc());
}

