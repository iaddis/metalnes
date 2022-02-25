
#if WIN32

#include <stddef.h>
#include <assert.h>
#include <string>
#include <map>
#include <vector>

#include "context.h"
#include "platform.h"
#include "AutoRef.h"


#include <d3d11.h>
#include "..\..\external\dxsdk\Include\d3dx11.h"
#include <d3dcompiler.h>
#include <D3D11Shader.h>
//#include "..\..\external\dxsdk\Include\xnamath.h"



#pragma comment(lib, "d3d11.lib")
#pragma comment(lib, "d3dx11.lib")
#pragma comment(lib, "D3DCompiler.lib")
#pragma comment(lib, "dxguid.lib")


namespace render {
	namespace d3d11 {

		class DXContext;
		class DXTexture;
		class DXShader;
		using DXContextPtr = std::shared_ptr<DXContext>;
		using DXTexturePtr = std::shared_ptr<DXTexture>;
		using DXShaderPtr = std::shared_ptr<DXShader>;



		static DXGI_FORMAT ConvertFormat(PixelFormat format)
		{
			switch (format)
			{
			case PixelFormat::Invalid:
				return DXGI_FORMAT_UNKNOWN;

			case PixelFormat::RGBA8Unorm:
				return DXGI_FORMAT_R8G8B8A8_UNORM;

			case PixelFormat::RGBA8Unorm_sRGB:
				return DXGI_FORMAT_R8G8B8A8_UNORM_SRGB;

			case PixelFormat::BGRA8Unorm:
				return DXGI_FORMAT_B8G8R8A8_UNORM;
			case PixelFormat::BGRA8Unorm_sRGB:
				return DXGI_FORMAT_B8G8R8A8_UNORM_SRGB;

			case PixelFormat::A8Unorm:
				return DXGI_FORMAT_A8_UNORM;

			case PixelFormat::RGBA16Unorm:
			case PixelFormat::RGBA16Snorm:
			case PixelFormat::RGBA16Float:
			case PixelFormat::RGBA32Float:
			case PixelFormat::BGR10A2Unorm:
			default:
				assert(0);
				return DXGI_FORMAT_UNKNOWN;
			}
		}


		static PixelFormat ConvertFormat(DXGI_FORMAT format)
		{
			switch (format)
			{
			case DXGI_FORMAT_UNKNOWN:
				return PixelFormat::Invalid;
			case DXGI_FORMAT_B8G8R8A8_UNORM:
				return PixelFormat::BGRA8Unorm;
			case DXGI_FORMAT_R8G8B8A8_UNORM:
				return PixelFormat::RGBA8Unorm;
			case DXGI_FORMAT_B8G8R8A8_UNORM_SRGB:
				return PixelFormat::BGRA8Unorm_sRGB;
			case DXGI_FORMAT_R8G8B8A8_UNORM_SRGB:
				return PixelFormat::RGBA8Unorm_sRGB;
			case DXGI_FORMAT_A8_UNORM:
				return PixelFormat::A8Unorm;
			default:
				assert(0);
				return PixelFormat::Invalid;
			}
		}




		// Define the input layout
		static D3D11_INPUT_ELEMENT_DESC sVertexLayout[] =
		{
			{ "POSITION",  0, DXGI_FORMAT_R32G32B32_FLOAT, 0, offsetof(Vertex, x),      D3D11_INPUT_PER_VERTEX_DATA, 0 },
			{ "COLOR",     0, DXGI_FORMAT_R8G8B8A8_UNORM, 0, offsetof(Vertex, Diffuse),         D3D11_INPUT_PER_VERTEX_DATA, 0 },
			{ "TEXCOORD",  0, DXGI_FORMAT_R32G32_FLOAT, 0, offsetof(Vertex, tu),      D3D11_INPUT_PER_VERTEX_DATA, 0 },
			{ "TEXCOORD",  1, DXGI_FORMAT_R32G32_FLOAT, 0, offsetof(Vertex, rad),      D3D11_INPUT_PER_VERTEX_DATA, 0 },
		};


		struct VertexConstants
		{
			Matrix44	Projection;
			Matrix44	ColorXform;
			Matrix44	TexCoordXform;
		};


		class DXBufferPool
		{
		public:

		};
		using DXBufferPoolPtr = std::shared_ptr< DXBufferPool >;


		static size_t Align(size_t _pos, size_t alignment)
		{
			if (_pos & (alignment - 1)) {
				// align position
				_pos = (_pos + (alignment - 1)) & ~(alignment - 1);
			}
			return _pos;
		}

		class DXDynamicBuffer
		{
		public:

			UINT _bindflags;

			DXDynamicBuffer(UINT bindflags)
				:_bindflags(bindflags)
			{
			}

			~DXDynamicBuffer()
			{
				_buffer = nullptr;
			}

			void SetLabel(const char* label)
			{

			}

			void Clear()
			{
				_pos = 0;
				_base = 0;
			}

			void ResizeBuffer(ID3D11Device* device, size_t length)
			{
				{
					_buffer = nullptr;


					D3D11_BUFFER_DESC Desc = { 0 };
					Desc.Usage = D3D11_USAGE_DYNAMIC;
					Desc.BindFlags = _bindflags;
					Desc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
					Desc.MiscFlags = 0;
					Desc.ByteWidth = (UINT)length;


					ID3D11Buffer* buffer = nullptr;
					HRESULT hr = device->CreateBuffer(&Desc, NULL, &buffer);
					assert(SUCCEEDED(hr));

					if (FAILED(hr)) return;

					_buffer.SetPtr(buffer);
					_pos = 0;
					_base = 0;
					_capacity = length;

				}
			}

			void WriteBytes(ID3D11DeviceContext* context, const void* data, size_t alignment, size_t stride, size_t count)
			{
				_stride = stride;

				// align position
				_pos = Align(_pos, alignment);


				size_t length = count * stride;

				D3D11_MAP map;

				if (length > _capacity)
				{
					// we need a bigger buffer...
					size_t capacity = length;

					ID3D11Device* device;
					context->GetDevice(&device);
					ResizeBuffer(device, capacity);

					map = D3D11_MAP_WRITE_DISCARD;
				}
				else if (_pos == 0 || (_pos + length) > _capacity)
				{
					// start at beginning of buffer
					map = D3D11_MAP_WRITE_DISCARD;
					_pos = 0;
				}
				else
				{
					// append
					map = D3D11_MAP_WRITE_NO_OVERWRITE;
				}



				// map vertex buffer
				D3D11_MAPPED_SUBRESOURCE mapped;
				HRESULT hr = context->Map(_buffer, 0, map, 0, &mapped);
				if (FAILED(hr))
				{
					// failed to map
					assert(0);
					return;
				}


				// copy into buffer
				uint8_t* dest = (((uint8_t*)mapped.pData) + _pos);
				memcpy(dest, data, length);

				context->Unmap(_buffer, 0);

				_base = _pos;
				_pos += length;
			}


			template<typename T>
			void Write(ID3D11DeviceContext* context, const T* data, size_t count)
			{
				WriteBytes(context, data, alignof(T), sizeof(T), count);
			}

			size_t GetBase() const {
				return _base;
			}

			size_t GetStride() const {
				return _stride;
			}

			template<typename T>
			size_t GetBaseOffset(size_t index) const {
				return _base + index * sizeof(T);
			}

