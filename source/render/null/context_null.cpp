
#include "context.h"

namespace render {

class NullShader;
using NullShaderPtr = std::shared_ptr<NullShader>;

class NullTexture : public Texture, public std::enable_shared_from_this<Texture>
{
public:
    inline NullTexture(std::string name)
	: m_name(name)
	{
	}
	
	virtual ~NullTexture()
	{
	}
    
    virtual TexturePtr GetSharedPtr() override
    {
        return shared_from_this();
    }

    
	virtual Size2D GetSize() override
	{
        return Size2D(1,1);
	}
    
    virtual PixelFormat GetFormat() override
    {
        return PixelFormat::RGBA8Unorm;
    }


	
    
    virtual const std::string &GetName() override { return m_name; }

	
    std::string m_name;
	

};



class NullShader : public Shader
{
	
	class NullShaderConstant : public ShaderConstant
	{
	public:
		inline NullShaderConstant(NullShaderPtr shader)
		{
			m_shader = shader;
		}
		
		virtual ~NullShaderConstant() {}
		
        virtual const std::string &GetName() override { return m_name; }
        
        
        std::string m_name;
        

/*
		int GetRegister() override
		{
			return -1; // m_desc.RegisterIndex;
		}
	*/
        
        virtual void Set(float f) override {}
        virtual void Set(const Vector2 &v) override {}
        virtual void Set(const Vector3 &v) override {}
        virtual void Set(const Vector4 &v) override {}
        virtual void Set(const Matrix44 &m) override {}

		
		ShaderPtr GetShader()
		{
			return ShaderPtr(m_shader);
		}
		
		NullShaderPtr m_shader;
	};
	
	class NullSampler: public ShaderSampler
	{
	public:
		inline NullSampler(NullShaderPtr shader)
		{
			m_shader = shader;
		}
		
		virtual ~NullSampler() {}
		
        virtual const std::string &GetName() override { return m_name; }
        
        
        std::string m_name;
        

		/*
		virtual int GetRegister() override
		{
			return -1;
		}*/
		
		ShaderPtr GetShader()
		{
			return ShaderPtr(m_shader);
		}
		
		NullShaderPtr m_shader;
	};
	
	
public:
	NullShader(ContextPtr context)
	:m_context(context)
	{
	}
	
	virtual ~NullShader()
	{
	}
	
	virtual ContextPtr GetContext() { return m_context; }
	
	virtual int			GetSamplerCount()
	{
		return (int)m_samplers.size();
	}
	
	virtual ShaderSamplerPtr   GetSampler(int index)
	{
		return m_samplers[index];
	}
	
	virtual int			GetConstantCount()
	{
		return (int)m_constants.size();
	}
	
	virtual ShaderConstantPtr	GetConstant(int index)
	{
		return ShaderConstantPtr(m_constants[index]);
	}

    virtual bool Compile(const ShaderSource &source)
	{
		return true;
	}

	virtual bool Link()
	{
		return true;
	}
	
    virtual std::string GetErrors() {
        return "";
    }
protected:
	ContextPtr m_context;
	
    std::vector< std::shared_ptr<NullSampler> > m_samplers;
	std::vector< std::shared_ptr<NullShaderConstant> > m_constants;
};

//
// dx rendering context
//
class NullContext : public Context, public std::enable_shared_from_this<NullContext>
{
public:
	NullContext();
	virtual ~NullContext();
	
    virtual void SetShader(ShaderPtr shader)  override
	{
	}
    
