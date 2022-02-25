
#include "wire_defs.h"
#include "wire_module.h"
#include "logger.h"
#include <iostream>
#include <unordered_set>
#include <map>
#include <sstream>
#include <mutex>
#include <thread>
#include <condition_variable>
#include "Core/String.h"
#include "imgui_support.h"
#include "wire_node_resolver.h"
#include "triangulate.h"


namespace metalnes {


enum node_flags
{
    node_state    = (1 << 0),
    node_pull_up  = (1 << 1),
    node_set_high   = (1 << 2),
    node_set_low = (1 << 3),
    node_pwr = (1 << 4),
    node_gnd = (1 << 5),
    node_forcecompute = (1 << 6),
    node_has_callback = (1 << 7),
};


using node_value = uint8_t;


struct nodeinfo
{
    uint8_t flags = 0;
    int connections = 0;
//    bool    state = false;
//    bool    in_group = false;
    
//    int _group_count = 0;
    int _tlist_gates;
    int _tlist_c1c2s;
    int _tlist_c1gnd;
    int _tlist_c1pwr;


    node_flags get_flags() const {
        return (node_flags)flags;
    }

//    bool get_state() const {
//        return state;
//    }
//
//
//    void set_state(bool new_state) {
//        state = new_state;
//    }
//
    
    inline void setGnd()
    {
        flags = node_gnd;
//        set_state(false);
    }

    inline void setPwr()
    {
        flags = node_pwr;
//        set_state(true);
    }

    inline void setForceCompute()
    {
        flags |= node_forcecompute;
    }

    inline void setFloat()
    {
        flags &= ~(node_set_low | node_set_high);
    }

    inline void setHigh()
    {
        flags &= ~(node_set_low);
        flags |= node_set_high;
    }

    inline void setLow()
    {
        flags &= ~(node_set_high);
        flags |= node_set_low;
    }
    
    inline void setPullUp()
    {
        flags |= node_pull_up;
    }

};



struct node_callback_info
{
    class Wires *           wires;
    std::string             name;
    int                     index;
    nodeID                  target_node;
    std::vector<nodeID>     node_ids;
    std::function<void ()>  callback;
    bool                    enqueued = false;
};


struct node
{
    nodeID nn = EMPTYNODE;
    int    ref_count = 0;
    int    area = 0;
    int    pullups = 0;
    std::string name;
    std::vector<transistorID> gates;
    std::vector<transistorID> c1c2s;
    std::vector<wire_segment_ptr> segments;
    
    node_callback_info *      callback = nullptr;   // callback to be invoked when node has been updated
    
    bool is_referenced() const    {return ref_count > 0;}
    bool is_pwr_gnd() const       {return (nn == npwr) || (nn == ngnd);}
    bool has_pullup() const       {return pullups > 0;}
};

using node_ptr = node *;


struct Wires;

class wire_compute
{
    Wires * const _wires;
    
    int _group_flags = 0;
    
    bool    _max_state = false;
    int    _max_connections = 0;

    node_value        * _node_states = nullptr;
    nodeinfo *     _node_infos = nullptr;
    node_ptr *          _nodes = nullptr;
    wire_transistor *    _transistors = nullptr;
    
    int _count_total = 0;
    int _count_fallback = 0;
  
    // used during recalc
    std::vector<nodeID> _group;
//    std::vector<bool> grouped;

    
    std::vector<nodeID> _recalc_list;
    std::vector<nodeID> _recalc_list_next;
    std::vector<int> _recalc_hash;
    std::vector<int> _recalc_hash_next;

    
    std::vector<transistorID> _transistor_list;
    

    
public:
    wire_compute(Wires *_wires);
    
    int _recalc_iteration = 1;
    int _recalc_count = 1;
    
    int _trace = 0;


    uint8_t _flags_to_state[0x100];


    
    void recalcNodeList(nodeID nn);
    void recalcNodeList( const std::vector<nodeID> &list);
    
    void setFloat(nodeID nn) {
        _node_infos[nn].setFloat();
        recalcNodeList(nn);
    }

    void setHigh(nodeID nn) {
        _node_infos[nn].setHigh();
        recalcNodeList(nn);
    }

    void setLow(nodeID nn) {
        _node_infos[nn].setLow();
        recalcNodeList(nn);
    }
    
    void setForceCompute(nodeID nn) {
        _node_infos[nn].setForceCompute();
    }

    
    bool isNodeHigh(nodeID nn) {
        return(_node_states[nn]);
    }

    int getNodeFlags(nodeID nn) {
        return(_node_infos[nn].flags);
    }
    
   

    
    void nextCycle() {
        _recalc_iteration = 1;
        _recalc_count = 1;
        
    }
    
    void loadNodeState(nodeID nn, bool state);

    
    void reset();

//
//    int addTransistorList(const std::vector<transistorID> &list)
//    {
//        if (_transistor_list.size() == 0) {
//            _transistor_list.push_back(0);
//        }
//
//        if (list.empty()) {
//            return 0;
//        }
//
//
//        int index = (int)_transistor_list.size();
//        int count = (int)list.size();
//
//        _transistor_list.push_back( count );
//        _transistor_list.insert(_transistor_list.end(), list.begin(), list.end());
//        return index;
//    }

    int addTransistorList(const std::vector<nodeID> &list)
    {
        if (_transistor_list.size() == 0) {
            _transistor_list.push_back(0);
        }
        
        if (list.empty()) {
            return 0;
        }
                
        int index = (int)_transistor_list.size();
        _transistor_list.insert(_transistor_list.end(), list.begin(), list.end());
        _transistor_list.push_back( 0 );
        return index;
    }

    
    void dump()
    {
#if 0
        printf("groups: ");
        for (size_t i=0; i < _group_histogram.size(); i++)
        {
            printf("%d:%d ", (int)i, _group_histogram[i]);
        }
        printf("\n");
#endif
//        float frac = (float)_count_fallback / (float)_count_total;
        
//        printf("compute recalc_iteration:%d recalc_count:%d\n",  _recalc_iteration, _recalc_count);
  
//        printf("wires %d / %d  frac:%f\n",   _count_fallback, _count_total, frac);
//        _count_fallback = 0;
//        _count_total = 0;

    }


private:
    void enqueueNode(nodeID nn);
    void processQueue();
    void recalcNode(nodeID nn);

    void setNodeState(nodeID nn, node_value state);
    void traceRecalcNode(nodeID nn);
    void setTransistorState(transistorID tn, bool state);

    node_value computeNodeGroup(nodeID nn);
    void addNodeToGroup(nodeID nn);
    node_value getNodeValue();
    


        
};


class MemoryData : public wire_memory
{
public:
    MemoryData(const std::string &name, size_t size)
    :_name(name)
    {
        _data.resize(size);
    }
    
