
#pragma once


#include <stdint.h>


namespace Core
{

    class StopWatch
    {
    public:
        StopWatch(bool running = true)
            :
            mIsRunning(running),
            mElapsed(0),
            mLastTicks(GetTicks())
        {
        }

		static StopWatch StartNew()
		{
			return StopWatch(true);
		}

        bool        IsRunning()
        {
            return mIsRunning;
        }

        void        Start()
        {
            if (!mIsRunning)
            {
                mLastTicks = GetTicks();
                mIsRunning = true;
            }
        }

        void        Stop()
        {
            UpdateElapsed();
            mIsRunning = false;
        }

        void Reset()
        {
            mElapsed = 0;
            mLastTicks = GetTicks();
        }

		void Restart()
		{
			Reset();
			Start();
		}

        double      GetElapsedSeconds()
        {
            UpdateElapsed();
            return ConvertTicksToSeconds(mElapsed);
        }

        double      GetElapsedMilliSeconds()
        {
            return GetElapsedSeconds() * 1000.0;
        }

        double      GetElapsedMicroSeconds()
        {
            return GetElapsedSeconds() * 1000000.0;
        }


		static int64_t  GetTicks();
		static double   ConvertTicksToSeconds(int64_t ticks);

    protected:
        void        UpdateElapsed()
        {
            if (mIsRunning)
            {
                // get time
                int64_t time = GetTicks();
                // update elapsed time
                mElapsed += (time - mLastTicks);
                // set last tcks
                mLastTicks = time;
            }
        }

    private:
        bool        mIsRunning;
        int64_t     mElapsed;
        int64_t     mLastTicks;

    };


}