			ID3D11Buffer* GetBuffer() const {
				return _buffer;
			}

		protected:
			AutoRef<ID3D11Buffer> _buffer;
			size_t        _pos = 0;
			size_t        _base = 0;
			size_t        _capacity = 0;
			size_t        _stride = 0;

		};




		class DXContext : public Context
		{
		public:
			DXContext(ID3D11Device* pDevice, ID3D11DeviceContext* pDeviceContext, IDXGISwapChain* pSwapChain);
			virtual ~DXContext();


			virtual Size2D GetRenderTargetSize()  override { return m_renderTargetSize; }

			virtual float GetTexelOffset() override { return 0.0f; }
			virtual const std::string& GetDriver()  override { return m_driver; };
			virtual const std::string& GetDesc() override { return m_description; };


			virtual bool IsSupported(PixelFormat format) override
			{
				return true;
			}

			virtual TexturePtr CreateTextureFromFile(const char* name, const char* path)  override;
			virtual TexturePtr CreateRenderTarget(const char* name, int width, int height, PixelFormat format)  override;
			virtual TexturePtr CreateTexture(const char* name, int width, int height, PixelFormat format, const void* data)  override;
			virtual ShaderPtr CreateShader(const char* name)  override;
			virtual void SetShader(ShaderPtr shader) override;

			virtual void GetImageDataAsync(TexturePtr texture, std::function<void(ImageDataPtr)> callback) override;



			virtual void			BeginScene()  override;
			virtual void			EndScene()  override;

			virtual void            Present()  override;

		
			virtual void SetRenderTarget(TexturePtr texture, const char* passName = nullptr, LoadAction action = LoadAction::Load, Color4F clearColor = Color4F(0, 0, 0, 0)) override;

			

			ID3D11SamplerState* GetSamplerState(SamplerAddress address, SamplerFilter filter);

			void InternalSetTexture(int index, TexturePtr texture, SamplerAddress address, SamplerFilter filter);

			virtual void Flush() override
			{

			}

			bool Init();



			virtual void SetBlendDisable()  override
			{
				if (!mBlendStateDisable)
				{
					D3D11_BLEND_DESC desc = {};
					desc.RenderTarget[0].BlendEnable = false;
					desc.RenderTarget[0].SrcBlend = D3D11_BLEND_SRC_ALPHA;
					desc.RenderTarget[0].DestBlend = D3D11_BLEND_INV_SRC_ALPHA;
					desc.RenderTarget[0].BlendOp = D3D11_BLEND_OP_ADD;
					desc.RenderTarget[0].SrcBlendAlpha = D3D11_BLEND_ONE;
					desc.RenderTarget[0].DestBlendAlpha = D3D11_BLEND_ZERO;
					desc.RenderTarget[0].BlendOpAlpha = D3D11_BLEND_OP_ADD;
					desc.RenderTarget[0].RenderTargetWriteMask = D3D11_COLOR_WRITE_ENABLE_ALL;

					ID3D11BlendState* pBlendState;
					mD3DDevice->CreateBlendState(&desc, &pBlendState);
					mBlendStateDisable = pBlendState;
				}
				// set blend state
				float blendFactor[] = { 0, 0, 0, 0 };
				UINT sampleMask = 0xffffffff;
				mD3DContext->OMSetBlendState(mBlendStateDisable, blendFactor, sampleMask);

				//m_device->SetRenderState(D3DRS_ALPHABLENDENABLE, FALSE);
				//m_device->SetRenderState(D3DRS_ALPHABLENDENABLE, enable ? TRUE : FALSE);
			}

			virtual void SetDepthEnable(bool enable)  override
			{
				/*if (enable) {
					m_device->SetRenderState(D3DRS_ZENABLE, TRUE);
					m_device->SetRenderState(D3DRS_ZWRITEENABLE, TRUE);
				}
				else {
					m_device->SetRenderState(D3DRS_ZENABLE, FALSE);
					m_device->SetRenderState(D3DRS_ZWRITEENABLE, FALSE);
				}*/
			}

		

			using SamplerKey = std::tuple< SamplerAddress, SamplerFilter >;


			struct SamplerKeyHash
			{
				size_t operator()(const SamplerKey& key) const
				{
					return 0
						^ (std::hash<int>()((int)std::get<0>(key)) << 0)
						^ (std::hash<int>()((int)std::get<1>(key)) << 8)

						;
				}
			};


			using BlendKey = std::tuple< BlendFactor, BlendFactor>;
			
			struct BlendKeyHash
			{
				size_t operator()(const BlendKey& key) const
				{
					return 0
						^ (std::hash<int>()((int) std::get<0>(key) ) << 0)
						^ (std::hash<int>()((int) std::get<1>(key) ) << 8)
					
						;
				}
			};



			static D3D11_BLEND ConvertBlendFactor(BlendFactor factor)
			{
				switch (factor)
				{
				case 	BLEND_ZERO:
					return 	D3D11_BLEND_ZERO;
				case 	BLEND_ONE:
					return D3D11_BLEND_ONE;
				case 	BLEND_SRCCOLOR:
					return D3D11_BLEND_SRC_COLOR;
				case 	BLEND_INVSRCCOLOR:
					return D3D11_BLEND_INV_SRC_COLOR;
				case 	BLEND_SRCALPHA:
					return D3D11_BLEND_SRC_ALPHA;
				case 	BLEND_INVSRCALPHA:
					return D3D11_BLEND_INV_SRC_ALPHA;
				case 	BLEND_DESTALPHA:
					return D3D11_BLEND_DEST_ALPHA;
				case 	BLEND_INVDESTALPHA:
					return D3D11_BLEND_INV_DEST_ALPHA;
				case 	BLEND_DESTCOLOR:
					return D3D11_BLEND_DEST_COLOR;
				case 	BLEND_INVDESTCOLOR:
					return D3D11_BLEND_INV_DEST_COLOR;
				default:
					assert(0);
					return D3D11_BLEND_ZERO;
				}
			}


			virtual void SetBlend(BlendFactor sourceFactor, BlendFactor destFactor)  override
			{

				BlendKey key{ sourceFactor, destFactor };

				ID3D11BlendState* state;

				auto it = _blend_map.find(key);
				if (it != _blend_map.end())
				{
					state = it->second;
				}
				else
				{
					D3D11_BLEND_DESC desc = {};
					desc.RenderTarget[0].BlendEnable = true;
					desc.RenderTarget[0].SrcBlend = ConvertBlendFactor(sourceFactor);
					desc.RenderTarget[0].DestBlend = ConvertBlendFactor(destFactor);
					desc.RenderTarget[0].BlendOp = D3D11_BLEND_OP_ADD;
					desc.RenderTarget[0].SrcBlendAlpha = D3D11_BLEND_ONE;
					desc.RenderTarget[0].DestBlendAlpha = D3D11_BLEND_ZERO;
					desc.RenderTarget[0].BlendOpAlpha = D3D11_BLEND_OP_ADD;
					desc.RenderTarget[0].RenderTargetWriteMask = D3D11_COLOR_WRITE_ENABLE_ALL;

					mD3DDevice->CreateBlendState(&desc, &state);					
					_blend_map[key] = state;
				}
			
				// set blend state
				float blendFactor[] = { 0, 0, 0, 0 };
				UINT sampleMask = 0xffffffff;
				mD3DContext->OMSetBlendState(state, blendFactor, sampleMask);
			}


