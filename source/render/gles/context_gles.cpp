
#if !defined(WIN32)


#if __APPLE__
#include <TargetConditionals.h>

#define GL_SILENCE_DEPRECATION 1
#define GLES_SILENCE_DEPRECATION 1

#if TARGET_OS_IPHONE
#include <OpenGLES/ES3/gl.h>
#include <OpenGLES/ES3/glext.h>
#else
#include <OpenGL/gl.h>
#include <OpenGL/glext.h>
#include <OpenGL/glu.h>
#define glGenVertexArrays glGenVertexArraysAPPLE
#define glBindVertexArray glBindVertexArrayAPPLE
#define glDeleteVertexArrays glDeleteVertexArraysAPPLE

#define GL_RGBA16UI GL_RGBA16UI_EXT
#define GL_RGBA16I GL_RGBA16I_EXT
#define GL_RGBA16F GL_RGBA16F_ARB
#define GL_RGBA32F GL_RGBA32F_ARB

#endif

#elif EMSCRIPTEN
#include <emscripten.h>
#include <GLES3/gl3.h>
#include <EGL/egl.h>
#include <gl/gl.h>
#include <gl/glext.h>

#elif __ANDROID__

#include <GLES3/gl3.h>
#include <GLES3/gl3ext.h>
#include <EGL/egl.h>

#define GL_RGBA16 GL_RGBA16_EXT
#define GL_RGBA16F_ARB GL_RGBA16F

#define GL_BGRA                       0x80E1
#define GL_BGRA8                      0x93A1
#elif __linux__

#include <GL/gl.h>
#include <GL/glext.h>

#else
#error Unsupported platform
#endif

#include "render/context.h"
#include "context_gles.h"
#include <assert.h>
#include <map>
#include <iostream>
#include "Core/Log.h"
#include "Core/Path.h"
#include "Core/File.h"
#include "../../../external/hlsl2glslfork/include/hlsl2glsl.h"


namespace render {
namespace gles {



#define GL_ERROR_CHECK (0)

static void CheckGLError()
{
#if GL_ERROR_CHECK
    int error = glGetError();
    if (!error) return;
    printf("glError 0x%X: %s\n", error,
           "" // gluErrorString(error)
           );
    assert(0);
#endif
}


enum VertexAttrib
{
    VertexAttribPosition = 0,
    VertexAttribColor = 1,
    VertexAttribTexCoord0 = 2,
    VertexAttribTexCoord1 = 3
};



//
// gl texture 
//

class GLContext;
class GLTexture;
class GLShader;

using GLContextPtr = std::shared_ptr<GLContext>;
using GLTexturePtr = std::shared_ptr<GLTexture>;
using GLShaderPtr =std::shared_ptr<GLShader>;


struct TexImageFormat
{
    int internalFormat;
    int format;
    int type;
};

static TexImageFormat ConvertFormat(PixelFormat format)
{
    switch (format)
    {
        case PixelFormat::Invalid:
            return TexImageFormat{0,0,0};
        case PixelFormat::A8Unorm:
            return TexImageFormat{GL_R8, GL_ALPHA, GL_UNSIGNED_BYTE};
        case PixelFormat::RGBA8Unorm:
            return TexImageFormat{GL_RGBA8, GL_RGBA, GL_UNSIGNED_BYTE};
        case PixelFormat::RGBA8Unorm_sRGB:
            return TexImageFormat{GL_SRGB8_ALPHA8, GL_RGBA, GL_UNSIGNED_BYTE};
        case PixelFormat::BGRA8Unorm:
            return TexImageFormat{GL_RGBA8, GL_BGRA, GL_UNSIGNED_BYTE};
        case PixelFormat::BGRA8Unorm_sRGB:
            return TexImageFormat{GL_SRGB8_ALPHA8, GL_BGRA, GL_UNSIGNED_BYTE};
        case PixelFormat::RGBA16Unorm:
            return TexImageFormat{GL_RGBA16UI, GL_RGBA, GL_UNSIGNED_SHORT};
        case PixelFormat::RGBA16Snorm:
            return TexImageFormat{GL_RGBA16I, GL_RGBA, GL_SHORT};
        case PixelFormat::RGBA16Float:
            return TexImageFormat{GL_RGBA16F, GL_RGBA, GL_HALF_FLOAT};
        case PixelFormat::RGBA32Float:
            return TexImageFormat{GL_RGBA32F, GL_RGBA, GL_FLOAT};
            
        case PixelFormat::BGR10A2Unorm:
            return TexImageFormat{GL_RGB10_A2, GL_RGBA, GL_UNSIGNED_INT_2_10_10_10_REV};

#if TARGET_OS_IPHONE
        case PixelFormat::BGR10_XR:           // ios only
            return TexImageFormat{GL_RGB10_A2, GL_BGRA, GL_UNSIGNED_INT_2_10_10_10_REV};
        case PixelFormat::BGR10_XR_sRGB:           // ios only
            return TexImageFormat{GL_RGB10_A2, GL_BGRA, GL_UNSIGNED_INT_2_10_10_10_REV};
#endif
            
        default:
            assert(0);
            return TexImageFormat{0,0,0};
    }
}




class GLTexture : public Texture, public std::enable_shared_from_this<GLTexture>
{
public:
    GLTexture(std::string name, GLuint id, int width, int height, PixelFormat format)
		: m_name(name),m_id(id), m_fbo(), m_size(width, height), m_format(format)
	{
#ifdef glLabelObjectEXT
        glLabelObjectEXT(GL_TEXTURE, m_id, (GLsizei)name.size(), name.c_str());
#endif
	}

