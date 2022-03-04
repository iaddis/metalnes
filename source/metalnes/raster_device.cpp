

#include "raster_device.h"
#include "render/context.h"
#include "imgui_support.h"

#include "Core/File.h"
#include "logger.h"
#include <cmath>
#include <thread>
#include <mutex>
#include <condition_variable>

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "../external/stb/stb_image_write.h"


void SetCurrentThreadName(const char* threadName);

namespace metalnes {


//uint8_t *mGammaLookup;
//
//static uint8_t clamp_gamma_fix(float v, float gamma)
//{
//    if (v < 0) return 0;
//    
//    // gamma correct
//    v = pow(v, 2.2f / gamma);
//    
//    // clamp
//    int i = (int)(v * 255.0);
//    if (i > 255) i = 255;
//    return i;
//}
//
//
//
//static void GenerateGammaLookup()
//{
//    float gamma = 2.0;
//    int size = 1024;
//    mGammaLookup = new uint8_t[size];
//    
//    for (int i=0; i < size; i++)
//    {
//        float fval = i * 2.0f / (float)size;
//        int ival = clamp_gamma_fix(fval, gamma);
//        mGammaLookup[i] = (uint8_t)ival;
//    }
//}
//
//static uint8_t gamma_lookup(float fval)
//{
//    int index = (int)(fval * 1024.0 / 2.0);
//    if (index < 0)
//        return 0;
//    if (index >= 1024)
//        return 0xFF;
//    
//    if (!mGammaLookup)
//        GenerateGammaLookup();
//    return mGammaLookup[index];
//}


//static uint32_t ConvertYIQToRGB(float y, float i, float q)
//{
//    float fr = y + 0.946882f*i + 0.623557f*q;
//    float fg = y + -0.274788f*i + -0.635691f*q;
//    float fb = y + -1.108545f*i + 1.709007f*q;
//    //            int r = clamp_gamma_fix(fr);
//    //            int g = clamp_gamma_fix(fg);
//    //            int b = clamp_gamma_fix(fb);
//    
//    uint8_t r = gamma_lookup(fr);
//    uint8_t g = gamma_lookup(fg);
//    uint8_t b = gamma_lookup(fb);
//    
//    uint32_t rgb = (r << 0) | (g << 8) | (b << 16);
////    rgb |= 0xFF000000;
//    return rgb;
//}

//static inline int clamp_only(float v)
//{
//    // clamp
//    int i = (int)(v);
//    if (i < 0) return 0;
//    if (i > 255) return 255;
//    return i;
//}

static uint32_t ConvertYIQToYIQ8(float y, float i, float q)
{
    int y8 = (int)(y * 128.0f); // //clamp_only(y * 255.0f);
//    int y8 = clamp_only(y * 128.0f);
    int i8 = (int)(i * 128.0f + 128.0f);
    int q8 = (int)(q * 128.0f + 128.0f);

    i8 &= 0xff;
    q8 &= 0xff;

    uint32_t yiq = (y8 << 0) | (i8 << 8) | (q8 << 16);
    
    yiq |= 0xFF000000;
    return yiq;
}



static inline float NTSCNormalizeSignal(float signal)
{
    static constexpr float black = .518f, white = 1.962f;
    return (signal - black) / (white - black);
}



class ntsc_decoder
{
public:
    

    
    int SignalBufferWidth =  24;
    int ColorPhase = 2;
    int YTuningQuality = 12;
    int IQTuningQuality = 0;
    
    int hpos = 0;
    int vpos = 0;
    int waiting = 0;
    int SyncLength = 0;
    float previous = 0.0f;
    int temp = 0;
    int DecodeColorPhase = 0;
    
    int DecodePhase = 0;

    float ysum = 0.0f;
    float isum = 0.0f;
    float qsum = 0.0f;
    
    
    
    bool vblank = false;
    bool hblank = false;
    bool endframe = false;
    
    
    int signal_pos = 0;
    
    float signal_history[64] = {0};
//    YIQ kbuf[32] = {};

    
    // signal buffer
//    YIQ yiq_table[12];
    
