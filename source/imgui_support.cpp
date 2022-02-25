
#include <stdio.h>
#include <stdint.h>
#include <vector>

#include "imgui_support.h"
#include "render/context.h"
#include "Core/Path.h"
#include "Core/StopWatch.h"
#include "Core/File.h"

namespace ImGui
{

    class ImGuiRendererBase
    {
    public:
        ImGuiRendererBase() = default;
        virtual ~ImGuiRendererBase() = default;
        
        virtual const char *GetName() = 0;
        
        virtual ImTextureID CreateTexture(int width, int height, const uint32_t *data) = 0;

        virtual ImVec2 GetDisplaySize() = 0;
        virtual ImVec2 GetFramebufferScale() = 0;
        
        virtual void BeginRender(ImVec2 DisplayPos, ImVec2 DisplaySize, ImVec2 FramebufferScale ) = 0;
        virtual void EndRender() = 0;
        virtual void ResetRenderState() = 0;

        virtual void SetScissorRect( ImVec4 clip_rect ) = 0;
        virtual void SetTexture( ImTextureID texture ) = 0;
        virtual void UploadVertexData(int count, const ImDrawVert *data) = 0;
        virtual void UploadIndexData(int count,  const ImDrawIdx *data) = 0;
        virtual void DrawIndexed(int offset, int count) = 0;
    };


}


namespace render {
template <>
int GetVertexTypeID<ImDrawVert>()
{
    return 1;
}
}


class ImGuiRendererContext : public ImGui::ImGuiRendererBase
{
protected:
    render::ContextPtr _context;
    render::ShaderPtr _shader;
    std::vector<render::TexturePtr> _textures;
    
public:
    
    
    ImGuiRendererContext(render::ContextPtr context, render::ShaderPtr shader)
        :_context(context), _shader(shader)
    {
        
        using namespace render;
        
        _context->SetVertexDescriptor<ImDrawVert>(
             render::VertexDescriptor
             {
                 sizeof(ImDrawVert),
                 {
                     { 0,  VertexFormat::Float2,             offsetof(ImDrawVert, pos) },
                     { 1,  VertexFormat::UChar4Normalized,   offsetof(ImDrawVert, col) },
                     { 2,  VertexFormat::Float2,             offsetof(ImDrawVert, uv)  },
                 }
             }
         );
    }
    
    virtual const char *GetName() override
    {
        return "imgui_renderer_context";
    }

    
    virtual ImVec2 GetDisplaySize() override
    {
        auto sz = _context->GetDisplaySize();
        return ImVec2(sz.width, sz.height);
    }
    virtual ImVec2 GetFramebufferScale()  override
    {
        auto scale = _context->GetDisplayScale();
        return ImVec2(scale, scale);
    }
    
    virtual ImTextureID CreateTexture(int width, int height, const uint32_t *data) override
    {
        render::TexturePtr tex = _context->CreateTexture("imgui", width, height, render::PixelFormat::RGBA8Unorm, data);
        _textures.push_back(tex);
        
        // Store our identifier
        return tex.get();
    }

    
    virtual void BeginRender(ImVec2 DisplayPos, ImVec2 DisplaySize, ImVec2 FramebufferScale )  override
    {
        // Avoid rendering when minimized, scale coordinates for retina displays (screen coordinates != framebuffer coordinates)
        int fb_width = (int)(DisplaySize.x * FramebufferScale.x);
        int fb_height = (int)(DisplaySize.y * FramebufferScale.y);
        
        // setup viewport
        _context->SetViewport(0, 0, fb_width, fb_height);
        _context->SetBlend(render::BLEND_SRCALPHA, render::BLEND_INVSRCALPHA);
        
        float L = DisplayPos.x;
        float T = DisplayPos.y;
        float R = L + DisplaySize.x;
        float B = T + DisplaySize.y;

        Matrix44 ortho_projection = Matrix44::OrthoLH(L, R, B, T, 0, 1.0f);
        _context->SetTransform(ortho_projection);
        _context->SetShader( _shader );
    }
    
    virtual void EndRender()  override
    {
        _context->SetScissorDisable();
    }
    
    virtual void ResetRenderState() override
    {
        
    }

