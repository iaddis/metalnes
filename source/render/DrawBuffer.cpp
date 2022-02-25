

#include "DrawBuffer.h"
#include <vector>
#include "imgui_support.h"
#include "TProfiler.h"

bool UseQuadLines = true;
bool UseQuadPoints = true;

namespace render {


class DrawBuffer : public IDrawBuffer
{
public:
    DrawBuffer(ContextPtr context)
    :m_context(context)
    {
        m_vertex_data.reserve(64 * 1024);
        m_index_data.reserve(64 * 1024);
    }

    
    virtual void DrawTriangleFan(const Vertex *v, int count) override;
    virtual void DrawLineStripAA(int count, const Vertex *v, float thickness, float aa_size) override;
    
    virtual void DrawLineStrip(int count, Vertex *pVerts, bool thick) override;
    virtual void DrawLineList(int count, Vertex *pVerts) override;
    virtual void DrawLineListAA(int count, const Vertex *v, float thickness, float aa_size) override;

    virtual void DrawPoints(int count, Vertex *pVerts, bool thick) override;
    virtual void DrawPointsWithSize(int count, Vertex *pVerts, float size) override;

    virtual void DrawPointsAsQuads(int count, Vertex *pVerts, float size);

    virtual void Flush() override;

    
protected:
    
    void IndexQuad(int v0, int v1, int v2, int v3);
    void IndexTri(int v0, int v1, int v2);

