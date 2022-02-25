// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#pragma once

namespace hlslang {

class TIntermNode;
class TInfoSink;

namespace MetalCodeGen {

// HLSL allows "modifying" global variables; a concept that does not exist in GLSL.
// So this HLSL:
//
//  uniform float f;
//  void vs() { f *= 2; use f; }
//
// would need to end up like this in GLSL
//
//  uniform float f;
//  float mutable_f; // not uniform!
//  void main() {
//    mutable_f = f;
//    mutable_f *= 2.0;
//    use mutable_f;
//  }
void PropagateMutableUniforms (TIntermNode* root, TInfoSink &info);

}
}
