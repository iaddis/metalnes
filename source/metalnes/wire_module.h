#pragma once
#include "wire_defs.h"
#include "serializer.h"
#include "logger.h"

namespace metalnes {

class wire_module;
class wire_register;
class wire_memory;
class wire_instance;
struct wire_transistor;
struct wire_segment;

using wire_register_ptr = std::shared_ptr<wire_register>;
using wire_memory_ptr = std::shared_ptr<wire_memory>;
using wire_module_ptr = std::shared_ptr<wire_module>;
using wire_instance_ptr = std::shared_ptr<wire_instance>;
using wire_segment_ptr = std::shared_ptr<wire_segment>;
using wire_transistor_ptr = std::shared_ptr<wire_transistor>;


struct wire_transistor
{
    std::string name;
    nodeID gate;
    nodeID c1;
    nodeID c2;
    rect   bb;
    
    struct Hash {
      size_t operator()(const wire_transistor &t) const
        {
            return t.gate | (t.c1 <<8) | (t.c2 << 16);
        }
    };

};


inline bool operator ==(const wire_transistor &a, const wire_transistor &b)
{
    return a.gate == b.gate &&
    a.c1 == b.c1 &&
    a.c2 == b.c2;
}

struct wire_segment
{
    int         index;
    nodeID      node_id;
    bool        pullup;
    int         layer;
    rect        bb;
    int         area;
    std::vector<point> points;
    std::vector<int> triangle_list;
};



class wire_instance
{
public:
    std::weak_ptr<wire_module>   wires;
    std::string     name;
    std::string     type;
    std::string     label;
    wire_defs_ptr   defs;
    nodeID          node_start;
    nodeID          node_end;
    
    nodeID          node_gnd;
    nodeID          node_pwr;
    
    rect            bbox = {0};       // instance spatial bounding box
    
    std::weak_ptr<wire_instance>    parent;
    std::vector<wire_instance_ptr>  children;

    
    std::vector<nodeID>  pin_nodes;
    
    std::vector<wire_transistor> transistors;
    std::vector<wire_segment_ptr> segments;

};

class wire_memory
{
public:
    wire_memory() = default;
    virtual ~wire_memory() = default;
    wire_memory(const wire_memory &other) = delete;
    wire_memory& operator=(const wire_memory & rhs) = delete;

    virtual const std::string &getName() = 0;
    virtual size_t  getSize() = 0;
    virtual int  readByte(int address) = 0;
    virtual void writeByte(int address, int data) = 0;
    virtual bool writeBytes(size_t address, const uint8_t *ptr, size_t size) = 0;
    virtual void clear() = 0;
    virtual uint32_t computeHash() = 0;
    virtual const uint8_t *getDataPtr() = 0;
    
    virtual void saveState(state_writer &sw) = 0;
    virtual void loadState(const state_reader &sr) = 0;
};



class wire_module
{
public:
    wire_module() = default;
    virtual ~wire_module() = default;
    wire_module(const wire_module &other) = delete;
    wire_module& operator=(const wire_module & rhs) = delete;
    
    virtual const char *getName() const = 0;

    virtual wire_instance_ptr addInstance(wire_instance_ptr parent, wire_defs_ptr defs, std::string name) = 0;
    virtual wire_instance_ptr lookupInstance(const std::string &name) = 0;
    virtual std::vector<wire_instance_ptr> getAllInstances() = 0;

    
    virtual int getNodeCount() const = 0;
    virtual nodeID lookupNode(const std::string &name) = 0;
    virtual const char *getNodeName(nodeID nn) = 0;
    virtual bool isNodeHigh(nodeID nn) = 0;
    virtual int getNodeFlags(nodeID nn) = 0;

    virtual const std::vector<nodeID> &allNodes() = 0;

    virtual int  readBits(const std::vector<nodeID> &node_ids) = 0;
    virtual void writeBits(const std::vector<nodeID> &node_ids, int data) = 0;
    virtual void floatBits(const std::vector<nodeID> &node_ids) = 0;

    
    virtual wire_memory_ptr resolveMemory(const std::string &name) = 0;
    
    virtual void getNodeStates(std::vector<uint8_t> &state, int start, int count, uint8_t state_low, uint8_t state_high ) = 0;
    virtual uint32_t computeHash() = 0;

    virtual void setFloat(nodeID nn) = 0;
    virtual void setLow(nodeID nn) = 0;
    virtual void setHigh(nodeID nn) = 0;

    virtual void setTraceLevel(int level) = 0;
    virtual void resetState() = 0;
    virtual void recomputeAllNodes() = 0;
    
    virtual void saveState(state_writer &sw) = 0;
    virtual void loadState(state_reader &sr) = 0;
    
    
    virtual void dump() = 0;
    
    virtual void dumpNodeInfo(nodeID nn) = 0;
    

    virtual wire_register_ptr resolveRegister(const std::string &name) = 0;
    virtual void resolveNodes(const std::string &expr, std::vector<nodeID> &node_ids) = 0;


    virtual void add_callback(const std::vector<nodeID> &node_ids, std::function<void ()> callback ) = 0;

    virtual int  getTime() = 0;
    virtual void add_handler(std::function<void ()> callback) = 0;
    virtual void step(int count) = 0;
};




class wire_register
{
public:
    wire_register(wire_module_ptr wires, std::string name, std::vector<nodeID> nodes)
    :_wires(wires), _name(name), _nodes(nodes)
    {
        
    }
    
    virtual ~wire_register() = default;
    
    int getBitCount() const
    {
        return (int)_nodes.size();
    }
    
    
    const std::string &getName()  const
    {
        return _name;
    }
    
    int read()
    {
        return _wires->readBits(_nodes);
    }

    void write(int value)
    {
        _wires->writeBits(_nodes, value);
    }

    void floatBits()
    {
        _wires->floatBits(_nodes);
    }

    const auto &getNodes()  const
    {
        return _nodes;
    }

protected:
    wire_module_ptr _wires;
    std::string _name;
    std::vector<nodeID> _nodes;
};



wire_module_ptr WiresCreate();



}
