
#pragma once

#include <string>
#include <functional>
#include <memory>
#include "render/context.h"

#include "../external/imgui/imgui.h"
#include "../external/imgui/imgui_internal.h"
#include "Platform/keycode.h"



extern void     ImGuiSupport_Init(render::ContextPtr context, std::string assetDir, std::string userDir);
extern void     ImGuiSupport_Shutdown();
extern void     ImGuiSupport_NewFrame();
extern void     ImGuiSupport_Render();