			virtual void SetScissorDisable() override
			{
				mD3DContext->RSSetState(mScissorDisable);
			}

			virtual void SetPointSize(float size) override
			{
			}

			virtual void SetTransform(const Matrix44& m) override
			{
				m_xform = m;
			}

			virtual const Matrix44& GetTransform() const override
			{
				return m_xform;
			}


			virtual void SetScissorRect(int x, int y, int w, int h) override
			{
				D3D11_RECT r = {
					.left = x,
					.top = y,
					.right = x + w,
					.bottom = y + h
				};
				mD3DContext->RSSetScissorRects(1, &r);

				mD3DContext->RSSetState(mScissorEnable);
			}


			virtual void SetViewport(int x, int y, int w, int h) override
			{
				float minZ = 0;
				float maxZ = 1;

				// Setup the viewport
				D3D11_VIEWPORT vp;
				vp.TopLeftX = (float)x;
				vp.TopLeftY = (float)y;
				vp.Width = (float)w;
				vp.Height = (float)h;
				vp.MinDepth = minZ;
				vp.MaxDepth = maxZ;
				mD3DContext->RSSetViewports(1, &vp);

			}




			virtual void UploadIndexData(int indexCount, const IndexType* indices) override
			{
				_indexBuffer.Write(mD3DContext, indices, indexCount);
			}

			virtual void UploadVertexData(size_t vertexCount, const Vertex* v) override
			{
				_vertexBuffer.Write(mD3DContext, v, vertexCount);
			}

		

			virtual void DrawArrays(PrimitiveType primType, int start, int count) override;


			virtual void DrawIndexed(PrimitiveType primType, int indexOffset, int indexCount) override;


			//private:
			std::string m_driver;
			std::string m_description;

			Matrix44 m_xform;

			AutoRef<ID3D11Device>					mD3DDevice;
			AutoRef<ID3D11DeviceContext>			mD3DContext;
			DXShaderPtr							mShader;
			
			AutoRef<ID3D11RenderTargetView>			mSwapChainView;
			AutoRef<IDXGISwapChain>					mSwapChain;
			DXGI_SWAP_CHAIN_DESC					mSwapDesc;

			AutoRef<ID3D11RasterizerState> mScissorDisable;

			AutoRef<ID3D11RasterizerState> mScissorEnable;
			AutoRef<ID3D11DepthStencilState> mDepthStencilState;

			DXDynamicBuffer  _vertexBuffer;
			DXDynamicBuffer  _indexBuffer;
			DXDynamicBuffer  _uniformBuffer;


		

			std::unordered_map<BlendKey, AutoRef<ID3D11BlendState>, BlendKeyHash> _blend_map;

			std::unordered_map<SamplerKey, AutoRef<ID3D11SamplerState>, SamplerKeyHash> _sampler_map;


			AutoRef<ID3D11BlendState>				mBlendStateDisable;

			TexturePtr								m_whiteTexture;

			TexturePtr m_renderTarget;
			Size2D m_renderTargetSize;
			AutoRef<ID3D11RenderTargetView>			m_renderTargetView;
		};

		class DXTexture : public Texture, public std::enable_shared_from_this<DXTexture>
		{
		public:

			DXContext* _context;

			DXTexture(DXContext* context, std::string name, ID3D11Texture2D* texture)
				: _context(context), m_name(name)
			{
				_texture = texture;
				_texture->GetDesc(&_desc);
			}

			virtual ~DXTexture()
			{
			}


			virtual TexturePtr GetSharedPtr() override
			{
				return shared_from_this();
			}

			virtual const std::string& GetName() override
			{
				return m_name;
			}

			virtual Size2D GetSize() override
			{
				return Size2D(_desc.Width, _desc.Height);
			}

			virtual PixelFormat GetFormat() override
			{
				return ConvertFormat(_desc.Format);
			}


			ID3D11ShaderResourceView* GetShaderResourceView(ID3D11Device* device)
			{
				if (!_shaderView) {
					device->CreateShaderResourceView(_texture, NULL, _shaderView.GetAddressOf());
				}
				return _shaderView;
			}


			ID3D11RenderTargetView* GetRenderTargetView(ID3D11Device* device)
			{
				if (!_renderTargetView)
				{
					//setup the description of the render target view.
					D3D11_RENDER_TARGET_VIEW_DESC renderTargetViewDesc;
					renderTargetViewDesc.Format = _desc.Format;
					renderTargetViewDesc.ViewDimension = D3D11_RTV_DIMENSION_TEXTURE2D;
					renderTargetViewDesc.Texture2D.MipSlice = 0;

					HRESULT hr = device->CreateRenderTargetView(_texture, &renderTargetViewDesc, _renderTargetView.GetAddressOf() );
					if (FAILED(hr))
					{
						return NULL;
					}
				}
				return _renderTargetView;
			}

			
    
		//private:
			std::string m_name;

			AutoRef<ID3D11Texture2D>			_texture;
			AutoRef<ID3D11ShaderResourceView>	_shaderView;
			D3D11_TEXTURE2D_DESC				_desc;
			AutoRef<ID3D11RenderTargetView>		_renderTargetView;

			friend class Context;
		};


		//


		


		



		class DXShaderConstant : public ShaderConstant
		{
		public:
			DXShaderConstant(std::string name, D3D11_SHADER_TYPE_DESC type)
				:m_name(name), m_type(type)
			{
				memset(&m_value, 0, sizeof(m_value));

				_fieldPtr[0] = _fieldPtr[1] = nullptr;
			}

			virtual ~DXShaderConstant() {}

			virtual const std::string& GetName() override
			{
				return m_name;
			}

			/*
			virtual int GetRegister() override
			{
				return 0;
			}*/

			virtual void SetFloat(float f) override
			{
				m_value.f1 = f;
			}


			virtual void SetVector(const Vector4& v) override
			{
				*(Vector4*)&m_value.v4 = v;
			}

			virtual void SetMatrix(const Matrix44& m) override
			{
				*(Matrix44*)&m_value.m44 = m;
			}

#if 1
			void Flush()
			{
				switch (m_type.Class)
				{

				case D3D_SVC_MATRIX_COLUMNS:
				{
					for (int i = 0; i < 2; i++)
					{
						if (_fieldPtr[i]) {
							*(Matrix44*)_fieldPtr[i] = *(Matrix44*)&m_value.m44;
						}
					}
					return;
				}

				case D3D_SVC_MATRIX_ROWS:
				{
					assert(0);
					return;
				}

				case D3D_SVC_VECTOR:
				{
					switch (m_type.Columns)
					{
					case 2:
						for (int i = 0; i < 2; i++)
						{
							float* src = m_value.v4;
							if (_fieldPtr[i]) {
								float* dest = (float*)_fieldPtr[i];
								dest[0] = src[0];
								dest[1] = src[1];
							}
						}
						break;

					case 3:
						for (int i = 0; i < 2; i++)
						{
							float* src = m_value.v4;
							if (_fieldPtr[i]) {
								float* dest = (float*)_fieldPtr[i];
								dest[0] = src[0];
								dest[1] = src[1];
								dest[2] = src[2];
							}
						}
						break;
					case 4:
						for (int i = 0; i < 2; i++)
						{
							if (_fieldPtr[i]) {
								*(Vector4*)_fieldPtr[i] = *(Vector4*)&m_value.v4;
							}
						}
						break;
					default:
						assert(0);
						return;

					}
				}
				return;

				
				case D3D_SVC_SCALAR:
				{
					for (int i = 0; i < 2; i++)
					{
						if (_fieldPtr[i]) {
							*(float*)_fieldPtr[i] = m_value.f1;
						}
					}
					return;
				}

				default:
					assert(0);
					return;
				}

			}
#endif
			std::string m_name;
			D3D11_SHADER_TYPE_DESC m_type;
			void* _fieldPtr[2] = { nullptr };

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
			std::string m_name;
			TexturePtr m_texture;
			SamplerAddress m_addr = SAMPLER_WRAP;
			SamplerFilter m_filter = SAMPLER_LINEAR;
			int _index = 0;