    virtual ~MemoryData() = default;
    
    virtual const std::string &getName() override {
        return _name;
    }
    
    virtual size_t getSize() override
    {
        return _data.size();
    }
    
    virtual int  readByte(int address)  override
    {
        return _data[address];
    }
    
    virtual void writeByte(int address, int data)  override
    {
        _data[address] = data;
    }
    
    virtual bool writeBytes(size_t address, const uint8_t *ptr, size_t size) override
    {

        if (address >=  _data.size())
            return false;
        
        if (address + size > _data.size())
        {
            size =  _data.size() - address;
        }
        
        memcpy(_data.data() + address, ptr, size );
//        _data.assign( _data.begin() + address, data, data + size);
        return true;

    }
    
    virtual void clear() override
    {
        for (auto &b : _data)
        {
            b = 0;
        }
    }
    
    virtual uint32_t computeHash() override
    {
        return ComputeHash(1, _data);
    }
    
    std::vector<uint8_t> &getData()
    {
        return _data;
    }

    virtual const uint8_t *getDataPtr() override
    {
        return _data.data();
    }
   
    virtual void saveState(state_writer &sw) override
    {
        serialize(sw, _data);
    }
    

    virtual void loadState(state_reader &sr) override
    {
        serialize(sr, _data);
    }

protected:
    std::string             _name;
    std::vector<uint8_t>    _data;
};

using MemoryDataPtr = std::shared_ptr<MemoryData>;


static std::string remap(wire_instance_ptr instance, const std::string &node_name)
{
    return combinePrefix(instance->name, node_name);
}

static nodeID remap(wire_instance_ptr instance, nodeID nn)
{
    if (nn == EMPTYNODE) return nn;
    if (nn == instance->node_gnd) return ngnd;
    if (nn == instance->node_pwr) return npwr;

    return instance->node_start + nn;
}

enum wire_stats
{
    None,
    
    RecalcNode,
    AddNodeToGroup,
    SetTransistor,
    
    
    TOTAL
};

class Wires : public wire_module, public std::enable_shared_from_this<Wires>
{
public:
    Wires();
    
    std::mutex  _mutex;

    std::string _name;

    int _time = 0;
    int _verbose = 1;

    std::vector<node_value> _node_states;
    std::vector<nodeinfo> _node_infos;
    std::vector<node_ptr> _node_ptrs;
    std::vector<wire_transistor> _transistors;
    std::unordered_set<wire_transistor, wire_transistor::Hash> _transistor_set;
    wire_node_resolver_ptr _node_resolver;
    
    
    int _stats[wire_stats::TOTAL] = {0};
    
    
    inline void increase_stat(wire_stats stat) { _stats[stat] ++; }

    
    node_ptr getOrCreateNode(nodeID nn)
    {
        if (nn == EMPTYNODE) return nullptr;
        if (nn >= _node_ptrs.size())
        {
            _node_ptrs.resize(nn + 1);
        }

        auto nptr = _node_ptrs[nn];
        if (!nptr) {
            nptr = new node();
            nptr->nn = nn;
            nptr->ref_count++;
            _node_ptrs[nn] = nptr;
        }
        return nptr;
    }

    nodeID resolve(wire_instance_ptr instance, const noderef &ref)
    {
        if (!ref.node_name.empty()) {
            return _node_resolver->lookupNode( remap(instance, ref.node_name) );
        }
        
        return remap(instance, ref.node_id );
    }

//    nodeID resolve(const noderef &ref)
//    {
//        return _node_resolver->resolve(ref);
//    }

    std::vector<wire_instance_ptr> _instances;
    std::unordered_map<std::string, wire_instance_ptr> _instance_map;
    
    std::vector<MemoryDataPtr> _memory_list;
    
    std::vector<nodeID> _all_nodes;
    std::vector<nodeID> _forceComputeList;

    wire_compute *_compute;
    
    int _trace = 0;
    
    virtual nodeID addNode(const std::string &name);
    virtual bool addConnection(wire_instance_ptr instance, const std::string &from, const std::string &to);
    virtual bool addConnection(wire_instance_ptr instance,nodeID from, nodeID to);
    virtual void addForceCompute(std::string name);

    virtual wire_instance_ptr addInstance(wire_instance_ptr parent, wire_defs_ptr defs, std::string prefix) override;
    
    virtual wire_instance_ptr lookupInstance(const std::string &name) override;

    virtual std::vector<wire_instance_ptr> getAllInstances() override
    {
        return _instances;
    }
    
    virtual const char *getName() const override
    {
        return _name.c_str();
    }

    virtual int getNodeCount() const override {
        return (int)_node_ptrs.size(); // nodes.size();
    }
    
    virtual bool isNodeHigh(nodeID nn) override;
    virtual int getNodeFlags(nodeID nn) override;
    virtual void setFloat(nodeID nn) override;
    virtual void setHigh(nodeID nn) override;
    virtual void setLow(nodeID nn) override;

    virtual int  readBits(const std::vector<nodeID> &node_ids) override;
    virtual void writeBits(const std::vector<nodeID> &node_ids, int data) override;
    virtual void floatBits(const std::vector<nodeID> &node_ids) override;
    
    virtual wire_memory_ptr resolveMemory(const std::string &name) override
    {
        for (auto it : _memory_list)
        {
            if (it->getName() == name) {
                return it;
            }
        }
        return nullptr;
    }
    
    virtual void setTraceLevel(int level) override
    {
        _trace = level;
        _compute->_trace = level;
    }
    
    
    virtual void resetState() override;
    virtual void recomputeAllNodes() override;

    void saveState(std::string &res, int start, int end);
    void loadState(const std::string_view &res, int start, int end);
    void loadState(const std::string &name, const std::string_view &state);

    
    void loadState(state_reader &sr, int start, int end);
    void saveState(state_writer &sw, int start, int end);

    
    virtual void saveState(state_writer &sw) override;
    virtual void loadState(state_reader &sr) override;
    
    virtual int getTime() override
    {
        return _time;
    }

    virtual const char *getNodeName(nodeID nn) override;
    virtual nodeID lookupNode(const std::string &name) override;



    virtual void getNodeStates(std::vector<uint8_t> &state, int start, int count, uint8_t state_low, uint8_t state_high ) override
    {
        node_value *states = _node_states.data() + start;
        for (int i=0; i < count; i++)
        {
            state[i] = states[i] ? state_high : state_low;
        }
    }
    
    virtual uint32_t computeHash() override
    {
        return ComputeHash(1, _node_states.data(), _node_states.size() );
    }
    

    
public:
    
