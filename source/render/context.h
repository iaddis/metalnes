
#pragma once


#include <string>
#include <memory>
#include <memory.h>
#include <queue>
#include <fstream>
#include <streambuf>
#include <sstream>
#include <functional>
#include "Core/Math.h"

namespace render {

struct Vertex
{
    Vector4 position;
    Vector4 color;
    Vector2 texcoord0;
    Vector2 texcoord1;
};




enum class PixelFormat
{
    Invalid,
    A8Unorm,
    RGBA8Unorm,
    RGBA8Unorm_sRGB,
    BGRA8Unorm,
    BGRA8Unorm_sRGB,
    RGBA16Unorm,
    RGBA16Snorm,
    RGBA16Float,
    RGBA32Float,
    BGR10A2Unorm,
    BGR10_XR,           // ios only
    BGR10_XR_sRGB,      // ios only
};

const char *PixelFormatToString(PixelFormat format);
int PixelFormatGetPixelSize(PixelFormat format);
bool PixelFormatIsHDR(PixelFormat format);


enum class VertexFormat
{
    Invalid,
    Float,
    Float2,
    Float3,
    Float4,
    UChar4Normalized,
};

struct VertexAttribute
{
    int          index;
    VertexFormat format;
    int          offset;
    int          bufferIndex = 0;
};


enum VertexAttribIndex
{
    VertexAttribPosition = 0,
    VertexAttribColor = 1,
    VertexAttribTexCoord0 = 2,
    VertexAttribTexCoord1 = 3
};


struct VertexDescriptor
{
    size_t                       stride;
    std::vector<VertexAttribute> attribs;
};




template <typename T>
int GetVertexTypeID();


template <>
int GetVertexTypeID<Vertex>();


enum PrimitiveType 
{
	PRIMTYPE_POINTLIST = 1,
	PRIMTYPE_LINELIST = 2,
	PRIMTYPE_LINESTRIP = 3,
	PRIMTYPE_TRIANGLELIST = 4,
	PRIMTYPE_TRIANGLESTRIP = 5,
	PRIMTYPE_TRIANGLEFAN = 6,
	PRIMTYPE_FORCE_DWORD = 0x7fffffff, /* force 32-bit size enum */
};

enum SamplerAddress
{
	SAMPLER_WRAP,
	SAMPLER_CLAMP
};

enum SamplerFilter
{
	SAMPLER_POINT,
	SAMPLER_LINEAR,
	SAMPLER_ANISOTROPIC
};

enum BlendFactor
{
	BLEND_ZERO = 1,
	BLEND_ONE = 2,
	BLEND_SRCCOLOR = 3,
	BLEND_INVSRCCOLOR = 4,
	BLEND_SRCALPHA = 5,
	BLEND_INVSRCALPHA = 6,
	BLEND_DESTALPHA = 7,
	BLEND_INVDESTALPHA = 8,
	BLEND_DESTCOLOR = 9,
	BLEND_INVDESTCOLOR = 10,
};

class Context;
class Texture;
class Shader;
class ShaderSampler;
class ShaderConstant;

using ContextPtr = std::shared_ptr<Context>;
using ShaderSamplerPtr = std::shared_ptr<ShaderSampler>;
using ShaderConstantPtr = std::shared_ptr<ShaderConstant>;
using ShaderPtr = std::shared_ptr<Shader>;
using TexturePtr = std::shared_ptr<Texture>;

//using IndexType = uint16_t;
using IndexType = uint32_t;


struct RenderStats
{
    double timeBlocking;
    int drawCalls;
    int indexCount;
    int vertexCount;
    int triangleCount;
    int lineCount;
    
    void Clear()
    {
        timeBlocking = 0;
        drawCalls = 0;
        indexCount = 0;
        vertexCount = 0;
        triangleCount = 0;
        lineCount = 0;
    }
    
};


using ImageDataPtr = std::shared_ptr<class ImageData>;

class ImageData
{
public:
    ImageData(int width, int height, PixelFormat format)
    : format(format),
        width(width), height(height),
        pitch(width * PixelFormatGetPixelSize(format)),
        size(pitch * height)
    {
        data = new uint8_t[size];
        memset(data,0,size);
    }
    
