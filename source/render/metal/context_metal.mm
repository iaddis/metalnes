

#include <TargetConditionals.h>
#import <MetalKit/MetalKit.h>

#include <memory>
#include <map>
#include <set>
#include <unordered_map>
#include <iostream>
#include <thread>
#include <array>

#include "render/context.h"
#include "context_metal.h"

#include "Core/Path.h"
#include "Core/StopWatch.h"
#include "Core/File.h"
#include "Core/Log.h"

#include "../../../external/hlsl2glslfork/include/hlsl2msl.h"

#if TARGET_OS_OSX
#define RESOURCE_OPTIONS (MTLResourceStorageModeManaged)
#else
#define RESOURCE_OPTIONS (MTLResourceStorageModeShared)
#endif


#define PROFILE_FUNCTION()
#define PROFILE_FUNCTION_CAT(__name)
#define PROFILE_GPU()



namespace render {
namespace metal {




struct PipelineKey
{
    MTLPixelFormat  pixelFormat = MTLPixelFormatInvalid;
    bool blendEnable = false;
    BlendFactor sourceFactor;
    BlendFactor destFactor;
    uint8_t writeMask = 0xF;
    int vertexTypeID = 0;
   
    bool operator==(const PipelineKey& b) const
    {
        return
           sourceFactor == b.sourceFactor
        && destFactor == b.destFactor
        && blendEnable == b.blendEnable
        && writeMask == b.writeMask
        && pixelFormat == b.pixelFormat
        && vertexTypeID == b.vertexTypeID
        ;
    }
    

    struct Hash
    {
        size_t operator()(const PipelineKey &key ) const
        {
            return 0
            ^ (std::hash<int>()((int)key.sourceFactor) << 0)
            ^ (std::hash<int>()((int)key.destFactor) << 8)
            ^ (std::hash<int>()((int)key.blendEnable) << 10)
            ^ (std::hash<int>()((int)key.pixelFormat) << 16)
            ^ (std::hash<int>()((int)key.writeMask) << 12)
            ^ (std::hash<int>()((int)key.vertexTypeID) << 20)
                  ;
        }
    };

};



struct SamplerKey
{
    SamplerAddress addr;
    SamplerFilter  filter;
    
    bool operator==(const SamplerKey& b) const
    {
        return addr == b.addr
        && filter == b.filter
        ;
    }
    
    struct Hash
    {
        size_t operator()(const SamplerKey &key ) const
        {
            return 0
            ^ (std::hash<int>()((int)key.addr) << 1)
            ^ (std::hash<int>()((int)key.filter) << 8)
                  ;
        }
    };

};




PixelFormat ConvertFormat(MTLPixelFormat format)
{
    switch (format)
    {
        case MTLPixelFormatInvalid:
            return PixelFormat::Invalid;
            
        case MTLPixelFormatA8Unorm:
            return PixelFormat::A8Unorm;
        case MTLPixelFormatRGBA8Unorm:
            return PixelFormat::RGBA8Unorm;
        case MTLPixelFormatRGBA8Unorm_sRGB:
            return PixelFormat::RGBA8Unorm_sRGB;
        case MTLPixelFormatBGRA8Unorm:
            return PixelFormat::BGRA8Unorm;
        case MTLPixelFormatBGRA8Unorm_sRGB:
            return PixelFormat::BGRA8Unorm_sRGB;
        case MTLPixelFormatRGBA16Unorm:
            return PixelFormat::RGBA16Unorm;
        case MTLPixelFormatRGBA16Snorm:
            return PixelFormat::RGBA16Snorm;
        case MTLPixelFormatRGBA16Float:
            return PixelFormat::RGBA16Float;
        case MTLPixelFormatRGBA32Float:
            return PixelFormat::RGBA32Float;
        case MTLPixelFormatBGR10A2Unorm:
            return PixelFormat::BGR10A2Unorm;
            
#if TARGET_OS_IPHONE
        case MTLPixelFormatBGR10_XR:           // ios only
            return PixelFormat::BGR10_XR;
        case MTLPixelFormatBGR10_XR_sRGB:           // ios only
            return PixelFormat::BGR10_XR_sRGB;
#endif
        default:
            assert(0);
            return PixelFormat::Invalid;
    }
}


MTLPixelFormat ConvertFormat(PixelFormat format)
{
    switch (format)
    {
        case PixelFormat::Invalid:
            return MTLPixelFormatInvalid;
        case PixelFormat::A8Unorm:
            return MTLPixelFormatA8Unorm;
        case PixelFormat::RGBA8Unorm:
            return MTLPixelFormatRGBA8Unorm;
        case PixelFormat::RGBA8Unorm_sRGB:
            return MTLPixelFormatRGBA8Unorm_sRGB;
        case PixelFormat::BGRA8Unorm:
            return MTLPixelFormatBGRA8Unorm;
        case PixelFormat::BGRA8Unorm_sRGB:
            return MTLPixelFormatBGRA8Unorm_sRGB;
        case PixelFormat::RGBA16Unorm:
            return MTLPixelFormatRGBA16Unorm;
        case PixelFormat::RGBA16Snorm:
            return MTLPixelFormatRGBA16Snorm;
        case PixelFormat::RGBA16Float:
            return MTLPixelFormatRGBA16Float;
        case PixelFormat::RGBA32Float:
            return MTLPixelFormatRGBA32Float;
        case PixelFormat::BGR10A2Unorm:
            return MTLPixelFormatBGR10A2Unorm;
            
#if TARGET_OS_IPHONE
        case PixelFormat::BGR10_XR:           // ios only
            return MTLPixelFormatBGR10_XR;
        case PixelFormat::BGR10_XR_sRGB:           // ios only
            return MTLPixelFormatBGR10_XR_sRGB;
#endif
            
        default:
            assert(0);
            return MTLPixelFormatInvalid;
    }
}



class MetalContext;
class MetalShader;

id <MTLRenderPipelineState> CreatePipelineState(MetalShader *shader, const PipelineKey &key);

class PipelineCache
{
public:
    using State = id <MTLRenderPipelineState>;
    
    State GetOrCreatePipelineState(MetalShader *shader, const PipelineKey &key)
    {
        auto it = _map.find(key);
        if (it != _map.end()) {
            return it->second;
        }
        
        State state = CreatePipelineState(shader, key);
        if (!state) {
            // there was an error
            return nil;
        }
        _map[key] = state;
        return state;
    }
    
    
protected:
    std::unordered_map<PipelineKey, State, PipelineKey::Hash> _map;
    
    
};


class SamplerCache
{
public:
    using State = id <MTLSamplerState>;
    
    static State CreateState(id<MTLDevice> device, const SamplerKey &key)
    {
        MTLSamplerDescriptor *sd = [MTLSamplerDescriptor new];
        
        switch (key.filter)
        {
            case SAMPLER_POINT:
                sd.minFilter = MTLSamplerMinMagFilterNearest;
                sd.magFilter = MTLSamplerMinMagFilterNearest;
                sd.mipFilter = MTLSamplerMipFilterNearest;
                break;
            case SAMPLER_LINEAR:
                sd.minFilter = MTLSamplerMinMagFilterLinear;
                sd.magFilter = MTLSamplerMinMagFilterLinear;
                sd.mipFilter = MTLSamplerMipFilterLinear;
                break;
            case SAMPLER_ANISOTROPIC:
                sd.minFilter = MTLSamplerMinMagFilterLinear;
                sd.magFilter = MTLSamplerMinMagFilterLinear;
                sd.mipFilter = MTLSamplerMipFilterLinear;
                sd.maxAnisotropy = 4.0;
                break;
            default:
                assert(0);
                break;
        }
        
        switch (key.addr)
        {
            case SAMPLER_WRAP:
                sd.rAddressMode = MTLSamplerAddressModeRepeat;
                sd.sAddressMode = MTLSamplerAddressModeRepeat;
                sd.tAddressMode = MTLSamplerAddressModeRepeat;
                break;
            case SAMPLER_CLAMP:
                sd.rAddressMode = MTLSamplerAddressModeClampToEdge;
                sd.sAddressMode = MTLSamplerAddressModeClampToEdge;
                sd.tAddressMode = MTLSamplerAddressModeClampToEdge;
                break;
            default:
                assert(0);
                break;
        }
        
        return [device newSamplerStateWithDescriptor:sd];
    }
    
    State GetOrCreateState(id<MTLDevice> device, const SamplerKey &key)
    {
        auto it = _map.find(key);
        if (it != _map.end()) {
            return it->second;
        }
        
        State state = CreateState(device, key);
        if (!state) {
            // there was an error
            assert(0);
            return nil;
        }
        _map[key] = state;
        return state;
    }
    
protected:
    std::unordered_map<SamplerKey, State, SamplerKey::Hash> _map;
};

///
///
///




class MetalBuffer : public Buffer
{
public:
    MetalBuffer(id<MTLBuffer> buffer, size_t count, size_t stride, int vertexTypeID)
    :_buffer(buffer), _count(count), _stride(stride), _vertexTypeID(vertexTypeID)
    {
    }
    
    id<MTLBuffer> GetBuffer()
    {
        return _buffer;
    }
    
    int  GetBase()
    {
        return _base;
    }
    
    
    size_t  GetStride()
    {
        return _stride;
    }

    size_t  GetCount()
    {
        return _count;
    }

    
    size_t GetBaseOffset(size_t index) const {
        return _base + index * _stride;
    }
    