    virtual void SetScissorRect( ImVec4 clip_rect )  override
    {
        _context->SetScissorRect(
                                (int)clip_rect.x,
                                (int)clip_rect.y,
                                (int)(clip_rect.z - clip_rect.x),
                                (int)(clip_rect.w - clip_rect.y)
                                );
        
    }
    virtual void SetTexture( ImTextureID texture ) override
    {
        auto sampler = _shader->GetSampler(0);
        render::TexturePtr tex = texture ? texture->GetSharedPtr() : nullptr;
        if (sampler)
            sampler->SetTexture( tex, render::SAMPLER_WRAP, render::SAMPLER_LINEAR);
    }
    
    virtual void UploadVertexData(int count, const ImDrawVert *data) override
    {
        _context->UploadVertexData(count, data);
    }
    virtual void UploadIndexData(int count,  const ImDrawIdx *data) override
    {
        _context->UploadIndexData(count, sizeof(*data), data);
    }
    virtual void DrawIndexed(int offset, int count) override
    {
        _context->DrawIndexed(render::PrimitiveType::PRIMTYPE_TRIANGLELIST, offset, count);
    }
};

void   ImGuiRenderInit(ImGui::ImGuiRendererBase *renderer)
{
    // Setup back-end capabilities flags
    ImGuiIO& io = ImGui::GetIO();
    io.BackendRendererName = renderer->GetName();
    
    // Build texture atlas
    unsigned char* pixels;
    int width, height;
    io.Fonts->GetTexDataAsRGBA32(&pixels, &width, &height);
    io.Fonts->TexID = renderer->CreateTexture(width, height, (const uint32_t *)pixels);
}

void   ImGuiRenderNewFrame(ImGui::ImGuiRendererBase *renderer)
{
    auto &io = ImGui::GetIO();
    ImVec2 size = renderer->GetDisplaySize();
    ImVec2 scale  = renderer->GetFramebufferScale();
    
    io.DisplaySize.x = size.x / scale.x;
    io.DisplaySize.y = size.y / scale.y;
    io.DisplayFramebufferScale = scale;
}

// (this used to be set in io.RenderDrawListsFn and called by ImGui::Render(), but you can now call this directly from your main loop)
// Note that this implementation is little overcomplicated because we are saving/setting up/restoring every OpenGL state explicitly, in order to be able to run within any OpenGL engine that doesn't do so.
 void   ImGuiRenderDrawData(ImGui::ImGuiRendererBase *renderer, ImDrawData* draw_data)
{
    // Will project scissor/clipping rectangles into framebuffer space
    ImVec2 clip_off = draw_data->DisplayPos;         // (0,0) unless using multi-viewports
    ImVec2 clip_scale = draw_data->FramebufferScale; // (1,1) unless using retina display which are often (2,2)
    
    // Avoid rendering when minimized, scale coordinates for retina displays (screen coordinates != framebuffer coordinates)
    int fb_width = (int)(draw_data->DisplaySize.x * clip_scale.x);
    int fb_height = (int)(draw_data->DisplaySize.y * clip_scale.y);
    if (fb_width <= 0 || fb_height <= 0)
        return;

    renderer->BeginRender(  draw_data->DisplayPos, draw_data->DisplaySize, draw_data->FramebufferScale);
    
    // Render command lists
    for (int n = 0; n < draw_data->CmdListsCount; n++)
    {
        const ImDrawList* cmd_list = draw_data->CmdLists[n];
        
        renderer->UploadVertexData(cmd_list->VtxBuffer.Size, cmd_list->VtxBuffer.Data);
        renderer->UploadIndexData(cmd_list->IdxBuffer.Size, cmd_list->IdxBuffer.Data);

        for (int cmd_i = 0; cmd_i < cmd_list->CmdBuffer.Size; cmd_i++)
        {
            const ImDrawCmd* pcmd = &cmd_list->CmdBuffer[cmd_i];
            if (pcmd->UserCallback != NULL)
            {
                // User callback, registered via ImDrawList::AddCallback()
                // (ImDrawCallback_ResetRenderState is a special callback value used by the user to request the renderer to reset render state.)
                if (pcmd->UserCallback == ImDrawCallback_ResetRenderState)
                    renderer->ResetRenderState();
                else
                    pcmd->UserCallback(cmd_list, pcmd);
            }
            else
            {
                // Project scissor/clipping rectangles into framebuffer space
                ImVec4 clip_rect;
                clip_rect.x = (pcmd->ClipRect.x - clip_off.x) * clip_scale.x;
                clip_rect.y = (pcmd->ClipRect.y - clip_off.y) * clip_scale.y;
                clip_rect.z = (pcmd->ClipRect.z - clip_off.x) * clip_scale.x;
                clip_rect.w = (pcmd->ClipRect.w - clip_off.y) * clip_scale.y;

                if (clip_rect.x < fb_width && clip_rect.y < fb_height && clip_rect.z >= 0.0f && clip_rect.w >= 0.0f)
                {
                    // Apply scissor/clipping rectangle
                    renderer->SetScissorRect(clip_rect);
                    renderer->SetTexture(pcmd->TextureId);
                    renderer->DrawIndexed(pcmd->IdxOffset, pcmd->ElemCount);
                }
            }
        }
    }
    
     renderer->EndRender();
}


