
#import <Cocoa/Cocoa.h>

#include "UnitTests.h"

int main(int argc, const char * argv[])
{
    if (argc >=2 ) {
        if (strcmp(argv[1], "runtests") == 0)
        {
            UnitTestsSetArgs(argc, argv);
            return RunUnitTests();
        }
    }

    return NSApplicationMain(argc, argv);
}