    virtual void ResetState() 
    {
        
    }

	
	virtual void SetFixedPixelShader(bool alpha) 
	{
//		if (!alpha)
//		{
//			// reset these to the standard safe mode:
//			m_device->SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE);
//			m_device->SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_DIFFUSE);
//			m_device->SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_TEXTURE);
//			m_device->SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);
//			m_device->SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);
//			m_device->SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_DIFFUSE);
//			m_device->SetTextureStageState(1, D3DTSS_ALPHAOP, D3DTOP_DISABLE);
//		}
//		else
//		{
//			m_device->SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE);
//			m_device->SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_DIFFUSE);
//			m_device->SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_TEXTURE);
//			m_device->SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);
//			m_device->SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);
//			m_device->SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_DIFFUSE);
//			m_device->SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_TEXTURE);
//			m_device->SetTextureStageState(1, D3DTSS_ALPHAOP, D3DTOP_DISABLE);
//		}
	}
	
	
	
	virtual TexturePtr CreateTextureFromFile(const char *name, const char *path) override;
	virtual TexturePtr CreateRenderTarget(const char *name, int width, int height, PixelFormat format)  override;
	virtual TexturePtr CreateTexture(const char *name, int width, int height, PixelFormat format, const void *data) override;

	
    virtual void SetRenderTarget(TexturePtr texture, const char *passName = nullptr, LoadAction action = LoadAction::Load, Color4F clearColor = Color4F(0,0,0,0) ) override
	{
//		assert(texture);
//		
//		IDirect3DSurface9* pTarget = NULL;
//		LPDIRECT3DTEXTURE9 d3dtex = (LPDIRECT3DTEXTURE9)texture->GetD3DTexture();
//		d3dtex->GetSurfaceLevel(0, &pTarget);
//		m_device->SetRenderTarget(0, pTarget);
//		pTarget->Release();
	}
	
    virtual float GetTexelOffset() override {return 0.5f;}

    virtual const std::string &GetDriver()  override { return m_driver; };
    virtual const std::string &GetDesc() override  { return m_description; };
    
    std::string m_driver = "Null";
    std::string m_description =  "Null";

	virtual void Present() override;
	virtual void NextFrame() override;
    
    virtual Size2D GetRenderTargetSize() override {
        return Size2D(640, 480);
    }

    
	
	virtual ShaderPtr CreateShader(const char *name) override;

	
	void SetViewport();
	
	virtual void InternalSetTexture(int index, TexturePtr texture)
	{
//		m_device->SetTexture(index, texture ? texture->GetD3DTexture() : NULL );
	}
	
	virtual void InternalSetSamplerState(int i, SamplerAddress address, SamplerFilter filter) 
	{
//		switch (address)
//		{
//			case SAMPLER_WRAP:
//				m_device->SetSamplerState(i, D3DSAMP_ADDRESSU, D3DTADDRESS_WRAP);
//				m_device->SetSamplerState(i, D3DSAMP_ADDRESSV, D3DTADDRESS_WRAP);
//				m_device->SetSamplerState(i, D3DSAMP_ADDRESSW, D3DTADDRESS_WRAP);
//				break;
//			case SAMPLER_CLAMP:
//				m_device->SetSamplerState(i, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
//				m_device->SetSamplerState(i, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);
//				m_device->SetSamplerState(i, D3DSAMP_ADDRESSW, D3DTADDRESS_CLAMP);
//				break;
//			default:
//				assert(0);
//				break;
//		}
//		
//		switch (filter)
//		{
//			case SAMPLER_POINT:
//				m_device->SetSamplerState(i, D3DSAMP_MAGFILTER, D3DTEXF_POINT);
//				m_device->SetSamplerState(i, D3DSAMP_MINFILTER, D3DTEXF_POINT);
//				m_device->SetSamplerState(i, D3DSAMP_MIPFILTER, D3DTEXF_POINT);
//				break;
//			case SAMPLER_LINEAR:
//				m_device->SetSamplerState(i, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
//				m_device->SetSamplerState(i, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
//				m_device->SetSamplerState(i, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);
//				break;
//			case SAMPLER_ANISOTROPIC:
//				m_device->SetSamplerState(i, D3DSAMP_MAGFILTER, D3DTEXF_ANISOTROPIC);
//				m_device->SetSamplerState(i, D3DSAMP_MINFILTER, D3DTEXF_ANISOTROPIC);
//				m_device->SetSamplerState(i, D3DSAMP_MIPFILTER, D3DTEXF_ANISOTROPIC);
//				m_device->SetSamplerState(i, D3DSAMP_MAXANISOTROPY, 1);
//				break;
//			default:
//				assert(0);
//				break;
//		}
	}
	
