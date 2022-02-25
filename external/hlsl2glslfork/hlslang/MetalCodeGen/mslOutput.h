// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#pragma once

#include <sstream>

#include "localintermediate.h"
#include "mslCommon.h"
#include "mslStruct.h"
#include "mslSymbol.h"
#include "mslFunction.h"

namespace hlslang {
namespace MetalCodeGen {


class TMslOutputTraverser : public TIntermTraverser
{
private:
	static void traverseSymbol(TIntermSymbol*, TIntermTraverser*);
	static void traverseParameterSymbol(TIntermSymbol *node, TIntermTraverser *it);
	static void traverseConstant(TIntermConstant*, TIntermTraverser*);
	static void traverseImmediateConstant( TIntermConstant *node, TIntermTraverser *it);
	static bool traverseBinary(bool preVisit, TIntermBinary*, TIntermTraverser*);
	static bool traverseUnary(bool preVisit, TIntermUnary*, TIntermTraverser*);
	static bool traverseSelection(bool preVisit, TIntermSelection*, TIntermTraverser*);
	static bool traverseAggregate(bool preVisit, TIntermAggregate*, TIntermTraverser*);
	static bool traverseLoop(bool preVisit, TIntermLoop*, TIntermTraverser*);
	static bool traverseBranch(bool preVisit, TIntermBranch*,  TIntermTraverser*);
	static bool traverseDeclaration(bool preVisit, TIntermDeclaration*, TIntermTraverser*);

	void outputLineDirective (const TSourceLoc& line);
	void traverseArrayDeclarationWithInit(TIntermDeclaration* decl);

public:
	TMslOutputTraverser (TInfoSink& i, std::vector<MslFunction*> &funcList, std::vector<MslStruct*> &sList, std::stringstream& deferredArrayInit, std::stringstream& deferredMatrixInit, ETargetVersion version, unsigned options);
	MslStruct *createStructFromType( TType *type );
	
	// Info Sink
	TInfoSink& infoSink;

	// Global function
	MslFunction *global;

	// Current function
	MslFunction *current;

	// Are we currently generating code?
	bool generatingCode;

	// List of functions
	std::vector<MslFunction*> &functionList;

	// List of structures
	std::vector<MslStruct*> &structList;

	// Map of structure names to GLSL structures
	std::map<std::string,MslStruct*> structMap;

	// Persistent data for collecting indices
	std::vector<int> indexList;
	
	// Code to initialize global arrays when we can't use GLSL 1.20+ syntax
	std::stringstream& m_DeferredArrayInit;
	// Code to initialize global matrices when we can't use GLSL 1.20+ syntax
	std::stringstream& m_DeferredMatrixInit;

	TSourceLoc m_LastLineOutput;
	unsigned swizzleAssignTempCounter;
	ETargetVersion m_TargetVersion;
	bool m_UsePrecision;
	bool m_ArrayInitWorkaround;
};

}}