    int _base = 0;
    id<MTLBuffer>   _buffer;
    size_t          _count;
    size_t          _stride;
    int             _vertexTypeID;
};



class MetalBufferPool
{
public:
    MetalBufferPool(id<MTLDevice> device, size_t minCapacity)
    :_device(device), _minCapacity(minCapacity)
    {
        _frame = 0;
    }
    
    
    
    id<MTLBuffer> AllocBuffer(size_t capacity, NSString *label)
    {
        std::lock_guard<std::mutex> lock(_mutex);
        
        if (capacity < _minCapacity) capacity = _minCapacity;

        id<MTLBuffer> buffer = nil;
        
        // find right size buffer
        for (auto it = _available.begin();  it != _available.end(); ++it)
        {
            if ((*it).length >= capacity) {
                // return available buffer...
                buffer = *it;
                _available.erase(it);
                break;
            }
        }
        
        if (buffer == nil)
        {
            // allocate new buffer
            buffer =  [_device newBufferWithLength:capacity
                                         options:RESOURCE_OPTIONS];
//            LogPrint("MTLBuffer newBufferWithLength:%d\n", (int)buffer.length);
        }
        
        // set label
        if (label) {
            buffer.label = label;
        }
        
        // commit buffer
        _committed.insert( std::make_pair(_commandBuffer, buffer) );
        
        // return buffer
        return buffer;
    }

    
    void BeginCommandBuffer(  id<MTLCommandBuffer> cbuffer )
    {
        std::lock_guard<std::mutex> lock(_mutex);
        _commandBuffer = cbuffer;
        _frame++;
    }
    
    inline id<MTLCommandBuffer> GetCommandBuffer() const
    {
        return _commandBuffer;
    }
    
    void ReleaseResources( id<MTLCommandBuffer> cbuffer  )
    {
        // add buffers to available list
        std::lock_guard<std::mutex> lock(_mutex);
        
        // move committed buffers bound to this command buffer into available
        for (auto it = _committed.begin(); it != _committed.end(); )
        {
            if (it->first == cbuffer) {
                _available.push_back(it->second);
                it = _committed.erase(it);
            } else {
                it++;
            }
        }
    }

    inline int GetFrame() const
    {
        return _frame;
    }
    
protected:
    std::mutex                      _mutex;
    id<MTLCommandBuffer>            _commandBuffer = nil;
    std::vector< id<MTLBuffer> >    _available;
    
    std::multimap< id<MTLCommandBuffer>, id<MTLBuffer> > _committed;
    
    std::atomic<int>                _frame;
    
    id<MTLDevice>                   _device;
    size_t                          _minCapacity;

};

using MetalBufferPoolPtr = std::shared_ptr<MetalBufferPool>;


static size_t Align(size_t _pos, size_t alignment)
{
    if (_pos & (alignment - 1)) {
        // align position
        _pos = (_pos + (alignment - 1)) & ~(alignment - 1);
    }
    return _pos;
}



class MetalDynamicBuffer : public Buffer
{
public:
    MetalDynamicBuffer(MetalBufferPoolPtr pool)
    :  _pool(pool)
    {
    }
    
    virtual ~MetalDynamicBuffer()
    {
        Clear();
    }
    
    void SetLabel(const char *label)
    {
        if (label)
            _label = [NSString stringWithUTF8String:label];
        else
            _label = nil;
    }
    
    void Clear()
    {
        _commandBuffer = nil;
        _buffer = nil;
        _pos = 0;
        _base = 0;
    }
    
    
    virtual void WriteBytes(const void *data, size_t alignment, size_t length)
    {
        // align position
        _pos = Align(_pos, alignment);
        
        if (_buffer == nil ||
            (_commandBuffer != _pool->GetCommandBuffer()) ||
            ((_pos + length) > _buffer.length))
        {
            // alloc new buffer from pool
            _buffer  = _pool->AllocBuffer( length, _label);
            _pos = 0;
            _base = 0;
            _commandBuffer = _pool->GetCommandBuffer();
        }
        
        // copy into buffer
        uint8_t* dest = (((uint8_t *)_buffer.contents) + _pos);
        memcpy(dest, data, length);
        
#if TARGET_OS_OSX
        [_buffer didModifyRange:NSMakeRange(_pos, length)];
#endif
        
        _base = _pos;
        _pos += length;
    }

    
    void Write(size_t count, size_t stride, const void *data)
    {
        size_t length = count * stride;
        WriteBytes(data, 16, length);
    }
    
    size_t GetBase() const
    {
        return _base;
    }

    template<typename T>
    size_t GetBaseOffset(size_t index) const {
        return _base + index * sizeof(T);
    }

    id<MTLBuffer> GetBuffer() const {
        return _buffer;
    }
    
protected:
    MetalBufferPoolPtr _pool;
    id<MTLBuffer> _buffer = nil;
    id<MTLCommandBuffer> _commandBuffer = nil;
    size_t        _pos = 0;
    size_t        _base = 0;
    NSString *    _label = nil;
};




constexpr int kMaxBuffersInFlight = 3;




//
// gl texture 
//

class MetalContext;
class MetalTexture;
class MetalShader;

using MetalContextPtr = std::shared_ptr<MetalContext>;
using MetalTexturePtr = std::shared_ptr<MetalTexture>;
using MetalShaderPtr =std::shared_ptr<MetalShader>;

using MetalBufferPtr = std::shared_ptr<MetalBuffer>;

class MetalTexture : public Texture, public std::enable_shared_from_this<MetalTexture>
{
public:
    MetalTexture(std::string name, id<MTLTexture> mt)
		: m_name(name),_texture(mt), m_size((int)mt.width, (int)mt.height)
	{
	}

    virtual TexturePtr GetSharedPtr() override { return shared_from_this(); }
    
	virtual ~MetalTexture()
	{

	}

    virtual Size2D GetSize() override {
        return m_size;
    }

    
    virtual const std::string &GetName() override
    {
        return m_name;
    }
    
    virtual PixelFormat GetFormat() override
    {
        return ConvertFormat(_texture.pixelFormat);
    }



//protected:
    std::string m_name;
    id<MTLTexture> _texture;
	Size2D m_size;
};


static const char *GetTypeName(MTLDataType type)
{
    switch (type)
    {
        case MTLDataTypeFloat:
        return "float";
        case MTLDataTypeInt:
        return "int";
        case MTLDataTypeFloat2:
        return "float2";
        case MTLDataTypeFloat3:
        return "float3";
        case MTLDataTypeFloat4:
        return "float4";
        case MTLDataTypeFloat2x2:
        return "float2x2";
        case MTLDataTypeFloat3x3:
        return "float3x3";
        case MTLDataTypeFloat4x4:
        return "float4x4";
        default:
        assert(0);
        return "";
    }
}




//
// gl rendering context
//
class MetalContext : public IMetalContext
{
public:
	MetalContext(id <MTLDevice> device);
	virtual ~MetalContext();
	
	
    virtual bool IsThreaded() override { return true; }
	
	virtual TexturePtr CreateTextureFromFile(const char *name, const char *path) override;
	virtual TexturePtr CreateRenderTarget(const char *name, int width, int height, PixelFormat format) override;
	virtual TexturePtr CreateTexture(const char *name, int width, int height, PixelFormat format, const void *data) override;
	virtual ShaderPtr  CreateShader(const char *name) override;
    virtual bool IsSupported(PixelFormat format) override;

    virtual void GetImageDataAsync(TexturePtr texture, std::function<void (ImageDataPtr)> callback) override;

    virtual void SetRenderTarget(TexturePtr texture, const char *passName = nullptr, LoadAction action = LoadAction::Load, Color4F clearColor = Color4F(0,0,0,0) ) override;

    
    virtual Size2D GetRenderTargetSize() override {
        return m_renderTargetSize;
    }
    

    virtual bool UploadTextureData(TexturePtr texture, const void *data, int width, int height, int pitch) override;





	virtual const std::string &GetDriver()  override { return m_driver; };
    virtual float GetTexelOffset() override
    {
        return 0.0f;
    }
    
	virtual const std::string &GetDesc()  override
    {
        return m_desc;
    };
	
	virtual void Present()  override;
    virtual void ResetState();
	virtual void NextFrame()  override;
    virtual void Flush()  override;

    id<MTLCommandBuffer> GetCommandBuffer();
    void EndCommandBuffer();

    
    virtual void PushLabel(const char *name) override
    {
//        if (_encoder)
//        {
//            [_encoder pushDebugGroup:[NSString stringWithUTF8String:name]];
//        }
//        else
            if (_commandBuffer)
        {
            [_commandBuffer pushDebugGroup:[NSString stringWithUTF8String:name]];
        }
    }
    
    virtual void PopLabel() override
    {
//        if (_encoder)
//        {
//            [_encoder popDebugGroup];
//        }
//        else
            if (_commandBuffer)
        {
            [_commandBuffer popDebugGroup];
        }

    }

    
	
	virtual void SetShader(ShaderPtr shader) override;
	virtual void InternalSetTexture(int index, TexturePtr texture, id<MTLSamplerState> sampler);
	virtual void SetPointSize(float size) override;
	virtual void SetDepthEnable(bool enable) override;
    virtual void SetBlend(BlendFactor sourceFactor, BlendFactor destFactor) override;
    virtual void SetWriteMask(int mask) override;
    virtual void SetBlendDisable() override;

//    virtual void Clear(Color4F color);
    
    
    virtual void SetVertexDescriptor(int vertexTypeID, const VertexDescriptor &vd) override;
    
