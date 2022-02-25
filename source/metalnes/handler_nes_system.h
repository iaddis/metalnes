

#pragma once

#include "wire_handler.h"
#include "Core/File.h"

#include "imgui_support.h"

#include "audio_device.h"
#include "raster_device.h"

#include "handler_ram.h"
#include "handler_rom.h"
#include "handler_palette_ram.h"
#include "handler_sprite_ram.h"

namespace metalnes
{

class handler_nes_system : public wire_handler
{
    struct EmulationState
    {
        int time;
        
        int ppu_hpos;
        int ppu_vpos;
        int ppu_vbl_flag;
        int ppu_spr_overflow;
        int ppu_spr0_hit;
        int ppu_ab;
        int ppu_db;

        int cpu_a;
        int cpu_x;
        int cpu_y;
        int cpu_ps;
        int cpu_sp;
        int cpu_pc;
        int cpu_opCode;
        int cpu_fetch;

        int cpu_ab;
        int cpu_db;
    };

    wire_field(_clk,  "ppu.clk0");
    wire_field(_res,  "res");
    wire_field(_ppu_in_vblank, "ppu.in_vblank");

    wire_memory_field( _cpuRam, "u1.ram");
    wire_memory_field( _ppuRam, "u4.ram");
    wire_memory_field( _chrRom, "cart.chr.rom");
    wire_memory_field( _chrRam, "cart.chrram.ram");
    wire_memory_field( _prgRom, "cart.prg.rom");
    wire_memory_field( _extraRam, "cart.eram.ram");

    wire_field(_cpu_clk0, "cpu.clk0");
    wire_field(_cpu_sync, "cpu.sync");
    wire_field(_cpu_nmi,  "cpu.nmi");
    wire_field(_cpu_so,   "cpu.so");
    wire_field(_cpu_irq,  "cpu.irq");
    wire_field(_cpu_rw,   "cpu.rw");

    wire_field(_ppu_int,  "ppu.int");

    wire_register_field(_cpu_a,   "cpu.a[7:0]");
    wire_register_field(_cpu_x,   "cpu.x[7:0]");
    wire_register_field(_cpu_y,   "cpu.y[7:0]");
    wire_register_field(_cpu_p,   "cpu.p[7:0]");
    wire_register_field(_cpu_s,   "cpu.s[7:0]");
    wire_register_field(_cpu_ir,  "cpu.ir[7:0]");
    wire_register_field(_cpu_pc,  "cpu.pcl[7:0]|cpu.pch[7:0]");
    wire_register_field(_cpu_pcl, "cpu.pcl[7:0]");
    wire_register_field(_cpu_pch, "cpu.pch[7:0]");
    wire_register_field(_cpu_db,  "cpu.db[7:0]");
    wire_register_field(_cpu_ab,  "cpu.ab[15:0]");


    
    wire_register_field(_ppu_vbl_flag, "ppu.vbl_flag");
    wire_register_field(_ppu_spr_overflow, "ppu.spr_overflow");
    wire_register_field(_ppu_spr0_hit, "ppu.spr0_hit");

    wire_register_field(_ppu_vid_,  "ppu.vid_[11:0]");
    wire_register_field(_ppu_vpos,  "ppu.vpos[7:0]");
    wire_register_field(_ppu_hpos,  "ppu.hpos[7:0]");
    wire_register_field(_ppu_ab,    "ppu.ab[13:0]");
    wire_register_field(_ppu_db,    "ppu.db[7:0]");
    wire_register_field(_ppu_io_ab, "ppu.io_ab[2:0]");
    wire_register_field(_ppu_io_db, "ppu.io_db[7:0]");
    

    wire_register_field(_port0_buttons, "port0.buttons[7:0]");
    wire_register_field(_port1_buttons, "port1.buttons[7:0]");

    
    std::string _state_path;

    
public:
    
    handler_palette_ram *_palram = nullptr;
    handler_sprite_ram *_sprite_ram = nullptr;
    
    bool prev_ppu_in_vblank = false;;
    
    bool _save_frame_states = false;
    int _frame = 0;
    int _frameStartTime = 0;
    int _prevhalfcycle = 0;
    float _frameTime = 0;
    Core::StopWatch _frameTimer;
    
    bool _pad_clear = true;
    int _pad0 = 0;
    int _pad1 = 0;
    