    virtual void resolveNodes(const std::string &expr, std::vector<nodeID> &node_ids) override;

    virtual void resolveNodes(const noderef &node_ref, std::vector<nodeID> &node_ids);
    virtual wire_register_ptr resolveRegister(const std::string &name) override;
    
    nodeID lookupNode(const char *name);
    
    void setupInstance(wire_instance_ptr instance);
    void setupNodes(wire_instance_ptr defs);
    void setupPins(wire_instance_ptr defs);
    void setupMemory(wire_instance_ptr defs);
    void setupSegments(wire_instance_ptr defs);
    void setupTransistors(wire_instance_ptr defs);


    void addNode(nodeID nn, const std::string &name);
    void addTransistor(wire_instance_ptr instance, const std::string &name, nodeID gate, nodeID c1, nodeID c2 );
    void addSegment(nodeID nn, const segdef *sd);

    void dumpTransistors();

    

    
    virtual const std::vector<nodeID> &allNodes() override;
    
    void dumpNodeInfo(nodeID nn) override;
    
    
    virtual void dump() override {
        auto hash = computeHash();
        log_printf("wires cycle:%08d hash:%08X\n", _time, hash);

        _compute->dump();
        
    }
    
    
    int _callback_enqueue_count = 0;
    std::vector<node_callback_info *> _callbacks;
    node_callback_info *_callback_single  = nullptr;
    
    
    void enqueue_callback(node_callback_info *handler)
    {
        if (!handler->enqueued)
        {
            _callback_enqueue_count++;
            _callback_single = handler;
            handler->enqueued = true;
        }
    }
    
    void invoke_callbacks()
    {
        if (!_callback_enqueue_count)
            return;

        // handle special case of a single callback
        if (_callback_enqueue_count == 1)
        {
            auto handler = _callback_single;
            _callback_enqueue_count = 0;
            _callback_single = nullptr;

            if (handler->enqueued) {
                handler->callback();
                handler->enqueued = false;
            }
            return;
        }

        
        _callback_enqueue_count = 0;
        for (auto handler : _callbacks)
        {
            if (handler->enqueued)
            {
                
//                int bits = readBits( handler->node_ids );
//                log_printf("%d: invoke '%s' bits:%d\n", getTime(), handler->name.c_str(),  bits );
                

                handler->callback();
                handler->enqueued = false;
            }
        }
    }
    
    

    
    virtual void add_callback(const std::vector<nodeID> &node_ids, std::function<void ()> callback ) override
    {
        int index = (int)_callbacks.size();
        
        std::string name = "callback:";
        for (auto nn : node_ids)
        {
            name += getNodeName(nn);
            name += ',';
        }
        nodeID target_node_id = addNode(name);
        
        
        // create node callback info
        auto *handler = new node_callback_info();
        handler->name = name;
        handler->wires = this;
        handler->index = index;
        handler->target_node = target_node_id;
        handler->node_ids = node_ids;
        handler->callback = callback;
        handler->enqueued = false;
        _callbacks.push_back(handler);
        
        
        // add transitors to source nodes
        for (nodeID nn : node_ids)
        {
            addTransistor(nullptr,
                          "callback",
                          nn, target_node_id, ngnd
                          );
        }
        
        
        node_ptr nptr = getOrCreateNode(target_node_id);
        
        // add handler to target ndoe
        nptr->callback = handler;
    }


//    std::vector<std::function<void ()> > _handlers;

    
    std::function<void ()> _handler;

    nodeID _clk = EMPTYNODE;
    
    void step_cycle()
    {
        bool clk = isNodeHigh(_clk);
        if(clk) {
            setLow(_clk);
        } else {
            setHigh(_clk);
        }
        
        
        if (_handler) {
            _handler();
        }

        if (_trace)
        {
            dump();
        }

        _compute->nextCycle();
        _time++;
    }


    virtual void add_handler(std::function<void ()> callback) override
    {
        auto prev_handler = _handler;
        if (prev_handler) {
            _handler = [=]() {
                prev_handler();
                callback();
            };
        } else {
            _handler = callback;
        }
    }

