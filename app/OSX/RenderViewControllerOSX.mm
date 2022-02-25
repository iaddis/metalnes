

#import <GLKit/GLKit.h>
#import <GameController/GameController.h>
#include <sys/stat.h>
#include <sys/types.h>
#import "RenderViewControllerOSX.h"

#include "render/context.h"
#include "render/metal/context_metal.h"
#include "keycode_osx.h"
#include "../external/imgui/imgui.h"
#include "../external/imgui/imgui_impl_osx.h"


#include "Application.h"
#include "imgui_support.h"



static bool GetApplicationSupportDir(std::string &user_dir)
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(
                                                            NSApplicationSupportDirectory,
                                                            NSUserDomainMask,
                                                            YES);
    for (int i=0; i < paths.count; i++)
    {
        NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
        NSString *resolvedPath = [paths objectAtIndex:i];
        NSString *dir = [resolvedPath stringByAppendingPathComponent:bundleId];
             
        NSError *error;
        if ([[NSFileManager defaultManager] createDirectoryAtPath:dir
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error])
        {
            user_dir = [dir UTF8String];
            return true;
        }
    }
    return false;
}

static int readGamePad(GCExtendedGamepad *pad)
{
    if (!pad) return 0;
    
    int bits = 0;
    if (pad.buttonA.pressed) bits |= (1 << 0);
    if (pad.buttonB.pressed) bits |= (1 << 0);
    if (pad.buttonX.pressed) bits |= (1 << 1);
    if (pad.buttonY.pressed) bits |= (1 << 1);

    if (pad.buttonOptions.pressed) bits |= (1 << 2);
    if (pad.buttonMenu.pressed) bits |= (1 << 3);
    if (pad.dpad.up.pressed) bits |= (1 << 4);
    if (pad.dpad.down.pressed) bits |= (1 << 5);
    if (pad.dpad.left.pressed) bits |= (1 << 6);
    if (pad.dpad.right.pressed) bits |= (1 << 7);
    return bits;
}

int readGamePad(int index)
{
    NSArray<GCController *> *controllers = [GCController controllers];
    if (index >= controllers.count)
        return 0;
    
    GCController *controller = [controllers objectAtIndex:index];
    if (!controller) {
        return 0;
    }
    return readGamePad(controller.extendedGamepad);
}



@implementation RenderViewControllerOSX
{
    std::string _resourceDir;
    std::string _userDir;

    render::ContextPtr _context;
    render::ContextPtr _gl_context;
    render::metal::IMetalContextPtr _metal_context;
    NSTrackingArea *_trackingArea;
    
}

