#!/bin/bash 
set -e

ANDROID_NDK_ROOT=~/Library/Android/sdk//ndk/22.1.7171670/
#ANDROID_NDK_ROOT=~/Library/Android/sdk//ndk/ndk-bundle/


cmake   -S . \
        -B build.android \
        -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake \
        -DANDROID_ABI=arm64-v8a \
        -DANDROID_PLATFORM=android-24 \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -C build.android
