
#import <TargetConditionals.h>
#import <Carbon/Carbon.h>


#include "keycode_osx.h"



KeyCode ConvertKeyCode_OSX(int code)
{
    switch (code)
    {
        case kVK_ANSI_A                    :
            return KEYCODE_A;
        case kVK_ANSI_S                    :
            return KEYCODE_S;
        case kVK_ANSI_D                    :
            return KEYCODE_D;
        case kVK_ANSI_F                    :
            return KEYCODE_F;
        case kVK_ANSI_H                    :
            return KEYCODE_H;
        case kVK_ANSI_G                    :
            return KEYCODE_G;
        case kVK_ANSI_Z                    :
            return KEYCODE_Z;
        case kVK_ANSI_X                    :
            return KEYCODE_X;
        case kVK_ANSI_C                    :
            return KEYCODE_C;
        case kVK_ANSI_V                    :
            return KEYCODE_V;
        case kVK_ANSI_B                    :
            return KEYCODE_B;
        case kVK_ANSI_Q                    :
            return KEYCODE_Q;
        case kVK_ANSI_W                    :
            return KEYCODE_W;
        case kVK_ANSI_E                    :
            return KEYCODE_E;
        case kVK_ANSI_R                    :
            return KEYCODE_R;
        case kVK_ANSI_Y                    :
            return KEYCODE_Y;
        case kVK_ANSI_T                    :
            return KEYCODE_T;
        case kVK_ANSI_1                    :
            return KEYCODE_1;
        case kVK_ANSI_2                    :
            return KEYCODE_2;
        case kVK_ANSI_3                    :
            return KEYCODE_3;
        case kVK_ANSI_4                    :
            return KEYCODE_4;
        case kVK_ANSI_6                    :
            return KEYCODE_6;
        case kVK_ANSI_5                    :
            return KEYCODE_5;
        case kVK_ANSI_Equal                :
            return KEYCODE_EQUALS;
        case kVK_ANSI_9                    :
            return KEYCODE_9;
        case kVK_ANSI_7                    :
            return KEYCODE_7;
        case kVK_ANSI_Minus                :
            return KEYCODE_MINUS;
        case kVK_ANSI_8                    :
            return KEYCODE_8;
        case kVK_ANSI_0                    :
            return KEYCODE_0;
        case kVK_ANSI_RightBracket         :
            return KEYCODE_RIGHTBRACKET;
        case kVK_ANSI_O                    :
            return KEYCODE_O;
        case kVK_ANSI_U                    :
            return KEYCODE_U;
        case kVK_ANSI_LeftBracket          :
            return KEYCODE_LEFTBRACKET;
        case kVK_ANSI_I                    :
            return KEYCODE_I;
        case kVK_ANSI_P                    :
            return KEYCODE_P;
        case kVK_ANSI_L                    :
            return KEYCODE_L;
        case kVK_ANSI_J                    :
            return KEYCODE_J;
        case kVK_ANSI_Quote                :
            return KEYCODE_APOSTROPHE;
        case kVK_ANSI_K                    :
            return KEYCODE_K;
        case kVK_ANSI_Semicolon            :
            return KEYCODE_SEMICOLON;
        case kVK_ANSI_Backslash            :
            return KEYCODE_BACKSLASH;
        case kVK_ANSI_Comma                :
            return KEYCODE_COMMA;
        case kVK_ANSI_Slash                :
            return KEYCODE_SLASH;
        case kVK_ANSI_N                    :
            return KEYCODE_N;
        case kVK_ANSI_M                    :
            return KEYCODE_M;
        case kVK_ANSI_Period               :
            return KEYCODE_PERIOD;
        case kVK_ANSI_Grave                :
            return KEYCODE_GRAVE;
        case kVK_ANSI_KeypadDecimal        :
            return KEYCODE_KP_DECIMAL;
        case kVK_ANSI_KeypadMultiply       :
            return KEYCODE_KP_MULTIPLY;
        case kVK_ANSI_KeypadPlus           :
            return KEYCODE_KP_PLUS;
        case kVK_ANSI_KeypadClear          :
            return KEYCODE_KP_CLEAR;
        case kVK_ANSI_KeypadDivide         :
            return KEYCODE_KP_DIVIDE;
        case kVK_ANSI_KeypadEnter          :
            return KEYCODE_KP_ENTER;
        case kVK_ANSI_KeypadMinus          :
            return KEYCODE_KP_MINUS;
        case kVK_ANSI_KeypadEquals         :
            return KEYCODE_KP_EQUALS;
        case kVK_ANSI_Keypad0              :
            return KEYCODE_KP_0;
        case kVK_ANSI_Keypad1              :
            return KEYCODE_KP_1;
        case kVK_ANSI_Keypad2              :
            return KEYCODE_KP_2;
        case kVK_ANSI_Keypad3              :
            return KEYCODE_KP_3;
        case kVK_ANSI_Keypad4              :
            return KEYCODE_KP_4;
        case kVK_ANSI_Keypad5              :
            return KEYCODE_KP_5;
        case kVK_ANSI_Keypad6              :
            return KEYCODE_KP_6;
        case kVK_ANSI_Keypad7              :
            return KEYCODE_KP_7;
        case kVK_ANSI_Keypad8              :
            return KEYCODE_KP_8;
        case kVK_ANSI_Keypad9              :
            return KEYCODE_KP_9;
            
        case    kVK_Return                  :
            return KEYCODE_RETURN;
        case    kVK_Tab                     :
            return KEYCODE_TAB;
        case    kVK_Space                   :
            return KEYCODE_SPACE;
        case    kVK_Delete                  :
            return KEYCODE_BACKSPACE;
        case    kVK_Escape                  :
            return KEYCODE_ESCAPE;
        case    kVK_Command                 :
            return KEYCODE_LGUI;
        case    kVK_Shift                   :
            return KEYCODE_LSHIFT;
        case    kVK_CapsLock                :
            return KEYCODE_CAPSLOCK;
        case    kVK_Option                  :
            return KEYCODE_LALT;
        case    kVK_Control                 :
            return KEYCODE_LCTRL;
        case    kVK_RightShift              :
            return KEYCODE_RSHIFT;
        case    kVK_RightOption             :
            return KEYCODE_RALT;
        case    kVK_RightControl            :
            return KEYCODE_RCTRL;
        case    kVK_Function                :
            return KEYCODE_MODE;
        case    kVK_F17                     :
            return KEYCODE_F17;
        case    kVK_VolumeUp                :
            return KEYCODE_VOLUMEUP;
        case    kVK_VolumeDown              :
            return KEYCODE_VOLUMEDOWN;
        case    kVK_Mute                    :
            return KEYCODE_MUTE;
        case    kVK_F18                     :
            return KEYCODE_F18;
        case    kVK_F19                     :
            return KEYCODE_F19;
        case    kVK_F20                     :
            return KEYCODE_F20;
        case    kVK_F5                      :
            return KEYCODE_F5;
        case    kVK_F6                      :
            return KEYCODE_F6;
        case    kVK_F7                      :
            return KEYCODE_F7;
        case    kVK_F3                      :
            return KEYCODE_F3;
        case    kVK_F8                      :
            return KEYCODE_F8;
        case    kVK_F9                      :
            return KEYCODE_F9;
        case    kVK_F11                     :
            return KEYCODE_F11;
        case    kVK_F13                     :
            return KEYCODE_F13;
        case    kVK_F16                     :
            return KEYCODE_F16;
        case    kVK_F14                     :
            return KEYCODE_F14;
        case    kVK_F10                     :
            return KEYCODE_F10;
        case    kVK_F12                     :
            return KEYCODE_F12;
        case    kVK_F15                     :
            return KEYCODE_F15;
        case    kVK_Help                    :
            return KEYCODE_HELP;
        case    kVK_Home                    :
            return KEYCODE_HOME;
        case    kVK_PageUp                  :
            return KEYCODE_PAGEUP;
        case    kVK_ForwardDelete           :
            return KEYCODE_DELETE;
        case    kVK_F4                      :
            return KEYCODE_F4;
        case    kVK_End                     :
            return KEYCODE_END;
        case    kVK_F2                      :
            return KEYCODE_F2;
        case    kVK_PageDown                :
            return KEYCODE_PAGEDOWN;
        case    kVK_F1                      :
            return KEYCODE_F1;
        case    kVK_LeftArrow               :
            return KEYCODE_LEFT;
        case    kVK_RightArrow              :
            return KEYCODE_RIGHT;
        case    kVK_DownArrow               :
            return KEYCODE_DOWN;
        case    kVK_UpArrow                 :
            return KEYCODE_UP;
            
        default:
            return KEYCODE_UNKNOWN;
    }
    
}