    virtual void step(int count) override
    {
        for(int i = 0; i < count; i++)
        {
            step_cycle();
        }
    }


};






Wires::Wires()
{
    _name = "";
    
    _node_resolver = CreateNodeResolver();
    
    _node_ptrs.resize(0x10000);
    addNode(ngnd, "vss");
    addNode(npwr, "vcc");


    _compute = new wire_compute(this);
}

void Wires::dumpNodeInfo(nodeID nn)
{
#if 0
    auto &n = _nodes[nn];
    
    
    printf("transitor %d %s\n",
           nn, getNodeName(nn));

    for (auto c : n.gates)
    {
        auto &td = this->_transistors[c];
        //for (auto d : )
        printf("transitor %d %s: %d %s [%d %s %d %s]\n",
               c, td.name.c_str(),
               td.gate, getNodeName(td.gate),
               td.c1, getNodeName(td.c1),
               td.c2, getNodeName(td.c2));
    }
    
    for (auto c : n.c1c2s)
    {
        auto &td = this->_transistors[c];

        printf("transitor %d %s: %d %s [%d %s %d %s]\n",
               c, td.name.c_str(),
               td.gate, getNodeName(td.gate),
               td.c1, getNodeName(td.c1),
               td.c2, getNodeName(td.c2));
    }
#endif
}

void Wires::dumpTransistors()
{
#if 0
    for(const auto &t : _transistors) {

        if (t.gate >= 40000)
        printf("%s#%d%c => [%s#%d%c <> %s#%d%c]\n",
                   //t.name.c_str(),
                   getNodeName(t.gate), t.gate, _nodes[t.gate].has_pullup() ? '+' : ' ',
                   getNodeName(t.c1), t.c1, _nodes[t.c1].has_pullup() ? '+' : ' ',
                   getNodeName(t.c2), t.c2, _nodes[t.c2].has_pullup() ? '+' : ' '

                   );

    }
#endif
}


void Wires::resetState()
{
//    dumpTransistors();

//    for(auto &n : nodestates) {
//        n.set_state(false);
//    }
//
//    for(transistor &t : transistors) {
//        t.on = (t.gate == npwr);
//    }
    
    _clk = lookupNode("clk");
    
    _compute->reset();
    
    
    
    recomputeAllNodes();
}

nodeID Wires::lookupNode(const char *name)
{
    return _node_resolver->lookupNode(name);
}



nodeID Wires::lookupNode(const std::string &name)
{
    return _node_resolver->lookupNode(name);
}

const char *Wires::getNodeName(nodeID nn) {
    if((size_t)nn >= _node_ptrs.size()) {
        return nullptr;
    }
    
    node_ptr nptr = _node_ptrs[nn];
    
    return nptr ? nptr->name.c_str() : nullptr;;
}

void Wires::addNode(nodeID nn, const std::string &name)
{

    node_ptr nptr = getOrCreateNode(nn);
    if (!nptr) {
        // akk....
        return;
    }
    
    if (_verbose >= 3)
        printf("node '%s': %d\n", name.c_str(), nn);
    _node_resolver->addNode(nn, name);
    
     
    if (nptr->name.empty()) {
        nptr->name = name;
    } else {
        if (!is_pwr_gnd(nn) && name.find('#') == std::string::npos )
        {
            if (_verbose >= 3)
                printf("alias '%s' <-> '%s'\n", nptr->name.c_str(), name.c_str());
        }
    }
}


void Wires::setupNodes(wire_instance_ptr instance)
{
    for(const auto &nd : instance->defs->nodedefs)
    {
        addNode(remap(instance, nd.node_id),
                remap(instance, nd.name) );
    }
}



static rect ComputeBoundingBox(const std::vector<point> &points)
{
    rect bb = {0};
    if (points.empty())
        return bb;
    bbox_reset(bb);
    for (auto p : points)
    {
        bbox_append(bb, p);
    }
    return bb;
}

static void EraseDuplicatePoints(std::vector<point> &points)
{
    // erase duplicate points
    point last = points.front();
    for (int i=(int)points.size() - 1; i >= 0; i--)
    {
        point curr = points[i];
        if (last.x == curr.x && last.y == curr.y)
        {
            points.erase(points.begin() + i);
        }
        last = curr;
    }

}


static int ComputeArea(const std::vector<int> &triangle_list, const std::vector<point> &points)
{
    
#if 0
    std::vector<int> sp;
    
    sp.push_back(seg.nn);
    sp.push_back(seg.pullup);
    sp.push_back(seg.layer);
    for (auto p : seg.points)
    {
        sp.push_back(p.x);
        sp.push_back(p.y);
    }

    int64_t area = (int64_t)sp[sp.size() - 2] * (int64_t)sp[4] - (int64_t)sp[3] * (int64_t)sp[sp.size() - 1];
    for(size_t j = 3; j + 4 < sp.size(); j += 2) {
        area += (int64_t)sp[j] * (int64_t)sp[j + 3] - (int64_t)sp[j + 2] * (int64_t)sp[j - 1];
    }
    if(area < 0) {
       area = -area;
   }
    return (int)area;
#else
    int area = 0;
    for (int i=0; i < (int)triangle_list.size(); i+=3)
    {
        point p0 = points[ triangle_list[i + 0] ];
        point p1 = points[ triangle_list[i + 1] ];
        point p2 = points[ triangle_list[i + 2] ];
        
        int x1 = p0.x;
        int x2 = p1.x;
        int x3 = p2.x;
        int y1 = p0.y;
        int y2 = p1.y;
        int y3 = p2.y;

        
        int tri_area = (x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)) / 2;
        area += tri_area;
    }
    return area;
#endif

    

}



void Wires::setupSegments(wire_instance_ptr instance)
{
    int index = 0;
    for (const segdef &sd : instance->defs->segdefs)
    {
        wire_segment_ptr segment =  std::shared_ptr<wire_segment>( new wire_segment
        {
            index++,
            resolve(instance, sd.nn),
            sd.pullup == "+",
            sd.layer
        });

        segment->points = sd.points;

        if (!segment->points.empty())
        {
            EraseDuplicatePoints(segment->points);
            BuildTriangleList(segment->points, segment->triangle_list);
        }

        
        segment->bb = ComputeBoundingBox(segment->points);
        segment->area = ComputeArea(segment->triangle_list, segment->points);

        // add to instance...
        instance->segments.push_back(segment);
        

        node_ptr nptr = getOrCreateNode(segment->node_id);
        if (nptr)  {
        
            if(is_pwr_gnd(segment->node_id)) continue;
            
            nptr->area += segment->area;
            
            if (segment->pullup)
            {
                nptr->pullups ++;
            }

            nptr->segments.push_back(segment);
        }
        
    }
    
    
    for (auto pullup : instance->defs->pullups)
    {
        std::vector<nodeID> node_ids;
        _node_resolver->resolveNodes( remap(instance, pullup), node_ids);
        assert(!node_ids.empty());
        for (auto node_id : node_ids)
        {
            node_ptr nptr = getOrCreateNode(node_id);
            if (nptr)  {
                nptr->pullups++;
            }
        }
    }
}


void Wires::addTransistor(wire_instance_ptr instance, const std::string &name, nodeID gate, nodeID c1, nodeID c2 )
{
    assert(gate != EMPTYNODE);
    assert(c1 != EMPTYNODE);
    assert(c2 != EMPTYNODE);
    if (c1 == c2)
    {
        return;
    }
    
    if(is_pwr_gnd(c1))
    {
        std::swap(c1, c2);
    }
    
    if (_verbose >= 4)
        printf("transistor '%s' %d %d %d\n", name.c_str(), gate, c1, c2);

    wire_transistor t = { name, gate, c1, c2};
    if (_transistor_set.count(t) != 0)
    {
        return;
    }

    
    transistorID i = (int)_transistors.size();
    _transistors.push_back(t);
    _transistor_set.insert(t);
    
    if (instance)
    {
        instance->transistors.push_back(t);
    }
    
    
    getOrCreateNode(gate)->gates.push_back(i);
    getOrCreateNode(c1)->c1c2s.push_back(i);
    getOrCreateNode(c2)->c1c2s.push_back(i);
}

void Wires::setupTransistors(wire_instance_ptr instance)
{
	for(const transdef &tdef : instance->defs->transdefs) {
        
        addTransistor(instance,
                      remap(instance, tdef.name),
                      resolve(instance, tdef.gate),
                      resolve(instance, tdef.c1),
                      resolve(instance, tdef.c2)
                      );
	}
  
}

nodeID Wires::addNode(const std::string &name)
{
    if (lookupNode(name) != EMPTYNODE)
    {
        assert(0);
    }
    
    nodeID nn =  _node_resolver->allocNodes(1, 1);
    addNode(nn, name);
    return nn;
}