    virtual TexturePtr GetSharedPtr() override { return shared_from_this(); }
    
	virtual ~GLTexture()
	{
        glDeleteTextures(1, &m_id);
        
        if (m_fbo)
        {
            glDeleteFramebuffers(1, &m_fbo);
        }
	}

    virtual Size2D GetSize() override
    {
        return m_size;
    }
    
    virtual PixelFormat GetFormat() override
    {
        return m_format;
    }


    
    virtual const std::string &GetName() override { return m_name; }
    

//protected:
    std::string m_name;
	GLuint m_id;
	GLuint m_fbo;
	Size2D m_size;
    PixelFormat m_format;
};




//
// gl rendering context
//
class GLContext : public Context
{
public:
	GLContext(GLTextureLoadFunc textureLoadFunc);
	virtual ~GLContext();
	
	
	
    virtual bool IsSupported(PixelFormat format) override;

	virtual TexturePtr CreateTextureFromFile(const char *name, const char *path) override;
	virtual TexturePtr CreateRenderTarget(const char *name, int width, int height, PixelFormat format) override;
	virtual TexturePtr CreateTexture(const char *name, int width, int height, PixelFormat format, const void *data) override;
	virtual ShaderPtr  CreateShader(const char *name) override;

    virtual void GetImageDataAsync(TexturePtr texture, std::function<void (ImageDataPtr)> callback) override;


//	virtual void SetRenderTarget(TexturePtr texture) override;
    virtual void SetRenderTarget(TexturePtr texture, const char *passName = nullptr, LoadAction action = LoadAction::Load, Color4F clearColor = Color4F(0,0,0,0) ) override;

    virtual Size2D GetRenderTargetSize() override {
        return m_renderTargetSize;
    }

    virtual const std::string &GetDriver()  override { return m_driver; };
    virtual const std::string &GetDesc() override  { return m_description; };
    
    std::string m_driver = "GLES";
    std::string m_description = (const char *)glGetString(GL_VERSION);

    
    virtual float GetTexelOffset() override
    {
//        return 0.5f;
            return 0.0f; 
    }

	
	virtual void Present()  override;
	virtual void NextFrame()  override;
    virtual void Flush()  override;

    
    virtual void PushLabel(const char *name) override
    {
#ifdef glPushGroupMarkerEXT
        glPushGroupMarkerEXT((int)strlen(name), name);
#endif
    }
    
    virtual void PopLabel() override
    {
#ifdef glPopGroupMarkerEXT
        glPopGroupMarkerEXT();
#endif
    }

    
    virtual void ResetState();

    virtual void OnSetDisplayInfo() override {
#if !EMSCRIPTEN
        // get framebuffer
        glGetIntegerv(GL_FRAMEBUFFER_BINDING, &m_fbo);
#endif

    }
    
	virtual void SetShader(ShaderPtr shader) override;
	virtual void InternalSetTexture(int index, TexturePtr texture, SamplerAddress address, SamplerFilter filter);
	virtual void SetPointSize(float size) override;
	virtual void SetDepthEnable(bool enable) override;
    virtual void SetBlend(BlendFactor sourceFactor, BlendFactor destFactor) override;
    virtual void SetBlendDisable() override;
    virtual void Clear(Color4F color);
    

    virtual void SetVertexDescriptor(int vertexTypeID, const VertexDescriptor &vd) override
    {
        
    }

    virtual void UploadIndexData(size_t count, size_t stride, const IndexType *indices) override;
    virtual void UploadVertexData(size_t count, size_t stride, const void *data, int vertexTypeId) override;
    virtual void DrawArrays(PrimitiveType primType, int vertexStart, int vertexCount) override;
    virtual void DrawIndexed(PrimitiveType primType, int indexOffset, int indexCount) override;

    virtual void SetViewport(int x, int y, int w, int h) override 
    {
        glViewport(x,y,w,h);
    }
    
    virtual void SetTransform(const Matrix44 &m) override
    {
        m_xform = m;
    }

    virtual const Matrix44 &GetTransform() const override
    {
        return m_xform;
    }
    
    virtual void SetScissorRect(int x, int y, int w, int h) override
    {
        glEnable(GL_SCISSOR_TEST);
        glScissor(x, m_renderTargetSize.height - y - h, w, h);
    }
    virtual void SetScissorDisable() override
    {
        glDisable(GL_SCISSOR_TEST);
    }
    
    render::BufferPtr CreateBuffer(size_t count, size_t stride, const void *data, int vertexTypeId) override {
        return nullptr;
    }
    
