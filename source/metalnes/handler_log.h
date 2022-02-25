

#pragma once

#include "wire_handler.h"
#include "Core/String.h"


namespace metalnes
{




class handler_log : public wire_handler
{
    int _logTriggerCount = 0;
    std::vector<wire_register_handle> _logVars;
    std::vector<int > _logVarValues;
    std::vector<int> _logBuffer;
//    std::stringstream _ss;

public:
    
    handler_log(wire_module_ptr wires, std::string prefix)
        : wire_handler(wires, prefix)
    {
        _wires->add_handler([this](){
            this->captureLog();
        });
    }
    
    
    void captureLog()
    {
    //    if (_logCount <= 0)
    //    {
    //        return;
    //    }
    //
    //    if (_logCount > 0)
    //    {
    //        _logCount--;
    //    }

        if (_logVars.empty())
            return;

        bool modified = false;
        for(size_t i = 0; i < _logTriggerCount; i++) {
            int value = _logVars[i].get();
            
            if (value != _logVarValues[i+1]) {
                _logVarValues[i+1] = value;
                modified = true;
            }
        }

        if (!modified)
        {
            return;
        }
        
        _logVarValues[0] = getTime();

        for(size_t i = _logTriggerCount; i < _logVars.size(); i++) {
            int value = _logVars[i].get();
            _logVarValues[i+1] = value;
        }



        _logBuffer.insert(_logBuffer.end(), _logVarValues.begin(), _logVarValues.end());
        flushLog();
    }

//    virtual void handle() override
//    {
//        captureLog();
//    }
//    
    
    void flushLog()
    {
        if (_logBuffer.empty())
            return;
        
        size_t count = _logVars.size() + 1;
        for(size_t i =0; i < _logBuffer.size(); i += count) {
            int time = _logBuffer[i];
            
            std::stringstream _ss;

            _ss.clear();
            logFormat(_ss, time, _logVars, &_logBuffer[i + 1] );
            logOutput(_ss.str());
        }
        _logBuffer.clear();
        
    }


    void logOutput(const std::string &str)
    {
        log_write(str);
    }


    void logFormat(std::stringstream &ss, int time, const std::vector<wire_register_handle> &vars, const int *values)
    {
        char buffer[4096];
        snprintf(buffer, sizeof(buffer), "[%02d] %08d ",
               0,
//               (int)(time / 2)
                 (int)time
               );
        
        ss << buffer;
        
        int i =0;
        for (const auto &var : vars)
        {
            if (i > 0) {
                ss << ' ';
            }
            
            int value = values[i];
            
            ss << var.reg->getName();
            ss << ':';
            
            int size  = var.reg->getBitCount();
            if (size == 1)
            {
                ss << ((value) ? '1' : '0');
            }
            else if (size <= 4)
            {
                snprintf(buffer, sizeof(buffer), "%01X", value);
                ss << buffer;
            }
            else if (size <= 8)
            {
                snprintf(buffer, sizeof(buffer), "%02X", value);
                ss << buffer;
            }
            else
            {
                snprintf(buffer, sizeof(buffer), "%04X", value);
                ss << buffer;
            }
            i++;
        }
        
        ss << std::endl;
    }
    
    void setTrace(const std::string &trace)
    {
        _logVars.clear();
        
        auto nodes = Core::String::Split(trace, ',', true);
        
        _logTriggerCount = (int)nodes.size();
        

        for(std::string node : nodes) {
            if (node == "-")
            {
                _logTriggerCount = (int)_logVars.size();
                continue;
            }
            
            auto reg = resolveRegister(node);
            _logVars.push_back(std::move(reg));
        }
        
        _logVarValues.clear();
        _logVarValues.resize( _logVars.size() + 1 );
        
    }


};






}