void Wires::setupPins(wire_instance_ptr instance)
{
    instance->pin_nodes.resize( instance->defs->pindefs.size() + 1);
    
    // setup pins
    for (const auto &pd : instance->defs->pindefs)
    {
        nodeID pinNode = lookupNode( remap(instance, pd.name) );
        if (pinNode == EMPTYNODE)
        {
            printf("missing pin %s\n", pd.name.c_str());
            assert(0);
        }

        assert(instance->pin_nodes[pd.pin] == 0);
        
        instance->pin_nodes[pd.pin] = pinNode;
        
        std::string pinNodeName = remap(instance, "#") + std::to_string(pd.pin);
        addNode(pinNode, pinNodeName);
    }
}

void Wires::setupMemory(wire_instance_ptr instance)
{
    // setup memory regions
    for (const auto &md : instance->defs->memorydefs)
    {
        auto mem = std::make_shared<MemoryData>( remap(instance, md.name), md.size );
        _memory_list.push_back(mem);
        
        if (_verbose >= 1)
            printf("memory-region '%s' size:%d\n", mem->getName().c_str(), (int)mem->getSize() );
    }
}



void Wires::setupInstance(wire_instance_ptr instance)
{
    if (_verbose >= 1)
        printf("instance '%s' type:%s (%d -> %d) gnd:%d pwr:%d\n", instance->name.c_str(), instance->type.c_str(), instance->node_start, instance->node_end ,
           instance->node_gnd, instance->node_pwr);

    setupNodes(instance);
    setupPins(instance);
    setupMemory(instance);
    setupSegments(instance);
    setupTransistors(instance);
}


wire_instance_ptr Wires::lookupInstance(const std::string &name)
{
    auto it = _instance_map.find(name);
    if (it == _instance_map.end())
        return nullptr;
    return it->second;
}


wire_instance_ptr Wires::addInstance(wire_instance_ptr parent, wire_defs_ptr defs, std::string prefix)
{
    wire_instance_ptr instance;
    
    
    auto it = _instance_map.find(prefix);
    if (it == _instance_map.end())
    {
        // allocate node-space for instance
        int maxNode = defs->maxNodeID;
        
        int alignment = (maxNode < 100) ? 100 : 1000;
        int nodeStart = _node_resolver->allocNodes(alignment, maxNode + 1);

        // create instance
        instance = std::make_shared<wire_instance>();
        instance->wires = shared_from_this();
        instance->parent = parent;
        instance->name = prefix;
        instance->type = defs->type;
        instance->defs = defs;
        instance->label = instance->type + " (" + instance->name + ")";
        instance->node_gnd = defs->findNode("vss");
        instance->node_pwr = defs->findNode("vcc");
        instance->node_start = nodeStart;
        instance->node_end   = nodeStart + maxNode;
        _instances.push_back(instance);
        _instance_map.insert( std::make_pair(instance->name, instance) );

        setupInstance(instance);
    }
    else
    {
        instance = it->second;
    }
    
    //
    for (auto &md : defs->modules)
    {
        wire_instance_ptr child = addInstance(instance, md.defs, remap(instance, md.prefix));
        instance->children.push_back(child);
    }
       
    for (auto &connection : defs->connections)
    {
       addConnection(instance,
                     remap(instance, connection.from.node_name),
                     remap(instance, connection.to.node_name) );
    }

    for (auto &name : defs->forceCompute)
    {
       addForceCompute( remap(instance, name) );
    }
    

    return instance;
}



void Wires::addForceCompute(std::string name)
{
    resolveNodes(name, _forceComputeList);
}


bool Wires::addConnection(wire_instance_ptr instance, const std::string &from_name, const std::string &to_name)
{
    std::vector<nodeID> from_list;
    std::vector<nodeID> to_list;

    resolveNodes(from_name, from_list);
    resolveNodes(to_name, to_list);
    
    
    if (from_list.size() == 1 && !to_list.empty())
    {
        // one to many mapping;...
        for (size_t i=0; i < to_list.size(); i++)
        {
            addConnection(instance, from_list[0], to_list[i]);
        }
        return true;
    }
    
    // one to one mapping
    if (from_list.size() == to_list.size() && !from_list.empty() && !to_list.empty())
    {
        for (size_t i=0; i < from_list.size(); i++)
        {
            addConnection(instance, from_list[i], to_list[i]);
        }
        return true;
    }

    printf("Connection failed: %s -> %s\n", from_name.c_str(), to_name.c_str());
    return false;
}

bool Wires::addConnection(wire_instance_ptr instance, nodeID from, nodeID to)
{
    if (from == to) return true;
    
    if (is_pwr_gnd(from))  {
        std::swap(from, to);
    }

    
    std::string from_name = getNodeName(from);
    std::string to_name = getNodeName(to);
    std::string name = from_name + "<>" + to_name;
    

#if 0
    if (is_pwr_gnd(to)) {
        printf("remapped node: %s -> %s (%d->%d)\n", from_name.c_str(), to_name.c_str(), from, to );
        applyNodeRemap(from, to);
        return true;
    }
#endif
    
    addTransistor(instance, name, npwr, from, to);
    
    if (_verbose >= 2)
        printf("added connection: %s -> %s (%d->%d)\n", from_name.c_str(), to_name.c_str(), from, to );
    return true;
}



wire_module_ptr WiresCreate()
{
    return std::make_shared<Wires>();
}


void Wires::recomputeAllNodes()
{
    _compute->recalcNodeList( allNodes() );
}



wire_compute::wire_compute(Wires *wires)
    :
    _wires(wires)
{

}


void wire_compute::loadNodeState(nodeID nn, bool state)
{
    _node_states[nn] = state ? 1 : 0;
}

static bool flagsToState(int flags)
{
    if ( flags & node_flags::node_forcecompute)
    {
        if ((flags & node_flags::node_gnd) &&  (flags & node_flags::node_pwr))
        
        {
            flags &= ~node_flags::node_gnd;
            flags &= ~node_flags::node_pwr;
        }
    }

    
    if (flags & node_flags::node_gnd) {
        return false;
    }

    if (flags & node_flags::node_pwr) {
        return true;
    }
    
    if (flags & node_flags::node_set_high) {
        return true;
    }

    if (flags & node_flags::node_set_low) {
        return false;
    }

    if (flags & node_flags::node_pull_up) {
        return true;
    }

    if (flags & node_flags::node_state) {
        return true;
    } else {
        return false;
    }
}



