// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#pragma once

#include <sstream>

#include "localintermediate.h"

namespace hlslang {
namespace MetalCodeGen {

// GLSL symbol types
enum EMslSymbolType
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
enum EMslQualifier
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
class MslStruct;

// Contains everything that is shared by
// MslSymbol and MslStruct::StructMember
class MslSymbolOrStructMemberBase
{
public:
   MslSymbolOrStructMemberBase(const std::string &n, const std::string &s, EMslSymbolType t, EMslQualifier q, TPrecision prec, int as, std::string const& bn = "") :
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
   virtual ~MslSymbolOrStructMemberBase() = default;
   bool isArray() const { return (arraySize > 0); }
   int getArraySize() const { return arraySize; }
   const std::string &getSemantic() const { return semantic; }
   virtual const MslStruct* getStruct() const { return 0; }
   virtual MslStruct* getStruct() { return 0; }
   EMslSymbolType getType() const { return type; }
   EMslQualifier getQualifier() const { return qual; }
   void suppressOutput(MslSymbolOrStructMemberBase* suppressor) { suppressedBy = suppressor; }
   MslSymbolOrStructMemberBase const* outputSuppressedBy() const { return suppressedBy; }
public:
   std::string name;
   std::string baseName;
   std::string semantic;
   EMslSymbolType type;
   EMslQualifier qual;
   TPrecision precision;
   int arraySize;
private:
   MslSymbolOrStructMemberBase const* suppressedBy;
};


/// Outputs the type of the symbol to the output buffer
void writeType(std::ostream &out, EMslSymbolType type, const MslStruct *s, TPrecision precision);

const char *getTypeString( const EMslSymbolType t );
//const char *getMSLPrecisiontring (TPrecision prec);

/// Translates the type to a GLSL symbol type
EMslSymbolType translateType( const TType *type );

/// Translates the qualifier to a GLSL qualifier enumerant
EMslQualifier translateQualifier( TQualifier qual);

// Gets the number of elements in EMslSymbolType.
int getElements( EMslSymbolType t );
    
}}
