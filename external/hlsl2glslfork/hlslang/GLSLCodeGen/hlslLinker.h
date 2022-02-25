// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#ifndef HLSL_LINKER_H
#define HLSL_LINKER_H

#include <sstream>

#include "../Include/Common.h"

#include "glslFunction.h"

namespace hlslang {


class HlslCrossCompiler;


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


class HlslLinker
{
public:

   HlslLinker(TInfoSink& infoSink);
   ~HlslLinker();
	
   TInfoSink& getInfoSink() { return infoSink; }

   bool link(HlslCrossCompiler*, const char* entry, ETargetVersion version, unsigned options);

   bool setUserAttribName (EAttribSemantic eSemantic, const char *pName);

   const char* getShaderText() const;
      
   int getUniformCount() const { return (int)uniforms.size(); }
   const ShUniformInfo* getUniformInfo() const  { return (!uniforms.empty()) ? &uniforms[0] : 0; }
   
private:
	typedef std::vector<GlslFunction*> FunctionSet;
	typedef std::set<std::string> ExtensionSet;

	std::string stripSemanticModifier(const std::string &semantic, bool warn);
	EAttribSemantic parseAttributeSemantic(const std::string &semantic);
	
	bool addCalledFunctions( GlslFunction *func, FunctionSet& funcSet, std::vector<GlslFunction*> &funcList);
	void getAttributeName( GlslSymbolOrStructMemberBase const* symOrStructMember, std::string &outName, EAttribSemantic sem, int semanticOffset);
	bool getArgumentData2( GlslSymbolOrStructMemberBase const* symOrStructMember,
							   EClassifier c, std::string &outName, std::string &ctor, int &pad, int semanticOffset);
	bool getArgumentData( GlslSymbol* sym, EClassifier c, std::string &outName,
				  std::string &ctor, int &pad);
	
	bool linkerSanityCheck(HlslCrossCompiler* compiler, const char* entryFunc);
	bool buildFunctionLists(HlslCrossCompiler* comp, EShLanguage lang, const std::string& entryPoint, GlslFunction*& globalFunction, std::vector<GlslFunction*>& functionList, FunctionSet& calledFunctions, GlslFunction*& funcMain);
	void buildUniformsAndLibFunctions(const FunctionSet& calledFunctions, std::vector<GlslSymbol*>& constants, std::set<TOperator>& libFunctions);
	void buildUniformReflection(const std::vector<GlslSymbol*>& constants);
	
	void appendDuplicatedInSemantics(GlslSymbolOrStructMemberBase* sym, EAttribSemantic sem, std::vector<GlslSymbolOrStructMemberBase*>& list);
	void markDuplicatedInSemantics(GlslFunction* func);

	void emitLibraryFunctions(const std::set<TOperator>& libFunctions, EShLanguage lang, bool usePrecision);
	void emitStructs(HlslCrossCompiler* comp);
	void emitGlobals(const GlslFunction* globalFunction, const std::vector<GlslSymbol*>& constants);
	
	void emitInputNonStructParam(GlslSymbol* sym, EShLanguage lang, bool usePrecision, EAttribSemantic attrSem, std::stringstream& attrib, std::stringstream& varying, std::stringstream& preamble, std::stringstream& call);
	bool emitInputStruct(const GlslStruct* str, std::string parentName, EShLanguage lang, std::stringstream& attrib, std::stringstream& varying, std::stringstream& preamble, const std::string& parentStructSemantic = "");
	void emitInputStructParam(GlslSymbol* sym, EShLanguage lang, std::stringstream& attrib, std::stringstream& varying, std::stringstream& preamble, std::stringstream& call);
	void emitOutputNonStructParam(GlslSymbol* sym, EShLanguage lang, bool usePrecision, EAttribSemantic attrSem, std::stringstream& varying, std::stringstream& preamble, std::stringstream& postamble, std::stringstream& call);
	void emitOutputStructParam(GlslSymbol* sym, EShLanguage lang, bool usePrecision, EAttribSemantic attrSem, std::stringstream& varying, std::stringstream& preamble, std::stringstream& postamble, std::stringstream& call);
	void emitMainStart(const HlslCrossCompiler* compiler, const EGlslSymbolType retType, GlslFunction* funcMain, unsigned options, bool usePrecision, std::stringstream& preamble, const std::vector<GlslSymbol*>& constants);
	bool emitReturnValue(const EGlslSymbolType retType, GlslFunction* funcMain, EShLanguage lang, std::stringstream& varying, std::stringstream& postamble);
	bool emitReturnStruct(GlslStruct* retStruct, std::string parentName, EShLanguage lang, std::stringstream& varying, std::stringstream& postamble, const std::string& parentStructSemantic = "");
	
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
	
	ExtensionSet m_Extensions;
	ETargetVersion m_Target;
	unsigned m_Options;
};

}

#endif //HLSL_LINKER_H
