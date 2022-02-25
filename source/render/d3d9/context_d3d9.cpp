
#ifdef WIN32

#include <queue>
#include <stack>
#include <vector>
#include <string>
#include "context.h"
#include "platform.h"

#ifdef _DEBUG
#define D3D_DEBUG_INFO  // declare this before including d3d9.h
#endif

// This should be the only file including d3d directly
#include <d3d9.h>
#include "..\..\external\dxsdk\Include\d3dx9.h"


#pragma comment(lib,"d3d9.lib")
#pragma comment(lib,"d3dx9.lib")

namespace render {
	namespace d3d9 {

class DXTexture;
class DXShader;
using DXTexturePtr = std::shared_ptr<DXTexture>;
using DXShaderPtr = std::shared_ptr<DXShader>;



    //
    //
    //

    template <class T>
    class AutoRef
    {
    public:
        inline AutoRef()
            : mPtr(NULL)
        {
        }

        inline AutoRef(T *ptr)
            : mPtr(ptr)
        {
            if (mPtr != NULL)
                mPtr->AddRef();
        }

        // copy constructor
        inline     AutoRef(const AutoRef<T> &other)
            : mPtr(other.mPtr)
        {
            if (mPtr != NULL)
                mPtr->AddRef();
        }

        inline ~AutoRef()
        {
            Clear();
        }

        // assignment operator
        inline void operator= (T *ptr)
        {
            SetPtr(ptr);
        }

        // assignment operator
        inline void operator= (const AutoRef &other)
        {
            SetPtr(other.mPtr);
        }

        inline void Clear()
        {
            if (mPtr)
                mPtr->Release();
            mPtr = NULL;
        }

        void SetPtr(T *ptr)
        {
            if (mPtr != ptr)
            {
                if (mPtr != NULL)
                    mPtr->Release();
                mPtr = ptr;
                if (mPtr != NULL)
                    mPtr->AddRef();
            }
        }

        inline T* Get() const
        {
            return mPtr;
        }

        inline T** GetAddressOf()
        {
            Clear();
            return &mPtr;
        }

        // no auto decrement
        T * Detach()
        {
            T * ptr = mPtr;
            mPtr = NULL;
            return ptr;
        }

        inline operator T *() const
        {
            return mPtr;
        }

        inline T * operator ->()
        {
            return mPtr;
        }
        
        inline T & operator *()
        {
            return *mPtr;
        }

    private:
        T *            mPtr;
    };

    
// note: these must match layouts in support.h!!
D3DVERTEXELEMENT9 g_MyVertDecl[] =
{
	{ 0, offsetof(Vertex, x),  D3DDECLTYPE_FLOAT3,   D3DDECLMETHOD_DEFAULT, D3DDECLUSAGE_POSITION, 0 },
	{ 0, offsetof(Vertex, Diffuse), D3DDECLTYPE_UBYTE4, D3DDECLMETHOD_DEFAULT, D3DDECLUSAGE_COLOR,    0 },
	{ 0, offsetof(Vertex, tu), D3DDECLTYPE_FLOAT4,   D3DDECLMETHOD_DEFAULT, D3DDECLUSAGE_TEXCOORD, 0 },
	{ 0, offsetof(Vertex, rad), D3DDECLTYPE_FLOAT2,   D3DDECLMETHOD_DEFAULT, D3DDECLUSAGE_TEXCOORD, 1 },
	D3DDECL_END()
};


static D3DFORMAT ConvertFormat(PixelFormat format)
{
	switch (format)
	{
	case PixelFormat::Invalid:
		return D3DFMT_UNKNOWN;

	case PixelFormat::RGBA8Unorm:
	case PixelFormat::RGBA8Unorm_sRGB:
		return D3DFMT_A8B8G8R8; // not always supported on D3D9

	case PixelFormat::BGRA8Unorm:
	case PixelFormat::BGRA8Unorm_sRGB:
		return D3DFMT_A8R8G8B8; 

	case PixelFormat::A8Unorm:
		return D3DFMT_A8;

	case PixelFormat::RGBA16Unorm:
	case PixelFormat::RGBA16Snorm:
	case PixelFormat::RGBA16Float:
	case PixelFormat::RGBA32Float:
	case PixelFormat::BGR10A2Unorm:
	default:
		assert(0);
		return D3DFMT_UNKNOWN;
	}
}


static PixelFormat ConvertFormat(D3DFORMAT format)
{
	switch (format)
	{
	case D3DFMT_UNKNOWN:
		return PixelFormat::Invalid;
	case D3DFMT_A8R8G8B8:
		return PixelFormat::BGRA8Unorm;
	case D3DFMT_A8B8G8R8:
		return PixelFormat::RGBA8Unorm;
	case D3DFMT_A8:
		return PixelFormat::A8Unorm;
	default:
		assert(0);
		return PixelFormat::Invalid;
	}
}



class DXTexture : public Texture, public std::enable_shared_from_this<DXTexture>
{
public:
	inline DXTexture(std::string name, LPDIRECT3DTEXTURE9 texture)
		: m_name(name), m_texture(texture)
	{
		m_texture->GetLevelDesc(0, &m_desc);
	}

	virtual ~DXTexture()
	{
        m_texture->Release();
	}


    virtual TexturePtr GetSharedPtr() override
    {
        return shared_from_this();
    }

    virtual const std::string &GetName() override
    {
        return m_name;
    }

	virtual Size2D GetSize() override
	{
		return Size2D(m_desc.Width,  m_desc.Height);
	}
    
    virtual PixelFormat GetFormat() override
    {
        return ConvertFormat(m_desc.Format);
    }



	virtual LPDIRECT3DBASETEXTURE9 GetD3DTexture()
	{
		return m_texture;
	}

    std::string m_name;
	LPDIRECT3DTEXTURE9 m_texture;
	D3DSURFACE_DESC m_desc;
};


class DXShader;

//
// dx rendering context
//
class DXContext : public Context, public std::enable_shared_from_this<DXContext>
{
public:
	DXContext(HWND hWnd);
	bool InitD3D();
	virtual ~DXContext();
    
    virtual bool IsSupported(PixelFormat format) override
    {
		switch (format)
		{
		case PixelFormat::BGRA8Unorm:
			return true;

		case PixelFormat::BGRA8Unorm_sRGB:
		case PixelFormat::Invalid:
		case PixelFormat::RGBA8Unorm:
		case PixelFormat::RGBA8Unorm_sRGB:
		case PixelFormat::RGBA16Unorm:
		case PixelFormat::RGBA16Snorm:
		case PixelFormat::RGBA16Float:
		case PixelFormat::RGBA32Float:
		case PixelFormat::BGR10A2Unorm:
		default:
			return false;
		}
    }



