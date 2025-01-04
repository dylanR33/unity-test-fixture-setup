#include "unity_fixture.h"

static void RunAllTests(void)
{
    RUN_TEST_GROUP(SomeFile);
    RUN_TEST_GROUP(OtherFile);
}

int main(int argc, const char* argv[])
{
    return UnityMain(argc, argv, RunAllTests);
}
