

#pragma once

#include "wire_defs.h"

namespace metalnes {


// this class manages the "node-id space" and resolves node names to ids
class wire_node_resolver
{
public:
    wire_node_resolver() = default;
    virtual ~wire_node_resolver() = default;
    
    virtual nodeID resolve(const noderef &ref) = 0;
    virtual nodeID lookupNode(const std::string &name) = 0;
    virtual const char *getNodeName(nodeID node_id) = 0;
    
    virtual nodeID allocNodes(int alignment, int count) = 0;
    
    virtual void addNode(nodeID nn, const std::string &name) = 0;
    virtual void resolveNodes(const noderef &node_ref, std::vector<nodeID> &node_ids) = 0;
    virtual void resolveNodes(const std::vector<std::string> &node_names, std::vector<nodeID> &node_ids) = 0;
    virtual void resolveNodes(const std::string &expr, std::vector<nodeID> &node_ids) = 0;
};

using wire_node_resolver_ptr = std::shared_ptr<wire_node_resolver>;

wire_node_resolver_ptr CreateNodeResolver();

} //