    float sin_table[64];
    
    
//    YIQ yiq[341 * 8];
    
    
    
    std::vector<float> line_signal;
    
    
    ntsc_decoder()
    {
        init();
    }
    
    void init()
    {
        float hue = 3.9f;
//           float saturation = 1.7f;
//           float brightness = 1.0f;
//
//           for (int i = 0; i < 12; i++)
//           {
//
//              float angle = M_PI / 6 * (i + hue);
//
//              float cos = cosf(angle);
//              float sin = sinf(angle);
//
//              yiq_table[i].y = 1.0f * brightness;
//              yiq_table[i].i = cos * saturation;
//              yiq_table[i].q = sin * saturation;
//
//
//           }
//

        for (int i = 0; i < 64; i++)
        {
            float angle = M_PI / 6 * (i + hue);
            sin_table[i] = cosf(angle);
        }
        

        line_signal.resize(341 * 8);

//        memset(yiq, 0, sizeof(yiq));
    }

    void FilterSignal(const float *  src, int srcCount, render::ImageDataPtr dest);

    
    template<typename TSerializer>
    void serialize_fields(TSerializer &serializer)
    {
#define SERIALIZE(_name) serialize(serializer, #_name, _name );
        SERIALIZE(SignalBufferWidth)
        SERIALIZE(ColorPhase)
        SERIALIZE(YTuningQuality)
        SERIALIZE(IQTuningQuality)
        SERIALIZE(hpos)
        SERIALIZE(vpos)
        SERIALIZE(waiting)
        SERIALIZE(SyncLength)
        SERIALIZE(previous)
        SERIALIZE(DecodeColorPhase)
        SERIALIZE(DecodePhase)
        SERIALIZE(ysum)
        SERIALIZE(isum)
        SERIALIZE(qsum)
        SERIALIZE(vblank)
        SERIALIZE(hblank)
#undef SERIALIZE

    }

    virtual void saveState(state_writer &sw)
    {
        serialize_fields(sw);
    }
    
    
    
