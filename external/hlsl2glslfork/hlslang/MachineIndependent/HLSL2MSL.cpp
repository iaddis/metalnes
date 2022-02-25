// Copyright (c) The HLSL2MslFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "SymbolTable.h"
#include "ParseHelper.h"
#include "RemoveTree.h"

#include "../../include/hlsl2msl.h"
#include "Initialize.h"
#include "../MetalCodeGen/mslSupportLib.h"

#include "../MetalCodeGen/mslCrossCompiler.h"
#include "../MetalCodeGen/mslLinker.h"
#include "../MetalCodeGen/mslCommon.h"

#include "../Include/InitializeGlobals.h"
#include "../Include/InitializeParseContext.h"
#include "osinclude.h"

#include <iostream>

using namespace hlslang;
using namespace hlslang::MetalCodeGen;
// -----------------------------------------------------------------------------


static OS_TLSIndex s_ThreadInitialized = OS_INVALID_TLS_INDEX;


static bool InitThread()
{
	if (s_ThreadInitialized == OS_INVALID_TLS_INDEX)
	{
		assert(0 && "InitThread(): Process hasn't been initalised.");
		return false;
	}

	// already initialized?
	if (OS_GetTLSValue(s_ThreadInitialized) != 0)
		return true;
	
	// initialize per-thread data
	InitializeGlobalPools();
	
	if (!InitializeGlobalParseContext())
		return false;
	
	if (!OS_SetTLSValue(s_ThreadInitialized, (void *)1))
	{
		assert(0 && "InitThread(): Unable to set init flag.");
		return false;
	}
	return true;
}


static bool InitProcess()
{
	if (s_ThreadInitialized != OS_INVALID_TLS_INDEX)
		return true;
	
	s_ThreadInitialized = OS_AllocTLSIndex();
	if (s_ThreadInitialized == OS_INVALID_TLS_INDEX)
	{
		assert(0 && "InitProcess(): Failed to allocate TLS area for init flag");
		return false;
	}
	
	if (!InitializePoolIndex())
	{
		assert(0 && "InitProcess(): Failed to initalize global pool");
		return false;
	}
	
	if (!InitializeParseContextIndex())
	{
//        assert(0 && "InitProcess(): Failed to initalize parse context");
//        return false;
	}
	
	InitThread();
	return true;
}


static bool DetachThread()
{
	if (s_ThreadInitialized == OS_INVALID_TLS_INDEX)
		return true;
	if (OS_GetTLSValue(s_ThreadInitialized) == 0)
		return true;
	
	bool success = true;
	if (!OS_SetTLSValue(s_ThreadInitialized, (void *)0))
	{
		assert(0 && "DetachThread(): Unable to clear init flag.");
		success = false;
	}
	
	FreeGlobalPools();
	
	if (!FreeParseContext())
		success = false;
	
	return success;
}




// -----------------------------------------------------------------------------


// A symbol table for each language.  Each has a different set of built-ins, and we want to preserve that
// from compile to compile.
static TSymbolTable SymbolTables[EShLangCount];


// Global pool allocator (per process)
static TPoolAllocator* PerProcessGPA = 0;


/// Initializize the symbol table
/// \param BuiltInStrings
///      Pointer to built in strings.
/// \param language
///      Shading language to initialize symbol table for
/// \param infoSink
///      Information sink (for errors/warnings)
/// \param symbolTables
///      Array of symbol tables (one for each language)
/// \param bUseGlobalSymbolTable
///      Whether to use the global symbol table or the per-language symbol table
/// \return
///      True if succesfully initialized, false otherwise
static bool InitializeSymbolTable( TBuiltInStrings* BuiltInStrings, EShLanguage language, TInfoSink& infoSink, 
                            TSymbolTable* symbolTables, bool bUseGlobalSymbolTable )
{
   TSymbolTable* symbolTable;

   if ( bUseGlobalSymbolTable )
      symbolTable = symbolTables;
   else
      symbolTable = &symbolTables[language];

	//@TODO: for now, we use same global symbol table for all target language versions.
	// This is wrong and will have to be changed at some point.
	TParseContext parseContext(*symbolTable, language, ETargetVersionCount, 0, infoSink);

   GlobalParseContext = &parseContext;

   setInitialState();

   assert(symbolTable->isEmpty() || symbolTable->atSharedBuiltInLevel());

   //
   // Parse the built-ins.  This should only happen once per
   // language symbol table.
   //
   // Push the symbol table to give it an initial scope.  This
   // push should not have a corresponding pop, so that built-ins
   // are preserved, and the test for an empty table fails.
   //

   symbolTable->push();

   for (TBuiltInStrings::iterator i  = BuiltInStrings[parseContext.language].begin();
       i != BuiltInStrings[parseContext.language].end();
       ++i)
   {
      const char* builtInShaders = (*i).c_str();

      if (PaParseString(const_cast<char*>(builtInShaders), parseContext, NULL) != 0)
      {
         infoSink.info.message(EPrefixInternalError, "Unable to parse built-ins");
         return false;
      }
   }

   if (  !bUseGlobalSymbolTable )
   {
      IdentifyBuiltIns(parseContext.language, *symbolTable);
   }

   return true;
}


