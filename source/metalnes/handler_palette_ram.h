

#pragma once

#include "wire_handler.h"

namespace metalnes
{


class handler_palette_ram : public wire_handler
{
    static constexpr int paletteRamSize = 0x20;
    std::vector<wire_register_handle> _palette_nodes;
public:
    handler_palette_ram(wire_module_ptr wires, std::string prefix)
     : wire_handler(wires, prefix)
    {
        _palette_nodes.reserve(paletteRamSize);
        for (int i=0; i < paletteRamSize; i++)
        {
            char name[256];
            sprintf(name, "ppu.pal_ram_%02X_b[5:0]", i);
            _palette_nodes.push_back(resolveRegister(name));
        }
    }
    
    int palette_read(int addr) {
        return _palette_nodes[addr].get();
    }
     
    void palette_write(int addr, int val) {
        _palette_nodes[addr].set(val);
    }
    
    
    
    void logPalette()
    {
        std::stringstream ss;
        ss << ("palette:");
        for (int i=0; i < 32; i++)
        {
            if ((i&3) == 0) {
                ss << ' ';
            }

            int paldata = palette_read(i);
            
            char str[64];
            sprintf(str, "%02X", paldata);
            ss << str;
        }
        ss << '\n';
        
        log_write(ss.str());
    }
};





}