    virtual ~ImageData()
    {
        delete[] data;
    }
    
    template<typename T>
    inline T *Row(int line)
    {
        if ((uint32_t)line >= (uint32_t)height) return nullptr;
        return (T *)(data + line * pitch);
    }

    template<typename T>
    inline const T *Row(int line) const
    {
        if ((uint32_t)line >= (uint32_t)height) return nullptr;
        return (const T *)(data + line * pitch);
    }
    
    static inline ImageDataPtr Create(int width, int height, PixelFormat format)
    {
        return std::make_shared<ImageData>(width, height, format);
    }

    
    PixelFormat   format;
    int           width;
    int           height;
    size_t        pitch;
    size_t        size;
    uint8_t *     data;
};


class Texture
{
protected:
	Texture()  = default;
    
public:
    virtual ~Texture() = default;

    virtual TexturePtr GetSharedPtr() = 0;
    virtual const std::string &GetName() = 0;
    virtual Size2D GetSize() = 0;    
    virtual PixelFormat GetFormat() = 0;

    

    int GetWidth() {
        return GetSize().width;
    }
    int GetHeight() {
        return GetSize().height;
    }
    
};



class Buffer
{
public:
    Buffer() = default;
    virtual ~Buffer() = default;
};
using BufferPtr = std::shared_ptr<Buffer>;




class ShaderSampler
{
protected:
	ShaderSampler() = default;
    virtual ~ShaderSampler() = default;
    
public:
	virtual const std::string &GetName() = 0;

    virtual void SetTexture(TexturePtr texture)
    {
        SetTexture(texture, SAMPLER_WRAP, SAMPLER_LINEAR);
    }

    virtual void SetTexture(TexturePtr texture, SamplerAddress address, SamplerFilter filter) = 0;
};


class ShaderConstant
{
protected:
	ShaderConstant() = default;
    virtual ~ShaderConstant() = default;

public:
	virtual const std::string &GetName() = 0;
    virtual void Set(float f) = 0;
    virtual void Set(const Vector2 &v) = 0;
    virtual void Set(const Vector3 &v) = 0;
    virtual void Set(const Vector4 &v) = 0;
    virtual void Set(const Matrix44 &m) = 0;
};

enum class ShaderType
{
    Vertex,
    Fragment
};

struct ShaderSource
{
    bool IsVertex() const   {return type == ShaderType::Vertex;}
    bool IsFragment() const {return type == ShaderType::Fragment;}
    
    ShaderType  type;
    std::string path;
    std::string code;
    std::string functionName;
    std::string profile;
    std::string language;
};


class Shader
{
public:
    Shader() = default;
	virtual ~Shader()  = default;


    virtual bool CompileAndLink(const std::initializer_list<ShaderSource> &sourceList)
    {
        for (auto source : sourceList)
        {
            Compile(source);
        }
        return Link();
    }

protected:
    virtual bool Compile(const ShaderSource &source) = 0;
	virtual bool Link() = 0;
public:
    virtual std::string GetErrors() = 0;

    
	virtual int			GetSamplerCount() = 0;
	virtual ShaderSamplerPtr   GetSampler(int index) = 0;
    
	virtual int			GetConstantCount() = 0;
	virtual ShaderConstantPtr	GetConstant(int index) = 0;

    bool SetSampler(int index, TexturePtr texture, SamplerAddress address = SAMPLER_WRAP, SamplerFilter filter = SAMPLER_LINEAR)
    {
        ShaderSamplerPtr sampler = GetSampler(index);
        if (!sampler)
          return false;

        sampler->SetTexture(texture, address, filter);
        return true;
    }

    
    bool SetSampler(const char *name, TexturePtr texture, SamplerAddress address = SAMPLER_WRAP, SamplerFilter filter = SAMPLER_LINEAR)
    {
       ShaderSamplerPtr sampler = FindSampler(name);
       if (!sampler)
           return false;
       
       sampler->SetTexture(texture, address, filter);
       return true;
    }
    