- (void)flagsChanged:(NSEvent *)event
{
    ImGuiIO& io = ImGui::GetIO();
    unsigned int flags = [event modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask;

    bool oldKeyCtrl = io.KeyCtrl;
    bool oldKeyShift = io.KeyShift;
    bool oldKeyAlt = io.KeyAlt;
    bool oldKeySuper = io.KeySuper;
    io.KeyCtrl      = flags & NSEventModifierFlagControl;
    io.KeyShift     = flags & NSEventModifierFlagShift;
    io.KeyAlt       = flags & NSEventModifierFlagOption;
    io.KeySuper     = flags & NSEventModifierFlagCommand;

    // We must reset them as we will not receive any keyUp event if they where pressed with a modifier
    if ((oldKeyShift && !io.KeyShift) || (oldKeyCtrl && !io.KeyCtrl) || (oldKeyAlt && !io.KeyAlt) || (oldKeySuper && !io.KeySuper))
    {
     
        //memset(io.KeysDown,0, sizeof(io.KeysDown));// resetKeys();
    }

}

- (void)keyDown:(NSEvent *)event
{
    ImGui_ImplOSX_HandleEvent(event, self.view);

    ImGuiIO& io = ImGui::GetIO();
    io.KeyCtrl  = (event.modifierFlags & NSEventModifierFlagControl) != 0;
    io.KeyShift = (event.modifierFlags & NSEventModifierFlagShift) != 0;
    io.KeyAlt   = (event.modifierFlags & NSEventModifierFlagOption) != 0;
    io.KeySuper = (event.modifierFlags & NSEventModifierFlagCommand) != 0;

    KeyCode code = ConvertKeyCode_OSX(event.keyCode);
    if (code != 0 && code < sizeof(io.KeysDown))
    {
       io.KeysDown[code] = true;
    }

    NSString* str = event.characters;
    int len = (int)[str length];
    for (int i = 0; i < len; i++)
    {
        int c = [str characterAtIndex:i];
        if (!io.KeyCtrl && !(c >= 0xF700 && c <= 0xFFFF))
            io.AddInputCharacter((unsigned int)c);
    }
}

- (void)keyUp:(NSEvent *)event
{
    ImGuiIO& io = ImGui::GetIO();
    io.KeyCtrl  = (event.modifierFlags & NSEventModifierFlagControl) != 0;
    io.KeyShift = (event.modifierFlags & NSEventModifierFlagShift) != 0;
    io.KeyAlt   = (event.modifierFlags & NSEventModifierFlagOption) != 0;
    io.KeySuper = (event.modifierFlags & NSEventModifierFlagCommand) != 0;

    KeyCode code = ConvertKeyCode_OSX(event.keyCode);
    if (code != 0 && code < sizeof(io.KeysDown))
    {
       io.KeysDown[code] = false;
    }
}


-(void)onDragDrop:(NSArray * _Nonnull)files
{
//    [self.visualizer onDragDrop:files];
}


#define HANDLE_EVENT( __name) \
    - (void)__name:(NSEvent *)event {   \
        ImGui_ImplOSX_HandleEvent(event, self.view);    \
    }   


HANDLE_EVENT(mouseMoved)
HANDLE_EVENT(mouseDown)
HANDLE_EVENT(mouseUp)
HANDLE_EVENT(mouseDragged)
HANDLE_EVENT(rightMouseDown)
HANDLE_EVENT(rightMouseUp)
HANDLE_EVENT(rightMouseDragged)
HANDLE_EVENT(otherMouseDown)
HANDLE_EVENT(otherMouseUp)
HANDLE_EVENT(otherMouseDragged)
HANDLE_EVENT(scrollWheel)



- (void)viewDidLoad
{
    [super viewDidLoad];

    
    _resourceDir = [[[NSBundle mainBundle] resourcePath] UTF8String];
    GetApplicationSupportDir(_userDir);
    
    
    [self initMetal];
    
    
    _context->SetAssetDir(_resourceDir);

    std::vector<std::string> args;
    AppInit(_context, _resourceDir, _userDir, args);
    ImGui_ImplOSX_Init();
    
    auto &io = ImGui::GetIO();
    io.BackendFlags |= ImGuiBackendFlags_HasGamepad;
//    io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;
    
    // Add a tracking area in order to receive mouse events whenever the mouse is within the bounds of our view
    _trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                                 options:NSTrackingMouseMoved | NSTrackingInVisibleRect | NSTrackingActiveAlways
                                                   owner:self
                                                userInfo:nil];
    [self.view addTrackingArea:_trackingArea];

    [self.view becomeFirstResponder];
}


-(void)viewWillDisappear
{
    AppShutdown();
}

-(void)initMetal
{
    id <MTLDevice> device = MTLCreateSystemDefaultDevice();
    if(!device)
    {
        NSLog(@"Metal is not supported on this device");
        return;
    }
    MetalView *view = [[MetalView alloc] initWithFrame:self.view.frame device:device];;
    
    // configure view
//    view.depthStencilPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
    view.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    view.depthStencilPixelFormat = MTLPixelFormatInvalid;
    view.sampleCount = 1;
    view.framebufferOnly = YES;
    view.delegate = self;
    view.preferredFramesPerSecond = 60.0f;
    view.eventDelegate = self;
    [view registerDragDrop];

    self.view = view;
    

    _metal_context = render::metal::MetalCreateContext(device);
    _context = _metal_context;
    

    _metal_context->SetView( view );
//    _context->SetRenderTarget(nullptr);

}


