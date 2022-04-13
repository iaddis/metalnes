
#include <deque>
#include <cstring>
#include <algorithm>
#include <ostream>
#include <iostream>
#include <future>
#include <thread>
#include <stdarg.h>
#include "UnitTests.h"

#include "system.h"
#include "imgui_support.h"
#include "render/context.h"
#include "raster_device.h"
#include "Core/File.h"
#include "Core/Path.h"
#include "Core/StopWatch.h"
#include "serializer.h"
#include "chiprender.h"
#include "nesrom.h"
#include "logger.h"
#include "nesdisasm.h"
#include "wire_gui.h"
#include "wire_node_resolver.h"

#include "handler_log.h"
#include "handler_video_out.h"
#include "handler_audio_out.h"
#include "handler_nes_system.h"

bool _demo_window_open = false;


namespace metalnes {


void system_state::startThread()
{
    printf("Starting thread system:'%s' rom:'%s'\n",  _wires->getName(), _rom->name.c_str());
    _scheduler.startThread();
}

void system_state::stopThread()
{
    printf("Stopping thread system:'%s' rom:'%s'\n",  _wires->getName(), _rom->name.c_str());
    _scheduler.stopThread();
}



system_state::system_state(wire_module_ptr wires, nesrom_ptr rom, std::string state_path)
    : wire_handler(wires, ""), _scheduler(wires), _rom(rom), _state_path(state_path)
{
    
    _wire_gui =  CreateWireGui(wires);

    
    _audio_device = audio_device_create();
    _raster_device = raster_device_create();


    
    _handler_rom   = register_handlers<handler_rom>("*func<rom>");
    _handler_ram   = register_handlers<handler_ram>("*func<ram>");
    _handler_video_out = register_handlers<handler_video_out>("*func<video_out>", _raster_device);
    _handler_audio_out = register_handlers<handler_audio_out>("*func<audio_out>", _audio_device);

    _handler_nes_system = add_handler<handler_nes_system>("", state_path, _raster_device, _audio_device);

    _handler_nes_system->reset();
}




system_state::~system_state()
{
    stopThread();
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

bool system_state::shouldQuit()
{
    if (_handler_nes_system)
    {
        return _handler_nes_system->IsUnitTestComplete();
    }
    return false;
}

bool system_state::onGui(render::ContextPtr context)
{
//    std::lock_guard<std::mutex> lock(_execMutex);
    
    if (!_window_open)
    {
        return false;
    }
    
    if (_window_name.empty())
    {
//        _window_name = "metal-nes";
        _window_name += _rom->name;
        _window_name += "##";
        _window_name += std::to_string( ((uintptr_t)this) );
    }

    _wire_gui->onGui(context);
    
    
    ImGuiWindowFlags window_flags = ImGuiWindowFlags_MenuBar;
    //  ImGui::SetNextWindowPos(ImVec2(0,0)); //, ImGuiCond_Always);
//    ImGui::SetNextWindowContentSize(ImVec2(800,600)); //, ImGuiCond_Always);
    if (!ImGui::Begin( _window_name.c_str(), &_window_open, window_flags))
    {
        // Early out if the window is collapsed, as an optimization.
        ImGui::End();
        
        return false;
    }
    
    
    
    if (ImGui::BeginMenuBar())
    {
        if (ImGui::BeginMenu("View"))
        {
            /*
            for (auto chip : _chip_render_list)
            {
                if (ImGui::MenuItem( chip->GetName(), NULL,  chip->IsVisible() ))
                {
                    chip->SetVisible( !chip->IsVisible() );
                }
            }
            */
            
            if (ImGui::MenuItem( "IMGui Demo", NULL, _demo_window_open))
            {
                _demo_window_open = !_demo_window_open;
            }
            
            ImGui::EndMenu();
        }
        
//        if (ImGui::BeginMenu("Simulator"))
//        {
//            if (ImGui::MenuItem("Run", nullptr, _scheduler.isRunning() ))
//            {
//                _scheduler.toggleRunning();
//            }
//
//            ImGui::EndMenu();
//        }
        
//        if (ImGui::BeginMenu("Unit Tests"))
//        {
//            RunUnitTests();
//            ImGui::EndMenu();
//        }

        ImGui::EndMenuBar();
    }

    if (_rom)
    {
        ImGui::Text("rom: %s\n",_rom->name.c_str() );
    }
    

    bool running = _scheduler.isRunning();
    if (ToggleButton("Run", &running))
    {
        _scheduler.toggleRunning();
    }
    ImGui::SameLine();

    if (ImGui::ButtonEx("Step", ImVec2(0,0), ImGuiButtonFlags_Repeat)) {
        _scheduler.enqueue([this] {
            _scheduler.setRunning(false);
            _scheduler.step();
            _raster_device->Flush();
        });
    }
    ImGui::SameLine();



    if (ImGui::ButtonEx("Trace")) {
        _scheduler.enqueue([this] {
//            this->_traceCycles = 12 * 2;
        });
    }

//    ImGui::SameLine();
    ImGui::SameLine();

    
    if (ImGui::Button("SoftReset"))
    {
        _scheduler.enqueue([this] {
            _handler_nes_system->softReset();
        });
    }


    ImGui::SameLine();

    if (ImGui::Button("Load State"))
    {
        _scheduler.enqueue([this] {
            _handler_nes_system->LoadState();
        });
        
    }
    ImGui::SameLine();

    if (ImGui::Button("Save State"))
    {
        _scheduler.enqueue([this] {
            _handler_nes_system->SaveState();
        });
    }
    
    
    if (ImGui::Button("Run Unit Tests"))
    {
        RunUnitTests();
    }

    
    if (_handler_nes_system)
    {
        _handler_nes_system->onGui();
    }
    ImGui::End();

    

    if (_raster_device)
    {
        _raster_device->onGui(context);
    }

    if (_audio_device)
    {
        _audio_device->onGui( _state_path );
    }

    
//    gui_draw_chip(_wires);
    
    return true;
}






void disassemble(const uint8_t *mem, int start, int end)
{
    std::string line;
    int pc = start;
    while (pc < end)
    {
        int size = nes_disasm(line, mem, pc);
        
        printf("%04X ", pc);
        
        for (int i=0; i < size; i++)
        {
            printf("%02X", mem[i] );
        }
        
        for (int i=size; i < 3; i++)
        {
            printf("  ");
        }

        printf(" %s\n", line.c_str());
        
//        printf("%04X %s\n", pc, line.c_str());
        pc  += size;
        mem += size;
    }
}


//static void setupRom(wire_defs_ptr defs, nesrom_ptr rom, std::string prefix)
//{
//    if (rom->prg_rom.size() == 0x4000)
//    {
//        defs->setMemory(combinePrefix(prefix, "prg.rom"), 0x0000, rom->prg_rom.data(), 0x4000);
//        defs->setMemory(combinePrefix(prefix, "prg.rom"), 0x4000, rom->prg_rom.data(), 0x4000);
//    }
//    else
//    if (!rom->prg_rom.empty())
//    {
//        if (!defs->setMemory(combinePrefix(prefix, "prg.rom"), 0x0000, rom->prg_rom.data(), rom->prg_rom.size() ))
//        {
//            assert(0);
//        }
//    }
//
//    if (!rom->chr_rom.empty())
//    {
//        if (!defs->setMemory(combinePrefix(prefix, "chr.rom"), 0x0000, rom->chr_rom.data(), rom->chr_rom.size() ))
//        {
//            assert(0);
//        }
//    }
//}


bool setMemory(wire_module_ptr wires, std::string name, int address, const uint8_t *ptr, size_t size)
{
    auto memory = wires->resolveMemory(name);
    if (memory) {
        memory->writeBytes(address, ptr, size);
        return true;
    }
    return false;
}


static void setupRom(wire_module_ptr wires, nesrom_ptr rom, std::string prefix)
{
    if (rom->prg_rom.size() == 0x4000)
    {
        setMemory(wires, combinePrefix(prefix, "prg.rom"), 0x0000, rom->prg_rom.data(), 0x4000);
        setMemory(wires, combinePrefix(prefix, "prg.rom"), 0x4000, rom->prg_rom.data(), 0x4000);
    }
    else
    if (!rom->prg_rom.empty())
    {
        if (!setMemory(wires, combinePrefix(prefix, "prg.rom"), 0x0000, rom->prg_rom.data(), rom->prg_rom.size() ))
        {
            assert(0);
        }
    }

    if (!rom->chr_rom.empty())
    {
        if (!setMemory(wires, combinePrefix(prefix, "chr.rom"), 0x0000, rom->chr_rom.data(), rom->chr_rom.size() ))
        {
            assert(0);
        }
    }
}

system_state_ptr system_state::Create(std::string system_def_dir, std::string state_dir, nesrom_ptr rom)
{
//    disassemble( rom->prg_rom.data(), 0x8000, (int)(0x8000 + rom->prg_rom.size()) );


    
    //
    // load system definitions
    //
    
    std::string defs_name = "nes-001";
    wire_defs_ptr system_defs = wire_defs::Load( system_def_dir, defs_name);
    if (!system_defs)
    {
        return nullptr;
    }

    
    //
    // load cart definitions
    //
    
    auto cart_defs = wire_defs::Load( system_def_dir, "cart-mmu0");
    assert(cart_defs);

    {
        cart_defs->addInstance(system_def_dir, "cart-mmu0-prgrom", "");
    }

    
    {
        std::string cart_chr_name = (!rom->chr_rom.empty()) ? "cart-mmu0-chrrom" : "cart-mmu0-chrram";
        cart_defs->addInstance(system_def_dir, cart_chr_name, "");
    }

    // add extra ram...
#if 1
    if (rom->path.find("nes-test-roms/") !=  std::string::npos)     // do it just for test roms....need a better way
    {
        cart_defs->addInstance(system_def_dir, "cart-extraram" , "");
    }
#endif


    // add cart to system
//    system_defs->addInstance(cart_defs, "cart");
//    setupRom(system_defs, rom, "cart.");
    
    
    wire_module_ptr wires = WiresCreate();
  
    wires->addInstance(nullptr, system_defs, "");
    wires->addInstance(nullptr, cart_defs,   "cart");

    
    setupRom(wires, rom, "cart.");

    
    

    
    
    

    
    std::string state_path = Core::Path::Combine(state_dir, rom->name);

    
    system_state_ptr state = std::make_shared<system_state>(wires, rom, state_path);

    
    
    
    
    
//    std::string _tracedColumns = "cpu.clk_in,cpu_clk0,ppu_io_ce,ppu_io_ab,ppu_io_db,cpu_ab,cpu_db,cpu_rw";
//  state->setTrace( _tracedColumns );
//    state->logCount = 10000;
//    state->setTraceTrigger( "cpu.clk0");
    

//        std::string _tracedColumns = "cpu.clk_in,cpu_clk0,ppu_io_ce,ppu_io_ab,ppu_io_db,cpu_ab,cpu_db,cpu_rw";
  
//    std::string _tracedColumns = "u3.2/E,u3.2A1,u3.2A0,u3.2E,u3.2Y0,u3.2Y1,u3.2Y2,u3.2Y3,u3.2/Y0,u3.2/Y1,u3.2/Y2,u3.2/Y3";
    
//    std::string _tracedColumns = "u3.2/E,u3.2A1,u3.2A0,u3.2/Y0,u3.2/Y1,u3.2/Y2,u3.2/Y3";
//    std::string _tracedColumns = "u3.2/E,u3.2A1,u3.2A0,u3.2/Y0,u3.2/Y1,u3.2/Y2,u3.2/Y3,u3.1/E,u3.1A1,u3.1A0,u3.1/Y0,u3.1/Y1,u3.1/Y2,u3.1/Y3";

//    std::string _tracedColumns = "u3.2/E,u3.2A1,u3.2A0,u3.2/Y0,u3.2/Y1,u3.2/Y2,u3.2/Y3," "u3.1/E,u3.1A1,u3.1A0,u3.1/Y0,u3.1/Y1,u3.1/Y2,u3.1/Y3";
    
//    std::string _tracedColumns = "u3.2/E,u3.2A1,u3.2A0,u3.1A1,u3.1A0,u3.1/Y1";

//        std::string _tracedColumns = "cpu.clk0,cpu.ab15,cpu.ab14,cpu.ab13,u3.1/Y0,u3.1/Y1,ppu.io_ce";

    std::string  _tracedColumns;
//
//    _tracedColumns = "u3.1/Y3";
    
//    _tracedColumns = "cpu.clk0,u1.a,u1.d,u1.cs,u1./oe,u1./we";
//    _tracedColumns = "cpu.clk0,cpu.ab,cpu.db,cpu.rw,prg.a,prg.d,prg.cs,prg.rw,prg./oe";


//    _tracedColumns = "cpu.clk0,u4.a,u4.d,u4.cs,u4./oe,u4./we,cart.ppu_a13,cart.ppu_/a13";
//    _tracedColumns = "u4.a,u4.d,u4.cs,u4./oe,u4./we,cart.ppu_a13,cart.ppu_/a13";
    
//    _tracedColumns = "u2.OE,u2.LE,u2.d0,u2./d0,u2.q0,u2./q0,u2.s0,u2.r0,u2.o0";
  
//    _tracedColumns = "cpu.out0,cpu.out1,port0.clk,port0.d0,port0.out,port0.buttons";
    
//    _tracedColumns = "cpu.out0,cpu.out1,port0.d0,port0.out,port0.buttons";
  
//    _tracedColumns = "port0.shift.L0.strobe,-,port0.shift.CLK,port0.shift.PL,cpu.out1,port0.d0,port0.buttons[],port0.shift.d[],port0.shift.q[],port0.shift.L0.clk";
    
//    _tracedColumns = "port0.shift.L0.strobe,port0.shift.L0.clk,port0.shift.L0.d,port0.shift.L0.q,port0.shift.L0./q,port0.shift.L0.set,port0.shift.L0.reset";

//    _tracedColumns = "ppu.io_ce,ppu.pal_ptr[],ppu.vpos[],ppu.hpos[],cpu.clk_in,cpu.clk0,ppu.io_ab[],ppu.io_db[],cpu.ab[],cpu.db[],cpu.rw";
    
    
//    _tracedColumns = "ppu.pclk1,ppu.pal_d[5:0]_out,ppu.pal_ptr[],ppu.vpos[],ppu.hpos[],cpu.clk_in,"
//
//    "ppu.+(++/spr_pixel_opaque_and_not_hidden_behind_bg_pixel)_or_/vramaddr_v4,"
//    "ppu.(++/selected_attr1_or_exp_in3_if_bg)_or_/vramaddr_v3,"
//    "ppu.(++/selected_attr0_or_exp_in2_if_bg)_or_/vramaddr_v2,"
//    "ppu.(++/selected_pat1_or_exp_in1_if_bg)_or_/vramaddr_v1,"
//    "ppu.(++/selected_pat0_or_exp_in0_if_bg)_or_/vramaddr_v0"

    ;
    
//    _tracedColumns = "ppu.pclk1,ppu.pal_d[5:0]_out,ppu.pal_ptr[],ppu.vpos[],ppu.hpos[],cpu.clk_in";
    
//    _tracedColumns = "cpu.clk0,cpu.ab[],cpu.db[],cpu.rw,cart.eram.cs,cart.cpu_a14,cart.cpu_a13";
//
//    _tracedColumns += ",-,";
//
//
//    _tracedColumns += "cart.u3.2/E,cart.u3.2A1,cart.u3.2A0,cart.u3.2/Y0,cart.u3.2/Y1,cart.u3.2/Y2,cart.u3.2/Y3,cart.u3.1/E,cart.u3.1A1,cart.u3.1A0,cart.u3.1/Y0,cart.u3.1/Y1,cart.u3.1/Y2,cart.u3.1/Y3";
    
    
//    sprintf(name, "ppu.paldata_%02X_b[5:0]", i);

    
    

//    _tracedColumns = "port0.shift.CLK,port0.shift.PL,cpu.out1,port0.d0,port0.buttons[],port0.shift.d[],port0.shift.q7,port0.shift.q6,port0.shift.q5,port0.shift.L0.clk";
    
//    _tracedColumns = "cpu.joy1,cpu.joy2,cpu.out[],-,cpu.clk0,port0.buttons[],cpu.db[4:0]";

    
    if (!_tracedColumns.empty())
    {
        auto log = state->add_handler<handler_log>("");
        log->setTrace(_tracedColumns );
    }


    // start simulation...
    state->startThread();
    
    return state;
}


} // namespace