    virtual void UploadIndexData(size_t count, size_t stride, const IndexType *indices) override;
    virtual void UploadVertexData(size_t count, size_t stride, const void *data, int vertexTypeID) override;
    virtual void DrawArrays(PrimitiveType primType, int start, int count) override;
    virtual void DrawIndexed(PrimitiveType primType, int indexOffset, int indexCount) override;

    
    virtual BufferPtr CreateBuffer(size_t count, size_t stride, const void *data, int vertexTypeID)  override;
    virtual void SetIndexBuffer(BufferPtr ib)  override;
    virtual void SetVertexBuffer(int index, BufferPtr vb)  override;

    
    virtual void SetViewport(int x, int y, int w, int h) override 
    {
        _viewport = MTLViewport
        {
            .originX = (double)x,
            .originY = (double)y,
            .width = (double)w,
            .height = (double)h,
            .znear = 0.0,
            .zfar = 1.0
        };
        
        if (_encoder)
            [_encoder setViewport:_viewport];
    }
    
    
    virtual void SetTransform(const Matrix44 &m) override
    {
        m_xform = m;
    }

    virtual const Matrix44 &GetTransform() const override
    {
        return m_xform;
    }
    
    
    virtual void SetScissorDisable() override
    {
        _scissorRect =
        {
            .x = 0,
            .y = 0,
            .width = (NSUInteger)m_renderTargetSize.width,
            .height = (NSUInteger)m_renderTargetSize.height
        };
        
        if (_encoder)
            [_encoder setScissorRect:_scissorRect];

    }

    virtual void SetScissorRect(int x, int y, int w, int h) override
    {
        _scissorRect = MTLScissorRect
        {
            .x = NSUInteger(x),
            .y = NSUInteger(y),
            .width = NSUInteger(w),
            .height = NSUInteger(h)
        };

        if (_encoder)
            [_encoder setScissorRect:_scissorRect];
    }


    id <MTLRenderCommandEncoder> GetEncoder();

    bool HasTextureRenderTarget() const {return m_renderTarget != nullptr;}
    
//    void StartPass(const Color4F *clearColor, const char *passName);
//    void StartPassD(MTLRenderPassDescriptor *rpd, const char *passName);
    
    void EndEncoder()
    {
        if (_encoder) {
            [_encoder endEncoding];
            _encoder = nil;
        }
    }
    
    
    
//protected:
    
    friend class MetalShader;

    
    virtual void SetView(MTKView *view) override;

    std::string m_driver = "Metal";
    
    std::string m_desc;

    
    PipelineKey _key;
    id <MTLRenderPipelineState> _pipeline_state = nil;
    
    MTKView *_view;
//    id<CAMetalDrawable> _currentDrawable;
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue = nil;
    id <MTLCommandBuffer> _commandBuffer = nil;
    id <MTLRenderCommandEncoder> _encoder = nil;

    dispatch_semaphore_t _inFlightSemaphore;


    SamplerCache _samplerCache;

    std::array<MTLVertexDescriptor *, 16> _vertexDescriptors;
    id <MTLDepthStencilState> _depthState_always  = nil;
    
    
    MTLViewport _viewport;
    MTLScissorRect _scissorRect;
    


    MetalBufferPoolPtr _bufferPool;
   
    MetalBufferPtr  _userIndexBuffer;
    MetalBufferPtr _userVertexBuffer;
    
    MetalDynamicBuffer  _vertexBuffer;
    MetalDynamicBuffer  _indexBuffer;
    MetalDynamicBuffer  _uniformBuffer;
    MetalDynamicBuffer  _textureBuffer;


    Size2D m_renderTargetSize;


    
    TexturePtr m_whiteTexture;
    MetalShaderPtr m_shader;

    
    MetalTexturePtr        m_renderTarget;
    NSString * _encoderLabel = nil;
    LoadAction   _loadAction = LoadAction::Load;
    Color4F      _loadClearColor = Color4F(0,0,0,0);
    
    Matrix44 m_xform = Matrix44::Identity();
    
};



void MetalContext::GetImageDataAsync(TexturePtr texture, std::function<void (ImageDataPtr)> callback)
{
    if (!callback)
        return;
    
    MetalTexturePtr mtexture = std::static_pointer_cast<MetalTexture>(texture);
    if (!mtexture) {
        callback(nullptr);
        return;
    }

    
    
    
    
    
    
    // create temporary texture
    id<MTLTexture> gpu_texture = mtexture->_texture;
    auto *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:gpu_texture.pixelFormat
                                                                    width:gpu_texture.width
                                                                   height:gpu_texture.height
                                                                mipmapped:NO];
    
    desc.resourceOptions = MTLResourceCPUCacheModeDefaultCache | RESOURCE_OPTIONS;
    
    __block id<MTLTexture> cpu_texture = [_device newTextureWithDescriptor:desc];
    
    
    // create blit command encoder
    EndEncoder();
    id <MTLCommandBuffer>  cb = GetCommandBuffer();
    id<MTLBlitCommandEncoder> blitEncoder = [cb blitCommandEncoder];

    [blitEncoder copyFromTexture:gpu_texture
                 sourceSlice:0
                 sourceLevel:0
                sourceOrigin:MTLOriginMake(0,0,0)
                  sourceSize:MTLSizeMake(gpu_texture.width, gpu_texture.height, 1)
                   toTexture:cpu_texture
            destinationSlice:0
            destinationLevel:0
           destinationOrigin:MTLOriginMake(0,0,0)
     ];
    
#if TARGET_OS_OSX
    [blitEncoder synchronizeTexture:cpu_texture slice:0 level:0];
#endif
    [blitEncoder endEncoding];
    blitEncoder = nil;
        
    
    // add completion handler for main command buffer
    [cb addCompletedHandler:^(id<MTLCommandBuffer> cb)
     {
        // create image
        auto image = std::make_shared<ImageData>(cpu_texture.width, cpu_texture.height,
                                                                 ConvertFormat(cpu_texture.pixelFormat) );

        // get texture data
        [cpu_texture getBytes:image->data
                  bytesPerRow:image->pitch
                   fromRegion:MTLRegionMake2D(0, 0, image->width, image->height)
                  mipmapLevel:0
         ];

        callback(image);
     }];
    
    

}


//
//
//

class MetalShaderConstant : public ShaderConstant
{
public:
    MetalShaderConstant(std::string name, MTLDataType type)
    :m_name(name), m_type(type)
    {
        memset(&m_value, 0, sizeof(m_value));
    }
    
    virtual ~MetalShaderConstant() {}
    
    virtual const std::string &GetName() override
    {
        return m_name;
    }

    /*
    virtual int GetRegister() override
    {
        return 0;
    }*/
    
    virtual void Set(float f) override
    {
        m_value.f1 = f;
    }

    virtual void Set(const Vector2 &v) override
    {
        *(Vector2 *)&m_value.v4 = v;
    }

    
    virtual void Set(const Vector3 &v) override
    {
        *(Vector3 *)&m_value.v4 = v;
    }
    
    virtual void Set(const Vector4 &v) override
    {
        *(Vector4 *)&m_value.v4 = v;
    }
    
    virtual void Set(const Matrix44 &m) override
    {
        *(Matrix44 *)&m_value.m44 = m;
    }
    
    void Flush(MetalContext *context)
    {
        switch (m_type)
        {
        case MTLDataTypeFloat4x4:
            {
                for (int i=0; i < 2; i++)
                {
                    if (_fieldPtr[i]) {
                        *(Matrix44 *)_fieldPtr[i] = *(Matrix44 *)&m_value.m44;
                    }
                }
            }
            return;
            
        case MTLDataTypeFloat4:
            {
                for (int i=0; i < 2; i++)
                {
                    if (_fieldPtr[i]) {
                        *(Vector4 *)_fieldPtr[i] = *(Vector4 *)&m_value.v4;
                    }
                }
            }
            return;

        case MTLDataTypeFloat3:
            {
                for (int i=0; i < 2; i++)
                {
                    float * src = m_value.v4;
                    if (_fieldPtr[i]) {
                        float * dest = (float *)_fieldPtr[i];
                        dest[0] = src[0];
                        dest[1] = src[1];
                        dest[2] = src[2];
                    }
                }
                return;
            }
        case MTLDataTypeFloat2:
            {
                for (int i=0; i < 2; i++)
                {
                    float * src = m_value.v4;
                    if (_fieldPtr[i]) {
                        float * dest = (float *)_fieldPtr[i];
                        dest[0] = src[0];
                        dest[1] = src[1];
                    }
                }
                return;
            }

        case MTLDataTypeFloat:
            {
                for (int i=0; i < 2; i++)
                {
                    if (_fieldPtr[i]) {
                        *(float *)_fieldPtr[i] = m_value.f1;
                    }
                }
                return;
            }
        
        case MTLDataTypeInt:
        {
            for (int i=0; i < 2; i++)
            {
                if (_fieldPtr[i]) {
                    *(int32_t *)_fieldPtr[i] = (int32_t)m_value.f1;
                }
            }
            return;
        }
        default:
            assert(0);
            return;
        }
       
    }
    
    std::string m_name;
    MTLDataType m_type;
    void * _fieldPtr[2] = {nullptr};
    
