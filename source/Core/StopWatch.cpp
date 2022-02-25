
#ifdef WIN32
#include <Windows.h>
#include <mmsystem.h>
#endif

#ifdef __APPLE__
#include <mach/mach_time.h>
#endif

#ifdef __linux__
#include <time.h>
#endif

#ifdef EMSCRIPTEN
#include <emscripten.h>
#endif


#include "Core/StopWatch.h"


namespace Core
{
	int64_t  StopWatch::GetTicks()
	{
#if defined(WIN32)
		LARGE_INTEGER count;
		QueryPerformanceCounter(&count);
		return (int64_t)count.QuadPart;
#elif defined(__APPLE__)
		return mach_absolute_time();
#elif defined(__linux__)
		struct timespec ts;
		if (clock_gettime(CLOCK_REALTIME, &ts) < 0)
		{
			return 0;
		}

		// convert to nanoseconds
		int64_t ns = ((int64_t )ts.tv_sec) * 1000000000LL;
		ns += ts.tv_nsec;
		return ns;
#elif defined(EMSCRIPTEN)
		// convert to nano seconds
		return (int64_t)(emscripten_get_now() * 1000000.0);
#else
#error Platform not supported
#endif
	}

	double StopWatch::ConvertTicksToSeconds(int64_t ticks)
	{
#if defined(WIN32)
		LARGE_INTEGER freq;
		QueryPerformanceFrequency(&freq);
		return (double)ticks / (double)freq.QuadPart;
#elif defined(__APPLE__)
		
		static double rate = 0.0;
		if (rate == 0.0)
		{
			mach_timebase_info_data_t info;
			mach_timebase_info(&info);
			rate = 1000000000.0 * ((double)info.denom) / ((double)info.numer);
		}
		return ((double)ticks) / rate; 
#elif defined(__linux__)
		return ((double)ticks) * 1e-9;
#elif defined(EMSCRIPTEN)
		return ((double)ticks) * 1e-9;
#else
#error Platform not supported
#endif
	}

}