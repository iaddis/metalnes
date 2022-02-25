

#include "audio_device.h"
#include "imgui_support.h"

#include "Core/File.h"
#include "logger.h"
#include <cmath>
#include <thread>
#include <mutex>
#include "AudioFileWriter.h"

#ifdef __APPLE__
void AudioPlaySound(double sample_rate, const float *sample_data, size_t sample_count);
#endif

namespace metalnes {

class buffer_audio_device : public audio_device
{
public:

    struct SampleEntry
    {
        int     time;
        float   output;
    };

    
    double _sample_rate = 48000.0;
    double _clock_rate = 21.48 * 1000 * 1000 * 2.0;
    std::mutex _mutex;
    std::vector<float> _samples;
    std::vector<SampleEntry> _sample_list;
    
    
    buffer_audio_device()
    {
        
        
//        _sample_list.push_back( {0, 0.0f} );
        
    }
    virtual ~buffer_audio_device()
    {
        
    }
    
    virtual void saveState(state_writer &sw) override
    {
        std::lock_guard<std::mutex> lock(_mutex);
        
        sw.Key("samples");
        
        sw.StartArray();
        for (auto sample : _sample_list)
        {
            sw.StartArray();
            sw.Int(sample.time);
            sw.Double(sample.output);
            sw.EndArray();
        }
        sw.EndArray();
    }
    
    
    virtual void loadState(state_reader &sr)  override
    {
        {
            std::lock_guard<std::mutex> lock(_mutex);
            
            _sample_list.clear();
            _samples.clear();

            auto samples = sr["samples"].GetArray();

            for (const auto &it : samples)
            {
                auto array = it.GetArray();
                
                int time = array[0].GetInt();
                float output = array[1].GetDouble();
                _sample_list.push_back( {time, output});
            }
        }
        
        
        Flush();
    }
    
    
    virtual void Write(int time, float output) override
    {
        {
            std::lock_guard<std::mutex> lock(_mutex);
            _sample_list.push_back( {time, output} );
//        log_printf("sample time:%d output:%f\n", time, output);
        }
        
        Flush();
    }
    

    int _interpolate_last_pos = 0;
    float interpolateSample(int time)
    {
        int end = (int)_sample_list.size() - 1;
        
        int pos = _interpolate_last_pos;
        
        while (pos >= 0 && pos < end)
        {
            const auto &prev = _sample_list[pos];
            const auto &next = _sample_list[pos + 1];
            // find two samples for time
            if (time >= prev.time  && time < next.time)
            {
                float frac = (float)(time - prev.time) / (float)(next.time - prev.time);
                float o = frac * next.output + (1 - frac) * prev.output;
                
                _interpolate_last_pos = pos;
                return o;
            }

            // search for teh right sample
            if (time >= next.time) pos++; else pos--;
        }
        _interpolate_last_pos = pos;
        return 0;
    }
    
    
    virtual void Flush() override
    {
        std::lock_guard<std::mutex> lock(_mutex);
        
        if (_sample_list.empty())
            return;
        
        const auto &last = _sample_list.back();
        
        double time_seconds = ((double)last.time)  / _clock_rate;
        
        size_t sample_end = (size_t)(std::floor(time_seconds * _sample_rate));
        
        size_t sample_pos = _samples.size();
        while (sample_pos < sample_end)
        {
            int sample_time = (int)(sample_pos * _clock_rate / _sample_rate);
            float sample = interpolateSample(sample_time);
            _samples.push_back(sample);
            sample_pos++;
        }
        
    }
    
    virtual void saveAudio(std::string path) override
    {
        std::lock_guard<std::mutex> lock(_mutex);
        
        if (AudioSaveToFile(path, _sample_rate, _samples.data(), _samples.size() ))
        {
            log_printf("Saved audio to %s\n", path.c_str());
        } else {
            log_printf("ERROR: Could not save audio to %s\n", path.c_str());
        }
    }
    
    void PlayAudio()
    {
        std::lock_guard<std::mutex> lock(_mutex);
#ifdef __APPLE__
        AudioPlaySound( _sample_rate, _samples.data(), _samples.size() );
#endif
    }
    
    
    virtual void onGui(const std::string &state_path) override
    {
        ImGuiWindowFlags window_flags = 0;
        
        ImGui::SetNextWindowSizeConstraints(ImVec2(64, 256),
                                            ImVec2(FLT_MAX, FLT_MAX)
                                            );
    

        if (!ImGui::Begin( "audio_device", NULL, window_flags))
        {
            ImGui::End();
            return;
        }
        
        {
            if (ImGui::Button("Play"))
            {
                PlayAudio();
                
            }
            ImGui::SameLine();

            if (ImGui::Button("Save"))
            {
                std::string path = state_path + ".wav";
                saveAudio(path);
            }
        }
        
        ImGui::Separator();
        
        {


            ImGui::PushStyleColor(ImGuiCol_FrameBg, ImVec4(0.2f,.2f,0.2f,.2f));
            ImGui::PushStyleColor(ImGuiCol_FrameBgHovered, ImVec4(0.2f,.2f,0.2f,.2f));

            ImGui::PushStyleColor(ImGuiCol_PlotHistogram, ImVec4(0.2f,1.0f,0.2f,1.0f));


            ImVec2 sz = ImGui::GetContentRegionAvail();

//            float h = 120;
//                        std::string buffer = StringFormat("%.fhz %.1fms", m_samples.GetSampleRate(), m_dt * 1000.0f);
            {
                std::lock_guard<std::mutex> lock(_mutex);

                ImGui::PlotHistogram("",
                             _samples.data(),
                              (int)_samples.size(), 0,
                              "", // buffer.c_str(),
                              -1.0f, 1.0f,
                              ImVec2(sz.x, sz.y),
                             sizeof(_samples[0])
                            );
            }
            
            ImGui::PopStyleColor();

            ImGui::SameLine();

            ImGui::PopStyleColor(2);
        }

        
        
        ImGui::End();

    }
};

audio_device_ptr audio_device_create()
{
    return std::make_shared<buffer_audio_device>();
}

}
