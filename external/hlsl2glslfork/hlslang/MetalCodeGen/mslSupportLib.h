// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#pragma once

#include <set>
#include <string>
#include <map>
#include "../Include/intermediate.h"
#include "../../include/hlsl2glsl.h" // for ETargetVersion

namespace hlslang {

namespace MetalCodeGen {
    

struct CodeMap
{
    void insert(TOperator op,  std::string str)
    {
        _map[op] = str;
    }
    
    std::string GetSupportCode(TOperator op)
    {
        auto it = _map.find(op);
        if (it == _map.end()) {
            return "";
        }
        return it->second;
    }
    
    std::map<TOperator,std::string> _map;
};


    
CodeMap *createMetalSupportLibrary(ETargetVersion targetVersion);


}
}
