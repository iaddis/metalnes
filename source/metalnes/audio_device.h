#pragma once

#include <stdint.h>
#include <memory>
#include "serializer.h"

namespace metalnes {

class audio_device
{
public:
    audio_device() = default;
    virtual ~audio_device() = default;
    
    
    virtual void Write(int time, float output) = 0;
    virtual void Flush() = 0;
    virtual void onGui(const std::string &state_path) = 0;

    virtual void saveState(state_writer &sw) = 0;
    virtual void loadState(state_reader &sr) = 0;
  
    virtual void saveAudio(std::string path) = 0;
};

using audio_device_ptr = std::shared_ptr<audio_device>;

audio_device_ptr audio_device_create();

}
