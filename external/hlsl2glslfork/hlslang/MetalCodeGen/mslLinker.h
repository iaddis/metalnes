// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#pragma once

#include <sstream>

#include "../Include/Common.h"

#include "mslFunction.h"

namespace hlslang {
namespace MetalCodeGen {

class MslCrossCompiler;


#define MAX_ATTRIB_NAME 64


enum EClassifier 
{
   EClassNone,
   EClassAttrib,
   EClassVarOut,
   EClassVarIn,
   EClassRes,
   EClassUniform
};


class MslLinker
{
public:

   MslLinker(TInfoSink& infoSink);
   ~MslLinker();
	
   TInfoSink& getInfoSink() { return infoSink; }

   bool link(MslCrossCompiler*, const char* entry, ETargetVersion version, unsigned options);

   bool setUserAttribName (EAttribSemantic eSemantic, const char *pName);

   const char* getShaderText() const;
      
   int getUniformCount() const { return (int)uniforms.size(); }
   const ShUniformInfo* getUniformInfo() const  { return (!uniforms.empty()) ? &uniforms[0] : 0; }
   
private:
	typedef std::vector<MslFunction*> FunctionSet;

	std::string stripSemanticModifier(const std::string &semantic, bool warn);
	EAttribSemantic parseAttributeSemantic(const std::string &semantic);
	
	bool addCalledFunctions( MslFunction *func, FunctionSet& funcSet, std::vector<MslFunction*> &funcList);
	void getAttributeName( MslSymbolOrStructMemberBase const* symOrStructMember, std::string &outName, EAttribSemantic sem, int semanticOffset);
	bool getArgumentData2( MslSymbolOrStructMemberBase const* symOrStructMember,
							   EClassifier c, std::string &outName, std::string &ctor, int &pad, int semanticOffset);
	bool getArgumentData( MslSymbol* sym, EClassifier c, std::string &outName,
				  std::string &ctor, int &pad);
	
	bool linkerSanityCheck(MslCrossCompiler* compiler, const char* entryFunc);
	bool buildFunctionLists(MslCrossCompiler* comp, EShLanguage lang, const std::string& entryPoint, MslFunction*& globalFunction, std::vector<MslFunction*>& functionList, FunctionSet& calledFunctions, MslFunction*& funcMain);
	void buildUniformsAndLibFunctions(const FunctionSet& calledFunctions, std::vector<MslSymbol*>& constants, std::set<TOperator>& libFunctions);
	void buildUniformReflection(const std::vector<MslSymbol*>& constants);
	
	void appendDuplicatedInSemantics(MslSymbolOrStructMemberBase* sym, EAttribSemantic sem, std::vector<MslSymbolOrStructMemberBase*>& list);
	void markDuplicatedInSemantics(MslFunction* func);

	void emitLibraryFunctions(struct CodeMap *map, const std::set<TOperator>& libFunctions, EShLanguage lang, bool usePrecision);
	void emitStructs(MslCrossCompiler* comp);
	void emitGlobals(const MslFunction* globalFunction, const std::vector<MslSymbol*>& constants);
	
	void emitInputNonStructParam(MslSymbol* sym, EShLanguage lang, bool usePrecision, EAttribSemantic attrSem, std::stringstream& attrib, std::stringstream& varying, std::stringstream& preamble, std::stringstream& call);
	bool emitInputStruct(const MslStruct* str, std::string parentName, EShLanguage lang, std::stringstream& attrib, std::stringstream& varying, std::stringstream& preamble, const std::string& parentStructSemantic = "");
	void emitInputStructParam(MslSymbol* sym, EShLanguage lang, std::stringstream& attrib, std::stringstream& varying, std::stringstream& preamble, std::stringstream& call);
	void emitOutputNonStructParam(MslSymbol* sym, EShLanguage lang, bool usePrecision, EAttribSemantic attrSem, std::stringstream& varying, std::stringstream& preamble, std::stringstream& postamble, std::stringstream& call);
	void emitOutputStructParam(MslSymbol* sym, EShLanguage lang, bool usePrecision, EAttribSemantic attrSem, std::stringstream& varying, std::stringstream& preamble, std::stringstream& postamble, std::stringstream& call);
	void emitMainStart(const MslCrossCompiler* compiler, const EMslSymbolType retType, MslFunction* funcMain, unsigned options, bool usePrecision, std::stringstream& preamble, const std::vector<MslSymbol*>& constants);
	bool emitReturnValue(const EMslSymbolType retType, MslFunction* funcMain, EShLanguage lang, std::stringstream& varying, std::stringstream& postamble);
	bool emitReturnStruct(MslStruct* retStruct, std::string parentName, EShLanguage lang, std::stringstream& varying, std::stringstream& postamble, const std::string& parentStructSemantic = "");
	
private:
	TInfoSink& infoSink;
	
	// GLSL string for additional extension prepropressor directives.
	// This is used for version and extensions that expose built-in variables.
	std::stringstream shaderPrefix;
	
	// GLSL string for generated shader
	std::stringstream shader;
	
	// Uniform list
	std::vector<ShUniformInfo> uniforms;
	
	// Helper string to store shader text
	mutable std::string bs;
	
	// Table holding the list of user attribute names per semantic
	char userAttribString[EAttrSemCount][MAX_ATTRIB_NAME];
	
	ETargetVersion m_Target;
	unsigned m_Options;
};


}}
