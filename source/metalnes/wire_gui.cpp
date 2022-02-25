

#include "wire_defs.h"
#include "wire_module.h"
#include "wire_gui.h"
#include <iostream>
#include <unordered_set>
#include "Core/String.h"
#include "chiprender.h"


namespace metalnes {


class main_wire_gui : public wire_gui
{
    std::vector<chip_render_ptr> _chip_render_list;

public:
    
    main_wire_gui(wire_module_ptr wires)
    :_wires(wires)
    {
        
        addInstanceRenderer("cpu");
        addInstanceRenderer("ppu");
    }
    
    void addInstanceRenderer(std::string name)
    {
        auto instance = _wires->lookupInstance(name);
        if (instance) {
            _chip_render_list.push_back( CreateWireRender(_wires, instance) );
        }
    }
    
    virtual ~main_wire_gui()
    {
        
    }

    void onGuiNodeList();
    void onGuiNodeInfo();
    void onGuiCanvas();
    
    virtual void onGui(render::ContextPtr context) override;
    
protected:
    wire_module_ptr _wires;
    
    bool                _ui_node_update = true;
    std::string         _ui_node_search;
    std::vector<nodeID> _ui_nodes;
    std::unordered_set<nodeID> _ui_selected_nodes;
    ImGuiTextFilter     _ui_nodefilter;


    bool _window_open_nodelist = false;
    bool _window_open_nodeinfo = false;
    bool _window_open_canvas = false;
    
