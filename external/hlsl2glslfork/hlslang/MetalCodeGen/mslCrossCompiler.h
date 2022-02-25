// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#pragma once


#include "../Include/Common.h"

#include "mslFunction.h"
#include "mslStruct.h"

namespace hlslang {
namespace MetalCodeGen {
    
class MslLinker;

class MslCrossCompiler
{
public:   
   MslCrossCompiler(EShLanguage l);
   ~MslCrossCompiler();

    bool IsVertex() const {return language == EShLangVertex;}
    bool IsFragment() const {return language == EShLangFragment;}

   EShLanguage getLanguage() const { return language; }
   TInfoSink& getInfoSink() { return infoSink; }

   void TransformAST (TIntermNode* root);
   void ProduceMSL (TIntermNode* root, ETargetVersion version, unsigned options);
   bool IsASTTransformed() const { return m_ASTTransformed; }
   bool IsMslProduced() const { return m_MslProduced; }

   MslLinker* GetLinker() { return linker; }

private:
	EShLanguage language;
	bool m_ASTTransformed;
	bool m_MslProduced;

public:
	MslLinker* linker;
	TInfoSink infoSink;
	std::vector<MslFunction*> functionList;
	std::vector<MslStruct*> structList;
	std::stringstream m_DeferredArrayInit;
	std::stringstream m_DeferredMatrixInit;
};


}}