    union
    {
        float f1;
        float v4[4];
        float m44[16];
    } m_value;
    
};


class MetalShaderSampler : public ShaderSampler
{
public:
    inline MetalShaderSampler(std::string name, int reg)
    :m_name(name), m_register(reg)
    {
        _samplerKey.addr = SAMPLER_WRAP;
        _samplerKey.filter = SAMPLER_LINEAR;
    }
    
    virtual ~MetalShaderSampler() {}
    
    virtual const std::string &GetName() override
    {
        return m_name;
    }

    
    
    virtual void SetTexture(TexturePtr texture, SamplerAddress addr, SamplerFilter filter) override
    {
        m_texture = texture;
        
        if (addr != _samplerKey.addr || filter != _samplerKey.filter)
        {
            _samplerKey.addr = addr;
            _samplerKey.filter = filter;
            _sampler = nil;
        }
    }
    
    void Flush(MetalContext *context)
    {
        if (_sampler == nil) {
            _sampler = context->_samplerCache.GetOrCreateState(context->_device, _samplerKey);
        }
        context->InternalSetTexture(m_register, m_texture,  _sampler );
    }
    
    int GetRegister()
    {
        return m_register;
    }
    
protected:
    TexturePtr m_texture;
    
    id<MTLSamplerState> _sampler = nil;
    SamplerKey _samplerKey;
    std::string m_name;
    int m_register;
};

using MetalShaderConstantPtr = std::shared_ptr<MetalShaderConstant>;
using MetalShaderSamplerPtr = std::shared_ptr<MetalShaderSampler>;


static bool _Hlsl2Glsl_IncludeOpenFunc(bool isSystem, const char* fname, const char* parentfname, const char* parent, std::string& output, void* data)
{
    std::string *rootDir = (std::string *)data;
    if (!rootDir) {
        return false;
    }
    std::string headerPath = Core::Path::Combine(*rootDir, fname);
    if (!Core::File::ReadAllText(headerPath, output)) {
        return false;
    }
    return true;
}

static void _Hlsl2Glsl_IncludeCloseFunc(const char* file, void* data)
{
    
}


struct MetalBufferFieldDesc
{
    std::string name;
    MTLDataType type;
    int         offset;
};


using MetalShaderBufferDescPtr = std::shared_ptr<class MetalShaderBufferDesc>;


class MetalShaderBufferDesc
{
public:
    MetalShaderBufferDesc(std::string name, int size, int alignment)
    :_name(name), _size(size), _alignment(alignment)
    {
        
    }
    
    const std::string _name;
    const int         _alignment;
    const int         _size;
    
    std::vector<MetalBufferFieldDesc>       _fields;
    
    void Dump()
    {
        Log::WriteLine("buffer %s %d %d\n", _name.c_str(), _alignment, _size);
        for (auto &field : _fields)
        {
            Log::WriteLine("\tfield %s %s (%d)\n", GetTypeName(field.type), field.name.c_str(), field.offset );
            
        }
    }
    
    void AddField(std::string name, int offset, MTLDataType type)
    {
        MetalBufferFieldDesc field;
        field.name = name;
        field.type = type;
        field.offset = offset;
        _fields.push_back(field);
    }
    
    static MetalShaderBufferDescPtr CreateFromArgument(MTLArgument *arg)
    {
        MetalShaderBufferDescPtr bd = std::make_shared<MetalShaderBufferDesc>( arg.name.UTF8String,
                                                                  (int)arg.bufferDataSize,
                                                                  (int)arg.bufferAlignment
                                                                  );
                          
        
        MTLStructType *st =  arg.bufferStructType;
        for (MTLStructMember *member in st.members) {
            if (member.dataType != MTLDataTypeSampler  && member.dataType != MTLDataTypeTexture)
                bd->AddField(member.name.UTF8String, (int)member.offset, member.dataType );
        }
        return bd;
    }
};


using MetalShaderBufferPtr = std::shared_ptr<class MetalShaderBuffer>;

class MetalShaderBuffer
{
public:
    MetalShaderBuffer(MetalShaderBufferDescPtr desc, int index)
    :_desc(desc), _index(index), _alignment(desc->_alignment)
    {
        _data.resize(desc->_size);
    }
    
    virtual ~MetalShaderBuffer()
    {
    }
    
    uint8_t *GetFieldPtr(int offset)
    {
        return &_data[offset];
    }
    
    
    bool                                _vertex;
    MetalShaderBufferDescPtr            _desc;
    std::vector<uint8_t>                _data;
    int                                 _alignment;
    int                                 _index;
    std::vector<MetalShaderConstantPtr> _constants;
    
    
    static MetalShaderBufferPtr CreateFromArgument(MTLArgument *arg)
    {
        MetalShaderBufferDescPtr bd = MetalShaderBufferDesc::CreateFromArgument(arg);
        return  std::make_shared<MetalShaderBuffer>(bd, (int)arg.index);
    }



};



    static bool ConvertHLSLToMetal(const ShaderSource &source, ShaderSource &metal_source, std::string &errors)
    {
        PROFILE_FUNCTION_CAT("shader")

        std::string hlsl = source.code;
        std::string entryName = source.functionName;
        std::string rootDir = Core::Path::GetDirectory(source.path);
        
        EShLanguage language = (source.IsVertex()) ? EShLangVertex : EShLangFragment;
        
        int options = ETranslateOpAvoidBuiltinAttribNames;

        //        /options |= ETranslateOpIntermediate;
        // options |= ETranslateOpEmitGLSL120ArrayInitWorkaround;
        
        ETargetVersion  targetVersion = ETargetMetal_200;
        
        hlsl.insert(0,
                    "#define METAL 1\n"
                    );
        
        
        MetalShHandle compiler = Hlsl2Msl_ConstructCompiler(language);
        Hlsl2Glsl_ParseCallbacks callbacks {_Hlsl2Glsl_IncludeOpenFunc, _Hlsl2Glsl_IncludeCloseFunc, &rootDir};
        if (!Hlsl2Msl_Parse(compiler, hlsl.c_str(),
                            targetVersion,
                            &callbacks, options)) {
            errors = "Hlsl2Glsl_Parse error:\n";
            errors += Hlsl2Msl_GetInfoLog(compiler);
//            printf("%s\n", hlsl.c_str());
            Hlsl2Msl_DestructCompiler(compiler);
            return false;
        }
        
        //    printf("Hlsl2Glsl\n%s\n", Hlsl2Msl_GetInfoLog(compiler));
        
        if ( !Hlsl2Msl_Translate(
                                 compiler,
                                 entryName.c_str(),
                                 targetVersion,
                                 options)) {
            errors = "Hlsl2Glsl_Translate error:\n";
            errors += Hlsl2Msl_GetInfoLog(compiler);
//            printf("%s\n", hlsl.c_str());
            Hlsl2Msl_DestructCompiler(compiler);
            return false;
        }
        
        
        std::string metalCode = Hlsl2Msl_GetShader(compiler);
        Hlsl2Msl_DestructCompiler(compiler);

        metal_source.type = source.type;
        metal_source.path = source.path;
        metal_source.code = metalCode;
        metal_source.functionName =source.IsVertex() ? "vertex_main" : "fragment_main";
        metal_source.profile = source.IsVertex() ? "vertex_metal"  : "fragment_metal";
        metal_source.language = "metal";
        return true;
    }
    


class MetalShader : public Shader
{
public:
    
	MetalShader(MetalContext *context, id<MTLDevice>  device, const char *name)
    : _context(context), _device(device), _name(name)
	{
   
	}

	virtual ~MetalShader()
	{
	}

	virtual int			GetSamplerCount() override
	{
		return (int)m_samplers.size();
	}

	virtual ShaderSamplerPtr   GetSampler(int index) override
	{
        if ((size_t)index >= m_samplers.size()) return nullptr;
		return m_samplers[index];
	}

	virtual int			GetConstantCount() override
	{
		return (int)m_constants.size();
	}

	virtual ShaderConstantPtr	GetConstant(int index) override
	{
        if ((size_t)index >= m_constants.size()) return nullptr;
		return m_constants[index];
	}

    
    virtual id <MTLRenderCommandEncoder>  Flush(MetalContext *context)
    {
        const PipelineKey &key = context->_key;
        
        id<MTLRenderPipelineState> state = _pipelineCache.GetOrCreatePipelineState(this, key);
        if (state == nil) {
            return nil;
        }
        
        
        id <MTLRenderCommandEncoder>  encoder = context->GetEncoder();
        
        
        if (state != context->_pipeline_state)
        {
        
            // set pipeline state for shader pipeline
            [encoder setRenderPipelineState:state];
            
            context->_pipeline_state = state;
        }
        
        

        if (m_constant_xform_position)
        {
            const Matrix44 &xform = context->GetTransform();
            m_constant_xform_position->Set(xform);
        }
        
        for (auto &sampler : m_samplers)
        {
            sampler->Flush(context);
        }
        
        for (auto &constant : m_constants)
        {
            constant->Flush(context);
        }
        
        
        // set options

        MetalDynamicBuffer *ub = &context->_uniformBuffer;

        // bind vertex buffer
        auto vb = _vertexShader->buffer;
        if (vb)
        {
 
             
             
            
            if (ub) {
                ub->WriteBytes( vb->_data.data(), vb->_alignment, vb->_data.size() );
                
                [encoder setVertexBuffer: ub->GetBuffer()
                                  offset: ub->GetBase()
                                 atIndex: vb->_index
                 ];
            } else {
                [encoder setVertexBytes: vb->_data.data()
                                 length: vb->_data.size()
                                atIndex: vb->_index
                 ];
            }
        }
        
        // bind fragment buffer
        auto fb = _fragmentShader->buffer;
        if (fb)
        {
            if (ub)
            {
                ub->WriteBytes( fb->_data.data(), fb->_alignment, fb->_data.size() );
                [encoder setFragmentBuffer: ub->GetBuffer()
                                    offset: ub->GetBase()
                                   atIndex: fb->_index
                 ];
            } else
            {
                [encoder setFragmentBytes: fb->_data.data()
                                   length: fb->_data.size()
                                  atIndex: fb->_index
                ];
            }
        }
        

        
        return encoder;
    }
    
    
    