	virtual TexturePtr CreateTextureFromFile(const char *name, const char *path)  override;
	virtual TexturePtr CreateRenderTarget(const char *name, int width, int height, PixelFormat format)  override;


	virtual TexturePtr CreateTexture(const char *name, int width, int height, PixelFormat format, const uint32_t *data)  override;

	virtual ShaderPtr CreateShader(const char *name)  override;
	virtual void SetShader(ShaderPtr shader) override;

    virtual void SetTransform(const Matrix44 &m) override
    {
        m_xform = m;
    }
    
    virtual const Matrix44 &GetTransform() const override
    {
        return m_xform;
    }

	virtual void SetRenderTarget(TexturePtr texture, const char* passName = nullptr, LoadAction action = LoadAction::Load, Color4F clearColor = Color4F(0, 0, 0, 0)) override
	//void SetRenderTarget(TexturePtr texture, const char* passName, LoadAction action, Color4F clearColor)  override
	{
		if (!texture)
		{
            m_renderTarget = nullptr;
			m_device->SetRenderTarget(0, m_frameBuffer);
            m_renderTargetSize = m_displayInfo.size;
		}
        else
        {

            assert(texture);

            DXTexturePtr t = std::static_pointer_cast<DXTexture>(texture);

            m_renderTarget = t;
            m_renderTargetSize = t->GetSize();

            IDirect3DSurface9* pTarget = NULL;
            LPDIRECT3DTEXTURE9 d3dtex = (LPDIRECT3DTEXTURE9)t->GetD3DTexture();
            d3dtex->GetSurfaceLevel(0, &pTarget);
            m_device->SetRenderTarget(0, pTarget);
            pTarget->Release();
        }

        SetViewport(0, 0, m_renderTargetSize.width, m_renderTargetSize.height);
        SetScissorDisable();


		if (action != LoadAction::Load) {
			Clear(clearColor);
		}


        
	}


    virtual Size2D GetRenderTargetSize()  override { return m_renderTargetSize; }
	
    virtual float GetTexelOffset() override {return 0.5f;}
	virtual const std::string &GetDriver()  override { return m_driver; };
	virtual const std::string &GetDesc() override  { return m_description; };

    std::string m_driver = "D3D9";
    std::string m_description = "D3D9";

	virtual void Present()  override;
	virtual void BeginScene()  override;
	virtual void EndScene()  override;

    virtual void ResetState();
	bool UpdateDevice();

	inline LPDIRECT3DDEVICE9  GetDevice() { return m_device; }

	

	virtual void SetScissorRect(int x, int y, int w, int h) override;


    virtual void SetViewport(int x, int y, int w, int h) override;

    virtual void InternalSetTexture(int index, TexturePtr texture)
	{
        DXTexturePtr t = std::static_pointer_cast<DXTexture>(texture);

		if (!t)
		{
			// default to white if no texture is bound
            t = std::static_pointer_cast<DXTexture>(m_whiteTexture);
		}

		m_device->SetTexture(index, t->GetD3DTexture());
	}

