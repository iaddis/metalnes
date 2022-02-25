#include "wire_defs.h"
#include <memory.h>
#include "Core/File.h"
#include "Core/Path.h"
#include "Core/JsonParser.h"


using namespace Core;


namespace metalnes {



template<typename T>
void deserialize(T &c, JsonParser::ValueReader &reader);


template<typename T>
void deserialize_key(T &c, JsonParser::ObjectReader &reader);



// deserialize >> operator
template <typename T>
JsonParser::ValueReader &operator >>(JsonParser::ValueReader &reader, T &value)
{
    deserialize( value, reader );
    return reader;
}



template<typename T>
T deserialize(JsonParser::ValueReader &reader)
{
    T o;
    deserialize(o, reader);
    return std::move(o);
}

template<>
void deserialize(bool &value, JsonParser::ValueReader &reader)
{
    reader.ReadBoolean(value);
}


template<>
void deserialize(int &value, JsonParser::ValueReader &reader)
{
    reader.ReadNumber(value);
}

template<>
void deserialize(float &value, JsonParser::ValueReader &reader)
{
    reader.ReadNumber(value);
}



template<>
void deserialize(double &value, JsonParser::ValueReader &reader)
{
    reader.ReadNumber(value);
}

template<>
void deserialize(std::string &str, JsonParser::ValueReader &reader)
{
    reader.ReadString(str);
}



template<>
void deserialize(noderef &ref, JsonParser::ValueReader &reader)
{
    if (reader.IsNumber())
    {
        reader.ReadNumber(ref.node_id);
    }
    else if (reader.IsString())
    {
        reader.ReadString(ref.node_name);
    }
    else
    {
        assert(0);
    }
}



template<typename T>
void deserialize_vector(std::vector<T> &list, JsonParser::ValueReader &reader)
{
    reader.ReadArray([&list](JsonParser::ArrayReader &ar) {
        while(!ar.End())
        {
            T o = deserialize<T>(ar);
            list.push_back( std::move(o) );
        }
    });
}


template<typename T>
std::vector<T> deserialize_vector(JsonParser::ValueReader &reader)
{
    std::vector<T> list;
    deserialize_vector(list, reader);
    return list;
}



template<typename T>
void deserialize_object(std::unordered_map< std::string, T> &map, JsonParser::ValueReader &reader)
{
    reader.ReadObject([&map](JsonParser::ObjectReader &ar) {
        while(!ar.End())
        {
            std::string key = ar.Key();
            
            T o;
            deserialize(o, ar);
            map.insert( std::make_pair(key, o ));
//            map[key] = o;
        }
    });
}


template<typename T>
void deserialize_object(std::vector<T> &v, JsonParser::ValueReader &reader)
{
    reader.ReadObject([&v](JsonParser::ObjectReader &objreader) {
        while(!objreader.End())
        {
//            std::string key = ar.Key();
            
            T o;
            deserialize_key(o, objreader);
            v.push_back(o);
//            map.insert( std::make_pair(key, o ));
//            map[key] = o;
        }
    });
}




template<>
void deserialize(connection &c, JsonParser::ValueReader &reader)
{
    reader.ReadArray([&c](JsonParser::ArrayReader &ar) {
        ar >> c.from >> c.to;
    });
}

template<>
void deserialize_key(nodedef &nd, JsonParser::ObjectReader &reader)
{
    nd.name = reader.Key();
    reader.ReadNumber(nd.node_id);
}




template<>
void deserialize(rect &bb, JsonParser::ValueReader &reader)
{
    reader.ReadArray([&bb](JsonParser::ArrayReader &ar) {
        ar >> bb.min.x >> bb.max.x >> bb.min.y >> bb.max.y;
    });
}



template<>
void deserialize(transdef &def, JsonParser::ValueReader &reader)
{
    reader.ReadArray([&def](JsonParser::ArrayReader &ar) {
        
        ar >> def.name >> def.gate >> def.c1 >> def.c2;

        if (ar.IsArray())
        {
            ar >> def.bb;
        }

        if (ar.IsArray())
        {
            ar.ReadArray([&def](JsonParser::ArrayReader &ar2) {
                ar2 >> def.width1 >> def.width2 >> def.height >> def.num_segments >> def.area;
            });
        }

        if (ar.IsBoolean())
        {
            ar >> def.unknown_2;
        }
    });
}



template<>
void deserialize(segdef &sd, JsonParser::ValueReader &reader)
{
    reader.ReadArray([&sd](JsonParser::ArrayReader &ar) {
        
        ar >> sd.nn >> sd.pullup >> sd.layer;
        
        while (!ar.End())
        {
            point p;
            ar >> p.x >> p.y;
            sd.points.push_back(p);
        }
    });

}

template<>
void deserialize(pindef &pd, JsonParser::ValueReader &reader)
{
    reader.ReadArray([&pd](JsonParser::ArrayReader &ar) {
        ar >> pd.pin >> pd.name;
    });

}


template<>
void deserialize(moduledef &md, JsonParser::ValueReader &reader)
{
    reader.ReadArray([&md](JsonParser::ArrayReader &ar) {
        ar >> md.prefix >> md.type;
        ar.ReadInteger();
    });
    
    
    assert(!md.prefix.empty());
    assert(md.prefix.back() != '\'');

}

template<>
void deserialize_key(memorydef &md, JsonParser::ObjectReader &reader)
{
    md.name = reader.Key();
    md.size = reader.ReadInteger();
}

template<>
void deserialize_key(wire_defs &defs, JsonParser::ObjectReader &reader)
{
    while(!reader.End())
    {
        std::string key = reader.Key();
        
        if (key == "name") {
            deserialize(defs.type, reader);
        } else if (key == "description") {
            deserialize(defs.description, reader);
        } else if (key == "pins") {
            deserialize_vector(defs.pindefs, reader);
        } else if (key == "modules") {
            deserialize_vector(defs.modules, reader);
        } else if (key == "nodenames") {
            deserialize_object(defs.nodedefs, reader);
        } else if (key == "transdefs") {
            deserialize_vector(defs.transdefs, reader);
        } else if (key == "segdefs") {
            deserialize_vector(defs.segdefs, reader);
        } else if (key == "connections") {
            deserialize_vector(defs.connections, reader);
        } else if (key == "forceCompute") {
            deserialize_vector(defs.forceCompute, reader);
        } else if (key == "pullups") {
            deserialize_vector(defs.pullups, reader);
        } else if (key == "memory") {
            deserialize_object(defs.memorydefs, reader);
        } else if (key == "nodenames_files") {
            deserialize_vector(defs.nodenames_files, reader);
        } else if (key == "transdefs_files") {
            deserialize_vector(defs.transdefs_files, reader);
        } else if (key == "segdefs_files") {
            deserialize_vector(defs.segdefs_files, reader);
        } else {
            printf("Unrecognized key %s\n", key.c_str());
            assert(0);
            reader.SkipValue();
        }
    }

}

bool loadJsonFile(std::string path, std::string varname, std::function<void (JsonTokenizer &)> callback)
{
    std::string text;
    if (!Core::File::ReadAllText(path, text))
    {
        printf("Could not load file %s\n", path.c_str());
        return false;
    }
    
    JsonTokenizer tr(text, path);
    
    std::string s1 = tr.ReadString();
    std::string s2 = tr.ReadString();
    if (s1 != "var" || s2 != varname) {
        return false;
    }
    tr.Consume( JsonToken::EQUALS );
    
    if (!tr.HasError())
    {
        callback(tr);
    }
    
    if (tr.HasError())
    {
        printf("JSON parse error: %s\n", tr.GetErrorMessage().c_str()  );
    }
    return !tr.HasError();
}


template<typename T>
bool loadJsonVector(std::vector<T> &list, std::string filename, std::string varname)
{
    return loadJsonFile(filename, varname, [&list](JsonTokenizer &tr) {
        JsonParser::ValueReader reader(tr);
        deserialize_vector(list, reader);
    });
}

template<typename T>
bool loadJsonObject(std::vector<T> &list, std::string filename, std::string varname)
{
    return loadJsonFile(filename, varname, [&list](JsonTokenizer &tr) {
        JsonParser::ValueReader reader(tr);
        deserialize_object(list, reader);
    });
}

static bool loadModuleDefinitionJson(wire_defs_ptr defs, std::string filename)
{
    return loadJsonFile(filename, "module", [&defs](JsonTokenizer &tr) {
        JsonParser::ObjectReader reader(tr);
        deserialize_key(*defs, reader);
    });
}


static bool loadExternalFiles(wire_defs_ptr defs)
{
    std::string dirname = Core::Path::GetDirectory(defs->path);

    for (auto filename : defs->nodenames_files)
    {
        std::string path = Core::Path::Combine(dirname, filename);
        if (!loadJsonObject(defs->nodedefs, path, "nodenames")) {
            printf("Could not load %s\n", path.c_str());
            return false;
        }
    }
    
    for (auto filename : defs->transdefs_files)
    {
        std::string path = Core::Path::Combine(dirname, filename);
        if (!loadJsonVector(defs->transdefs, path, "transdefs")) {
            printf("Could not load %s\n", path.c_str());
            return false;
        }
    }
    
    for (auto filename : defs->segdefs_files)
    {
        std::string path = Core::Path::Combine(dirname, filename);
        if (!loadJsonVector(defs->segdefs, path, "segdefs")) {
            printf("Could not load segment definitions from %s\n", path.c_str());
            return false;
        }
    }

    return true;
}


nodeID wire_defs::findNode(const std::string &name) const
{
    for (auto &nd : nodedefs)
    {
        if (nd.name == name)
            return nd.node_id;
    }
    return EMPTYNODE;
}





static int find_max_node(wire_defs_ptr defs)
{
    int maxNodeId = 0;
    
    for (const auto &nd : defs->nodedefs)
    {
        maxNodeId = std::max(nd.node_id, maxNodeId);
    }

    
    for (const auto &sd : defs->segdefs)
    {
        maxNodeId = std::max(sd.nn.node_id, maxNodeId);
    }

    for (const auto &td : defs->transdefs)
    {
        maxNodeId = std::max(td.gate.node_id, maxNodeId);
        maxNodeId = std::max(td.c1.node_id, maxNodeId);
        maxNodeId = std::max(td.c2.node_id, maxNodeId);
    }

    return maxNodeId;
}

void wire_defs::addInstance(wire_defs_ptr defs, std::string prefix)
{
    moduledef md;
    md.prefix  = prefix;
    md.type = defs->type;
    md.defs = defs;
    modules.push_back(md);
}

void wire_defs::addInstance(std::string dir, std::string type, std::string prefix)
{
    moduledef md;
    md.prefix  = prefix;
    md.type = type;
    md.defs = wire_defs::Load(dir, type);
    modules.push_back(md);
}

static std::string quote(const std::string &s)
{
    std::string quoted;
    quoted+= '\'';
    quoted+= s;
    quoted+= '\'';
    return quoted;
}

void dump_namecomma(const std::string &str, int width = 16)
{
    printf("%s,", str.c_str());
    for (size_t i=str.size(); i < width; i++)
    {
        printf(" ");
    }

}

void dump_nodename(wire_defs_ptr defs, nodeID nn)
{
    std::string name = defs->unmap[nn];
    auto gate = !name.empty() ? quote(name) : std::to_string(nn);
    dump_namecomma(gate, 24);
}

void dump_transistors(wire_defs_ptr defs)
{
    printf("var transdefs = [\n");
    for (auto &td : defs->transdefs)
    {
        auto name = quote(td.name);
        
        printf("[");
        dump_namecomma(name);
        dump_nodename(defs, td.gate.node_id);
        dump_nodename(defs, td.c1.node_id);
        dump_nodename(defs, td.c2.node_id);
        printf("[%.f,%.f,%.f,%.f]", td.bb.min.x, td.bb.max.x, td.bb.min.y, td.bb.max.y      );
        printf(",");
        printf("[%d,%d,%d,%d,%d]", td.width1, td.width2, td.height, td.num_segments, td.area );
        printf(",");
        printf("%s", td.unknown_2 ? "true" : "false"   );
        printf("],");
        
        
        printf("\n");

    }
    printf("];\n");

}

void dump_segdefs(wire_defs_ptr defs)
{
    printf("var segdefs = [\n");
    for (auto &sd : defs->segdefs)
    {
        printf("[");
        dump_nodename(defs, sd.nn.node_id);
        printf("'+', 0");
        
        printf("],");
        printf("\n");
    }
    printf("];\n");
}

std::string combinePrefix(const std::string &prefix, const std::string &name)
{
    if (prefix.empty())
    {
        return name;
    }

    if (name.empty())
    {
        return prefix;
    }

    if (prefix.back() == '.')
    {
        return prefix + name;
    }
    
    // insert '.' between prefix and name
    return prefix + '.' + name;
}


wire_defs_ptr wire_defs::Load(std::string dir, std::string name)
{
    std::string path = Core::Path::Combine(dir, name) + ".js";
    
    wire_defs_ptr defs = std::make_shared<wire_defs>();
    defs->path = path;
    
    if (!loadModuleDefinitionJson(defs, path))
    {
        assert(0);
        return nullptr;
    }
    
    if (!loadExternalFiles(defs))
    {
        assert(0);
        return nullptr;
    }
    
    defs->maxNodeID = find_max_node(defs);
    
    // build maps
    for (const auto &nd : defs->nodedefs)
    {
        defs->map[nd.name] = nd.node_id;
        if (defs->unmap.find(nd.node_id) == defs->unmap.end())
            defs->unmap[nd.node_id] = nd.name;
    }

    printf("Loaded definitions from '%s'\n", defs->path.c_str());

    // load submodules
    for (auto &module : defs->modules)
    {
        module.defs = wire_defs::Load(dir, module.type);
    }
    
    return defs;
}



}
