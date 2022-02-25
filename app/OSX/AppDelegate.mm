
#import "AppDelegate.h"

#import <AVFoundation/AVFoundation.h>
#include <string>

#import <GLKit/GLKit.h>

#include "Core/Path.h"
#include <pthread.h>
#include "Application.h"

void SetCurrentThreadName(const char* threadName)
{
;
    [[NSThread currentThread] setName:    [NSString stringWithUTF8String:threadName] ]; // For Cocoa
    pthread_setname_np(threadName); // For GDB.
}


@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
//    AppShutdown();
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app {
    return NSTerminateNow;
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}


-(IBAction)saveState:(id)sender
{
    
}
-(IBAction)loadState:(id)sender
{
    
}



@end


