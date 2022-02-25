
#include "chiprender.h"
#include "imgui_support.h"
//#include "imgui_internal.h"
#include <set>
#include <unordered_set>


namespace metalnes {


class DynamicMesh
{
public:
    using Index = render::IndexType;
    using Vertex = render::Vertex;
    
    DynamicMesh()
    {
        SetColor(1,1,1,1);
    }
    
    bool Empty()
    {
        return _vertex_data.empty();
    }
    
    void Clear()
    {
        _index_data.clear();
        _vertex_data.clear();
        _vertex = {0};
        SetColor(1,1,1,1);

        _gpu_index_buffer = nullptr;
        _gpu_vertex_buffer = nullptr;
    }
    
    
    const std::vector<Index>  &     GetIndexData()  const {return _index_data;}
    const std::vector<Vertex>     & GetVertexData() const {return _vertex_data;}

    
    
    Index GetVertexCount()
    {
        return (Index)_vertex_data.size();
    }

    Index AddVertex(Vector4 position)
    {
        _vertex.position = position;
        return PushVertex();
    }
    
    Index AddVertex(Vector2 position)
    {
        _vertex.position.x = position.x;
        _vertex.position.y = position.y;
        _vertex.position.z = 0;
        _vertex.position.w = 0;
        
        return PushVertex();
    }
    
    Index AddVertex(float x, float y, float z = 0.0f, float w = 1.0f)
    {
        return AddVertex({x,y,z,w});
    }

    void SetColor(Vector4 v)
    {
        _vertex.color = v;
    }

    void SetColor(float r, float g, float b, float a = 1.0f)
    {
        SetColor({r,g,b,a});
    }
    
    void SetAlpha(float a)
    {
        _vertex.color.w = a;
    }

    
    void SetTexcoord0(Vector2 v)
    {
        _vertex.texcoord0 = v;
    }
    
    void SetTexcoord0(float s, float t)
    {
        SetTexcoord0({s,t});
    }

    void SetTexcoord1(Vector2 v)
    {
        _vertex.texcoord1 = v;
    }
    
    void SetTexcoord1(float s, float t)
    {
        SetTexcoord1({s,t});
    }
    
    int GetIndexCount()
    {
        return (int)_index_data.size();
    }
    
    void AddTriangle(Index i0, Index i1, Index i2)
    {
        AddIndex(i0);
        AddIndex(i1);
        AddIndex(i2);
    }

    
    void AddIndex(Index index)
    {
        _index_data.push_back(index);
    }
    
    void WriteIndexQuad(Index i0, Index i1, Index i2, Index i3)
    {
        AddTriangle(i0,i1,i2);
        AddTriangle(i1,i2,i3);

    }

    
    
    void Draw(render::ContextPtr context)
    {
        if (GetIndexCount() == 0)
        {
            return;
        }
        
        if (!_gpu_vertex_buffer) {
            _gpu_vertex_buffer = context->CreateVertexBuffer(_vertex_data);
        }
        if (!_gpu_index_buffer) {
            _gpu_index_buffer = context->CreateIndexBuffer(_index_data);
        }

        //     context->UploadVertexData(_vd_layers.GetVertexData());
          //   context->UploadIndexData(_id_layers.GetIndexData());
        context->SetVertexBuffer(0, _gpu_vertex_buffer);
        context->SetIndexBuffer(_gpu_index_buffer);
        context->DrawIndexed(render::PRIMTYPE_TRIANGLELIST, 0, GetIndexCount() );
    }

protected:
    Index PushVertex()
    {
        Index index = (Index)_vertex_data.size();
        _vertex_data.push_back(_vertex);
        return index;
    }
    
    Vertex              _vertex = {0};
    
    std::vector<Vertex>     _vertex_data;
    std::vector<Index>      _index_data;

