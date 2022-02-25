
#include "../external/imgui/imgui.h"
#include "imgui_support.h"
#include <stdio.h>
#include <assert.h>
#include <emscripten.h>
#include <SDL.h>
#include <SDL_opengles2.h>
#include <stdlib.h>
#include <GLES2/gl2.h>
#include <EGL/egl.h>
#include <emscripten/html5.h>
#include <emscripten/trace.h>

#include "render/context.h"
#include "render/context_gles.h"
#include "VizController.h"
#include "audio/IAudioSource.h"

using namespace render;





// Emscripten requires to have full control over the main loop. We're going to store our SDL book-keeping variables globally.
// Having a single function that acts as a loop prevents us to store state in the stack of said function. So we need some location for this.
static SDL_Window *g_Window;
static EMSCRIPTEN_WEBGL_CONTEXT_HANDLE g_context_handle;
static ContextPtr _context;
static IVizControllerPtr _vizController;
static IAudioSourcePtr m_audioSource;
static bool         g_MousePressed[3] = { false, false, false };

static void SetCanvasFocus()
{
    // needed to ensure canvas has focus
    EM_ASM({
        var canvas = document.getElementById('canvas');
        if (canvas)
            canvas.focus();
    });
}


static void ShowOutputTextArea()
{
    EM_ASM({
        // show output element
        var output = document.getElementById('output');
        if (output)
            output.style.display = 'block';
    });
}

static void ShowControls()
{
    EM_ASM({
        // show output element
        var e = document.getElementById('controls');
        if (e)
            e.style.display = 'block';
    });
}

static void HideControls()
{
    EM_ASM({
        // show output element
        var e = document.getElementById('controls');
        if (e)
            e.style.display = 'none';
    });
}




static void UpdateMousePosAndButtons()
{
    ImGuiIO& io = ImGui::GetIO();

    int mx, my;
    Uint32 mouse_buttons = SDL_GetMouseState(&mx, &my);
    io.MouseDown[0] = g_MousePressed[0] || (mouse_buttons & SDL_BUTTON(SDL_BUTTON_LEFT)) != 0;  // If a mouse press event came, always pass it as "mouse held this frame", so we don't miss click-release events that are shorter than 1 frame.
    io.MouseDown[1] = g_MousePressed[1] || (mouse_buttons & SDL_BUTTON(SDL_BUTTON_RIGHT)) != 0;
    io.MouseDown[2] = g_MousePressed[2] || (mouse_buttons & SDL_BUTTON(SDL_BUTTON_MIDDLE)) != 0;
    g_MousePressed[0] = g_MousePressed[1] = g_MousePressed[2] = false;

    io.MousePos = ImVec2((float)mx, (float)my);
}


static bool ProcessEvent(const SDL_Event* event)
{
    ImGuiIO& io = ImGui::GetIO();
    switch (event->type)
    {
    case SDL_MOUSEWHEEL:
        {
            if (event->wheel.x > 0) io.MouseWheelH += 1;
            if (event->wheel.x < 0) io.MouseWheelH -= 1;
            if (event->wheel.y > 0) io.MouseWheel += 1;
            if (event->wheel.y < 0) io.MouseWheel -= 1;
            return true;
        }
    case SDL_MOUSEBUTTONDOWN:
        {
            if (event->button.button == SDL_BUTTON_LEFT) g_MousePressed[0] = true;
            if (event->button.button == SDL_BUTTON_RIGHT) g_MousePressed[1] = true;
            if (event->button.button == SDL_BUTTON_MIDDLE) g_MousePressed[2] = true;
            return true;
        }
    case SDL_TEXTINPUT:
        {
            io.AddInputCharactersUTF8(event->text.text);
            return true;
        }
    case SDL_KEYDOWN:
    case SDL_KEYUP:
        {
            int key = event->key.keysym.sym;
            if (key >= 0 && key < IM_ARRAYSIZE(io.KeysDown))
            {
                io.KeysDown[key] = (event->type == SDL_KEYDOWN);
            }
            io.KeyShift = ((SDL_GetModState() & KMOD_SHIFT) != 0);
            io.KeyCtrl = ((SDL_GetModState() & KMOD_CTRL) != 0);
            io.KeyAlt = ((SDL_GetModState() & KMOD_ALT) != 0);
            io.KeySuper = ((SDL_GetModState() & KMOD_GUI) != 0);
            return true;
        }
    }
    return false;
}



