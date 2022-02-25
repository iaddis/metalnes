
#define CATCH_CONFIG_RUNNER  // This tells Catch to provide a main() - only do this in one cpp file
#define CATCH_CONFIG_NO_POSIX_SIGNALS
#include "../external/Catch2/single_include/catch2/catch.hpp"

#include "UnitTests.h"
#include "imgui_support.h"


static Catch::Session s_session; // There must be exactly one instance

void UnitTestsSetArgs(int argc, const char * argv[])
{
    s_session.applyCommandLine(argc, argv);
}

int RunUnitTests()
{
    s_session.config().showDurations();
    int result = s_session.run();
    return result;
}



static bool _window_open_unittests =  true;
void onGuiUnitTests()
{
    ImGui::SetNextWindowSize(ImVec2(500, 440), ImGuiCond_FirstUseEver);
    
    ImGuiWindowFlags window_flags = 0; //ImGuiWindowFlags_MenuBar;
    //  ImGui::SetNextWindowPos(ImVec2(0,0)); //, ImGuiCond_Always);
    //    ImGui::SetNextWindowContentSize(ImVec2(800,600)); //, ImGuiCond_Always);
    if (!ImGui::Begin("Unit Tests", &_window_open_unittests, window_flags))
    {
        ImGui::End();
        return;
    }
    
    if (ImGui::Button("Run"))
    {
        RunUnitTests();
    }
    
    
    
    ImGui::End();
}


