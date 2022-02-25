// dear imgui: Platform Binding for OSX / Cocoa
// This needs to be used along with a Renderer (e.g. OpenGL2, OpenGL3, Vulkan, Metal..)
// [ALPHA] Early bindings, not well tested. If you want a portable application, prefer using the GLFW or SDL platform bindings on Mac.

// Implemented features:
//  [X] Platform: Mouse cursor shape and visibility. Disable with 'io.ConfigFlags |= ImGuiConfigFlags_NoMouseCursorChange'.
//  [X] Platform: OSX clipboard is supported within core Dear ImGui (no specific code in this back-end).
// Issues:
//  [ ] Platform: Keys are all generally very broken. Best using [event keycode] and not [event characters]..

#include "imgui.h"
#include "imgui_impl_osx.h"
#import <Cocoa/Cocoa.h>

// CHANGELOG
// (minor and older changes stripped away, please see git history for details)
//  2019-05-28: Inputs: Added mouse cursor shape and visibility support.
//  2019-05-18: Misc: Removed clipboard handlers as they are now supported by core imgui.cpp.
//  2019-05-11: Inputs: Don't filter character values before calling AddInputCharacter() apart from 0xF700..0xFFFF range.
//  2018-11-30: Misc: Setting up io.BackendPlatformName so it can be displayed in the About Window.
//  2018-07-07: Initial version.

// Data
static NSCursor*      g_MouseCursors[ImGuiMouseCursor_COUNT] = { 0 };
static bool           g_MouseCursorHidden = false;

// Undocumented methods for creating cursors.
@interface NSCursor()
+ (id)_windowResizeNorthWestSouthEastCursor;
+ (id)_windowResizeNorthEastSouthWestCursor;
+ (id)_windowResizeNorthSouthCursor;
+ (id)_windowResizeEastWestCursor;
@end

// Functions
bool ImGui_ImplOSX_Init()
{
    ImGuiIO& io = ImGui::GetIO();
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;     // Enable Keyboard Controls

    // Setup back-end capabilities flags
    io.BackendFlags |= ImGuiBackendFlags_HasMouseCursors;         // We can honor GetMouseCursor() values (optional)
    //io.BackendFlags |= ImGuiBackendFlags_HasSetMousePos;          // We can honor io.WantSetMousePos requests (optional, rarely used)
    //io.BackendFlags |= ImGuiBackendFlags_PlatformHasViewports;    // We can create multi-viewports on the Platform side (optional)
    //io.BackendFlags |= ImGuiBackendFlags_HasMouseHoveredViewport; // We can set io.MouseHoveredViewport correctly (optional, not easy)
    io.BackendPlatformName = "imgui_impl_osx";

  
    // Load cursors. Some of them are undocumented.
    g_MouseCursorHidden = false;
    g_MouseCursors[ImGuiMouseCursor_Arrow] = [NSCursor arrowCursor];
    g_MouseCursors[ImGuiMouseCursor_TextInput] = [NSCursor IBeamCursor];
    g_MouseCursors[ImGuiMouseCursor_ResizeAll] = [NSCursor closedHandCursor];
    g_MouseCursors[ImGuiMouseCursor_Hand] = [NSCursor pointingHandCursor];
    g_MouseCursors[ImGuiMouseCursor_ResizeNS] = [NSCursor respondsToSelector:@selector(_windowResizeNorthSouthCursor)] ? [NSCursor _windowResizeNorthSouthCursor] : [NSCursor resizeUpDownCursor];
    g_MouseCursors[ImGuiMouseCursor_ResizeEW] = [NSCursor respondsToSelector:@selector(_windowResizeEastWestCursor)] ? [NSCursor _windowResizeEastWestCursor] : [NSCursor resizeLeftRightCursor];
    g_MouseCursors[ImGuiMouseCursor_ResizeNESW] = [NSCursor respondsToSelector:@selector(_windowResizeNorthEastSouthWestCursor)] ? [NSCursor _windowResizeNorthEastSouthWestCursor] : [NSCursor closedHandCursor];
    g_MouseCursors[ImGuiMouseCursor_ResizeNWSE] = [NSCursor respondsToSelector:@selector(_windowResizeNorthWestSouthEastCursor)] ? [NSCursor _windowResizeNorthWestSouthEastCursor] : [NSCursor closedHandCursor];

    // We don't set the io.SetClipboardTextFn/io.GetClipboardTextFn handlers,
    // because imgui.cpp has a default for them that works with OSX.

    return true;
}

void ImGui_ImplOSX_Shutdown()
{
}

