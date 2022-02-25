
#include "wire_defs.h"
#include "wire_node_resolver.h"
#include <unordered_map>
#include <assert.h>
#include "Core/String.h"

namespace metalnes {


// this class manages the "node-id space" and resolves node names to ids
class node_resolver : public wire_node_resolver
{
public:
    virtual nodeID resolve(const noderef &ref) override
    {
        if (ref.node_id == 0) {
            return lookupNode(ref.node_name);
        }
        return ref.node_id;
    }
    
    virtual nodeID lookupNode(const std::string &name) override
    {
        auto it = _node_map.find(name);
        if (it == _node_map.end()) {
            return EMPTYNODE;
        }
        return it->second;
    }
    
    virtual const char *getNodeName(nodeID node_id) override
    {
        auto it = _node_name_map.find(node_id);
        if (it == _node_name_map.end()) {
            return nullptr;
        }
        
        return it->second.c_str();
    }
    
    virtual nodeID allocNodes(int alignment, int count) override
    {
        nodeID start = _max_nodeid + 1;
        
        // align...
        while ((start % alignment) != 0)
        {
            start++;
        }
        
        _max_nodeid = start + count - 1;
        return start;
    }
    
    virtual void addNode(nodeID nn, const std::string &name) override
    {
        if (nn == EMPTYNODE) return;

        auto it = _node_map.find(name);
        if (it != _node_map.end()) {
            if (it->second != nn)
            {
                // node name already exists
                printf("node name '%s' already exists (%d and %d)\n", name.c_str(), nn, it->second);
//                assert(0);
            }
            return;
        }
        
        
        if (_node_name_map.find(nn) != _node_name_map.end())
        {
            // this is an alias...
        }
        
        _max_nodeid = std::max(_max_nodeid, nn);
        _node_map.insert( std::make_pair(name, nn));
        _node_name_map.insert( std::make_pair(nn, name));
    }

    virtual void resolveNodes(const noderef &node_ref, std::vector<nodeID> &node_ids) override
    {
        if (node_ref.node_id)
        {
            node_ids.push_back(node_ref.node_id);
            return;
        }
     
        resolveNodes(node_ref.node_name, node_ids);
    }

    //virtual
    virtual void resolveNodes(const std::vector<std::string> &node_names, std::vector<nodeID> &node_ids) override
    {
        for (auto &name : node_names)
        {
            resolveNodes(name, node_ids);
        }
    }

    static bool wildcard_check(const std::string &str, const std::string &prefix, const std::string &suffix)
    {
        if (prefix.size() > str.size()) return false;
        if (suffix.size() > str.size()) return false;
        
        return prefix == str.substr(0, prefix.size()) && suffix == str.substr(str.size() - suffix.size());
    }


    struct ParsedArray
    {
        std::string left;
        std::string right;
        int        range_start = 0;
        int        range_end = 0;
        
        std::string get_element_name(size_t index)
        {
            return left + std::to_string(index) + right;
        }
    };


    static bool ParseArray(const std::string &expr, ParsedArray &pa)
    {
        size_t bracket_start = expr.find('[');
        if (bracket_start == std::string::npos)
            return false;
        
        size_t bracket_end = expr.find(']', bracket_start);
        if (bracket_end == std::string::npos)
            return false;

        
        std::string range = expr.substr(bracket_start + 1, bracket_end - bracket_start - 1);

        pa.left  = expr.substr(0, bracket_start);
        pa.right = expr.substr(bracket_end + 1);
        pa.range_start = 0;
        pa.range_end   = 0;
        
        if (range.empty())
        {
            // empty range
            return true;
        }

        
        size_t colon = range.find(':');
        if (colon == std::string::npos)
            return false;
        
        

        std::string left = range.substr(0, colon);
        std::string right = range.substr(colon + 1);
        

        if (!Core::String::Parse(left, pa.range_end))
        {
            return false;
        }
        
        if (!Core::String::Parse(right,  pa.range_start))
        {
            return false;
        }

        return true;
    }

    virtual void resolveNodes(const std::string &expr, std::vector<nodeID> &node_ids) override
    {
        if (expr.find('|') != std::string::npos) {
            std::vector<std::string> tokens = Core::String::Split(expr, '|');
            resolveNodes(tokens, node_ids);
            return;
        }
        
        if (expr.find('*') != std::string::npos) {
            size_t wildcard_pos = expr.find('*');
            std::string left = expr.substr(0, wildcard_pos);
            std::string right = expr.substr(wildcard_pos + 1);
            
            for (auto it : _node_name_map)
            {
                if (wildcard_check(it.second, left, right))
                {
                    node_ids.push_back(it.first);
                }
            }
            return;
        }

        if (expr.find('[') != std::string::npos) {
            ParsedArray pa;
            if (ParseArray(expr, pa))
            {
                if (pa.range_end == 0)
                {
                    // unknown range
                    for (int i=pa.range_start; ; i++)
                    {
                        std::string namenumber = pa.get_element_name(i);
                        nodeID nn= lookupNode(namenumber);
                        if (nn == EMPTYNODE)
                            break;
                        node_ids.push_back(nn);
                    }
                }
                else
                {
                    int delta = (pa.range_start < pa.range_end) ? 1 : -1;
                    for (int i=pa.range_start; i <= pa.range_end; i+=delta)
                    {
                        std::string namenumber = pa.get_element_name(i);
                        nodeID nn= lookupNode(namenumber);
                        if (nn == EMPTYNODE)
                        {
        //                    assert(nn != EMPTYNODE);
                            nn = ngnd;
                        }

                        node_ids.push_back(nn);
                    }
                    
                    int valid = 0;
                    for (auto nn : node_ids) {
                        if (nn != ngnd)
                            valid++;
                    }
                    
                    if (valid == 0)
                    {
                        printf("Empty register: %s\n", expr.c_str());
    //                    assert(0);
                    }
                }
                return;
            }
        }

        
        nodeID nn = lookupNode(expr);
        if (nn == EMPTYNODE)
        {
            assert(nn != EMPTYNODE);
            nn = ngnd;
        }

        node_ids.push_back(nn);

    }


protected:
    
    nodeID _max_nodeid = 0;

    // maps node names -> node IDs
    std::unordered_map<std::string, nodeID> _node_map;
    
    // maps node IDs -> node names
    std::unordered_multimap<nodeID, std::string> _node_name_map;
};


wire_node_resolver_ptr CreateNodeResolver()
{
    return std::make_shared<node_resolver>();
}

} //
