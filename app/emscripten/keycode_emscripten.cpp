
#include <emscripten.h>
#include <emscripten/key_codes.h>
#include "keycode_emscripten.h"

KeyCode ConvertKeyCode_Emscripten(const char *keyCode)
{
    int dom_pk_code = emscripten_compute_dom_pk_code(keyCode);
    return ConvertKeyCode_Emscripten(dom_pk_code);
}

KeyCode ConvertKeyCode_Emscripten(int code)
{
    switch (code)
    {
        case DOM_PK_A                    :
            return KEYCODE_A;
        case DOM_PK_S                    :
            return KEYCODE_S;
        case DOM_PK_D                    :
            return KEYCODE_D;
        case DOM_PK_F                    :
            return KEYCODE_F;
        case DOM_PK_H                    :
            return KEYCODE_H;
        case DOM_PK_G                    :
            return KEYCODE_G;
        case DOM_PK_Z                    :
            return KEYCODE_Z;
        case DOM_PK_X                    :
            return KEYCODE_X;
        case DOM_PK_C                    :
            return KEYCODE_C;
        case DOM_PK_V                    :
            return KEYCODE_V;
        case DOM_PK_B                    :
            return KEYCODE_B;
        case DOM_PK_Q                    :
            return KEYCODE_Q;
        case DOM_PK_W                    :
            return KEYCODE_W;
        case DOM_PK_E                    :
            return KEYCODE_E;
        case DOM_PK_R                    :
            return KEYCODE_R;
        case DOM_PK_Y                    :
            return KEYCODE_Y;
        case DOM_PK_T                    :
            return KEYCODE_T;
        case DOM_PK_1                    :
            return KEYCODE_1;
        case DOM_PK_2                    :
            return KEYCODE_2;
        case DOM_PK_3                    :
            return KEYCODE_3;
        case DOM_PK_4                    :
            return KEYCODE_4;
        case DOM_PK_6                    :
            return KEYCODE_6;
        case DOM_PK_5                    :
            return KEYCODE_5;
        case DOM_PK_EQUAL                :
            return KEYCODE_EQUALS;
        case DOM_PK_9                    :
            return KEYCODE_9;
        case DOM_PK_7                    :
            return KEYCODE_7;
        case DOM_PK_MINUS                :
            return KEYCODE_MINUS;
        case DOM_PK_8                    :
            return KEYCODE_8;
        case DOM_PK_0                    :
            return KEYCODE_0;
        case DOM_PK_BRACKET_RIGHT         :
            return KEYCODE_RIGHTBRACKET;
        case DOM_PK_O                    :
            return KEYCODE_O;
        case DOM_PK_U                    :
            return KEYCODE_U;
        case DOM_PK_BRACKET_LEFT          :
            return KEYCODE_LEFTBRACKET;
        case DOM_PK_I                    :
            return KEYCODE_I;
        case DOM_PK_P                    :
            return KEYCODE_P;
        case DOM_PK_L                    :
            return KEYCODE_L;
        case DOM_PK_J                    :
            return KEYCODE_J;
        case DOM_PK_QUOTE                :
            return KEYCODE_APOSTROPHE;
        case DOM_PK_K                    :
            return KEYCODE_K;
        case DOM_PK_SEMICOLON            :
            return KEYCODE_SEMICOLON;
        case DOM_PK_BACKSLASH            :
            return KEYCODE_BACKSLASH;
        case DOM_PK_COMMA                :
            return KEYCODE_COMMA;
        case DOM_PK_SLASH                :
            return KEYCODE_SLASH;
        case DOM_PK_N                    :
            return KEYCODE_N;
        case DOM_PK_M                    :
            return KEYCODE_M;
        case DOM_PK_PERIOD              :
            return KEYCODE_PERIOD;
        case DOM_PK_BACKQUOTE                :
            return KEYCODE_GRAVE;
        case DOM_PK_NUMPAD_DECIMAL        :
            return KEYCODE_KP_DECIMAL;
        case DOM_PK_NUMPAD_MULTIPLY       :
            return KEYCODE_KP_MULTIPLY;
        case DOM_PK_NUMPAD_ADD           :
            return KEYCODE_KP_PLUS;
//        case DOM_PK_KeypadClear          :
//            return KEYCODE_KP_CLEAR;
//        case DOM_PK_KeypadDivide         :
//            return KEYCODE_KP_DIVIDE;
        case DOM_PK_NUMPAD_ENTER          :
            return KEYCODE_KP_ENTER;
        case DOM_PK_NUMPAD_SUBTRACT          :
            return KEYCODE_KP_MINUS;
        case DOM_PK_NUMPAD_EQUAL         :
            return KEYCODE_KP_EQUALS;
        case DOM_PK_NUMPAD_0              :
            return KEYCODE_KP_0;
        case DOM_PK_NUMPAD_1              :
            return KEYCODE_KP_1;
        case DOM_PK_NUMPAD_2              :
            return KEYCODE_KP_2;
        case DOM_PK_NUMPAD_3              :
            return KEYCODE_KP_3;
        case DOM_PK_NUMPAD_4              :
            return KEYCODE_KP_4;
        case DOM_PK_NUMPAD_5              :
            return KEYCODE_KP_5;
        case DOM_PK_NUMPAD_6              :
            return KEYCODE_KP_6;
        case DOM_PK_NUMPAD_7              :
            return KEYCODE_KP_7;
        case DOM_PK_NUMPAD_8              :
            return KEYCODE_KP_8;
        case DOM_PK_NUMPAD_9              :
            return KEYCODE_KP_9;
            
        case    DOM_PK_ENTER                  :
            return KEYCODE_RETURN;
        case    DOM_PK_TAB                     :
            return KEYCODE_TAB;
        case    DOM_PK_SPACE                   :
            return KEYCODE_SPACE;
        case    DOM_PK_BACKSPACE                 :
            return KEYCODE_BACKSPACE;
        case    DOM_PK_ESCAPE                  :
            return KEYCODE_ESCAPE;
        case    DOM_PK_META_LEFT                 :
            return KEYCODE_LGUI;
        case    DOM_PK_SHIFT_LEFT                  :
            return KEYCODE_LSHIFT;
        case    DOM_PK_CAPS_LOCK                :
            return KEYCODE_CAPSLOCK;
        case    DOM_PK_ALT_LEFT                  :
            return KEYCODE_LALT;
        case    DOM_PK_CONTROL_LEFT                 :
            return KEYCODE_LCTRL;
        case    DOM_PK_SHIFT_RIGHT              :
            return KEYCODE_RSHIFT;
        case    DOM_PK_ALT_RIGHT             :
            return KEYCODE_RALT;
        case    DOM_PK_CONTROL_RIGHT            :
            return KEYCODE_RCTRL;
//        case    DOM_PK_Function                :
//            return KEYCODE_MODE;
        case    DOM_PK_F17                     :
            return KEYCODE_F17;
        case    DOM_PK_AUDIO_VOLUME_UP                :
            return KEYCODE_VOLUMEUP;
        case    DOM_PK_AUDIO_VOLUME_DOWN              :
            return KEYCODE_VOLUMEDOWN;
//        case    DOM_PK_VOLUMEMUTE                    :
//            return KEYCODE_MUTE;
        case    DOM_PK_F18                     :
            return KEYCODE_F18;
        case    DOM_PK_F19                     :
            return KEYCODE_F19;
        case    DOM_PK_F20                     :
            return KEYCODE_F20;
        case    DOM_PK_F5                      :
            return KEYCODE_F5;
        case    DOM_PK_F6                      :
            return KEYCODE_F6;
        case    DOM_PK_F7                      :
            return KEYCODE_F7;
        case    DOM_PK_F3                      :
            return KEYCODE_F3;
        case    DOM_PK_F8                      :
            return KEYCODE_F8;
        case    DOM_PK_F9                      :
            return KEYCODE_F9;
        case    DOM_PK_F11                     :
            return KEYCODE_F11;
        case    DOM_PK_F13                     :
            return KEYCODE_F13;
        case    DOM_PK_F16                     :
            return KEYCODE_F16;
        case    DOM_PK_F14                     :
            return KEYCODE_F14;
        case    DOM_PK_F10                     :
            return KEYCODE_F10;
        case    DOM_PK_F12                     :
            return KEYCODE_F12;
        case    DOM_PK_F15                     :
            return KEYCODE_F15;
//        case    DOM_PK_Help                    :
//            return KEYCODE_HELP;
        case    DOM_PK_HOME                    :
            return KEYCODE_HOME;
        case    DOM_PK_PAGE_UP                  :
            return KEYCODE_PAGEUP;
        case    DOM_PK_DELETE           :
            return KEYCODE_DELETE;
        case    DOM_PK_F4                      :
            return KEYCODE_F4;
        case    DOM_PK_END                     :
            return KEYCODE_END;
        case    DOM_PK_F2                      :
            return KEYCODE_F2;
        case    DOM_PK_PAGE_DOWN                :
            return KEYCODE_PAGEDOWN;
        case    DOM_PK_F1                      :
            return KEYCODE_F1;
        case    DOM_PK_ARROW_LEFT               :
            return KEYCODE_LEFT;
        case    DOM_PK_ARROW_RIGHT              :
            return KEYCODE_RIGHT;
        case    DOM_PK_ARROW_DOWN               :
            return KEYCODE_DOWN;
        case    DOM_PK_ARROW_UP                 :
            return KEYCODE_UP;
            
        default:
            return KEYCODE_UNKNOWN;
    }
    
}

