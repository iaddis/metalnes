// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#ifndef _BASICTYPES_INCLUDED_
#define _BASICTYPES_INCLUDED_

//
// Precision qualifiers
//
enum TPrecision
{
	// These need to be kept sorted
	EbpUndefined,
	EbpLow,
	EbpMedium,
	EbpHigh,
};


//
// Basic type.  Arrays, vectors, etc., are orthogonal to this.
//
enum TBasicType
{
   EbtVoid,
   EbtFloat,
   EbtInt,
   EbtBool,
   EbtGuardSamplerBegin,  // non type:  see implementation of IsSampler()
   EbtSamplerGeneric,     // untyped D3D sampler, assumes type via usage
   EbtSampler1D,
   EbtSampler2D,
   EbtSampler3D,
   EbtSamplerCube,
   EbtSampler1DShadow,
   EbtSampler2DShadow,
   EbtSamplerRect,        // ARB_texture_rectangle
   EbtSamplerRectShadow,  // ARB_texture_rectangle
   EbtSampler2DArray,
   EbtGuardSamplerEnd,    // non type:  see implementation of IsSampler()
   EbtTexture,            // HLSL Texture variable (presently just a dummy) 
   EbtStruct,
};

__inline bool IsSampler(TBasicType type)
{
   return type > EbtGuardSamplerBegin && type < EbtGuardSamplerEnd;
}

__inline bool IsNumeric(TBasicType type)
{
   return type > EbtVoid && type < EbtGuardSamplerBegin;
}

//
// Qualifiers and built-ins.  These are mainly used to see what can be read
// or written, and by the machine dependent translator to know which registers
// to allocate variables in.  Since built-ins tend to go to different registers
// than varying or uniform, it makes sense they are peers, not sub-classes.
//
enum TQualifier
{
   EvqTemporary,     // For temporaries (within a function), read/write
   EvqGlobal,        // For globals read/write
   EvqConst,         // User defined constants and non-output parameters in functions
   EvqStatic,        // Static variables
   EvqAttribute,     // Readonly 
   EvqUniform,       // Readonly, vertex and fragment
   EvqMutableUniform,// HLSL uniform that is modified by the shader

   // parameters
   EvqIn,
   EvqOut,
   EvqInOut,

   // end of list
   EvqLast,
};

//
// This is just for debug print out, carried along with the definitions above.
//
__inline const char* getQualifierString(TQualifier q) 
{
   switch (q)
   {
   case EvqTemporary:      return "Temporary";      break;
   case EvqGlobal:         return "Global";         break;
   case EvqConst:          return "const";          break;
   case EvqAttribute:      return "attribute";      break;
   case EvqUniform:        return "uniform";        break;
   case EvqIn:             return "in";             break;
   case EvqOut:            return "out";            break;
   case EvqInOut:          return "inout";          break;
   default:                return "unknown qualifier";
   }
}

#endif // _BASICTYPES_INCLUDED_

