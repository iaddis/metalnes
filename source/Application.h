
#pragma once

#include "render/context.h"


void AppInit(render::ContextPtr context, std::string data_dir, std::string user_dir, const std::vector<std::string> &args);
void AppShutdown();
void AppRender(render::ContextPtr context);
bool AppShouldQuit();