    EmulationState _state = { 0 };

    
    void getState(EmulationState *state)
    {
        state->time = getTime();
        state->ppu_hpos = (_ppu_hpos);
        state->ppu_vpos = (_ppu_vpos);
        state->ppu_vbl_flag = (_ppu_vbl_flag);
        state->ppu_spr_overflow = (_ppu_spr_overflow);
        state->ppu_spr0_hit = (_ppu_spr0_hit);
        state->ppu_ab = (_ppu_ab);
        state->ppu_db = (_ppu_db);

        state->cpu_a = (_cpu_a);
        state->cpu_x = (_cpu_x);
        state->cpu_y = (_cpu_y);
        state->cpu_ps = (_cpu_p);
        state->cpu_sp = (_cpu_s);
        state->cpu_pc = (_cpu_pc);
        state->cpu_ab = (_cpu_ab);
        state->cpu_db = (_cpu_db);

        state->cpu_opCode = (_cpu_ir);
        state->cpu_fetch = (_cpu_sync) ? state->cpu_db : -1;

    }



    
    void clear(wire_memory_handle &mem)
    {
        if (mem)
        {
            mem->clear();
        }
    }




public:
    
    raster_device_ptr _raster_device;
    audio_device_ptr _audio_device;
    

    int getFrame()
    {
        return _frame;
    }
    
    
    handler_nes_system(wire_module_ptr wires, std::string prefix, std::string state_path, raster_device_ptr raster_device, audio_device_ptr audio_device)
     : wire_handler(wires, prefix), _state_path(state_path), _raster_device(raster_device), _audio_device(audio_device)
    {

        _palram = add_handler<handler_palette_ram>("");
        _sprite_ram = add_handler<handler_sprite_ram>("");
        
        add_edge_callback(_ppu_in_vblank, 1, [this](){
            handle_vblank_flag();
        });
    }
    
    
    void handle_vblank_flag()
    {
        onFrameEnd();
    }
    
    
    // this handles blargg test roms which write results to $6000
    bool _unit_test_found = false;
    bool _unit_test_complete = false;
    void check_unit_test()
    {
        // grab eram from cart ($6000)
        auto eram = _wires->resolveMemory( "cart.eram.ram" );
        if (!eram) {
            return;
        }
        
        
        const uint8_t *data = eram->getDataPtr();
        
        
        // check for signature...
        if (data[0x0001] == 0xDE && data[0x0002] == 0xB0 && data[0x0003] == 0x61)
        {
            if (!_unit_test_found) {
                log_printf("[nes-test] unit-test signature found\n");
                _unit_test_found = true;
            }
            
            int result = data[0];
            if (result < 127)
            {
                std::string output;
                
                for (int i=0; i < 1024; i++)
                {
                    char c = (char)data[0x0004 + i];
                    if (!c) break;
                    if (c == '\r') continue;
                    
                    output += c;
                }
                
                if (!_unit_test_complete) {
                    onUnitTestComplete(result, output);
                    _unit_test_complete = true;
                }
            }
        }
    }
    
    void onUnitTestComplete(int result, std::string output)
    {
        log_printf("[nes-test] complete result:%d\n", result);
        log_printf("[nes-test] output:\n%s\n", output.c_str());
        
        if (_raster_device)
            _raster_device->saveImage(_state_path + ".test.png");
        if (_audio_device)
            _audio_device->saveAudio(_state_path + ".test");
    }
    
    bool IsUnitTestComplete()
    {
        return _unit_test_complete;
    }
    
    
    void onFrameEnd()
    {
        int timeFrame  = getTime() - _frameStartTime;
        _frameStartTime = getTime();

        _frameTime = _frameTimer.GetElapsedSeconds();
        _frameTimer.Restart();

        
        
        // capture structured state
        EmulationState emustate;
        getState(&emustate);
        
        
        _port0_buttons = ~_pad0;
        _port1_buttons = ~_pad1;
        
        if (_pad_clear) {
            _pad0 = 0;
            _pad1 = 0;
        }

        int pc = (_cpu_pc);
        log_printf("frame[%d] time:%d pc:%04X a:%02X x:%02X y:%02X p:%02X s:%02X frame-time:%.3fs\n", _frame,
               timeFrame,
               pc,
                   emustate.cpu_a,
                   emustate.cpu_x,
                   emustate.cpu_y,
                   emustate.cpu_ps,
                   emustate.cpu_sp,
               _frameTime
                   );

        
        check_unit_test();

//        logPalette();
        
    //    uint8_t newpal[] = {
    //        0x0F, 0x29, 0x1A, 0x0F , 0x0F, 0x36, 0x17, 0x0F , 0x0F, 0x30, 0x21, 0x0F , 0x0F, 0x27, 0x17, 0x02
    //    , 0x0F, 0x16, 0x27, 0x18 , 0x0F, 0x1A, 0x30, 0x27 , 0x0F, 0x16, 0x30, 0x27 , 0x0F, 0x0F, 0x36, 0x17};
    //
    //    for (int i=0; i < 32; i++)
    //        palette_write(i, newpal[i]);

        

//        wires->dump();
        
    #if 1
        if (_save_frame_states) {
            std::string state_path = _state_path + ".frame#" + std::to_string(_frame);
            SaveState(state_path);
        }
    #endif
        
        
        _frame++;
    }
    
