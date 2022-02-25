// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "glslSymbol.h"
#include <float.h>
#include <cstring>

namespace hlslang {


// Check against names that are keywords in GLSL, but not HLSL
static bool IsReservedGlslKeyword (const std::string& name)
{
	static const char* s_reservedKeywords[] = {
//		"const",
		"uniform",
		"layout",
		"centroid",
		"flat",
		"smooth",
//		"break",
//		"continue",
//		"do",
//		"for",
//		"while",
//		"switch",
//		"case",
//		"default",
//		"if",
//		"else",
//		"in",
//		"out",
		"inout",
//		"float",
//		"int",
//		"void",
//		"bool",
//		"true",
//		"false",
		"invariant",
		"discard",
		"return",
		"mat2",
		"mat3",
		"mat4",
		"mat2x2",
		"mat2x3",
		"mat2x4",
		"mat3x2",
		"mat3x3",
		"mat3x4",
		"mat4x2",
		"mat4x3",
		"mat4x4",
		"vec2",
		"vec3",
		"vec4",
		"ivec2",
		"ivec3",
		"ivec4",
		"bvec2",
		"bvec3",
		"bvec4",
		"uint",
		"uvec2",
		"uvec3",
		"uvec4",
		"lowp",
		"mediump",
		"highp",
		"precision",
		"sampler2D",
		"sampler3D",
		"samplerCube",
		"sampler2DShadow",
		"samplerCubeShadow",
		"sampler2DArray",
		"sampler2DArrayShadow",
		"isampler2D",
		"isampler3D",
		"isamplerCube",
		"isampler2DArray",
		"usampler2D",
		"usampler3D",
		"usamplerCube",
		"usampler2DArray",
		"struct",
		"attribute",
		"varying",
		"coherent",
		"volatile",
		"restrict",
		"readonly",
		"writeonly",
		"resource",
		"atomic",
		"uint",
		"noperspective",
		"patch",
		"sample",
		"subroutine",
		"common",
		"partition",
		"active",
		"asm",
		"class",
		"union",
		"enum",
		"typedef",
		"template",
		"this",
		"packed",
		"goto",
		"inline",
		"noinline",
		"volatile",
		"public",
		"static",
//		"extern",
		"external",
		"interface",
		"long",
		"short",
		"double",
		"half",
		"fixed",
		"unsigned",
		"superp",
		"input",
		"output",
		"hvec2",
		"hvec3",
		"hvec4",
		"dvec2",
		"dvec3",
		"dvec4",
		"fvec2",
		"fvec3",
		"fvec4",
		"sampler3DRect",
		"filter",
		"image1D",
		"image2D",
		"image3D",
		"imageCube",
		"iimage1D",
		"iimage2D",
		"iimage3D",
		"iimageCube",
		"uimage1D",
		"uimage2D",
		"uimage3D",
		"uimageCube",
		"image1DArray",
		"image2DArray",
		"iimage1DArray",
		"iimage2DArray",
		"uimage1DArray",
		"uimage2DArray",
		"image1DShadow",
		"image2DShadow",
		"image1DArrayShadow",
		"image2DArrayShadow",
		"imageBuffer",
		"iimageBuffer",
		"uimageBuffer",
		"sampler1D",
		"sampler1DShadow",
		"sampler1DArray",
		"sampler1DArrayShadow",
		"isampler1D",
		"isampler1DArray",
		"usampler1D",
		"usampler1DArray",
		"sampler2DRect",
		"sampler2DRectShadow",
		"isampler2DRect",
		"usampler2DRect",
		"samplerBuffer",
		"isamplerBuffer",
		"usamplerBuffer",
		"sampler2DMS",
		"isampler2DMS",
		"usampler2DMS",
		"sampler2DMSArray",
		"isampler2DMSArray",
		"usampler2DMSArray",
		"sizeof",
		"cast",
		"namespace",
		"using"
	};

	for (int ndx = 0; ndx < (int)(sizeof(s_reservedKeywords)/sizeof(s_reservedKeywords[0])); ndx++)
	{
		if (name == s_reservedKeywords[ndx])
			return true;
	}
	
	return false;
}

// Check against names that are built-ins in GLSL. This might overlap with HLSL
// but HLSL allows variables to have the same name as a built-in (e.g. lerp),
// where GLSL might not.
static bool IsGlslBuiltin (const std::string& name)
{
	static const char* s_reservedKeywords[] = {
		"radians",
		"degrees",
		"sin",
		"cos",
		"tan",
		"asin",
		"acos",
		"atan",
		"sinh",
		"cosh",
		"tanh",
		"asinh",
		"acosh",
		"atanh",
		"pow",
		"exp",
		"log",
		"exp2",
		"log2",
		"sqrt",
		"inversesqrt",
		"abs",
		"sign",
		"floor",
		"trunc",
		"round",
		"roundEven",
		"ceil",
		"fract",
		"mod",
		"modf",
		"min",
		"max",
		"clamp",
		"mix",
		"step",
		"smoothstep",
		"isnan",
		"isinf",
		"floatBitsToInt",
		"floatBitsToUint",
		"intBitsToFloat",
		"uintBitsToFloat",
		"fma",
		"frexp",
		"ldexp",
		"packUnorm2x16",
		"packSnorm2x16",
		"packUnorm4x8",
		"packSnorm4x8",
		"unpackUnorm2x16",
		"unpackSnorm2x16",
		"unpackUnorm4x8",
		"unpackSnorm4x8",
		"packDouble2x32",
		"unpackDouble2x32",
		"packHalf2x16",
		"unpackHalf2x16",
		"length",
		"distance",
		"dot",
		"cross",
		"normalize",
		"faceforward",
		"reflect",
		"refract",
		"matrixCompMult",
		"outerProduct",
		"transpose",
		"determinant",
		"inverse",
		"lessThan",
		"lessThanEqual",
		"greaterThan",
		"greaterThanEqual",
		"equal",
		"notEqual",
		"any",
		"all",
		"not",
		"uaddCarry",
		"usubBorrow",
		"umulExtended",
		"imulExtended",
		"bitfieldExtract",
		"bitfieldInsert",
		"bitfieldReverse",
		"bitCount",
		"findLSB",
		"findMSB",
		"textureSize",
		"textureQueryLod",
		"textureQueryLevels",
		"textureSamples",
		"textureProj",
		"textureLod",
		"textureOffset",
		"texelFetch",
		"texelFetchOffset",
		"textureProjOffset",
		"textureLodOffset",
		"textureProjLod",
		"textureProjLodOffset",
		"textureGrad",
		"textureGradOffset",
		"textureProjGrad",
		"textureProjGradOffset",
		"textureGather",
		"textureGatherOffset",
		"textureGatherOffsets",
		"atomicCounterIncrement",
		"atomicCounterDecrement",
		"atomicCounter",
		"atomicAdd",
		"atomicMin",
		"atomicMax",
		"atomicAnd",
		"atomicOr",
		"atomicXor",
		"atomicExchange",
		"atomicCompSwap",
		"imageSize",
		"imageSamples",
		"imageLoad",
		"imageStore",
		"imageAtomicAdd",
		"imageAtomicMin",
		"imageAtomicMax",
		"imageAtomicAnd",
		"imageAtomicOr",
		"imageAtomicXor",
		"imageAtomicExchange",
		"imageAtomicCompSwap",
		"dFdx",
		"dFdy",
		"dFdxFine",
		"dFdyFine",
		"dFdxCoarse",
		"dFdyCoarse",
		"fwidth",
		"fwidthFine",
		"fwidthCoarse",
		"interpolateAtCentroid",
		"interpolateAtSample",
		"interpolateAtOffset",
		"EmitStreamVertex",
		"EndStreamPrimitive",
		"EmitVertex",
		"EndPrimitive",
		"barrier",
		"memoryBarrier",
		"memoryBarrierAtomicCounter",
		"memoryBarrierBuffer",
		"memoryBarrierShared",
		"memoryBarrierImage",
		"groupMemoryBarrier",
	};

	for (int ndx = 0; ndx < (int)(sizeof(s_reservedKeywords)/sizeof(s_reservedKeywords[0])); ndx++)
	{
		if (name == s_reservedKeywords[ndx])
			return true;
	}

	if (name.length() > 3 && strncmp(name.c_str(), "gl_", 3) == 0)
		return true;

	return false;
}

GlslSymbol::GlslSymbol( const std::string &n, const std::string &s, const std::string &r, int id, EGlslSymbolType t, TPrecision prec, EGlslQualifier q, int as )
 : GlslSymbolOrStructMemberBase(n, s, t, q, prec, as),
   registerSpec(r),
   identifier(id),
   mangleCounter(0),
   structPtr(0),
   isParameter(false),
   refCount(0)
{
	if (IsReservedGlslKeyword(n) || IsGlslBuiltin(n))
	{
		name = "xlat_var" + n;
	}
	mangledName = name;

	if (qual == EqtMutableUniform)
		mutableMangledName = "xlat_mutable" + mangledName;
	else
		mutableMangledName = mangledName;   
}



void GlslSymbol::writeDecl (std::stringstream& out, WriteDeclMode mode)
{
	switch (qual)
	{
	case EqtNone:			break;
	case EqtUniform:		break;
	case EqtMutableUniform:	break;
	case EqtConst:           out << "const ";   break;
	case EqtIn:              out << "in ";      break;
	case EqtOut:             out << "out ";     break;
	case EqtInOut:           out << "inout ";   break;
	}

	if (mode != kWriteDeclMutableInit)
		writeType (out, type, structPtr, precision);
	if (mode == kWriteDeclMutableInit)
		out << "   ";

	out << " " << (mode != kWriteDeclDefault ? mutableMangledName : mangledName);
	if (arraySize && mode != kWriteDeclMutableInit)
		out << "[" << arraySize << "]";
	
	if (qual == EqtMutableUniform && mode == kWriteDeclMutableInit)
		out << " = " << mangledName;
}


void GlslSymbol::mangleName()
{
	std::stringstream s;
	mangleCounter++;
	s << "_" << mangleCounter;
	mangledName = name + s.str();
	if ( qual == EqtMutableUniform) 
		mutableMangledName = "xlat_mutable" + mangledName;
	else
		mutableMangledName = mangledName;
}

}
