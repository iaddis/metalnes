#pragma once

#include "wire_defs.h"
#include "wire_module.h"
#include "wire_gui.h"
#include "raster_device.h"
#include "serializer.h"
#include "nesrom.h"
#include "Core/StopWatch.h"
#include "wire_thread.h"

#include "handler_nes_system.h"
#include "handler_video_out.h"
#include "handler_audio_out.h"

namespace metalnes {



class system_state;
using system_state_ptr = std::shared_ptr<system_state>;


class system_state : public wire_handler
{
protected:
    
    wire_thread _scheduler;
    nesrom_ptr _rom;
    raster_device_ptr _raster_device = nullptr;
    audio_device_ptr _audio_device = nullptr;
    wire_gui_ptr _wire_gui = nullptr;

    std::string _state_path;
    
    
    
    
    handler_nes_system *_handler_nes_system;
    
    
    std::vector<handler_ram *> _handler_ram;
    std::vector<handler_rom *> _handler_rom;
    std::vector<handler_video_out *> _handler_video_out;
    std::vector<handler_audio_out *> _handler_audio_out;

    
    bool  _window_open= true;
    std::string _window_name;

public:
    static system_state_ptr Create(std::string system_def_dir, std::string state_dir, nesrom_ptr rom);

    system_state(wire_module_ptr wires, nesrom_ptr rom, std::string state_path);
    
    virtual ~system_state();


    bool onGui(render::ContextPtr context);
    void startThread();
    void stopThread();
    
    bool shouldQuit();


};


}
