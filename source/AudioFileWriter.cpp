
#include "AudioFileWriter.h"
#include <vector>
#include "Core/File.h"

static void write8(std::vector<uint8_t> &data, uint8_t v)
{
    data.push_back(v);
}

static void write16(std::vector<uint8_t> &data, uint16_t v)
{
    write8(data, (uint8_t)(v >> 0));
    write8(data, (uint8_t)(v >> 8));
}

static void write32(std::vector<uint8_t> &data, uint32_t v)
{
    write8(data, (uint8_t)(v >> 0));
    write8(data, (uint8_t)(v >> 8));
    write8(data, (uint8_t)(v >> 16));
    write8(data, (uint8_t)(v >> 24));
}

static void writeFloat(std::vector<uint8_t> &data, float f)
{
    union {
        float f;
        uint8_t d[4];
    } u;
    
    u.f = f;
    write8(data, u.d[0]);
    write8(data, u.d[1]);
    write8(data, u.d[2]);
    write8(data, u.d[3]);
}

static void writeTag(std::vector<uint8_t> &data, const char *tag)
{
    write8(data, (uint8_t)(tag[0]));
    write8(data, (uint8_t)(tag[1]));
    write8(data, (uint8_t)(tag[2]));
    write8(data, (uint8_t)(tag[3]));
}

#if 0
bool AudioSaveToFile(std::string path, double sample_rate, const float *sample_data, size_t sample_count)
{
    std::vector<uint8_t> data;
    
    using wave_sample = int16_t;
    
    const int header_size = 0x2C;
    int chan_count = 1;
    
    // generate header
    int rate = (int)sample_rate;

    int frame_size = chan_count * sizeof (wave_sample);

    int ds = (int)(sample_count * frame_size);
    int rs = (int)(header_size - 8 + ds);
    int bytes_per_second = rate * frame_size;
    int bits_per_sample = sizeof(wave_sample) * 8;
    int format = 1;

    
    writeTag(data, "RIFF");
    write32(data, rs);
    writeTag(data, "WAVE");
    writeTag(data, "fmt ");
    
    write32(data, 0x10);
    write16(data, format);
    write16(data, chan_count);
    write32(data, rate);
    write32(data, bytes_per_second);
    write16(data, frame_size);
    write16(data, bits_per_sample);
    writeTag(data, "data");
    write32(data, ds);
    
    
    float scale = 1.0f;
    for (size_t i=0; i < sample_count; i++)
    {
        int s = (int)(sample_data[i] * scale * 0x7FFF);
        s = std::clamp(s, (int)std::numeric_limits<int16_t>::min(),  (int)std::numeric_limits<int16_t>::max() );
        for (int i=0; i < chan_count; i++)
            write16(data, s);
    }
    
    return Core::File::WriteAllBytes(path, data);
}
#else

bool AudioSaveToFile(std::string path, double sample_rate, const float *sample_data, size_t sample_count)
{
    std::vector<uint8_t> data;
    
    using wave_sample = float;
    
    const int header_size = 0x2C;
    int chan_count = 1;
    
    // generate header
    int rate = (int)sample_rate;
    int frame_size = chan_count * sizeof (wave_sample);
    int ds = (int)(sample_count * frame_size);
    int rs = (int)(header_size - 8 + ds);
    int bytes_per_second = rate * frame_size;
    int bits_per_sample = sizeof(wave_sample) * 8;
    int format = 3;     // 1-PCM, 3-float

    
    writeTag(data, "RIFF");
    write32(data, rs);
    writeTag(data, "WAVE");
    writeTag(data, "fmt ");
    
    write32(data, 0x10);
    write16(data, format);
    write16(data, chan_count);
    write32(data, rate);
    write32(data, bytes_per_second);
    write16(data, frame_size);
    write16(data, bits_per_sample);
    writeTag(data, "data");
    write32(data, ds);
    
    
    float scale = 1.0f;
    for (size_t i=0; i < sample_count; i++)
    {
        float s = (sample_data[i] * scale);
        for (int i=0; i < chan_count; i++)
            writeFloat(data, s );
    }
    
    return Core::File::WriteAllBytes(path, data);
}
#endif