/*
 ImGuiNavInput_Activate,      // activate / open / toggle / tweak value       // e.g. Cross  (PS4), A (Xbox), A (Switch), Space (Keyboard)
 ImGuiNavInput_Cancel,        // cancel / close / exit                        // e.g. Circle (PS4), B (Xbox), B (Switch), Escape (Keyboard)
 ImGuiNavInput_Input,         // text input / on-screen keyboard              // e.g. Triang.(PS4), Y (Xbox), X (Switch), Return (Keyboard)
 ImGuiNavInput_Menu,          // tap: toggle menu / hold: focus, move, resize // e.g. Square (PS4), X (Xbox), Y (Switch), Alt (Keyboard)
 ImGuiNavInput_DpadLeft,      // move / tweak / resize window (w/ PadMenu)    // e.g. D-pad Left/Right/Up/Down (Gamepads), Arrow keys (Keyboard)
 ImGuiNavInput_DpadRight,     //
 ImGuiNavInput_DpadUp,        //
 ImGuiNavInput_DpadDown,      //
 ImGuiNavInput_LStickLeft,    // scroll / move window (w/ PadMenu)            // e.g. Left Analog Stick Left/Right/Up/Down
 ImGuiNavInput_LStickRight,   //
 ImGuiNavInput_LStickUp,      //
 ImGuiNavInput_LStickDown,    //
 ImGuiNavInput_FocusPrev,     // next window (w/ PadMenu)                     // e.g. L1 or L2 (PS4), LB or LT (Xbox), L or ZL (Switch)
 ImGuiNavInput_FocusNext,     // prev window (w/ PadMenu)                     // e.g. R1 or R2 (PS4), RB or RT (Xbox), R or ZL (Switch)
 ImGuiNavInput_TweakSlow,     // slower tweaks                                // e.g. L1 or L2 (PS4), LB or LT (Xbox), L or ZL (Switch)
 ImGuiNavInput_TweakFast,     // faster tweaks                                // e.g. R1 or R2 (PS4), RB or RT (Xbox), R or ZL (Switch)

 
 */


-(void)updateControllers
{
    auto &io = ImGui::GetIO();
    
    NSArray<GCController *> *controllers = [GCController controllers];
    
    int i = 0;
    for (GCController *controller in controllers)
    {
        GCExtendedGamepad *pad =  controller.extendedGamepad;
        if (!pad) continue;
        io.NavInputs[ImGuiNavInput_Activate]  = pad.buttonA.value;
        io.NavInputs[ImGuiNavInput_Cancel]    = pad.buttonB.value;
        io.NavInputs[ImGuiNavInput_Input]     = pad.buttonY.value;
        io.NavInputs[ImGuiNavInput_Menu]      = pad.buttonX.value;
        
        io.NavInputs[ImGuiNavInput_DpadLeft]  = pad.dpad.left.value;
        io.NavInputs[ImGuiNavInput_DpadRight] = pad.dpad.right.value;
        io.NavInputs[ImGuiNavInput_DpadUp]    = pad.dpad.up.value;
        io.NavInputs[ImGuiNavInput_DpadDown]  = pad.dpad.down.value;

        io.NavInputs[ImGuiNavInput_LStickLeft]  = pad.leftThumbstick.left.value;
        io.NavInputs[ImGuiNavInput_LStickRight] = pad.leftThumbstick.right.value;
        io.NavInputs[ImGuiNavInput_LStickUp]    = pad.leftThumbstick.up.value;
        io.NavInputs[ImGuiNavInput_LStickDown]  = pad.leftThumbstick.down.value;

        io.NavInputs[ImGuiNavInput_FocusPrev]     = pad.leftShoulder.value;
        io.NavInputs[ImGuiNavInput_FocusNext]     = pad.rightShoulder.value;

        io.NavInputs[ImGuiNavInput_TweakSlow]     = pad.leftTrigger.value;
        io.NavInputs[ImGuiNavInput_TweakFast]     = pad.rightTrigger.value;

        i++;
    }
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    @autoreleasepool {
        

       
        [self updateControllers];
        

//        ImGuiSupport_NewFrame();
        ImGui_ImplOSX_NewFrame();
        _metal_context->SetView( view );
        _context->NextFrame();
        AppRender(_context);
        _context->Present();

//        if (AppShouldQuit())
//        {
//           NSWindow *window = view.window;
//           [window close];
//        }
    }
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    /// Respond to drawable size or orientation changes here
//    _context->SetDisplaySize(size.width, size.height);
}





@end
