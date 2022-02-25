

#pragma once

#include "wire_handler.h"

namespace metalnes
{


class handler_sprite_ram : public wire_handler
{
    static constexpr int spriteRamSize = 0x120;
    std::vector<wire_register_handle> _sprite_nodes;
public:
    
    handler_sprite_ram(wire_module_ptr wires, std::string prefix)
     : wire_handler(wires, prefix)
    {
        _sprite_nodes.reserve(spriteRamSize);
        for (int i=0; i < spriteRamSize; i++)
        {
            char name[256];
            sprintf(name, "ppu.oam_ram_%02X_b[7:0]", i);
            _sprite_nodes.push_back(resolveRegister(name));
        }
    }
    
    int sprite_read(int addr) {
        return _sprite_nodes[addr].get();
    }

    void sprite_write(int addr, int val) {
        _sprite_nodes[addr].set(val);
    }

};





}
