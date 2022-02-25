#pragma once

#include "wire_module.h"
#include "dispatch_queue.h"
#include <thread>
#include <functional>
#include <atomic>

namespace metalnes {

class wire_thread
{
public:
    wire_thread(const wire_thread &other) = delete;
    wire_thread& operator=(const wire_thread & rhs) = delete;
    
    wire_thread(wire_module_ptr wires)
    :_wires(wires)
    {
        _running = true;
        _done = false;
    }
    
    virtual ~wire_thread()
    {
        stopThread();
    }
    
    void startThread()
    {
        assert(!_thread.joinable());
        
        _done = false;
        _running = true;
        _thread = std::thread ( [this] {
            this->mainThread();
        });
    }
    
    void stopThread()
    {
        _done = true;
        _running = false;
        if (_thread.joinable())
            _thread.join();
    }

    
    void enqueue(dispatch_queue::Func f)
    {
        _queue.enqueue(f);
    }
    
    void invoke( std::function<void ()> f)
    {
        std::lock_guard<std::mutex> lock(_mutex);
        f();
    }
    
    void add_handler(std::function<void ()> handler)
    {
        std::lock_guard<std::mutex> lock(_mutex);
        _wires->add_handler(handler);
    }
    
    void step()
    {
        std::lock_guard<std::mutex> lock(_mutex);
        _wires->step(1);
    }


    void step(int count)
    {
        std::lock_guard<std::mutex> lock(_mutex);
        _wires->step(count);
    }
    
    bool isRunning() const
    {
        return _running;
    }
    
    void setRunning(bool running)
    {
        _running = running;
    }
    
    
    void toggleRunning()
    {
        _running = !_running;
    }

protected:
    std::mutex _mutex;
    std::thread _thread;

    wire_module_ptr _wires;
    dispatch_queue _queue;
    int _stepCount = 1024;
    std::atomic<bool> _running;
    std::atomic<bool> _done;

    
    void mainThread()
    {
        SetCurrentThreadName("system-simulation");
        while (!_done)
        {
            if (_running)
            {
                step(_stepCount);
            }
            else
            {
                std::this_thread::sleep_for(std::chrono::milliseconds(1));
            }
            
            _queue.dispatch();
        }
    }


};


} // namespace