/// Generate the built in symbol table
/// \param infoSink
///      Information sink (for errors/warnings)
/// \param symbolTables
///      Array of symbol tables (one for each language)
/// \param bUseGlobalSymbolTable
///      Whether to use the global symbol table or the per-language symbol table
/// \param language
///      Shading language to build symbol table for
/// \return
///      True if succesfully built, false otherwise
static bool GenerateBuiltInSymbolTable(TInfoSink& infoSink, TSymbolTable* symbolTables, EShLanguage language)
{
   TBuiltIns builtIns;

   if ( language != EShLangCount )
   {      
      InitializeSymbolTable(builtIns.getBuiltInStrings(), language, infoSink, symbolTables, true);
   }
   else
   {
      builtIns.initialize();
      InitializeSymbolTable(builtIns.getBuiltInStrings(), EShLangVertex, infoSink, symbolTables, false);
      InitializeSymbolTable(builtIns.getBuiltInStrings(), EShLangFragment, infoSink, symbolTables, false);
   }

   return true;
}


int C_DECL Hlsl2Msl_Initialize()
{
   TInfoSink infoSink;

   if (!InitProcess())
      return 0;

   if (!PerProcessGPA)
   {
      TPoolAllocator *builtInPoolAllocator = new TPoolAllocator();
      builtInPoolAllocator->push();
      TPoolAllocator* gPoolAllocator = &GlobalPoolAllocator;
      SetGlobalPoolAllocatorPtr(builtInPoolAllocator);

      TSymbolTable symTables[EShLangCount];
      GenerateBuiltInSymbolTable(infoSink, symTables, EShLangCount);

      PerProcessGPA = new TPoolAllocator();
      PerProcessGPA->push();
      SetGlobalPoolAllocatorPtr(PerProcessGPA);

      SymbolTables[EShLangVertex].copyTable(symTables[EShLangVertex]);
      SymbolTables[EShLangFragment].copyTable(symTables[EShLangFragment]);

      SetGlobalPoolAllocatorPtr(gPoolAllocator);

      symTables[EShLangVertex].pop();
      symTables[EShLangFragment].pop();

      builtInPoolAllocator->popAll();
      delete builtInPoolAllocator;        

   }

   return 1;
}

void C_DECL Hlsl2Msl_Shutdown()
{
	if (s_ThreadInitialized == OS_INVALID_TLS_INDEX)
		return;
	
	if (PerProcessGPA)
	{
		SymbolTables[EShLangVertex].pop();
		SymbolTables[EShLangFragment].pop();
		
		PerProcessGPA->popAll();
		delete PerProcessGPA;
		PerProcessGPA = NULL;
	}
	
	DetachThread();
	
	FreePoolIndex();
	FreeParseContextIndex();
	
	OS_FreeTLSIndex(s_ThreadInitialized);
	s_ThreadInitialized = OS_INVALID_TLS_INDEX;
}


MetalShHandle C_DECL Hlsl2Msl_ConstructCompiler( const EShLanguage language )
{
   if (!InitThread())
      return 0;

   MslCrossCompiler* compiler = new MslCrossCompiler(language);
   return compiler;
}

void C_DECL Hlsl2Msl_DestructCompiler( MetalShHandle handle )
{
   if (handle == 0)
      return;

   delete handle;
}

