// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "mslCrossCompiler.h"

#include "mslOutput.h"
#include "mslTypeSamplers.h"
#include "mslPropagateMutable.h"
#include "mslLinker.h"

namespace hlslang {
namespace MetalCodeGen {

MslCrossCompiler::MslCrossCompiler(EShLanguage l)
:	language(l)
,	m_ASTTransformed(false)
,	m_MslProduced(false)
{
	linker = new MslLinker(infoSink);
}

MslCrossCompiler::~MslCrossCompiler()
{
   for ( std::vector<MslFunction*>::iterator it = functionList.begin() ; it != functionList.end(); it++)
   {
      delete *it;
   }

   for ( std::vector<MslStruct*>::iterator it = structList.begin() ; it != structList.end(); it++)
   {
      delete *it;
   }
   delete linker;
}


void MslCrossCompiler::TransformAST (TIntermNode *root)
{
	m_ASTTransformed = true;
	PropagateSamplerTypes (root, infoSink);
	PropagateMutableUniforms (root, infoSink);
}

void MslCrossCompiler::ProduceMSL (TIntermNode *root, ETargetVersion version, unsigned options)
{
	m_MslProduced = true;
	TMslOutputTraverser glslTraverse (infoSink, functionList, structList, m_DeferredArrayInit, m_DeferredMatrixInit, version, options);
	root->traverse(&glslTraverse);
}

}}