			DXSampler(const char* name, int index)
				:m_name(name), _index(index)
			{
			}

			virtual ~DXSampler()
			{
			}

			virtual const std::string& GetName()
			{
				return m_name;
			}

			int GetRegister()
			{
				return _index;
			}

			virtual void SetTexture(TexturePtr texture, SamplerAddress addr, SamplerFilter filter) override
			{
				m_texture = texture;
				m_addr = addr;
				m_filter = filter;
			}

			void Flush(DXContext* context)
			{
				context->InternalSetTexture(_index, m_texture, m_addr, m_filter);
			}
		};


		using DXSamplerPtr = std::shared_ptr<DXSampler>;


		using DXShaderConstantPtr = std::shared_ptr<DXShaderConstant>;
		


		struct DXShaderBufferFieldDesc
		{
			std::string name;
			int         offset;
			int			size;
			D3D11_SHADER_TYPE_DESC type;

		};


		using DXShaderBufferDescPtr = std::shared_ptr<class DXShaderBufferDesc>;

		const char* GetTypeName(const D3D11_SHADER_TYPE_DESC &type)
		{
			switch (type.Class)
			{
			case D3D_SVC_SCALAR:
				return "float";
			case D3D_SVC_VECTOR:
				return "float4";
			case D3D_SVC_MATRIX_ROWS:
				return "float4x4";
			case D3D_SVC_MATRIX_COLUMNS:
				return "float4x4";

			}
			return type.Name;
		}

		class DXShaderBufferDesc
		{
		public:
			DXShaderBufferDesc(std::string name, int size, int alignment)
				:_name(name), _size(size), _alignment(alignment)
			{

			}

			const std::string _name;
			const int         _alignment;
			const int         _size;

			std::vector<DXShaderBufferFieldDesc>       _fields;
			
			void Dump()
			{
				LogPrint("buffer %s %d %d\n", _name.c_str(), _alignment, _size);
				for (auto& field : _fields)
				{
					LogPrint("\tfield %s %s (%d)\n", GetTypeName(field.type), field.name.c_str(), field.offset);

				}
			}

			void AddField(std::string name, int offset, int size,  D3D11_SHADER_TYPE_DESC type)
			{
				DXShaderBufferFieldDesc field;
				field.name = name;
				field.offset = offset;
				field.size = size;
				field.type = type;

				_fields.push_back(field);
			}

			
			static DXShaderBufferDescPtr CreateFromReflection(ID3D11ShaderReflectionConstantBuffer *cb)
			{
				D3D11_SHADER_BUFFER_DESC desc;
				cb->GetDesc(&desc);


				DXShaderBufferDescPtr bd = std::make_shared<DXShaderBufferDesc>(
					desc.Name,
					(int)desc.Size,
					(int)16
					);

				for (int i = 0; i < (int)desc.Variables; i++)
				{
					ID3D11ShaderReflectionVariable * cv = cb->GetVariableByIndex(i);
					D3D11_SHADER_VARIABLE_DESC vdesc;
					cv->GetDesc(&vdesc);

					D3D11_SHADER_TYPE_DESC tdesc;
					auto *type = cv->GetType();
					type->GetDesc(&tdesc);
					
					if (vdesc.TextureSize == 0)
					{
						bd->AddField(vdesc.Name, (int)vdesc.StartOffset, (int)vdesc.Size, tdesc);
					}
					else
					{

						assert(0);
					}

				}
				return bd;
			}
			
		};


		using DXShaderBufferPtr = std::shared_ptr<class DXShaderBuffer>;

		class DXShaderBuffer
		{
		public:
			DXShaderBuffer(DXShaderBufferDescPtr desc, int index, ID3D11Buffer* buffer)
				:_desc(desc), _index(index), _alignment(desc->_alignment), _buffer(buffer)
			{
				_data.resize(desc->_size);
			}

			virtual ~DXShaderBuffer()
			{
			}

			uint8_t* GetFieldPtr(int offset, int size)
			{
				assert((offset + size) <= _data.size());
				return &_data[offset];
			}

			void Flush(DXContext* context)
			{
#if 0
				context->mD3DContext->UpdateSubresource(
					_buffer,
					0,
					NULL,
					_data.data(),
					_data.size(),
					_data.size()
				);

#else
				// set vertex constants
				D3D11_MAPPED_SUBRESOURCE map;
				HRESULT hr = context->mD3DContext->Map(_buffer, 0, D3D11_MAP_WRITE_DISCARD, 0, &map);
				if (FAILED(hr))
					return;

				memcpy(map.pData, _data.data(), _data.size());

				context->mD3DContext->Unmap(_buffer, 0);
#endif
			}


			bool                                _vertex;
			DXShaderBufferDescPtr            _desc;
			std::vector<uint8_t>                           _data;
			int                           _alignment;

			AutoRef<ID3D11Buffer> _buffer;


			int                                 _index;
			std::vector<DXShaderConstantPtr> _constants;


		};


		class DXShader : public Shader
		{

			
		public:

			DXShader(DXContext* context, std::string name)
				:_context(context), _name(name), _linked(false)
			{

			}

			virtual ~DXShader() {

			}

			class CompilerInclude : public ID3DInclude
			{
			public:

				CompilerInclude(std::string path)
					:m_path(path) {}

				HRESULT __stdcall Open(D3D_INCLUDE_TYPE IncludeType, LPCSTR pFileName, LPCVOID pParentData, LPCVOID* ppData, UINT* pBytes) override
				{
					std::string root = PathGetDirectory(m_path);
					std::string path = PathCombine(root, pFileName);

					*ppData = NULL;
					*pBytes = 0;

					std::string output;
					if (!FileReadAllText(path, output)) {
						return -1;
					}

					*ppData = strdup(output.c_str());
					*pBytes = (UINT)output.size();
					return S_OK;

				}

				HRESULT __stdcall Close(LPCVOID pData) override
				{
					free((void*)pData);
					return S_OK;
				}


				std::string m_path;


			};


