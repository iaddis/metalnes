
#pragma once

#include <deque>
#include <functional>
#include <mutex>


class dispatch_queue
{
public:
    using Func = std::function<void ()>;
    
    void enqueue(Func f)
    {
        std::lock_guard<std::mutex> lock(_mutex);
        _queue.push_back( f );
    }

    void dispatch()
    {
        for (;;)
        {
            Func func = nullptr;
            
            // dequeue function
            {
                std::lock_guard<std::mutex> lock(_mutex);
                if (_queue.empty())
                    break;
                
                func = _queue.front();
                _queue.pop_front();
            }
            
            
            // invoke
            func();
        }
    }

protected:
    std::deque<Func> _queue;
    std::mutex       _mutex;

};
