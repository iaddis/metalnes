#pragma once
#include "wire_module.h"
#include "imgui_support.h"

namespace metalnes {


class wire_gui
{
    
public:
    
    wire_gui() = default;
    virtual ~wire_gui() = default;
    
    virtual void onGui(render::ContextPtr context) = 0;
};

using wire_gui_ptr = std::shared_ptr<wire_gui>;

wire_gui_ptr CreateWireGui(wire_module_ptr wires);

}
