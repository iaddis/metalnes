
#pragma once

#include <stdint.h>
#include "context.h"

namespace render {


class IDrawBuffer
{
public:
    IDrawBuffer() = default;
    virtual ~IDrawBuffer() = default;
    
    virtual void DrawTriangleFan(const Vertex *v, int count) = 0;
    virtual void DrawLineStripAA(int count, const Vertex *v, float thickness, float aa_size) = 0;

    virtual void DrawLineStrip(int count, Vertex *pVerts, bool thick) = 0;

    virtual void DrawLineList(int count, Vertex *pVerts) = 0;
    virtual void DrawLineListAA(int count, const Vertex *v, float thickness, float aa_size) = 0;

    virtual void DrawPoints(int count, Vertex *pVerts, bool thick) = 0;
    virtual void DrawPointsWithSize(int count, Vertex *pVerts, float size) = 0;

    virtual void Flush() = 0;

    
};

using IDrawBufferPtr = std::shared_ptr<IDrawBuffer>;

IDrawBufferPtr CreateDrawBuffer(ContextPtr context);


} // namespace render
