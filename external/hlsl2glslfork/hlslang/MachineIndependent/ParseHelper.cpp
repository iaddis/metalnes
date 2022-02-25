// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "ParseHelper.h"
#include "../Include/InitializeParseContext.h"
#include "osinclude.h"
#include <stdarg.h>


// ------------------------------------------------------------------
namespace hlslang {

namespace {
	union Nodes {
		TIntermAggregate* a;
		TIntermBinary* b;
		TIntermConstant* c;
		TIntermOperator* op;
		TIntermSelection* sel;
		TIntermTyped* t;
	};
	
	inline bool isConst(TQualifier q)
	{
		return q == EvqConst;
	}
	
	inline bool isConst(TOperator op)
	{
		switch (op) {
			case EOpPostIncrement:
			case EOpPostDecrement:
			case EOpPreIncrement:
			case EOpPreDecrement:
			case EOpLit:
			case EOpDPdx:
			case EOpDPdy:
			case EOpFwidth:
			case EOpFclip:
			case EOpTex1D:
			case EOpTex1DProj:
			case EOpTex1DLod:
			case EOpTex1DBias:
			case EOpTex1DGrad:
			case EOpTex2D:
			case EOpTex2DProj:
			case EOpTex2DLod:
			case EOpTex2DBias:
			case EOpTex2DGrad:
			case EOpTex3D:
			case EOpTex3DProj:
			case EOpTex3DLod:
			case EOpTex3DBias:
			case EOpTex3DGrad:
			case EOpTexCube:
			case EOpTexCubeProj:
			case EOpTexCubeLod:
			case EOpTexCubeBias:
			case EOpTexCubeGrad:
			case EOpTexRect:
			case EOpTexRectProj:
			case EOpAssign:
			case EOpAddAssign:
			case EOpSubAssign:
			case EOpMulAssign:
			case EOpVectorTimesMatrixAssign:
			case EOpVectorTimesScalarAssign:
			case EOpMatrixTimesScalarAssign:
			case EOpMatrixTimesMatrixAssign:
			case EOpDivAssign:
			case EOpModAssign:
			case EOpAndAssign:
			case EOpInclusiveOrAssign:
			case EOpExclusiveOrAssign:
			case EOpLeftShiftAssign:
			case EOpRightShiftAssign:
				return false;
			default:
				return true;
		}
	}
	
	bool isBranchConstant(TIntermNode* node);
	
	bool isBranchConstant(TNodeArray& seq)
	{
		TNodeArray::iterator it = seq.begin(), end = seq.end();
		for (; it != end; ++it) {
			if (!isBranchConstant(*it))
				return false;
		}
		return true;
	}
	
