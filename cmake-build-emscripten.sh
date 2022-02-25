#!/bin/bash 
set -e
set -x
cmake   -S . \
        -B build.emscripten \
        -DCMAKE_TOOLCHAIN_FILE=${EMSDK}/emscripten/main/cmake/Modules/Platform/Emscripten.cmake \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -C build.emscripten


