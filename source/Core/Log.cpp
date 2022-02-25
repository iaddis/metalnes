
#ifdef WIN32
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
//#define va_copy(a,b) (a)=(b);
#endif

#ifdef __APPLE__
#include <pthread.h>
#endif


#define USE_SYSLOG 0 //(defined(__APPLE__) || defined(__linux__))

#include <assert.h>
#include <stdarg.h>
#if USE_SYSLOG
#include <syslog.h>
#endif

#include <mutex>

#include "Core/Log.h"
#include "Core/String.h"
#include "Core/DateTime.h"
#include "Core/StopWatch.h"

namespace Log {

static std::mutex sLogMutex;

#ifdef WIN32
static bool	   sLogDebugger = true;
#endif
static bool    sLogStdOut = true;
static FILE *  sLogFile = NULL;
static std::string *sLogStringCapture = nullptr;


void BeginCapture()
{
     std::lock_guard<std::mutex> lock(sLogMutex);
     delete sLogStringCapture;
     sLogStringCapture = new std::string();
}

std::string EndCapture()
{
     std::string result;
     
     std::lock_guard<std::mutex> lock(sLogMutex);
     
     if (sLogStringCapture) {
          result = *sLogStringCapture;
          delete sLogStringCapture;
          sLogStringCapture = nullptr;
     }
     
     
     return result;
}


void OpenFile(std::string path, std::string logId)
{
     CloseFile();
     
     if (!path.empty())
     {
          sLogFile = fopen(path.c_str(), "wt");
     }
}

void CloseFile()
{
     if (sLogFile)
     {
          fclose(sLogFile);
          sLogFile = NULL;
     }
}

Core::StopWatch sLogTime;
Core::StopWatch sLogDelta;

/*
 //		std::string timeStamp = Core::Time::Now().ToLocalString();
 
 //        double delta = sLogDelta.GetElapsedMicroSeconds()
 //        sLogDelta.Restart();
 
 //        double time = sLogTime.GetElapsedMilliSeconds();
 char prefix[256];
 prefix[0] = 0;
 //        sprintf(prefix, "%8.3f (%9.3f) : ", time, delta);
 */

/*static*/
static void Print(const char *str)
{
#ifdef WIN32
     if (sLogDebugger && IsDebuggerPresent())
     {
          OutputDebugStringA(str);
     }
#endif
     
     if (sLogStringCapture)
     {
          std::lock_guard<std::mutex> lock(sLogMutex);
          if (sLogStringCapture)
               (*sLogStringCapture) += str;
          return;
     }
     
     
     if (sLogStdOut)
     {
          fputs(str, stdout);
     }
     
     if (sLogFile)
     {
          fputs(str, sLogFile);
          fflush(sLogFile);
     }
}



void Writev(const char *format, va_list args, bool newline)
{
     static constexpr int capacity = 16 * 1024;
     
     char buffer[capacity];
     
     // print to local buffer
     va_list argscopy;
     va_copy(argscopy, args);
     int len = vsnprintf(buffer, capacity - 2, format, argscopy);
     va_end(argscopy);
     
     if (len < 0 || (len >= capacity - 2))
     {
          // string is too long
          std::string str = Core::String::FormatV(format, args);
          if (newline)
          {
               str += '\n';
          }
          Print(str.c_str());
          return;
     }
     
     if (newline)
     {
          // append newline
          buffer[len++] = '\n';
          buffer[len++] = 0;
     }
     
     // print buffer
     Print(buffer);
     
}

/*static*/
void Printf(const char *format, ...)
{
     va_list args;
     va_start(args, format);
     Writev(format, args, false);
     va_end(args);
}


/*static*/
void Write(const char *format, ...)
{
     va_list args;
     va_start(args, format);
     Writev(format, args, false);
     va_end(args);
}

/*static*/
void WriteLine(const char *format, ...)
{
     va_list args;
     va_start(args, format);
     Writev(format, args, true);
     va_end(args);
}

/*static*/
void Error(const char *format, ...)
{
     va_list args;
     va_start(args, format);
     Writev(format, args, true);
     va_end(args);
}

/*static*/
void Warning(const char *format, ...)
{
     va_list args;
     va_start(args, format);
     Writev(format, args, true);
     va_end(args);
}

}