void wire_compute::reset()
{
    for (int i=0; i < sizeof(_flags_to_state); i++)
    {
        _flags_to_state[i] = flagsToState(i) ? 0x1 : 0x0;
    }
    size_t node_count = _wires->_node_ptrs.size();
    _recalc_list.clear();
    _recalc_list_next.clear();
    _recalc_hash.resize( node_count );
    _recalc_hash_next.resize( node_count );

    _wires->_node_states.clear();
    _wires->_node_states.resize( node_count );

    _wires->_node_infos.clear();
    _wires->_node_infos.resize( node_count );

    
    _node_states = _wires->_node_states.data();
    _node_infos = _wires->_node_infos.data();
    _nodes = _wires->_node_ptrs.data();
    _transistors = _wires->_transistors.data();

    
    for (nodeID nn : _wires->allNodes())
    {
        _node_states[nn] = 0;
        
        auto &ns = _node_infos[nn];
        node_ptr nptr = _nodes[nn];
        ns.connections = (int)(nptr->c1c2s.size() + nptr->gates.size());

        ns.setFloat();

        if (_nodes[nn]->pullups > 0) {
            ns.setPullUp();
            _node_states[nn] = 1; // pull this node up
        }
        
        if (nptr->callback != nullptr) {
            ns.flags |= node_flags::node_has_callback;
        }
    }
    
    _transistor_list.clear();
    _transistor_list.push_back(0);
    for (nodeID nn = 0; nn < (int)node_count; nn++)
    {
        node_ptr nptr = _nodes[nn];
        if (!nptr)
            continue;
        
        nodeinfo & ns = _node_infos[nn];
        
        {
            std::vector<nodeID> list;
            for (auto tid : nptr->gates) {
                auto &t = _transistors[tid];
                list.push_back(t.c1);
                list.push_back(t.c2);
            }
            ns._tlist_gates    = addTransistorList(list);
        }
        
        {
            std::vector<nodeID> list;
            std::vector<nodeID> list_gnd;
            std::vector<nodeID> list_pwr;
            for (auto tid : nptr->c1c2s) {
                auto &t = _transistors[tid];
                auto c2 = (t.c1 == nn) ? t.c2 : t.c1;
                
                if (t.gate == ngnd)
                    continue;
                
                if (c2 == ngnd) {
                    list_gnd.push_back(t.gate);
                } else if (c2 == npwr) {
                    list_pwr.push_back(t.gate);
                } else
                {
                    list.push_back(t.gate);
                    list.push_back(c2);
                }
            }
            ns._tlist_c1c2s = addTransistorList(list);
            ns._tlist_c1gnd = addTransistorList(list_gnd);
            ns._tlist_c1pwr = addTransistorList(list_pwr);
        }
        
        
//        ns._tlist_gates    = addTransistorList(n.gates);
//        ns._tlist_c1c2s    = addTransistorList(n.c1c2s);
//        ns._tlist_c1gndpwr = addTransistorList(n.c1gndpwr);
        
//        printf("node #%d %s %d %d %d\n", nn, n.name.c_str(), (int)n.gates.size(), (int)n.c1c2s.size(), (int)n.c1gndpwr.size() );

    }

    _node_states[ngnd] = 0;
    _node_infos[ngnd].setGnd();
    
    _node_states[npwr] = 1;
    _node_infos[npwr].setPwr();

    for (nodeID nn : _wires->_forceComputeList)
    {
        _node_infos[nn].setForceCompute();
    }
    
//    for (auto &md : _wires->_instances)
//    {
//        if (_verbose >= 2)
//            printf("instance '%s' type:%s (%d -> %d)\n", md->name.c_str(), md->type.c_str(),  md->node_start, md->node_end);
//    }

}

void wire_compute::recalcNodeList(nodeID nn)
{
    enqueueNode(nn);
    processQueue();
}


void wire_compute::recalcNodeList( const std::vector<nodeID> &list)
{
    for (auto nn : list)
    {
        enqueueNode(nn);
    }
    processQueue();
}


void wire_compute::processQueue()
{

    
    int iteration = 0;
        
    while (!_recalc_list_next.empty())
    {
        if(++iteration == 100) {
            printf("iteration warning %d\n", iteration);
        }
        
        
        _recalc_iteration++;


        _recalc_list_next.swap(_recalc_list);
        _recalc_hash_next.swap(_recalc_hash);


        for(nodeID nn : _recalc_list) {
            _recalc_count++;

//            recalcNode(nn);
            

            if (_recalc_hash[nn])
            {
                recalcNode(nn);
                _recalc_hash[nn] = 0;
//                _recalc_list.remove(nn);
            }
        }
//
//        for(nodeID nn : _recalc_list) {
//            _recalc_list_hash[nn] = false;
//        }
//
        _recalc_list.clear();
    }
 
    
    _wires->invoke_callbacks();
}



node_value wire_compute::computeNodeGroup(nodeID nn)
{
    _group_flags = (node_flags)0;
    _group.clear();
    
    _max_state = false ;
    _max_connections = 0;

    
    addNodeToGroup(nn);

    return getNodeValue();
}

void wire_compute::setNodeState(nodeID gnn, node_value newState)
{
//        ns._group_count = group_count;
    if(_node_states[gnn] != newState) {
        _node_states[gnn] = newState;


        nodeinfo& ns = _node_infos[gnn];
        if (ns._tlist_gates)
        {
            const nodeID *ptr = &_transistor_list[ns._tlist_gates];
            while (*ptr)
            {
                nodeID c1 = *ptr++;
                nodeID c2 = *ptr++;
                
                
                _wires->increase_stat(SetTransistor);

                
                enqueueNode(c1);
                if (!newState)
                {
                    if (!is_pwr_gnd(c2))
                        enqueueNode(c2);
                }
            }
        }
    }
    
//        ns.in_group = false;

}

static void print_node_flags(std::ostream &os, int flags)
{
    if (flags & (node_flags::node_gnd))
    {
        os << "|gnd";
    }

    if (flags & (node_flags::node_pwr))
    {
        os << "|pwr";
    }

    if (flags & (node_flags::node_set_high))
    {
        os << "|set_high";
    }

    if (flags & (node_flags::node_set_low))
    {
        os << "|set_low";
    }

    
    if (flags & (node_flags::node_pull_up))
    {
        os << "|pullup";
    }
    

    
    if (flags & (node_flags::node_forcecompute))
    {
        os << "|forcecompute";
    }
}



static void print_node_value(Wires *wires, std::ostream &os, nodeID nn)
{
    os << '(';
    os << wires->isNodeHigh(nn);
    print_node_flags(os, wires->getNodeFlags(nn));
    os << ')';
}

static void print_node_name(Wires *wires, std::ostream &os, nodeID nn)
{
    os << wires->getNodeName(nn) << "#" << nn;
}

static void print_node_name_value(Wires *wires, std::ostream &os, nodeID nn)
{
    if (nn == ngnd) {
        os << "ngnd";
        return;
    }
    if (nn == npwr) {
        os << "npwr";
        return;
    }
    print_node_name(wires, os, nn);
    print_node_value(wires, os, nn);
}


