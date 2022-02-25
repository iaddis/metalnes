
#pragma once

#include <string>
#include <stdarg.h>


namespace Log
{
    void OpenFile(std::string path, std::string logId);
    void CloseFile();
    
    void BeginCapture();
    std::string EndCapture();

    void Printf(const char *format, ...);

    void Write(const char *format, ...);
	void Writev(const char *format, va_list args, bool newline);
	void WriteLine(const char *format, ...);
    void Error(const char *format, ...);
    void Warning(const char *format, ...);
   
} // namespace Log
