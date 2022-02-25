

#pragma once

#include "render/context.h"
#include <functional>

namespace render {
namespace gles {


//bool LoadTextureFromFile(const char *path, GLuint *name, GLint *width, GLint *height)

struct GLTextureInfo
{
    unsigned int name;
    int width;
    int height;
};

using GLTextureLoadFunc = std::function<bool (const char *path, GLTextureInfo &info)>;


ContextPtr GLCreateContext(GLTextureLoadFunc textureLoadFunc);


}}