    struct MetalShaderInfo
    {
        ShaderSource     source;
        id<MTLLibrary>   library;
        id<MTLFunction>  function;
        
        MetalShaderBufferPtr            buffer;
        std::map<int, std::string>      samplers;
        
        double time_convert = 0;
        double time_compile = 0;
    };
    
    

    
    using MetalShaderInfoPtr = std::shared_ptr<MetalShaderInfo>;

    double _time_link = 0;

    

    MetalShaderInfoPtr CompileMetal(const ShaderSource &source)
    {
        PROFILE_FUNCTION_CAT("shader")

        Core::StopWatch sw;
        NSError *error = nil;
        MTLCompileOptions *opt = [MTLCompileOptions new];
        id<MTLLibrary> library = [_device newLibraryWithSource:[NSString stringWithUTF8String:source.code.c_str()]
                                                       options:opt
                                                         error:&error];
        
        if (error != nil) {
            // error
            std::cout<<source.code << std::endl;
            Log::Error( "Metal compilation failed: %s\n", error.description.UTF8String );
            return nullptr;
        }
        
        library.label = [NSString stringWithUTF8String: _name.c_str() ];

        id<MTLFunction> function =
            [library newFunctionWithName: [NSString stringWithUTF8String:source.functionName.c_str()] ];
        
        if (!function) {
            Log::Error( "Could not find function\n");
            return nullptr;
        }
        
        
        std::string label = source.path + "@" + source.functionName;
        function.label = [NSString stringWithUTF8String: label.c_str() ];

        
        MetalShaderInfoPtr  info = std::make_shared<MetalShaderInfo>();
        info->source    = source;
        info->function  = function;
        info->library   = library;
        info->time_convert = 0;
        info->time_compile += sw.GetElapsedMilliSeconds();

        return info;
    }
    
  
	virtual bool Compile(const ShaderSource &source) override
	{
        PROFILE_FUNCTION_CAT("shader")

        ShaderSource metal_source;
        std::string error;
        if (!ConvertHLSLToMetal(source, metal_source, error)) {
            m_errors += error;
            return false;
        }
        
        MetalShaderInfoPtr info = CompileMetal(metal_source);
        if (!info) {
            return false;
        }
        
//        std::cout << info->source << '\n';
        
        if (metal_source.IsVertex()) {
            _vertexShader   = info;
        } else {
            _fragmentShader = info;
        }
        
        
        return true;
	}
    
    void AddShaderConstants(MetalShaderBufferPtr buffer)
    {
        for (const auto &field : buffer->_desc->_fields)
        {
            MetalShaderConstantPtr constant;
            
            auto it = m_constant_map.find(field.name);
            if (it == m_constant_map.end()) {
                constant = std::make_shared<MetalShaderConstant>(field.name, field.type);
                m_constant_map[field.name] = constant;
                m_constants.push_back(constant);
            } else {
                constant = it->second;
                if (constant->m_type != field.type) {
                    assert(0);
                    continue;
                }
            }

            buffer->_constants.push_back(constant);

            
            // bind constant to buffer
            uint8_t *fieldPtr = buffer->GetFieldPtr(field.offset);
            
            for (int i=0; i < 2; i++) {
                if (!constant->_fieldPtr[i]) {
                    constant->_fieldPtr[i] = fieldPtr;
                    break;
                }
            }
            
        }

    }
    
    
    MTLRenderPipelineReflection *GetReflectionInfo()
    {
        PROFILE_FUNCTION_CAT("shader")

        
        std::stringstream ss;
        ss << "Pipeline_Reflection_" << _name;
        
        std::string label = ss.str();
        
        MTLRenderPipelineDescriptor *psd = [[MTLRenderPipelineDescriptor new] init];
        psd.label = [NSString stringWithUTF8String:label.c_str()] ;
        psd.sampleCount = 1;
        psd.vertexFunction = _vertexShader->function;
        psd.fragmentFunction = _fragmentShader->function;
        psd.vertexDescriptor = _context->_vertexDescriptors[0];
        psd.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
        psd.depthAttachmentPixelFormat = MTLPixelFormatInvalid;
        psd.stencilAttachmentPixelFormat = MTLPixelFormatInvalid;
        
        
        
        MTLAutoreleasedRenderPipelineReflection reflection;
        MTLPipelineOption options = MTLPipelineOptionArgumentInfo | MTLPipelineOptionBufferTypeInfo;
        
        NSError *error = NULL;
        id <MTLRenderPipelineState> state = [_device newRenderPipelineStateWithDescriptor:psd
                                                                                  options:options
                                                                               reflection:&reflection
                                                                                    error:&error];
        
        if (!state) {
            NSLog(@"Failed to created pipeline state, error %@", error);
            
            std::cout << _fragmentShader->source.code;
            return nil;
        }
        return reflection;
    }

	virtual bool Link() override
	{
        PROFILE_FUNCTION_CAT("shader")

        if (!_vertexShader || !_fragmentShader) {
            return false;
        }
        
        Core::StopWatch sw;

        MTLRenderPipelineReflection *reflection = GetReflectionInfo();
        if (reflection == nil) {
            return false;
        }
        
        for (MTLArgument *arg in reflection.vertexArguments) {
            //            NSLog(@"vertex-arg: %@\n", arg);
            if (arg.type == MTLArgumentTypeBuffer && [arg.name isEqualToString:@"uniforms"]) {
                _vertexShader->buffer     = MetalShaderBuffer::CreateFromArgument(arg);
            }
        }

        for (MTLArgument *arg in reflection.fragmentArguments) {
//            NSLog(@"fragment-arg: %@\n", arg);
            if (arg.type == MTLArgumentTypeTexture) {
//                _fragmentShader->samplers[ (int)arg.index] = arg.name.UTF8String;
            }
            else if (arg.type == MTLArgumentTypeSampler) {
                _fragmentShader->samplers[ (int)arg.index] = arg.name.UTF8String;
            }
            else if (arg.type == MTLArgumentTypeBuffer && [arg.name isEqualToString:@"uniforms"]) {
                _fragmentShader->buffer     = MetalShaderBuffer::CreateFromArgument(arg);
            }
        }
        

        // add constants
        AddShaderConstants(_vertexShader->buffer);
        AddShaderConstants(_fragmentShader->buffer);



        // add samplers
        for (auto it : _fragmentShader->samplers)
        {
            m_samplers.push_back(std::make_shared<MetalShaderSampler>(it.second, it.first));
        }
        // sort samplers
        std::sort(m_samplers.begin(), m_samplers.end(), [](MetalShaderSamplerPtr a, MetalShaderSamplerPtr b)->bool {
            return a->GetRegister() < b->GetRegister();
        } );
        
        
#if 0
        for (auto c : m_constants) {
            LogPrint("constant %s %d %p %p\n", c->GetName().c_str(), c->m_type, c->_fieldPtr[0], c->_fieldPtr[1] );
        }

        for (auto s : m_samplers) {
            LogPrint("sampler %s register:%d\n", s->GetName().c_str(), s->GetRegister());
        }
#endif
        
        m_constant_xform_position = Shader::GetConstant("xform_position");

        sw.Stop();
        _time_link += sw.GetElapsedMilliSeconds();

        return true;
	}
    
    
    virtual std::string GetErrors() override
    {
        return m_errors;
    }

    
    MetalContext *_context;
    id<MTLDevice>  _device;
    std::string _name;

    
    MetalShaderInfoPtr  _vertexShader = nullptr;
    MetalShaderInfoPtr  _fragmentShader = nullptr;
    
    PipelineCache _pipelineCache;

    
//protected:
    ShaderConstantPtr m_constant_xform_position;

    friend class MetalContext;
    
    std::string m_errors;
    
