#pragma once
#include "wire_module.h"
#include "dispatch_queue.h"
#include <thread>
#include "Core/String.h"

namespace metalnes {


//using wire_register_handle = wire_register_ptr;
//using wire_node_handle = nodeID;
using wire_memory_handle = wire_memory_ptr;

struct wire_register_handle
{
    wire_register_ptr reg;
    
    const std::string &name() const
    {
        return reg->getName();
    }

    int size() const
    {
        return reg->getBitCount();
    }

    int get() const
    {
        return reg->read();
    }
    
    void set(int bits)
    {
        reg->write(bits);
    }
    
    void floatBits()
    {
        reg->floatBits();
    }

    
    wire_register_handle &operator=(int v)
    {
        set(v);
        return *this;
    }
    
    operator int() const
    {
        return get();
    }
};

struct wire_node_handle
{
    nodeID node_id;
    wire_module_ptr wires;
    
    
    bool isNodeHigh() const
    {
        return wires->isNodeHigh( node_id );
    }

    void setFloat()
    {
        wires->setFloat( node_id );
    }

    void setHigh()
    {
        wires->setHigh( node_id  );
    }

    void setLow()
    {
        wires->setLow( node_id  );
    }
    
    bool get() const
    {
        return wires->isNodeHigh( node_id );
    }
    
    void set(bool state)
    {
        if (state) setHigh(); else setLow();
    }


    wire_node_handle &operator=(int i)
    {
        set( i!=0 );
        return *this;
    }

    wire_node_handle &operator=(bool v)
    {
        set(v);
        return *this;
    }
    
    operator bool() const
    {
        return get();
    }
};


#define wire_register_field(_VAR, _NAME)   wire_register_handle _VAR =  { resolveRegister(_NAME) }
#define wire_memory_field(_VAR, _NAME)     wire_memory_handle _VAR =  { resolveMemory(_NAME) }
#define wire_field(_VAR, _NAME)            wire_node_handle _VAR =  { resolveNode(_NAME) }



class wire_handler 
{
protected:
    wire_module_ptr _wires;
    std::string     _prefix;
    
    
    std::string remapName(std::string name)
    {
        // remap many nodes collected together using | operator
        if (name.find('|') != std::string::npos) {
            std::string expr;
            std::vector<std::string> tokens = Core::String::Split(name, '|');
            for (auto token : tokens)
            {
                expr += combinePrefix(_prefix, token);
                expr += '|';
                
            }
            if (!expr.empty())
                expr.pop_back();
            return expr;
        }

        return combinePrefix(_prefix, name);
    }
    
    
    wire_node_handle resolveNode(const std::string &name)
    {
        std::string fullname = remapName(name);
        nodeID nn = _wires->lookupNode(fullname);
        
        if (nn == EMPTYNODE) {
            printf("lookupNode failed %s\n", fullname.c_str());
            assert(0);
        }
        return wire_node_handle { nn, _wires };
    }

    wire_register_handle resolveRegister(const std::string &name)
    {
        std::string fullname = remapName(name);
        return wire_register_handle { _wires->resolveRegister(fullname) };
    }
    
    wire_memory_ptr resolveMemory(const std::string &name)
    {
        std::string fullname = remapName(name);
        return _wires->resolveMemory(fullname);
    }
    

public:
    
    wire_handler(wire_module_ptr wires, std::string prefix)
    :_wires(wires), _prefix(prefix)
    {
        
    }
    
    virtual ~wire_handler() = default;
    
    wire_handler(const wire_handler &other) = delete;
    wire_handler& operator=(const wire_handler & rhs) = delete;


    template<typename T, typename... TArgs>
    T *add_handler(std::string prefix, TArgs&&... args)
    {
        std::string fullname = remapName(prefix);
        
//        log_printf("add_handler '%s'\n", fullname.c_str());


        T *handler = new T(_wires, fullname, std::forward<TArgs>(args)...);
        return handler;
    }


    template<typename T, typename... TArgs>
    std::vector<T *> register_handlers(std::string expr, TArgs&&... args)
    {
        std::vector<T *> handlers;
        
        std::vector<nodeID> list;
        _wires->resolveNodes(expr, list);
        for (auto nn : list)
        {
            std::string name = _wires->getNodeName(nn);
            
            while(!name.empty() && name.back() != '.')
                name.pop_back();
            T *handler = add_handler<T>(name, std::forward<TArgs>(args)...);
            handlers.push_back(handler);
        }
        return handlers;
    }

        
    
    void add_edge_callback(wire_node_handle &handle, int state, std::function<void ()> callback )
    {
        std::vector<nodeID> node_ids {handle.node_id};
        _wires->add_callback(node_ids, [=](){
            if (this->isNodeHigh(handle) == state)
            {
                callback();
            }
            
        });
    }
    
    
    void add_callback(wire_register_handle reg, std::function<void ()> callback )
    {
        _wires->add_callback(reg.reg->getNodes(), callback);
    }


/*
    
    void add_callback(const std::string &node_expr, std::function<void ()> callback )
    {
        std::string expr;
        if (node_expr.find('|') != std::string::npos) {
            std::vector<std::string> tokens = Core::String::Split(node_expr, '|');
            for (auto token : tokens)
            {
                expr += remapName(token);
                expr += '|';
                
            }
            if (!expr.empty())
                expr.pop_back();
        } else {
            expr = remapName(node_expr);
        }
        

        std::vector<nodeID> node_ids;
        _wires->resolveNodes(expr, node_ids);
        if (!node_ids.empty())
        {
            _wires->add_callback(node_ids, callback);
        }
        else
        {
            assert(0);
        }
    }*/



    bool isNodeHigh(wire_node_handle handle)
    {
        return _wires->isNodeHigh( handle.node_id );
    }

    void setFloat(wire_node_handle handle )
    {
        return _wires->setFloat(  handle.node_id );
    }

    void setHigh(wire_node_handle handle)
    {
        return _wires->setHigh(  handle.node_id  );
    }

    void setLow(wire_node_handle handle)
    {
        return _wires->setLow(  handle.node_id  );
    }

    bool isNodeHigh(const char *name)
    {
        return isNodeHigh(resolveNode(name));
    }

    void setFloat(const char *name)
    {
        setFloat(resolveNode(name));
    }

    void setHigh(const char *name)
    {
        setHigh(resolveNode(name));
    }

    void setLow(const char *name)
    {
        setLow(resolveNode(name));
    }

    
    //
    // register stuff
    //
    
    
    int readBits(const wire_register_handle &reg )
    {
        return reg.get();
    }

    void writeBits(wire_register_handle &reg, int value )
    {
        reg.set(value);
    }
    
    void floatBits(wire_register_handle &reg)
    {
        reg.floatBits();
    }


    int getTime()
    {
        return _wires->getTime();
    }

};






}
