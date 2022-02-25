

#include <thread>
#include <mutex>
#include <condition_variable>
#include <stdarg.h>
#include "logger.h"



class logbuffer
{
    std::mutex  _mutex;
    std::thread _thread;
    std::condition_variable _cvar;
    bool _done = false;
    
    std::string _buffer;

    
    void emit(const std::string_view str)
    {
        fwrite(str.data(), sizeof(str[0]), str.size(), stdout);
    }
    
    void thread_func()
    {
        SetCurrentThreadName("logbuffer");

        std::string str;
        str.reserve(_buffer.capacity());
        while (read(str))
        {
            emit(str);
        }
    }

public:
    
    logbuffer()
    {
        _buffer.reserve(64 * 1024);
        
        _thread = std::thread( [this]{
            thread_func();
        });
    }
    
    virtual ~logbuffer()
    {
        {
            std::unique_lock<std::mutex> lock(_mutex);
            _done = true;
            _cvar.notify_all();
        }
        
        _thread.join();
    }

    
    void write(const std::string_view str)
    {
        std::unique_lock<std::mutex> lock(_mutex);
        _buffer.append(str);
        _cvar.notify_all();
        
    }
    
    bool read(std::string &out_str)
    {
        std::unique_lock<std::mutex> lock(_mutex);

        _cvar.wait(lock, [this] {
            return _done || !_buffer.empty();
        });
        
        // swap with buffer out
        _buffer.swap(out_str);
        _buffer.clear();
        
        return !out_str.empty();
    }
    
    void flush()
    {
        std::unique_lock<std::mutex> lock(_mutex);
        emit(_buffer);
    }
};


static logbuffer *_logbuffer = new logbuffer();
//static logbuffer *_logbuffer;

void log_write(const std::string_view str)
{
    if (_logbuffer)
    {
        _logbuffer->write(str);
    }
    else
    {
        fwrite(str.data(), sizeof(str[0]), str.size(), stdout);
    }
}

void log_flush()
{
    if (_logbuffer)
        _logbuffer->flush();
}

void log_printf(const char *format, ...)
{
    char buffer[16 * 1024];

    va_list args;
    va_start(args, format);
    int result = vsnprintf(buffer, sizeof(buffer), format, args);
    (void)result;
    va_end(args);
    buffer[sizeof(buffer)-1] = '\0';
    
    log_write(buffer);
}