void main_loop(void* arg)
{
    PROFILE_FRAME()
    
    
    ImGuiIO& io = ImGui::GetIO();
    IM_UNUSED(io); 
    IM_UNUSED(arg); // We can pass this argument as the second parameter of emscripten_set_main_loop_arg(), but we don't use that.
    
    SetCanvasFocus();
    
    // Poll and handle events (inputs, window resize, etc.)
    SDL_Event event;
    while (SDL_PollEvent(&event))
    {
        ProcessEvent(&event);
    }
    
    if (_vizController->IsDebugUIVisible()) {
        SDL_ShowCursor(1);
        ShowControls();
    } else {
        SDL_ShowCursor(0);
        HideControls();
    }
    
    
    emscripten_webgl_make_context_current(g_context_handle);
    
    SDL_GL_SetSwapInterval(1); // Enable vsync

    double width, height;
    emscripten_get_element_css_size("canvas", &width, &height);
    emscripten_set_canvas_element_size("canvas", (int)width, (int)height);
    

    
    double dpr = emscripten_get_device_pixel_ratio();
//    emscripten_set_canvas_element_size("canvas", (int)(width * dpr), (int)(height * dpr));

    
    int buffer_width, buffer_height;
    EMSCRIPTEN_WEBGL_CONTEXT_HANDLE webgl_context = emscripten_webgl_get_current_context();
    emscripten_webgl_get_drawing_buffer_size(webgl_context, &buffer_width, &buffer_height);
    Size2D displaySize(buffer_width, buffer_height);

//    printf("canvas_element_size:(%f,%f) dpr:%f buffer:(%d,%d)\n", width, height, dpr, buffer_width, buffer_height);


    float scale = (int)displaySize.width / (int)width;
 
    render::DisplayInfo info;
    info.size= displaySize;
    info.format= render::PixelFormat::RGBA8Unorm;
    info.refreshRate = 60.0f;
    info.scale = scale;
    info.samples = 1;
    info.maxEDR = 1;
    

    _context->SetDisplayInfo(info);


    UpdateMousePosAndButtons();

    _context->BeginScene();
    
    float dt = 1.0f / 60.0f;
    _vizController->Update(dt);
    _vizController->DrawVisualizer(nullptr, true);
    _vizController->DrawGUI(nullptr, false);
    _context->EndScene();
    _context->Present();

    
    emscripten_webgl_commit_frame();

//    SDL_GL_SwapWindow(g_Window);
}


void WebClientSend(const WebRequest &wr, std::function<void (const WebResponse &)> complete )
{

}

void HttpSend(std::string method, std::string url, const char *content,  size_t content_size, bool compress, const char *contentType, HttpCompleteFunc complete)
{
}

extern "C" int main(int argc, const char *argv[])
{
    for (int i=1; i < argc; i++)
        LogPrint("arg[%d] = %s\n", i, argv[i]);
    
    SDL_version compiled;
    SDL_version linked;
    SDL_VERSION(&compiled);
    SDL_GetVersion(&linked);
    LogPrint("Compiled SDL version %d.%d.%d\n",
         compiled.major, compiled.minor, compiled.patch);
    LogPrint("Linked SDL version %d.%d.%d\n",
         linked.major, linked.minor, linked.patch);
    
    
    EmscriptenWebGLContextAttributes attr = {};
    attr.alpha = false;
    attr.depth = false;
    attr.stencil = false;
    attr.antialias = false;
    attr.premultipliedAlpha = false;
    attr.preserveDrawingBuffer = false;
    attr.majorVersion = 2;
    attr.minorVersion = 0;
    attr.enableExtensionsByDefault = true;
    g_context_handle = emscripten_webgl_create_context("canvas", &attr);
    if (!g_context_handle) {
        LogError("This browser does not support WebGL2. If using safari, enable WebGL in the experimental settings\n");
        ShowOutputTextArea();
        return -1;
    }
    
    emscripten_webgl_make_context_current(g_context_handle);
    
    // Setup SDL
    if (SDL_Init(SDL_INIT_VIDEO) != 0)
    {
        LogError("SDL_GetError: %s\n", SDL_GetError());
        ShowOutputTextArea();
        return -1;
    }
    
    
    SDL_WindowFlags window_flags = (SDL_WindowFlags)( SDL_WINDOW_RESIZABLE);
    g_Window = SDL_CreateWindow("m1lkdr0p", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1024, 1024, window_flags);
    
    
    _context = render::gles::GLCreateContext();
    
    std::string resourceDir = "";
    std::string assetDir =  resourceDir + "/assets";
    std::string userDir= "/user";
    
    ImGuiSupport_Init(_context, assetDir);

    
    // Setup backend capabilities flags
    ImGuiIO& io = ImGui::GetIO();
//    io.BackendFlags |= ImGuiBackendFlags_HasMouseCursors;       // We can honor GetMouseCursor() values (optional)
//    io.BackendFlags |= ImGuiBackendFlags_HasSetMousePos;        // We can honor io.WantSetMousePos requests (optional, rarely used)
    io.BackendPlatformName = "emscripten";

    
    _vizController = CreateVizController(_context, assetDir, userDir);
    
    // This function call won't return, and will engage in an infinite loop, processing events from the browser, and dispatching them.
    emscripten_set_main_loop_arg(main_loop, NULL, 0, true);
}