    render::BufferPtr  _gpu_vertex_buffer;
    render::BufferPtr  _gpu_index_buffer;
};



static Vector2 ComputeNormal(const point &v0, const point &v1)
{
    Vector2 delta {v1.x - v0.x, v1.y - v0.y};

    delta = delta.Normalized();

    Vector2 normal{ delta.y, -delta.x};
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


void DrawLineStripAA(DynamicMesh &vb, const std::vector<point> &v, bool loop, float thickness, float aa_size)
{
    int count = (int)v.size();
    if (count < 2)
        return;
    
    constexpr float MAX = 4.0f;
    
    Vector2 size {1,1};
    Vector2 screen_scale{ 1.0f / (float)size.x,  1.0f / (float)size.y};
    
    float half_inner_thickness = (thickness - aa_size) * 0.5f;
    float half_outer_thickness = half_inner_thickness + aa_size;

//    Vector2 prev_normal = ComputeNormal(v[0], v[1]);

    
    int vb_base = vb.GetVertexCount();
    
    int prev = loop ? (count - 1) : 0;
    int curr = 0;
    
    for (int i=0; i < count; i++)
    {
        int next = curr + 1;
        if (next >= count) {
            if (!loop)
                break;
            
            // loop...
            next = 0;
        }
        
        Vector2 p0 {v[curr].x, v[curr].y};

        Vector2 prev_normal = ComputeNormal(v[prev], v[curr]);
        Vector2 line_normal = ComputeNormal(v[curr], v[next]);
        Vector2 vertex_normal = AverageNormals(prev_normal,  line_normal);
        Vector2 miter = vertex_normal;

        
        float  dot =  Dot(miter, line_normal);
        
        float  miter_length = (dot != 0.0f) ? (1.0f / dot) : 0.0f;
        if (miter_length >  MAX)  miter_length = MAX;
        if (miter_length < -MAX)  miter_length = -MAX;
        
        miter.x *= screen_scale.x;
        miter.y *= screen_scale.y;
        
        
        Vector2 n_in  = miter * (half_inner_thickness * miter_length);
        Vector2 n_out = miter * (half_outer_thickness * miter_length);

        {
            // left edge
            vb.SetAlpha(0);
            vb.AddVertex(p0 - n_out);

            vb.SetAlpha(1);
            vb.AddVertex(p0 - n_in);

            vb.SetAlpha(1);
            vb.AddVertex(p0 + n_in);

            // right edge
            vb.SetAlpha(0);
            vb.AddVertex(p0 + n_out);
        }

//        if (i > 0)
        {
            int vb_base0 = vb_base  + (curr * 4);
            int vb_base1 = vb_base  + (next * 4);
            
            // left edge
//            vb.WriteIndexQuad(vb_base0 + 0, vb_base0 + 1, vb_base1 + 0, vb_base1 + 1);

            // middle
            vb.WriteIndexQuad(vb_base0 + 1, vb_base0 + 2, vb_base1 + 1, vb_base1 + 2);

            // right edge
            vb.WriteIndexQuad(vb_base0 + 2, vb_base0 + 3, vb_base1 + 2, vb_base1 + 3);
        }
        
        prev = curr;
        curr = next;
    }
}

void DrawOutline(DynamicMesh &vb, const std::vector<point> &v, float thickness, float aa_size)
{
    int count = (int)v.size();
    if (count < 2)
        return;
    
    constexpr float MAX = 4.0f;
    
    float half_inner_thickness = (thickness - aa_size) * 0.5f;
    float half_outer_thickness = half_inner_thickness + aa_size;

    
    Vector2 size {1,1};
    Vector2 screen_scale{ 1.0f / (float)size.x,  1.0f / (float)size.y};
    
    
    int vb_base = vb.GetVertexCount();
    
    int prev = (count - 1);
    int curr = 0;
    
    for (int i=0; i < count; i++)
    {
        int next = curr + 1;
        if (next >= count) {
            // loop...
            next = 0;
        }
        
        Vector2 p0 {v[curr].x, v[curr].y};

        Vector2 prev_normal = ComputeNormal(v[prev], v[curr]);
        Vector2 line_normal = ComputeNormal(v[curr], v[next]);
        Vector2 vertex_normal = AverageNormals(prev_normal,  line_normal);
        Vector2 miter = vertex_normal;

        
        float  dot =  Dot(miter, line_normal);
        
        float  miter_length = (dot != 0.0f) ? (1.0f / dot) : 0.0f;
        if (miter_length >  MAX)  miter_length = MAX;
        if (miter_length < -MAX)  miter_length = -MAX;
        
        miter.x *= screen_scale.x;
        miter.y *= screen_scale.y;
        
        
        Vector2 n_in  = miter * (-half_inner_thickness * miter_length);
        Vector2 n_out = miter * (-half_outer_thickness * miter_length);

        {
            vb.SetAlpha(1);
            vb.AddVertex(p0);

            vb.SetAlpha(1);
            vb.AddVertex(p0 + n_in);

            // right edge
            vb.SetAlpha(0);
            vb.AddVertex(p0 + n_out);
        }

        {
            int vb_base0 = vb_base  + (curr * 3);
            int vb_base1 = vb_base  + (next * 3);
            
            // middle
            vb.WriteIndexQuad(vb_base0 + 0, vb_base0 + 1, vb_base1 + 0, vb_base1 + 1);

            // edge
            vb.WriteIndexQuad(vb_base0 + 1, vb_base0 + 2, vb_base1 + 1, vb_base1 + 2);
        }
        
        prev = curr;
        curr = next;
    }
}


class wire_render : public chip_render
{
public:
    wire_module_ptr _wires;

    // nodes we are to render
    std::unordered_set<nodeID> _nodes;
    
    std::vector<wire_segment_ptr> _segments;
    
    wire_instance_ptr _instance;
    
    wire_render(wire_module_ptr wires, wire_instance_ptr instance)
    :_wires(wires), _label(instance->name), _instance(instance)
    {
        for (const auto &segment : _instance->segments)
        {
            _nodes.insert( segment-> node_id );
            _segments.push_back(segment);
        }

        for (const auto &transistor : _instance->transistors)
        {
            _nodes.insert( transistor.gate );
            _nodes.insert( transistor.c1 );
            _nodes.insert( transistor.c2 );
        }

        
        resetView();
    }
    
    void resetView()
    {
        bbox_reset(_bb);
        
        for (auto seg : _segments)
        {
            if (!seg->points.empty())
            {
                bbox_append(_bb, seg->bb);
            }
        }
        
        _tx = (_bb.max.x + _bb.min.x) / 2;
        _ty = (_bb.max.y + _bb.min.y) / 2;
        
        float scalex = (_bb.max.x - _bb.min.x);
        float scaley = (_bb.max.y - _bb.min.y);
        _scale = std::max(scalex, scaley);
    }
    
    void draw(render::ContextPtr context, const Matrix44 &projection);

    void updateTransistors(render::ContextPtr context);
    void updateWires(render::ContextPtr context);
    void updateActiveWires(render::ContextPtr context);
    void updateHighlights(render::ContextPtr context);
    
    virtual const char *GetName() override
    {
        return _label.c_str();
    }

    virtual bool IsVisible() override
    {
        return _window_open;
    }


    virtual void SetVisible(bool visible) override
    {
        _window_open = visible;
    }

    virtual void onGui(render::ContextPtr context) override;
    
    virtual void onGuiSelectionWindow();
    void check_input();
    
    virtual void setSelectedNodes(const std::unordered_set<nodeID> &nodes) override
    {
        _selected_nodes = nodes;
        _updateSelectedNodes = true;
        
        bbox_reset(_bb);
        for (auto seg : _segments)
        {
            if (_selected_nodes.empty() || _selected_nodes.count(seg->node_id) > 0)
            {
                bbox_append(_bb, seg->bb);
            }
        }
        
        _tx = (_bb.max.x + _bb.min.x) / 2;
        _ty = (_bb.max.y + _bb.min.y) / 2;
        
        float scalex = (_bb.max.x - _bb.min.x);
        float scaley = (_bb.max.y - _bb.min.y);
        _scale = std::max(scalex, scaley);
    }
    
    void intersect(point p, std::set<wire_segment_ptr> &segments);
    void intersect(point p, std::set<const wire_transistor *> &transistors);
    
    Matrix44 ComputeMatrix(ImVec2 sz);
    point ConvertPixelToWire(ImVec2 p);
    
    bool _window_open = true;
    
    std::string _label;
    
    render::TexturePtr _texture;
    render::TexturePtr _texture_overlay;

    
//    std::vector<uint32_t> _state_texture_data;
    std::vector<uint8_t> _state_texture_data;

    render::TexturePtr _state_texture;
    
    std::vector<uint32_t> _layer_texture_data;
    render::TexturePtr _layer_texture;
    
    
    
    rect _bb;

    int _chip_id;
    point pmin, pmax;
    
    int layerMask = 0xFF;
    int _lastLayerMask = -1;
    bool _showTransistors = false;
    bool _showActiveNodes = true;
    bool _showUnnamedNodes = false;

    
    float _scale = 24000;
    float _tx = 0, _ty = 0;
    
    bool _updateSelectedNodes = true;
    std::set<wire_segment_ptr> _selected_segments;
    std::set<const wire_transistor *> _selected_transistors;
    std::unordered_set<nodeID> _selected_nodes;
    
    render::ShaderPtr _shader;
    
    
    DynamicMesh _vd_layers;
    DynamicMesh _vd_active;

    DynamicMesh _vd_highlight;

    DynamicMesh _vd_transistors;
};



void wire_render::check_input()
{
    
    if (ImGui::IsKeyDown(KEYCODE_Q)) {
        _scale += 100;
    }
    
    if (ImGui::IsKeyDown(KEYCODE_E)) {
        _scale -= 100;
    }
    
    
    if (ImGui::IsKeyDown(KEYCODE_A)) {
        _tx -= 100;
    }
    
    if (ImGui::IsKeyDown(KEYCODE_D)) {
        _tx += 100;
    }
    
    if (ImGui::IsKeyDown(KEYCODE_W)) {
        _ty += 100;
    }
    
    if (ImGui::IsKeyDown(KEYCODE_S)) {
        _ty -= 100;
    }
    
    
}

static const char *s_layernames[6] = {"metal", "switched diffusion", "inputdiode", "grounded diffusion", "powered diffusion", "polysilicon"};
static ImColor s_layercolors[8] {
//    ImColor(50, 50, 76,   255),
//    ImColor(128, 128, 192,   255),
    ImColor(0.5f, 0.5f, 0.75f,  0.4f ),
    
    ImColor(0xFF, 0xFF, 0x00,   255),
    ImColor(0xFF, 0x00, 0xFF,   255),
    ImColor(0x4D, 0xFF, 0x4D,   255),
    ImColor(0xFF, 0x4F, 0x4D,   255),
    ImColor(0x80, 0x1A, 0xC0,   255),
    ImColor(0x80, 0x00, 0xFF,   192),
//    ImColor(192/2, 0x00, 192,   255),
    ImColor(0x00, 0x00, 0x00,   255),
};

point wire_render::ConvertPixelToWire(ImVec2 p)
{
    float L = _tx - _scale * 0.5f;
    float T = _ty - _scale * 0.5f;
    float R = _tx + _scale * 0.5f;
    float B = _ty + _scale * 0.5f;
    
    float dx =  (p.x);
    float dy =  (p.y) ;
    
    dx *= R - L;
    dy *= B - T;
    
    dx += L;
    dy += T;
    
    return point{dx, dy};
}

Matrix44 wire_render::ComputeMatrix(ImVec2 sz)
{
    float scaleX = _scale;
    float scaleY = _scale * sz.y / sz.x;
    
    float L = _tx - scaleX * 0.5f;
    float T = _ty - scaleY * 0.5f;
    float R = _tx + scaleX * 0.5f;
    float B = _ty + scaleY * 0.5f;
    
    Matrix44 projection = Matrix44::OrthoLH(L, R, T, B, 0, 1.0f);
    return projection;
}


//static void KeepAspectRatio(ImGuiSizeCallbackData* data)
//{
//    data->DesiredSize.y = data->DesiredSize.x * data->CurrentSize.y / data->CurrentSize.x;
//}

static int sign (point p1, point p2, point p3)
{
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

static bool IntersectTriangle(point pt, point v1, point v2, point v3)
{
    auto d1 = sign(pt, v1, v2);
    auto d2 = sign(pt, v2, v3);
    auto d3 = sign(pt, v3, v1);
    
    bool has_neg = (d1 < 0) || (d2 < 0) || (d3 < 0);
    bool has_pos = (d1 > 0) || (d2 > 0) || (d3 > 0);
    
    return !(has_neg && has_pos);
}

void wire_render::intersect(point p, std::set<wire_segment_ptr> &segments)
{
    for (auto sd : _segments)
    {
        if (bbox_contains(sd->bb, p))
        {
            // do intersection test
            for (int i=0; i < sd->triangle_list.size(); i+=3)
            {
                int i0 = sd->triangle_list[i + 0];
                int i1 = sd->triangle_list[i + 1];
                int i2 = sd->triangle_list[i + 2];
                
                if (IntersectTriangle(p, sd->points[i0],  sd->points[i1],  sd->points[i2] ))
                {
                    segments.insert(sd);
                    break;
                }
            }
        }
        
    }
}


void wire_render::intersect(point p, std::set<const wire_transistor *> &transistors)
{
    for (const auto &transistor : _instance->transistors)
    {
        if (bbox_contains(transistor.bb, p))
        {
            transistors.insert(&transistor);
        }
    }
}




void wire_render::onGuiSelectionWindow()
{
    ImGui::SetNextWindowSize(ImVec2(600, 200), ImGuiCond_Once); //, ImGuiCond_Always);

    
    ImGuiWindowFlags window_flags = 0;
    
    if (!ImGui::Begin("selection", NULL, window_flags))
    {
        ImGui::End();
        return;
    }

    
    auto print_node = [=](const char *prefix, nodeID nn) {
        
        const char *name = _wires->getNodeName(nn);
        bool state = _wires->isNodeHigh(nn);
        int flags = _wires->getNodeFlags(nn);
        ImGui::Text("%s %-16s #%05d state:%c flags:%02X\n", prefix, name, nn, state  ? '+' : '-', flags);
    };
    
    
    wire_segment_ptr to_remove;
    for (auto sd : _selected_segments)
    {
        ImGui::PushID(sd.get());
        bool check = true;
        if (ImGui::Checkbox("", &check))
        {
            to_remove = sd;
        }
        ImGui::SameLine();
        
        ImGui::Text("[%4d]", sd->index );
        ImGui::SameLine();
        
        print_node("segment: ", sd->node_id);

        ImGui::SameLine();
        ImGui::Text("(%s)\n", s_layernames[sd->layer]);
//                ImGui::Text("segment %s area:%d\n", s_layernames[sd->layer], sd->area);
        

        ImGui::PopID();
    }
    
    if (to_remove) {
        _selected_segments.erase(to_remove);
        _updateSelectedNodes = true;
    }
    

    ImGui::End();

}



void wire_render::onGui(render::ContextPtr context)
{
    // Always Square
    if (!_window_open)
        return;
    
    onGuiSelectionWindow();
    
    ImGui::SetNextWindowSize(ImVec2(512, 512), ImGuiCond_Once); //, ImGuiCond_Always);
//    ImGui::SetNextWindowSizeConstraints(ImVec2(64, 64),
//                                        ImVec2(FLT_MAX, FLT_MAX),
//                                        KeepAspectRatio
//                                        );
    
    ImGui::SetNextWindowBgAlpha(1.0f);
    
    ImGuiWindowFlags window_flags = ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_MenuBar;
    
    if (!ImGui::Begin(_label.c_str(), &_window_open, window_flags))
    {
        ImGui::End();
        return;
    }
    
    if (ImGui::BeginMenuBar())
    {
        if (ImGui::BeginMenu("View"))
        {
            for (int i=0; i < 6; i++)
            {
                bool v = layerMask & (1 << i);
                
                ImVec4 color = s_layercolors[i];
                
                ImGui::PushStyleColor(ImGuiCol_Text, color);
                ImGui::MenuItem(s_layernames[i], NULL, &v);
                ImGui::PopStyleColor(1);
                
                layerMask &= ~(1 << i);
                if (v){
                    layerMask |=  (1 << i);
                }
//                ImGui::SameLine();
            }
            
            ImGui::MenuItem("Transistors", NULL, &_showTransistors);
            ImGui::MenuItem("Active Nodes", NULL, &_showActiveNodes);
            ImGui::MenuItem("Unnamed Nodes", NULL, &_showUnnamedNodes);

            ImGui::EndMenu();
        }
        ImGui::EndMenuBar();
    }

    
    /*
    
    for (int i=0; i < 6; i++)
    {
        bool v = layerMask & (1 << i);
        
        ImVec4 color = s_layercolors[i];
        
        ImGui::PushStyleColor(ImGuiCol_Text, color);
        ImGui::Checkbox(s_layernames[i], &v);
        ImGui::PopStyleColor(1);
        
        layerMask &= ~(1 << i);
        if (v){
            layerMask |=  (1 << i);
        }
        ImGui::SameLine();
        
    }
    */
    
    
//    ImGui::NewLine();
    
    
    ImDrawList* draw_list = ImGui::GetWindowDrawList();
    ImVec2 canvas_p = ImGui::GetCursorScreenPos();       // ImDrawList API uses screen coordinates!
    ImVec2 canvas_sz = ImGui::GetContentRegionAvail();   // Resize canvas to what's available
//    canvas_sz.y = canvas_sz.x;
    if (canvas_sz.x < 50.0f) canvas_sz.x = 50.0f;
    if (canvas_sz.y < 50.0f) canvas_sz.y = 50.0f;

    ImVec2 canvas_p0 = ImGui::GetCursorScreenPos();      // ImDrawList API uses screen coordinates!
    ImVec2 canvas_p1 = ImVec2(canvas_p0.x + canvas_sz.x, canvas_p0.y + canvas_sz.y);

    
    Matrix44 projection = ComputeMatrix(canvas_sz);

    
    // update texture
    draw(context, projection);

    draw_list->AddImage(_texture.get(),
                        canvas_p0, canvas_p1,
                        ImVec2(0,0), ImVec2(1, 1),
                        ImColor(1.0f,1.0f,1.0f,1.0f)
//                        IM_COL32(255, 255, 255, 255)
                        );

    draw_list->AddImage(_texture_overlay.get(),
                        canvas_p0, canvas_p1,
                        ImVec2(0,0), ImVec2(1, 1),
                        //IM_COL32(255, 255, 255, 64)
                        ImColor(1.0f,1.0f,1.0f,0.5f)

                        );
    
    //         draw_list->AddRectFilledMultiColor(canvas_p, ImVec2(canvas_p.x + canvas_sz.x, canvas_p.y + canvas_sz.y), IM_COL32(50, 50, 50, 255), IM_COL32(50, 50, 60, 255), IM_COL32(60, 60, 70, 255), IM_COL32(50, 50, 60, 255));
    //         draw_list->AddRect(canvas_p, ImVec2(canvas_p.x + canvas_sz.x, canvas_p.y + canvas_sz.y), IM_COL32(255, 255, 255, 255));
    
    
    ImGui::InvisibleButton("chip", canvas_sz);
    ImVec2 mouse_pos_global = ImGui::GetIO().MousePos;
    ImVec2 mouse_pos_canvas = ImVec2(mouse_pos_global.x - canvas_p.x, mouse_pos_global.y - canvas_p.y);
    
    
    
    
    float mouse_x =  (mouse_pos_canvas.x) / canvas_sz.x;
    float mouse_y =  1.0f - (mouse_pos_canvas.y) / canvas_sz.y;
    
    
    Matrix44 inv_projection = projection.Invert();
    Vector4 mouse_pos   = {mouse_x * 2 - 1, mouse_y * 2 - 1, 0.0f, 1.0f};

//            Vector4 v = {mouse_x, mouse_y, 0.0f, 1.0f};
    Vector4 r = inv_projection.Multiply(mouse_pos);


    if (ImGui::IsItemHovered())
        check_input();
    
    {
        
        if (ImGui::IsItemActive() && ImGui::IsMouseDragging(0))
        {
            ImVec2 delta = ImGui::GetMouseDragDelta(0);

            Vector4 mouse_delta = {-2.0f * delta.x / canvas_sz.x , 2.0f * delta.y / canvas_sz.y, 0.0f, 1.0f};

            Vector4 newp = inv_projection.Multiply(mouse_delta);
            _tx = newp.x;
            _ty = newp.y;
            ImGui::ResetMouseDragDelta(0);
        }
        
        
        else if (ImGui::IsItemActive() && ImGui::IsMouseClicked(0) && ImGui::GetIO().KeyShift)
        {
            point p = { r.x, r.y };
            
            std::set<wire_segment_ptr> segments;
            std::set<const wire_transistor *> transistors;
            intersect(p, segments);
            intersect(p, transistors );
            
            if (!segments.empty())
            {
                for (auto segment : segments)
                {
                    if (_selected_segments.count(segment) > 0) {
                        _selected_segments.erase(segment);
                    } else {
                        _selected_segments.insert(segment);
                    }
                }
                
                _selected_nodes.clear();
                for (auto sd : _selected_segments)
                {
                    if (is_pwr_gnd(sd->node_id) )
                        continue;
                    
                    _selected_nodes.insert(sd->node_id);
        //            _selectedNode = sd->nn;
                }
                
                _updateSelectedNodes = true;
            }

            
            if (!transistors.empty())
            {
                for (auto transistor : transistors)
                {
                    if (_selected_transistors.count(transistor) > 0) {
                        _selected_transistors.erase(transistor);
                    } else {
                        _selected_transistors.insert(transistor);
                    }
                }
                _updateSelectedNodes = true;
            }
            
        }
        else if (ImGui::IsItemHovered() && ImGui::IsMouseClicked(1) && !ImGui::GetIO().KeyShift)
        {
            _selected_segments.clear();
            _selected_nodes.clear();
            _selected_transistors.clear();
            _updateSelectedNodes = true;
        }

    }
    
    
    if (ImGui::IsItemHovered())
    {
        auto &io = ImGui::GetIO();
        if (io.MouseWheel != 0)
        {
//            float prev_scale = scale;
            _scale -= io.MouseWheel * 500.0f;
            if (_scale < 30) _scale = 30;
            
            // adjust position to scale around the current mosue position
            Matrix44 new_projection = ComputeMatrix(canvas_sz);
            Matrix44 new_inv_projection = new_projection.Invert();
            Vector4 r2 = new_inv_projection.Multiply(mouse_pos);
         //   point p2 = { (int)r2.x, (int)r2.y };
//            printf("%d,%d -> %d,%d\n", p.x, p.y, p2.x, p2.y);
            _tx += r.x - r2.x;
            _ty += r.y - r2.y;
        }
    }
    
    
    if (ImGui::IsItemHovered())
    {
        point p = { r.x, r.y };

        std::set<wire_segment_ptr> segments;
        std::set<const wire_transistor *> transistors;
        intersect(p, segments);
        intersect(p, transistors );


//        ImGui::Text("Hovering %f %f\n", mouse_x, mouse_y);
        
        if (!segments.empty() || !transistors.empty())
        {
            std::set<nodeID> nodes;
            
            
//            int start = _instance->node_start;
            
            auto print_node = [=](const char *prefix, nodeID nn) {
                
                const char *name = _wires->getNodeName(nn);
                bool state = _wires->isNodeHigh(nn);
                int flags = _wires->getNodeFlags(nn);
                ImGui::Text("%s %-16s #%05d state:%c flags:%02X\n", prefix, name, nn, state  ? '+' : '-', flags);
            };
            
            for(auto sd : segments) {
                nodes.insert(sd->node_id);
            }

            ImGui::BeginTooltip();
            
            for (auto sd : segments)
            {
                print_node("node: ", sd->node_id);

                ImGui::SameLine();
                ImGui::Text("(%s)\n", s_layernames[sd->layer]);
//                ImGui::Text("segment %s area:%d\n", s_layernames[sd->layer], sd->area);
                

            }
            
            for (auto td : transistors)
            {
//                ImGui::Text("transistor %s [%d %d %d %d %d]\n", td->name.c_str(),
//                            td->width1,
//                            td->width2,
//                            td->height,
//                            td->num_segments,
//                            td->area
//
//                            );

                ImGui::Text("transistor %s\n", td->name.c_str());

                print_node("\tgate: ", td->gate);
                print_node("\tc1:   ", td->c1);
                print_node("\tc2:   ", td->c2);

            }
            
            
//            for (auto nn : nodes)
//            {
//                print_node("node: ", nn);
//            }
            ImGui::EndTooltip();
        }

    }
    
    
    
    ImGui::End();
    
}

void wire_render::updateTransistors(render::ContextPtr context)
{
    DynamicMesh &mesh = _vd_transistors;
    
    mesh.Clear();
    
    int i = 0;
    for (const auto &td : _instance->transistors)
    {
        int base_index = mesh.GetVertexCount();
        
//        if (td.width1 == td.width2 )
            mesh.SetColor(1,1,1,1);
//        else
//            mesh.SetColor(0,0,1,1);
        
        mesh.SetTexcoord0(0,0);
        mesh.AddVertex(td.bb.min.x, td.bb.min.y);
        mesh.SetTexcoord0(1,0);
        mesh.AddVertex(td.bb.max.x, td.bb.min.y);
        mesh.SetTexcoord0(0,1);
        mesh.AddVertex(td.bb.min.x, td.bb.max.y);
        mesh.SetTexcoord0(1,1);
        mesh.AddVertex(td.bb.max.x, td.bb.max.y);
        
        mesh.AddTriangle( base_index + 0, base_index + 1, base_index + 2);
        mesh.AddTriangle( base_index + 2, base_index + 1, base_index + 3);

        std::vector<point> points;
        points.push_back(  {td.bb.min.x, td.bb.max.y} );
        points.push_back(  {td.bb.max.x, td.bb.max.y} );
        points.push_back(  {td.bb.max.x, td.bb.min.y} );
        points.push_back(  {td.bb.min.x, td.bb.min.y} );
        
        mesh.SetColor(1,1,1,1);
        DrawOutline(mesh, points, 4.0f, 2.0f);

        i++;
//            if (i>=1) break;
    }


}

void wire_render::updateWires(render::ContextPtr context)
{
    DynamicMesh &mesh = _vd_layers;

    mesh.Clear();
    
    int twidth = _state_texture->GetWidth();
    
    Vector2 txscale0 = {1.0f / (float)_state_texture->GetWidth(),
                       1.0f / (float)_state_texture->GetHeight()};

    Vector2 txscale1 = {1.0f / (float)_layer_texture->GetWidth(),
                       1.0f / (float)_layer_texture->GetHeight()};

    
    for (auto seg : _segments)
    {
        int nn = seg->node_id;
        int layer = seg->layer;
        
        /*
         ImColor color = s_layercolors[layer % 8];
        _vd_layers.SetColor(
            color.Value.x * color.Value.w,
            color.Value.y * color.Value.w,
            color.Value.z * color.Value.w,
            1.0
        );
         */
        mesh.SetColor(1,1,1,1);

        int ty = (nn / twidth);
        int tx = nn - (ty * twidth);
        
        mesh.SetTexcoord0(
            ((float)tx + 0.5f) * txscale0.x,
            ((float)ty + 0.5f) * txscale0.y
        );
        
        mesh.SetTexcoord1(
          ((float)layer + 0.5f)  * txscale1.x,
          ((float)0     + 0.5f)  * txscale1.y
        );
        
        float z  = 0; //1.0f + ((float)layer) / 8.0f; ;

        int base_index = mesh.GetVertexCount();
        for (auto p : seg->points)
        {
            mesh.AddVertex(p.x, p.y, z);
        }
        
        for (auto ti : seg->triangle_list)
        {
            mesh.AddIndex(base_index + ti);
        }
        
        if (layer == 0 || layer == 6)
        {
            DrawLineStripAA(mesh, seg->points, true, 4.0f, 2.0f);
        }
        
    }
    

    
    

}


void wire_render::updateActiveWires(render::ContextPtr context)
{
    DynamicMesh &mesh = _vd_active;

    mesh.Clear();
    
    int twidth = _state_texture->GetWidth();
    
    Vector2 txscale0 = {1.0f / (float)_state_texture->GetWidth(),
                       1.0f / (float)_state_texture->GetHeight()};

    Vector2 txscale1 = {1.0f / (float)_layer_texture->GetWidth(),
                       1.0f / (float)_layer_texture->GetHeight()};

    
    for (auto seg : _segments)
    {
        int nn = seg->node_id - _instance->node_start;
        int layer = seg->layer;
        
        if (layer == Layer::GroundedDiffusion || layer == Layer::PoweredDiffusion)
            continue;

        mesh.SetColor(1,1,1,1);

        int ty = (nn / twidth);
        int tx = nn - (ty * twidth);
        
        mesh.SetTexcoord0(
            ((float)tx + 0.5f) * txscale0.x,
            ((float)ty + 0.5f) * txscale0.y
        );
        
        mesh.SetTexcoord1(
          ((float)layer + 0.5f)  * txscale1.x,
          ((float)0     + 0.5f)  * txscale1.y
        );
        
        float z  = 0; //1.0f + ((float)layer) / 8.0f; ;

        int base_index = mesh.GetVertexCount();
        for (auto p : seg->points)
        {
            mesh.AddVertex(p.x, p.y, z);
        }
        
        for (auto ti : seg->triangle_list)
        {
            mesh.AddIndex(base_index + ti);
        }
        
    }
    

    
    

}


void wire_render::updateHighlights(render::ContextPtr context)
{
    DynamicMesh &mesh = _vd_highlight;

    mesh.Clear();
    
    for (const auto &seg : _selected_segments)
    {
        if (!(layerMask & (1 << seg->layer)))
            continue;

        {
            mesh.SetTexcoord0({0,0});
            mesh.SetTexcoord1({0,0});
            
#if 1
            mesh.SetColor(1,1,1, 0.8);

            int base_index = mesh.GetVertexCount();
            for (auto p : seg->points)
            {
                mesh.AddVertex(p.x, p.y, 0);
            }
            
            for (auto ti : seg->triangle_list)
            {
                mesh.AddIndex(base_index + ti);
            }
#endif

            mesh.SetColor(0,0,1,1);
            DrawOutline(mesh, seg->points, 4.0f, 2.0f);
        }
    }
    
    for (const auto &td : _selected_transistors)
    {
        
        int base_index = mesh.GetVertexCount();
        
        mesh.SetColor(1,1,1,0.7);
        
        mesh.SetTexcoord0(0,0);
        mesh.AddVertex(td->bb.min.x, td->bb.min.y);
        mesh.SetTexcoord0(1,0);
        mesh.AddVertex(td->bb.max.x, td->bb.min.y);
        mesh.SetTexcoord0(0,1);
        mesh.AddVertex(td->bb.min.x, td->bb.max.y);
        mesh.SetTexcoord0(1,1);
        mesh.AddVertex(td->bb.max.x, td->bb.max.y);
        
        mesh.AddTriangle( base_index + 0, base_index + 1, base_index + 2);
        mesh.AddTriangle( base_index + 2, base_index + 1, base_index + 3);
        
        
        /*
        std::vector<point> points;
        points.push_back(  {td->bb.min.x, td->bb.max.y} );
        points.push_back(  {td->bb.max.x, td->bb.max.y} );
        points.push_back(  {td->bb.max.x, td->bb.min.y} );
        points.push_back(  {td->bb.min.x, td->bb.min.y} );
        
        mesh.SetColor(1,1,1,1);
        DrawOutline(mesh, points, 4.0f, 2.0f);
         */

    }
}

void wire_render::draw(render::ContextPtr context, const Matrix44 &projection)
{
    using namespace render;
    
    if (!_texture)
    {
        _texture = context->CreateRenderTarget("chipsim", 2048, 2048, render::PixelFormat::RGBA8Unorm);
    }
    
    
    if (!_texture_overlay)
    {
        _texture_overlay = context->CreateRenderTarget("chipsim-overlay", 2048, 2048, render::PixelFormat::RGBA8Unorm);
    }
    
    {
        int start = _instance->node_start;
        int count = _instance->node_end - _instance->node_start + 1;
        
        
        int width = 256;
        int height = 256;

        _state_texture_data.resize( width * height );
        
        if (!_showUnnamedNodes)
        {
            _wires->getNodeStates(_state_texture_data, start, count, 0x00, 0xFF );
        }
        else
        {
            for (int i=0; i < count; i++)
            {
                const char *name =  _wires->getNodeName(start + i);
                _state_texture_data[i] = !name[0] ? 0xFF : 0x00;
            }
        }
        
        if (!_state_texture)
        {
            auto format = sizeof(_state_texture_data[0]) == 1 ? render::PixelFormat::A8Unorm : render::PixelFormat::RGBA8Unorm;
            _state_texture = context->CreateTexture("chipsim-state", width, height, format, _state_texture_data.data());
        }

        context->UploadTextureData(_state_texture, _state_texture_data.data(),  width, height, width * sizeof(_state_texture_data[0]) );
    }
    
    {
        int width  = 8;
        int height = 1;

        _layer_texture_data.resize( width * height );
        
        for (int i=0; i < width; i++)
        {
            uint32_t color32  = 0;
            if ((layerMask & (1<<i))) {
                color32 = s_layercolors[i % 8];
            }
            
            _layer_texture_data[i] = color32;

        }
        
        
        if (!_layer_texture)
        {
    //        auto image = _state_texture_image;
            _layer_texture = context->CreateTexture("chipsim-layer", width, height, render::PixelFormat::RGBA8Unorm, _layer_texture_data.data());
        }

        context->UploadTextureData(_layer_texture, _layer_texture_data.data(),  width, height, width * sizeof(_layer_texture_data[0]) );
    }
    
    
    //    context->SetRenderTargetDepth(_chipTexture, _chipTextureStencil, "chipsim", render::LoadAction::Clear, Color4F(0.1,0.1,0.1,1));
    
    
    if (_updateSelectedNodes)
    {        
        updateHighlights(context);
        _updateSelectedNodes = false;
    }

    
    if (_vd_transistors.Empty())
    {
        updateTransistors(context);
    }
    
    if (_vd_layers.Empty())
    {
        updateWires(context);
    }

    if (_vd_active.Empty())
    {
        updateActiveWires(context);
    }


    
 
    
#if 0
    float L = tx - scale * 0.5f;
    float T = ty - scale * 0.5f;
    float R = tx + scale * 0.5f;
    float B = ty + scale * 0.5f;
    auto projection2 = Matrix44::PerspectiveOffCenterLH(L,R,T,B,1,4);
#endif
    
    context->SetTransform(projection);

    
    if (!_shader) {
        _shader = context->LoadShaderFromFile("data/shaders/ChipRender.fx");
    }
    
    context->SetRenderTarget(_texture, "chipsim", render::LoadAction::Clear, Color4F(0.0,0.0,0.0,1));
    context->SetBlend(BLEND_SRCALPHA, BLEND_INVSRCALPHA);
    context->SetWriteMask( ColorWriteMaskRed | ColorWriteMaskGreen | ColorWriteMaskBlue );


    // draw circuits
    if (!_vd_layers.Empty())
    {
        // draw base circuits
        context->SetShader(_shader);
        _shader->SetSampler(0, nullptr);
        _shader->SetSampler(1, _layer_texture);
        _shader->SetConstant("color_scale", Vector4{1,1,1,1});
        _vd_layers.Draw(context);

    }
    
    context->SetRenderTarget(_texture_overlay, "chipsim-overlay", render::LoadAction::Clear, Color4F(0.0,0.0,0.0,1));
//    context->SetBlendDisable();
    context->SetBlend(BLEND_SRCALPHA, BLEND_INVSRCALPHA);

    context->SetWriteMask( ColorWriteMaskRed | ColorWriteMaskGreen | ColorWriteMaskBlue );

    if (_showUnnamedNodes)
    {
        float glow = 0.7f + 0.1f * sinf( ImGui::GetTime() * 4.0f / (2.0f * M_PI) );
        // draw unnamed nodes
        context->SetShader(_shader);
        _shader->SetSampler(0, _state_texture);
        _shader->SetSampler(1, nullptr);
        _shader->SetConstant("color_scale", Vector4{1.0, 1.0, 1.0, glow});
        _vd_active.Draw(context);
    }
    else
    if (_showActiveNodes)
    {
        float glow = 0.7f + 0.1f * sinf( ImGui::GetTime() * 4.0f /  (2.0f * M_PI) );
        // draw active nodes
        context->SetShader(_shader);
        _shader->SetSampler(0, _state_texture);
        _shader->SetSampler(1, nullptr);
        _shader->SetConstant("color_scale", Vector4{1.0, 0.0, 0.25, glow});
        _vd_active.Draw(context);
    }

    
    
    if (_showTransistors)
    {
   
        context->SetShader(_shader);
        _shader->SetSampler(0, nullptr);
        _shader->SetSampler(1, nullptr);
        _shader->SetConstant("color_scale", Vector4{1,1,1,1});
        _vd_transistors.Draw(context);
    }

    // draw highlights
    if (!_vd_highlight.Empty())
    {
   
        context->SetShader(_shader);
        _shader->SetSampler(0, nullptr);
        _shader->SetSampler(1, nullptr);
        _shader->SetConstant("color_scale", Vector4{1,1,1,0.9});
        _vd_highlight.Draw(context);
    }

    context->SetVertexBuffer(0, nullptr);
    context->SetIndexBuffer(nullptr);

    context->SetWriteMask( ColorWriteMaskAll );
    context->SetBlendDisable();
    
    
}


chip_render_ptr CreateWireRender(wire_module_ptr wires, wire_instance_ptr instance)
{
    return std::make_shared<wire_render>(wires, instance);
}

}
