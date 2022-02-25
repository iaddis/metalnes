

#pragma once

#include "wire_handler.h"

namespace metalnes
{


class handler_video_out : public wire_handler
{
    
    //    // video output levels, ordered from GND to VCC (duplicates of the above)
    //    vid_0:751, // h sync
    //    vid_1:4941, // colorburst L
    //    vid_2:5538, // color 0D
    //    vid_3:787, // colors xE and xF
    //    vid_4:5835, // color 1D, same level as xE/xF
    //    vid_5:4942, // colorburst H
    //    vid_6:5912, // color 2D
    //    vid_7:5556, // color 00
    //    vid_8:5842, // color 10
    //    vid_9:5805, // color 3D
    //    vid_10:5925, // color 20
    //    vid_11:5784, // color 30, same as vid_10 (color 20)
    //
    //    Synch    0.781    0.000    -0.359
    //    Colorburst L    1.000    0.218    -0.208
    //    Colorburst H    1.712    0.931    0.286
    //    Color 0D    1.131    0.350    -0.117
    //    Color 1D (black)    1.300    0.518    0.000
    //    Color 2D    1.743    0.962    0.308
    //    Color 3D    2.331    1.550    0.715
    //    Color 00    1.875    1.090    0.397
    //    Color 10    2.287    1.500    0.681
    //    Color 20    2.743    1.960    1.000
    //    Color 30    2.743    1.960    1.000


    static constexpr float _ntsc_levels[12] = {
        0.781,    //    Synch       0.781    0.000    -0.359            vid_sync_l
        1.000,    //    ColorbursL  1.000    0.218    -0.208            vid_burst_l
        1.131,    //    Color 0D    1.131    0.350    -0.117            vid_luma0_l
        1.300,    //    Color 1D    1.300    0.518    0.000             vid_sync_h
        1.300,    //    Color 1D    1.300    0.518    0.000             vid_luma1_l
        1.712,    //    ColorburstH 1.712    0.931    0.286             vid_burst_h
        1.743,    //    Color 2D    1.743    0.962    0.308             vid_luma2_l
        1.875,    //    Color 00    1.875    1.090    0.397             vid_luma0_h
        2.287,    //    Color 10    2.287    1.500    0.681             vid_luma1_h
        2.331,    //    Color 3D    2.331    1.550    0.715             vid_luma3_l
        2.743,    //    Color 20    2.743    1.960    1.000             vid_luma2_h
        2.743,    //    Color 30    2.743    1.960    1.000             vid_luma3_h
    };

//    wire_register_field(_vid_output,
//    "vid_sync_l|vid_burst_l|vid_luma0_l|vid_sync_h|vid_luma1_l|vid_burst_h|vid_luma2_l|vid_luma0_h|vid_luma1_h|vid_luma3_l|vid_luma2_h|vid_luma3_h"


    raster_device_ptr _raster_device;

    wire_register_field(_vid_output, "vid_[11:0]");
    
    
    
public:
    
    handler_video_out(wire_module_ptr wires, std::string prefix, raster_device_ptr raster_device)
        : wire_handler(wires, prefix), _raster_device(raster_device)
    {
        add_callback(_vid_output, [this](){
            check_video_out();
        });
    }
    
    
    float _signal = 0.0f;
    int _time = 0;
    
    
    void check_video_out()
    {
        const auto &nodes = _vid_output.reg->getNodes();
        
        int level = 0;
        for (int i=11; i >=0; i--)
        {
            if (_wires->isNodeHigh(nodes[i])) {
                level = i;
                break;
            }
        }
        
        
        float signal = _ntsc_levels[level];
        
        
        // emit signal
        int time = getTime();
        int dt = time - _time;

        if (_raster_device)
        {
            if (dt >= 0 && dt < 1024 * 1024)
            {
                _raster_device->Write(dt, _signal);
            }
        }

        _time = time;
        _signal = signal;
    }
  
};





}
