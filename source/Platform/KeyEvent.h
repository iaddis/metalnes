
#pragma once

#include "keycode.h"


struct KeyEvent
{
    char c;
    KeyCode  code;
    bool     KeyShift;
    bool     KeyCtrl;
    bool     KeyAlt;
    bool     KeyCommand;
};