    virtual void loadState(state_reader &sr)
    {
        serialize_fields(sr);
    }
};

void ntsc_decoder::FilterSignal(const float *  src,  int srcCount, render::ImageDataPtr dest)
{
    int Ywidth = SignalBufferWidth - YTuningQuality;
    int Iwidth = SignalBufferWidth - IQTuningQuality;
    int Qwidth = Iwidth;
    float ymul = 1.0f / Ywidth;
    float imul = 1.0f / Iwidth;
    float qmul = 1.0f / Qwidth;
//
//    constexpr float ymul = 1.0f;
//    constexpr float imul = 1.0f;
//    constexpr float qmul = 1.0f;
    
    int destWidth = dest->width;
    
//    int pcount = 0;
    
    float level = previous;

    uint32_t *dest_line = dest->Row<uint32_t>(vpos);

    for (int i = 0; i < srcCount; i++)
    {
         float s = src[i];

        
        previous = level;
        level = NTSCNormalizeSignal(s);
     
        if (hpos < destWidth)
        {
            
            line_signal[hpos] = level;
            
            
            
            if (dest_line)
            {
                if (waiting < 0)
                {
//                    dest_line[hpos] = ConvertYIQToRGB( level , 0.2, 0);
                    dest_line[hpos] = ConvertYIQToYIQ8( level , 0.2, 0);
                    
//                    dest_line[hpos] = ConvertYIQToRGB( level , level, 0);
//                    dest_line[hpos] = 0xFF00FFFF;
                }
                else
                {
                    dest_line[hpos] = ConvertYIQToYIQ8(
//                    dest_line[hpos] = ConvertYIQToRGB(
                        ysum * ymul,
                        isum * imul,
                        qsum * qmul
                     );
                }
            }
            hpos++;
            
            //                pcount += 256 * 8;
        }

        if (--DecodePhase < 0)    DecodePhase = SignalBufferWidth - 1;
   
        

        
        // sync signal?
        if (level <= 0.19f)
        {
            SyncLength++;

            if (SyncLength == 25)
            {
                // hsync
                hpos = 0;
                vpos++;
                if (vpos >= 261) vpos = 261;

//                dest_line = dest->Row<uint32_t>(vpos);
//                for (int i=0; i < destWidth; i++)
//                {
//                    dest_line[i] = 0x00200080;
//                }
            }
            else
            if (SyncLength == 2000)
            {
                // vsync
          //                      printf("vsync vpos:%03d hpos:%03d %d\n", vpos, hpos, SyncLength);
                hpos = 0;
                vpos = 0;
                endframe = true;
            }
            

            waiting = -1;
            dest_line = dest->Row<uint32_t>(vpos);
            continue;
        }

        if (SyncLength > 0) {
          SyncLength -= 5;
            if (SyncLength < 0) SyncLength = 0;
        }
        
        if (waiting < 0)
        {
            // pulse?
            if (level >= 0.9f)
            {
                waiting--;
                if (waiting <= -6)
                {
                    waiting = 0;
                    
//                    printf("%d: %d %d\n", vpos, DecodePhase, DecodeColorPhase);
                    DecodePhase    = (DecodePhase + SignalBufferWidth - DecodeColorPhase + ColorPhase) % 12;

                    ysum = 0;
                    isum = qsum = 0;
                }
            }
            else
                
            if (level >= 0.5f && previous < 0.5f)
            {
                DecodeColorPhase = temp;
                temp = DecodePhase;
            }
        }
        else if (waiting > 0)
        {
            waiting--;
        }
        else // waiting == 0
        {
              
            int DecodePhaseY  = (signal_pos + YTuningQuality);
            int DecodePhaseI = (signal_pos + IQTuningQuality);
            if (DecodePhaseY >= SignalBufferWidth)  DecodePhaseY -= SignalBufferWidth;
            if (DecodePhaseI >= SignalBufferWidth)  DecodePhaseI -= SignalBufferWidth;


            float y_delta  = level - signal_history[DecodePhaseY];
            float iq_delta = level - signal_history[DecodePhaseI];
            signal_history[signal_pos] = level;
            if (++signal_pos >= SignalBufferWidth)    signal_pos = 0;

            ysum += y_delta;
            isum += iq_delta * sin_table[DecodePhase + 3];
            qsum += iq_delta * sin_table[DecodePhase + 0];

        }

    
    }
}




template<typename T>
class SignalBuffer
{
    std::mutex      _mutex;
    std::vector<T>  _buffer;
    std::vector<T>  _buffer_read;
    std::vector<T> _fbuffer;
    
    std::condition_variable _cvar;
    
public:
    SignalBuffer()
    {
        _fbuffer.reserve(1024);
        _buffer.reserve(256  * 8);
        _buffer_read.reserve(256  * 8);
    }
    
    
    
    void Write(int dt, T value)
    {
        _fbuffer.insert(_fbuffer.end(), dt, value);
        
//        for (int i=0; i < dt; i++)
//        {
//            _fbuffer.push_back(value);
//        }
        
        if (_fbuffer.size() >= 512)
        {
            Flush();
        }
    }
    
    void Flush()
    {
        {
            std::lock_guard<std::mutex> lock(_mutex);
            _buffer.insert(_buffer.end(), _fbuffer.cbegin(), _fbuffer.cend());
            _fbuffer.clear();
        }
        
        _cvar.notify_all();
    }

    
    
    using ReadFunc = std::function<void (const T *, size_t)>;
    void StartReadThread(ReadFunc func)
    {
        std::thread t( [=]()
        {
            SetCurrentThreadName("raster-device");
            ReadThread(func);
        });
        
        t.detach();
    }
    

protected:
    
    void ReadThread(ReadFunc func)
    {

        for (;;)
        {
            {
                std::unique_lock<std::mutex> lock(_mutex);
                while (_buffer.empty())
                {
                    _cvar.wait(lock);
                }
                _buffer_read.swap(_buffer);
            }
            
            if (!_buffer_read.empty()) {
                func(_buffer_read.data(), _buffer_read.size());
                _buffer_read.clear();
            }
            
//            std::this_thread::sleep_for(std::chrono::milliseconds(5));
        }
    }

    
};




class buffer_raster_device : public raster_device
{
public:
    
    