			ID3DBlob* CompileShaderSource(const ShaderSource& source)
			{
				//LogPrint("Compiling shader %s %s %s", path.c_str(), profile, entry);

				// Create the effect
				DWORD dwShaderFlags = 0;
				//        dwShaderFlags |= D3DCOMPILE_ENABLE_STRICTNESS;
				if (true)
				{
					dwShaderFlags |= D3DCOMPILE_DEBUG;
				}

				dwShaderFlags |= D3DCOMPILE_ENABLE_BACKWARDS_COMPATIBILITY;


				const D3D_SHADER_MACRO defines[] =
				{
					"HLSL_4", "1",
					NULL, NULL
				};


				std::string profile =  source.IsVertex() ? "vs_4_0" : "ps_4_0";

				//        LogPrint("%s\n", text.c_str());


						//std::wstring wpath = Core::String::Convert(path.c_str());

				std::string path = source.path;
				CompilerInclude include(path);

				ID3DBlob* pBlob = NULL;
				ID3DBlob* pErrorBlob = NULL;
				//HRESULT hr = D3DCompileFromFile(wpath.c_str(), NULL, include, entry, profile, dwShaderFlags, 0, &pBlob, &pErrorBlob);
		//        HRESULT hr = D3DX11CompileFromFile(path.c_str(), NULL, include, entry, profile, dwShaderFlags, 0, NULL, &pBlob, &pErrorBlob, NULL);
				HRESULT hr = D3DCompile(source.code.c_str(), source.code.size(), path.c_str(), defines, &include, source.functionName.c_str(), profile.c_str(), dwShaderFlags, 0, &pBlob, &pErrorBlob);
				if (FAILED(hr))
				{
					if (pErrorBlob)
					{
						m_errors = (const char*)pErrorBlob->GetBufferPointer();
						//				LogError("%s", mErrors.c_str());
						pErrorBlob->Release();
					}

					LogError("Could not compile shader with profile %s\n%s\n%s", source.profile.c_str(),
						m_errors.c_str(), source.code.c_str());

					return nullptr;
				}

				return pBlob;
			}


			AutoRef< ID3DBlob > mVertexShaderBlob;

			AutoRef< ID3DBlob > mPixelShaderBlob;
			AutoRef< ID3D11VertexShader > mVertexShader;
			AutoRef< ID3D11PixelShader > mPixelShader;
			AutoRef< ID3D11InputLayout > mVertexLayout;


			std::vector<DXShaderBufferPtr> _buffers;





			std::vector<ID3D11Buffer *> _dx_pixel_buffers;
			std::vector<ID3D11Buffer *> _dx_vertex_buffers;

			ShaderConstantPtr m_constant_xform_position;

			ShaderSource _vertexSource;
			ShaderSource _pixelSource;

			virtual bool Compile(const ShaderSource& source) override
			{
				ID3DBlob* blob = CompileShaderSource(source);
				if (!blob) {
					return false;
				}

				if (source.IsVertex())
				{
					mVertexShaderBlob = blob;
					_vertexSource = source;
				}
				else if (source.IsFragment())
				{
					mPixelShaderBlob = blob;
					_pixelSource = source;
				}

		
				return true;
			}



			virtual bool Link() override
			{


				ReflectShader(mVertexShaderBlob, _buffers, _dx_vertex_buffers);

				ReflectShader(mPixelShaderBlob, _buffers, _dx_pixel_buffers);

				

				{
					ID3D11PixelShader* pshader;
					HRESULT hr = _context->mD3DDevice->CreatePixelShader(mPixelShaderBlob->GetBufferPointer(), mPixelShaderBlob->GetBufferSize(), NULL, mPixelShader.GetAddressOf());
					if (FAILED(hr))
						return false;
					 

				}


				{
					HRESULT hr = _context->mD3DDevice->CreateVertexShader(mVertexShaderBlob->GetBufferPointer(), mVertexShaderBlob->GetBufferSize(), NULL, mVertexShader.GetAddressOf());
					if (FAILED(hr))
						return false;

					hr = _context->mD3DDevice->CreateInputLayout(sVertexLayout, ARRAYSIZE(sVertexLayout), mVertexShaderBlob->GetBufferPointer(), mVertexShaderBlob->GetBufferSize(), mVertexLayout.GetAddressOf() );
					if (FAILED(hr))
						return false;
				}


				m_constant_xform_position = Shader::GetConstant("xform_position");
				return true;
			}




			void AddShaderConstants(DXShaderBufferPtr buffer)
			{
				for (const auto& field : buffer->_desc->_fields)
				{
					DXShaderConstantPtr constant;

					auto it = m_constant_map.find(field.name);
					if (it == m_constant_map.end()) {
						constant = std::make_shared<DXShaderConstant>(field.name, field.type);
						m_constant_map[field.name] = constant;
						m_constants.push_back(constant);
					}
					else {
						constant = it->second;
						/*
						if (constant->m_type != field.type) {
							assert(0);
							continue;
						}
						*/
					}

					buffer->_constants.push_back(constant);


					// bind constant to buffer
					uint8_t* fieldPtr = buffer->GetFieldPtr(field.offset, field.size);

					for (int i = 0; i < 2; i++) {
						if (!constant->_fieldPtr[i]) {
							constant->_fieldPtr[i] = fieldPtr;
							break;
						}
					}

				}

			}



			void ReflectShader(ID3DBlob* pBlob, std::vector<DXShaderBufferPtr> & buffers, std::vector<ID3D11Buffer *>& dxbuffers)
			{
				ID3D11ShaderReflection* pReflector = NULL;
				D3DReflect(pBlob->GetBufferPointer(), pBlob->GetBufferSize(), IID_ID3D11ShaderReflection, (void**)&pReflector);
				if (!pReflector)
					return;

				D3D11_SHADER_DESC sd;
				pReflector->GetDesc(&sd);

				for (int i = 0; i < (int)sd.BoundResources; i++)
				{
					D3D11_SHADER_INPUT_BIND_DESC desc;
					pReflector->GetResourceBindingDesc(i, &desc);

					if (desc.Type == D3D_SIT_TEXTURE)
					{
						DXSamplerPtr sampler = std::make_shared<DXSampler>(desc.Name, desc.BindPoint);
						m_samplers.push_back(sampler);
					}
					else if (desc.Type == D3D_SIT_SAMPLER)
					{
			

					}


				}
				for (int i = 0; i < (int)sd.ConstantBuffers; i++)
				{
					ID3D11ShaderReflectionConstantBuffer* cb = pReflector->GetConstantBufferByIndex(i);

					DXShaderBufferDescPtr bd = DXShaderBufferDesc::CreateFromReflection(cb);
					//bd->Dump();

					
					// Setup constant buffers
					D3D11_BUFFER_DESC Desc;
					Desc.Usage = D3D11_USAGE_DYNAMIC;
					Desc.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
					Desc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
					Desc.MiscFlags = 0;
					Desc.ByteWidth = bd->_size;
					ID3D11Buffer* dxbuffer = nullptr;
					HRESULT hr = _context->mD3DDevice->CreateBuffer(&Desc, NULL, &dxbuffer);
					

					DXShaderBufferPtr buffer  = std::make_shared<DXShaderBuffer>(bd, i, dxbuffer);
					AddShaderConstants(buffer);

					buffers.push_back(buffer);

					dxbuffers.push_back(dxbuffer);

				}

			}



			virtual std::string GetErrors()
			{
				return m_errors;
			}


			virtual int			GetSamplerCount()
			{
				return (int)m_samplers.size();
			}

			virtual ShaderSamplerPtr   GetSampler(int index)
			{
				if (index >= (int)m_samplers.size())
					return nullptr;

				ShaderSamplerPtr sampler = m_samplers[index];
				return sampler;
			}

			virtual int			GetConstantCount()
			{
				return (int)m_constants.size();
			}

			virtual ShaderConstantPtr	GetConstant(int index)
			{
				if (index >= (int)m_constants.size())
					return nullptr;
				return m_constants[index];
			}