    int AppendVertexData(const Vertex *v, int count);
    IndexType *WriteIndexData(int count);

    
    Vertex *WriteVertexData(int *base_index, int count);

    
    ContextPtr              m_context;
    ImVector<Vertex>     m_vertex_data;
    ImVector<IndexType>   m_index_data;
};



template<typename T = IndexType>
static inline T *WriteIndexQuad(T *iptr, int i0, int i1, int i2, int i3)
{
    iptr[0] = (T)i0;
    iptr[1] = (T)i1;
    iptr[2] = (T)i2;
    iptr[3] = (T)i1;
    iptr[4] = (T)i2;
    iptr[5] = (T)i3;
    return iptr + 6;
}

template<typename T = IndexType>
static inline T *WriteIndexTri(T *iptr, int i0, int i1, int i2)
{
    iptr[0] = (T)i0;
    iptr[1] = (T)i1;
    iptr[2] = (T)i2;
    return iptr + 3;
}


void DrawBuffer::IndexQuad(int v0, int v1, int v2, int v3)
{
    m_index_data.push_back((IndexType)v0);
    m_index_data.push_back((IndexType)v1);
    m_index_data.push_back((IndexType)v2);
    m_index_data.push_back((IndexType)v1);
    m_index_data.push_back((IndexType)v2);
    m_index_data.push_back((IndexType)v3);
}

void DrawBuffer::IndexTri(int v0, int v1, int v2)
{
    m_index_data.push_back((IndexType)v0);
    m_index_data.push_back((IndexType)v1);
    m_index_data.push_back((IndexType)v2);
}

IndexType *DrawBuffer::WriteIndexData(int count)
{
    int start = (int)m_index_data.size();
    m_index_data.resize(start + count);
    return &m_index_data[start];
}


Vertex *DrawBuffer::WriteVertexData(int *base_index, int count)
{
    int index = (int)m_vertex_data.size();
    if ((index + count) >= 0x10000)
    {
        Flush();
        index = (int)m_vertex_data.size();
    }

    m_vertex_data.resize(index + count);

    *base_index = index;

    // return pointer to vertex data
    return &m_vertex_data[index];
}


int DrawBuffer::AppendVertexData(const Vertex *v, int count)
{
    int index = (int)m_vertex_data.size();
    if ((index + count) >= 0x10000)
    {
        Flush();
        index = (int)m_vertex_data.size();
    }

    // append vertex data
    m_vertex_data.resize( index + count );
    memcpy( &m_vertex_data[index], v, count * sizeof(v[0]));

    return index;
}

void DrawBuffer::Flush()
{
    if (m_index_data.empty())
        return;
    
    
    m_context->UploadVertexData(m_vertex_data.size(), m_vertex_data.begin());
    m_context->UploadIndexData(m_index_data.size(), m_index_data.begin() );
    m_context->DrawIndexed(PRIMTYPE_TRIANGLELIST, 0, (int)m_index_data.size());
    
    m_index_data.clear();
    m_index_data.reserve(64 * 1024);
    m_vertex_data.clear();
    m_vertex_data.reserve(64 * 1024);

}


void DrawBuffer::DrawTriangleFan(const Vertex *v, int count)
{
    int base =  AppendVertexData(v, count);
    IndexType *iptr = WriteIndexData( (count - 2) * 3);

    // add triangles of fan
    for (int i=2; i < count; i++)
    {
        iptr = WriteIndexTri(iptr, base + 0, base + i, base + i - 1);
    }
}

static Vector2 ComputeNormal(const Vertex &v0, const Vertex &v1)
{
    Vector2 delta(v1.x - v0.x, v1.y - v0.y);

    delta = delta.Normalized();

    Vector2 normal( delta.y, -delta.x);
    return normal;
}

Vector2 ComputeNormal(Vector2 p0, Vector2 p1)
{
    Vector2 delta = (p1 - p0).Normalized();

    Vector2 normal( delta.y, -delta.x);
    return normal;
}



#if 1
static Vector2 AverageNormals(Vector2 n0, Vector2 n1)
{
    Vector2 normal = (n0 + n1) * 0.5f;
    return normal.Normalized();
}


#else
static Vector2 AverageNormals(Vector2 n0, Vector2 n1)
{
    Vector2 normal = (n0 + n1) * 0.5f;
    float d2 = normal.LengthSquared();
    if (d2 < 0.5f) d2 = 0.5f;
    normal *= 1.0f / d2;
    return normal;
}
#endif


void DrawBuffer::DrawLineStripAA(int count, const Vertex *v, float thickness, float aa_size)
{
    PROFILE_FUNCTION()
    if (count < 2)
        return;
    
    
    constexpr float MAX = 4.0f;
    
    Size2D size = m_context->GetRenderTargetSize();

    
    Vector2 screen_scale( 1.0f / (float)size.width,  1.0f / (float)size.height);
    
    float half_inner_thickness = (thickness - aa_size) * 0.5f;
    float half_outer_thickness = half_inner_thickness + aa_size;

    int base;
    Vertex *out = WriteVertexData(&base, count * 4);

    Vector2 prev_normal = ComputeNormal(v[0], v[1]);

    for (int i=0; i < count; i++)
    {
        Vector2 p0(v[i+0].x, v[i+0].y);

        Vector2 line_normal(0,0);
        
        if (i < count - 1)
        {
            line_normal = ComputeNormal(v[i], v[i+1]);
        }
        else
        {
            line_normal = prev_normal;
        }

        Vector2 vertex_normal = AverageNormals(prev_normal,  line_normal);
        prev_normal  = line_normal;

        
        Vector2 miter = vertex_normal;

        
        float  dot =  Dot(miter, line_normal);
        
        float  miter_length = (dot != 0.0f) ? (1.0f / dot) : 0.0f;
        if (miter_length >  MAX)  miter_length = MAX;
        if (miter_length < -MAX)  miter_length = -MAX;
        
        miter.x *= screen_scale.x;
        miter.y *= screen_scale.y;
        
        
        Vector2 n_in  = miter * (half_inner_thickness * miter_length);
        Vector2 n_out = miter * (half_outer_thickness * miter_length);
        
        
        Vector2 vp[4] =
        {
            p0 - n_out,
            p0 - n_in,
            p0 + n_in,
            p0 + n_out
        };
        
        // write vertex data
        for (int j=0; j < 4; j++)
        {
            out[j] = v[i];
            out[j].x = vp[j].x;
            out[j].y = vp[j].y;
        }
        
        out[0].Diffuse &= 0xFFFFFF;
        out[3].Diffuse &= 0xFFFFFF;;
        
        out += 4;
    }
    
    IndexType *iptr = WriteIndexData( (count - 1) * 3 * 6);

    
    for (int i=0; i < count - 1; i++)
    {
        iptr = WriteIndexQuad(iptr, base + 0, base + 1, base + 4, base + 5);
        iptr = WriteIndexQuad(iptr, base + 1, base + 2, base + 5, base + 6);
        iptr = WriteIndexQuad(iptr, base + 2, base + 3, base + 6, base + 7);

        base += 4;
    }
    
//    Flush();
}

void DrawBuffer::DrawLineListAA(int count, const Vertex *v, float thickness, float aa_size)
{
    if (count < 2)
        return;

    
    PROFILE_FUNCTION()

    Size2D size = m_context->GetRenderTargetSize();
    
    Vector2 screen_scale(1.0f / (float)size.width,  1.0f / (float)size.height);
    
    float half_inner_thickness = (thickness - aa_size) * 0.5f;
    float half_outer_thickness = half_inner_thickness + aa_size;

    int base;
    Vertex *out = WriteVertexData(&base, count * 4);

    for (int i=0; i < count; i+=2)
    {
        Vector2 p0(v[i+0].x, v[i+0].y);
        Vector2 p1(v[i+1].x, v[i+1].y);

        Vector2 line_normal = ComputeNormal(v[i], v[i+1]);
        Vector2 miter = line_normal;
        
        miter.x *= screen_scale.x;
        miter.y *= screen_scale.y;
        
        
        Vector2 n_in  = miter * (half_inner_thickness);
        Vector2 n_out = miter * (half_outer_thickness);
        
        
        Vector2 vp[8] =
        {
            p0 - n_out,
            p0 - n_in,
            p0 + n_in,
            p0 + n_out,
            p1 - n_out,
            p1 - n_in,
            p1 + n_in,
            p1 + n_out
        };
        
        // write vertex data
        for (int j=0; j < 8; j++)
        {
            out[j] = v[i];
            out[j].x = vp[j].x;
            out[j].y = vp[j].y;
        }
        
        out[0].Diffuse &= 0xFFFFFF;
        out[3].Diffuse &= 0xFFFFFF;
        out[4].Diffuse &= 0xFFFFFF;
        out[7].Diffuse &= 0xFFFFFF;
        out += 8;
    }
    
    
    IndexType *iptr = WriteIndexData(count / 2 * 3 * 6);
    
    
    for (int i=0; i < count; i+=2)
    {
        iptr = WriteIndexQuad(iptr, base + 0, base + 1, base + 4, base + 5);
        iptr = WriteIndexQuad(iptr, base + 1, base + 2, base + 5, base + 6);
        iptr = WriteIndexQuad(iptr, base + 2, base + 3, base + 6, base + 7);
        base += 8;
    }
    
    //    Flush();
}

void DumpVertices(int count, const Vertex *pVerts)
{
    for (int i=0; i  < count; i++)
    {
        printf("[%d] (%f, %f)\n", i, pVerts[i].x, pVerts[i].y );
    }

    
}


void DrawBuffer::DrawLineList(int count, Vertex *pVerts)
{
    if (count < 2)
        return;

    bool thick = false;
    if (UseQuadLines) {
//        DumpVertices(count, pVerts);
       DrawLineListAA(count, pVerts, thick ? 8.0f : 2.0f, 1.0f);
       return;
   }
    
    m_context->DrawArrays(PRIMTYPE_LINELIST, count, pVerts);
}

void DrawBuffer::DrawLineStrip(int count, Vertex *pVerts, bool thick)
{
    if (count < 2)
        return;
    
    if (UseQuadLines) {
        DrawLineStripAA(count, pVerts, thick ? 8.0f : 2.0f, 1.0f);
        return;
    }
    
    Size2D size = m_context->GetRenderTargetSize();
    
    int its = thick ? 4 : 1;
    float x_inc = 2.0f / (float)size.width;
    float y_inc = 2.0f / (float)size.height;
    for (int it=0; it<its; it++)
    {
       switch(it)
       {
           case 0: break;
           case 1: for (int j=0; j<count; j++) pVerts[j].x += x_inc; break;        // draw fat dots
           case 2: for (int j=0; j<count; j++) pVerts[j].y += y_inc; break;        // draw fat dots
           case 3: for (int j=0; j<count; j++) pVerts[j].x -= x_inc; break;        // draw fat dots
       }
       m_context->DrawArrays(PRIMTYPE_LINESTRIP, (int)count, pVerts);
    }
}




void DrawBuffer::DrawPoints(int count, Vertex *pVerts, bool thick)
{
    if (count <= 0) return;

    
    if (UseQuadPoints) {
        DrawPointsWithSize( count, pVerts, thick ? 4.0f : 1.0f);
        return;
    }

    Size2D size = m_context->GetRenderTargetSize();
    
    int its = thick ? 4 : 1;
    float x_inc = 2.0f / (float)size.width;
    float y_inc = 2.0f / (float)size.height;
    for (int it=0; it<its; it++)
    {
       switch(it)
       {
           case 0: break;
           case 1: for (int j=0; j<count; j++) pVerts[j].x += x_inc; break;        // draw fat dots
           case 2: for (int j=0; j<count; j++) pVerts[j].y += y_inc; break;        // draw fat dots
           case 3: for (int j=0; j<count; j++) pVerts[j].x -= x_inc; break;        // draw fat dots
       }
       m_context->DrawArrays(PRIMTYPE_POINTLIST, count, pVerts);
    }
    
}


void DrawBuffer::DrawPointsAsQuads(int count, Vertex *v, float point_size)
{
    if (count <= 0) return;

    Size2D size = m_context->GetRenderTargetSize();
    
    int base;
    Vertex *out = WriteVertexData(&base, count * 4);

    Vector2 screen_scale(1.0f / (float)size.width,  1.0f / (float)size.height);

    Vector2 delta = screen_scale * point_size;
    
    for (int i=0; i < count; i++)
    {

        out[0] = v[i];
        out[1] = v[i];
        out[2] = v[i];
        out[3] = v[i];
        
        out[0].x -= delta.x;
        out[0].y -= delta.y;

        out[1].x -= delta.x;
        out[1].y += delta.y;

        out[2].x += delta.x;
        out[2].y -= delta.y;
        
        out[3].x += delta.x;
        out[3].y += delta.y;
  
        out += 4;
        
    }
    

    
    IndexType *iptr = WriteIndexData(count * 6);
    for (int i=0; i < count; i++)
    {
        iptr = WriteIndexQuad(iptr, base + 0, base + 1, base + 2, base + 3);
        base += 4;
    }
    
    Flush();
        

}


void DrawBuffer::DrawPointsWithSize(int count, Vertex *pVerts, float size)
{
    if (UseQuadPoints) {
        DrawPointsAsQuads(count, pVerts, size);
        return;
    }

   m_context->SetPointSize(size);
   m_context->DrawArrays(PRIMTYPE_POINTLIST, count, pVerts);
   m_context->SetPointSize(1.0f);
}



IDrawBufferPtr CreateDrawBuffer(ContextPtr context)
{
    return std::make_shared<DrawBuffer>(context);
}



}