    virtual void Flush() override
    {
        _signal.Flush();
    }
    
    virtual void Write(int dt, float signal) override
    {
        _signal.Write(dt, signal);
    }
    
    virtual void onGui(render::ContextPtr context) override;
    
    
    
    void clearBuffer(uint32_t color)
    {
        for (int y=0; y < _ppuImage->height; y++)
        {
            auto *row = _ppuImage->Row<uint32_t>(y);
            for (int x=0; x < _ppuImage->width; x++)
            {
                row[x] = 0x00808000;
            }
        }
    }
    
    
    virtual void saveImage(std::string path) override
    {
    //    stbi_write_force_png_filter = 0;
    //    stbi_write_png_compression_level = 1;
        
        // TODO: this needs to be thread safe
        /*
        if (_context)
        _context->GetImageDataAsync( _ppuTextureOut, [=](render::ImageDataPtr image)
        {
            if (stbi_write_png( path.c_str(), image->width, image->height, 4,
                               image->data, (int)image->pitch ) != 0)
            {
                //
                printf("Image saved to: '%s'\n", path.c_str());
            } else {
                printf("ERROR saving image to: '%s'\n", path.c_str());
            }
        });
        
        */
//        if (stbi_write_png( path.c_str(), _ppuImage->width, _ppuImage->height, 4,
//                              _ppuImage->data, (int)_ppuImage->pitch ) != 0)
//        {
//            //
//        }


    }
    
    virtual void saveState(state_writer &sw) override
    {
        std::lock_guard<std::mutex> lock(_mutex);
        serialize_object(sw, "ntsc-decoder", &_decoder);
    }
    
    
    
    virtual void loadState(state_reader &sr) override
    {
        std::lock_guard<std::mutex> lock(_mutex);
        serialize_object(sr, "ntsc-decoder", &_decoder);
    }
    
    buffer_raster_device()
    {
        _ppuImage = std::make_shared<render::ImageData>( 341 * 8, 262, render::PixelFormat::RGBA8Unorm);
       
        clearBuffer(0x00808000);
        
        _signal.StartReadThread( [this](const float *data, size_t size) {
            
            std::lock_guard<std::mutex> lock(_mutex);
            _decoder.FilterSignal(data, (int)size, _ppuImage );
            
        });
        
    }
    
protected:
    int _hpos = 0;
    int _line = 0;
    
    bool _window_open = true;

    
    std::mutex _mutex;
    SignalBuffer<float> _signal;

    ntsc_decoder _decoder;