			virtual void Flush(DXContext* context)
			{
				// TODO:

				auto mD3DContext = context->mD3DContext;


				if (m_constant_xform_position)
				{
					const Matrix44& xform = context->GetTransform();
					m_constant_xform_position->SetMatrix(xform);
				}


				for (auto c : m_constants)
				{
					c->Flush();

				}

				for (auto buffer : _buffers)
				{
					buffer->Flush(context);
				}



				// set current shader
				mD3DContext->VSSetShader(mVertexShader, NULL, 0);
				mD3DContext->PSSetShader(mPixelShader, NULL, 0);

				// Set the input layout
				mD3DContext->IASetInputLayout(mVertexLayout);


				// set constant buffer resources
				mD3DContext->VSSetConstantBuffers(0, (UINT)_dx_vertex_buffers.size(), _dx_vertex_buffers.data() );	
				mD3DContext->PSSetConstantBuffers(0, (UINT)_dx_pixel_buffers.size(), _dx_pixel_buffers.data() );


				for (auto sampler : m_samplers)
				{
					sampler->Flush(context);

				}
				// set  texture resources
			//	ID3D11ShaderResourceView* resources[1] = { mTexture[0]->GetShaderResourceView() };
			//	mD3DContext->PSSetShaderResources(0, 1, resources);

			//	ID3D11SamplerState* samplers[1] = { context->mSamplerStates[0] };
			//	mD3DContext->PSSetSamplers(0, 1, samplers);


			}


			DXContext* _context;
			std::string _name;
			bool _linked = false;
			std::vector< DXSamplerPtr > m_samplers;
			std::vector< DXShaderConstantPtr > m_constants;
			std::unordered_map<std::string, DXShaderConstantPtr > m_constant_map;

			std::string m_errors;
		};



		//
		// Device creator
		//

		ContextPtr D3D11CreateContext(HWND hWnd)
		{
			bool debugEnabled = false;
			RECT rc;
			GetClientRect(hWnd, &rc);
			UINT width = rc.right - rc.left;
			UINT height = rc.bottom - rc.top;

			UINT createDeviceFlags = 0;
			if (debugEnabled)
			{
				createDeviceFlags |= D3D11_CREATE_DEVICE_DEBUG;
			}

			D3D_FEATURE_LEVEL featureLevels[] =
			{
				D3D_FEATURE_LEVEL_11_1,
				D3D_FEATURE_LEVEL_11_0,
				D3D_FEATURE_LEVEL_10_1,
				D3D_FEATURE_LEVEL_10_0,
			};
			UINT numFeatureLevels = ARRAYSIZE(featureLevels);
			D3D_FEATURE_LEVEL mFeatureLevel = D3D_FEATURE_LEVEL_11_1;

			DXGI_SWAP_CHAIN_DESC sd;
			ZeroMemory(&sd, sizeof(sd));
			sd.BufferCount = 1;
			sd.BufferDesc.Width = width;
			sd.BufferDesc.Height = height;
			sd.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
			sd.BufferDesc.RefreshRate.Numerator = 60;
			sd.BufferDesc.RefreshRate.Denominator = 1;
			sd.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
			sd.OutputWindow = hWnd;
			sd.SampleDesc.Count = 1;
			sd.SampleDesc.Quality = 0;
			sd.Windowed = true;

			ID3D11DeviceContext* pContext = NULL;
			ID3D11Device* pDevice = NULL;
			IDXGISwapChain* pSwapChain = NULL;
			HRESULT hr = D3D11CreateDeviceAndSwapChain(NULL, D3D_DRIVER_TYPE_HARDWARE, NULL, createDeviceFlags, featureLevels, numFeatureLevels,
				D3D11_SDK_VERSION, &sd, &pSwapChain, &pDevice, &mFeatureLevel, &pContext);
			if (FAILED(hr))
				return NULL;

			// create device
			std::shared_ptr<DXContext> context = std::make_shared<DXContext>(pDevice, pContext, pSwapChain);
			if (!context->Init())
			{
				return nullptr;
			}

			context->BeginScene();
			context->EndScene();

			return context;
		}


		TexturePtr DXContext::CreateTextureFromFile(const char* name, const char* path)
		{
			//D3DX11_IMAGE_LOAD_INFO loadInfo;
			ID3D11Resource* pResource;
			HRESULT hr = D3DX11CreateTextureFromFile(
				mD3DDevice, path, NULL, NULL, &pResource, NULL);
			if (FAILED(hr))
			{
				return NULL;
			}

			// query texture from resource
			ID3D11Texture2D* pD3DTexture = NULL;
			pResource->QueryInterface(__uuidof(ID3D11Texture2D), (LPVOID*)&pD3DTexture);
			pResource->Release();
			if (pD3DTexture == NULL)
			{
				return NULL;
			}

			return std::make_shared<DXTexture>(this, name, pD3DTexture);
		}

		TexturePtr DXContext::CreateRenderTarget(const char* name, int width, int height, PixelFormat format)
		{
			D3D11_TEXTURE2D_DESC desc = { 0 };
			desc.Width = width;
			desc.Height = height;
			desc.MipLevels = 1;
			desc.ArraySize = 1;
			desc.Format = ConvertFormat(format);
			desc.SampleDesc.Count = 1;
			desc.SampleDesc.Quality = 0;
			desc.Usage = D3D11_USAGE_DEFAULT;
			desc.BindFlags = D3D11_BIND_SHADER_RESOURCE | D3D11_BIND_RENDER_TARGET;
			desc.CPUAccessFlags = 0;
			desc.MiscFlags = 0;

			ID3D11Texture2D* pD3DTexture = NULL;
			HRESULT hr = mD3DDevice->CreateTexture2D(&desc, NULL, &pD3DTexture);
			if (FAILED(hr))
			{
				return NULL;
			}

			return std::make_shared<DXTexture>(this, name, pD3DTexture);

		}
		TexturePtr DXContext::CreateTexture(const char* name, int width, int height, PixelFormat format, const uint32_t* data)
		{
			D3D11_TEXTURE2D_DESC desc = { 0 };
			desc.Width = width;
			desc.Height = height;
			desc.MipLevels = 1;
			desc.ArraySize = 1;
			desc.Format = ConvertFormat(format);
			desc.SampleDesc.Count = 1;
			desc.SampleDesc.Quality = 0;
			desc.Usage = D3D11_USAGE_IMMUTABLE;
			desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
			desc.CPUAccessFlags = 0;
			desc.MiscFlags = 0;

			D3D11_SUBRESOURCE_DATA rd;
			rd.pSysMem = data;
			rd.SysMemPitch = width * PixelFormatGetPixelSize(format);
			rd.SysMemSlicePitch = rd.SysMemPitch * height;


			ID3D11Texture2D* pD3DTexture = NULL;
			HRESULT hr = mD3DDevice->CreateTexture2D(&desc, &rd, &pD3DTexture);
			if (FAILED(hr))
			{
				return NULL;
			}

			return std::make_shared<DXTexture>(this, name, pD3DTexture);

		}