int C_DECL Hlsl2Msl_Parse(
	const MetalShHandle handle,
	const char* shaderString,
	ETargetVersion targetVersion,
	Hlsl2Glsl_ParseCallbacks* callbacks,
	unsigned options)
{
   if (!InitThread())
      return 0;

   if (handle == 0)
      return 0;

   MslCrossCompiler* compiler = handle;

   GlobalPoolAllocator.push();
   compiler->infoSink.info.erase();
   compiler->infoSink.debug.erase();

   if (!shaderString)
	   return 1;

   TSymbolTable symbolTable(SymbolTables[compiler->getLanguage()]);

   GenerateBuiltInSymbolTable(compiler->infoSink, &symbolTable, compiler->getLanguage());

   TParseContext parseContext(symbolTable, compiler->getLanguage(), targetVersion, options, compiler->infoSink);

   GlobalParseContext = &parseContext;

   setInitialState();

   //
   // Parse the application's shaders.  All the following symbol table
   // work will be throw-away, so push a new allocation scope that can
   // be thrown away, then push a scope for the current shader's globals.
   //
   bool success = true;

   symbolTable.push();
   if (!symbolTable.atGlobalLevel())
      parseContext.infoSink.info.message(EPrefixInternalError, "Wrong symbol table level");


   int ret = PaParseString(const_cast<char*>(shaderString), parseContext, callbacks);
   if (ret)
      success = false;

   if (success && parseContext.treeRoot)
   {
		TIntermAggregate* aggRoot = parseContext.treeRoot->getAsAggregate();
		if (aggRoot && aggRoot->getOp() == EOpNull)
			aggRoot->setOperator(EOpSequence);

		if (options & ETranslateOpIntermediate)
			ir_output_tree(parseContext.treeRoot, parseContext.infoSink);

		compiler->TransformAST (parseContext.treeRoot);
		compiler->ProduceMSL (parseContext.treeRoot, targetVersion, options);
   }
   else if (!success)
   {
		// only add "X compilation errors" message if somehow there are no other errors whatsoever, yet
		// we still failed. for some reason.
		if (parseContext.infoSink.info.IsEmpty())
		{
			parseContext.infoSink.info.prefix(EPrefixError);
			parseContext.infoSink.info << parseContext.numErrors << " compilation errors.  No code generated.\n\n";
		}
		success = false;
		if (options & ETranslateOpIntermediate)
			ir_output_tree(parseContext.treeRoot, parseContext.infoSink);
   }

	ir_remove_tree(parseContext.treeRoot);

   //
   // Ensure symbol table is returned to the built-in level,
   // throwing away all but the built-ins.
   //
   while (! symbolTable.atSharedBuiltInLevel())
      symbolTable.pop();

   //
   // Throw away all the temporary memory used by the compilation process.
   //
   GlobalPoolAllocator.pop();

   return success ? 1 : 0;
}


int C_DECL Hlsl2Msl_Translate(
	const MetalShHandle handle,
	const char* entry,
	ETargetVersion targetVersion,
	unsigned options)
{
   if (handle == 0)
      return 0;

   MslCrossCompiler* compiler = handle;
   compiler->infoSink.info.erase();

   // \todo [2013-05-14 pyry] Maintain different support library per target version.

	if (!compiler->IsASTTransformed() || !compiler->IsMslProduced())
	{
		compiler->infoSink.info.message(EPrefixError, "Shader does not have valid object code.");
		return 0;
	}

   bool ret = compiler->GetLinker()->link(compiler, entry, targetVersion, options);


   return ret ? 1 : 0;
}


const char* C_DECL Hlsl2Msl_GetShader( const MetalShHandle handle )
{
	if (!handle)
		return 0;
	return handle->GetLinker()->getShaderText();
}


const char* C_DECL Hlsl2Msl_GetInfoLog( const MetalShHandle handle )
{
   if (!InitThread())
      return 0;
   if (handle == 0)
      return 0;
   MslCrossCompiler* base = static_cast<MslCrossCompiler*>(handle);
   TInfoSink* infoSink = &(base->getInfoSink());
   infoSink->info << infoSink->debug.c_str();
   return infoSink->info.c_str();
}


int C_DECL Hlsl2Msl_GetUniformCount( const MetalShHandle handle )
{
	if (!handle)
		return 0;
   const MslLinker *linker = handle->GetLinker();
   if (!linker)
      return 0;
   return linker->getUniformCount();
}


const ShUniformInfo* C_DECL Hlsl2Msl_GetUniformInfo( const MetalShHandle handle )
{
	if (!handle)
		return 0;
   const MslLinker *linker = handle->GetLinker();
   if (!linker)
      return 0;
   return linker->getUniformInfo();
}


int C_DECL Hlsl2Msl_SetUserAttributeNames ( MetalShHandle handle,
                                             const EAttribSemantic *pSemanticEnums, 
                                             const char *pSemanticNames[], 
                                             int nNumSemantics )
{
	if (!handle)
		return 0;
	MslLinker* linker = handle->GetLinker();

   for (int i = 0; i < nNumSemantics; i++ )
   {
      bool bError = linker->setUserAttribName ( pSemanticEnums[i], pSemanticNames[i] );

      if ( bError == false )
         return false;
   }

   return true;
}


static bool kVersionUsesPrecision[ETargetVersionCount] = {
	true,	// ES 1.00
	false,	// 1.10
	false,	// 1.20
    false,	// 1.40
	true,	// ES 3.0
};

bool C_DECL Hlsl2Msl_VersionUsesPrecision (ETargetVersion version)
{
	assert (version >= 0 && version < ETargetVersionCount);
	return kVersionUsesPrecision[version];
}