    void SetIndexBuffer(render::BufferPtr ib) override {
        
    }
    
    void SetVertexBuffer(int index, render::BufferPtr vb) override {
        
    }
    


    bool HasTextureRenderTarget() const {return m_renderTarget != nullptr;}
    
    inline float GetPointSize() const {return m_pointsize;}
protected:
    
    GLTextureLoadFunc m_textureLoadFunc;
    
    GLTexturePtr        m_renderTarget;
    Size2D              m_renderTargetSize;
    
    TexturePtr m_whiteTexture;
    GLShaderPtr m_shader;


    Matrix44 m_xform = Matrix44::Identity();
    float m_pointsize = 1.0f;

    GLuint				m_vb = 0;
    GLuint              m_ib = 0;
    GLuint              m_vao = 0;
	GLint               m_fbo = 0;
};


void GLContext::GetImageDataAsync(TexturePtr texture, std::function<void (ImageDataPtr)> callback)

{
#if !TARGET_OS_IPHONE && !EMSCRIPTEN && !defined(__ANDROID__)
    GLTexturePtr gltexture = std::static_pointer_cast<GLTexture>(texture);
    if (!gltexture) {
        callback(nullptr);
        return;
    }
    
    Size2D size = gltexture->GetSize();
    
    ImageDataPtr image = std::make_shared<ImageData>(size.width, size.height, PixelFormat::RGBA8Unorm);

    GLint old_texture = 0;
    glActiveTexture(GL_TEXTURE8);
    glGetIntegerv(GL_TEXTURE_BINDING_2D,  &old_texture);
    glBindTexture(GL_TEXTURE_2D, gltexture->m_id);
    glGetTexImage(GL_TEXTURE_2D, 0,  GL_RGBA, GL_UNSIGNED_BYTE, (void *)image->data);
    glBindTexture(GL_TEXTURE_2D, old_texture);

    assert(glGetError() == 0);
    glActiveTexture(GL_TEXTURE0);
    callback(image);
#else
    callback(nullptr);
#endif
}


//
//
//

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



static bool ConvertHLSLToGLSL(const ShaderSource &source, ShaderSource &glsl_source)
{
    std::string hlsl = source.code;
    std::string rootDir = Core::Path::GetDirectory(source.path);
    
    EShLanguage language = (source.profile[0] == 'v') ? EShLangVertex : EShLangFragment;
    
    int options = ETranslateOpAvoidBuiltinAttribNames;
//    options |= ETranslateOpIntermediate;
    // options |= ETranslateOpEmitGLSL120ArrayInitWorkaround;
#if TARGET_OS_IPHONE || defined(EMSCRIPTEN) || defined(__ANDROID__)
    //ETargetVersion  targetVersion = ETargetGLSL_ES_100;
    ETargetVersion  targetVersion = ETargetGLSL_ES_300;
#else
    ETargetVersion  targetVersion = ETargetGLSL_120;
#endif
    
    hlsl.insert(0, "#define GLSL 1\n");
   


    ShHandle compiler = Hlsl2Glsl_ConstructCompiler(language);
    Hlsl2Glsl_ParseCallbacks callbacks {_Hlsl2Glsl_IncludeOpenFunc, _Hlsl2Glsl_IncludeCloseFunc, &rootDir};
    if (!Hlsl2Glsl_Parse(compiler, hlsl.c_str(),
                        targetVersion,
                        &callbacks, options)) {
        printf("Hlsl2Glsl_Parse error: %s\n", Hlsl2Glsl_GetInfoLog(compiler));
        printf("%s\n", hlsl.c_str());
        Hlsl2Glsl_DestructCompiler(compiler);
        return false;
    }
    
//    printf("Hlsl2Glsl %s\n", Hlsl2Glsl_GetInfoLog(compiler))
    
    if ( !Hlsl2Glsl_Translate(
                             compiler,
                             source.functionName.c_str(),
                             targetVersion,
                             options)) {
        printf("Hlsl2Glsl_Translate error: %s\n", Hlsl2Glsl_GetInfoLog(compiler));
        printf("%s\n", hlsl.c_str());
        Hlsl2Glsl_DestructCompiler(compiler);
        return false;
    }

    
    std::string glsl = Hlsl2Glsl_GetShader(compiler);
    Hlsl2Glsl_DestructCompiler(compiler);
    
    std::string prefix;

    if (targetVersion == ETargetGLSL_ES_100)
    {
        prefix += "#version 100\n";
        if (language == EShLangFragment)
            prefix += " precision lowp float;\n";
        else
            prefix += " precision highp float;\n";
    }
    
    // fix it up for GLES3
    if (targetVersion == ETargetGLSL_ES_300)
    {
        prefix += "#version 300 es\n";
        prefix += " precision highp float;\n";
        if (language == EShLangFragment)
        {
            prefix += " out highp vec4 xlt_FragData;";
            
            std::string search = "gl_FragData[0]";
            size_t pos = glsl.find(search);
            if (pos != std::string::npos) {
                glsl.replace(pos, search.size(), "xlt_FragData");
            }
        }
    }
    
    glsl.insert(0, prefix);
    
    glsl_source.code = glsl;
    glsl_source.functionName = "main";
    glsl_source.profile  = source.IsVertex() ? "vertex_glsl" : "fragment_glsl";
    glsl_source.path = source.path;
    glsl_source.language = "glsl";
    return true;

}



class GLShaderConstant : public ShaderConstant
{
public:
    inline GLShaderConstant(std::string name, int location, GLenum type)
    :m_name(name), m_location(location), m_type(type)
    {
        memset(&m_value, 0, sizeof(m_value));
    }
    