		static ImageDataPtr GetImageData(ID3D11DeviceContext *context, ID3D11Texture2D* texture)
		{
			D3D11_TEXTURE2D_DESC desc;
			texture->GetDesc(&desc);

			// set vertex constants
			D3D11_MAPPED_SUBRESOURCE map;
			HRESULT hr = context->Map(texture, 0, D3D11_MAP_READ, 0, &map);
			if (FAILED(hr)) {
				return nullptr;
			}

			// swap BGRA -> RGBA 
//			bool swapPixel = false;
			auto format = ConvertFormat(desc.Format);
//			if (format == PixelFormat::BGRA8Unorm) {
//				format = PixelFormat::RGBA8Unorm;
//				swapPixel = true;
//			}

			ImageDataPtr image = std::make_shared<ImageData>( (int)desc.Width, (int)desc.Height, format );

			for (int y = 0; y < image->height; y++)
			{
				const uint8_t* src_line = (((const uint8_t*)map.pData) + y * map.RowPitch);
				uint8_t* dest_line = (((uint8_t*)image->data) + y * image->pitch);


//				if (!swapPixel)
					memcpy(dest_line, src_line, image->pitch);
//				else
//					CopyPixelsSwap(dest_line, src_line, image->width);
			}
			context->Unmap(texture, 0);

			return image;
		}


		void DXContext::GetImageDataAsync(TexturePtr texture, std::function<void(ImageDataPtr)> callback) 
		{
			if (!texture) {
				callback(nullptr);
				return;
			}

			DXTexturePtr t = std::static_pointer_cast<DXTexture>(texture);


			ID3D11Texture2D* dxtexture = t->_texture;

			D3D11_TEXTURE2D_DESC desc;
			dxtexture->GetDesc(&desc);
			desc.Usage = D3D11_USAGE_STAGING;
			desc.BindFlags = 0;
			desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
			desc.MiscFlags = 0;


			AutoRef<ID3D11Texture2D> stagingTexture;
			HRESULT hr = mD3DDevice->CreateTexture2D(&desc, nullptr, stagingTexture.GetAddressOf() );
			if (FAILED(hr)) {
				callback(nullptr);
				return;
			}


			// copy the texture to a staging resource
			mD3DContext->CopyResource(stagingTexture, dxtexture);

			ImageDataPtr image = GetImageData(mD3DContext, stagingTexture);
			if (!image) {
				callback(nullptr);
				return;
			}

			callback(image);
		}


		ShaderPtr DXContext::CreateShader(const char* name)
		{
			return std::make_shared<DXShader>(this, name);
		}


		DXContext::DXContext(ID3D11Device* device, ID3D11DeviceContext* pDeviceContext, IDXGISwapChain* chain)
			: mD3DDevice(device), mSwapChain(chain),
			_vertexBuffer(D3D11_BIND_VERTEX_BUFFER),
			_indexBuffer(D3D11_BIND_INDEX_BUFFER),
			_uniformBuffer(D3D11_BIND_CONSTANT_BUFFER)

		{


		
			m_driver = "D3D11";
			m_description = "D3D11";

			ID3D11DeviceContext* context;
			mD3DDevice->GetImmediateContext(&context);
			mD3DContext = context;

			// get desc for swap chain
			mSwapChain->GetDesc(&mSwapDesc);

		}

		DXContext::~DXContext()
		{
			mD3DContext->ClearState();
		}


		static D3D_PRIMITIVE_TOPOLOGY  ConvertPrimType(PrimitiveType primType)
		{
			switch (primType)
			{
			case PRIMTYPE_POINTLIST:
				return D3D_PRIMITIVE_TOPOLOGY_POINTLIST;
			case PRIMTYPE_LINELIST:
				return D3D_PRIMITIVE_TOPOLOGY_LINELIST;
			case PRIMTYPE_LINESTRIP:
				return D3D_PRIMITIVE_TOPOLOGY_LINESTRIP;
			case PRIMTYPE_TRIANGLELIST:
				return D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST;
			case PRIMTYPE_TRIANGLESTRIP:
				return D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP;
			case PRIMTYPE_TRIANGLEFAN:
			default:
				assert(0);
				return D3D_PRIMITIVE_TOPOLOGY_UNDEFINED;
			};
		}


		void DXContext::DrawArrays(PrimitiveType primType, int start, int count) 
		{
			if (!mShader)
				return;

			if (primType == PRIMTYPE_TRIANGLEFAN)
			{
				const int MAX_COUNT = 1024;
				int primCount = count - 2;
				// draw triangle fan as indexed triangles
				IndexType index_data[MAX_COUNT];
				assert(primCount * 3 < MAX_COUNT);

				int index_count = 0;
				for (int i = 0; i < primCount; i++)
				{
					index_data[index_count++] = 0;
					index_data[index_count++] = i + 2;
					index_data[index_count++] = i + 1;
				}
				UploadIndexData(index_count, index_data);
				DrawIndexed(PRIMTYPE_TRIANGLELIST, 0, index_count);
				return;
			}


			mShader->Flush(this);

#if 1
			UINT strides[] = { (UINT)_vertexBuffer.GetStride() };
			UINT offsets[] = { (UINT)_vertexBuffer.GetBase() };
			ID3D11Buffer* buffers[] = { _vertexBuffer.GetBuffer() };
			mD3DContext->IASetVertexBuffers(0, 1, buffers, strides, offsets);

			// Set primitive topology
			mD3DContext->IASetPrimitiveTopology(ConvertPrimType(primType));


			mD3DContext->Draw(count, start);
#endif
		}


		void DXContext::DrawIndexed(PrimitiveType primType, int indexOffset, int indexCount) 
		{

			if (!mShader)
				return;

			mShader->Flush(this);

#if 1
			UINT strides[] = { (UINT)_vertexBuffer.GetStride() };
			UINT offsets[] = { (UINT)_vertexBuffer.GetBase() };
			ID3D11Buffer* buffers[] = { _vertexBuffer.GetBuffer() };
			mD3DContext->IASetVertexBuffers(0, 1, buffers, strides, offsets);

			// set index buffer
			mD3DContext->IASetIndexBuffer(_indexBuffer.GetBuffer(), sizeof(IndexType) == 4 ?  DXGI_FORMAT_R32_UINT : DXGI_FORMAT_R16_UINT, (UINT)_indexBuffer.GetBase());

			// Set primitive topology
			mD3DContext->IASetPrimitiveTopology(ConvertPrimType(primType));

			mD3DContext->DrawIndexed(indexCount, indexOffset, 0);
#endif
		}



		bool DXContext::Init()
		{

			if (!m_whiteTexture) {
				uint32_t white[32 * 32];
				for (int i = 0; i < 32 * 32; i++)
					white[i] = 0xFFFFFFFF;
				m_whiteTexture = CreateTexture("white", 32, 32, PixelFormat::BGRA8Unorm, &white[0]);
			}



			// Create the rasterizer state
			{
				D3D11_RASTERIZER_DESC desc = {  };
				desc.FillMode = D3D11_FILL_SOLID;
				desc.CullMode = D3D11_CULL_NONE;
				desc.ScissorEnable = false;
				desc.DepthClipEnable = false;
				mD3DDevice->CreateRasterizerState(&desc, mScissorDisable.GetAddressOf() );

				desc.ScissorEnable = true;
				desc.DepthClipEnable = false;
				mD3DDevice->CreateRasterizerState(&desc, mScissorEnable.GetAddressOf());
			}

			// Create depth-stencil State
			{
				D3D11_DEPTH_STENCIL_DESC desc = {  };
				desc.DepthEnable = false;
				desc.DepthWriteMask = D3D11_DEPTH_WRITE_MASK_ALL;
				desc.DepthFunc = D3D11_COMPARISON_ALWAYS;
				desc.StencilEnable = false;
				desc.FrontFace.StencilFailOp = 
				desc.FrontFace.StencilDepthFailOp = 
				desc.FrontFace.StencilPassOp = D3D11_STENCIL_OP_KEEP;
				desc.FrontFace.StencilFunc = D3D11_COMPARISON_ALWAYS;
				desc.BackFace = desc.FrontFace;
				mD3DDevice->CreateDepthStencilState(&desc, mDepthStencilState.GetAddressOf() );
			}


			_vertexBuffer.ResizeBuffer(mD3DDevice, 64 * 1024);
			_indexBuffer.ResizeBuffer(mD3DDevice, 64 * 1024);
			_uniformBuffer.ResizeBuffer(mD3DDevice, 64 * 1024);
			return true;
		}


