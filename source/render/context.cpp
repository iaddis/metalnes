
#include "context.h"
#include <assert.h>

#include "Core/Path.h"
#include "Core/File.h"

namespace render {



template <>
int GetVertexTypeID<Vertex>()
{
    return 0;
}


ShaderPtr Context::LoadShaderFromFile(const std::string &path)
{
    std::string full_path = Core::Path::Combine(_assetDir, path);
    
    std::string code;
    if (!Core::File::ReadAllText(full_path, code))
    {
        assert(0);
        return nullptr;
    }
    std::string name = Core::Path::GetFileName(path);
    
    ShaderPtr shader = CreateShader(name.c_str());
    bool result = shader->CompileAndLink({
        ShaderSource{ShaderType::Vertex,     full_path, code, "VS", "vs_3_0", "hlsl"},
        ShaderSource{ShaderType::Fragment,   full_path, code, "PS", "ps_3_0", "hlsl"}
    });
    assert(result);
    return shader;
}

void Context::SetDisplayInfo(DisplayInfo info)
{
    m_displayInfo = info;
    OnSetDisplayInfo();
}



int PixelFormatGetPixelSize(PixelFormat format)
{
    switch (format)
    {
        case PixelFormat::Invalid:
            return 0;
        case PixelFormat::A8Unorm:
            return sizeof(uint8_t) * 1;
        case PixelFormat::RGBA8Unorm:
        case PixelFormat::RGBA8Unorm_sRGB:
        case PixelFormat::BGRA8Unorm:
        case PixelFormat::BGRA8Unorm_sRGB:
            return sizeof(uint8_t) * 4;
        case PixelFormat::RGBA16Unorm:
            return sizeof(uint16_t) * 4;
        case PixelFormat::RGBA16Snorm:
            return sizeof(int16_t) * 4;
        case PixelFormat::RGBA16Float:
            return sizeof(uint16_t) * 4;
        case PixelFormat::RGBA32Float:
            return sizeof(float) * 4;
        case PixelFormat::BGR10A2Unorm:
            return sizeof(uint32_t);

        case PixelFormat::BGR10_XR:           // ios only
        case PixelFormat::BGR10_XR_sRGB:           // ios only
            return sizeof(uint32_t);


        default:
            assert(0);
            return 0;
    }
}

bool PixelFormatIsHDR(PixelFormat format)
{
    switch (format)
    {
        case PixelFormat::Invalid:
            return false;
        case PixelFormat::A8Unorm:
            return false;
        case PixelFormat::RGBA8Unorm:
        case PixelFormat::RGBA8Unorm_sRGB:
        case PixelFormat::BGRA8Unorm:
        case PixelFormat::BGRA8Unorm_sRGB:
            return false;

        case PixelFormat::RGBA16Unorm:
        case PixelFormat::RGBA16Snorm:
        case PixelFormat::RGBA16Float:
        case PixelFormat::RGBA32Float:
        case PixelFormat::BGR10A2Unorm:
            return true;

        case PixelFormat::BGR10_XR:           // ios only
        case PixelFormat::BGR10_XR_sRGB:           // ios only
            return true;


        default:
            return false;
    }
}


const char *PixelFormatToString(PixelFormat fmt)
{
#define _CASE(_x) case PixelFormat::_x: return #_x;
    
    switch (fmt)
    {
        _CASE(Invalid)
        _CASE(A8Unorm)
        _CASE(RGBA8Unorm)
        _CASE(RGBA8Unorm_sRGB)
        _CASE(BGRA8Unorm)
        _CASE(BGRA8Unorm_sRGB)
        _CASE(RGBA16Unorm)
        _CASE(RGBA16Snorm)
        _CASE(RGBA16Float)
        _CASE(RGBA32Float)
        _CASE(BGR10A2Unorm)
        _CASE(BGR10_XR)
        _CASE(BGR10_XR_sRGB)


        default:
            return "<unknown>";
    }
#undef _CASE
}


}