    template<typename T>
    bool SetConstant(const char *name, T v)
    {
        ShaderConstantPtr constant = GetConstant(name);
        if (!constant)
            return false;
        
        constant->Set(v);
        return true;
    }

	virtual ShaderConstantPtr	GetConstant(const char *name)
	{
		int count = GetConstantCount();
		for (int i = 0; i < count; i++)
		{
			ShaderConstantPtr constant = GetConstant(i);
			if (constant->GetName() == name) {
				return constant;
			}
		}
		return NULL;
	}
    
    
    virtual ShaderSamplerPtr    FindSampler(const char *name)
    {
        int count = GetSamplerCount();
        for (int i = 0; i < count; i++)
        {
            auto sampler = GetSampler(i);
            if (sampler->GetName() == name) {
                return sampler;
            }
        }
        return NULL;
    }
private:

};


struct DisplayInfo
{
    Size2D      size = Size2D(0, 0);
    PixelFormat format = render::PixelFormat::Invalid;
    float       refreshRate = 60.0f;
    float       scale = 1;
    int         samples = 1;
    float       maxEDR = 1.0f;
    bool        srgb = false;
    bool        hdr = false;
    std::string colorSpace;
};


enum class LoadAction
{
    Load,
    Clear,
    Discard
};

enum ColorWriteMask
{
    ColorWriteMaskNone  = 0,
    ColorWriteMaskRed   = 0x1 << 3,
    ColorWriteMaskGreen = 0x1 << 2,
    ColorWriteMaskBlue  = 0x1 << 1,
    ColorWriteMaskAlpha = 0x1 << 0,
    ColorWriteMaskAll   = 0xf
};


// rendering context
class Context
{
protected:
    Context()  = default;
public:
    virtual ~Context() = default;


    int     GetDisplayMultisampleCount() const           { return m_displayInfo.samples; }

    virtual float GetDisplayScale() const           { return m_displayInfo.scale; }
    virtual float GetDisplayRate() const            { return m_displayInfo.refreshRate; }
    virtual Size2D GetDisplaySize() const           { return m_displayInfo.size; }
    virtual PixelFormat GetDisplayFormat() const    { return m_displayInfo.format; }
    virtual float GetDisplayEDRMax() const          { return m_displayInfo.maxEDR;}
    
    virtual float GetTexelOffset() = 0;
	virtual const std::string &GetDriver() = 0;
	virtual const std::string &GetDesc() = 0;
    
    virtual void PushLabel(const char *name) {}
    virtual void PopLabel() {}
    
    virtual bool IsThreaded() { return false; }

	virtual TexturePtr CreateTextureFromFile(const char *name, const char *path) = 0;
	virtual TexturePtr CreateRenderTarget(const char *name, int width, int height, PixelFormat format) = 0;
	virtual TexturePtr CreateTexture(const char *name, int width, int height, PixelFormat format, const void *data) = 0;
	virtual ShaderPtr  CreateShader(const char *name) = 0;
    virtual ShaderPtr  LoadShaderFromFile(const std::string &path);
    
    virtual void SetAssetDir(std::string dir) {_assetDir = dir;}

    virtual void GetImageDataAsync(TexturePtr texture, std::function<void(ImageDataPtr)> callback) = 0;
   

    
	virtual void SetShader(ShaderPtr shader) = 0;

    virtual void SetDepthEnable(bool enable) = 0;
	virtual void SetBlend(BlendFactor sourceFactor, BlendFactor destFactor) = 0;
    virtual void SetBlendDisable() = 0;
    virtual void SetWriteMask(int mask) {}

    virtual void SetTransform(const Matrix44 &m) = 0;
    virtual const Matrix44 &GetTransform() const = 0;

