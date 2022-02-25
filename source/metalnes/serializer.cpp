
#include <vector>
#include <assert.h>
#include "serializer.h"
#include "logger.h"
#include "Core/File.h"

namespace metalnes
{

bool readJsonFromFile(std::string path, std::function<void (state_reader &sr)> callback)
{
    std::string json;
    if (!Core::File::ReadAllText(path, json))
    {
        log_printf("ERROR: Could not read from file: %s\n", path.c_str());
        return false;
    }

    rapidjson::Document d;
    d.Parse(json.c_str());
    if (d.HasParseError())
    {
        log_printf("ERROR: could not parse JSON code:%d file:%s\n", d.GetParseError(), path.c_str());
        assert(0);
        return false;
    }
    
    callback(d);
    return true;
}

bool writeJsonToFile(std::string path, std::function<void (state_writer &sw)> callback)
{
    rapidjson::StringBuffer s;
    rapidjson::PrettyWriter<rapidjson::StringBuffer> writer(s);
    
    writer.StartObject();
    callback(writer);
    writer.EndObject();
    
    
//    printf("json:\n%s\n", s.GetString());

    
    if (!Core::File::WriteAllText(path, s.GetString(), s.GetLength() ))
    {
        log_printf("ERROR: Could not write to file: %s\n", path.c_str());
        return false;
    }
    return true;
}


static void EncodeBinary(const std::vector<uint8_t> &binary, std::string &text)
{
    const char *digits = "0123456789ABCDEF";
    
    text.clear();
    text.reserve(binary.size() * 2);
    for (uint8_t byte : binary)
    {
        text += digits[((byte >> 4) & 0xF)];
        text += digits[((byte >> 0) & 0xF)];
    }
}


static int HexToInt(char c)
{
    if (c >= '0' && c <= '9') return (int)(c - '0');
    if (c >= 'A' && c <= 'F') return (int)(c - 'A' + 10);
    if (c >= 'a' && c <= 'f') return (int)(c - 'a' + 10);
    assert(0);
    return 0;
}


static void DecodeBinary(const std::string_view &text,  std::vector<uint8_t> &binary)
{
    size_t count = binary.size();
    assert( text.size() == count * 2);
    
    for (size_t i=0; i < count; i++)
    {
        char d1 = text[i * 2 + 0];
        char d0 = text[i * 2 + 1];
        
        int byte = (HexToInt(d1) << 4)  | HexToInt(d0);
        binary[i] = (uint8_t)byte;
    }
    
}




void serialize_large_string(state_writer &writer, const std::string_view &str)
{
    constexpr size_t lineChars = 128;
    size_t pos = 0;
    size_t size = str.size();
    
    writer.StartArray();
    while (pos < size)
    {
        size_t count = size - pos;
        count = std::min(count, lineChars);
        
        const std::string_view line = str.substr(pos, count);
        writer.String(line.data(), (int)line.size());
        
        pos += count;
    }
    writer.EndArray();
}


void deserialize_large_string(state_reader &sr, std::string &str)
{
    str.clear();
    
    if (sr.IsString())
    {
        // single string
        str = sr.GetString();
        return;
    }
    
    if (sr.IsArray())
    {
        // array of strings...
        for (const auto &child : sr.GetArray())
        {
            if (child.IsString())
            {
                int count = child.GetStringLength();
                const char *ptr = child.GetString();
                str.append(ptr, (size_t)count);
            }
        }
    }
}



template<>
void serialize(state_writer &sw, const std::vector<uint8_t> &binary)
{
    std::string text;
    EncodeBinary(binary, text);
    serialize_large_string(sw, text);
}


template<>
void serialize(state_reader &sr,  std::vector<uint8_t> &binary)
{
    std::string text;
    deserialize_large_string(sr, text);
    DecodeBinary(text, binary);
}



}


