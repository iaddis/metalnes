
#include <stdlib.h>
#include <memory.h>
#include "Core/DateTime.h"
#include "Core/String.h"


namespace Core
{
    class TimeSpan;
    class Time;
    class SplitTime;
    


// SplitTime a time split up into date and time components (year, month, day, hours, minutes, seconds)
// a SplitTime has an associated timezone, either local or UTC
    SplitTime::SplitTime(const struct tm &tm)
    : mTime(tm)
    {
    }
    
    SplitTime::SplitTime(int year, int month, int day, int hour, int minute, int second)
    {
        memset(&mTime, 0, sizeof(mTime));
        mTime.tm_sec = second;
        mTime.tm_min = minute;
        mTime.tm_hour= hour;
        mTime.tm_mday= day;
        mTime.tm_mon = month;
        mTime.tm_year= year - 1900;
    }
    
    std::string SplitTime::ToString() const
    {
		const char *zone = "Z";

#ifndef WIN32
		if (mTime.tm_zone)
		{
			zone = mTime.tm_zone;
		} 
#endif
        return Core::String::Format("%04d-%02d-%02dT%02d:%02d:%02d%s",
                            mTime.tm_year + 1900, mTime.tm_mon + 1, mTime.tm_mday,
                            mTime.tm_hour, mTime.tm_min, mTime.tm_sec, 
							zone
                            );
    }
    
    
//
// a point in time, stored as the number of seconds since the epoch (Jan 1, 1970)
//
    
    Time::Time()
        : mTime(0) {}
    
    Time::Time(time_t t)
        : mTime( (int64_t) t) 
    {
    }
    
#ifndef WIN32
    Time::Time(timespec t)
        : mTime( (int64_t) t.tv_sec) 
    {
    }
#endif
    
    /*static*/
    Time Time::Now()
    {
        time_t t;
        time(&t);
        return Time(t);
    }
    
    /*static*/ 
    Time Time::FromUTC(int year, int month, int day, int hour, int minute, int second)
    {
        struct tm lt;
        memset(&lt, 0, sizeof(lt));
        lt.tm_sec = second;
        lt.tm_min = minute;
        lt.tm_hour= hour;
        lt.tm_mday= day;
        lt.tm_mon = month;
        lt.tm_year= year - 1900;
#ifdef WIN32
        return Time( _mkgmtime(&lt));
#else
        return Time( timegm(&lt));
#endif
    }
    
    /*static*/ 
    Time Time::FromLocal(int year, int month, int day, int hour, int minute, int second)
    {
        struct tm lt;
        memset(&lt, 0, sizeof(lt));
        lt.tm_sec = second;
        lt.tm_min = minute;
        lt.tm_hour= hour;
        lt.tm_mday= day;
        lt.tm_mon = month;
        lt.tm_year= year - 1900;
        return Time( mktime(&lt));
    }
    
    
    std::string Time::ToUTCString() const
    {
        return ToUTC().ToString();
    }

    std::string Time::ToLocalString() const
    {
        return ToLocal().ToString();
    }

    SplitTime Time::ToLocal() const
    {
        struct tm t;
        time_t tval = ToCTime();
#ifdef WIN32
        localtime_s(&t, &tval);
#else
        localtime_r(&tval, &t);
#endif
        return SplitTime(t);
    }
    
    SplitTime Time::ToUTC() const
    {
        struct tm t;
        time_t tval = ToCTime();
#ifdef WIN32
        gmtime_s(&t, &tval);
#else
        gmtime_r(&tval, &t);
#endif
        return SplitTime(t);
    }
    
    time_t Time::ToCTime() const
    {
        return (time_t)mTime;
    }
    
    double Time::operator-(const Time &a)
    {
        return difftime( this->ToCTime(), a.ToCTime() );
    }
    
    Time Time::operator+(double a)
    {
        return Time(time_t(mTime) + time_t(a) );
    }
    
} // namespace Core


