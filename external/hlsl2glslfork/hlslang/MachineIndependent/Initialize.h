// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#ifndef _INITIALIZE_INCLUDED_
#define _INITIALIZE_INCLUDED_

#include "../Include/Common.h"
#include "SymbolTable.h"
#include "../../include/hlsl2glsl.h"

namespace hlslang {

typedef TVector<TString> TBuiltInStrings;

class TBuiltIns
{
public:
   POOL_ALLOCATOR_NEW_DELETE(GlobalPoolAllocator)
   void initialize();
   TBuiltInStrings* getBuiltInStrings()
   {
      return builtInStrings;
   }
	
private:

   TBuiltInStrings builtInStrings[EShLangCount];
};

void IdentifyBuiltIns(EShLanguage, TSymbolTable&);

}

#endif // _INITIALIZE_INCLUDED_

