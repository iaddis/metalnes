// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "glslStruct.h"

#include <string.h>
#include <stdlib.h>
namespace hlslang {


/// Table to convert GLSL variable types to strings
const char kGLSLTypeNames[EgstTypeCount][32] =
{
   "void",
   "bool",
   "bvec2",
   "bvec3",
   "bvec4",
   "int",
   "ivec2",
   "ivec3",
   "ivec4",
   "float",
   "vec2",
   "vec3",
   "vec4",
   "mat2",
   "mat2x3",
   "mat2x4",
   "mat3x2",
   "mat3",
   "mat3x4",
   "mat4x2",
   "mat4x3",
   "mat4",
   "sampler",
   "sampler1D",
   "sampler1DShadow",
   "sampler2D",
   "sampler2DShadow",
   "sampler3D",
   "samplerCube",
   "sampler2DRect",
   "sampler2DRectShadow",
   "sampler2DArray",
   "struct"
};

const char* getGLSLPrecisiontring (TPrecision p)
{
	switch (p) {
	case EbpLow: return "lowp ";
	case EbpMedium: return "mediump ";
	case EbpHigh: return "highp ";
	case EbpUndefined: return "";
	default: assert(false); return "";
	}
}

/// Outputs the type of the symbol to the output buffer
///    \param out
///       The output buffer to write the type to
///    \param type
///       The type of the GLSL symbol to output
///    \param s
///       If it is a structure, a pointer to the structure to write out
void writeType (std::stringstream &out, EGlslSymbolType type, const GlslStruct *s, TPrecision precision)
{
	if (type >= EgstInt) // precision does not apply to void/bool
		out << getGLSLPrecisiontring (precision);

   switch (type)
   {
   case EgstVoid:  
   case EgstBool:  
   case EgstBool2: 
   case EgstBool3: 
   case EgstBool4: 
   case EgstInt:   
   case EgstInt2:  
   case EgstInt3:  
   case EgstInt4:  
   case EgstFloat: 
   case EgstFloat2:
   case EgstFloat3:
   case EgstFloat4:
   case EgstFloat2x2:
   case EgstFloat2x3:
   case EgstFloat2x4:
   case EgstFloat3x2:
   case EgstFloat3x3:
   case EgstFloat3x4:
   case EgstFloat4x2:
   case EgstFloat4x3:
   case EgstFloat4x4:
   case EgstSamplerGeneric: 
   case EgstSampler1D:
   case EgstSampler1DShadow:
   case EgstSampler2D:
   case EgstSampler2DShadow:
   case EgstSampler3D:
   case EgstSamplerCube:
   case EgstSamplerRect:
   case EgstSamplerRectShadow:
   case EgstSampler2DArray:
      out << kGLSLTypeNames[type];
      break;
   case EgstStruct:
      if (s)
         out << s->getName();
      else
         out << "struct";
      break;
	case EgstTypeCount:
		break;
   }
}


const char* getTypeString( const EGlslSymbolType t )
{
   assert (t >= EgstVoid && t < EgstTypeCount);
   return kGLSLTypeNames[t];
}


EGlslSymbolType translateType( const TType *type )
{
   if ( type->isMatrix() )
   {
      switch (type->getColsCount())
      {
      case 2:
          switch (type->getRowsCount())
          {
          case 2:  return EgstFloat2x2;
          case 3:  return EgstFloat2x3;
          case 4:  return EgstFloat2x4;
          } break;
      case 3:
          switch (type->getRowsCount())
          {
          case 2:  return EgstFloat3x2;
          case 3:  return EgstFloat3x3;
          case 4:  return EgstFloat3x4;
          } break;
      case 4:
          switch (type->getRowsCount())
          {
          case 2:  return EgstFloat4x2;
          case 3:  return EgstFloat4x3;
          case 4:  return EgstFloat4x4;
          } break;
      }
   }
   else
   {
      switch (type->getBasicType())
      {
      case EbtVoid:
         return EgstVoid;
      case EbtBool:
         return EGlslSymbolType(EgstBool + (type->getRowsCount() - 1));
      case EbtInt:
         return EGlslSymbolType(EgstInt + (type->getRowsCount() - 1));
      case EbtFloat:
         return EGlslSymbolType(EgstFloat + (type->getRowsCount() - 1));
      case EbtSamplerGeneric:
         return EgstSamplerGeneric;
      case EbtSampler1D:
         return EgstSampler1D;
	  case EbtSampler1DShadow:
		  return EgstSampler1DShadow;
      case EbtSampler2D:
         return EgstSampler2D;
	  case EbtSampler2DShadow:
		  return EgstSampler2DShadow;
      case EbtSampler3D:
         return EgstSampler3D;
      case EbtSamplerCube:
         return EgstSamplerCube;
	  case EbtSamplerRect:
		  return EgstSamplerRect;
	  case EbtSamplerRectShadow:
		  return EgstSamplerRectShadow;
	  case EbtSampler2DArray:
		  return EgstSampler2DArray;
      case EbtStruct:
         return EgstStruct;
      default:
         return EgstVoid;
      }
   }

   return EgstVoid;
}


EGlslQualifier translateQualifier( TQualifier qual )
{
   switch (qual)
   {
   case EvqTemporary:     return EqtNone;
   case EvqGlobal:        return EqtNone;
   case EvqConst:         return EqtConst;
   case EvqAttribute:     return EqtNone;
   case EvqUniform:       return EqtUniform;
   case EvqMutableUniform: return EqtMutableUniform;
   case EvqIn:            return EqtIn;
   case EvqOut:           return EqtOut;
   case EvqInOut:         return EqtInOut;
   default: return EqtNone;
   }
}


// we want to enforce position semantic to have highp precision
// otherwise, if we encounter shader compiler (e.g. mali) that treats prec hints as "force precision"
// we will have problems with outputing half4 to gl_Position, effectively breaking lots of stuf due to prec loss
// we do it in a bit strange way because i am a bit lazy to go through all code to make sure that we have lower-case string in there
bool IsPositionSemantics(const char* sem, int len)
{
   bool isPos = false;

   char* str = (char*)::malloc(len+1);

   for(int i = 0 ; i <= len ; ++i)
       str[i] = ::tolower(sem[i]);

   if(::strstr(str, "position"))
       isPos = true;

   ::free(str);
   return isPos;
}


int getElements( EGlslSymbolType t )
{
	switch (t)
	{
	case EgstBool:
	case EgstInt:
	case EgstFloat:
	case EgstStruct:
		return 1;
	case EgstBool2:
	case EgstInt2:
	case EgstFloat2:
		return 2;
	case EgstBool3:
	case EgstInt3:
	case EgstFloat3:
		return 3;
	case EgstBool4:
	case EgstInt4:
	case EgstFloat4:
	case EgstFloat2x2:
		return 4;
	case EgstFloat2x3:
		return 6;
	case EgstFloat2x4:
		return 8;
	case EgstFloat3x2:
		return 6;
	case EgstFloat3x3:
		return 9;
	case EgstFloat3x4:
		return 12;
	case EgstFloat4x2:
		return 8;
	case EgstFloat4x3:
		return 12;
	case EgstFloat4x4:
		return 16;
	default:
		return 0;
	}
}

}