    virtual ~GLShaderConstant() {}
    
    virtual const std::string &GetName() override
    {
        return m_name;
    }
    
    int GetRegister()
    {
        return m_location;
    }
    
    virtual void Set(float f) override
    {
        m_value.f1 = f;
        //glUniform1f(m_location, f);
    }

    
    virtual void Set(const Vector4 &v) override
    {
        *(Vector4 *)&m_value.v4 = v;
        //glUniform4fv(m_location, 1, (const float *)&v);
    }
    
    virtual void Set(const Matrix44 &m) override
    {
        *(Matrix44 *)&m_value.m44 = m;
        //glUniformMatrix4fv(m_location, 1, false, (const float *)&m);
    }
    
    void Set(const Vector2 &v) override {
        m_value.v4[0] = v.x;
        m_value.v4[1] = v.y;
        m_value.v4[2] = 0;
        m_value.v4[3] = 0;
    }
    
    void Set(const Vector3 &v) override {
        m_value.v4[0] = v.x;
        m_value.v4[1] = v.y;
        m_value.v4[2] = v.z;
        m_value.v4[3] = 0;
    }
    
    
    void Flush(GLContext *context)
    {
        switch (m_type)
        {
            case GL_INT:
                break;
            case GL_FLOAT:
                glUniform1f(m_location, m_value.f1);
                break;
            case GL_FLOAT_VEC2:
                glUniform2fv(m_location, 1, m_value.v4);
                break;
            case GL_FLOAT_VEC3:
                glUniform3fv(m_location, 1, m_value.v4);
                break;
                
            case GL_FLOAT_MAT2:
                glUniformMatrix2fv(m_location, 1, false, m_value.m44);
                break;

            case GL_FLOAT_VEC4:
                glUniform4fv(m_location, 1, m_value.v4);
                break;
            case GL_FLOAT_MAT4:
                glUniformMatrix4fv(m_location, 1, false, m_value.m44);
                break;
            default:
                assert(0);
                break;
        }
    }
    
    std::string m_name;
    int  m_location;
    GLenum m_type;
    
    union
    {
        float f1;
        float v4[4];
        float m44[16];
    } m_value;
    
};


class GLShaderSampler : public ShaderSampler
{
public:
    inline GLShaderSampler(std::string name, int location, int reg)
    :m_name(name), m_location(location), m_register(reg)
    {
    }
    
    virtual ~GLShaderSampler() {}
    
    virtual const std::string &GetName() override
    {
        return m_name;
    }
    
    
    virtual void SetTexture(TexturePtr texture, SamplerAddress addr, SamplerFilter filter) override
    {
        m_texture = texture;
        m_addr = addr;
        m_filter = filter;
    }
    
    void Flush(GLContext *context)
    {
        glUniform1i(m_location, m_register);
        context->InternalSetTexture(m_register, m_texture, m_addr, m_filter);
    }
    
    int GetRegister() 
    {
        return m_register;
    }
    
protected:
    TexturePtr m_texture;
    SamplerAddress m_addr = SAMPLER_WRAP;
    SamplerFilter m_filter = SAMPLER_LINEAR;
    std::string m_name;
    int m_location;
    int m_register;
};

using GLShaderConstantPtr = std::shared_ptr<GLShaderConstant>;
using GLShaderSamplerPtr = std::shared_ptr<GLShaderSampler>;


class GLShader : public Shader
{
public:
	GLShader(const char *name)
    :_name(name)
	{
        m_verbose = false;
        m_vertexShader = 0;
        m_fragmentShader  = 0;
        m_program = 0;
	}

	virtual ~GLShader()
	{
        glDeleteShader(m_vertexShader);
        glDeleteShader(m_fragmentShader);
        glDeleteProgram(m_program);
	}

	virtual int			GetSamplerCount()
	{
		return (int)m_samplers.size();
	}

	virtual ShaderSamplerPtr   GetSampler(int index)
	{
        if ((size_t)index >= m_samplers.size()) return nullptr;
		return m_samplers[index];
	}

	virtual int			GetConstantCount()
	{
		return (int)m_constants.size();
	}

