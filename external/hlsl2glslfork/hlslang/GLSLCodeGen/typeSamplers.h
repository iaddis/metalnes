// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#ifndef TYPE_SAMPLERS_H
#define TYPE_SAMPLERS_H

namespace hlslang {

class TIntermNode;
class TInfoSink;

// Iterates over the intermediate tree and sets untyped sampler symbols to have types based on the
// type of texture operation the samplers are used for
void PropagateSamplerTypes (TIntermNode* root, TInfoSink &info);

}

#endif //TYPE_SAMPLERS_H