    std::vector< MetalShaderSamplerPtr > m_samplers;
	std::vector< MetalShaderConstantPtr > m_constants;
    std::unordered_map<std::string, MetalShaderConstantPtr > m_constant_map;
};

//
//
//



static MTLBlendFactor ConvertBlendFactor(BlendFactor factor)
{
    switch (factor)
    {
        case     BLEND_ZERO:
            return MTLBlendFactorZero;
        case     BLEND_ONE:
            return MTLBlendFactorOne;
        case     BLEND_SRCCOLOR:
            return MTLBlendFactorSourceColor;
        case     BLEND_INVSRCCOLOR:
            return MTLBlendFactorOneMinusSourceColor;
        case     BLEND_SRCALPHA:
            return MTLBlendFactorSourceAlpha;
        case     BLEND_INVSRCALPHA:
            return MTLBlendFactorOneMinusSourceAlpha;
        case     BLEND_DESTALPHA:
            return MTLBlendFactorDestinationAlpha;
        case     BLEND_INVDESTALPHA:
            return MTLBlendFactorOneMinusDestinationAlpha;
        case     BLEND_DESTCOLOR:
            return MTLBlendFactorDestinationColor;
        case     BLEND_INVDESTCOLOR:
            return MTLBlendFactorOneMinusDestinationColor;
        default:
            assert(0);
            return MTLBlendFactorZero;
    }
}






id <MTLRenderPipelineState> CreatePipelineState(MetalShader *shader, const PipelineKey &key)
{
    MetalContext *context = shader->_context;
    std::stringstream ss;
    ss << "Pipeline_" <<  shader->_name;
    ss << '_'  << key.pixelFormat;
    ss << '_'  << key.vertexTypeID;

   // if (key.blendEnabled) {
    ss << '_' << key.sourceFactor;
    ss << '_' << key.destFactor;
    //}
    
//    auto _view = context->_view;
    MTLRenderPipelineDescriptor *psd = [[MTLRenderPipelineDescriptor alloc] init];
    psd.label = [NSString stringWithUTF8String:ss.str().c_str()] ;
    psd.sampleCount = 1; //_view.sampleCount;
    psd.vertexFunction = shader->_vertexShader->function;
    psd.fragmentFunction = shader->_fragmentShader->function;
    psd.vertexDescriptor = context->_vertexDescriptors[key.vertexTypeID];

    psd.colorAttachments[0].pixelFormat = key.pixelFormat;
    psd.depthAttachmentPixelFormat = MTLPixelFormatInvalid;
    psd.stencilAttachmentPixelFormat = MTLPixelFormatInvalid;

    if (key.blendEnable) {
        psd.colorAttachments[0].blendingEnabled = YES;
        psd.colorAttachments[0].rgbBlendOperation = MTLBlendOperationAdd;
        psd.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
        psd.colorAttachments[0].sourceRGBBlendFactor =  ConvertBlendFactor(key.sourceFactor);
        psd.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactorOne;
        psd.colorAttachments[0].destinationRGBBlendFactor =  ConvertBlendFactor(key.destFactor);
        psd.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorZero;
    } else {
        psd.colorAttachments[0].blendingEnabled = NO;
    }
    
    
    psd.colorAttachments[0].writeMask = key.writeMask;

    
    NSError *error = NULL;
    id <MTLRenderPipelineState> state = [context->_device newRenderPipelineStateWithDescriptor:psd error:&error];
    if (state == nil) {
        NSLog(@"Failed to created pipeline state, error %@", error);
        return nil;
    }

    return state;
}



//
//
//


static MTLVertexFormat ConvertVertexFormat(VertexFormat format)
{
    switch (format)
    {
        case VertexFormat::Invalid:
            return MTLVertexFormatInvalid;
        case VertexFormat::Float:
            return MTLVertexFormatFloat;
        case VertexFormat::Float2:
            return MTLVertexFormatFloat2;
        case VertexFormat::Float3:
            return MTLVertexFormatFloat3;
        case VertexFormat::Float4:
            return MTLVertexFormatFloat4;
        case VertexFormat::UChar4Normalized:
            return MTLVertexFormatUChar4Normalized;
    }
}


static MTLVertexDescriptor *ConvertVertexDescriptor(const VertexDescriptor &desc)
{
    MTLVertexDescriptor *vd = [MTLVertexDescriptor new];
    
    for (const auto &attrib : desc.attribs)
    {
        vd.attributes[attrib.index].format = ConvertVertexFormat(attrib.format);
        vd.attributes[attrib.index].offset = attrib.offset;
        vd.attributes[attrib.index].bufferIndex = 0;
    }

    
    vd.layouts[0].stride = desc.stride;
    vd.layouts[0].stepRate = 1;
    vd.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
    return vd;
}






static TexturePtr CreateWhiteTexture(Context *context)
{
    int size = 64;
    std::vector<uint32_t> image;
    image.resize(size * size);
    for (auto &pixel : image)
        pixel = 0xFFFFFFFF;
    auto texture = context->CreateTexture("white", size, size, PixelFormat::RGBA8Unorm, image.data() );
    return texture;
}


static std::string GetFeatureSet(id<MTLDevice> device)
{
    std::string m_desc;
    
    m_desc = device.name.UTF8String;
    /*
#if TARGET_OS_OSX
    MTLFeatureSet highest = MTLFeatureSet_macOS_GPUFamily1_v1;
    for (int features = MTLFeatureSet_macOS_GPUFamily1_v1; features <= (int)10005; features++)
    {
        if ([device supportsFeatureSet:(MTLFeatureSet)features]) {
            highest = (MTLFeatureSet)features;
        } else {
            break;
        }
    }
    
    switch (highest)
    {
        case MTLFeatureSet_macOS_GPUFamily1_v1: m_desc = "macOS_GPUFamily1_v1"; break;
        case MTLFeatureSet_macOS_GPUFamily1_v2: m_desc = "macOS_GPUFamily1_v2"; break;
        case MTLFeatureSet_macOS_GPUFamily1_v3: m_desc = "macOS_GPUFamily1_v3"; break;
        case MTLFeatureSet_macOS_GPUFamily1_v4: m_desc = "macOS_GPUFamily1_v4"; break;
        case (MTLFeatureSet)10005: m_desc = "macOS_GPUFamily2_v1"; break;
        case MTLFeatureSet_macOS_ReadWriteTextureTier2: m_desc = "macOS_ReadWriteTextureTier2"; break;
        default:
            m_desc = "Metal";
            break;
    }
#else
    m_desc = "Metal";
#endif
     */

    return m_desc;

}

MetalContext::MetalContext(id<MTLDevice> device)
    : _device(device), _view(nullptr),
    _bufferPool(std::make_shared<MetalBufferPool>(_device, 256 * 1024 )),
    _vertexBuffer(_bufferPool),
    _indexBuffer(_bufferPool),
    _uniformBuffer(_bufferPool),
    _textureBuffer(_bufferPool)
{
    
    Hlsl2Msl_Initialize();
    
    m_desc = GetFeatureSet(device);
    
    
    _key.writeMask = ColorWriteMaskAll;
    _key.blendEnable = false;
    _key.sourceFactor = BLEND_ONE;
    _key.destFactor = BLEND_ZERO;

    _inFlightSemaphore = dispatch_semaphore_create(kMaxBuffersInFlight);
    _commandQueue = [_device newCommandQueue];
//    _vertexDescriptors[0] = CreateVertexDescriptor();
//    _vertexDescriptors[1] = CreateVertexDescriptor2();
    
    SetVertexDescriptor(
        GetVertexTypeID<Vertex>(),
         render::VertexDescriptor
         {
             sizeof(Vertex),
             {
                 { 0,  VertexFormat::Float4,             offsetof(Vertex, position) },
                 { 1,  VertexFormat::Float4,             offsetof(Vertex, color) },
                 { 2,  VertexFormat::Float2,             offsetof(Vertex, texcoord0)  },
                 { 3,  VertexFormat::Float2,             offsetof(Vertex, texcoord1)  },
             }
         }
     );

    
    m_whiteTexture = CreateWhiteTexture(this);
    
    MTLDepthStencilDescriptor *depthStateDesc = [[MTLDepthStencilDescriptor alloc] init];
    depthStateDesc.depthCompareFunction = MTLCompareFunctionAlways;
    depthStateDesc.depthWriteEnabled = NO;
    _depthState_always = [_device newDepthStencilStateWithDescriptor:depthStateDesc];

    
    _vertexBuffer.SetLabel("VertexData");
    _indexBuffer.SetLabel("IndexData");
    _uniformBuffer.SetLabel("UniformData");
    _textureBuffer.SetLabel("TextureData");


    m_renderTarget = nullptr;
    m_displayInfo.size       = Size2D(0, 0);
    m_renderTargetSize = m_displayInfo.size;
    _loadAction =  LoadAction::Load;

    
    SetViewport(0,0, m_renderTargetSize.width, m_renderTargetSize.height);
    SetScissorDisable();
    
    
}



MetalContext::~MetalContext()
{
}


void MetalContext::ResetState()
{
    SetRenderTarget(nullptr, nullptr, LoadAction::Discard);
    SetBlendDisable();
    SetDepthEnable(false);
    SetScissorDisable();
}



id <MTLRenderCommandEncoder> MetalContext::GetEncoder()
{
    if (_encoder) {
        return _encoder;
    }
    
    // setup render pass descriptor...
    MTLRenderPassDescriptor *rpd;
    if (!m_renderTarget)
    {
        // Obtain a renderPassDescriptor generated from the view's drawable textures
        rpd = _view.currentRenderPassDescriptor;
        rpd.colorAttachments[0].storeAction = MTLStoreActionStore;
    }
    else
    {
        rpd = [MTLRenderPassDescriptor renderPassDescriptor];
        rpd.colorAttachments[0].texture = m_renderTarget->_texture;
        rpd.colorAttachments[0].storeAction = MTLStoreActionStore;
    }

        // setup load action
    switch (_loadAction)
    {
        case LoadAction::Load:
            rpd.colorAttachments[0].loadAction = MTLLoadActionLoad;
            break;
        case LoadAction::Discard:
            rpd.colorAttachments[0].loadAction = MTLLoadActionDontCare;
            break;
        case LoadAction::Clear:
            rpd.colorAttachments[0].loadAction = MTLLoadActionClear;
            rpd.colorAttachments[0].clearColor = MTLClearColorMake(_loadClearColor.r,_loadClearColor.g, _loadClearColor.b, _loadClearColor.a);
            break;
        default:
            assert(0);
            break;
    }

    // reset load action
    _loadAction = LoadAction::Load;
    
    id<MTLCommandBuffer> cb = GetCommandBuffer();
    
    // create new encoder
    _encoder = [cb renderCommandEncoderWithDescriptor:rpd];
    
    _pipeline_state = nil;
    
    // set encoder label
    if (_encoderLabel) {
        _encoder.label = _encoderLabel;
        _encoderLabel = nil;
    }
    
    // set default state
    [_encoder setCullMode:MTLCullModeNone];
    [_encoder setDepthStencilState:_depthState_always];
    [_encoder setViewport:_viewport];
    
    //[_encoder setScissorRect:_scissorRect];

    
    return _encoder;
}

void MetalContext::EndCommandBuffer()
{
    if (_commandBuffer) {
        EndEncoder();
        
        [_commandBuffer commit];
        
//        [_commandBuffer enqueue];
        _commandBuffer = nil;
    }
}



id<MTLCommandBuffer> MetalContext::GetCommandBuffer()
{
    if (_commandBuffer) {
        EndEncoder();
        return _commandBuffer;
    }
    
    _commandBuffer = [_commandQueue commandBuffer];

    // enqueue command buffer
    [_commandBuffer enqueue];

//    __block uintptr_t async_id = (uintptr_t) (__bridge void *)_commandBuffer;

//    __block TProfiler::ProfilerTicks createTime = TProfiler::GetTime();
//    __block TProfiler::ProfilerTicks scheduleTime;

//    PROFILE_DECLARE_SECTION(_cbuffer_begin_section, "CommandBuffer", "gpu")
//    TProfiler::AddAsyncBegin(_cbuffer_begin_section, async_id);
    
    _bufferPool->BeginCommandBuffer(_commandBuffer);
    
    
//     [_commandBuffer addScheduledHandler:^(id<MTLCommandBuffer> buffer)
//         {
//
//         PROFILE_DECLARE_SECTION(_cbuffer_commit_section, "CommandBuffer::Commit", "gpu")
//         TProfiler::AddAsyncEnd(_cbuffer_commit_section, async_id);
//
//
//         PROFILE_DECLARE_SECTION(_cbuffer_scheduled_section, "CommandBuffer::Execute", "gpu")
//         TProfiler::AddAsyncBegin(_cbuffer_scheduled_section, async_id);
//
//         }];

    __block MetalBufferPoolPtr block_pool = _bufferPool;
    [_commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer)
     {
         block_pool->ReleaseResources(buffer);

//        PROFILE_DECLARE_SECTION(_cbuffer_scheduled_section, "CommandBuffer::Execute", "gpu")
//        TProfiler::AddAsyncEnd(_cbuffer_scheduled_section, async_id);
//
//
//        PROFILE_DECLARE_SECTION(_cbuffer_completed_section, "CommandBuffer", "gpu")
//        TProfiler::AddAsyncEnd(_cbuffer_completed_section, async_id);
     }];
    
