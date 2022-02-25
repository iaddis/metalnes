// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.

#ifndef _HLSL2GLSL_INTERFACE_INCLUDED_
#define _HLSL2GLSL_INTERFACE_INCLUDED_

#ifdef _WIN32
   #define C_DECL __cdecl
   #define SH_IMPORT_EXPORT
#else
   #define SH_IMPORT_EXPORT
   #define __fastcall
   #define C_DECL
#endif

#include <string>


extern "C" {

/// Types of languages the HLSL2GLSL translator can consume.
typedef enum
{
	EShLangVertex,
	EShLangFragment,
	EShLangCount,
} EShLanguage;

/// Binding table.  This can be used for locating attributes, uniforms, globals, etc., as needed.
typedef struct
{
	char* name;
	int binding;
} ShBinding;

typedef struct
{
	int numBindings;
	ShBinding* bindings;  // array of bindings
} ShBindingTable;


/// GLSL shader variable types
/// NOTE: these are ordered to exactly match the internal enums
typedef enum
{
	EShTypeVoid,
	EShTypeBool,
	EShTypeBVec2,
	EShTypeBVec3,
	EShTypeBVec4,
	EShTypeInt,
	EShTypeIVec2,
	EShTypeIVec3,
	EShTypeIVec4,
	EShTypeFloat,
	EShTypeVec2,
	EShTypeVec3,
	EShTypeVec4,
	EShTypeMat2,
	EShTypeMat2x3,
	EShTypeMat2x4,
	EShTypeMat3x2,
	EShTypeMat3,
	EShTypeMat3x4,
	EShTypeMat4x2,
	EShTypeMat4x3,
	EShTypeMat4x4,
	EShTypeSampler,
	EShTypeSampler1D,
	EShTypeSampler1DShadow,
	EShTypeSampler2D,
	EShTypeSampler2DShadow,
	EShTypeSampler3D,
	EShTypeSamplerCube,
	EShTypeSamplerRect,
	EShTypeSamplerRectShadow,
	EShTypeSampler2DArray,
	EShTypeStruct
} EShType;


/// HLSL attribute semantics
/// NOTE: these are ordered to exactly match the internal tables
enum EAttribSemantic
{
	EAttrSemNone,
	EAttrSemPosition,
	EAttrSemPosition1,
	EAttrSemPosition2,
	EAttrSemPosition3,
	EAttrSemVPos,
	EAttrSemVFace,
	EAttrSemNormal,
	EAttrSemNormal1,
	EAttrSemNormal2,
	EAttrSemNormal3,
	EAttrSemColor0,
	EAttrSemColor1,
	EAttrSemColor2,
	EAttrSemColor3,
	EAttrSemTex0,
	EAttrSemTex1,
	EAttrSemTex2,
	EAttrSemTex3,
	EAttrSemTex4,
	EAttrSemTex5,
	EAttrSemTex6,
	EAttrSemTex7,
	EAttrSemTex8,
	EAttrSemTex9,
	EAttrSemTangent,
	EAttrSemTangent1,
	EAttrSemTangent2,
	EAttrSemTangent3,
	EAttrSemBinormal,
	EAttrSemBinormal1,
	EAttrSemBinormal2,
	EAttrSemBinormal3,
	EAttrSemBlendWeight,
	EAttrSemBlendWeight1,
	EAttrSemBlendWeight2,
	EAttrSemBlendWeight3,
	EAttrSemBlendIndices,
	EAttrSemBlendIndices1,
	EAttrSemBlendIndices2,
	EAttrSemBlendIndices3,
	EAttrSemPSize,
	EAttrSemPSize1,
	EAttrSemPSize2,
	EAttrSemPSize3,
	EAttrSemDepth,
	EAttrSemUnknown,
	EAttrSemVertexID,
	EAttrSemInstanceID,
	EAttrSemPrimitiveID,
	EAttrSemCoverage,
	EAttrSemCount
};


/// Uniform info struct
typedef struct
{
	char *name;
	char *semantic;
	char *registerSpec;
	EShType type;
	int arraySize;
	float *init;
} ShUniformInfo;


/// Target language version
enum ETargetVersion
{
	// NOTE: keep ordering roughly in increasing capability set
	ETargetGLSL_ES_100,
	ETargetGLSL_110,
	ETargetGLSL_120,
	ETargetGLSL_140,
	ETargetGLSL_ES_300,
    ETargetMetal_200,
	// ETargetGLSL_330,
	ETargetVersionCount
};


/// Translation options
enum TTranslateOptions
{
	ETranslateOpNone = 0,
	ETranslateOpIntermediate = (1<<0),

	/// Some drivers (e.g. OS X 10.6.x) have bugs with GLSL 1.20 array
	/// initializer syntax. If you need to support this configuration,
	/// use this flag to generate compatible syntax. You'll need
	/// to prepend HLSL2GLSL_ENABLE_ARRAY_120_WORKAROUND to the shader.
	///
	/// Example of emitted code for a simple array declaration:
	/// (HLSL Source)
	///		float2 samples[] = {
	///			float2(-1, 0.1),
	///			float2(0, 0.5),
	///			float2(1, 0.1)
	///		};
	/// (GLSL Emitted result)
	///		#if defined(HLSL2GLSL_ENABLE_ARRAY_120_WORKAROUND)
	///			vec2 samples[];
	///			samples[0] = vec2(-1.0, 0.1);
	///			samples[1] = vec2(0.0, 0.5);
	///			samples[2] = vec2(1.0, 0.1);
	///		#else
	///			const vec2 samples[] = vec2[](vec2(-1.0, 0.1), vec2(0.0, 0.5), vec2(1.0, 0.1)); 
	///		#endif
	ETranslateOpEmitGLSL120ArrayInitWorkaround = (1<<1),

	// Instead of using built-in "gl_MultiTexCoord0" for "appdata_t.texcoord : TEXCOORD0"
	//  we will output an attribute "xlat_attrib_TEXCOORD0". Targeting GLSL ES forces this
	//  as there are no built-in attributes in that variant.
	ETranslateOpAvoidBuiltinAttribNames = (1<<2),
	
	// Always use "gl_MultiTexCoord0" for "TEXCOORD0" and so on,
	// even in GLSL ES. It is expected that client code will add #defines to handle them
	// later on.
	ETranslateOpForceBuiltinAttribNames = (1<<3),

	// When not using built-in attribute names (due to ETranslateOpAvoidBuiltinAttribNames or GLSL ES),
	//  instead of outputting e.g. "xlat_attrib_TEXCOORD0" for "appdata_t.texcoord : TEXCOORD0"
	//  we will output "appdata_t_texcoord"
	ETranslateOpPropogateOriginalAttribNames = (1<<4),
    
    ETranslateOpPointSize = (1<<5),

};



/// Generic opaque handle.  This type is used for handles to the parser/translator.
/// If handle creation fails, 0 will be returned.
namespace hlslang {
class HlslCrossCompiler;
}
typedef hlslang::HlslCrossCompiler* ShHandle;
	

/// Initialize the HLSL2GLSL translator.  This function must be called once prior to calling any other
/// HLSL2GLSL translator functions
/// \return
///   1 on success, 0 on failure
SH_IMPORT_EXPORT int C_DECL Hlsl2Glsl_Initialize();

/// Shutdown the HLSL2GLSL translator.  This function should be called to de-initialize the HLSL2GLSL
/// translator and should only be called once on shutdown.
SH_IMPORT_EXPORT void C_DECL Hlsl2Glsl_Shutdown();

/// Construct a compiler for the given language (one per shader)
SH_IMPORT_EXPORT ShHandle C_DECL Hlsl2Glsl_ConstructCompiler( const EShLanguage language );  


SH_IMPORT_EXPORT void C_DECL Hlsl2Glsl_DestructCompiler( ShHandle handle );


/// File read callback for #include processing.
typedef bool (C_DECL *Hlsl2Glsl_IncludeOpenFunc)(bool isSystem, const char* fname, const char* parentfname, const char* parent, std::string& output, void* data);
typedef void (C_DECL *Hlsl2Glsl_IncludeCloseFunc)(const char* file, void* data);
struct Hlsl2Glsl_ParseCallbacks
{
	Hlsl2Glsl_IncludeOpenFunc includeOpenCallback;
	Hlsl2Glsl_IncludeCloseFunc includeCloseCallback;
	void* data;
};

/// Parse HLSL shader to prepare it for final translation.
/// \param callbacks
///		File read callback for #include processing. If NULL is passed, then #include directives will result in error.
/// \param options
///		Flags of TTranslateOptions
SH_IMPORT_EXPORT int C_DECL Hlsl2Glsl_Parse(
	const ShHandle handle,
	const char* shaderString,
	ETargetVersion targetVersion,
	Hlsl2Glsl_ParseCallbacks* callbacks,
	unsigned options);



/// After parsing a HLSL shader, do the final translation to GLSL.
SH_IMPORT_EXPORT int C_DECL Hlsl2Glsl_Translate(
	const ShHandle handle,
	const char* entry,
	ETargetVersion targetVersion,
	unsigned options);


/// After translating HLSL shader(s), retrieve the translated GLSL source.
SH_IMPORT_EXPORT const char* C_DECL Hlsl2Glsl_GetShader( const ShHandle handle );


SH_IMPORT_EXPORT const char* C_DECL Hlsl2Glsl_GetInfoLog( const ShHandle handle );


/// After translating, retrieve the number of uniforms
SH_IMPORT_EXPORT int C_DECL Hlsl2Glsl_GetUniformCount( const ShHandle handle );


/// After translating, retrieve the uniform info table
SH_IMPORT_EXPORT const ShUniformInfo* C_DECL Hlsl2Glsl_GetUniformInfo( const ShHandle handle );


/// Instead of mapping HLSL attributes to GLSL fixed-function attributes, this function can be used to 
/// override the  attribute mapping.  This tells the code generator to use user-defined attributes for 
/// the semantics that are specified.
///
/// \param handle
///      Handle to the compiler.  This should be called BEFORE calling Hlsl2Glsl_Translate
/// \param pSemanticEnums 
///      Array of semantic enums to set
/// \param pSemanticNames 
///      Array of user attribute names to use
/// \param nNumSemantics 
///      Number of semantics to set in the arrays
/// \return
///      1 on success, 0 on failure
SH_IMPORT_EXPORT int C_DECL Hlsl2Glsl_SetUserAttributeNames ( ShHandle handle, 
                                                              const EAttribSemantic *pSemanticEnums, 
                                                              const char *pSemanticNames[], 
                                                              int nNumSemantics );



SH_IMPORT_EXPORT bool C_DECL Hlsl2Glsl_VersionUsesPrecision (ETargetVersion version);

} // extern "C"


#endif // _HLSL2GLSL_INTERFACE_INCLUDED_
