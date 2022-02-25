
#import "MetalView.h"

@implementation MetalView

-(BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(NSEvent *)event
{
    [self.eventDelegate keyDown:event];
}

- (void)keyUp:(NSEvent *)event
{    
    [self.eventDelegate keyUp:event];
}


- (void)registerDragDrop
{
    [self registerForDraggedTypes:[NSArray arrayWithObjects:
                                   NSPasteboardTypeFileURL, nil]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
    NSPasteboard *pboard = [sender draggingPasteboard];

    if ( [[pboard types] containsObject:NSPasteboardTypeFileURL] ) {
        if (sourceDragMask & NSDragOperationLink) {
            return NSDragOperationLink;
        } else if (sourceDragMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];

    if ( [[pboard types] containsObject:NSPasteboardTypeFileURL] ) {
        NSArray *files = [pboard propertyListForType:NSPasteboardTypeFileURL];
        [self.eventDelegate onDragDrop:files];
    }
    return YES;
}

@end
