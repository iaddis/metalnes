

#pragma once

#include "wire_handler.h"

namespace metalnes
{


class handler_rom : public wire_handler
{
    wire_memory_field(_rom, "rom");
    
    wire_register_field(_a, "a[]");
    wire_register_field(__d, "_d[7:0]");
    wire_field(_cs, "cs");
    wire_field(_rw, "rw");
    wire_register_field(_trigger, "cs|rw|a[]");

public:
    
    handler_rom(wire_module_ptr wires, std::string prefix)
        : wire_handler(wires, prefix)
    {
        if (_rom)
        {
            add_callback(_trigger, [this](){
                check_rom();
            });
        }
    }
    
    void check_rom()
    {
        if (!_rom) return;
        
        if (!_cs)
        {
            if (_rw)
            {
                int addr = _a;
                int data = _rom->readByte(addr);;
                __d = data;
            }
        }
        else
        {
    //        floatBits(_d);
        }

    }
    

};





}
