// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#ifndef HLSL_SUPPORT_LIB_H
#define HLSL_SUPPORT_LIB_H

#include <set>
#include <string>
#include "../Include/intermediate.h"
#include "../../include/hlsl2glsl.h" // for ETargetVersion

namespace hlslang {

void initializeHLSLSupportLibrary(ETargetVersion targetVersion);
void finalizeHLSLSupportLibrary();

typedef std::set<std::string> ExtensionSet;

std::string getHLSLSupportCode (TOperator op, ExtensionSet& extensions, bool vertexShader, bool gles);

}
#endif //HLSL_SUPPORT_LIB_H