    return _commandBuffer;
}


static bool CFStringConvert(CFStringRef aString, std::string &result) {
    result.clear();
    if (aString == NULL) {
        return false;
    }
    

    CFIndex length = CFStringGetLength(aString);
    CFIndex maxSize =CFStringGetMaximumSizeForEncoding(length, kCFStringEncodingUTF8) + 1;
    
    char buffer[maxSize];
    if (!CFStringGetCString(aString, buffer, maxSize, kCFStringEncodingUTF8)) {
        return false;
    }
    
    result = buffer;
    return true;
}


void MetalContext::SetView(MTKView *view)
{
    _view = view;
    
    {
        PROFILE_GPU()
//        _currentDrawable = view.currentDrawable;
    }
    

    
#if TARGET_OS_OSX

    NSWindow *window = view.window;
    float scale = [window backingScaleFactor];
    
    NSScreen *screen = window.screen;
    float maxEDR  = screen.maximumExtendedDynamicRangeColorComponentValue;
#else
    UIWindow *window = view.window;
    UIScreen * screen = window.screen;
    if (!screen) screen = UIScreen.mainScreen;
    float scale = screen.scale;
    float maxEDR = 1.0f;
#endif

 
    std::string colorSpaceName;
    if (@available(tvOS 13.0, iOS 13.0, *))
    {
        CAMetalLayer *layer = (CAMetalLayer *)view.layer;
        CGColorSpaceRef colorSpace = layer.colorspace;
        if (colorSpace)
        {
            CFStringConvert( CGColorSpaceGetName(colorSpace), colorSpaceName);
        }
    }


    int sampleCount = (int)view.sampleCount;
    float rate = view.preferredFramesPerSecond;
    
    


    auto drawable = view.currentDrawable;
    auto texture = drawable.texture;
    Size2D displaySize((int)texture.width, (int)texture.height);

    SetDisplayInfo({
        .size= displaySize,
        .format= ConvertFormat(view.colorPixelFormat),
        .refreshRate= rate,
        .scale= scale,
        .samples= sampleCount,
        .maxEDR= maxEDR,
        .colorSpace = colorSpaceName
    });
    
    
    
    SetScissorDisable();
    SetRenderTarget(nullptr);
}

void MetalContext::NextFrame()
{
    PROFILE_FUNCTION_CAT("gfx")

    EndCommandBuffer();

    {
//        StopWatch sw;
        PROFILE_GPU()
        dispatch_semaphore_wait(_inFlightSemaphore, DISPATCH_TIME_FOREVER);
//        printf("dispatch_semaphore_wait %.2fms\n", sw.GetElapsedMilliSeconds());
    }

    id<MTLCommandBuffer> cb = GetCommandBuffer();
    
    __block dispatch_semaphore_t block_sema = _inFlightSemaphore;
    [cb addCompletedHandler:^(id<MTLCommandBuffer> buffer)
     {
         dispatch_semaphore_signal(block_sema);
     }];

    SetRenderTarget(nullptr, "BeginScene");
}


void MetalContext::Flush()
{
    EndCommandBuffer();
}



void MetalContext:: Present()
{
    PROFILE_FUNCTION_CAT("gfx")

    id<MTLCommandBuffer> cb = GetCommandBuffer();
    

    {
        PROFILE_GPU()
        id<CAMetalDrawable> drawable =  _view.currentDrawable;

        [cb presentDrawable:drawable];
    }
    
    EndCommandBuffer();
}


bool MetalContext::IsSupported(PixelFormat format) 
{
    switch (format)
    {
        default:
            return true;
    }
}



TexturePtr MetalContext::CreateTextureFromFile(const char *name, const char *path)
{
    PROFILE_FUNCTION_CAT("texture")

    std::vector<uint8_t> data;
    if (!Core::File::ReadAllBytes(path, data)) {
        return nullptr;
    }
    
    NSData *nsdata = [NSData dataWithBytes:data.data() length: (NSUInteger) data.size() ];

    NSDictionary *textureLoaderOptions =
    @{
      MTKTextureLoaderOptionTextureUsage       : @(MTLTextureUsageShaderRead),
      MTKTextureLoaderOptionTextureStorageMode : @(MTLStorageModePrivate)
      };
    
    MTKTextureLoader* textureLoader = [[MTKTextureLoader alloc] initWithDevice:_device];
    
    
    
    NSError *error = nil;
    id<MTLTexture>  texture = [textureLoader newTextureWithData:nsdata
                                                        options:textureLoaderOptions
                                                          error:&error]
                                                          ;

    if (texture == nil) {
        return nullptr;
    }
    
    texture.label = [NSString stringWithUTF8String:name];
    return std::make_shared<MetalTexture>(name, texture);
}





TexturePtr MetalContext::CreateRenderTarget(const char *name, int width, int height, PixelFormat format)
{

    
    MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:ConvertFormat(format)
                                                                                    width:(NSUInteger)width
                                                                                   height:(NSUInteger)height
                                                                                mipmapped:NO];
    
    desc.usage  |= MTLTextureUsageRenderTarget; // | MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite;
    desc.storageMode = MTLStorageModePrivate;

    id<MTLTexture> texture = [_device newTextureWithDescriptor:desc];
    texture.label = [NSString stringWithUTF8String:name];
    return std::make_shared<MetalTexture>(name, texture);
}


TexturePtr MetalContext::CreateTexture(const char *name, int width, int height, PixelFormat format, const void *data)
{
    MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:ConvertFormat(format)
                                                                                    width:(NSUInteger)width
                                                                                   height:(NSUInteger)height
                                                                                mipmapped:NO];
    
    desc.usage  |= MTLTextureUsageShaderRead; // | MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite;
    desc.resourceOptions = MTLResourceCPUCacheModeDefaultCache | RESOURCE_OPTIONS;
   
    id<MTLTexture> texture = [_device newTextureWithDescriptor:desc];
    if (texture == nil) {
        return nullptr;
    }
    texture.label = [NSString stringWithUTF8String:name];
    
    int pitch = width * PixelFormatGetPixelSize(format);
    [texture replaceRegion:MTLRegionMake2D(0,0,width,height)
                mipmapLevel:0
                  withBytes:data
                bytesPerRow:pitch
     ];
    
    return std::make_shared<MetalTexture>(name, texture);

}

