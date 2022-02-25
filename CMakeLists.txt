
cmake_minimum_required(VERSION 3.1)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_BUILD_TYPE RelWithDebInfo )

project(MetalNes LANGUAGES C CXX)


set(APP_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/app)
set(COMMON_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/source)
set(EXTERNAL_DIR ${CMAKE_CURRENT_SOURCE_DIR}/external)
set(IMGUI_SOURCE_DIR ${EXTERNAL_DIR}/imgui)
set(DATA_DIR ${CMAKE_CURRENT_SOURCE_DIR}/data)



add_subdirectory(${EXTERNAL_DIR}/hlsl2glslfork)

    

set(IMGUI_SOURCE
        ${IMGUI_SOURCE_DIR}/imgui.cpp
        ${IMGUI_SOURCE_DIR}/imgui_draw.cpp
        ${IMGUI_SOURCE_DIR}/imgui_widgets.cpp
        ${IMGUI_SOURCE_DIR}/imgui_demo.cpp
        ${IMGUI_SOURCE_DIR}/imgui_tables.cpp
        )

        
set(TRIANGLE_SOURCE
        ${EXTERNAL_DIR}/triangle/triangle.c
        ${EXTERNAL_DIR}/triangle/tricall.c
      )


set(COMMON_SOURCE
        ${COMMON_SOURCE_DIR}/Core/Matrix.cpp
        ${COMMON_SOURCE_DIR}/Core/File.cpp
        ${COMMON_SOURCE_DIR}/Core/DateTime.cpp
        ${COMMON_SOURCE_DIR}/Core/Log.cpp
        ${COMMON_SOURCE_DIR}/Core/Path.cpp
        ${COMMON_SOURCE_DIR}/Core/StopWatch.cpp
        ${COMMON_SOURCE_DIR}/Core/String.cpp
        ${COMMON_SOURCE_DIR}/metalnes/audio_device.cpp
        ${COMMON_SOURCE_DIR}/metalnes/chiprender.cpp
        ${COMMON_SOURCE_DIR}/metalnes/logger.cpp
        ${COMMON_SOURCE_DIR}/metalnes/nesdisasm.cpp
        ${COMMON_SOURCE_DIR}/metalnes/nesrom.cpp
        ${COMMON_SOURCE_DIR}/metalnes/raster_device.cpp
        ${COMMON_SOURCE_DIR}/metalnes/serializer.cpp
        ${COMMON_SOURCE_DIR}/metalnes/system.cpp
        ${COMMON_SOURCE_DIR}/metalnes/triangulate.cpp
        ${COMMON_SOURCE_DIR}/metalnes/wire_defs.cpp
        ${COMMON_SOURCE_DIR}/metalnes/wire_gui.cpp
        ${COMMON_SOURCE_DIR}/metalnes/wire_module.cpp
        ${COMMON_SOURCE_DIR}/metalnes/wire_node_resolver.cpp
        ${COMMON_SOURCE_DIR}/render/context.cpp
        ${COMMON_SOURCE_DIR}/imgui_support.cpp
        ${COMMON_SOURCE_DIR}/Application.cpp
        ${COMMON_SOURCE_DIR}/UnitTests.cpp
        ${COMMON_SOURCE_DIR}/AudioFileWriter.cpp
      )


if (APPLE)
    set(PLATFORM_SOURCE
        ${COMMON_SOURCE_DIR}/Platform/OSX/CoreAudio.mm
      )

elseif (UNIX)
    set(PLATFORM_SOURCE
      )


elseif (WIN32)
    set(PLATFORM_SOURCE
      )

else()
    message(FATAL_ERROR "Target platform not supported")
endif()



include_directories(
        ${COMMON_SOURCE_DIR}
    )


if (APPLE)


    add_executable(MetalNes
        ${TRIANGLE_SOURCE}
        ${IMGUI_SOURCE}
        ${COMMON_SOURCE}
        ${PLATFORM_SOURCE}
    #    ${APP_SOURCE_DIR}/OSX/main.mm
        ${APP_SOURCE_DIR}/Linux/main.cpp
        )

    target_link_libraries(
        MetalNes
        hlsl2glsl
        "-framework CoreGraphics"
        "-framework Foundation"
        "-framework AppKit"
        "-framework AudioToolbox"
        "-framework CoreAudio"
        "-framework Metal"
        "-framework MetalKit"
        "-framework GameController"
    )
    

    set_property (TARGET MetalNes APPEND_STRING PROPERTY COMPILE_FLAGS "-fobjc-arc")

elseif (EMSCRIPTEN)


    include_directories(
        ${INCLUDE_DIRS}
    )
    
    SET(APP_NAME ${CMAKE_PROJECT_NAME} )

    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -s USE_ZLIB -Wno-deprecated-register -Wno-version-check")



    add_executable(MetalNes
        ${TRIANGLE_SOURCE}
        ${IMGUI_SOURCE}
        ${COMMON_SOURCE}
        ${PLATFORM_SOURCE}
    #    ${COMMON_SOURCE_DIR}/Platform/OSX/main.mm
        ${APP_SOURCE_DIR}/Linux/main.cpp
        ${COMMON_SOURCE_DIR}/render/gles/context_gles.cpp
#        ${APP_SOURCE_DIR}/emscripten/emscripten_main.cpp

        )


    # Include libraries needed for lib
    target_link_libraries(${APP_NAME}
                ${LIBS}
                hlsl2glsl
            )
            
#    set(SHELL_FILE ${CMAKE_SOURCE_DIR}/app/emscripten/shell_minimal.html )
    set(SHELL_FILE ${CMAKE_SOURCE_DIR}/app/emscripten/emscripten_shell.html )

    set_target_properties(${APP_NAME} PROPERTIES LINK_FLAGS
            "--preload-file ${CMAKE_SOURCE_DIR}/data@/assets \
            --shell-file ${SHELL_FILE} \
             -emrun \
             -s TOTAL_MEMORY=536870912 \
             -s LLD_REPORT_UNDEFINED \
             -s NO_EXIT_RUNTIME=0 \
             -s DEMANGLE_SUPPORT=1 \
             -s WASM=1 \
             -s ASSERTIONS=1 \
             -s USE_WEBGL2=1 \
             -s USE_SDL=2 \
             -s MIN_WEBGL_VERSION=2 \
             -s MAX_WEBGL_VERSION=2 \
             -s DISABLE_DEPRECATED_FIND_EVENT_TARGET_BEHAVIOR=1 \
             -mnontrapping-fptoint \
             -lopenal"
            )

    set(CMAKE_EXECUTABLE_SUFFIX ".html")
#    set_target_properties(${APP_NAME} PROPERTIES OUTPUT_NAME "metalnes.html")





elseif (UNIX)

    target_link_libraries(
        MetalNes
        hlsl2glsl
        pthread
    )


elseif (WIN32)

    target_link_libraries(
        MetalNes
        hlsl2glsl
    )
    
else()
    message(FATAL_ERROR "Target platform not supported")
endif()


