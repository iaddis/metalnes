// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "hlslCrossCompiler.h"

#include "glslOutput.h"
#include "typeSamplers.h"
#include "propagateMutable.h"
#include "hlslLinker.h"

namespace hlslang {

HlslCrossCompiler::HlslCrossCompiler(EShLanguage l)
:	language(l)
,	m_ASTTransformed(false)
,	m_GlslProduced(false)
{
	linker = new HlslLinker(infoSink);
}

HlslCrossCompiler::~HlslCrossCompiler()
{
   for ( std::vector<GlslFunction*>::iterator it = functionList.begin() ; it != functionList.end(); it++)
   {
      delete *it;
   }

   for ( std::vector<GlslStruct*>::iterator it = structList.begin() ; it != structList.end(); it++)
   {
      delete *it;
   }
   delete linker;
}


void HlslCrossCompiler::TransformAST (TIntermNode *root)
{
	m_ASTTransformed = true;
	PropagateSamplerTypes (root, infoSink);
	PropagateMutableUniforms (root, infoSink);
}

void HlslCrossCompiler::ProduceGLSL (TIntermNode *root, ETargetVersion version, unsigned options)
{
	m_GlslProduced = true;
	TGlslOutputTraverser glslTraverse (infoSink, functionList, structList, m_DeferredArrayInit, m_DeferredMatrixInit, version, options);
	root->traverse(&glslTraverse);
}

}