	bool isBranchConstant(TIntermNode* node)
	{
		Nodes n;
		if ((n.a = node->getAsAggregate()))
			return isConst(n.a->getOp()) && isBranchConstant(n.a->getNodes());			
		else if ((n.b = node->getAsBinaryNode()))
			return isBranchConstant(n.b->getLeft()) && isBranchConstant(n.b->getRight());
		else if ((n.c = node->getAsConstant()))
			return true;
		else if ((n.op = node->getAsOperatorNode()))
			return isConst(n.op->getOp());
		else if ((n.sel = node->getAsSelectionNode()))
			return isBranchConstant(n.sel->getCondition()) && isBranchConstant(n.sel->getTrueBlock()) && isBranchConstant(n.sel->getFalseBlock());
		else if ((n.t = node->getAsTyped()))
			return isConst(n.t->getQualifier());
		else
			return false;
	}
}

// --------------------------------------------------------------------------


TIntermTyped* TParseContext::add_binary(TOperator op, TIntermTyped* a, TIntermTyped* b, TSourceLoc line, const char* name, bool boolResult)
{
	TIntermTyped* res = ir_add_binary_math(op, a, b, line, *this);
	if (res == NULL)
	{
		binaryOpError(line, name, a->getCompleteString(), b->getCompleteString());
		recover();
		if (boolResult)
		{
            TIntermConstant* constant = ir_add_constant(TType(EbtBool, EbpUndefined, EvqConst), line);
			constant->setValue(false);
			res = constant;
		}
		else
		{
			res = a;
		}
	}
	else if (op == EOpEqual || op == EOpNotEqual)
	{
		if (a->isArray() || b->isArray())
			recover();
	}
	return res;
}


// --------------------------------------------------------------------------

// Sub- vector and matrix fields


//
// Look at a '.' field selector string and change it into offsets
// for a vector.
//
bool TParseContext::parseVectorFields(const TString& compString, int vecSize, TVectorFields& fields, const TSourceLoc& line)
{
	fields.num = (int) compString.size();
	if (fields.num > 4)
	{
		error(line, "illegal vector field selection", compString.c_str(), "");
		return false;
	}
	
	enum
	{
		exyzw,
		ergba,
		estpq,
	} fieldSet[4];
	
	for (int i = 0; i < fields.num; ++i)
	{
		switch (compString[i])
		{
		case 'x': 
			fields.offsets[i] = 0;
			fieldSet[i] = exyzw;
			break;
		case 'r': 
			fields.offsets[i] = 0;
			fieldSet[i] = ergba;
			break;
		case 's':
			fields.offsets[i] = 0;
			fieldSet[i] = estpq;
			break;
		case 'y': 
			fields.offsets[i] = 1;
			fieldSet[i] = exyzw;
			break;
		case 'g': 
			fields.offsets[i] = 1;
			fieldSet[i] = ergba;
			break;
		case 't':
			fields.offsets[i] = 1;
			fieldSet[i] = estpq;
			break;
		case 'z': 
			fields.offsets[i] = 2;
			fieldSet[i] = exyzw;
			break;
		case 'b': 
			fields.offsets[i] = 2;
			fieldSet[i] = ergba;
			break;
		case 'p':
			fields.offsets[i] = 2;
			fieldSet[i] = estpq;
			break;
			
		case 'w': 
			fields.offsets[i] = 3;
			fieldSet[i] = exyzw;
			break;
		case 'a': 
			fields.offsets[i] = 3;
			fieldSet[i] = ergba;
			break;
		case 'q':
			fields.offsets[i] = 3;
			fieldSet[i] = estpq;
			break;
		default:
			error(line, "illegal vector field selection", compString.c_str(), "");
			return false;
		}
	}
	
	for (int i = 0; i < fields.num; ++i)
	{
		if (fields.offsets[i] >= vecSize)
		{
			error(line, "vector field selection out of range",  compString.c_str(), "");
			return false;
		}
		
		if (i > 0)
		{
			if (fieldSet[i] != fieldSet[i-1])
			{
				error(line, "illegal - vector component fields not from the same set", compString.c_str(), "");
				return false;
			}
		}
	}
	
	return true;
}

//
// Look at a '.' field selector string and change it into offsets
// for a matrix.
//
bool TParseContext::parseMatrixFields(const TString& compString, int matCols, int matRows, TVectorFields& fields, const TSourceLoc& line)
{
	fields.num = 1;
	fields.offsets[0] = 0;
	
	if (compString.size() < 3  || compString[0] != '_')
	{
		error(line, "illegal matrix field selection", compString.c_str(), "");
		return false;
	}
	
	if (compString[1] == 'm')
	{
		//The selection is 0 based with the syntax _m## 
		if ( (compString.size() % 4) != 0 || compString.size() > 16)
		{
			error(line, "illegal matrix field selection", compString.c_str(), "");
			return false;
		}
		for (int ii = 0; ii < (int)compString.size(); ii+=4)
		{
			if (compString[ii] != '_' || compString[ii + 1] != 'm')
			{
				error(line, "illegal matrix field selection", compString.c_str(), "");
				return false;
			}
			if (compString[ii + 2] < '0' || compString[ii + 2] > '3' ||
				compString[ii + 3] < '0' || compString[ii + 3] > '3')
			{
				error(line, "illegal matrix field selection", compString.c_str(), "");
				return false;
			}
			int row = compString[ii + 2] - '0';
			int collumn = compString[ii + 3] - '0';
			if ( row >= matRows || collumn >= matCols)
			{
				error(line, "matrix field selection out of range", compString.c_str(), "");
				return false;
			}
			fields.offsets[ii/4] =  row * 4 + collumn;
		}
		fields.num = static_cast<int>(compString.size())/4;
	}
	else
	{
		//The selection is 1 based with the syntax _##
		if ( (compString.size() % 3) != 0 || compString.size() > 12)
		{
			error(line, "illegal matrix field selection", compString.c_str(), "");
			return false;
		}
		for (int ii = 0; ii < (int)compString.size(); ii += 3)
		{
			if (compString[ii] != '_')
			{
				error(line, "illegal matrix field selection", compString.c_str(), "");
				return false;
			}
			if (compString[ii + 1] < '1' || compString[ii + 1] > '4' ||
				compString[ii + 2] < '1' || compString[ii + 2] > '4')
			{
				error(line, "illegal matrix field selection", compString.c_str(), "");
				return false;
			}
			int row = compString[ii + 1] - '1';
			int collumn = compString[ii + 2] - '1';
			if ( row >= matRows || collumn >= matCols)
			{
				error(line, "matrix field selection out of range", compString.c_str(), "");
				return false;
			}
			fields.offsets[ii/3] =  row * 4 + collumn;
		}
		fields.num = static_cast<int>(compString.size())/3;
	}
	
	return true;
}

// ------------------------------------------------------------------
// Errors

//
// Track whether errors have occurred.
//
void TParseContext::recover()
{
   recoveredFromError = true;
}

//
// Used by flex/bison to output all syntax and parsing errors.
//
void C_DECL TParseContext::error(TSourceLoc nLine, const char *szReason, const char *szToken, 
                                 const char *szExtraInfoFormat, ...)
{
   char szExtraInfo[400];
   va_list marker;

   va_start(marker, szExtraInfoFormat);

   _vsnprintf(szExtraInfo, sizeof(szExtraInfo), szExtraInfoFormat, marker);

   /* VC++ format: file(linenum) : error #: 'token' : extrainfo */
   infoSink.info.location(nLine);
   infoSink.info.prefix(EPrefixError);
   infoSink.info << "'" << szToken <<  "' : " << szReason << " " << szExtraInfo << "\n";

   va_end(marker);

   ++numErrors;
}

//
// Same error message for all places assignments don't work.
//
void TParseContext::assignError(const TSourceLoc& line, const char* op, TString left, TString right)
{
   error(line, "", op, "cannot convert from '%s' to '%s'",
         right.c_str(), left.c_str());
}

//
// Same error message for all places unary operations don't work.
//
void TParseContext::unaryOpError(const TSourceLoc& line, const char* op, TString operand)
{
   error(line, " wrong operand type", op, 
         "no operation '%s' exists that takes an operand of type %s (or there is no acceptable conversion)",
         op, operand.c_str());
}

//
// Same error message for all binary operations don't work.
//
void TParseContext::binaryOpError(const TSourceLoc& line, const char* op, TString left, TString right)
{
   error(line, " wrong operand types ", op, 
         "no operation '%s' exists that takes a left-hand operand of type '%s' and "
         "a right operand of type '%s' (or there is no acceptable conversion)", 
         op, left.c_str(), right.c_str());
}

//
// Both test and if necessary, spit out an error, to see if the node is really
// an l-value that can be operated on this way.
//
// Returns true if the was an error.
//
bool TParseContext::lValueErrorCheck(const TSourceLoc& line, const char* op, TIntermTyped* node)
{
	TIntermSymbol* symNode = node->getAsSymbolNode();
	TIntermBinary* binaryNode = node->getAsBinaryNode();
	
	if (binaryNode)
	{
		bool errorReturn;
		
		switch (binaryNode->getOp())
		{
			case EOpIndexDirect:
			case EOpIndexIndirect:
			case EOpIndexDirectStruct:
				return lValueErrorCheck(line, op, binaryNode->getLeft());
			case EOpVectorSwizzle:
				errorReturn = lValueErrorCheck(line, op, binaryNode->getLeft());
				if (!errorReturn)
				{
					int offset[4] = {0,0,0,0};
					
					TIntermTyped* rightNode = binaryNode->getRight();
					TIntermAggregate *aggrNode = rightNode->getAsAggregate();
					
					for (TNodeArray::iterator p = aggrNode->getNodes().begin(); 
						 p != aggrNode->getNodes().end(); p++)
					{
						int value = (*p)->getAsTyped()->getAsConstant()->toInt();
						offset[value]++;     
						if (offset[value] > 1)
						{
							error(line, " l-value of swizzle cannot have duplicate components", op, "", "");
							
							return true;
						}
					}
				}
			case EOpMatrixSwizzle:
				errorReturn = lValueErrorCheck(line, op, binaryNode->getLeft());
				if (!errorReturn)
				{
					int offset[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
					
					TIntermTyped* rightNode = binaryNode->getRight();
					TIntermAggregate *aggrNode = rightNode->getAsAggregate();
					
					for (TNodeArray::iterator p = aggrNode->getNodes().begin(); 
						 p != aggrNode->getNodes().end(); p++)
					{
						int value = (*p)->getAsTyped()->getAsConstant()->toInt();
						offset[value]++;     
						if (offset[value] > 1)
						{
							error(line, " l-value of swizzle cannot have duplicate components", op, "", "");
							
							return true;
						}
					}
				}
				
				return errorReturn;
			default: 
				break;
		}
		error(line, " l-value required", op, "", "");
		
		return true;
	}
	
	
	const char* symbol = 0;
	if (symNode != 0)
		symbol = symNode->getSymbol().c_str();
	
	const char* message = 0;
	switch (node->getQualifier())
	{
		case EvqConst:          message = "can't modify a const";        break;
		case EvqAttribute:      message = "can't modify an attribute";   break;
		case EvqUniform:
			// mark this uniform as mutable
			node->getTypePointer()->changeQualifier(EvqMutableUniform);
			break;
		default:
			
			//
			// Type that can't be written to?
			//
			switch (node->getBasicType())
			{
				case EbtSamplerGeneric:
				case EbtSampler1D:
				case EbtSampler2D:
				case EbtSampler3D:
				case EbtSamplerCube:
				case EbtSampler1DShadow:
				case EbtSampler2DShadow:
				case EbtSampler2DArray:
				case EbtSamplerRect:       // ARB_texture_rectangle
				case EbtSamplerRectShadow: // ARB_texture_rectangle
					message = "can't modify a sampler";
					break;
				case EbtVoid:
					message = "can't modify void";
					break;
				default: 
					break;
			}
	}
	
	if (message == 0 && binaryNode == 0 && symNode == 0)
	{
		error(line, " l-value required", op, "", "");
		
		return true;
	}
	
	
	//
	// Everything else is okay, no error.
	//
	if (message == 0)
		return false;
	
	//
	// If we get here, we have an error and a message.
	//
	if (symNode)
		error(line, " l-value required", op, "\"%s\" (%s)", symbol, message);
	else
		error(line, " l-value required", op, "(%s)", message);
	
	return true;
}

//
// Both test, and if necessary spit out an error, to see if the node is really
// a constant.
//
// Returns true if the was an error.
//
bool TParseContext::constErrorCheck(TIntermTyped* node)
{
   if (node->getQualifier() == EvqConst)
      return false;

   error(node->getLine(), "constant expression required", "", "");

   return true;
}

//
// Both test, and if necessary spit out an error, to see if the node is really
// an integer or convertible to an integer.
//
// Returns true if the was an error.
//
bool TParseContext::scalarErrorCheck(TIntermTyped* node, const char* token)
{
    if (node->isScalar())
        return false;

   error(node->getLine(), "scalar expression required", token, "");

   return true;
}

//
// Both test, and if necessary spit out an error, to see if we are currently
// globally scoped.
//
// Returns true if the was an error.
//
bool TParseContext::globalErrorCheck(const TSourceLoc& line, bool global, const char* token)
{
   if (global)
      return false;

   error(line, "only allowed at global scope", token, "");

   return true;
}

//
// For now, keep it simple:  if it starts "gl_", it's reserved, independent
// of scope.  Except, if the symbol table is at the built-in push-level,
// which is when we are parsing built-ins.
//
// Returns true if there was an error.
//
bool TParseContext::reservedErrorCheck(const TSourceLoc& line, const TString& identifier)
{
   if (!symbolTable.atBuiltInLevel())
   {
      if (identifier.substr(0, 3) == TString("gl_"))
      {
         error(line, "reserved built-in name", "gl_", "");
         return true;
      }
      if (identifier.find("__") != TString::npos)
      {
         infoSink.info.message(EPrefixWarning, "Two consecutive underscores are reserved for future use.", line);
         return false;
      }
   }

   return false;
}

//
// Make sure there is enough data provided to the constructor to build
// something of the type of the constructor.  Also returns the type of
// the constructor.
//
// Returns true if there was an error in construction.
//
bool TParseContext::constructorErrorCheck(const TSourceLoc& line, TIntermNode* node, TFunction& function, TOperator op, TType* type)
{
   *type = function.getReturnType();

   bool constructingMatrix = false;
   switch (op)
   {
   case EOpConstructMat2x2:
   case EOpConstructMat2x3:
   case EOpConstructMat2x4:
   case EOpConstructMat3x2:
   case EOpConstructMat3x3:
   case EOpConstructMat3x4:
   case EOpConstructMat4x2:
   case EOpConstructMat4x3:
   case EOpConstructMat4x4:
      constructingMatrix = true;
      break;
   default: 
      break;
   }

   //
   // Note: It's okay to have too many components available, but not okay to have unused
   // arguments.  'full' will go to true when enough args have been seen.  If we loop
   // again, there is an extra argument, so 'overfull' will become true.
   //

   int size = 0;
   bool constType = true;
   bool full = false;
   bool overFull = false;
   bool arrayArg = false;
   for (int i = 0; i < function.getParamCount(); ++i)
   {
      size += function[i].type->getObjectSize();

      if (full)
         overFull = true;
      if (op != EOpConstructStruct && !type->isArray() && size >= type->getObjectSize())
         full = true;
      if (function[i].type->getQualifier() != EvqConst)
         constType = false;
      if (function[i].type->isArray())
         arrayArg = true;
   }
	
	if (constructingMatrix)
		constType = false;

   if (constType)
      type->changeQualifier(EvqConst);

   if (type->isArray() && type->getArraySize() != function.getParamCount())
   {
      error(line, "array constructor needs one argument per array element", "constructor", "");
      return true;
   }

   if (arrayArg && op != EOpConstructStruct)
   {
      error(line, "constructing from a non-dereferenced array", "constructor", "");
      return true;
   }

   if (overFull)
   {
      error(line, "too many arguments", "constructor", "");
      return true;
   }

   if (op == EOpConstructStruct && !type->isArray() && (type->getStruct()->size() != function.getParamCount() && function.getParamCount() != 1))
   {
      error(line, "Number of constructor parameters does not match the number of structure fields", "constructor", "");
      return true;
   }

   if (( size != 1 && size < type->getObjectSize()) ||
       ((op == EOpConstructStruct && size < type->getObjectSize()) && size > 1))
   {
      error(line, "not enough data provided for construction", "constructor", "");
      return true;
   }

   TIntermTyped* typed = node->getAsTyped();
   if (typed == 0)
   {
      error(line, "constructor argument does not have a type", "constructor", "");
      return true;
   }
   if (op != EOpConstructStruct && IsSampler(typed->getBasicType()))
   {
      error(line, "cannot convert a sampler", "constructor", "");
      return true;
   }
   if (typed->getBasicType() == EbtVoid)
   {
      error(line, "cannot convert a void", "constructor", "");
      return true;
   }

   return false;
}

// This function checks to see if a void variable has been declared and raise an error message for such a case
//
// returns true in case of an error
//
bool TParseContext::voidErrorCheck(const TSourceLoc& line, const TString& identifier, const TPublicType& pubType)
{
   if (pubType.type == EbtVoid)
   {
      error(line, "illegal use of type 'void'", identifier.c_str(), "");
      return true;
   }

   return false;
}

// This function checks to see if the node (for the expression) contains a scalar boolean expression or not
//
// returns true in case of an error
//
bool TParseContext::boolErrorCheck(const TSourceLoc& line, const TIntermTyped* type)
{
   // In HLSL, any float or int will be automatically casted to a bool, so the basic type can be bool,
   // float, or int.
   if ((type->getBasicType() != EbtBool && type->getBasicType() != EbtInt && type->getBasicType() != EbtFloat) || 
        type->isArray() || type->isMatrix() || type->isVector())
   {
      error(line, "boolean expression expected", "", "");
      return true;
   }

   return false;
}


bool TParseContext::boolOrVectorErrorCheck(const TSourceLoc& line, const TIntermTyped* type)
{
	// In HLSL, any float or int will be automatically casted to a bool, so the basic type can be bool,
	// float, or int.
	if ((type->getBasicType() != EbtBool && type->getBasicType() != EbtInt && type->getBasicType() != EbtFloat) || 
        type->isArray() || type->isMatrix())
	{
		error(line, "boolean or vector expression expected", "", "");
		return true;
	}
	
	return false;
}


// This function checks to see if the node (for the expression) contains a scalar boolean expression or not
//
// returns true in case of an error
//
bool TParseContext::boolErrorCheck(const TSourceLoc& line, const TPublicType& pType)
{
   // In HLSL, any float or int will be automatically casted to a bool, so the basic type can be bool,
   // float, or int.   
   if ((pType.type != EbtBool && pType.type != EbtInt && pType.type != EbtFloat) ||
        pType.array || pType.matrix || (pType.matcols > 1) || (pType.matrows > 1))
   {
      error(line, "boolean expression expected", "", "");
      return true;
   }

   return false;
}

bool TParseContext::samplerErrorCheck(const TSourceLoc& line, const TPublicType& pType, const char* reason)
{
   if (pType.type == EbtStruct)
   {
      if (containsSampler(*pType.userDef))
      {
         error(line, reason, TType::getBasicString(pType.type), "(structure contains a sampler)");

         return true;
      }

      return false;
   }
   else if (IsSampler(pType.type))
   {
      error(line, reason, TType::getBasicString(pType.type), "");

      return true;
   }

   return false;
}

bool TParseContext::structQualifierErrorCheck(const TSourceLoc& line, const TPublicType& pType)
{
   if (pType.qualifier == EvqAttribute && pType.type == EbtStruct)
   {
      error(line, "cannot be used with a structure", getQualifierString(pType.qualifier), "");

      return true;
   }


   return false;
}

bool TParseContext::parameterSamplerErrorCheck(const TSourceLoc& line, TQualifier qualifier, const TType& type)
{
   if ((qualifier == EvqOut || qualifier == EvqInOut) && 
       type.getBasicType() != EbtStruct && IsSampler(type.getBasicType()))
   {
      error(line, "samplers cannot be output parameters", type.getBasicString(), "");
      return true;
   }

   return false;
}

bool TParseContext::containsSampler(TType& type)
{
   if (IsSampler(type.getBasicType()))
      return true;

   if (type.getBasicType() == EbtStruct)
   {
      TTypeList& structure = *type.getStruct();
      for (unsigned int i = 0; i < structure.size(); ++i)
      {
         if (containsSampler(*structure[i].type))
            return true;
      }
   }

   return false;
}

bool TParseContext::insertBuiltInArrayAtGlobalLevel()
{
   TString *name = NewPoolTString("gl_TexCoord");
   TSymbol* symbol = symbolTable.find(*name);
   if (!symbol)
   {
      error(gNullSourceLoc, "INTERNAL ERROR finding symbol", name->c_str(), "");
      return true;
   }
   TVariable* variable = static_cast<TVariable*>(symbol);

   TVariable* newVariable = new TVariable(name, variable->getType());

   if (! symbolTable.insert(*newVariable))
   {
      delete newVariable;
      error(gNullSourceLoc, "INTERNAL ERROR inserting new symbol", name->c_str(), "");
      return true;
   }

   return false;
}



// Do size checking for an array type's size.
// NOTE: deletes passed expression!
// Returns true if there was an error.
bool TParseContext::arraySizeErrorCheck(const TSourceLoc& line, TIntermTyped* expr, int& size)
{
	TIntermConstant* constant = expr->getAsConstant();
	if (constant == 0 || constant->getBasicType() != EbtInt)
	{
		delete expr;
		error(line, "array size must be a constant integer expression", "", "");
		return true;
	}

	size = constant->toInt();
	delete expr;

	if (size <= 0)
	{
		error(line, "array size must be a positive integer", "", "");
		size = 1;
		return true;
	}

	return false;
}

//
// See if this qualifier can be an array.
//
// Returns true if there is an error.
//
bool TParseContext::arrayQualifierErrorCheck(const TSourceLoc& line, TPublicType type)
{
   if (type.qualifier == EvqAttribute)
   {
      error(line, "cannot declare arrays of this qualifier", TType(type).getCompleteString().c_str(), "");
      return true;
   }

   return false;
}

//
// See if this type can be an array.
//
// Returns true if there is an error.
//
bool TParseContext::arrayTypeErrorCheck(const TSourceLoc& line, TPublicType type)
{
   //
   // Can the type be an array?
   //
   if (type.array)
   {
      error(line, "multidimentional arrays ar not supported", TType(type).getCompleteString().c_str(), "");
      return true;
   }

   return false;
}

//
// Do all the semantic checking for declaring an array, with and 
// without a size, and make the right changes to the symbol table.
//
// size == 0 means no specified size.
//
// Returns true if there was an error.
//
bool TParseContext::arrayErrorCheck(const TSourceLoc& line, TString& identifier, TPublicType type, TVariable*& variable)
{

   return arrayErrorCheck( line, identifier, 0, type, variable);
}


static inline void AdjustTypeQualifier(TPublicType& type)
{
	if (type.qualifier == EvqGlobal)
		type.qualifier = EvqUniform; // according to hlsl, non static globals are uniforms
	else if (type.qualifier == EvqStatic)
		type.qualifier = EvqGlobal;	
}

//
// Do all the semantic checking for declaring an array, with and 
// without a size, and make the right changes to the symbol table.
//
// size == 0 means no specified size.
//
// Returns true if there was an error.
//
bool TParseContext::arrayErrorCheck(const TSourceLoc& line, TString& identifier, const TTypeInfo *info, TPublicType type, TVariable*& variable)
{
   //
   // Don't check for reserved word use until after we know it's not in the symbol table,
   // because reserved arrays can be redeclared.
   //
	
	AdjustTypeQualifier (type);

   bool builtIn = false; 
   bool sameScope = false;
   TSymbol* symbol = symbolTable.find(identifier, &builtIn, &sameScope);
   if (symbol == 0 || !sameScope)
   {
      if (reservedErrorCheck(line, identifier))
         return true;

      variable = new TVariable(&identifier, info, TType(type));

      if (type.arraySize)
         variable->getType().setArraySize(type.arraySize);

      if (! symbolTable.insert(*variable))
      {
         delete variable;
         error(line, "INTERNAL ERROR inserting new symbol", identifier.c_str(), "");
         return true;
      }
   }
   else
   {
      if (! symbol->isVariable())
      {
         error(line, "variable expected", identifier.c_str(), "");
         return true;
      }

      variable = static_cast<TVariable*>(symbol);
      if (! variable->getType().isArray())
      {
         error(line, "redeclaring non-array as array", identifier.c_str(), "");
         return true;
      }
      if (variable->getType().getArraySize() > 0)
      {
         error(line, "redeclaration of array with size", identifier.c_str(), "");
         return true;
      }

      if (! variable->getType().sameElementType(TType(type)))
      {
         error(line, "redeclaration of array with a different type", identifier.c_str(), "");
         return true;
      }

      TType* t = variable->getArrayInformationType();
      while (t != 0)
      {
         if (t->getMaxArraySize() > type.arraySize)
         {
            error(line, "higher index value already used for the array", identifier.c_str(), "");
            return true;
         }
         t->setArraySize(type.arraySize);
         t = t->getArrayInformationType();
      }

      if (type.arraySize)
         variable->getType().setArraySize(type.arraySize);
   } 

   if (voidErrorCheck(line, identifier, type))
      return true;

   return false;
}

bool TParseContext::arraySetMaxSize(TIntermSymbol *node, TType* type, int size, bool updateFlag, TSourceLoc line)
{
   bool builtIn = false;
   TSymbol* symbol = symbolTable.find(node->getSymbol(), &builtIn);
   if (symbol == 0)
   {
      error(line, " undeclared identifier", node->getSymbol().c_str(), "");
      return true;
   }
   TVariable* variable = static_cast<TVariable*>(symbol);

   type->setArrayInformationType(variable->getArrayInformationType());
   variable->updateArrayInformationType(type);

   // we dont want to update the maxArraySize when this flag is not set, we just want to include this 
   // node type in the chain of node types so that its updated when a higher maxArraySize comes in.
   if (!updateFlag)
      return false;

   size++;
   variable->getType().setMaxArraySize(size);
   type->setMaxArraySize(size);
   TType* tt = type;

   while (tt->getArrayInformationType() != 0)
   {
      tt = tt->getArrayInformationType();
      tt->setMaxArraySize(size);
   }

   return false;
}

//
// Enforce non-initializer type/qualifier rules.
//
// Returns true if there was an error.
//
bool TParseContext::nonInitConstErrorCheck(const TSourceLoc& line, TString& identifier, TPublicType& type)
{
   //
   // Make the qualifier make sense.
   //
   if (type.qualifier == EvqConst)
   {
      type.qualifier = EvqTemporary;
      error(line, "variables with qualifier 'const' must be initialized", identifier.c_str(), "");
      return true;
   }

   return false;
}

//
// Do semantic checking for a variable declaration that has no initializer,
// and update the symbol table.
//
// Returns true if there was an error.
//
bool TParseContext::nonInitErrorCheck(const TSourceLoc& line, TString& identifier, TPublicType& type)
{

   return nonInitErrorCheck( line, identifier, 0, type);
}

//
// Do semantic checking for a variable declaration that has no initializer,
// and update the symbol table.
//
// Returns true if there was an error.
//
bool TParseContext::nonInitErrorCheck(const TSourceLoc& line, TString& identifier, const TTypeInfo *info, TPublicType& type)
{
   if (reservedErrorCheck(line, identifier))
      recover();

	AdjustTypeQualifier (type);

   TVariable* variable = new TVariable(&identifier, info, TType(type));

   if (! symbolTable.insert(*variable))
   {
      error(line, "redefinition", variable->getName().c_str(), "");
      delete variable;
      return true;
   }

   if (voidErrorCheck(line, identifier, type))
      return true;

   return false;
}

bool TParseContext::paramErrorCheck(const TSourceLoc& line, TQualifier qualifier, TQualifier paramQualifier, TType* type)
{
   if (qualifier != EvqConst && qualifier != EvqTemporary && qualifier != EvqUniform)
   {
      error(line, "qualifier not allowed on function parameter", getQualifierString(qualifier), "");
      return true;
   }
   if (qualifier == EvqConst && paramQualifier != EvqIn)
   {
      error(line, "qualifier not allowed with ", getQualifierString(qualifier), getQualifierString(paramQualifier));
      return true;
   }

   if (qualifier == EvqUniform)
      type->changeQualifier(EvqUniform);
   else if (qualifier == EvqConst)
      type->changeQualifier(EvqConst);
   else
      type->changeQualifier(paramQualifier);

   return false;
}


// ------------------------------------------------------------------
// Non-Errors.


//
// Look up a function name in the symbol table, and make sure it is a function.
//
// Return the function symbol if found, otherwise 0.
//
const TFunction* TParseContext::findFunction(const TSourceLoc& line, TFunction* call, bool *builtIn)
{
   const TSymbol* symbol = symbolTable.find(call->getMangledName(), builtIn);

   if (symbol == 0)
   {
      // The symbol was not found, look for a unambiguous type conversion
      bool ambiguous = false;

      symbol = symbolTable.findCompatible( call, builtIn, ambiguous);

      if (symbol == 0)
      {
         if (ambiguous)
            error(line, "cannot resolve function call unambiguously", call->getName().c_str(), "(check parameter types)");
         else
            error(line, "no matching overloaded function found", call->getName().c_str(), "");
         return 0;
      }
   }

   if (! symbol->isFunction())
   {
      error(line, "function name expected", call->getName().c_str(), "");
      return 0;
   }

   const TFunction* function = static_cast<const TFunction*>(symbol);

   return function;
}

//
// Initializers show up in several places in the grammar.  Have one set of
// code to handle them here.
//
bool TParseContext::executeInitializer(TSourceLoc line, TString& identifier, TPublicType& pType, 
                                       TIntermTyped*& initializer, TIntermSymbol*& intermNode, TVariable* variable)
{

   return executeInitializer( line, identifier, 0, pType, initializer, intermNode, variable);
}

//
// Initializers show up in several places in the grammar.  Have one set of
// code to handle them here.
//
bool TParseContext::executeInitializer(TSourceLoc line, TString& identifier, const TTypeInfo *info, TPublicType& pType, 
                                       TIntermTyped*& initializer, TIntermSymbol*& intermNode, TVariable* variable)
{
	AdjustTypeQualifier (pType);

	TType type = TType(pType);
	if (variable == 0)
	{
		if (reservedErrorCheck(line, identifier))
			return true;

		if (voidErrorCheck(line, identifier, pType))
			return true;

		//
		// add variable to symbol table
		//
		variable = new TVariable(&identifier, info, type);
		if (! symbolTable.insert(*variable))
		{
			error(line, "redefinition", variable->getName().c_str(), "");
			return true;
			// don't delete variable, it's used by error recovery, and the pool 
			// pop will take care of the memory
		}
	} 
	//check to see if we have a blind aggregate
	TIntermAggregate *agg = initializer->getAsAggregate();
	if (agg && agg->getOp() == EOpNull)
	{	
		if (type.isArray() && type.getArraySize() == 0)
			variable->getType().setArraySize(agg->getNodes().size());
		
		if (type.getStruct())
			variable->getType().setStruct(type.getStruct());
		
		initializer = addConstructor(agg, &variable->getType(), getConstructorOp(variable->getType()), 0, agg->getLine());
		if ( initializer == NULL )
			return true;
		
		type = variable->getType();
	}
	
	TIntermTyped* converted = ir_add_conversion(EOpAssign, type, initializer, infoSink);
	if (converted)
		initializer = converted;

	//
	// identifier must be of type constant, a global, or a temporary
	//
	TQualifier qualifier = variable->getType().getQualifier();
	if ((qualifier != EvqTemporary) && (qualifier != EvqGlobal) && (qualifier != EvqConst) && (qualifier != EvqUniform))
	{
		error(line, " cannot initialize this type of qualifier ", variable->getType().getQualifierString(), "");
		return true;
	}
	
	TQualifier initializerQualifier = initializer->getType().getQualifier();	
	bool isConst = (initializerQualifier == EvqConst);
	// GLSL 1.20+ allows more things in constant initializers;
	// not so much for earlier GLSL versions.
	if (!isConst && (targetVersion >= ETargetGLSL_120))
	{
		/*
		// isBranchConstant doesn't actually work yet, e.g. it sees "-foobar" and assumes it's
		// constant no matter what foobar actually is. Disable for now.
		 
		isConst |= isBranchConstant(initializer);
		if (isConst)
		{
			initializerQualifier = EvqConst;
			initializer->getTypePointer()->changeQualifier(initializerQualifier);
		}
		 */
	}
	
	// Are we trying to initialize a constant?
	if (qualifier == EvqConst)
	{
		// Handle cases where initializer type does not match
		if (type != initializer->getType())
		{
			const TBasicType basicType = type.getBasicType();
			const TBasicType initializerType = initializer->getType().getBasicType();
			
			// allow type promotion (eg: const float SCALE = 2;)
			if ((basicType == EbtFloat) && (initializerType == EbtInt) && (type.getObjectSize() == initializer->getType().getObjectSize()))
			{
				// allow this
			}
			else
			{
				error(line, " non-matching types for const initializer", variable->getType().getQualifierString(), "");
				variable->getType().changeQualifier(EvqTemporary);
				return true;				
			}
		}
		
		// If we're trying to initialize something marked as const with a non-const initializer,
		// change its type to temporary instead
		if (initializerQualifier != EvqConst)
		{
			qualifier = EvqTemporary;
			variable->getType().changeQualifier(qualifier);
		}
		else if (!isConst)
		{
			error(line, " Attempting to initialize a const variable with a non-constant initializer", "", "");
			variable->getType().changeQualifier(EvqTemporary);
			return true;
		}
	}
	

	// constant initializer value, if present
	if (initializer->getAsConstant())
	{
		variable->constValue = initializer->getAsConstant();
	}
	
//ACS: this was stopping non-type-explicit constant initializers from working (was that by design?)
//  e.g. it allowed this: 
//      uniform float3 my_constants = float3(1, 2, 3);
//  but not this, which afaik is legal hlsl: 
//      uniform float3 my_constants = { 1, 2, 3 };
//
// 	if (qualifier == EvqUniform)
// 	{
// 		if (!isConst)
// 		{
// 			error(line, " Attempting to initialize uniform with a non-constant initializer", "", "");
// 			variable->getType().changeQualifier(EvqTemporary);
// 			return true;
// 		}
// 	}

	TIntermSymbol* intermSymbol = ir_add_symbol(variable, line);
	intermNode = intermSymbol;
	return false;
}

// Returns false if this was a matrix that still needs a transpose
static bool TransposeMatrixConstructorArgs (const TType* type, TNodeArray& args)
{
	if (!type->isMatrix())
		return true;
	if (args.size() != type->getObjectSize())
		return false;

	// HLSL vs. GLSL construct matrices in transposed order, so transpose the arguments for the constructor
	const int cols = type->getColsCount();
	const int rows = type->getRowsCount();
	for (int r = 0; r < rows; ++r)
	{
		for (int c = r+1; c < cols; ++c)
		{
			size_t idx1 = r*cols+c;
			size_t idx2 = c*rows+r;
			std::swap (args[idx1], args[idx2]);
		}
	}

	return true;
}


// This function is used to test for the correctness of the parameters passed to various constructor functions
// and also convert them to the right datatype if it is allowed and required. 
//
// Returns 0 for an error or the constructed node (aggregate or typed) for no error.
//
TIntermTyped* TParseContext::addConstructor(TIntermNode* node, const TType* type, TOperator op, TFunction* fnCall, TSourceLoc line)
{
	if (node == 0)
		return 0;
	
	TTypeList * struct_members = type->getStruct();
	TIntermAggregate* aggregate = node->getAsAggregate();
	if (aggregate && aggregate->getOp() == EOpNull) {
		
		if (type->isArray())
			return constructArray(aggregate, type, op, line);
		
		TType element_type = *type;
		element_type.clearArrayness();
		
		TNodeArray &params = aggregate->getNodes();
		unsigned n_params = params.size();
		for (unsigned i = 0; i != n_params; ++i) {
			TIntermNode* p = params[i];
			if (type->isArray())
				p = constructBuiltIn(&element_type, op, p, node->getLine(), true);
			else if (op == EOpConstructStruct)
            {
                assert(struct_members);
				p = constructStruct(p, (*struct_members)[i].type, i+1, node->getLine(), true);
            }
			else
				p = constructBuiltIn(type, op, p, node->getLine(), true);
			
			if (p)
				params[i] = p;
		}
		
		TIntermTyped* constructor = ir_set_aggregate_op(aggregate, op, line);
		constructor->setType(*type);
		if (!TransposeMatrixConstructorArgs (type, params))
			constructor = ir_add_unary_math (EOpTranspose, constructor, line, *this);
		
		return constructor;
	}
	
	if (type->isArray())
		return constructBuiltIn(type, op, node, node->getLine(), true);
	else if (op == EOpConstructStruct)
	{
        assert(struct_members);
		TType* firstPrimitiveType = (*struct_members)[0].type;
		while (firstPrimitiveType->getBasicType() == EbtStruct)
		{
			firstPrimitiveType = (*firstPrimitiveType->getStruct())[0].type;
		}
		return constructStruct(node, firstPrimitiveType, 1, node->getLine(), false);
	}
	else
		return constructBuiltIn(type, op, node, node->getLine(), false);
}

// Function for determining which basic constructor op to use
TOperator TParseContext::getConstructorOp( const TType& type)
{
   TOperator op = EOpNull;

   switch (type.getBasicType())
   {
   case EbtFloat:
      if (type.isMatrix())
      {
         switch (type.getColsCount())
         {
         case 2:
           switch (type.getRowsCount())
           {
           case 2: op = EOpConstructMat2x2; break;
           case 3: op = EOpConstructMat2x3; break;
           case 4: op = EOpConstructMat2x4; break;
           default: op = EOpNull; break;
           } break;
         case 3:
           switch (type.getRowsCount())
           {
           case 2: op = EOpConstructMat3x2; break;
           case 3: op = EOpConstructMat3x3; break;
           case 4: op = EOpConstructMat3x4; break;
           default: op = EOpNull; break;
           } break;
         case 4:
           switch (type.getRowsCount())
           {
           case 2: op = EOpConstructMat4x2; break;
           case 3: op = EOpConstructMat4x3; break;
           case 4: op = EOpConstructMat4x4; break;
           default: op = EOpNull; break;
           } break;
         }
      }
      else
      {
         switch (type.getRowsCount())
         {
         case 1: op = EOpConstructFloat; break;
         case 2: op = EOpConstructVec2; break;
         case 3: op = EOpConstructVec3; break;
         case 4: op = EOpConstructVec4; break;
         default: op = EOpNull; break;
         }
      }
      break;
   case EbtInt:
      switch (type.getRowsCount())
      {
      case 1: op = EOpConstructInt; break;
      case 2: op = EOpConstructIVec2; break;
      case 3: op = EOpConstructIVec3; break;
      case 4: op = EOpConstructIVec4; break;
      default: op = EOpNull; break;
      }
      break;
   case EbtBool:
      switch (type.getRowsCount())
      {
      case 1: op = EOpConstructBool; break;
      case 2: op = EOpConstructBVec2; break;
      case 3: op = EOpConstructBVec3; break;
      case 4: op = EOpConstructBVec4; break;
      default: op = EOpNull; break;
      }
      break;
   case EbtStruct: op = EOpConstructStruct; break;
   default:
      op = EOpNull;
      break;
   }
   return op;
}

TIntermTyped* TParseContext::constructBuiltInAllowUpwardVectorPromote(
    const TType* type, TOperator op, TIntermNode* node, TSourceLoc line, bool subset)
{
    TIntermTyped* tNode = node->getAsTyped();
    // Handle upward promotion of vectors:
    //   HLSL allows upward promotion of vectors as a special case to function calls.  For example,
    //   the call mul( mf4, vf3 ) will end up upward promoting the second argument from a float3
    //   to a float4 ( xyz, 0 ).  This code here generalizes this case, where in the case that
    //   an upward promotion of a vector is required, the necessary constants initializers are
    //   added to an aggregate.
    if ( tNode->getRowsCount() < type->getRowsCount() && tNode->isVector() && type->isVector() )
    {
        TIntermAggregate *tempAgg = 0;

        // Add the vector being uprward promoted
        tempAgg = ir_grow_aggregate(tempAgg, tNode, line);

        // Determine the number of trailing 0's required
        int nNumZerosToPad = type->getRowsCount() - tNode->getRowsCount();
        for ( int nPad = 0; nPad < nNumZerosToPad; nPad++ )
        {
            // Create a new constant with value 0.0
            TIntermConstant *cUnion = ir_add_constant(TType(EbtFloat, EbpUndefined, EvqConst), tNode->getLine());
            cUnion->setValue(0.0f);

            // Add the constant to the aggregrate node
            tempAgg = ir_grow_aggregate( tempAgg, cUnion, tNode->getLine()); 
        }

        // Construct the built-in with padding
        tNode = constructBuiltIn (type, op, tempAgg, line, subset);
    }
    else
    {
        tNode = constructBuiltIn(type, op, tNode, line, subset);
    }

    return tNode;
}

// This function promotes the function arguments contained in node to
// match the types from func.
TIntermNode* TParseContext::promoteFunctionArguments( TIntermNode *node, const TFunction* func)
{
   TIntermAggregate *aggNode = node->getAsAggregate();
   TIntermTyped *tNode = 0;
   TIntermNode *ret = 0;

   // if the node is an aggregate list of parameters to a function call, promote
   // each individual subnode. Note the Op could be EOpNull too while processing,
   // the important distinction is we should not include other aggregates like
   // EOpTex2DLod
   if (aggNode && aggNode->getOp() <= EOpParameters)
   {
      //This is a function call with multiple arguments
      TNodeArray &seq = aggNode->getNodes();
      int paramNum = 0;

      assert( (int)seq.size() == func->getParamCount());

      for ( TNodeArray::iterator it = seq.begin(); it != seq.end(); it++, paramNum++)
      { 
         tNode = (*it)->getAsTyped();

         if ( tNode != 0 && tNode->getType() != *(*func)[paramNum].type)
         {
            TOperator op = getConstructorOp(*(*func)[paramNum].type);
            tNode = constructBuiltInAllowUpwardVectorPromote( (*func)[paramNum].type, op, tNode, tNode->getLine(), false);
         }

         if ( !tNode )
         {
            //function parameters need to have a type
            ret = 0;
            break;
         }

         ret = ir_grow_aggregate( ret, tNode, node->getLine());
      }
   }
   else
   {
      assert( func->getParamCount() == 1);
      TOperator op = getConstructorOp(*(*func)[0].type);
      ret = constructBuiltInAllowUpwardVectorPromote( (*func)[0].type, op, node, node->getLine(), false);
   }

   return ret;
}

TIntermTyped* TParseContext::addAssign(TOperator op, TIntermTyped* left, TIntermTyped* right, TSourceLoc loc)
{
   TIntermTyped *tNode;


   if ( (tNode = ir_add_assign(op,left,right,loc, *this)) == 0)
   {
      //need to convert
      TOperator cop = getConstructorOp( left->getType());
      TType type = left->getType();
      tNode = constructBuiltIn( &type, cop, right, loc, false);
      tNode = ir_add_assign(op, left, tNode, loc, *this);
   }

   return tNode;
}

// Function for constructor implementation. Calls ir_add_unary_math with appropriate EOp value
// for the parameter to the constructor (passed to this function). Essentially, it converts
// the parameter types correctly. If a constructor expects an int (like ivec2) and is passed a 
// float, then float is converted to int.
//
// Returns 0 for an error or the constructed node.
//
TIntermTyped* TParseContext::constructBuiltIn(const TType* type, TOperator op, TIntermNode* node, TSourceLoc line, bool subset)
{
	TIntermTyped* newNode;
	TOperator basicOp;
	
	// Check for no-op constructions such as casting to the same builtin type.
	if (node->getAsTyped() && *node->getAsTyped()->getTypePointer() == *type) {
		return node->getAsTyped();
	}

	//
	// First, convert types as needed.
	//
	switch (op)
	{
	case EOpConstructVec2:
	case EOpConstructVec3:
	case EOpConstructVec4:
	case EOpConstructMat2x2:
	case EOpConstructMat2x3:
	case EOpConstructMat2x4:
	case EOpConstructMat3x2:
	case EOpConstructMat3x3:
	case EOpConstructMat3x4:
	case EOpConstructMat4x2:
	case EOpConstructMat4x3:
	case EOpConstructMat4x4:
	case EOpConstructFloat:
		basicOp = EOpConstructFloat;
		break;

	case EOpConstructIVec2:
	case EOpConstructIVec3:
	case EOpConstructIVec4:
	case EOpConstructInt:
		basicOp = EOpConstructInt;
		break;

	case EOpConstructBVec2:
	case EOpConstructBVec3:
	case EOpConstructBVec4:
	case EOpConstructBool:
		basicOp = EOpConstructBool;
		break;

	default:
		error(line, "unsupported construction", "", "");
		recover();
		return 0;
	}
	newNode = ir_add_unary_math(basicOp, node, node->getLine(), *this);
	if (newNode == 0)
	{
	  error(line, "can't convert", "constructor", "");
	  return 0;
	}

    // this conversion is not allowed, except when passing a parameter to a function
    if ( newNode->getTypePointer()->isVector() && type->isVector() &&
         newNode->getRowsCount() < type->getRowsCount())
        return 0;

    //
    // Now, if there still isn't an operation to do the construction, and we need one, add one.
    //

	// Otherwise, skip out early.
	if (subset || (newNode != node && newNode->getType() == *type))
	  return newNode;

   //now perform HLSL style matrix conversions
   if ( newNode->getTypePointer()->isMatrix() && type->isMatrix())
   {
      if (newNode->getColsCount() < type->getColsCount() ||
          newNode->getRowsCount() < type->getRowsCount())
          return 0;
	   
	   if (targetVersion < ETargetGLSL_120)
	   {
		   const int c = type->getColsCount();
		   const int r = type->getRowsCount();
		   if (c == 2 && r == 2)
			   op = EOpConstructMat2x2FromMat;
		   else if (c == 3 && r == 3)
			   op = EOpConstructMat3x3FromMat;
		   //@TODO: errors on others?
	   }
	   else
	   {

		  switch (type->getColsCount())
		  {
		  case 2:
			  switch (type->getRowsCount())
			  {
			  case 2: op = EOpConstructMat2x2; break;
			  case 3: op = EOpConstructMat2x3; break;
			  case 4: op = EOpConstructMat2x4; break;
			  } break;
		  case 3:
			  switch (type->getRowsCount())
			  {
			  case 2: op = EOpConstructMat3x2; break;
			  case 3: op = EOpConstructMat3x3; break;
			  case 4: op = EOpConstructMat3x4; break;
			  } break;
		  case 4:
			  switch (type->getRowsCount())
			  {
			  case 2: op = EOpConstructMat4x2; break;
			  case 3: op = EOpConstructMat4x3; break;
			  case 4: assert(false); break;
			  } break;
		  }
	   }
   }

	// will insert a new node for the constructor, as needed.
	newNode = ir_set_aggregate_op(newNode, op, line);
	newNode->setType(*type);
	return newNode;
}

// This function tests for the type of the parameters to the structures constructors. Raises
// an error message if the expected type does not match the parameter passed to the constructor.
//
// Returns 0 for an error or the input node itself if the expected and the given parameter types match.
//
TIntermTyped* TParseContext::constructStruct(TIntermNode* node, TType* type, int paramCount, TSourceLoc line, bool subset)
{
	TIntermTyped* result = 0;
	if (*type == node->getAsTyped()->getType())
		result = subset ? node->getAsTyped() : ir_set_aggregate_op(node->getAsTyped(), EOpConstructStruct, line);
	else if (node->getAsConstant())
		result = ir_promote_constant(type->getBasicType(), node->getAsConstant(), infoSink);
	else if (node->getAsTyped())
		result = ir_add_conversion(EOpAssign, *type, node->getAsTyped(), infoSink);
		
	if (result)
		return result;
	
	error(line, "", "constructor", "cannot convert parameter %d from '%s' to '%s'", paramCount, node->getAsTyped()->getType().getBasicString(), type->getBasicString());
	recover();

	return 0;
}

//
// This function tries to construct an array from an aggregate
//
TIntermTyped* TParseContext::constructArray(TIntermAggregate* aggNode, const TType* type, TOperator op, TSourceLoc line)
{
   TType elementType = *type;
   int elementCount = type->getArraySize();
   TIntermAggregate *newAgg = 0;

   elementType.clearArrayness();

   TNodeArray &seq = aggNode->getNodes();
   TNodeArray::iterator sit = seq.begin();

   // Count the total size of the initializer sequence and make sure it matches the array size
   int nInitializerSize = 0;
   while ( sit != seq.end() )
   {
      nInitializerSize += (*sit)->getAsTyped()->getSize();
      sit++;
   }

   if ( nInitializerSize != elementType.getObjectSize() * elementCount)
   {
      error(line, "", "constructor", "improper number of arguments to array constructor, expected %d got %d",
            elementType.getObjectSize() *elementCount, nInitializerSize);
      recover();
      return 0;
   }
	
	aggNode->setType(*type);
	aggNode->setOperator(EOpConstructArray);
	
	return aggNode;

  /* sit = seq.begin();

   // Loop over each of the elements in the initializer sequence and add to the constructors
   for (int ii = 0; ii < elementCount; ii++)
   {
      TIntermAggregate *tempAgg = 0;

      // Initialize this element of the array
      int nInitSize = 0;
      while ( nInitSize < elementType.getObjectSize() )
      {
         tempAgg = ir_grow_aggregate( tempAgg, *sit, line);
         nInitSize += (*sit)->getAsTyped()->getSize();
         sit++;
      }

      // Check to make sure that the initializer does not span array size boundaries.  This is allowed in
      // HLSL, although currently not supported by the translator.  It could be done, it will just make
      // the array code generation much more complicated, because it will have to potentially break up
      // elements that span array boundaries.
      if ( nInitSize != elementType.getObjectSize() )
      {
         error ( line, "", "constructor", "can not handle initializers that span array element boundaries");
         recover();
         return 0;           
      }
      newAgg = ir_grow_aggregate( newAgg, addConstructor( tempAgg, &elementType, op, 0, line), line);
   }*/

   return addConstructor( newAgg, type, op, 0, line);

}



// This function takes two aggragates, and merges them into a single one
// It does not nest the right inside the left, as ir_grow_aggregate would
TIntermAggregate* TParseContext::mergeAggregates( TIntermAggregate *left, TIntermAggregate *right)
{
   TIntermAggregate *node = left;
   if (!left)
      return right;

   if (right)
   {
      TNodeArray &seq = right->getNodes();

      for ( TNodeArray::iterator it = seq.begin(); it != seq.end(); it++)
      {
         node = ir_grow_aggregate( node, *it, right->getLine());
      }
   }

   return node;
}

OS_TLSIndex GlobalParseContextIndex = OS_INVALID_TLS_INDEX;

bool InitializeParseContextIndex()
{
   if (GlobalParseContextIndex != OS_INVALID_TLS_INDEX)
   {
     // assert(0 && "InitializeParseContextIndex(): Parse Context already initalised");
      return true;
   }

   //
   // Allocate a TLS index.
   //
   GlobalParseContextIndex = OS_AllocTLSIndex();

   if (GlobalParseContextIndex == OS_INVALID_TLS_INDEX)
   {
      assert(0 && "InitializeParseContextIndex(): Parse Context already initalised");
      return false;
   }

   return true;
}

bool InitializeGlobalParseContext()
{
   if (GlobalParseContextIndex == OS_INVALID_TLS_INDEX)
   {
      assert(0 && "InitializeGlobalParseContext(): Parse Context index not initalised");
      return false;
   }

   TThreadParseContext *lpParseContext = static_cast<TThreadParseContext *>(OS_GetTLSValue(GlobalParseContextIndex));
   if (lpParseContext != 0)
   {
//      assert(0 && "InitializeParseContextIndex(): Parse Context already initalised");
      return true;
   }

   TThreadParseContext *lpThreadData = new TThreadParseContext();
   if (lpThreadData == 0)
   {
      assert(0 && "InitializeGlobalParseContext(): Unable to create thread parse context");
      return false;
   }

   lpThreadData->lpGlobalParseContext = 0;
   OS_SetTLSValue(GlobalParseContextIndex, lpThreadData);

   return true;
}

TParseContextPointer& GetGlobalParseContext()
{
   //
   // Minimal error checking for speed
   //

   TThreadParseContext *lpParseContext = static_cast<TThreadParseContext *>(OS_GetTLSValue(GlobalParseContextIndex));

   return lpParseContext->lpGlobalParseContext;
}

bool FreeParseContext()
{
   if (GlobalParseContextIndex == OS_INVALID_TLS_INDEX)
   {
      assert(0 && "FreeParseContext(): Parse Context index not initalised");
      return false;
   }

   TThreadParseContext *lpParseContext = static_cast<TThreadParseContext *>(OS_GetTLSValue(GlobalParseContextIndex));
   if (lpParseContext)
      delete lpParseContext;

   return true;
}

bool FreeParseContextIndex()
{
   OS_TLSIndex tlsiIndex = GlobalParseContextIndex;

   if (GlobalParseContextIndex == OS_INVALID_TLS_INDEX)
   {
      assert(0 && "FreeParseContextIndex(): Parse Context index not initalised");
      return false;
   }

   GlobalParseContextIndex = OS_INVALID_TLS_INDEX;

   return OS_FreeTLSIndex(tlsiIndex);
}



} //namespace hlslang {