ShaderPtr MetalContext::CreateShader(const char *name)
{
	return std::make_shared<MetalShader>(this, _device, name);
}



void MetalContext::InternalSetTexture(int index, TexturePtr texture, id<MTLSamplerState> sampler)
{
    if (!texture)
    {
        // use white texture....
        texture = m_whiteTexture;
    }
    
    MetalTexturePtr metal_texture = std::static_pointer_cast<MetalTexture>(texture);
    assert(metal_texture);

    [_encoder setFragmentTexture:metal_texture->_texture atIndex:index];
    [_encoder setFragmentSamplerState:sampler atIndex:index];
}

void MetalContext::SetPointSize(float size)
{
#if USE_POINT_SIZE
    m_options.point_size = size;
#endif
}


void MetalContext::SetDepthEnable(bool enable)
{

}


void MetalContext::SetWriteMask(int mask)
{
    _key.writeMask = mask;

}


void MetalContext::SetBlend(BlendFactor sourceFactor, BlendFactor destFactor)
{
    _key.blendEnable = true;
    _key.sourceFactor = sourceFactor;
    _key.destFactor = destFactor;
}


void MetalContext::SetBlendDisable()
{
    _key.blendEnable = false;
    _key.sourceFactor = BLEND_ONE;
    _key.destFactor  = BLEND_ZERO;
}

void MetalContext::SetShader(ShaderPtr shader)
{
    // set shader
    m_shader = std::static_pointer_cast<MetalShader>(shader);
}





void MetalContext::SetRenderTarget(TexturePtr texture, const char *passName, LoadAction action, Color4F clearColor )
{
    MetalTexturePtr target = std::static_pointer_cast<MetalTexture>(texture);
//    if (m_renderTarget == target) {
//        return;
//    }
    
    EndEncoder();
    
    m_renderTarget = target;
    if (!m_renderTarget)
    {
        _key.pixelFormat = _view.colorPixelFormat;
        m_renderTargetSize   = m_displayInfo.size;
    }
    else
    {
        _key.pixelFormat = m_renderTarget->_texture.pixelFormat;
        m_renderTargetSize  = m_renderTarget->GetSize();
    }

    if (passName) {
        _encoderLabel = [NSString stringWithUTF8String:passName];
    } else {
        _encoderLabel = nil;
    }
    
    _loadAction = action;
    _loadClearColor = clearColor;

//    if (_loadAction == LoadAction::Clear)
    {
        GetEncoder();
    }
    

   // StartPass(nullptr, passName);
    SetViewport(0, 0, m_renderTargetSize.width, m_renderTargetSize.height);
    SetScissorDisable();
}



void MetalContext::SetVertexDescriptor(int vertexTypeID, const VertexDescriptor &vd)
{
    MTLVertexDescriptor *mvd = ConvertVertexDescriptor(vd);
    
    _vertexDescriptors[vertexTypeID] = mvd;
}


void MetalContext::SetIndexBuffer(BufferPtr ib)
{
    _userIndexBuffer = std::static_pointer_cast<MetalBuffer>(ib);
}

BufferPtr MetalContext::CreateBuffer(size_t count, size_t stride, const void *data, int vertexTypeID)
{
    size_t capacity = count * stride;
    if (capacity == 0)
        capacity = 16;
    id<MTLBuffer> buffer =  [_device newBufferWithBytes:data
                                             length:capacity
                                            options:RESOURCE_OPTIONS];
    return std::make_shared<MetalBuffer>(buffer, count, stride, vertexTypeID);
}

void MetalContext::SetVertexBuffer(int index, BufferPtr vb)
{
    _userVertexBuffer = std::static_pointer_cast<MetalBuffer>(vb);
    
    if (_userVertexBuffer)
    {
        _key.vertexTypeID = _userVertexBuffer->_vertexTypeID;
    }
}


void MetalContext::UploadIndexData(size_t count, size_t stride, const IndexType *indexData)
{
    _indexBuffer.Write(count, stride, indexData);
    
    _userIndexBuffer = nullptr;
}

void MetalContext::UploadVertexData(size_t count, size_t stride, const void *vertexData, int vertexTypeID)
{
    _vertexBuffer.Write(count, stride, vertexData);
    
    // set vertex type ID
    _key.vertexTypeID = vertexTypeID;
    
    _userVertexBuffer = nullptr;
}


bool MetalContext::UploadTextureData(TexturePtr texture, const void *data, int width, int height, int pitch)
{
    MetalTexturePtr mtexture = std::static_pointer_cast<MetalTexture>(texture);
    if (!mtexture) {
        return false;
    }

    _textureBuffer.WriteBytes(data, 16, pitch * height);

    EndEncoder();
        
    Size2D size = mtexture->GetSize();
    assert(width <= size.width && height <= size.height);
  
    auto cb = GetCommandBuffer();
    id<MTLBlitCommandEncoder> encoder = [cb blitCommandEncoder];
    
    [encoder copyFromBuffer:_textureBuffer.GetBuffer()
               sourceOffset:_textureBuffer.GetBase()
          sourceBytesPerRow:pitch
        sourceBytesPerImage:0
                 sourceSize:MTLSizeMake(width, height, 1)
                  toTexture:mtexture->_texture
           destinationSlice:0
           destinationLevel:0
          destinationOrigin:MTLOriginMake(0,0,0)
                    options:MTLBlitOptionNone
     ];
     
    [encoder endEncoding];
    
    return true;
}




static MTLPrimitiveType ConvertPrimType(PrimitiveType primType)
{
    switch (primType)
    {
        case PRIMTYPE_POINTLIST:
            return MTLPrimitiveTypePoint;
        case PRIMTYPE_LINELIST:
            return MTLPrimitiveTypeLine;
        case PRIMTYPE_LINESTRIP:
            return MTLPrimitiveTypeLineStrip;
        case PRIMTYPE_TRIANGLELIST:
            return MTLPrimitiveTypeTriangle;
        case PRIMTYPE_TRIANGLESTRIP:
            return MTLPrimitiveTypeTriangleStrip;
        default:
            assert(0);
            return MTLPrimitiveTypeTriangle;
    };
}

void MetalContext::DrawIndexed(PrimitiveType primType, int indexOffset, int indexCount)
{
    // flush shader before drawing
    id <MTLRenderCommandEncoder>  encoder = m_shader->Flush(this);
    if (!encoder) {
        // shader is invalid...skip draw
        return;
    }
    
    
    if (_userVertexBuffer)
    {
        // set vertex buffer
        [encoder setVertexBuffer:_userVertexBuffer->GetBuffer()
                                   offset:_userVertexBuffer->GetBase()
                                  atIndex:0];

    }
    else
    {
        // set vertex buffer
        [encoder setVertexBuffer:_vertexBuffer.GetBuffer()
                                   offset:_vertexBuffer.GetBase()
                                  atIndex:0];
    }
    
    if (_userIndexBuffer)
    {
        [encoder drawIndexedPrimitives:ConvertPrimType(primType)
                             indexCount:(NSUInteger)indexCount
                              indexType: _userIndexBuffer->GetStride() == 2 ? MTLIndexTypeUInt16 : MTLIndexTypeUInt32
                            indexBuffer: _userIndexBuffer->GetBuffer()
                      indexBufferOffset: _userIndexBuffer->GetBaseOffset(indexOffset)
            ];
    }
    else
    {

        [encoder drawIndexedPrimitives:ConvertPrimType(primType)
                             indexCount:(NSUInteger)indexCount
                              indexType: sizeof(IndexType) == 2 ? MTLIndexTypeUInt16 : MTLIndexTypeUInt32
                            indexBuffer: _indexBuffer.GetBuffer()
                      indexBufferOffset: _indexBuffer.GetBaseOffset<IndexType>(indexOffset)
            ];
    }
    
}


void MetalContext::DrawArrays(PrimitiveType primType, int vertexStart, int vertexCount)
{
    if (primType == PRIMTYPE_TRIANGLEFAN)
    {
        int primCount = vertexCount - 2;
        // draw triangle fan as indexed triangles
        IndexType index_data[primCount * 3];
        
        int index_count = 0;
        for (int i=0; i < primCount; i++)
        {
            index_data[index_count++] = 0;
            index_data[index_count++] = i+2;
            index_data[index_count++] = i+1;
        }
        UploadIndexData(index_count, sizeof(index_data[0]), index_data);
        DrawIndexed(PRIMTYPE_TRIANGLELIST, 0, index_count);
        return;
    }
    
    // flush shader before drawing
    id <MTLRenderCommandEncoder>  encoder = m_shader->Flush(this);
    if (!encoder) {
        // shader is invalid...skip draw
        return;
    }
    

    
    
    // set vertex buffer
    [encoder setVertexBuffer:_vertexBuffer.GetBuffer()
                       offset:_vertexBuffer.GetBase()
                      atIndex:0];
    
    [encoder drawPrimitives:ConvertPrimType(primType)
                 vertexStart:(NSUInteger)vertexStart
                 vertexCount:(NSUInteger)vertexCount
     ];
}


//void MetalContext::Clear(Color4F color)
//{
//    SetRenderTarget(m_renderTarget, "Clear", LoadAction::Clear, color);
//}
//

IMetalContextPtr MetalCreateContext(id <MTLDevice> device)
{
    return std::make_shared<MetalContext>(device);
}




}} // namespace render::metal
