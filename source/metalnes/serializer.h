
#pragma once

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdarg.h>
#include <functional>

#include "Core/Log.h"
#include <vector>

#define RAPIDJSON_HAS_STDSTRING 1
#include "../../external/rapidjson/include/rapidjson/writer.h"
#include "../../external/rapidjson/include/rapidjson/prettywriter.h"
#include "../../external/rapidjson/include/rapidjson/stringbuffer.h"
#include "../../external/rapidjson/include/rapidjson/rapidjson.h"
#include "../../external/rapidjson/include/rapidjson/reader.h"
#include "../../external/rapidjson/include/rapidjson/document.h"


namespace metalnes {

using  state_writer =  rapidjson::PrettyWriter<rapidjson::StringBuffer>;
using  state_reader =  const rapidjson::Document::ValueType;

//class state_serializable
//{
//public:
//    virtual void saveState(state_writer &sw) = 0;
//    virtual void loadState(state_reader &sr) = 0;
//};


bool readJsonFromFile(std::string path, std::function<void (state_reader &sr)> callback);
bool writeJsonToFile(std::string path, std::function<void (state_writer &sw)> callback);



void serialize_large_string(state_writer &writer, const std::string_view &str);
void deserialize_large_string(state_reader &sr, std::string &str);



//
// writing
//

template<typename T>
void serialize(state_writer &sw, const T &value);


template<typename T>
void serialize(state_writer &sw, const char *name, const T &value)
{
    sw.Key(name);
    serialize(sw, value);
}




template<typename T>
void serialize_object(state_writer &sw, const char *name, T o)
{
    sw.Key(name);
    sw.StartObject();
    o->saveState(sw);
    sw.EndObject();
}




template<>
inline void serialize(state_writer &sw, const bool &value)
{
    sw.Bool(value);
}

template<>
inline void serialize(state_writer &sw, const int &value)
{
    sw.Int(value);
}

template<>
inline void serialize(state_writer &sw, const float &value)
{
    sw.Double(value);
}


template<>
inline void serialize(state_writer &sw, const double &value)
{
    sw.Double(value);
}

template<>
inline void serialize(state_writer &sw, const std::string_view &value)
{
    sw.String(value.data(), (int)value.size());
}


template<>
void serialize(state_writer &sw, const std::vector<uint8_t> &binary);



//
// reader
//


template<typename T>
void serialize(state_reader &sr, T &value);

template<typename T>
void serialize(state_reader &sr, const char *name, T &value)
{
    assert(sr.HasMember(name));
    serialize( sr[name], value);
}

template<typename T>
void serialize_object(state_reader &sr, const char *name, T o)
{
    assert(sr.HasMember(name));
    o->loadState(sr[name]);
}



template<>
inline void serialize(state_reader &sr, bool &value)
{
    value = sr.GetBool();
}

template<>
inline void serialize(state_reader &sr, int &value)
{
    value = sr.GetInt();
}


template<>
inline void serialize(state_reader &sr, float &value)
{
    value = sr.GetFloat();
}

template<>
inline void serialize(state_reader &sr, double &value)
{
    value = sr.GetDouble();
}


template<>
inline void serialize(state_reader &sr, std::string &value)
{
    value = sr.GetString();
}


template<>
void serialize(state_reader &sr,  std::vector<uint8_t> &binary);





//
//


static inline uint32_t ComputeHash(uint32_t hash, uint32_t value)
{
    hash = (hash << 5) - hash;
    hash += (uint32_t)value;
    return hash;
}


static inline uint32_t ComputeHash(uint32_t hash, const uint8_t *v, size_t count)
{
    for (size_t i =0 ; i < count; i++)
    {
        hash = (hash << 5) - hash;
        hash += (uint32_t)v[i];
    }
    return hash;
}

static inline uint32_t ComputeHash(const uint8_t *v, size_t count)
{
    return ComputeHash(1, v, count);
}


static inline uint32_t ComputeHash(uint32_t hash, const std::vector<uint8_t> &v)
{
    return ComputeHash(hash, v.data(), v.size());
}


}

