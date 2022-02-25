#pragma once

#include <stdint.h>
#include "render/context.h"
#include "Core/Math.h"
#include "serializer.h"

namespace metalnes {

class raster_device
{
public:
    raster_device() = default;
    virtual ~raster_device() = default;
    
    virtual void Write(int dt, float ntsc_signal) = 0;
    virtual void Flush() = 0;
    virtual void onGui(render::ContextPtr context) = 0;
    virtual void saveState(state_writer &sw) = 0;
    virtual void loadState(state_reader &sr) = 0;
    
    virtual void saveImage(std::string path) = 0;
};

using raster_device_ptr = std::shared_ptr<raster_device>;

raster_device_ptr raster_device_create();

}
