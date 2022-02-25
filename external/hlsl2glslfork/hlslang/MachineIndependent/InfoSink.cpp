// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.

#include "../Include/InfoSink.h"
#include <string.h>
namespace hlslang {


void TInfoSinkBase::append(const char *s)           
{
   checkMem(strlen(s)); 
   sink.append(s); 
}

void TInfoSinkBase::append(int count, char c)       
{
   checkMem(count);         
   sink.append(count, c); 
}

void TInfoSinkBase::append(const std::string& t) 
{
   checkMem(t.size());  
   sink.append(t); 
}

void TInfoSinkBase::append(const TString& t)
{
   checkMem(t.size());  
   sink.append(t.c_str()); 
}

}