//
//

static ImGuiRendererContext *            _renderer;
static Core::StopWatch             _timer;





using namespace render;


// Functions


void     ImGuiSupport_NewFrame()
{
    if (!_renderer)
        return;
    
    ImGuiRenderNewFrame(_renderer);
    
    
    ImGuiIO &io = ImGui::GetIO();
    io.DeltaTime = _timer.GetElapsedSeconds();
    _timer.Restart();
    
    ImGui::NewFrame();
}

void    ImGuiSupport_Render()
{
    if (!_renderer)
        return;
    
    ImGui::Render();
    ImGuiRenderDrawData(_renderer, ImGui::GetDrawData());
}

void     ImGuiSupport_Shutdown()
{
    ImGuiIO& io = ImGui::GetIO();
    io.Fonts->TexID = nullptr;
    
    _renderer = nullptr;
    
    ImGui::DestroyContext();

}

//
//
//


ImFont*  ImGuiSupport_AddFontFromFile(const std::string &path, float size_pixels, const ImFontConfig* font_cfg = NULL, const ImWchar* glyph_ranges = NULL)
{
//    IMGUI_API ImFont*           AddFontFromMemoryTTF(void* font_data, int font_size, float size_pixels, const ImFontConfig* font_cfg = NULL, const ImWchar* glyph_ranges = NULL); // Note: Transfer ownership of 'ttf_data' to ImFontAtlas! Will be deleted after destruction of the atlas. Set font_cfg->FontDataOwnedByAtlas=false to keep ownership of your data and it won't be freed.

    std::vector<uint8_t> data;
    if (!Core::File::ReadAllBytes(path, data))
    {
        return nullptr;
    }
    
    void * font_data = ImGui::MemAlloc(data.size());
    memcpy(font_data, data.data(), data.size());
    
    ImGuiIO& io = ImGui::GetIO();
    return io.Fonts->AddFontFromMemoryTTF(font_data, (int)data.size(), size_pixels, font_cfg, glyph_ranges);
}