static void print_transistor(Wires *wires, std::ostream &ss, nodeID gate, nodeID c1, nodeID c2, bool gateState)
{
    ss << "\tgate: ";
    print_node_name(wires, ss, gate);
    ss << " ==> {";

    print_node_name_value(wires, ss, c1);

    if (gateState)
        ss << " == ";
    else
        ss << " <> ";

    print_node_name_value(wires, ss, c2);
    
    ss << "}";
}



void wire_compute::traceRecalcNode(nodeID nn)
{
//    if (nn >= 13000)
//        return;
//
    int recalc_count = _recalc_hash[nn];

    bool newState = computeNodeGroup(nn);
    
    bool changed = false;
    changed = true;
    for (auto gnn : _group)
    {
        if (isNodeHigh(gnn) != newState) {
            changed = true;
        }
    }
    
    if (!changed)
    {
        return;
    }
        std::stringstream ss;
        
        ss << "cycle#" << _wires->_time << " " ;
        ss << "iteration:" << _recalc_iteration << " " ;
        ss << "recalc:" << _recalc_count << " " ;
        ss << "from:" << recalc_count << " " ;

        

        ss << "[";
        bool first = true;
        for (auto gnn : _group) {
            if (!first)
                ss << ' ';
            
            print_node_name(_wires, ss, gnn);
            
            if (isNodeHigh(gnn) != newState) {
                ss << '(';
                ss << isNodeHigh(gnn);
                ss << "->";
                ss << newState;
                print_node_flags(ss, _wires->getNodeFlags(gnn));
                ss << ')';
              

            } else {
                print_node_value(_wires, ss, gnn);
            }
            
            first = false;
        }
    
        if (_group_flags & node_flags::node_gnd)
        {
            ss << ' ';
            print_node_name_value(_wires, ss, ngnd);
        }

        if (_group_flags & node_flags::node_pwr)
        {
            ss << ' ';
            print_node_name_value(_wires, ss, npwr);
        }

        ss << "]";
        print_node_flags(ss, _group_flags);
        
        ss << std::endl;
        
        
        for (auto gnn : _group) {
            if (isNodeHigh(gnn) != newState) {
                
                nodeinfo& ns = _node_infos[gnn];
                if (ns._tlist_gates)
                {
                    const nodeID *ptr = &_transistor_list[ns._tlist_gates];
                    while (*ptr)
                    {
                        nodeID c1 = *ptr++;
                        nodeID c2 = *ptr++;
                        
                        print_transistor(_wires, ss, gnn, c1, c2, newState);
                        ss << std::endl;

                    }

                }

            }
        }

        /*
        ss << " gates:";

        for (auto gnn : _group) {
            nodestate& ns = _node_states[gnn];

            if (ns._tlist_c1c2s)
            {
                const nodeID *ptr = &_transistor_list[ns._tlist_c1c2s];
                while (*ptr)
                {
                    nodeID gate = *ptr++;
                    nodeID c2   = *ptr++;
                    (void)c2;
                    
                    print_node(_wires, ss, gate, true);
                    ss << ' ';

                }
            }

            if (ns._tlist_c1gnd)
            {
                const nodeID *ptr = &_transistor_list[ns._tlist_c1gnd];
                while (*ptr)
                {
                    nodeID gate = *ptr++;
                    print_node(_wires, ss, gate, true);
                    ss << ' ';
                }
            }

            if (ns._tlist_c1pwr)
            {
                const nodeID *ptr = &_transistor_list[ns._tlist_c1pwr];
                while (*ptr)
                {
                    nodeID gate = *ptr++;
                    print_node(_wires, ss, gate, true);
                    ss << ' ';
                }
            }
        }
         */

        
//        ss << std::endl;
        
        log_write(ss.str());
        log_flush();
    

}

void wire_compute::recalcNode(nodeID nn) {
    if(is_pwr_gnd(nn)) return;

    _wires->increase_stat(RecalcNode);

#if 1
    if (_trace)
    {
        traceRecalcNode(nn);
    }
#endif
    
    bool newState = computeNodeGroup(nn);
    
    /*
    if (_group_flags & node_flags::node_set_low) {
        if (_group_flags & node_flags::node_pull_up) {
            if (!(_group_flags & node_flags::node_gnd)) {
                traceRecalcNode(nn);
                assert(0);
            }

        }
    }
     */

    
    for(nodeID gnn : _group) {
        setNodeState(gnn, newState);
    }
    
    if (_group_flags & node_flags::node_has_callback)
    {
        for(nodeID gnn : _group)
        {
            if (_nodes[gnn]->callback)
            {
                // enqueue callback to be called;
                _wires->enqueue_callback(_nodes[gnn]->callback);
            }
        }
    }
}

//void wire_compute::setTransistorState(transistorID i, bool state) {
//    transistor &t = _transistors[i];
//    if (t.on == state) return;
//    t.on = state;
//    
//    enqueueNode(t.c1);
//    if (!state) enqueueNode(t.c2); // add this one too?
//}


void wire_compute::enqueueNode(nodeID nn) {
    if(is_pwr_gnd(nn)) return;

    if (!_recalc_hash_next[nn])
    {
        _recalc_list_next.push_back(nn);
        _recalc_hash_next[nn] = _recalc_count;
    }
}


void wire_compute::addNodeToGroup(nodeID nn) {
    
    
    for  (auto gnn : _group)
    {
        if (gnn == nn)
            return;
    }

    nodeinfo &ns = _node_infos[nn];
    
    _group.push_back(nn);
    
    if (ns.connections > _max_connections) {
        _max_state       = _node_states[nn];
        _max_connections = ns.connections;
    }

    _recalc_hash[nn] = 0;

//
//    if (_recalc_list.contains(nn))
//    {
//        _recalc_list.remove(nn);
//    }
    
    
    // or in flags
    _group_flags |= ns.flags;
    
    
    if (ns._tlist_c1c2s)
    {
        const nodeID *ptr = &_transistor_list[ns._tlist_c1c2s];
        while (*ptr)
        {
            nodeID gate = *ptr++;
            nodeID c2   = *ptr++;
            if(_node_states[gate]) {
                addNodeToGroup(c2);
            }
        }
    }

    if (ns._tlist_c1gnd)
    {
        const nodeID *ptr = &_transistor_list[ns._tlist_c1gnd];
        while (*ptr)
        {
            nodeID gate = *ptr++;
            if(_node_states[gate]) {
                _group_flags |= node_flags::node_gnd;
                break;
            }
        }
    }

    if (ns._tlist_c1pwr)
    {
        const nodeID *ptr = &_transistor_list[ns._tlist_c1pwr];
        while (*ptr)
        {
            nodeID gate = *ptr++;
            if(_node_states[gate]) {
                _group_flags |= node_flags::node_pwr;
                break;
            }
        }
    }

}