	virtual ShaderConstantPtr	GetConstant(int index)
	{
        if ((size_t)index >= m_constants.size()) return nullptr;
		return m_constants[index];
	}

    
    virtual bool Flush(GLContext *context)
    {
        if (!m_program ) {
            /// shader is invalid
            return false;
        }

        glUseProgram(m_program);

        if (m_constant_global_yscale)
        {
           float yscale = 1.0f;
           if (context->HasTextureRenderTarget())
           {
               yscale = -1.0f;
           }
           m_constant_global_yscale->Set(yscale);
        }

        if (m_constant_global_pointsize)
        {
            m_constant_global_pointsize->Set(context->GetPointSize());
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
        
        
        // TODO:

        return true;
    }
    
    static std::string GetShaderLog(GLuint shader)
    {
        std::string result;
        GLint logLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetShaderInfoLog(shader, logLength, &logLength, log);
            result = log;
            free(log);
        }
        return result;
    }
    
    void AddError(std::string error)
    {
        m_errors += error;
        m_errors += '\n';
    }

	virtual bool Compile(const ShaderSource &source)
	{
        std::string profileStr = source.profile;
        
//        m_verbose= true;
        
        if (m_verbose)
            Log::Printf("ConvertHLSLToGLSL(%s, %s):\n%s\n", source.profile.c_str(),
                   source.functionName.c_str(), source.code.c_str()
                   );
        
        ShaderSource glsl_source;
        if (!ConvertHLSLToGLSL(source, glsl_source)) {
            return false;
        }
        

        GLint type = source.IsVertex() ? GL_VERTEX_SHADER : GL_FRAGMENT_SHADER;

  
        GLuint shader = glCreateShader(type);
        assert(shader != 0);
        
        const GLchar *ptr = (GLchar *)glsl_source.code.c_str();
        if (m_verbose)
            printf("CompileGLSL:\n%s\n", ptr);
        glShaderSource(shader, 1, &ptr, NULL);
        glCompileShader(shader);
        
        GLint status;
        glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
        if (status == 0)
        {
            std::string error = GetShaderLog(shader);
            Log::Error("ERROR: %s\n", error.c_str());
            Log::Error("GLSL:\n%s", glsl_source.code.c_str());
            AddError(error);
            return false;
        }
        
        m_attribs[VertexAttribPosition]  = "xlat_attrib_POSITION";
        m_attribs[VertexAttribColor]     = "xlat_attrib_COLOR";
        m_attribs[VertexAttribTexCoord0] = "xlat_attrib_TEXCOORD0";
        m_attribs[VertexAttribTexCoord1] = "xlat_attrib_TEXCOORD1";

        if (type == GL_VERTEX_SHADER)
            m_vertexShader = shader;
        if (type == GL_FRAGMENT_SHADER)
            m_fragmentShader = shader;
		return true;
	}
    
    static std::string GetProgramLog(GLuint program)
    {
        std::string result;
        int logLength = 0;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetProgramInfoLog(program, logLength, &logLength, log);
            result = log;
            free(log);
        }
        return result;
    }



	virtual bool Link()
	{
        if (!m_vertexShader || !m_fragmentShader)
        {
            AddError("Invalid vertex or fragment shader");
            return false;
        }
        
        GLuint program = glCreateProgram();
        glAttachShader(program, m_vertexShader);
        glAttachShader(program, m_fragmentShader);
        
        glBindAttribLocation(program, VertexAttribPosition,  "xlat_attrib_POSITION" );
        glBindAttribLocation(program, VertexAttribColor,     "xlat_attrib_COLOR");
        glBindAttribLocation(program, VertexAttribTexCoord0, "xlat_attrib_TEXCOORD0");
        glBindAttribLocation(program, VertexAttribTexCoord1, "xlat_attrib_TEXCOORD1");

        glLinkProgram(program);
        
        GLint status = 0;
        glGetProgramiv(program, GL_LINK_STATUS, &status);
        if (status == 0)
        {
            std::string error = GetProgramLog(program);
            AddError(error);
            Log::Error("ERROR: %s\n", error.c_str());

            glDeleteProgram(program);
            return false;
        }
        
        m_program = program;
        
//        extern void glGetActiveAttrib (GLuint program, GLuint index, GLsizei bufSize, GLsizei *length, GLint *size, GLenum *type, GLchar *name);
//        GLAPI void APIENTRY glGetActiveUniform (GLuint program, GLuint index, GLsizei bufSize, GLsizei *length, GLint *size, GLenum *type, GLchar *name);

        GLint count;
        glGetProgramiv(program, GL_ACTIVE_UNIFORMS, &count);
        for (int i=0; i < count; i++)
        {
            GLsizei length = -1;
            GLint size = -1;
            GLenum type = 0;
            char name[256];
            
            glGetActiveUniform(program, i, sizeof(name), &length, &size, &type, name);
            assert(!(type == 0 || size < 0 || length < 0));
            
            GLint location = i;
            
            // for emscripten specifically the uniform location is not sequential and must be looked up by name
            location = glGetUniformLocation(program, name);
            
            if (m_verbose)
                printf("uniform[%d] type:%d size:%d '%s' location:%d\n", i, type, size, name, location);
            if (type == GL_SAMPLER_2D)
            {
                int reg = (int)m_samplers.size();
                m_samplers.push_back(std::make_shared<GLShaderSampler>(name, location, reg));
            }
            else // if (type == 35666)
            {
                m_constants.push_back(std::make_shared<GLShaderConstant>(name, location, type));
            }
            
        }
        
        // find positional transform
        m_constant_xform_position = Shader::GetConstant("xform_position");
        m_constant_global_yscale = Shader::GetConstant("xlu_yscale");        
        m_constant_global_pointsize = Shader::GetConstant("xlu_pointsize");
        CheckGLError();
		return true;
	}
    