	virtual void SetPointSize(float size) override
	{
//		m_device->SetRenderState(D3DRS_POINTSIZE, *((DWORD*)&size));
	}
	
//	virtual void SetRenderState(D3DRENDERSTATETYPE rs, DWORD value)
//	{
////		m_device->SetRenderState(rs, value);
//	}
//	

	virtual void SetDepthEnable(bool enable) override
	{
		//		m_device->SetRenderState(D3DRS_ALPHABLENDENABLE, enable ? TRUE : FALSE);
	}

//	virtual void SetBlendEnable(bool enable) override
//	{
////		m_device->SetRenderState(D3DRS_ALPHABLENDENABLE, enable ? TRUE : FALSE);
//	}
//
//	virtual void SetBlendFactor(BlendFactor sourceFactor, BlendFactor destFactor) override
//	{
////		m_device->SetRenderState(D3DRS_SRCBLEND, (D3DBLEND)(sourceFactor));
////		m_device->SetRenderState(D3DRS_DESTBLEND, (D3DBLEND)(destFactor));
//	}
    

    virtual void SetBlend(BlendFactor sourceFactor, BlendFactor destFactor) override
    {
    }


    virtual void SetBlendDisable() override
    {
    }
	
	
	
//	virtual void Draw(PrimitiveType primType, int count, const Vertex *v) override
//	{
////		m_device->DrawPrimitiveUP((D3DPRIMITIVETYPE)primType, count, v, (UINT)vertexSize);
//	}
    
   
	
    
//    virtual void Clear(Color4F color)  override
//    {
////        float depth = 1.0;
////        glClearColor(color.r, color.g, color.b, color.a);
////#if GL_ES_VERSION_2_0
////        glClearDepthf(depth);
////#else
////        glClearDepth(depth);
////#endif
////        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
////
//    }
    
	
    virtual void SetTransform(const Matrix44 &m) override
    {
        m_xform = m;
    }
    
    virtual const Matrix44 &GetTransform() const override
    {
        return m_xform;
        
    }
    
    
    
    virtual void SetScissorDisable() override {}
    virtual void SetScissorRect(int x, int y, int w, int h) override {}
    virtual void SetViewport(int x, int y, int w, int h) override {}
    virtual void UploadIndexData(size_t count, size_t stride, const IndexType *indices) override {}
    virtual void UploadVertexData(size_t count, size_t stride,  const void *v, int vertexTypeID) override {}
    virtual void DrawArrays(PrimitiveType primType, int start, int count) override {}
    virtual void DrawIndexed(PrimitiveType primType, int indexOffset, int indexCount) override {}
	
protected:
    Matrix44 m_xform = Matrix44::Identity();
	
};

NullContext::NullContext()
{
	
}


NullContext::~NullContext()
{
	
}


void NullContext:: Present()
{
	
}

void NullContext:: NextFrame()
{
}

TexturePtr NullContext::CreateTextureFromFile(const char *name, const char *path)
{
    return std::make_shared<NullTexture>(name);
	
}

TexturePtr NullContext::CreateRenderTarget(const char *name, int width, int height, PixelFormat format)
{
	return std::make_shared<NullTexture>(name);
}


TexturePtr NullContext::CreateTexture(const char *name, int width, int height, PixelFormat format,  const void *data)
{
	return std::make_shared<NullTexture>(name);

}

ShaderPtr     NullContext::CreateShader(const char *name)

{
    return std::make_shared<NullShader>(shared_from_this());
}

}