void     ImGuiSupport_Init(ContextPtr context, std::string assetDir, std::string userDir)
{
    
    // Setup Dear ImGui context
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    
    ImGuiIO& io = ImGui::GetIO();

    io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;      // Enable Gamepad Controls

#ifdef EMSCRIPTEN
    //io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;     // Enable Keyboard Controls
    //io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;      // Enable Gamepad Controls
    //    io.IniFilename = NULL;
#else
    std::string iniPath= Core::Path::Combine(userDir, "imgui.ini");
    io.IniFilename = strdup(iniPath.c_str());
#endif

    
    
    io.KeyMap[ImGuiKey_Tab] = KEYCODE_TAB;
    io.KeyMap[ImGuiKey_LeftArrow] = KEYCODE_LEFT;
    io.KeyMap[ImGuiKey_RightArrow] = KEYCODE_RIGHT;
    io.KeyMap[ImGuiKey_UpArrow] = KEYCODE_UP;
    io.KeyMap[ImGuiKey_DownArrow] = KEYCODE_DOWN;
    io.KeyMap[ImGuiKey_PageUp] = KEYCODE_PAGEUP;
    io.KeyMap[ImGuiKey_PageDown] = KEYCODE_PAGEDOWN;
    io.KeyMap[ImGuiKey_Home] = KEYCODE_HOME;
    io.KeyMap[ImGuiKey_End] = KEYCODE_END;
    io.KeyMap[ImGuiKey_Insert] = KEYCODE_INSERT;
    io.KeyMap[ImGuiKey_Delete] = KEYCODE_DELETE;
    io.KeyMap[ImGuiKey_Backspace] = KEYCODE_BACKSPACE;
    io.KeyMap[ImGuiKey_Space] = KEYCODE_SPACE;
    io.KeyMap[ImGuiKey_Enter] = KEYCODE_RETURN;
    io.KeyMap[ImGuiKey_Escape] = KEYCODE_ESCAPE;
    io.KeyMap[ImGuiKey_A] = KEYCODE_A;
    io.KeyMap[ImGuiKey_C] = KEYCODE_C;
    io.KeyMap[ImGuiKey_V] = KEYCODE_V;
    io.KeyMap[ImGuiKey_X] = KEYCODE_X;
    io.KeyMap[ImGuiKey_Y] = KEYCODE_Y;
    io.KeyMap[ImGuiKey_Z] = KEYCODE_Z;
    
    
    // Setup Dear ImGui style
    //    ImGui::StyleColorsDark();
    ImGui::StyleColorsClassic();
    
    
    // Load Fonts
    // - If no fonts are loaded, dear imgui will use the default font. You can also load multiple fonts and use ImGui::PushFont()/PopFont() to select them.
    // - AddFontFromFileTTF() will return the ImFont* so you can store it if you need to select the font among multiple.
    // - If the file cannot be loaded, the function will return NULL. Please handle those errors in your application (e.g. use an assertion, or display an error and quit).
    // - The fonts will be rasterized at a given size (w/ oversampling) and stored into a texture when calling ImFontAtlas::Build()/GetTexDataAsXXXX(), which ImGui_ImplXXXX_NewFrame below will call.
    // - Read 'misc/fonts/README.txt' for more instructions and details.
    // - Remember that in C/C++ if you want to include a backslash \ in a string literal you need to write a double backslash \\ !
    
//    std::string fontPath = PathCombine(assetDir, "fonts/Cousine-Regular.ttf");

//#ifndef WIN32
//	std::string fontPath = Core::Path::Combine(assetDir, "fonts/Roboto-Medium.ttf");
//	io.Fonts->AddFontFromFileTTF(fontPath.c_str(), 18.0f);
//#endif

#if  0
    {
        std::string fontName;
        float fontSize;
        //
        
        fontName = "Roboto-Regular"; fontSize = 14;
        
    //        fontName = "ProggyTiny";  fontSize = 12;
    //    fontName = "ProggyClean"; fontSize = 18;
//        fontName = "Cousine-Regular"; fontSize = 14;
        std::string fontPath = Core::Path::Combine(Core::Path::Combine(assetDir, "data/fonts"), fontName) + ".ttf";
        
        ImFontConfig font_config;
        font_config.PixelSnapH = false;
        font_config.OversampleH = 2;
        font_config.OversampleV = 1;
        
        if (!ImGuiSupport_AddFontFromFile(fontPath, fontSize, &font_config))
        {
            io.Fonts->AddFontDefault();
        }
        
    }
#else
    io.Fonts->AddFontDefault();
#endif


    //io.Fonts->AddFontFromFileTTF("../../misc/fonts/Cousine-Regular.ttf", 15.0f);
    //io.Fonts->AddFontFromFileTTF("../../misc/fonts/DroidSans.ttf", 16.0f);
    //io.Fonts->AddFontFromFileTTF("../../misc/fonts/ProggyTiny.ttf", 10.0f);

    //IM_ASSERT(font != NULL);

    
    auto _shader = context->LoadShaderFromFile("data/shaders/imgui.fx");
    _renderer = new ImGuiRendererContext(context, _shader);
    ImGuiRenderInit( _renderer );
    

//    ImGui::PushStyleColor(ImGuiCol_WindowBg, ImVec4(0.00f, 0.00f, 0.00f, 1.00f));



}



namespace ImGui {
    void TextColumn(const char *format, ...)
    {
        char str[64 * 1024];
        
        va_list arglist;
        va_start(arglist, format);
        int count = vsnprintf(str, sizeof(str), format, arglist);
        va_end(arglist);
        (void)count;
        str[sizeof(str) - 1] = '\0';
        
        
        int start = 0;
        int i;
        for (i=0; str[i]; i++)
        {
            if (str[i] == '\t') {
                ImGui::TextUnformatted( &str[start], &str[i] );
                ImGui::NextColumn();
                start = i + 1;
            }
            
        }
        
        if (start < i)
        ImGui::TextUnformatted( &str[start], &str[i] );
    }
    


    static  float _values_getter(void* data, int idx)
    {
        auto func = (std::function<float (int idx)> *)data;
        return (*func)(idx);
    }


    void PlotHistogram(const char* label, std::function<float (int idx)> value_func, int values_count, int values_offset, const char* overlay_text, float scale_min, float scale_max, ImVec2 graph_size)
    {
        ImGui::PlotHistogram(label, _values_getter, &value_func, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size);
    }


}