    virtual std::string GetErrors()
    {
        return m_errors;
    }

protected:
    ShaderConstantPtr m_constant_xform_position;
    ShaderConstantPtr m_constant_global_yscale;
    ShaderConstantPtr m_constant_global_pointsize;

    friend class GLContext;
    std::string _name;
    

    bool m_verbose;
    std::string m_errors;
    
    

    
    GLuint m_vertexShader = 0;
    GLuint m_fragmentShader = 0;
    GLuint m_program = 0;
    
    std::vector< GLShaderSamplerPtr > m_samplers;
	std::vector< GLShaderConstantPtr > m_constants;
    
    std::map< VertexAttrib, std::string > m_attribs;
};


//
//
//


GLContext::GLContext(GLTextureLoadFunc textureLoadFunc)
    :m_textureLoadFunc(textureLoadFunc)
{
    Log::Printf("GL_VERSION:  %s\n", glGetString(GL_VERSION));
    Log::Printf("GL_VENDOR:   %s\n", glGetString(GL_VENDOR));
    Log::Printf("GL_RENDERER: %s\n", glGetString(GL_RENDERER));
    Log::Printf("GL_SHADING_LANGUAGE_VERSION: %s\n", glGetString(GL_SHADING_LANGUAGE_VERSION));

    // get framebuffer
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &m_fbo);

    // get width and height of viewport
//    int vpt[4];
//    glGetIntegerv( GL_VIEWPORT, vpt );
    m_displayInfo.size = Size2D(0, 0);
    
    // ensure we have a valid width/height or init will fail
//    assert(m_displaySize.width > 0 && m_displaySize.height > 0);
	
	glGenBuffers(1, &m_vb);
    glGenBuffers(1, &m_ib);

    glGenVertexArrays(1, &m_vao);

    // create main VAO
    glBindVertexArray(m_vao);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_ib);
    glBindBuffer(GL_ARRAY_BUFFER, m_vb);
    glEnableVertexAttribArray(VertexAttribPosition);
    glVertexAttribPointer(VertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, position.x));
    glEnableVertexAttribArray(VertexAttribColor);
//    glVertexAttribPointer(VertexAttribColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(Vertex), (void *)offsetof(Vertex, Diffuse));
    glVertexAttribPointer(VertexAttribTexCoord0, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, color.x ));
    glEnableVertexAttribArray(VertexAttribTexCoord0);
    glVertexAttribPointer(VertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, texcoord0.x ));
    glEnableVertexAttribArray(VertexAttribTexCoord1);
    glVertexAttribPointer(VertexAttribTexCoord1, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, texcoord1.x ));
    glBindVertexArray(0);


    int size = 64;
    uint32_t *data = new uint32_t[size * size];
    for (int i=0; i < size * size; i++)
        data[i] = 0xFFFFFFFF;
    m_whiteTexture = CreateTexture("white", size, size, PixelFormat::RGBA8Unorm,  data);
    delete[] data;
    
    Hlsl2Glsl_Initialize();
}


GLContext::~GLContext()
{
	glDeleteBuffers(1, &m_vb);
    glDeleteBuffers(1, &m_ib);
    glDeleteVertexArrays(1, &m_vao);


    Hlsl2Glsl_Shutdown();
}


void GLContext:: Present()
{
	
}

/*
void GLContext::SetDisplaySize(int w, int h, float rate, float scale)
{
#if !EMSCRIPTEN
    // get framebuffer
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &m_fbo);
#endif  

    m_displaySize = Size2D(w, h);
    m_displayRate = rate;
    m_displayScale = scale;
    m_displayRate = rate;
}
*/

void GLContext::ResetState()
{
    glBindVertexArray(0);
    SetRenderTarget(nullptr);
    glUseProgram(0);
    glDisable(GL_CULL_FACE);
    SetBlendDisable();
    SetScissorDisable();
    SetPointSize(1.0f);
    #ifdef GL_VERTEX_PROGRAM_POINT_SIZE_ARB
        glEnable(GL_VERTEX_PROGRAM_POINT_SIZE_ARB);
    #endif

#ifdef GL_PROGRAM_POINT_SIZE
    glEnable(GL_PROGRAM_POINT_SIZE);
#endif
    CheckGLError();
}

void GLContext::NextFrame()
{
    ResetState();
}


void GLContext::Flush()
{
    glFlush();
}