static void ImGui_ImplOSX_UpdateMouseCursor()
{
    ImGuiIO& io = ImGui::GetIO();
    if (io.ConfigFlags & ImGuiConfigFlags_NoMouseCursorChange)
        return;

    ImGuiMouseCursor imgui_cursor = ImGui::GetMouseCursor();
    if (io.MouseDrawCursor || imgui_cursor == ImGuiMouseCursor_None)
    {
        // Hide OS mouse cursor if imgui is drawing it or if it wants no cursor
        if (!g_MouseCursorHidden)
        {
            g_MouseCursorHidden = true;
            [NSCursor hide];
        }
    }
    else
    {
        // Show OS mouse cursor
        [g_MouseCursors[g_MouseCursors[imgui_cursor] ? imgui_cursor : ImGuiMouseCursor_Arrow] set];
        if (g_MouseCursorHidden)
        {
            g_MouseCursorHidden = false;
            [NSCursor unhide];
        }
    }
}

void ImGui_ImplOSX_NewFrame()
{
    ImGui_ImplOSX_UpdateMouseCursor();
}

static void UpdateMousePos(NSEvent* event, NSView* view)
{
    ImGuiIO& io = ImGui::GetIO();
    NSPoint mousePoint = event.locationInWindow;
    mousePoint = [view convertPoint:mousePoint fromView:nil];
    mousePoint = NSMakePoint(mousePoint.x, view.bounds.size.height - mousePoint.y);
    io.MousePos = ImVec2(mousePoint.x, mousePoint.y);

}

bool ImGui_ImplOSX_HandleEvent(NSEvent* event, NSView* view)
{
    ImGuiIO& io = ImGui::GetIO();

    if (event.type == NSEventTypeLeftMouseDown || event.type == NSEventTypeRightMouseDown || event.type == NSEventTypeOtherMouseDown)
    {
        int button = (int)[event buttonNumber];
        if (button >= 0 && button < IM_ARRAYSIZE(io.MouseDown))
            io.MouseDown[button] = true;
        UpdateMousePos(event, view);
        return io.WantCaptureMouse;
    }

    if (event.type == NSEventTypeLeftMouseUp || event.type == NSEventTypeRightMouseUp || event.type == NSEventTypeOtherMouseUp)
    {
        int button = (int)[event buttonNumber];
        if (button >= 0 && button < IM_ARRAYSIZE(io.MouseDown))
            io.MouseDown[button] = false;
        UpdateMousePos(event, view);
        return io.WantCaptureMouse;
    }

    if (event.type == NSEventTypeMouseMoved || event.type == NSEventTypeLeftMouseDragged)
    {
        UpdateMousePos(event, view);
    }

    if (event.type == NSEventTypeScrollWheel)
    {
        double wheel_dx = 0.0;
        double wheel_dy = 0.0;

        #if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
        {
            wheel_dx = [event scrollingDeltaX];
            wheel_dy = [event scrollingDeltaY];
            if ([event hasPreciseScrollingDeltas])
            {
                wheel_dx *= 0.1;
                wheel_dy *= 0.1;
            }
        }
        else
        #endif /*MAC_OS_X_VERSION_MAX_ALLOWED*/
        {
            wheel_dx = [event deltaX];
            wheel_dy = [event deltaY];
        }

        if (fabs(wheel_dx) > 0.0)
            io.MouseWheelH += wheel_dx * 0.1f;
        if (fabs(wheel_dy) > 0.0)
            io.MouseWheel += wheel_dy * 0.1f;
        return io.WantCaptureMouse;
    }

    /*
    // FIXME: All the key handling is wrong and broken. Refer to GLFW's cocoa_init.mm and cocoa_window.mm.
    if (event.type == NSEventTypeKeyDown)
    {
        NSString* str = [event characters];
        int len = (int)[str length];
        for (int i = 0; i < len; i++)
        {
            int c = [str characterAtIndex:i];
            if (!io.KeyCtrl && !(c >= 0xF700 && c <= 0xFFFF))
                io.AddInputCharacter((unsigned int)c);

            // We must reset in case we're pressing a sequence of special keys while keeping the command pressed
            int key = mapCharacterToKey(c);
                	if (key != -1 && key < 256 && !io.KeyCtrl)
                resetKeys();
            if (key != -1)
                io.KeysDown[key] = true;
        }
        return io.WantCaptureKeyboard;
    }

    if (event.type == NSEventTypeKeyUp)
    {
        NSString* str = [event characters];
        int len = (int)[str length];
        for (int i = 0; i < len; i++)
        {
            int c = [str characterAtIndex:i];
            int key = mapCharacterToKey(c);
            if (key != -1)
                io.KeysDown[key] = false;
        }
        return io.WantCaptureKeyboard;
    }

    if (event.type == NSEventTypeFlagsChanged)
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
            resetKeys();
        return io.WantCaptureKeyboard;
    }
     */

    return false;
}
