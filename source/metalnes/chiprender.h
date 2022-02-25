
#pragma once

#include "render/context.h"
#include "wire_module.h"
#include "wire_defs.h"
#include <unordered_set>
#include <memory>




namespace metalnes {


class chip_render
{
public:
    virtual ~chip_render() = default;
    virtual const char *GetName() = 0;
    virtual void onGui(render::ContextPtr context) = 0;
    
    
    virtual bool IsVisible() = 0;
    virtual void SetVisible(bool visible) =0;
    
    virtual void setSelectedNodes(const std::unordered_set<nodeID> &nodes) = 0;

};

using chip_render_ptr = std::shared_ptr<chip_render>;

chip_render_ptr CreateWireRender(wire_module_ptr wires, wire_instance_ptr instance);


} // namespace