#define FLAG_LOOKUP 1

node_value wire_compute::getNodeValue() {

    if ( _group_flags & node_flags::node_forcecompute)
    {
        if (_group_flags & node_flags::node_gnd)
        if (_group_flags & node_flags::node_pwr)
        {
            _group_flags &= ~node_flags::node_gnd;
            _group_flags &= ~node_flags::node_pwr;
        }
    }

    if (!_group_flags)
    {
        return _max_state;
    }
    
    
#if FLAG_LOOKUP
    return _flags_to_state[_group_flags];
#else
    
    if (_group_flags & node_flags::node_gnd) {
        return false;
    }

    if (_group_flags & node_flags::node_pwr) {
        return true;
    }
    
    if (_group_flags & node_flags::node_set_high) {
        return true;
    }

    if (_group_flags & node_flags::node_set_low) {
        return false;
    }

    if (_group_flags & node_flags::node_pull_up) {
        return true;
    }


    return _max_state;
#endif
}


bool Wires::isNodeHigh(nodeID nn) {
    return _compute->isNodeHigh(nn);
}

int Wires::getNodeFlags(nodeID nn) {
    return _compute->getNodeFlags(nn);
}



const std::vector<nodeID> &Wires::allNodes()
{
    if (_all_nodes.empty())  {
        for (nodeID nn=0; nn < (nodeID)_node_ptrs.size(); nn++)
        {
            node_ptr nptr = _node_ptrs[nn];
            if( nptr && !is_pwr_gnd(nn) && (nptr->ref_count > 0))  {
                _all_nodes.push_back(nn);
            }
        }
    }
    return _all_nodes;
}


void Wires::saveState(std::string &str, int start, int end)
{
    int count = end - start + 1;
    str.clear();
    str.reserve(count);

    for (int i = start; i <= end; i++)
    {
        node_ptr nptr = _node_ptrs[i];
        char c = 'x';
        if (nptr)
        {
            c = _node_states[i] ? '1' : '0';
        }
        
        str.push_back(c);
    }
}


void Wires::saveState(state_writer &writer)
{
    std::lock_guard<std::mutex> lock(_mutex);

     writer.Key("state");
    {
        writer.StartObject();
        serialize(writer, "time", _time);
        writer.EndObject();
    }

    
    writer.Key("nodes");
    {
        writer.StartObject();
        
        std::string str;
        str.reserve(getNodeCount());

        for (auto instance : _instances)
        {
            writer.Key(instance->name);
            
            saveState(str, instance->node_start, instance->node_end);
            serialize_large_string(writer, str);
        }
        writer.EndObject();
    }
    
    

    writer.Key("memory");
    {
        writer.StartObject();
        for (const auto &it : _memory_list)
        {
            writer.Key( it->getName() );
            it->saveState( writer );
        }
        writer.EndObject();
    }
}




void Wires::loadState(const std::string_view &str, int start, int end)
{
    int i = 0;
    for (char c : str)
    {
        int nn = start + i;
        if (nn > end) break;
        
        switch(c)
        {
            case 'x':
            case '_':
            {
                // skip
                break;
            }

            case '1':
            case 'v':
            case '+':
            {
                _compute->loadNodeState(nn, true);
                break;
            }
            case 'g':
            case '0':
            case '-':
            {
                _compute->loadNodeState(nn, false);
                break;
            }

            default:
                printf("unknown state char: '%c'\n",  c);
                assert(0);
                break;
        }
        i++;
    }

}




void Wires::loadState(const std::string &path, const std::string_view &value)
{
    wire_instance_ptr instance = lookupInstance(path);
    if (!instance) {
        assert(0);
        return;
    }
    
    loadState(value, instance->node_start, instance->node_end);
}


void Wires::loadState(state_reader &sr, int node_start, int node_end)
{
    std::string str;
    str.reserve( node_end - node_start + 1);
    deserialize_large_string(sr, str);
    loadState(str, node_start, node_end);
}






void Wires::loadState(state_reader &sr)
{
    std::lock_guard<std::mutex> lock(_mutex);

    {
        auto &state = sr["state"];
        serialize(state, "time", _time);
    }
    
    
    {
        auto nodes = sr["nodes"].GetObject();
        for (const auto &child : nodes)
        {
            const char *name = child.name.GetString();
            wire_instance_ptr instance = lookupInstance(name);
            if (!instance) {
                assert(0);
                continue;
            }
            
            loadState(child.value, instance->node_start, instance->node_end);
        }
    }

    {
        auto memory = sr["memory"].GetObject();
        for (const auto &child : memory)
        {
            const char *name = child.name.GetString();
//            const char *value = child.value.GetString();
            
            wire_memory_ptr memory = resolveMemory(name);
            
            if (memory)
            {
                memory->loadState(child.value);
            }
            else
            {
                assert(0);
            }
        }
    }

}


void Wires::setFloat(nodeID nn) {
    _compute->setFloat(nn);
}

void Wires::setHigh(nodeID nn) {
    _compute->setHigh(nn);
}

void Wires::setLow(nodeID nn) {
    _compute->setLow(nn);
}

int  Wires::readBits(const std::vector<nodeID> &nodes)
{
    int value = 0;
    int  i =0;
    for (nodeID nn : nodes )
    {
        if ( _compute->isNodeHigh(nn))
            value |= 1 << i;
        i++;
    }
    return value;
}

void Wires::writeBits(const std::vector<nodeID> &nodes, int data)
{
    int i = 1;
    for (nodeID nn : nodes)
    {
        if (data & i) {
            _compute->setHigh(nn);
        } else {
            _compute->setLow(nn);
        }

        i <<= 1;
     }
}

void Wires::floatBits(const std::vector<nodeID> &nodes)
{
    for (nodeID nn : nodes)
    {
        _compute->setFloat(nn);
    }
}




void Wires::resolveNodes(const noderef &node_ref, std::vector<nodeID> &node_ids)
{
    _node_resolver->resolveNodes(node_ref, node_ids);
}


void Wires::resolveNodes(const std::string &expr, std::vector<nodeID> &node_ids)
{
    _node_resolver->resolveNodes(expr, node_ids);
}


wire_register_ptr Wires::resolveRegister(const std::string &name)
{
    std::vector<nodeID> nodes;
    _node_resolver->resolveNodes(name, nodes);
    
    if (nodes.empty()) {
        printf("%s\n", name.c_str());
        assert(0);
    }
    return std::make_shared<wire_register>( shared_from_this(), name, nodes);
}



} // namespace