		void DXContext::Present()
		{
			PROFILE_FUNCTION()

			Flush();

			UINT syncInterval = 1;
			UINT flags = 0;
			mSwapChain->Present(syncInterval, flags);
		}



		void DXContext::SetRenderTarget(TexturePtr texture, const char* passName, LoadAction action, Color4F clearColor)

		{
			ID3D11RenderTargetView* view;

			if (!texture)
			{
				m_renderTarget = nullptr;
				m_renderTargetSize = m_displayInfo.size;
				view = mSwapChainView;
			}
			else
			{
				DXTexturePtr t = std::static_pointer_cast<DXTexture>(texture);
				m_renderTarget = t;
				m_renderTargetSize = t->GetSize();
				view = t->GetRenderTargetView(mD3DDevice);
			}

			// set views
			ID3D11RenderTargetView* views[1] = { view };
			mD3DContext->OMSetRenderTargets(1, views, NULL);

			SetViewport(0, 0, m_renderTargetSize.width, m_renderTargetSize.height);
			SetScissorDisable();


			if (action != LoadAction::Load) {
				float color[4] = { clearColor.r, clearColor.g, clearColor.b, clearColor.a };
				mD3DContext->ClearRenderTargetView(view, color);
			}
		}



		void  DXContext::BeginScene()
		{
			PROFILE_FUNCTION()

			// clear all device state
			mD3DContext->ClearState();


			// get desc for swap chain
			mSwapChain->GetDesc(&mSwapDesc);

			// get size of output window
			RECT rc;
			GetClientRect(mSwapDesc.OutputWindow, &rc);
			UINT width = rc.right - rc.left;
			UINT height = rc.bottom - rc.top;

			// do we need to resize swap chain?
			if (mSwapDesc.BufferDesc.Width != width || mSwapDesc.BufferDesc.Height != height)
			{
				ID3D11RenderTargetView* views[1] = { nullptr };
				mD3DContext->OMSetRenderTargets(1, views, NULL);

				mSwapChainView = NULL;
				//mRenderTarget = NULL;

				// resize swap chain
				HRESULT hr = mSwapChain->ResizeBuffers(mSwapDesc.BufferCount, width, height, mSwapDesc.BufferDesc.Format, mSwapDesc.Flags);
				if (FAILED(hr))
				{
					assert(0);
					return;
				}


				// get desc for swap chain
				mSwapChain->GetDesc(&mSwapDesc);
			}


			{
				// Create a render target view
				ID3D11Texture2D* pBuffer;
				HRESULT hr = mSwapChain->GetBuffer(0, __uuidof(ID3D11Texture2D), (LPVOID*)&pBuffer);
				if (FAILED(hr)) return;

				ID3D11RenderTargetView* pRenderTargetView;
				hr = mD3DDevice->CreateRenderTargetView(pBuffer, NULL, &pRenderTargetView);
				if (FAILED(hr)) return;
				mSwapChainView = pRenderTargetView;
				pRenderTargetView->Release();
				pBuffer->Release();
			}







			SetShader(NULL);
			SetRenderTarget(NULL);
			SetBlendDisable();
			SetScissorDisable();

			mD3DContext->OMSetDepthStencilState(mDepthStencilState, 0);


			UINT dpi = GetDpiForWindow(mSwapDesc.OutputWindow);
			float scale = ((float)dpi) / ((float)USER_DEFAULT_SCREEN_DPI);


			DisplayInfo info{
			.size = Size2D(mSwapDesc.BufferDesc.Width, mSwapDesc.BufferDesc.Height),
			.format = ConvertFormat(mSwapDesc.BufferDesc.Format),
			.refreshRate = (float)mSwapDesc.BufferDesc.RefreshRate.Numerator / (float)mSwapDesc.BufferDesc.RefreshRate.Denominator,
			.scale = scale,
			.samples = 1,
			.maxEDR = 1.0f
			};

			SetDisplayInfo(info);
		}

		void  DXContext::EndScene()
		{
			PROFILE_FUNCTION()
			Flush();
		}

		ID3D11SamplerState* DXContext::GetSamplerState(SamplerAddress address, SamplerFilter filter)
		{
			SamplerKey key{ address, filter };

			auto it = _sampler_map.find(key);
			if (it != _sampler_map.end())
			{
				return it->second;
			}

			// Create a sampler state
			D3D11_SAMPLER_DESC desc = {};
			
			switch (filter)
			{
			case SAMPLER_POINT:
				desc.Filter = D3D11_FILTER_MIN_MAG_MIP_POINT;
				break;
			case SAMPLER_LINEAR:
				desc.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
				break;
			case SAMPLER_ANISOTROPIC:
				desc.Filter = D3D11_FILTER_ANISOTROPIC;
				break;
			default:
				assert(0);
				break;
			}


			switch (address)
			{
			case SAMPLER_WRAP:
				desc.AddressU =
					desc.AddressV =
					desc.AddressW = D3D11_TEXTURE_ADDRESS_WRAP;
				break;

			case SAMPLER_CLAMP:
				desc.AddressU =
					desc.AddressV =
					desc.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
				break;
			default:
				assert(0);
				break;
			}

			desc.MipLODBias = 0.0f;
			desc.MaxAnisotropy = 1;
			desc.ComparisonFunc = D3D11_COMPARISON_ALWAYS;
			desc.BorderColor[0] = desc.BorderColor[1] = desc.BorderColor[2] = desc.BorderColor[3] = 0;
			desc.MinLOD = 0;
			desc.MaxLOD = D3D11_FLOAT32_MAX;

			ID3D11SamplerState* state;
			mD3DDevice->CreateSamplerState(&desc, &state);
			_sampler_map[key] = state;
			return state;
		}

		void DXContext::InternalSetTexture(int index, TexturePtr texture, SamplerAddress address, SamplerFilter filter)
		{
			if (!texture)
			{
				// use white texture....
				texture = m_whiteTexture;
			}

			DXTexturePtr t = std::static_pointer_cast<DXTexture>(texture);

			ID3D11ShaderResourceView* resources[1] = { t->GetShaderResourceView(mD3DDevice) };
			mD3DContext->PSSetShaderResources(index, 1, resources);


			ID3D11SamplerState* sampler_state = GetSamplerState(address, filter);
			ID3D11SamplerState* samplers[1] = { sampler_state };
			mD3DContext->PSSetSamplers(index, 1, samplers);
		}

		void DXContext::SetShader(ShaderPtr shader)
		{
			mShader = std::static_pointer_cast<DXShader>(shader);
			
		}


	} // namespace d3d11
} // namespace render


#endif