bool GLContext::IsSupported(PixelFormat format)
{
    switch (format)
    {
        case PixelFormat::Invalid:
            return false;
        case PixelFormat::A8Unorm:
            return true;
            
        case PixelFormat::RGBA8Unorm:
        case PixelFormat::RGBA8Unorm_sRGB:
            return true;
            
        case PixelFormat::BGRA8Unorm:
        case PixelFormat::BGRA8Unorm_sRGB:
#if EMSCRIPTEN || defined(__ANDROID__)
            return false;
#else
            return true;
#endif
            
        case PixelFormat::RGBA16Unorm:
        case PixelFormat::RGBA16Snorm:
        case PixelFormat::RGBA16Float:
        case PixelFormat::RGBA32Float:
            return true;
            
        case PixelFormat::BGR10A2Unorm:
            return true;

#if TARGET_OS_IPHONE
        case PixelFormat::BGR10_XR:           // ios only
        case PixelFormat::BGR10_XR_sRGB:           // ios only
            return true;
#endif
            
        default:
            return false;
    }

}



TexturePtr GLContext::CreateTextureFromFile(const char *name, const char *path)
{
    GLTextureInfo ti;
    if (!m_textureLoadFunc(path, ti))
    {
        Log::Printf("ERROR: Could not load texture %s\n", path);
        return nullptr;
    }
    
    Log::Printf("Load texture %s (%dx%d)\n", path, ti.width, ti.height);
    auto texture = std::make_shared<GLTexture>(name, ti.name, ti.width, ti.height, PixelFormat::RGBA8Unorm );
    return texture;
	
}



TexturePtr GLContext::CreateRenderTarget(const char *name, int width, int height, PixelFormat format)
{
    auto info = ConvertFormat(format);
    
    glGetError();
    
	GLuint id;
	glGenTextures(1, &id);
	glBindTexture(GL_TEXTURE_2D, id);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, info.internalFormat, width, height, 0, info.format, info.type, 0);
    
    int error = glGetError();
    if (error)
    {
        Log::Error("Could not create texture with format: %s\n", PixelFormatToString(format));
        glDeleteTextures(1, &id);
        return nullptr;
    }
	auto texture = std::make_shared<GLTexture>(name, id, width, height, format);
    return texture;
}


TexturePtr GLContext::CreateTexture(const char *name, int width, int height, PixelFormat format, const void *data)
{
    auto info = ConvertFormat(format);

    glGetError();

    GLuint id;
    glGenTextures(1, &id);
	glBindTexture(GL_TEXTURE_2D, id);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, info.internalFormat, width, height, 0, info.format, info.type, data);
    
    int error = glGetError();
    if (error)
    {
        Log::Error("Could not create texture with format: %s\n", PixelFormatToString(format));
        glDeleteTextures(1, &id);
        return nullptr;
    }

    auto texture = std::make_shared<GLTexture>(name, id, width, height, format);
    return texture;

}

ShaderPtr GLContext::CreateShader(const char *name)
{
	return std::make_shared<GLShader>(name);
}



void GLContext::InternalSetTexture(int index, TexturePtr texture, SamplerAddress address, SamplerFilter filter)
{
    if (!texture)
    {
        // use white texture....
        texture = m_whiteTexture;
    }
    
    GLTexturePtr gl_texture = std::static_pointer_cast<GLTexture>(texture);
    assert(gl_texture);

    glActiveTexture(GL_TEXTURE0 + index);
    glBindTexture(GL_TEXTURE_2D, gl_texture->m_id);

	switch (address)
	{
		case SAMPLER_WRAP:
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
			break;
		case SAMPLER_CLAMP:
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
			break;
		default:
			assert(0);
			break;
	}

    
	switch (filter)
	{
		case SAMPLER_POINT:
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
			break;
		case SAMPLER_LINEAR:
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			break;
		case SAMPLER_ANISOTROPIC:
			// TODO
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			break;
		default:
			assert(0);
			break;
	}
     
    CheckGLError();
 
}

void GLContext::SetPointSize(float size)
{
    m_pointsize = size;
#if !defined(GL_PROGRAM_POINT_SIZE) && defined(glPointSize)
    glPointSize(size);
#endif
}




void GLContext::SetDepthEnable(bool enable)
{
	if (enable)
	{
		glEnable(GL_DEPTH_TEST);
		//glEnable(GL_DEPTH_WRITEMASK);
	}
	else
	{
		glDisable(GL_DEPTH_TEST);
//		glDisable(GL_DEPTH_WRITEMASK);
	}
    
    CheckGLError();

}


static int ConvertBlendFactor(BlendFactor factor)
{
	switch (factor)
	{
	case 	BLEND_ZERO:
		return GL_ZERO;
	case 	BLEND_ONE:
		return GL_ONE;
	case 	BLEND_SRCCOLOR:
		return GL_SRC_COLOR;
	case 	BLEND_INVSRCCOLOR:
		return GL_ONE_MINUS_SRC_COLOR;
	case 	BLEND_SRCALPHA:
		return GL_SRC_ALPHA;
	case 	BLEND_INVSRCALPHA:
		return GL_ONE_MINUS_SRC_ALPHA;
	case 	BLEND_DESTALPHA:
		return GL_DST_ALPHA;
	case 	BLEND_INVDESTALPHA:
		return GL_ONE_MINUS_DST_ALPHA;
	case 	BLEND_DESTCOLOR:
		return GL_DST_COLOR;
	case 	BLEND_INVDESTCOLOR:
		return GL_ONE_MINUS_DST_COLOR;
	default:
		assert(0);
		return 0;
	}
}

