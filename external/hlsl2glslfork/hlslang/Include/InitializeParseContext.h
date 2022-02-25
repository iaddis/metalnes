// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#ifndef __INITIALIZE_PARSE_CONTEXT_INCLUDED_
#define __INITIALIZE_PARSE_CONTEXT_INCLUDED_

namespace hlslang {
bool InitializeParseContextIndex();
bool InitializeGlobalParseContext();
bool FreeParseContext();
bool FreeParseContextIndex();
}

#endif // __INITIALIZE_PARSE_CONTEXT_INCLUDED_
