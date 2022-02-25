

#pragma once

#include "wire_handler.h"

namespace metalnes
{



class handler_ram : public wire_handler
{
    wire_memory_field(_ram, "ram");
    wire_register_field(_a, "a[]");
    wire_register_field(__d, "_d[7:0]");
    wire_field(_cs, "cs");
    wire_field(__oe, "/oe");
    wire_field(__we, "/we");

    wire_register_field(_trigger, "cs|/we|a[]|d[]");
public:
    
    handler_ram(wire_module_ptr wires, std::string prefix)
        : wire_handler(wires, prefix)
    {
#if 1
        if (_ram)
        {
            add_callback(_trigger, [this](){
                check_ram();
            });
        }
#endif
    }
    
    void check_ram()
    {
        /*
        if (!_ram) return;
        
        if (!isNodeHigh(_cs))
        {
            if (isNodeHigh(__we))
            {
                int addr = readBits(_a);
                int data = _ram->readByte(addr);
                writeBits(__d, data);
            }
            else
            {
                int addr = readBits(_a);
                int data = readBits(__d);
                _ram->writeByte(addr, data);
                
//                if (verbose)
//                {
//                    int time = getFrameTime();
//                    log_printf("[%02d] %08d  %s-write[%04X] = %02X\n", _frame,  time,  ram._name, (int)addr, (int)data  );
//                }
            }
        }
        else
        {
    //        floatBits(_d);
        }
         */
        
        if (!_ram) return;
        
        if (!_cs)
        {
            if (__we)
            {
                int addr = _a;
                int data = _ram->readByte(addr);
                __d = data;
            }
            else
            {
                int addr = _a;
                int data = __d;
                _ram->writeByte(addr, data);
                
//                if (verbose)
//                {
//                    int time = getFrameTime();
//                    log_printf("[%02d] %08d  %s-write[%04X] = %02X\n", _frame,  time,  ram._name, (int)addr, (int)data  );
//                }
            }
        }
        else
        {
    //        floatBits(_d);
        }
    }
};





}
