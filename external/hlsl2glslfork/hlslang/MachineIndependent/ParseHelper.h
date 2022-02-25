// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#pragma once

#include "SymbolTable.h"
#include "localintermediate.h"

namespace hlslang {

//
// The following are extra variables needed during parsing, grouped together so
// they can be passed to the parser without needing a global.
//
struct TParseContext
{
	TParseContext(TSymbolTable& symt, EShLanguage L, ETargetVersion ver, unsigned opts, TInfoSink& is)
	: symbolTable(symt)
	, infoSink(is)
	, language(L)
	, targetVersion(ver)
	, options(opts)
	, treeRoot(0)
	, recoveredFromError(false)
	, numErrors(0)
	, lexAfterType(false)
	, loopNestingLevel(0)
	, inTypeParen(false)
	{
	}
	
	void C_DECL error(TSourceLoc, const char *szReason, const char *szToken, 
					 const char *szExtraInfoFormat, ...);
	bool reservedErrorCheck(const TSourceLoc& line, const TString& identifier);
	void recover();

	TQualifier getDefaultQualifier() const { return symbolTable.atGlobalLevel() ? EvqGlobal : EvqTemporary; }
	
	TIntermTyped* add_binary(TOperator op, TIntermTyped* a, TIntermTyped* b, TSourceLoc line, const char* name, bool boolResult);
	
	bool parseVectorFields(const TString&, int vecSize, TVectorFields&, const TSourceLoc& line);
	bool parseMatrixFields(const TString&, int matCols, int matRows, TVectorFields&, const TSourceLoc& line);
	void assignError(const TSourceLoc& line, const char* op, TString left, TString right);
	void unaryOpError(const TSourceLoc& line, const char* op, TString operand);
	void binaryOpError(const TSourceLoc& line, const char* op, TString left, TString right);
	bool lValueErrorCheck(const TSourceLoc& line, const char* op, TIntermTyped*);
	bool constErrorCheck(TIntermTyped* node);
	bool scalarErrorCheck(TIntermTyped* node, const char* token);
	bool globalErrorCheck(const TSourceLoc& line, bool global, const char* token);
	bool constructorErrorCheck(const TSourceLoc& line, TIntermNode*, TFunction&, TOperator, TType*);
	bool arraySizeErrorCheck(const TSourceLoc& line, TIntermTyped* expr, int& size);
	bool arrayQualifierErrorCheck(const TSourceLoc& line, TPublicType type);
	bool arrayTypeErrorCheck(const TSourceLoc& line, TPublicType type);
	bool arrayErrorCheck(const TSourceLoc& line, TString& identifier, TPublicType type, TVariable*& variable);
	bool arrayErrorCheck(const TSourceLoc& line, TString& identifier, const TTypeInfo *info, TPublicType type, TVariable*& variable);
	bool insertBuiltInArrayAtGlobalLevel();
	bool voidErrorCheck(const TSourceLoc& line, const TString&, const TPublicType&);
	bool boolErrorCheck(const TSourceLoc& line, const TIntermTyped*);
	bool boolErrorCheck(const TSourceLoc& line, const TPublicType&);
	bool boolOrVectorErrorCheck(const TSourceLoc& line, const TIntermTyped* type);
	bool samplerErrorCheck(const TSourceLoc& line, const TPublicType& pType, const char* reason);
	bool structQualifierErrorCheck(const TSourceLoc& line, const TPublicType& pType);
	bool parameterSamplerErrorCheck(const TSourceLoc& line, TQualifier qualifier, const TType& type);
	bool containsSampler(TType& type);
	bool nonInitConstErrorCheck(const TSourceLoc& line, TString& identifier, TPublicType& type);
	bool nonInitErrorCheck(const TSourceLoc& line, TString& identifier, const TTypeInfo *info, TPublicType& type);
	bool nonInitErrorCheck(const TSourceLoc& line, TString& identifier, TPublicType& type);
	bool paramErrorCheck(const TSourceLoc& line, TQualifier qualifier, TQualifier paramQualifier, TType* type);
	const TFunction* findFunction(const TSourceLoc& line, TFunction* pfnCall, bool *builtIn = 0);
	bool executeInitializer(TSourceLoc line, TString& identifier, const TTypeInfo *info, TPublicType& pType, 
						   TIntermTyped*& initializer, TIntermSymbol*& intermNode, TVariable* variable = 0);
	bool executeInitializer(TSourceLoc line, TString& identifier, TPublicType& pType, 
						   TIntermTyped*& initializer, TIntermSymbol*& intermNode, TVariable* variable = 0);
	TIntermTyped* addConstructor(TIntermNode*, const TType*, TOperator, TFunction*, TSourceLoc);
	TIntermTyped* constructArray(TIntermAggregate*, const TType*, TOperator, TSourceLoc);
	TIntermTyped* constructStruct(TIntermNode*, TType*, int, TSourceLoc, bool subset);
	TIntermTyped* constructBuiltIn(const TType*, TOperator, TIntermNode*, TSourceLoc, bool subset);
    TIntermTyped* constructBuiltInAllowUpwardVectorPromote(const TType*, TOperator, TIntermNode*, TSourceLoc, bool subset);
	TIntermTyped* addAssign(TOperator op, TIntermTyped* left, TIntermTyped* right, TSourceLoc);
	TIntermAggregate* mergeAggregates( TIntermAggregate *left, TIntermAggregate *right);
	bool arraySetMaxSize(TIntermSymbol*, TType*, int, bool, TSourceLoc);
	TOperator getConstructorOp( const TType&);
	TIntermNode* promoteFunctionArguments( TIntermNode *node, const TFunction* func);
	
public:
	TSymbolTable& symbolTable;   // symbol table that goes with the language currently being parsed
	TInfoSink& infoSink;
	
	EShLanguage language;
	ETargetVersion targetVersion;
	unsigned options; // TTranslateOptions bitmask
	
	TIntermNode* treeRoot;       // root of parse tree being created
	bool recoveredFromError;     // true if a parse error has occurred, but we continue to parse
	int numErrors;
	bool lexAfterType;           // true if we've recognized a type, so can only be looking for an identifier
	int loopNestingLevel;        // 0 if outside all loops
	bool inTypeParen;            // true if in parentheses, looking only for an identifier
	const TType* currentFunctionType;  // the return type of the function that's currently being parsed
	bool functionReturnsValue;   // true if a non-void function has a return
	bool AfterEOF;
};

int PaParseString(char* source, TParseContext&, Hlsl2Glsl_ParseCallbacks* = NULL);
void PaReservedWord();
int PaIdentOrType(TString& id, TParseContext&, TSymbol*&);
int PaParseComment(TSourceLoc &lineno, TParseContext&);
void setInitialState();


typedef TParseContext* TParseContextPointer;
extern TParseContextPointer& GetGlobalParseContext();
#define GlobalParseContext GetGlobalParseContext()

typedef struct TThreadParseContextRec
{
   TParseContext *lpGlobalParseContext;
} TThreadParseContext;

}
