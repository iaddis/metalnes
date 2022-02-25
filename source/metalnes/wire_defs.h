#pragma once
#include <stdint.h>
#include <string>
#include <vector>
#include <unordered_map>
#include <functional>
#include <memory>

namespace metalnes {

//using nodeID = uint16_t;
//using transistorID = uint16_t;
//constexpr nodeID EMPTYNODE = 65535;
using nodeID = int32_t;
using transistorID = int32_t;

constexpr nodeID EMPTYNODE = -1;
constexpr nodeID npwr = 1;
constexpr nodeID ngnd = 2;


static inline bool is_pwr_gnd(nodeID nn) {
    return nn == ngnd || nn == npwr;
}



struct wire_defs;
using wire_defs_ptr = std::shared_ptr<wire_defs>;

enum Layer
{
    Metal,
    SwitchedDiffusion,
    InputDiode,
    GroundedDiffusion,
    PoweredDiffusion,
    PolySilicon
};


struct point
{
    float x, y;
};

static inline bool operator==(const point &a, const point &b)
{
    return (a.x == b.x) &&  (a.y == b.y);
}

static inline point operator-(const point &a, const point &b)
{
    return point{a.x - b.x, a.y - b.y};
}

struct rect
{
    point min;
    point max;
};

static inline void bbox_reset(rect &bb)
{
    bb = rect{
       {
           std::numeric_limits<float>::max(),
           std::numeric_limits<float>::max()
       },
       {
           std::numeric_limits<float>::min(),
           std::numeric_limits<float>::min()
       }
   };
}

static inline void bbox_append(rect &bb, const point &p)
{
    bb.min.x  = std::min(bb.min.x, p.x);
    bb.min.y  = std::min(bb.min.y, p.y);
    bb.max.x  = std::max(bb.max.x, p.x);
    bb.max.y  = std::max(bb.max.y, p.y);
}

static inline void bbox_append(rect &bb, const rect &r)
{
    bbox_append(bb, r.min);
    bbox_append(bb, r.max);
}


static inline bool bbox_contains(const rect &bb, const point &p)
{
    return p.x >= bb.min.x && p.x <= bb.max.x &&
           p.y >= bb.min.y && p.y <= bb.max.y;
}
static inline bool bbox_intersect(const rect &b0, const rect &b1)
{
    if ((b0.min.x > b1.max.x) || (b0.min.y > b1.max.y) ||
        (b0.max.x < b1.min.x) || (b0.max.y < b1.min.y))
    {
        return false;
    }
    return true;
}


// a noderef is *either* a string or an id
struct noderef
{
    std::string node_name;
    nodeID      node_id = 0;
};



struct nodedef
{
    std::string name;
    nodeID      node_id;
};

struct transdef
{
    std::string name;
    noderef gate;
    noderef c1;
    noderef c2;
    rect bb = { {0,0}, {0,0} };
    
    int width1 = 0;
    int width2 = 0;
    int height = 0;
    int num_segments = 0;
    int area = 0;
    
    bool unknown_2 = false;
};

struct segdef
{
    noderef nn;
    std::string pullup;
    int layer;
    std::vector<point> points;
};


struct pindef
{
    int         pin;            // index
    std::string name;           // name
};

struct moduledef
{
    std::string prefix;
    std::string type;
    wire_defs_ptr  defs = nullptr;
};


struct memorydef
{
    std::string          name;
    int                  size;
};

struct connection
{
    noderef from;
    noderef to;
};


struct wire_defs
{
    std::string path;
    std::string type;
    std::string description;
    nodeID      maxNodeID = 0;
    std::vector<nodedef> nodedefs;
    std::vector<segdef> segdefs;
    std::vector<transdef> transdefs;
    std::vector<pindef> pindefs;
    std::vector<moduledef> modules;
    std::vector<connection> connections;
    std::vector<std::string> forceCompute;
    std::vector<std::string> pullups;
    std::vector<memorydef> memorydefs;

    std::vector<std::string> transdefs_files;
    std::vector<std::string> nodenames_files;
    std::vector<std::string> segdefs_files;
    
    std::unordered_map<std::string, nodeID> map;
    std::unordered_map<nodeID, std::string> unmap;

    nodeID findNode(const std::string &name) const;
    
    void addInstance(wire_defs_ptr defs, std::string prefix);
    void addInstance(std::string dir, std::string name, std::string prefix);
    
    static wire_defs_ptr Load(std::string dir, std::string name);

};


std::string combinePrefix(const std::string &prefix, const std::string &name);

}
