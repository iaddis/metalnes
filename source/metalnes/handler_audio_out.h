

#pragma once

#include "wire_handler.h"
#include "audio_device.h"

namespace metalnes
{


class handler_audio_out : public wire_handler
{
    
    wire_register_field(_sq0_out, "sq0_out[3:0]");
    wire_register_field(_sq1_out, "sq1_out[3:0]");
    wire_register_field(_tri_out, "tri_out[3:0]");
    wire_register_field(_noi_out, "noi_out[3:0]");
    wire_register_field(_pcm_out, "pcm_out[6:0]");
    
    wire_register_field(_snd0_out, "sq0_out[3:0]|sq1_out[3:0]");
    wire_register_field(_snd1_out, "tri_out[3:0]|noi_out[3:0]|pcm_out[6:0]");

    audio_device_ptr _audio_device;
    
    float _snd0 = 0;
    float _snd1 = 0;
public:
    handler_audio_out(wire_module_ptr wires, std::string prefix, audio_device_ptr audio_device)
        : wire_handler(wires, prefix), _audio_device(audio_device)
    {
        add_callback(_snd0_out, [this](){
            this->update_snd0();
        });
        
        add_callback(_snd1_out, [this](){
            this->update_snd1();
        });

    }

    
    /*
         
         output = pulse_out + tnd_out

                                     95.88
         pulse_out = ------------------------------------
                      (8128 / (pulse1 + pulse2)) + 100

                                                159.79
         tnd_out = -------------------------------------------------------------
                                             1
                    ----------------------------------------------------- + 100
                     (triangle / 8227) + (noise / 12241) + (dmc / 22638)
     
     */

    float compute_output_snd0(int sq0, int sq1)
    {
        float sum = (float)(sq0 + sq1);
        float pulse_out =  95.88f / ((8128.0f/sum) + 100.0f);
        return pulse_out;
    }
    
    float compute_output_snd1(int tri, int noi, int pcm)
    {
        float sum = ((float)tri / 8227.0f) + ((float)noi / 12241.0f) + ((float)pcm / 22638.0f);
        float tnd_out = 159.79f / ((1.0f / sum) + 100.0f);
        return tnd_out;
    }


    void update_snd0()
    {
        int sq0 = readBits(_sq0_out);
        int sq1 = readBits(_sq1_out);
        _snd0 = compute_output_snd0(sq0, sq1);
        
//        log_printf("audio %d %.03f sq0:%02X sq1:%02X\n",
//                   getTime(),
//                   _snd0,
//                   sq0, sq1);

        update();
    }

    
    void update_snd1()
    {
        int tri = readBits(_tri_out);
        int noi = readBits(_noi_out);
        int pcm = readBits(_pcm_out);
        _snd1 = compute_output_snd1(tri, noi, pcm);
        
//        log_printf("audio %d %.03f tri:%02X noi:%02X pcm:%02X\n",
//                   getTime(),
//                   _snd1,
//                   tri, noi,pcm);
        
        update();
    }
    
    
    
    void update()
    {
        if (_audio_device)
        {
            int time = getTime();
            
            float output = _snd0 + _snd1;
            _audio_device->Write(time, output);
            
//                log_printf("audio %d %.03f %02d %02d %02d %02d %02d\n",
//                           getTime(),
//                           output,
//                           sq0, sq1, tri, noi,pcm);

        }

    }
    

};





}
