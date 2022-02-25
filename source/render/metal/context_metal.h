

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#include "render/context.h"

#pragma once


namespace render {
namespace metal {



class IMetalContext : public Context
{
public:
    virtual void SetView(MTKView *view) = 0;
    
};

using IMetalContextPtr = std::shared_ptr<IMetalContext>;




extern IMetalContextPtr MetalCreateContext(id <MTLDevice> device);

}} // namespace

