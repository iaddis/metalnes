
#import <Cocoa/Cocoa.h>
#import <MetalKit/MetalKit.h>
#import "EventDelegate.h"



@interface MetalView : MTKView

@property (weak, nonatomic) IBOutlet id<EventDelegate> _Nullable eventDelegate;

- (void)registerDragDrop;

@end