    render::ContextPtr _context;
    render::ImageDataPtr _ppuImage;
    render::TexturePtr _ppuTexture;
    render::TexturePtr _ppuTextureOut;
    render::ShaderPtr _ntscShader;
};


static void DrawRect(
              render::ContextPtr context,
              float x0, float y0, float x1, float y1,
              float s0, float t0, float s1, float t1)
{
    
    render::Vertex        v[4];
    
    float z = 0.0f;
    
    for (int i = 0; i < 4; i++)
    {
        v[i].color = { 1,1,1,1 };
    }
    
    v[0].position = { x0, y0, z, 1.0f };
    v[1].position = { x1, y0, z, 1.0f };
    v[2].position = { x0, y1, z, 1.0f };
    v[3].position = { x1, y1, z, 1.0f };
    
    v[0].texcoord0 = { s0, t0};
    v[1].texcoord0 = { s1, t0};
    v[2].texcoord0 = { s0, t1};
    v[3].texcoord0 = { s1, t1};
    
    v[0].texcoord1 =
    v[1].texcoord1 =
    v[2].texcoord1 =
    v[3].texcoord1 = {0, 0};
    
    context->DrawArrays(render::PRIMTYPE_TRIANGLESTRIP, 4, v);
}


void buffer_raster_device::onGui(render::ContextPtr context)
{
    ImGuiWindowFlags window_flags = ImGuiWindowFlags_NoScrollbar;
    //  ImGui::SetNextWindowPos(ImVec2(0,0)); //, ImGuiCond_Always);
//        ImGui::SetNextWindowContentSize(ImVec2(256*2,224*2)); //, ImGuiCond_Always);
    
//    ImGui::SetNextWindowSize(ImVec2(256*3,256*3), ImGuiCond_Once); //, ImGuiCond_Always);
    
    
//    ImVec2 image_size(  _ppuImage->width / 8, _ppuImage->height);
    
//    ImGui::SetNextWindowSizeConstraints(ImVec2(256, 256),
//                                        ImVec2(FLT_MAX, FLT_MAX),
//                                        KeepAspectRatio
//                                        );
//

    if (!_window_open) return;
    
    if (!ImGui::Begin( "raster_device", &_window_open, window_flags))
    {
        ImGui::End();
        return;
    }
    

    
    /*
     ImGui::PushItemWidth(64);
     
     
     ImGui::InputInt("SignalBufferWidth", &decoder.SignalBufferWidth);
     ImGui::InputInt("ColorPhase", &decoder.ColorPhase);
     ImGui::InputInt("YTuningQuality", &decoder.YTuningQuality);
     ImGui::InputInt("IQTuningQuality", &decoder.IQTuningQuality);
     
     ImGui::PopItemWidth();
     */
    
    _context = context;
    
    if (!_ppuTexture)
    {
        _ppuTexture = _context->CreateTexture("raster-device", _ppuImage->width, _ppuImage->height, _ppuImage->format, _ppuImage->data );
        
    }
    
    if (!_ppuTextureOut)
    {
        _ppuTextureOut = _context->CreateRenderTarget("raster-device-out", _ppuImage->width / 2, _ppuImage->height * 4, render::PixelFormat::RGBA8Unorm);
        
    }
    
    //
    
    _context->UploadTextureData(_ppuTexture,
                                _ppuImage->data,
                                _ppuImage->width,
                                _ppuImage->height,
                                (int)_ppuImage->pitch
                                
                                );
    
    
    
    
    
    if (!_ntscShader) {
        _ntscShader = _context->LoadShaderFromFile("data/shaders/NTSCShader.fx");
    }
    
    _context->SetRenderTarget(_ppuTextureOut, "raster-device-out", render::LoadAction::Clear, Color4F(0.0,0.0,0.0,1));
    _context->SetBlendDisable();
    _context->SetShader(_ntscShader);
    _context->SetTransform( Matrix44::Identity() );
    
    
    _ntscShader->SetSampler(0, _ppuTexture, render::SAMPLER_CLAMP, render::SAMPLER_POINT);
    _context->SetTransform( Matrix44::Identity() );
    DrawRect( _context, -1,1,1,-1, 0,0,1,1 );
    
    //    _context->SetWriteMask( ColorWriteMaskRed | ColorWriteMaskGreen | ColorWriteMaskBlue );
    
    ImVec2 sz = ImGui::GetContentRegionAvail();
    
    float header_height = 32;

    ImGui::PlotLines("",  _decoder.line_signal.data(), (int)_decoder.line_signal.size(), 0, "", 0.0f, 1.5f, ImVec2(sz.x, header_height),  sizeof(float) );
    sz.y -= header_height;
    
    
    
    float sw = sz.x * 256.0 / 341.0f;
    float sh = sw * 262.0f / 256.0f;

    ImVec2 out_size(sz.x, sh) ;
    
    ImGui::Image(_ppuTextureOut.get(), out_size);
    
    if (ImGui::IsItemHovered()) // || ImGui::IsItemFocused())
    {
        auto p2 = ImGui::GetMousePos();
        
        ImVec2 p0 = ImGui::GetCursorScreenPos();
        
        
        int line = (p2.y - p0.y) *  _ppuTextureOut->GetHeight() / sz.y;
        _line = line;
        
        _hpos = (p2.x - p0.x) * _ppuTextureOut->GetWidth() / sz.x;
        
        //   ImGui::SetMouseCursor(i);
    }
    
    ImGui::End();

}

raster_device_ptr raster_device_create()
{
    return std::make_shared<buffer_raster_device>();
}

}
