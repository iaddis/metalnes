#pragma once

#include <stdint.h>
#include <string>
#include <time.h>

namespace Core
{
    class Time;
    class SplitTime;

    // a time split up into date and time components (year, month, day, hours, minutes, seconds)
    class SplitTime
    {
    public:
        explicit SplitTime(const struct tm &tm);
        SplitTime(int year, int month, int day, int hour, int minute, int second);

        std::string ToString() const;
        
    private:
        struct tm   mTime;
    };

    // a point in time, stored as the number of seconds since the epoch (Jan 1, 1970)
    class Time
    {
    public:
        Time();
        explicit Time(time_t t);
#ifndef WIN32
        explicit Time(timespec t);
#endif
        
        static Time Now();
        static Time FromUTC(int year, int month, int day, int hour, int minute, int second);
        static Time FromLocal(int year, int month, int day, int hour, int minute, int second);

        SplitTime   ToLocal() const;
        SplitTime   ToUTC() const;
        std::string ToLocalString() const;
        std::string ToUTCString() const;
        time_t      ToCTime() const;
 
        double      operator-(const Time &a);
        Time        operator+(double a);
        
    private:
        int64_t           mTime;        // seconds since epoch
    };
    

    
} // namespace Core

