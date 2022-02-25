
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Accelerate/Accelerate.h>
#if TARGET_OS_IPHONE
#import <AVFoundation/AVFoundation.h>
#else
#import <CoreAudio/CoreAudio.h>
#endif

#include <vector>

#define CheckStatus() \
    assert( status == 0 )


struct AudioSample
{
    float left;
    float right;
};

class AudioSource
{
public:
    AudioSource() = default;
    virtual ~AudioSource() = default;
    
    virtual bool render(AudioSample *samples, size_t count) = 0;
    
    AudioComponentInstance      _output;
};


static OSStatus renderCallback (void                        *inRefCon,
                                AudioUnitRenderActionFlags    * ioActionFlags,
                                const AudioTimeStamp         * inTimeStamp,
                                UInt32                        inOutputBusNumber,
                                UInt32                        inNumberFrames,
                                AudioBufferList                * ioData)
{
    AudioSource *source = (AudioSource *)inRefCon;

    
    // clear all buffers
    for (int i=0; i < ioData->mNumberBuffers; i++)
    {
        memset(ioData->mBuffers[i].mData, 0, ioData->mBuffers[i].mDataByteSize);
    }

    // render to first buffer...
    AudioBuffer *buffer = &ioData->mBuffers[0];
    if (inNumberFrames * sizeof(AudioSample) <= buffer->mDataByteSize)
    {
        if (!source->render( (AudioSample *)buffer->mData, inNumberFrames))
        {
            if (source->_output) {
                AudioOutputUnitStop(source->_output);
//                AudioUnitUninitialize(source->_output);
//                AudioComponentInstanceDispose(source->_output);
                source->_output = nullptr;
            }
//            delete source;
        }
    }

    
    return noErr;
}

class BufferAudioSource : public AudioSource
{
public:
    virtual bool render(AudioSample *samples, size_t count) override
    {
        for (size_t i=0; i < count; i++)
        {
            if (_position < _samples.size()) {
                float v = _samples[_position++];
                samples[i] = {v, v};
            } else {
                samples[i] = {0, 0};
            }
        }
        
        return (_position < _samples.size());
    }
  
    size_t             _position = 0;
    std::vector<float> _samples;
};


void AudioPlaySound(double sample_rate, const float *sample_data, size_t sample_count)
{
    
    AudioComponentInstance      output;
    
    OSStatus status;
    
    AudioComponentDescription desc = {0};
    desc.componentType = kAudioUnitType_Output;
#if TARGET_OS_IPHONE
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
#else
    desc.componentSubType = kAudioUnitSubType_HALOutput;
    
#endif
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    
    
    // Get component
    AudioComponent comp = AudioComponentFindNext(NULL, &desc);
    status = AudioComponentInstanceNew(comp, &output);
    CheckStatus();
    
    
    // Enable IO for playback
    UInt32 flag = 1;
    status = AudioUnitSetProperty(output,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  0,
                                  &flag,
                                  sizeof(flag));
    CheckStatus();
    
    
    AudioStreamBasicDescription fmt;
    UInt32 size = sizeof(fmt);
    
    
    status = AudioUnitGetProperty(output,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  0,
                                  &fmt,
                                  &size );
    CheckStatus();
    
    
    fmt.mSampleRate         = sample_rate;
    fmt.mFormatID           = kAudioFormatLinearPCM;
    fmt.mFormatFlags        = kAudioFormatFlagsNativeFloatPacked; //kAudioFormatFlagIsPacked | kAudioFormatFlagIsFloat;
    fmt.mChannelsPerFrame   = 2;
    fmt.mBitsPerChannel     = 32;
    fmt.mBytesPerFrame      = fmt.mBitsPerChannel * fmt.mChannelsPerFrame / 8;
    fmt.mBytesPerPacket     = fmt.mBytesPerFrame * fmt.mFramesPerPacket;
    
    size = sizeof(fmt);
    status = AudioUnitSetProperty(output,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  0,
                                  &fmt,
                                  size );
    CheckStatus();
    
    

    
    status = AudioUnitInitialize(output);
    CheckStatus();
    

    status = AudioUnitGetProperty(output,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  0,
                                  &fmt,
                                  &size );
    CheckStatus();
    
    
    BufferAudioSource *source = new BufferAudioSource();
    source->_output = output;
    source->_samples.assign( sample_data, sample_data + sample_count);
    
    AURenderCallbackStruct cb;
    cb.inputProc = renderCallback;
    cb.inputProcRefCon = source;
    status = AudioUnitSetProperty(output,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Output,
                                  0,
                                  &cb,
                                  sizeof(cb)
                                  );
    CheckStatus();
    
    status = AudioOutputUnitStart(output);
    CheckStatus();

}