void GLContext::SetBlend(BlendFactor sourceFactor, BlendFactor destFactor)
{
    glBlendEquation(GL_FUNC_ADD);
    glBlendFunc(ConvertBlendFactor(sourceFactor), ConvertBlendFactor(destFactor));
    glEnable(GL_BLEND);
}
void GLContext::SetBlendDisable()
{
    glDisable(GL_BLEND);

}


void GLContext::SetShader(ShaderPtr shader)
{
    GLShaderPtr glshader = std::static_pointer_cast<GLShader>(shader);
    m_shader = glshader;
    
}

void GLContext::SetRenderTarget(TexturePtr texture, const char *passName, LoadAction action, Color4F clearColor)
{
    m_renderTarget = std::static_pointer_cast<GLTexture>(texture);
    
    if (!m_renderTarget)
    {
        m_renderTargetSize  = m_displayInfo.size;
        
        // bind default framebuffer
        glBindFramebuffer(GL_FRAMEBUFFER, m_fbo);
        glViewport(0, 0, m_renderTargetSize.width, m_renderTargetSize.height);
        
        if (action != LoadAction::Load) {
            Clear(clearColor);
        }
        return;
    }
	
	if (m_renderTarget->m_fbo == 0)
	{
        glGenFramebuffers(1, &m_renderTarget->m_fbo);
        glBindFramebuffer(GL_FRAMEBUFFER, m_renderTarget->m_fbo);

#if GL_ES_VERSION_2_0
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, m_renderTarget->m_id, 0);
#else
		glFramebufferTextureEXT(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, m_renderTarget->m_id, 0);
#endif
        CheckGLError();

	}
	else
	{
		glBindFramebuffer(GL_FRAMEBUFFER, m_renderTarget->m_fbo);
	}

    
#if GL_ERROR_CHECK
    int status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE)
    {
        assert(0);
    }
#endif
	
    m_renderTargetSize  = m_renderTarget->GetSize();

    
	glViewport(0, 0, m_renderTargetSize.width, m_renderTargetSize.height);
    
    if (action != LoadAction::Load) {
        Clear(clearColor);
    }

}


void GLContext::UploadIndexData(size_t count, size_t stride, const IndexType *indexData)
{
    // upload index data
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_ib);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, count * stride, indexData, GL_DYNAMIC_DRAW);
    
}

void GLContext::UploadVertexData(size_t count, size_t stride, const void *data, int vertexTypeId)
{
    glBindBuffer(GL_ARRAY_BUFFER, m_vb);
    glBufferData(GL_ARRAY_BUFFER, count * stride, data, GL_DYNAMIC_DRAW);

}

static GLenum ConvertPrimType(PrimitiveType primType)
{
    switch (primType)
    {
        case PRIMTYPE_POINTLIST:
            return GL_POINTS;
        case PRIMTYPE_LINELIST:
            return GL_LINES;
        case PRIMTYPE_LINESTRIP:
            return GL_LINE_STRIP;
        case PRIMTYPE_TRIANGLELIST:
            return GL_TRIANGLES;
        case PRIMTYPE_TRIANGLESTRIP:
            return GL_TRIANGLE_STRIP;
        case PRIMTYPE_TRIANGLEFAN:
            return GL_TRIANGLE_FAN;
        default:
            assert(0);
            return 0;
    };
}

void GLContext::DrawIndexed(PrimitiveType primType, int indexOffset, int indexCount)
{
    // flush shader before drawing
    if (!m_shader->Flush(this)) {
        // shader is invalid...skip draw
        return;
    }
    
    glBindVertexArray(m_vao);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_ib);
    glDrawElements(ConvertPrimType(primType), indexCount,
                   sizeof(IndexType) == 2 ? GL_UNSIGNED_SHORT : GL_UNSIGNED_INT, (void *)(indexOffset * sizeof(IndexType))  );
    CheckGLError();
    glBindVertexArray(0);
}


void GLContext::DrawArrays(PrimitiveType primType, int start, int count)
{
    // flush shader before drawing
    if (!m_shader->Flush(this)) {
        // shader is invalid...skip draw
        return;
    }
    
    glBindVertexArray(m_vao);
    glDrawArrays(ConvertPrimType(primType), start, count);
    CheckGLError();
    glBindVertexArray(0);
}


void GLContext::Clear(Color4F color)
{
    float depth = 1.0;
    glClearColor(color.r, color.g, color.b, color.a);
#if GL_ES_VERSION_2_0
    glClearDepthf(depth);
#else
    glClearDepth(depth);
#endif
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

}

ContextPtr GLCreateContext(GLTextureLoadFunc textureLoadFunc)
{
    auto ptr = new GLContext(textureLoadFunc);
    return ContextPtr(ptr);
}

}} // namespace render::gles


#endif // !defined(WIN32)





