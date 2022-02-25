// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#ifndef GLSL_COMMON_H
#define GLSL_COMMON_H

#include <sstream>

#include "localintermediate.h"

namespace hlslang {


// GLSL symbol types
enum EGlslSymbolType
{
   EgstVoid,
   EgstBool,
   EgstBool2,
   EgstBool3,
   EgstBool4,
   EgstInt,
   EgstInt2,
   EgstInt3,
   EgstInt4,
   EgstFloat,
   EgstFloat2,
   EgstFloat3,
   EgstFloat4,
   EgstFloat2x2,
   EgstFloat2x3,
   EgstFloat2x4,
   EgstFloat3x2,
   EgstFloat3x3,
   EgstFloat3x4,
   EgstFloat4x2,
   EgstFloat4x3,
   EgstFloat4x4,
   EgstSamplerGeneric,
   EgstSampler1D,
   EgstSampler1DShadow,
   EgstSampler2D,
   EgstSampler2DShadow,
   EgstSampler3D,
   EgstSamplerCube,
   EgstSamplerRect,
   EgstSamplerRectShadow,
   EgstSampler2DArray,
   EgstStruct,
   EgstTypeCount
};

// GLSL qualifier enums
enum EGlslQualifier
{
   EqtNone,
   EqtUniform,
   EqtMutableUniform,
   EqtConst,
   EqtIn,
   EqtOut,
   EqtInOut
};


// Forward Declarations
class GlslStruct;

// Contains everything that is shared by
// GlslSymbol and GlslStruct::StructMember
class GlslSymbolOrStructMemberBase
{
public:
   GlslSymbolOrStructMemberBase(const std::string &n, const std::string &s, EGlslSymbolType t, EGlslQualifier q, TPrecision prec, int as, std::string const& bn = "") :
   semantic(s),
   type(t),
   qual(q),
   precision(prec),
   arraySize(as),
   suppressedBy(NULL),
   name(n),
   baseName((bn=="")?bn:bn+"_")
   {
   }
   virtual ~GlslSymbolOrStructMemberBase() = default;
   bool isArray() const { return (arraySize > 0); }
   int getArraySize() const { return arraySize; }
   const std::string &getSemantic() const { return semantic; }
   virtual const GlslStruct* getStruct() const { return 0; }
   virtual GlslStruct* getStruct() { return 0; }
   EGlslSymbolType getType() const { return type; }
   EGlslQualifier getQualifier() const { return qual; }
   void suppressOutput(GlslSymbolOrStructMemberBase* suppressor) { suppressedBy = suppressor; }
   GlslSymbolOrStructMemberBase const* outputSuppressedBy() const { return suppressedBy; }
public:
   std::string name;
   std::string baseName;
   std::string semantic;
   EGlslSymbolType type;
   EGlslQualifier qual;
   TPrecision precision;
   int arraySize;
private:
   GlslSymbolOrStructMemberBase const* suppressedBy;
};


/// Outputs the type of the symbol to the output buffer
void writeType(std::stringstream &out, EGlslSymbolType type, const GlslStruct *s, TPrecision precision);

const char *getTypeString( const EGlslSymbolType t );
const char *getGLSLPrecisiontring (TPrecision prec);

/// Translates the type to a GLSL symbol type
EGlslSymbolType translateType( const TType *type );

/// Translates the qualifier to a GLSL qualifier enumerant
EGlslQualifier translateQualifier( TQualifier qual);

// Gets the number of elements in EGlslSymbolType.
int getElements( EGlslSymbolType t );

}

#endif //GLSL_COMMON_H
