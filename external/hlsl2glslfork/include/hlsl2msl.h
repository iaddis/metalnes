// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.

#pragma once

#include <string>

#include "hlsl2glsl.h"

namespace hlslang {
namespace MetalCodeGen {

/// Generic opaque handle.  This type is used for handles to the parser/translator.
/// If handle creation fails, 0 will be returned.
class MslCrossCompiler;
}} // namespace

    
typedef hlslang::MetalCodeGen::MslCrossCompiler* MetalShHandle;
	


/// Initialize the HLSL2GLSL translator.  This function must be called once prior to calling any other
/// HLSL2GLSL translator functions
/// \return
///   1 on success, 0 on failure
SH_IMPORT_EXPORT int C_DECL Hlsl2Msl_Initialize();

/// Shutdown the HLSL2GLSL translator.  This function should be called to de-initialize the HLSL2GLSL
/// translator and should only be called once on shutdown.
SH_IMPORT_EXPORT void C_DECL Hlsl2Msl_Shutdown();

/// Construct a compiler for the given language (one per shader)
SH_IMPORT_EXPORT MetalShHandle C_DECL Hlsl2Msl_ConstructCompiler( const EShLanguage language );


SH_IMPORT_EXPORT void C_DECL Hlsl2Msl_DestructCompiler( MetalShHandle handle );



/// Parse HLSL shader to prepare it for final translation.
/// \param callbacks
///		File read callback for #include processing. If NULL is passed, then #include directives will result in error.
/// \param options
///		Flags of TTranslateOptions
SH_IMPORT_EXPORT int C_DECL Hlsl2Msl_Parse(
	const MetalShHandle handle,
	const char* shaderString,
	ETargetVersion targetVersion,
	Hlsl2Glsl_ParseCallbacks* callbacks,
	unsigned options);



/// After parsing a HLSL shader, do the final translation to GLSL.
SH_IMPORT_EXPORT int C_DECL Hlsl2Msl_Translate(
	const MetalShHandle handle,
	const char* entry,
	ETargetVersion targetVersion,
	unsigned options);


/// After translating HLSL shader(s), retrieve the translated GLSL source.
SH_IMPORT_EXPORT const char* C_DECL Hlsl2Msl_GetShader( const MetalShHandle handle );


SH_IMPORT_EXPORT const char* C_DECL Hlsl2Msl_GetInfoLog( const MetalShHandle handle );


/// After translating, retrieve the number of uniforms
SH_IMPORT_EXPORT int C_DECL Hlsl2Msl_GetUniformCount( const MetalShHandle handle );


/// After translating, retrieve the uniform info table
SH_IMPORT_EXPORT const ShUniformInfo* C_DECL Hlsl2Msl_GetUniformInfo( const MetalShHandle handle );


/// Instead of mapping HLSL attributes to GLSL fixed-function attributes, this function can be used to 
/// override the  attribute mapping.  This tells the code generator to use user-defined attributes for 
/// the semantics that are specified.
///
/// \param handle
///      Handle to the compiler.  This should be called BEFORE calling Hlsl2Msl_Translate
/// \param pSemanticEnums 
///      Array of semantic enums to set
/// \param pSemanticNames 
///      Array of user attribute names to use
/// \param nNumSemantics 
///      Number of semantics to set in the arrays
/// \return
///      1 on success, 0 on failure
SH_IMPORT_EXPORT int C_DECL Hlsl2Msl_SetUserAttributeNames ( MetalShHandle handle,
                                                              const EAttribSemantic *pSemanticEnums, 
                                                              const char *pSemanticNames[], 
                                                              int nNumSemantics );



SH_IMPORT_EXPORT bool C_DECL Hlsl2Msl_VersionUsesPrecision (ETargetVersion version);
  

