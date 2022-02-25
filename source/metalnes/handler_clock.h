

#pragma once

#include "wire_handler.h"

namespace metalnes
{


class handler_clock : public wire_handler
{
    wire_field(_clk, "clk");
    
public:
    
    handler_clock(wire_module *wires, std::string prefix)
        : wire_handler(wires, prefix)
    {
        _wires->add_handler([this](){
            this->handle();
        });
    }
    

    void handle() 
    {
        bool clk = isNodeHigh(_clk);
        if(clk) {
            setLow(_clk);
        } else {
            setHigh(_clk);
        }
    }
};






}