	virtual void InternalSetSamplerState(int i, SamplerAddress address, SamplerFilter filter)
	{
		switch (address)
		{
		case SAMPLER_WRAP:
			m_device->SetSamplerState(i, D3DSAMP_ADDRESSU, D3DTADDRESS_WRAP);
			m_device->SetSamplerState(i, D3DSAMP_ADDRESSV, D3DTADDRESS_WRAP);
			m_device->SetSamplerState(i, D3DSAMP_ADDRESSW, D3DTADDRESS_WRAP);
			break;
		case SAMPLER_CLAMP:
			m_device->SetSamplerState(i, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
			m_device->SetSamplerState(i, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);
			m_device->SetSamplerState(i, D3DSAMP_ADDRESSW, D3DTADDRESS_CLAMP);
			break;
		default:
			assert(0);
			break;
		}

		switch (filter)
		{
		case SAMPLER_POINT:
			m_device->SetSamplerState(i, D3DSAMP_MAGFILTER, D3DTEXF_POINT);
			m_device->SetSamplerState(i, D3DSAMP_MINFILTER, D3DTEXF_POINT);
			m_device->SetSamplerState(i, D3DSAMP_MIPFILTER, D3DTEXF_POINT);
			break;
		case SAMPLER_LINEAR:
			m_device->SetSamplerState(i, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
			m_device->SetSamplerState(i, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
			m_device->SetSamplerState(i, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);
			break;
		case SAMPLER_ANISOTROPIC:
			m_device->SetSamplerState(i, D3DSAMP_MAGFILTER, D3DTEXF_ANISOTROPIC);
			m_device->SetSamplerState(i, D3DSAMP_MINFILTER, D3DTEXF_ANISOTROPIC);
			m_device->SetSamplerState(i, D3DSAMP_MIPFILTER, D3DTEXF_ANISOTROPIC);
			m_device->SetSamplerState(i, D3DSAMP_MAXANISOTROPY, 1);
			break;
		default:
			assert(0);
			break;
		}
	}

	virtual void SetPointSize(float size) override
	{
		//m_device->SetRenderState(D3DRS_POINTSIZE, *((DWORD*)&size));
	}

	virtual void SetRenderState(D3DRENDERSTATETYPE rs, DWORD value) 
	{
		m_device->SetRenderState(rs, value);
	}

	virtual void SetBlendDisable()  override
	{
        m_device->SetRenderState(D3DRS_ALPHABLENDENABLE, FALSE);
		//m_device->SetRenderState(D3DRS_ALPHABLENDENABLE, enable ? TRUE : FALSE);
	}

	virtual void SetDepthEnable(bool enable)  override
	{
		if (enable) {
			m_device->SetRenderState(D3DRS_ZENABLE, TRUE);
			m_device->SetRenderState(D3DRS_ZWRITEENABLE, TRUE);
		}
		else {
			m_device->SetRenderState(D3DRS_ZENABLE, FALSE);
			m_device->SetRenderState(D3DRS_ZWRITEENABLE, FALSE);
		}
	}

	virtual void SetBlend(BlendFactor sourceFactor, BlendFactor destFactor)  override
	{
		m_device->SetRenderState(D3DRS_SRCBLEND, (D3DBLEND)(sourceFactor));
		m_device->SetRenderState(D3DRS_DESTBLEND, (D3DBLEND)(destFactor));
        m_device->SetRenderState(D3DRS_ALPHABLENDENABLE, TRUE);
	}

    
    virtual void SetScissorDisable() override
    {
        m_device->SetRenderState(D3DRS_SCISSORTESTENABLE, FALSE);
    }



  
    virtual void UploadIndexData(int indexCount, const IndexType* indices) override
    {
        DWORD dwLockFlags = D3DLOCK_NOOVERWRITE;

        if (m_ib_pos + indexCount > m_ib_capacity)
        {
            dwLockFlags = D3DLOCK_DISCARD;
            m_ib_pos = 0;
        }

        size_t size = indexCount * sizeof(IndexType);

        void* pBytes = NULL;
        m_ib->Lock((UINT)(m_ib_pos * sizeof(IndexType)), (UINT)size, &pBytes, dwLockFlags);


        IndexType* dest = (IndexType*)pBytes;
        for (int i = 0; i < indexCount; i++)
        {
            dest[i] = indices[i];
        }
        m_ib->Unlock();

        m_ib_drawbase = m_ib_pos;
        m_ib_pos += indexCount;


    }
    virtual void UploadVertexData(size_t vertexCount, const Vertex* v) override
    {
        DWORD dwLockFlags = D3DLOCK_NOOVERWRITE;

        if (m_vb_pos + vertexCount > m_vb_capacity)
        {
            dwLockFlags = D3DLOCK_DISCARD;
            m_vb_pos = 0;
        }

        size_t size = (size_t)(vertexCount * sizeof(v[0]));

        void* pBytes = NULL;
        m_vb->Lock((UINT)((m_vb_pos * sizeof(v[0]))), (UINT)size, &pBytes, dwLockFlags);

        memcpy(pBytes, v, size);
        m_vb->Unlock();


        m_vb_drawbase = m_vb_pos;
        m_vb_drawcount = (uint32_t)vertexCount;

        m_vb_pos += (uint32_t)vertexCount;

     //   m_device->SetStreamSource(0, m_vb,  0 * sizeof(v[0]), sizeof(v[0]));

      //  m_device->SetStreamSource(0, m_vb, m_vb_drawbase * sizeof(v[0]), sizeof(v[0])   );
    }

    virtual void DrawArrays(PrimitiveType primType, int start, int count) override;
    virtual void DrawIndexed(PrimitiveType primType, int indexOffset, int indexCount) override;

	/*
	virtual float GetDisplayScale() override
	{
		return 1.0f;
	}
	*/



	static void CopyPixelsSwap(uint8_t* dest, const uint8_t* src, int count)
	{
		for (int i = 0; i < count; i++)
		{
			// swap BGRA -> RGBA
			dest[0] = src[2];
			dest[1] = src[1];
			dest[2] = src[0];
			dest[3] = src[3];

			dest += 4;
			src += 4;
		}
	}
    
  	virtual void GetImageDataAsync(TexturePtr texture, std::function<void(ImageDataPtr)> callback) override
    {
        DXTexturePtr t = std::static_pointer_cast<DXTexture>(texture);
        
        LPDIRECT3DTEXTURE9 d3d_texture = t->m_texture;

		LPDIRECT3DSURFACE9 d3d_surface = NULL;
		d3d_texture->GetSurfaceLevel(0, &d3d_surface);

		if (!d3d_surface) {
			callback(nullptr);
			return;
		}


        
        int width = t->GetWidth();
        int height = t->GetHeight();

		LPDIRECT3DSURFACE9 system_surface = NULL;
		m_device->CreateOffscreenPlainSurface(width, height, D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, &system_surface, NULL);
		if (!system_surface) {
			d3d_surface->Release();
			callback(nullptr);
			return;
		}


		m_device->GetRenderTargetData(d3d_surface, system_surface);

		D3DLOCKED_RECT r;
		HRESULT hr = system_surface->LockRect(&r, NULL, D3DLOCK_READONLY);
		if (!SUCCEEDED(hr)) {
			d3d_surface->Release();
			system_surface->Release();
			callback(nullptr);
			return;
		}
        
		ImageDataPtr image = std::make_shared<ImageData>(width, height, PixelFormat::BGRA8Unorm);

		// copy texture data
		for (int y = 0; y < image->height; y++)
		{
			const uint8_t* src_line = (((const uint8_t*)r.pBits) + y * r.Pitch);
			uint8_t* dest_line = (((uint8_t*)image->data) + y * image->pitch);

			// swap BGRA->RGBA
            //	CopyPixelsSwap(dest_line, src_line, image->width);
            memcpy(dest_line, src_line, image->pitch);
		}

        hr = system_surface->UnlockRect();
        assert(SUCCEEDED(hr));

		system_surface->Release();
		d3d_surface->Release();
		callback(image);
        
    }



	
    virtual void Clear(Color4F color)
    {
        m_device->Clear(0, NULL, D3DCLEAR_TARGET | D3DCLEAR_ZBUFFER | D3DCLEAR_STENCIL, 0x00000000, 1.0f, 0);
    }

protected:
	HWND 			   m_window;
	LPDIRECT3DDEVICE9EX    m_device;
	D3DPRESENT_PARAMETERS  m_d3dpp;
	D3DPRESENT_PARAMETERS  m_last_d3dpp;
	LPDIRECT3D9EX          m_d3d;
	D3DCAPS9               m_caps;
	D3DDISPLAYMODEEX	   m_displayMode;
	RECT				   m_WindowRect;

	AutoRef<IDirect3DSurface9> m_frameBuffer;
	D3DSURFACE_DESC m_frameBuffer_desc;
  //  Size2D m_displaySize;

	// vertex declarations:
	AutoRef<IDirect3DVertexDeclaration9> m_pMyVertDecl;


    uint32_t m_vb_capacity;
    uint32_t m_vb_pos;


    uint32_t m_vb_drawbase;
    uint32_t m_vb_drawcount;


    AutoRef<IDirect3DVertexBuffer9> m_vb;

    uint32_t m_ib_capacity;
    uint32_t m_ib_pos;
    uint32_t m_ib_drawbase;

    AutoRef<IDirect3DIndexBuffer9> m_ib;

	DXShaderPtr m_shader;

	TexturePtr m_whiteTexture;

    
    Matrix44 m_xform = MatrixIdentity();


    TexturePtr m_renderTarget;
    Size2D m_renderTargetSize;
    
    std::vector<std::string> m_searchPaths;
    std::vector<std::string> m_textureExtensions;


};


ContextPtr D3D9CreateContext(HWND hWnd)
{
	std::shared_ptr< DXContext> context  = std::make_shared<DXContext>(hWnd);
	context->InitD3D();
	context->BeginScene();
	context->EndScene();
	return context;
}




class DXShader : public Shader, public std::enable_shared_from_this<DXShader>
{

	class DXShaderConstant : public ShaderConstant
	{
	public:
		DXShaderConstant(LPDIRECT3DDEVICE9 device, LPD3DXCONSTANTTABLE table, D3DXHANDLE handle, bool isVertex)
			: m_device(device), m_table(table), m_handle(handle), m_isVertex(isVertex)
		{
			m_table->GetConstantDesc(m_handle, &m_desc, NULL);
			m_table->AddRef();

            m_name = m_desc.Name;

			memset(&m_value, 0, sizeof(m_value));
		}

		virtual ~DXShaderConstant() 
		{
			m_table->Release();
		}

		const std::string &GetName()  override 
		{
			return m_name;
		}

		int GetRegister()
		{
			return m_desc.RegisterIndex;
		}

        
		virtual void SetFloat(float f) override
		{
			m_value.f1 = f;
		}
        virtual void SetVector(const Vector4 &v) override
		{
			*(Vector4*)&m_value.v4 = v;
		}
		virtual void SetMatrix(const Matrix44& m) override
		{
			*(Matrix44*)&m_value.m44 = m;
		}




        void Flush(DXContext *context)
        {
#if 1

			switch (m_desc.Class)
			{
			case D3DXPC_SCALAR:
			{
				if (m_isVertex)
					m_device->SetVertexShaderConstantF(m_desc.RegisterIndex, m_value.v4, 1);
				else
					m_device->SetPixelShaderConstantF(m_desc.RegisterIndex, m_value.v4, 1);

				break;
			}

			case D3DXPC_VECTOR:
			{
				if (m_isVertex)
					m_device->SetVertexShaderConstantF(m_desc.RegisterIndex, m_value.v4, 1);
				else
					m_device->SetPixelShaderConstantF(m_desc.RegisterIndex, m_value.v4, 1);

				break;
			}

			case D3DXPC_MATRIX_COLUMNS:
			{
				if (m_isVertex)
					m_device->SetVertexShaderConstantF(m_desc.RegisterIndex, m_value.m44, 4);
				else
					m_device->SetPixelShaderConstantF(m_desc.RegisterIndex, m_value.m44, 4);

				break;
			}
			case D3DXPC_MATRIX_ROWS:
			{
				D3DXMATRIX mt;
				D3DXMatrixTranspose(&mt, (const D3DXMATRIX*)&m_value.m44[0]);
				if (m_isVertex)
					m_device->SetVertexShaderConstantF(m_desc.RegisterIndex, (float *)&mt, 4);
				else
					m_device->SetPixelShaderConstantF(m_desc.RegisterIndex, (float*)&mt, 4);

				break;
			}

			default:
				assert(0);
				break;



			}
#else
      
			switch (m_desc.Class)
			{
			case D3DXPC_SCALAR:
					m_table->SetFloat(
						m_device,
						m_handle,
						m_value.f1
					);
					break;

			case D3DXPC_VECTOR:

					m_table->SetVector(
						m_device,
						m_handle,
						(const D3DXVECTOR4*)&m_value.v4[0]
					);
					break;

			case D3DXPC_MATRIX_ROWS:
					m_table->SetMatrix(
						m_device,
						m_handle,
						(const D3DXMATRIX*)&m_value.m44[0]
					);
					break;

			case D3DXPC_MATRIX_COLUMNS:
				m_table->SetMatrixTranspose(
					m_device,
					m_handle,
					(const D3DXMATRIX*)&m_value.m44[0]
				);
				break;

			default:
				assert(0);
				break;



			}
#endif
        }

        std::string m_name;
        LPDIRECT3DDEVICE9 m_device;
		LPD3DXCONSTANTTABLE m_table;
		D3DXHANDLE m_handle;
		D3DXCONSTANT_DESC m_desc;
		bool m_isVertex;


		union
		{
			float f1;
			float v4[4];
			float m44[16];
		} m_value;
	};

    class DXSampler : public ShaderSampler
    {
    public:
        inline DXSampler(LPDIRECT3DDEVICE9 device, LPD3DXCONSTANTTABLE table, D3DXHANDLE handle)
            : m_device(device), m_table(table), m_handle(handle)
        {
            m_table->GetConstantDesc(m_handle, &m_desc, NULL);
            m_table->AddRef();

            m_samplerIndex = m_table->GetSamplerIndex(m_handle);
            m_name = m_desc.Name;
        }

        virtual ~DXSampler()
        {
            m_table->Release();
        }

        virtual const std::string& GetName()

        {
            return m_name;
        }

        int GetRegister()
        {
            return m_desc.RegisterIndex;
        }

        virtual void SetTexture(TexturePtr texture, SamplerAddress addr, SamplerFilter filter) override
        {
            m_texture = texture;
            m_addr = addr;
            m_filter = filter;
        }

        void Flush(DXContext *context)
        {
            context->InternalSetTexture(GetRegister(), m_texture);
            context->InternalSetSamplerState(GetRegister(), m_addr, m_filter);

            //  m_context->SetTexture(sampler->m_desc.RegisterIndex, sampler->m_texture);

        }

        std::string m_name;
        TexturePtr m_texture;
        SamplerAddress m_addr = SAMPLER_WRAP;
        SamplerFilter m_filter = SAMPLER_LINEAR;

	
        LPDIRECT3DDEVICE9 m_device;
		LPD3DXCONSTANTTABLE m_table;
		D3DXHANDLE m_handle;
		D3DXCONSTANT_DESC m_desc;
        int m_samplerIndex;
	};


    using DXShaderConstantPtr = std::shared_ptr<DXShaderConstant>;
    using DXSamplerPtr = std::shared_ptr<DXSampler>;

public:
    std::string m_name;
	DXShader(DXContext *context, const char* name)
		:m_context(context), m_name(name)
	{
	}

	virtual ~DXShader()
	{
	}
	virtual bool Compile(const ShaderSource &source) override;
	virtual bool Link() override;

    virtual std::string GetErrors()
    {
        return m_errors;
    }

	void AddConstants(LPD3DXCONSTANTTABLE table, bool isVertex)
	{
		D3DXCONSTANTTABLE_DESC m_desc;
		table->GetDesc(&m_desc);
		for (int i = 0; i < (int)m_desc.Constants; i++)
		{
			D3DXHANDLE h = table->GetConstant(NULL, i);
			D3DXCONSTANT_DESC cd;
			table->GetConstantDesc(h, &cd, NULL);
			if (cd.RegisterSet == D3DXRS_SAMPLER)
			{
				m_samplers.push_back( std::make_shared<DXSampler>(m_context->GetDevice(), table,h));
			}
			else
			if (cd.RegisterSet == D3DXRS_FLOAT4)
			{
				m_constants.push_back(std::make_shared<DXShaderConstant>(m_context->GetDevice(), table, h, isVertex));
			}
		}


        // find positional transform
        m_constant_xform_position = Shader::GetConstant("xform_position");
	}

	//Context *GetContext() { return m_context; }

	virtual int			GetSamplerCount()
	{
		return (int)m_samplers.size();
	}

	virtual ShaderSamplerPtr   GetSampler(int index)
	{
		if (index >= (int)m_samplers.size())
			return nullptr;
		ShaderSamplerPtr sampler =  m_samplers[index];
		return sampler;
	}

	virtual int			GetConstantCount()
	{
		return (int)m_constants.size();
	}

	virtual ShaderConstantPtr	GetConstant(int index)
	{
		return m_constants[index];
	}


    virtual void Flush(DXContext *context)
    {

		if (m_constant_xform_position) {
#if 0
			const Matrix44& xform = context->GetTransform();
			m_constant_xform_position->SetMatrix(xform);
#else
			Matrix44 xform = context->GetTransform();

			Size2D size = context->GetRenderTargetSize();

			// apply half pixel offset fix
			float invX = (1.0f / (float)size.width);
			float invY = (1.0f / (float)size.width);
			xform._41 += invX * xform._44;
			xform._42 += invY * xform._44;
			m_constant_xform_position->SetMatrix(xform);
#endif

		}

		auto device = context->GetDevice();
		device->SetVertexShader(m_vertexShader);
		device->SetPixelShader(m_pixelShader);



		for (auto& constant : m_constants)
		{
			constant->Flush(context);
		}


        for (auto sampler : m_samplers)
        {
            sampler->Flush(context);
          
        }
    }


	//AutoRef<ID3DXConstantTable> m_table;
    ShaderConstantPtr m_constant_xform_position;
	
	DXContext *m_context;
	std::string m_source;

	std::vector< DXSamplerPtr > m_samplers;
	std::vector< DXShaderConstantPtr > m_constants;

	AutoRef<IDirect3DPixelShader9> m_pixelShader;
	AutoRef<IDirect3DVertexShader9> m_vertexShader;

    std::string m_errors;

};

//
//
//

//
//
//


DXContext::DXContext(HWND hWnd)
{
	m_window = hWnd;
	m_d3d = NULL;
	m_device = NULL;

	m_searchPaths.push_back("");

	m_textureExtensions.push_back("");
	m_textureExtensions.push_back(".jpg");
	m_textureExtensions.push_back(".dds");
	m_textureExtensions.push_back(".png");
	m_textureExtensions.push_back(".bmp");
	m_textureExtensions.push_back(".dib");
}

DXContext::~DXContext()
{
	// release 3D interfaces
	if (m_device)
		m_device->Release();
	if (m_d3d)
		m_d3d->Release();
}



//void DXContext::SetWindowedMode()
//{
//    m_d3dpp.Windowed = TRUE;
//}
//
//void DXContext::SetFullScreenMode()
//{
//    m_d3dpp.Windowed = FALSE;
//}
//
//void DXContext::ToggleFullScreenMode()
//{
//    m_d3dpp.Windowed = !m_d3dpp.Windowed;
//}

bool DXContext::UpdateDevice()
{
	// get target window dimensions
	RECT rect;
	GetClientRect(m_d3dpp.hDeviceWindow, &rect);
	int width = rect.right - rect.left;
	int height = rect.bottom - rect.top;

	if (!IsWindowVisible(m_d3dpp.hDeviceWindow) || width <= 0 || height <= 0)
	{
		return false;
	}

	if (m_d3dpp.Windowed)
	{
		m_d3dpp.BackBufferWidth = width;
		m_d3dpp.BackBufferHeight = height;
		m_d3dpp.FullScreen_RefreshRateInHz = 0;
		m_d3dpp.BackBufferFormat = D3DFMT_A8R8G8B8;
		m_d3dpp.SwapEffect = D3DSWAPEFFECT_DISCARD;
	}
	else
	{
		m_d3dpp.BackBufferWidth = m_displayMode.Width;
		m_d3dpp.BackBufferHeight = m_displayMode.Height;
		m_d3dpp.FullScreen_RefreshRateInHz = m_displayMode.RefreshRate;
		m_d3dpp.SwapEffect = D3DSWAPEFFECT_DISCARD;
		m_d3dpp.PresentationInterval = D3DPRESENT_INTERVAL_ONE;
		//m_d3dpp.BackBufferFormat = D3DFMT_A16B16G16R16; //;
	//	m_d3dpp.BackBufferFormat = D3DFMT_A2R10G10B10; //;
        m_d3dpp.BackBufferFormat = D3DFMT_A8R8G8B8;
	}

	if (memcmp(&m_d3dpp, &m_last_d3dpp, sizeof(m_d3dpp)) == 0)
	{
		// no change in present parameters... do nothing
		return true;
	}

	// did windowed state change?
	if (m_d3dpp.Windowed != m_last_d3dpp.Windowed)
	{
		if (m_d3dpp.Windowed)
		{
			// going to windowed
			SetWindowLong(m_d3dpp.hDeviceWindow, GWL_STYLE, WS_OVERLAPPEDWINDOW);
			SetWindowPos(m_d3dpp.hDeviceWindow, HWND_TOP,
				m_WindowRect.left, m_WindowRect.top,
				m_WindowRect.right - m_WindowRect.left,
				m_WindowRect.bottom - m_WindowRect.top,
				SWP_FRAMECHANGED | /*SWP_NOMOVE | SWP_NOSIZE |*/ SWP_SHOWWINDOW);
		}
		else
		{
			// going to full screen
			GetWindowRect(m_d3dpp.hDeviceWindow, &m_WindowRect);
			SetWindowLong(m_d3dpp.hDeviceWindow, GWL_STYLE, WS_EX_TOPMOST | WS_VISIBLE | WS_POPUP);
			SetWindowPos(m_d3dpp.hDeviceWindow, HWND_TOP, 0, 0, m_d3dpp.BackBufferWidth, m_d3dpp.BackBufferHeight,
				SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);
		}
	}

	// reset device
	HRESULT hr = m_device->ResetEx(&m_d3dpp, !m_d3dpp.Windowed ? &m_displayMode : nullptr);
	if (FAILED(hr)) {
		assert(0);
		return false;
	}

	m_last_d3dpp = m_d3dpp;


	/*
	D3DDISPLAYMODEEX m2;
	m2.Size = sizeof(m2);
	D3DDISPLAYROTATION r2;
	m_device->GetDisplayModeEx(0, &m2, &r2);
	*/

	LogPrint("Resized device to %dx%d (%s)\n", m_d3dpp.BackBufferWidth, m_d3dpp.BackBufferHeight, m_d3dpp.Windowed ? "windowed" : "fullscreen" );
	return true;
}


void DXContext::ResetState()
{
    m_device->SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
    m_device->SetRenderState(D3DRS_CLIPPING, TRUE);
    m_device->SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID);
    m_device->SetRenderState(D3DRS_ZFUNC, D3DCMP_ALWAYS);
    m_device->SetRenderState(D3DRS_ALPHATESTENABLE, FALSE);
    m_device->SetRenderState(D3DRS_ZENABLE, FALSE);

    m_shader = NULL;
    m_device->SetVertexShader(NULL);
    m_device->SetPixelShader(NULL);

    for (int i = 0; i < 8; i++)
    {
        InternalSetTexture(i, NULL);
        InternalSetSamplerState(i, SAMPLER_WRAP, SAMPLER_LINEAR);
    }
    SetDepthEnable(false);
    SetBlendDisable();

    // set initial viewport
    SetRenderTarget(nullptr);

    m_device->SetVertexDeclaration(m_pMyVertDecl);

}

void DXContext::BeginScene()
{
	if (!UpdateDevice())
	{
		return;
	}

	if (!m_whiteTexture) {
		uint32_t white[32*32];
		for (int i = 0; i < 32 * 32; i++)
			white[i] = 0xFFFFFFFF;
		m_whiteTexture = CreateTexture("white", 32, 32, PixelFormat::BGRA8Unorm, &white[0]);
	}

	m_device->BeginScene();

	// render to swap chain
	IDirect3DSurface9 *target = nullptr;
	m_device->GetBackBuffer(0, 0, D3DBACKBUFFER_TYPE_MONO, &target);
	if (!target)
		return;
	m_frameBuffer = target;
	target->Release();

	m_frameBuffer->GetDesc(&m_frameBuffer_desc);

   // m_displaySize = Size2D( m_frameBuffer_desc.Width, m_frameBuffer_desc.Height);

#if 1
	UINT dpi = GetDpiForWindow( m_window );
	float scale = ((float)dpi) / ((float)USER_DEFAULT_SCREEN_DPI);
#else 
	float scale = 1.0f;
#endif

	float rate = (float)m_displayMode.RefreshRate;
	if (rate == 0) rate = 60.0f;

	SetDisplayInfo(
		{
		.size = Size2D(m_frameBuffer_desc.Width, m_frameBuffer_desc.Height),
		.format =  ConvertFormat(m_frameBuffer_desc.Format),  // render::PixelFormat::RGBA8Unorm,
		.refreshRate = rate,
		.scale = scale,
		.samples = m_frameBuffer_desc.MultiSampleType,
		.maxEDR = 1.0f
		}
	);

    ResetState();

//	return true;
}

void DXContext::EndScene()
{
	m_device->EndScene();

	m_device->SetVertexShader(NULL);
	m_device->SetPixelShader(NULL);
	
    SetRenderTarget(nullptr);

	m_frameBuffer = NULL;
	m_shader = NULL;
}

void DXContext::Present()
{
	HRESULT hr;
	hr = m_device->Present(NULL, NULL, NULL, NULL);

	if (FAILED(hr))
	{
		// umm... reset device
		LogPrint("ERROR: Present failed, resetting device");
		hr = m_device->ResetEx(&m_d3dpp, !m_d3dpp.Windowed ? &m_displayMode : nullptr);
	}
}

void DXContext::SetShader(ShaderPtr shader)
{
	m_shader = std::static_pointer_cast<DXShader>(shader);
}


ShaderPtr DXContext::CreateShader(const char *name)
{
	return std::make_shared<DXShader>(this, name);
}


class CompilerInclude : public ID3DXInclude
{
public:

    CompilerInclude(std::string path)
        :m_path(path) {}

    HRESULT Open(D3DXINCLUDE_TYPE IncludeType, LPCSTR pFileName, LPCVOID pParentData, LPCVOID* ppData, UINT* pBytes) override
    {
		std::string dir = PathGetDirectory(m_path);
        std::string path = PathCombine(dir, pFileName);

        *ppData = NULL;
        *pBytes = 0;

        std::string output;
        if (!FileReadAllText(path, output)) {
            return -1;
        }

        *ppData = strdup(output.c_str());
        *pBytes = (UINT) output.size();
        return S_OK;

    }
    HRESULT Close(LPCVOID pData) override
    {
        free( (void *)pData);
        return S_OK;
    }

    std::string m_path;


};

bool DXShader::Compile(const ShaderSource &source)
{
	LPD3DXBUFFER pByteCode = NULL;
	LPD3DXBUFFER pErrors = NULL;
	LPD3DXCONSTANTTABLE pTable = NULL;

	DWORD flags = D3DXSHADER_ENABLE_BACKWARDS_COMPATIBILITY;
    CompilerInclude include(source.path);


	// now really try to compile it.
	HRESULT hr = D3DXCompileShader(
		source.code.c_str(),
		(UINT)source.code.size(),
		NULL,//CONST D3DXMACRO* pDefines,
		&include,//LPD3DXINCLUDE pInclude,
		source.functionName.c_str(),
		source.profile.c_str(),
		flags,
		&pByteCode,
		&pErrors,
		&pTable
		);
    if (hr != D3D_OK)
    {
        if (pErrors)
        {
            m_errors = (const char *)pErrors->GetBufferPointer();
        }

        LogError("Could not compile shader with profile %s\n%s\n%s", source.profile.c_str(),
            m_errors.c_str(), source.code.c_str());

    
		if (pErrors)
			pErrors->Release();
		return false;
	}

	if (source.IsVertex())
	{
		IDirect3DVertexShader9 *pShader;
		hr = m_context->GetDevice()->CreateVertexShader((const DWORD *)(pByteCode->GetBufferPointer()), &pShader);
		if (hr != D3D_OK)
		{
			return false;
		}
		m_vertexShader = pShader;

	}
	else if (source.IsFragment())
	{
		IDirect3DPixelShader9 *pShader;
		hr = m_context->GetDevice()->CreatePixelShader((const DWORD *)(pByteCode->GetBufferPointer()), &pShader);
		if (hr != D3D_OK)
		{
			return false;
		}
		m_pixelShader = pShader;
	}
	
	this->AddConstants(pTable, source.IsVertex());

	if (pByteCode)
		pByteCode->Release();
	if (pTable)
		pTable->Release();
	return true;
}

bool DXShader::Link()
{
	return (m_vertexShader != NULL) && (m_pixelShader != NULL);

}

static AutoRef<IDirect3DVertexDeclaration9> CreateVertexDeclaration(IDirect3DDevice9 *device, CONST D3DVERTEXELEMENT9*elements)
{
	AutoRef<IDirect3DVertexDeclaration9> decl;
	device->CreateVertexDeclaration(elements, decl.GetAddressOf() );
	return decl;
}

bool DXContext::InitD3D()
{
	HRESULT hr = Direct3DCreate9Ex(D3D_SDK_VERSION, &m_d3d);
	if (FAILED(hr))
	{
		LogError("Direct3DCreate9Ex Failed");
		return FALSE;
	}

	/*
	int adapterCount = m_d3d->GetAdapterCount();
	for (int i = 0; i < adapterCount; i++)
	{
		D3DDISPLAYMODEEX am;
		am.Size = sizeof(am);
		D3DDISPLAYROTATION rot;
		m_d3d->GetAdapterDisplayModeEx(i, &am, &rot);
		LogPrint("adapter[%d] mode %d %d %d\n", i, am.Width, am.Height, am.Format);
	}
	*/


	m_displayMode.Size = sizeof(m_displayMode);
	m_displayMode.Width = GetSystemMetrics(SM_CXSCREEN);
	m_displayMode.Height = GetSystemMetrics(SM_CYSCREEN);
	m_displayMode.RefreshRate = 60;
	m_displayMode.ScanLineOrdering = D3DSCANLINEORDERING_PROGRESSIVE;
//	m_displayMode.Format = D3DFMT_A2R10G10B10;
	m_displayMode.Format = D3DFMT_X8R8G8B8;

	RECT rect;
	::GetClientRect(m_window, &rect);
	
	// set up m_d3dpp (presentation parameters):
	memset(&m_d3dpp,0,sizeof(m_d3dpp));
	m_d3dpp.Windowed = TRUE;
	m_d3dpp.hDeviceWindow = m_window;
	m_d3dpp.EnableAutoDepthStencil = TRUE;
	m_d3dpp.AutoDepthStencilFormat = D3DFMT_D24S8;
	m_d3dpp.MultiSampleType = D3DMULTISAMPLE_NONE;
	m_d3dpp.BackBufferWidth = rect.right - rect.left;
	m_d3dpp.BackBufferHeight = rect.bottom - rect.top;
	m_d3dpp.BackBufferCount = 2;
	m_d3dpp.FullScreen_RefreshRateInHz = 0;
	m_d3dpp.SwapEffect = D3DSWAPEFFECT_DISCARD;
	m_d3dpp.BackBufferFormat = D3DFMT_A8R8G8B8;

	GetWindowRect(m_d3dpp.hDeviceWindow, &m_WindowRect);

	HRESULT hRes = m_d3d->CreateDeviceEx(
		D3DADAPTER_DEFAULT,
		D3DDEVTYPE_HAL,
		m_d3dpp.hDeviceWindow,
		D3DCREATE_HARDWARE_VERTEXPROCESSING | D3DCREATE_ENABLE_PRESENTSTATS,
		&m_d3dpp,
		!m_d3dpp.Windowed ? &m_displayMode : nullptr,
		&m_device
	);

	if (FAILED(hRes))
	{
		LogError("Unable to create D3D9 Device error:%d\n", hRes);
		return FALSE;
	}

	// save of present parameters
	m_last_d3dpp = m_d3dpp;

	// get caps
	m_device->GetDeviceCaps(&m_caps);

	D3DADAPTER_IDENTIFIER9 adapter_desc;
	m_d3d->GetAdapterIdentifier(m_caps.AdapterOrdinal, 0, &adapter_desc);

	m_description = adapter_desc.Description;

	

	m_pMyVertDecl = CreateVertexDeclaration(m_device, g_MyVertDecl);


    m_vb_capacity = 128 * 1024;
    m_vb_pos = 0;

    IDirect3DVertexBuffer9* vb;
    hr =  m_device->CreateVertexBuffer(m_vb_capacity * sizeof(Vertex), D3DUSAGE_DYNAMIC, 0, D3DPOOL_DEFAULT, &vb, NULL);
    if (FAILED(hr))
    {
        return FALSE;
    }

    m_vb.SetPtr(vb);

    m_ib_capacity = 512 * 1024;
    m_ib_pos = 0;

    IDirect3DIndexBuffer9* ib;
 //   hr = m_device->CreateIndexBuffer(m_ib_capacity * sizeof(int32_t), D3DUSAGE_DYNAMIC, D3DFMT_INDEX32,  D3DPOOL_DEFAULT, &ib, NULL);
    hr = m_device->CreateIndexBuffer(m_ib_capacity * sizeof(IndexType), D3DUSAGE_DYNAMIC,  sizeof(IndexType) == 2 ? D3DFMT_INDEX16 : D3DFMT_INDEX32, D3DPOOL_DEFAULT, &ib, NULL);

    if (FAILED(hr))
    {
        return FALSE;
    }
    m_ib.SetPtr(ib);



	// set initial viewport
	//SetViewport();
	return TRUE;
}

void DXContext::SetViewport(int x, int y, int w, int h)
{
    D3DVIEWPORT9 v;
    v.X = x;
    v.Y = y;
    v.Width = w;
    v.Height = h;
    v.MinZ = 0.0f;
    v.MaxZ = 1.0f;
    m_device->SetViewport(&v);
}

void DXContext::SetScissorRect(int x, int y, int w, int h)
{
	RECT s;
	s.left = x; 
	s.top = y;
	s.right = x + w;
	s.bottom = y + h;
	m_device->SetScissorRect(&s);

    m_device->SetRenderState(D3DRS_SCISSORTESTENABLE, TRUE);

}


static int ToPrimCount(PrimitiveType primType, int vertexCount)
{

    int primCount;
    int indexCount = vertexCount;
    switch (primType)
    {
    case PRIMTYPE_POINTLIST:
        primCount = indexCount;
        break;
    case PRIMTYPE_LINELIST:
        primCount = indexCount / 2;
        break;
    case PRIMTYPE_LINESTRIP:
        primCount = indexCount - 1;
        break;
    case PRIMTYPE_TRIANGLELIST:
        primCount = indexCount / 3;
        break;
    case PRIMTYPE_TRIANGLESTRIP:
        primCount = indexCount - 2;
        break;
    case PRIMTYPE_TRIANGLEFAN:
        primCount = indexCount - 2;
        break;
    default:
        assert(0);
        break;
    };
    return primCount;
}

void DXContext::DrawArrays(PrimitiveType primType, int vertexStart, int vertexCount) 
{
    m_shader->Flush(this);

    int primCount = ToPrimCount(primType, vertexCount);

   // m_device->DrawPrimitive((D3DPRIMITIVETYPE)primType, (0 + start), primCount);
  
    m_device->SetStreamSource(0, m_vb, 0, sizeof(Vertex));
    m_device->DrawPrimitive((D3DPRIMITIVETYPE)primType, (m_vb_drawbase + vertexStart), primCount);

}

void DXContext::DrawIndexed(PrimitiveType primType, int indexOffset, int indexCount) 
{
    //STDMETHOD(DrawIndexedPrimitive)(THIS_ D3DPRIMITIVETYPE, INT BaseVertexIndex, UINT MinVertexIndex, UINT NumVertices, UINT startIndex, UINT primCount) PURE;
    m_shader->Flush(this);


    int primCount = ToPrimCount(primType, indexCount);
   
  //  m_device->DrawIndexedPrimitive((D3DPRIMITIVETYPE)primType, 0, 0, m_vb_drawcount, m_ib_drawbase + indexOffset, primCount);

    m_device->SetStreamSource(0, m_vb, 0, sizeof(Vertex));
    m_device->SetIndices(m_ib);
    m_device->DrawIndexedPrimitive((D3DPRIMITIVETYPE)primType, m_vb_drawbase, 0, m_vb_drawcount, m_ib_drawbase + indexOffset, primCount);

 //   m_device->DrawIndexedPrimitive((D3DPRIMITIVETYPE)primType, 0 , 0, m_vb_drawcount, m_ib_drawbase + indexOffset, indexCount);
    //m_device->DrawIndexedPrimitive((D3DPRIMITIVETYPE)primType, m_vb_drawbase * sizeof(MYVERTEX), 0, m_vb_drawcount, m_ib_drawbase + indexOffset, indexCount);
}


TexturePtr DXContext::CreateRenderTarget(const char *name, int width, int height, PixelFormat format)
{
	IDirect3DTexture9 *texture = NULL;
	DWORD flags = D3DUSAGE_RENDERTARGET;
	HRESULT hr = m_device->CreateTexture(width, height, 1, flags,
		ConvertFormat(format),
		//D3DFMT_A8R8G8B8,
		//D3DFMT_A16B16G16R16
		//D3DFMT_A32B32G32R32F,
		D3DPOOL_DEFAULT, &texture, NULL);
	if (hr != D3D_OK)
	{
		return NULL;
	}
	auto dxtexture = std::make_shared<DXTexture>( name, texture);
	return dxtexture;
}

TexturePtr DXContext::CreateTexture(const char *name, int width, int height, PixelFormat format, const void *data)
{
	IDirect3DTexture9 *texture = NULL;
	DWORD flags = D3DUSAGE_DYNAMIC;
//	flags |= D3DUSAGE_AUTOGENMIPMAP;

	HRESULT hr = m_device->CreateTexture(width, height, 1, flags,
		ConvertFormat(format),
//		D3DFMT_A8R8G8B8,
		D3DPOOL_DEFAULT, 
		&texture, NULL);
	if (hr != D3D_OK)
	{
		return NULL;
	}

	D3DLOCKED_RECT r;
	hr = texture->LockRect(0, &r, NULL, D3DLOCK_DISCARD);
	assert(SUCCEEDED(hr));

	// copy texture data
	for (int y = 0; y < height; y++)
	{
		const void *src = data + width * y;
		void *dest = ((char *)r.pBits) + y * r.Pitch;
		memcpy(dest, src, width * sizeof(uint32_t));
	}

	hr = texture->UnlockRect(0);
	assert(SUCCEEDED(hr));

    auto dxtexture = std::make_shared<DXTexture>(name, texture);
	return dxtexture;
}

static std::string FixPath(std::string path)
{
    for (size_t i = 0; i < path.size(); i++)
    {
        if (path[i] == '/')
            path[i] = '\\';
    }
    return path;
}


TexturePtr DXContext::CreateTextureFromFile(const char *name, const char *path)
{
	for (size_t i = 0; i < m_searchPaths.size(); i++)
	{
		for (size_t j = 0; j < m_textureExtensions.size(); j++)
		{
			std::string fullPath;
			fullPath = m_searchPaths[i];
			fullPath += path;
			fullPath += m_textureExtensions[j];

            fullPath = FixPath(fullPath);

			if (FileExists(fullPath.c_str()))
			{
				IDirect3DTexture9 *texture = NULL;
#if 0
                D3DXIMAGE_INFO desc;
                HRESULT hr = D3DXCreateTextureFromFileExA(
					m_device,
					fullPath.c_str(),
					D3DX_DEFAULT, // w
					D3DX_DEFAULT, // h
					D3DX_DEFAULT,        // # mip levels to gen - all
					 0,                    // usage flags
					D3DFMT_UNKNOWN,
					D3DPOOL_MANAGED,
					D3DX_DEFAULT,     //filter
					D3DX_DEFAULT,     //mipfilter
					0,                // color key
					&desc,
					NULL,             //palette
					&texture
					);
#else 
                HRESULT hr = D3DXCreateTextureFromFileA(
                    m_device,
                    fullPath.c_str(),                
                    &texture
                );
#endif
				if (hr != D3D_OK)
				{
 					LogError("Could not load texture from file %s\n", fullPath.c_str());
					return NULL;
				}
                auto dxtexture = std::make_shared<DXTexture>(name, texture);
				return dxtexture;
			}
		}
	}

	LogError("Could not find texture %s\n", path);
	return NULL;
}

} // d3d9

} // namespace render

#endif // WIN32