    void reset()
    {
        clear(_cpuRam);
        clear(_ppuRam);
        clear(_chrRam);

        _wires->resetState();

//        setLow(_clk);
//        setHigh(_cpu_nmi);
        
//        setHigh(_ppu_int);
        
        setHigh(_res);
        
//        _wires->step( 6 * 2 );
//        _wires->step( 12 * 8 * 2 );

        _wires->step( 12 * 8 * 2 );

        
        
        setLow(_res);


    }
    
    void softReset()
    {
        setHigh(_res);
        _wires->step( 12 * 8 * 2 );
        setLow(_res);
    }
    
    void SaveState()
    {
        SaveState(_state_path);
    }
    
    void LoadState()
    {
        LoadState(_state_path);
    }
    
    
    
    template<typename TSerializer>
    void serialize_fields(TSerializer &s)
    {
        serialize(s, "frame", _frame);
        serialize(s, "frameStartTime", _frameStartTime);
        serialize_object(s, "wires", _wires);
        serialize_object(s, "raster_device", _raster_device);
        serialize_object(s, "audio_device", _audio_device);
    }

    
    void loadState(state_reader &sr)
    {
        serialize_fields(sr);
        
//            palette_write(0xFF, 0x22);
//            palette_write(0xF, 0x22);
//            _prgRom.ptr[ 0x0EBE - 3] = 0xEA;
//            _prgRom.ptr[ 0x0EBE - 2] = 0xEA;
//            _prgRom.ptr[ 0x0EBE - 1] = 0xEA;

#if 0
            for (int i=1; i < 32; i++)
                palette_write(i, 0x22);
//            palette_write(0xF, 0x22);

#endif

#if 0
        for (int i=0; i < _ppuRam.size; i++)
            _ppuRam.ptr[i] = 0x0;
        for (int i=0; i < _chrRom.size; i++)
            _chrRom.ptr[i] = (i&1) ? 0x00 : 0x00;
#endif

    }

    void saveState(state_writer &sw)
    {
        serialize_fields(sw);
    }

    
    void SaveState(std::string path)
    {
        path += ".json";
        
        if (writeJsonToFile(path, [this](state_writer &sw) {
            saveState(sw);
        }))
        {
            log_printf("Saved state to %s\n", path.c_str());
        }
    }
    
    void LoadState(std::string path)
    {
        path += ".json";
        
        if (readJsonFromFile(path, [this](state_reader &sr) {
            loadState(sr);
        }))
        {
            log_printf("Loaded state from %s\n", path.c_str());
        }
    }
    
    
    
    static bool ToggleButton(const char *text, bool *state)
    {
        bool toggled = false;
        
        if (*state)
        {
            ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(1.0f,0.0f,1.0f,1.0f));
            ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(1.0f,0.0f,1.0f,1.0f));
            ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(1.0f,0.0f,1.0f,1.0f));
        }
        
        toggled = ImGui::Button(text);
        
        if (*state)
        {
            ImGui::PopStyleColor(3);
        }
        
        if (toggled) {
            *state = !*state;
        }
        
        return toggled;
    }

    
    

    
    void onGui()
    {
        static const char *s_ButtonNames[8] =
        {
            "A",
            "B",
            "Select",
            "Start",
            "Up",
            "Down",
            "Left",
            "Right"
        };


        int halfCycle = getTime();
        int deltaCycle =  halfCycle - _prevhalfcycle;
        _prevhalfcycle = halfCycle;

        float rate = ((float)deltaCycle) / ImGui::GetIO().DeltaTime;
        ImGui::Text("cycles/sec: %.1f\n", rate );

        
        
        int frame =     getFrame();
        ImGui::Text("frame: %d\n", (int)frame );
        ImGui::SameLine();
        ImGui::Text("vpos: %d\n", (int)readBits(_ppu_vpos) );
        ImGui::SameLine();
        ImGui::Text("hpos: %d\n", (int)readBits(_ppu_hpos) );
    //    ImGui::SameLine();
        
        
        for (int i=0; i < 8; i++)
        {
            bool isdown =  (_pad0 & (1<<i));
            if (ToggleButton(s_ButtonNames[i], &isdown))
            {
                _pad0 ^= (1<<i);
            }
            ImGui::SameLine();
        }

        ToggleButton("ClearOnRead", &_pad_clear);
        ImGui::SameLine();

        ImGui::NewLine();
        

        ToggleButton("SaveFrameStates", &_save_frame_states);
        ImGui::SameLine();

        if (ImGui::ButtonEx("Save Screenshot")) {
            std::string path = _state_path + ".frame#" + std::to_string(frame)  +  ".png";
            _raster_device->saveImage(path);
        }

        
        ImGui::NewLine();

        
    }



    
};





}