    virtual void SetDisplayInfo(DisplayInfo info);
    virtual const DisplayInfo &GetDisplayInfo() {return m_displayInfo;}
    virtual void OnSetDisplayInfo() {}

	virtual void Present() = 0;
    virtual void NextFrame() = 0;
    
    virtual void Flush() {}

    virtual Size2D GetRenderTargetSize() = 0;


    virtual void SetRenderTarget(TexturePtr texture, const char *passName = nullptr, LoadAction action = LoadAction::Load, Color4F clearColor = Color4F(0,0,0,0) ) = 0;


	virtual void SetPointSize(float size) = 0;
	//virtual void Draw(PrimitiveType primType, int count, const Vertex *v) = 0;
    
    virtual void SetScissorRect(int x, int y, int w, int h) = 0;
    virtual void SetScissorDisable() = 0;
    virtual void SetViewport(int x, int y, int w, int h) = 0;
    

    virtual void SetVertexDescriptor(int vertexTypeID, const VertexDescriptor &vd) = 0;
    
    template<typename TVertex>
    void SetVertexDescriptor(const VertexDescriptor &vd)
    {
        SetVertexDescriptor(GetVertexTypeID<TVertex>(), vd);
    }


    
    virtual BufferPtr CreateBuffer(size_t count, size_t stride, const void *data, int vertexTypeID) = 0;
    virtual void SetIndexBuffer(BufferPtr ib) = 0;
    virtual void SetVertexBuffer(int index, BufferPtr vb) = 0;

    
    virtual void UploadIndexData(size_t count, size_t stride, const IndexType *indices) = 0;
    virtual void UploadVertexData(size_t count, size_t stride, const void *data, int vertexTypeID) = 0;
    virtual void DrawArrays(PrimitiveType primType, int vertexStart, int vertexCount) = 0;
    virtual void DrawIndexed(PrimitiveType primType, int indexOffset, int indexCount) = 0;

    
    virtual bool UploadTextureData(TexturePtr texture, const void *data, int width, int height, int pitch) {return false;}



    BufferPtr CreateIndexBuffer(size_t count, const IndexType *data)
    {
        return CreateBuffer(count, sizeof(data[0]), data, 0);
    }

    template<typename TVertex>
    BufferPtr CreateVertexBuffer(size_t count, const TVertex *data)
    {
        return CreateBuffer(count, sizeof(data[0]), data, GetVertexTypeID<TVertex>() );
    }

    
    
    template<typename TVertex>
    void UploadVertexData(size_t count, const TVertex *data)
    {
        UploadVertexData(count, sizeof(data[0]), data, GetVertexTypeID<TVertex>() );
    }


    template<typename TVertex>
    void DrawArrays(PrimitiveType primType, int count, const TVertex *data)
    {
        UploadVertexData(count, data);
        DrawArrays(primType, 0, count);
    }


    template<typename TVertex>
    void DrawArrays(PrimitiveType primType, const std::vector<TVertex> &vertexData)
    {
       DrawArrays(primType, (int) vertexData.size(), vertexData.data() );
    }
    
    void UploadIndexData(const std::vector<IndexType> &indexData)
    {
        UploadIndexData(indexData.size(), sizeof(indexData[0]), indexData.data());
    }

    template<typename TVertex>
    void UploadVertexData(const std::vector<TVertex> &vertexData)
    {
        UploadVertexData(vertexData.size(), vertexData.data());
    }

    template<typename TVertex>
    BufferPtr CreateVertexBuffer(const std::vector<TVertex> &v)
    {
        return CreateVertexBuffer( v.size(), v.data() );
    }

    BufferPtr CreateIndexBuffer(const std::vector<IndexType> &v)
    {
        return CreateIndexBuffer( v.size(), v.data() );
    }

    
    virtual bool IsSupported(PixelFormat format) { return false; }


protected:
    
    DisplayInfo             m_displayInfo;
    std::string             _assetDir;

};

} // render
 
