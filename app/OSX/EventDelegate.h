

#pragma once

#import <Cocoa/Cocoa.h>


@protocol EventDelegate <NSObject>

@required

- (void)keyDown:(NSEvent * _Nonnull)event;
- (void)keyUp:(NSEvent * _Nonnull)event;
-(void)onDragDrop:(NSArray * _Nonnull)files;

@end