    wire_instance_ptr _selected_instance;
};



void gui_draw_instance(wire_instance_ptr instance, float scale)
{
    ImGui::SetWindowFontScale(scale);


    ImVec2 button_size { 20 * scale, 14 * scale };
    
    float line_height = 18 * scale;

    float chip_width = 82 * scale;
    float chip_left = 150 * scale;

    
    auto defs = instance->defs;    size_t count = defs->pindefs.size() / 2;

    
    auto root_pos = ImGui::GetCursorPos();
    



    
    float chip_height = count * line_height + line_height;
    
    ImGui::SetCursorPosX(         root_pos.x + chip_left  );

//    root_pos.x += chip_left;
//    ImGui::SetCursorPos(root_pos);

    ImGui::BeginGroup();
    ImGui::PushStyleColor(ImGuiCol_Button, 0xFF202020);
    std::string label = instance->name + "\n" + instance->type;
    ImGui::Button(  label.c_str(), ImVec2( chip_width, chip_height ));
    ImGui::PopStyleColor(1);
    ImGui::EndGroup();
    ImGui::SameLine();


    ImGui::SetCursorPosX(         root_pos.x + 0 * scale  );

    ImGui::BeginGroup();
    ImGui::SetCursorPosY(         ImGui::GetCursorPosY() + line_height / 2 );
    for (size_t i=0; i < count; i++)
    {
        auto current_pos = ImGui::GetCursorPos();
        
        auto sz1 = ImGui::CalcTextSize(defs->pindefs[i].name.c_str());
        sz1.x = chip_left -  sz1.x - button_size.x - 16 * scale;
        if (sz1.x > 0)
            ImGui::InvisibleButton("", sz1);
        ImGui::SameLine();
        ImGui::TextUnformatted(defs->pindefs[i].name.c_str());
        
        
        ImGui::NewLine();
        current_pos.y += line_height;
        ImGui::SetCursorPos(current_pos);
    }
    ImGui::SetCursorPosY(         ImGui::GetCursorPosY() + line_height / 2 );
    ImGui::EndGroup();
    ImGui::SameLine();

    ImGui::SetCursorPosX(         root_pos.x + chip_left - button_size.x );

    ImGui::BeginGroup();
    ImGui::SetCursorPosY(         ImGui::GetCursorPosY() + line_height / 2 );
    
    auto wires = instance->wires.lock();
    for (size_t i=0; i < count; i++)
    {
        auto current_pos = ImGui::GetCursorPos();

        int pin = defs->pindefs[i].pin;
        int pin_node = instance->pin_nodes[pin];
        bool pin_state = wires->isNodeHigh(pin_node);
        
        ImGui::PushStyleColor(ImGuiCol_Button, pin_state ? 0xFF2020FF : 0xFF808080);
        ImGui::PushStyleColor(ImGuiCol_Text, 0xFF000000);
        ImGui::Button(  std::to_string(pin).c_str(), button_size );
        ImGui::PopStyleColor(2);
        ImGui::SameLine();
        
        ImGui::NewLine();
        current_pos.y += line_height;
        ImGui::SetCursorPos(current_pos);
        
        //ImGui::GetCursorScreenPos()


    }
    ImGui::SetCursorPosY(         ImGui::GetCursorPosY() + line_height / 2 );
    ImGui::EndGroup();
    
    ImGui::SameLine();


    ImGui::SetCursorPosX(        root_pos.x + chip_left + chip_width );
    
    ImGui::BeginGroup();

    ImGui::SetCursorPosY(         ImGui::GetCursorPosY() + line_height / 2 );
    for (size_t i=count; i < count * 2; i++)
    {
        auto current_pos = ImGui::GetCursorPos();
        
        int pin = defs->pindefs[i].pin;
        int pin_node = instance->pin_nodes[pin];
        bool pin_state = wires->isNodeHigh(pin_node);

        
        
        ImGui::PushStyleColor(ImGuiCol_Button, pin_state ? 0xFF2020FF : 0xFF808080);
        ImGui::PushStyleColor(ImGuiCol_Text, 0xFF000000);
        ImGui::Button(  std::to_string(pin).c_str(), button_size );
        ImGui::PopStyleColor(2);
        
        
        ImGui::NewLine();
        current_pos.y += line_height;
        ImGui::SetCursorPos(current_pos);
    }
    ImGui::SetCursorPosY(         ImGui::GetCursorPosY() + line_height / 2 );
    ImGui::EndGroup();

    ImGui::SameLine();
    
    ImGui::SetCursorPosX(         root_pos.x + chip_left + chip_width + button_size.x );
    ImGui::BeginGroup();
    ImGui::SetCursorPosY(         ImGui::GetCursorPosY() + line_height / 2 );
    for (size_t i=count; i < count * 2; i++)
    {
        auto current_pos = ImGui::GetCursorPos();

        ImGui::TextUnformatted(defs->pindefs[i].name.c_str());
        
        ImGui::NewLine();
        current_pos.y += line_height;
        ImGui::SetCursorPos(current_pos);
    }
    //    ImGui::EndChild();

    ImGui::EndGroup();
    ImGui::SetCursorPosY(         ImGui::GetCursorPosY() + line_height / 2 );
    ImGui::SameLine();
    
//    root_pos.x += chip_left;
//    ImGui::SetCursorPos(root_pos);

    
    ImGui::SetWindowFontScale(1.0f);

//    ImGui::PopStyleVar(2);

}

void gui_draw_chip(wire_module * wires)
{
    ImGuiWindowFlags window_flags = 0; //ImGuiWindowFlags_MenuBar;
    //  ImGui::SetNextWindowPos(ImVec2(0,0)); //, ImGuiCond_Always);
//    ImGui::SetNextWindowContentSize(ImVec2(800,600)); //, ImGuiCond_Always);
    if (!ImGui::Begin( "component", NULL, window_flags))
    {
        ImGui::End();
        return;
    }
    
//    ImGui::Text("hello\n");

//    ImDrawList* draw_list = ImGui::GetWindowDrawList();


    static float _scale = 1.0f;
    
    ImGui::SliderFloat("scale",&_scale, 0.1, 4.0f);
    
    
    auto oldpad =     ImGui::GetStyle().FramePadding ;
    ImGui::GetStyle().FramePadding = ImVec2(0,0);


    
//    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0,0));
//    ImGui::PushStyleVar(ImGuiStyleVar_CellPadding, ImVec2(0,0));

    int x =0;
    for (auto instance : wires->getAllInstances())
    {
        gui_draw_instance(instance, _scale);

        if (++x == 4) {
            ImGui::NewLine();
            x = 0;
        }
        
//        ImGui::Spacing();
    }
    
    ImGui::GetStyle().FramePadding = oldpad;

    
    
    ImGui::End();

}



static bool draw_node_table(wire_module_ptr wires, const std::vector<nodeID> &list, std::unordered_set<nodeID> &selected_nodes)
{
    //    const float TEXT_BASE_HEIGHT = ImGui::GetTextLineHeightWithSpacing();
    
    bool node_checked = false;
    
    ImGuiTableFlags flags = ImGuiTableFlags_ScrollY | ImGuiTableFlags_RowBg | ImGuiTableFlags_BordersOuter | ImGuiTableFlags_BordersV | ImGuiTableFlags_Resizable | ImGuiTableFlags_Reorderable | ImGuiTableFlags_Hideable;
    
    //    static ImGuiTableFlags flags = ImGuiTableFlags_ScrollY | ImGuiTableFlags_RowBg | ImGuiTableFlags_BordersOuter | ImGuiTableFlags_BordersV | ImGuiTableFlags_Resizable | ImGuiTableFlags_Reorderable | ImGuiTableFlags_Hideable;
    
    
    // When using ScrollX or ScrollY we need to specify a size for our table container!
    // Otherwise by default the table will fit all available space, like a BeginChild() call.
    //  ImVec2 size = ImVec2(0, TEXT_BASE_HEIGHT * 8);
    const float TEXT_BASE_WIDTH = 16.0f;
    ImVec2 size = ImVec2(0,0);
    if (ImGui::BeginTable("##node_table", 4, flags, size))
    {
        ImGui::TableSetupScrollFreeze(0, 1); // Make top row always visible
//        ImGui::TableSetupColumn("X", ImGuiTableColumnFlags_WidthFixed, TEXT_BASE_WIDTH * 1);
        ImGui::TableSetupColumn("ID", ImGuiTableColumnFlags_WidthFixed, TEXT_BASE_WIDTH * 5);
        ImGui::TableSetupColumn("State", ImGuiTableColumnFlags_WidthFixed, TEXT_BASE_WIDTH * 1);
        ImGui::TableSetupColumn("Flags", ImGuiTableColumnFlags_WidthFixed, TEXT_BASE_WIDTH * 2);
        ImGui::TableSetupColumn("Name", ImGuiTableColumnFlags_None);
        ImGui::TableHeadersRow();
        
        // Demonstrate using clipper for large vertical lists
        ImGuiListClipper clipper;
        clipper.Begin( (int)list.size() );
        while (clipper.Step())
        {
            for (int row = clipper.DisplayStart; row < clipper.DisplayEnd; row++)
            {
                nodeID nn = list[row];
                ImGui::PushID(nn);

                
                ImGui::TableNextRow();

                bool checked =  selected_nodes.count(nn) > 0;

                
//                ImGui::TableNextColumn();
//                if (ImGui::Checkbox("", &checked))
//                {
//                    if (!checked) selected_nodes.erase(nn);
//                    else          selected_nodes.insert(nn);
//                    node_checked = true;
//                }
                
                ImGui::TableNextColumn();
                ImGui::Text("%d", nn);
                ImGui::TableNextColumn();
                ImGui::Text("%d", wires->isNodeHigh(nn) );
                ImGui::TableNextColumn();
                ImGui::Text("%02X", wires->getNodeFlags(nn) );
                ImGui::TableNextColumn();
                
                const char *name = wires->getNodeName(nn);
                if (ImGui::Selectable(name, checked, ImGuiSelectableFlags_SpanAllColumns))
                {
                    
                    if (ImGui::GetIO().KeyCtrl)
                    {
                        if (checked) selected_nodes.erase(nn);
                        else          selected_nodes.insert(nn);
                    }
                    else //if (!(selection_mask & (1 << node_clicked))) // Depending on selection behavior you want, may want to preserve selection when clicking on item that is part of the selection
                    {
                        selected_nodes.clear();
                        selected_nodes.insert(nn);
                    }

                    node_checked = true;
                }
                
//                ImGui::Text("%s",  );
                
                ImGui::PopID();
                


            }
        }
        ImGui::EndTable();
    }
    return node_checked;
    
}

//static void filter_node_names(ImGuiTextFilter &filter, wire_module_ptr wires, const std::vector<nodeID> &input_list, std::vector<nodeID> &output_list,
//                              const std::unordered_set<nodeID> &selected_nodes)
//{
//    if (!filter.IsActive())
//    {
//        output_list.insert( output_list.end(), input_list.begin(), input_list.end());
//    }
//    else
//    {
//        for (auto nn : input_list)
//        {
//            if (selected_nodes.count(nn))
//            {
//                continue;
//            }
//                
//            const char *name = wires->getNodeName(nn);
//            if (name && filter.PassFilter(name))
//            {
//                output_list.push_back(nn);
//            }
//        }
//        
//    }
//}

static void filter_node_names(ImGuiTextFilter &filter, wire_module_ptr wires, const std::vector<nodeID> &input_list, std::vector<nodeID> &output_list)
{
    if (!filter.IsActive())
    {
        output_list.insert( output_list.end(), input_list.begin(), input_list.end());
    }
    else
    {
        for (auto nn : input_list)
        {
            const char *name = wires->getNodeName(nn);
            if (name && filter.PassFilter(name))
            {
                output_list.push_back(nn);
            }
        }
        
    }
}


//static void filter_nodes(std::vector<nodeID> &output_list, const std::vector<nodeID> &input_list,
//                              const std::unordered_set<nodeID> &selected_nodes)
//{
//    for (auto nn : input_list)
//    {
//        if (selected_nodes.count(nn))
//        {
//            output_list.push_back(nn);
//        }
//    }
//}


void main_wire_gui::onGuiNodeList()
{
    if (!_window_open_nodelist)
        return;
    
    
    {
        ImGuiWindowFlags window_flags = ImGuiWindowFlags_MenuBar;
        //  ImGui::SetNextWindowPos(ImVec2(0,0)); //, ImGuiCond_Always);
        //    ImGui::SetNextWindowContentSize(ImVec2(800,600)); //, ImGuiCond_Always);
        if (ImGui::Begin("All Nodes", &_window_open_nodelist, window_flags))
        {
            
            if (ImGui::BeginMenuBar())
            {
                if (ImGui::BeginMenu("View"))
                {
                    
                    for (auto chip : _chip_render_list)
                    {
                        if (ImGui::MenuItem( chip->GetName(), NULL,  chip->IsVisible() ))
                        {
                            chip->SetVisible( !chip->IsVisible() );
                        }
                    }
                    
                    
                    ImGui::EndMenu();

                }
                
                ImGui::EndMenuBar();

            }
            
            
            if (_ui_nodefilter.Draw("Filter:")) _ui_node_update = true;
            if (draw_node_table(_wires, _ui_nodes, _ui_selected_nodes)) _ui_node_update = true;

            if (_ui_node_update)
            {
                _ui_nodes.clear();
//                filter_nodes(_ui_nodes, allNodes(), _ui_selected_nodes );
//                filter_node_names(_ui_nodefilter, this, allNodes(), _ui_nodes, _ui_selected_nodes);
                filter_node_names(_ui_nodefilter, _wires, _wires->allNodes(), _ui_nodes);
                _ui_node_update = false;
                
                
                for (auto chip : _chip_render_list)
                {
                    chip->setSelectedNodes(_ui_selected_nodes);
                }

                
            }
        }
        ImGui::End();
    }

}

//
//static void print_node_flags(std::ostream &os, int flags)
//{
//    if (flags & (node_flags::node_gnd))
//    {
//        os << "|gnd";
//    }
//
//    if (flags & (node_flags::node_pwr))
//    {
//        os << "|pwr";
//    }
//
//    if (flags & (node_flags::node_set_high))
//    {
//        os << "|set_high";
//    }
//
//    if (flags & (node_flags::node_set_low))
//    {
//        os << "|set_low";
//    }
//
//
//    if (flags & (node_flags::node_pull_up))
//    {
//        os << "|pullup";
//    }
//
//
//
//    if (flags & (node_flags::node_forcecompute))
//    {
//        os << "|forcecompute";
//    }
//}




static void print_node_name_value(wire_module_ptr wires, nodeID nn)
{
    ImGui::Text("%s#%d (%d)", wires->getNodeName(nn),  nn, wires->isNodeHigh(nn));
    ImGui::SameLine();
}

//static void print_transdef(wire_module_ptr wires, const transdef &td)
//{
//    print_node_name_value(wires, td.gate.node_id);
//    ImGui::Text("==>{");
//    ImGui::SameLine();
//    print_node_name_value(wires, td.c1.node_id);
//    ImGui::Text(" <-> ");
//    ImGui::SameLine();
//    print_node_name_value(wires, td.c2.node_id);
//    ImGui::Text("}");
//    ImGui::SameLine();
//    ImGui::Text("\n");
//
//}


void main_wire_gui::onGuiNodeInfo()
{
    if (!_window_open_nodeinfo)
        return;
    
    ImGuiWindowFlags window_flags = ImGuiWindowFlags_MenuBar;
    //  ImGui::SetNextWindowPos(ImVec2(0,0)); //, ImGuiCond_Always);
    //    ImGui::SetNextWindowContentSize(ImVec2(800,600)); //, ImGuiCond_Always);
    if (ImGui::Begin("NodeInfo", &_window_open_nodeinfo, window_flags))
    {
        
        /*
        if (ImGui::BeginMenuBar())
        {
            if (ImGui::BeginMenu("View"))
            {
                
                for (auto chip : _chip_render_list)
                {
                    if (ImGui::MenuItem( chip->GetName(), NULL,  chip->IsVisible() ))
                    {
                        chip->SetVisible( !chip->IsVisible() );
                    }
                }
                
                
                ImGui::EndMenu();

            }
            
            ImGui::EndMenuBar();

        }
         */
        
        if (_ui_selected_nodes.empty())
        {
            ImGui::Text("No nodes selected\n");
        }
        else
        {
            for (auto nn : _ui_selected_nodes)
            {
//                const char *name = _wires->getNodeName(nn);
//                bool state = _wires->isNodeHigh(nn);
//                int flags = _wires->getNodeFlags(nn);
                
                print_node_name_value(_wires, nn);;
//                ImGui::Text("%s#%d %d %02X\n", name, nn, state, flags);
                ImGui::Text("\n");
                

//                auto maindefs = _wires->getDefs();
//                
//                for (auto &module : maindefs->modules)
//                {
//                    auto defs = module.defs;
//                    
//                    for (auto &td : defs->transdefs)
//                    {
//                        if (td.gate.node_id == nn) {
//                            print_transdef(_wires, td);
//                        }
//                    }
//                    
//                    for (auto &td : defs->transdefs)
//                    {
//                        if (td.c1.node_id == nn || td.c2.node_id == nn) {
//                            print_transdef(_wires, td);
//                        }
//                    }
//                }
                
                ImGui::Text("\n");

            }

            
        }
        
    }
    ImGui::End();

}




void main_wire_gui::onGuiCanvas()
{
    if (!_window_open_canvas)
        return;
    
    ImGui::SetNextWindowSize(ImVec2(500, 440), ImGuiCond_FirstUseEver);
    
    ImGuiWindowFlags window_flags = ImGuiWindowFlags_MenuBar;
    //  ImGui::SetNextWindowPos(ImVec2(0,0)); //, ImGuiCond_Always);
    //    ImGui::SetNextWindowContentSize(ImVec2(800,600)); //, ImGuiCond_Always);
    if (!ImGui::Begin("Canvas", &_window_open_canvas, window_flags))
    {
        ImGui::End();
        return;
    }

    // menu
    {
        if (ImGui::BeginMenuBar())
        {
            if (ImGui::BeginMenu("File"))
            {
                if (ImGui::MenuItem("Close")) _window_open_canvas = false;
                ImGui::EndMenu();
            }
            ImGui::EndMenuBar();
        }
    }
    
    // Left
    {
        ImGui::BeginChild("instance-list", ImVec2(150, 0), true);
        
        const auto &instances = _wires->getAllInstances();
        for (auto instance : instances)
        {
            if (ImGui::Selectable( instance->label.c_str(), instance == _selected_instance ))
                _selected_instance = instance;

        }
        ImGui::EndChild();
    }
    
    ImGui::SameLine();
    
    //right 
    {
        ImGui::BeginGroup();
        ImGui::BeginChild("instance-view", ImVec2(0, -ImGui::GetFrameHeightWithSpacing())); // Leave room for 1 line below us

        
        ImDrawList* draw_list = ImGui::GetWindowDrawList();
        ImVec2 canvas_sz = ImGui::GetContentRegionAvail();   // Resize canvas to what's available
        if (canvas_sz.x < 50.0f) canvas_sz.x = 50.0f;
        if (canvas_sz.y < 50.0f) canvas_sz.y = 50.0f;

        ImVec2 canvas_p0 = ImGui::GetCursorScreenPos();      // ImDrawList API uses screen coordinates!
        ImVec2 canvas_p1 = ImVec2(canvas_p0.x + canvas_sz.x, canvas_p0.y + canvas_sz.y);

     
    //    Matrix44 projection = ComputeMatrix(canvas_sz);

        
        // update texture
    //    draw(context, projection);

        /*
        draw_list->AddImage(_texture.get(),
                            canvas_p, ImVec2(canvas_p.x + canvas_sz.x, canvas_p.y + canvas_sz.y),
                            ImVec2(0,0), ImVec2(1, 1),
                            ImColor(1.0f,1.0f,1.0f,1.0f)
    //                        IM_COL32(255, 255, 255, 255)
                            );

        draw_list->AddImage(_texture_overlay.get(),
                            canvas_p, ImVec2(canvas_p.x + canvas_sz.x, canvas_p.y + canvas_sz.y),
                            ImVec2(0,0), ImVec2(1, 1),
                            //IM_COL32(255, 255, 255, 64)
                            ImColor(1.0f,1.0f,1.0f,0.5f)

                            );
        */
         draw_list->AddRectFilledMultiColor(canvas_p0, canvas_p1,
                                             IM_COL32(50, 50, 50, 255), IM_COL32(50, 50, 60, 255),
                                            IM_COL32(60, 60, 70, 255), IM_COL32(50, 50, 60, 255));
         draw_list->AddRect(canvas_p0, canvas_p1, IM_COL32(255, 255, 255, 255));

        
    //    ImGui::InvisibleButton("canvas", canvas_sz);
    //    ImVec2 mouse_pos_global = ImGui::GetIO().MousePos;
    //    ImVec2 mouse_pos_canvas = ImVec2(mouse_pos_global.x - canvas_p.x, mouse_pos_global.y - canvas_p.y);
        
        
        
        
    //    float mouse_x =  (mouse_pos_canvas.x) / canvas_sz.x;
    //    float mouse_y =  1.0f - (mouse_pos_canvas.y) / canvas_sz.y;
        
//        static ImVector<rect> rects;
        static bool adding_line;
        ImVec2 scrolling = {0,0};
        auto &io = ImGui::GetIO();
        
        ImGui::InvisibleButton("canvas", canvas_sz, ImGuiButtonFlags_MouseButtonLeft | ImGuiButtonFlags_MouseButtonRight);
        const bool is_hovered = ImGui::IsItemHovered(); // Hovered
    //    const bool is_active = ImGui::IsItemActive();   // Held
        const ImVec2 origin(canvas_p0.x + scrolling.x, canvas_p0.y + scrolling.y); // Lock scrolled origin
        const ImVec2 mouse_pos_in_canvas(io.MousePos.x - origin.x, io.MousePos.y - origin.y);

        // Add first and second point
        if (is_hovered && !adding_line && ImGui::IsMouseClicked(ImGuiMouseButton_Left))
        {
            rect r = { {mouse_pos_in_canvas.x, mouse_pos_in_canvas.y}, {mouse_pos_in_canvas.x, mouse_pos_in_canvas.y} };
//            rects.push_back(r);
            if (_selected_instance)
            _selected_instance->bbox = r;
            adding_line = true;
        }
        if (adding_line)
        {
            if (_selected_instance)
            _selected_instance->bbox.max = point{ mouse_pos_in_canvas.x, mouse_pos_in_canvas.y } ;
//            rects.back().max.x = mouse_pos_in_canvas.x;
//            rects.back().max.y = mouse_pos_in_canvas.y;

            if (!ImGui::IsMouseDown(ImGuiMouseButton_Left))
                adding_line = false;
        }


        draw_list->PushClipRect(canvas_p0, canvas_p1, true);
    //    if (opt_enable_grid)
        {
            const float GRID_STEP = 64.0f;
            for (float x = fmodf(scrolling.x, GRID_STEP); x < canvas_sz.x; x += GRID_STEP)
                draw_list->AddLine(ImVec2(canvas_p0.x + x, canvas_p0.y), ImVec2(canvas_p0.x + x, canvas_p1.y), IM_COL32(200, 200, 200, 40));
            for (float y = fmodf(scrolling.y, GRID_STEP); y < canvas_sz.y; y += GRID_STEP)
                draw_list->AddLine(ImVec2(canvas_p0.x, canvas_p0.y + y), ImVec2(canvas_p1.x, canvas_p0.y + y), IM_COL32(200, 200, 200, 40));
        }
        
        
        for (auto instance : _wires->getAllInstances())
        {
            draw_list->AddRectFilled(
                               ImVec2(origin.x + instance->bbox.min.x, origin.y + instance->bbox.min.y),
                               ImVec2(origin.x + instance->bbox.max.x, origin.y + instance->bbox.max.y),
                               IM_COL32(255, 255, 0, 255)
                                     
                               );

        }
        
        
        
        draw_list->PopClipRect();
        
        ImGui::EndChild();

        if (ImGui::Button("Revert"))
        {
            
        }
        ImGui::SameLine();
        if (ImGui::Button("Save"))
        {
            
        }
        ImGui::EndGroup();

        
    }

    
    
    ImGui::End();
}



void main_wire_gui::onGui(render::ContextPtr context)
{
    
    for (auto chip : _chip_render_list)
    {
        chip->onGui(context);
    }

//    gui_draw_chip( _wires.get() );
    
    onGuiNodeList();
    
    onGuiNodeInfo();
 
    onGuiCanvas();
    
    
    
}



wire_gui_ptr CreateWireGui(wire_module_ptr wires)
{
    return std::make_shared<main_wire_gui>(wires);
}







} // namespace

