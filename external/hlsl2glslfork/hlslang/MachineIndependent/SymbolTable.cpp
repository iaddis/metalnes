// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "SymbolTable.h"
#include <algorithm>

namespace hlslang {


TString* TParameter::NullSemantic = 0;

bool TSymbolTableLevel::insert(TSymbol& symbol) 
{
	//
	// returning true means symbol was added to the table
	//
	tInsertResult result;
	result = level.insert(tLevelPair(symbol.getMangledName(), &symbol));
	
	return result.second;
}

// Recursively generate mangled names.
void TType::buildMangledName(TString& mangledName) const
{
	if (isMatrix())
		mangledName += 'm';
	else if (isVector())
		mangledName += 'v';
	
	switch (type)
	{
		case EbtFloat:              mangledName += 'f';      break;
		case EbtInt:                mangledName += 'i';      break;
		case EbtBool:               mangledName += 'b';      break;
		case EbtSamplerGeneric:     mangledName += "sg";     break;
		case EbtSampler1D:          mangledName += "s1";     break;
		case EbtSampler2D:          mangledName += "s2";     break;
		case EbtSampler3D:          mangledName += "s3";     break;
		case EbtSamplerCube:        mangledName += "sC";     break;
		case EbtSampler1DShadow:    mangledName += "sS1";    break;
		case EbtSampler2DShadow:    mangledName += "sS2";    break;
		case EbtSampler2DArray:     mangledName += "sA2";    break;
		case EbtSamplerRect:        mangledName += "sR2";    break;  // ARB_texture_rectangle
		case EbtSamplerRectShadow:  mangledName += "sSR2";   break;  // ARB_texture_rectangle
		case EbtStruct:
			mangledName += "struct_";
			if (typeName)
				mangledName += *typeName;
		{// support MSVC++6.0
			for (unsigned int i = 0; i < structure->size(); ++i)
			{
				mangledName += '_';
				(*structure)[i].type->buildMangledName(mangledName);
			}
		}
		default: 
			break;
	}

	if (isMatrix())
	{
		mangledName += static_cast<char>('0' + getColsCount());
		mangledName += "x";
	}

	if (isMatrix() || isVector())
		mangledName += static_cast<char>('0' + getRowsCount());

	if (isArray())
	{
		char buf[10];
		sprintf(buf, "%d", arraySize);
		mangledName += 'a';
		mangledName += buf;
	}
}

int TType::getStructSize() const
{
	if (!getStruct())
	{
		assert(false && "Not a struct");
		return 0;
	}
	
	if (structureSize == 0)
		for (TTypeList::iterator tl = getStruct()->begin(); tl != getStruct()->end(); tl++)
			structureSize += ((*tl).type)->getObjectSize();
	
	return structureSize;
}


// Determine the parameter compatibility between this type and the parameter type
TType::ECompatibility TType::determineCompatibility ( const TType *pType ) const
{
	// make sure the array info matches
	if ( isArray() && pType->isArray() &&
		 getArraySize() != pType->getArraySize())
	{
		return NOT_COMPATIBLE;
	}

	if ( isArray() != pType->isArray())
	{
		return NOT_COMPATIBLE;
	}

	if ( IsNumeric( getBasicType() ) &&
		 IsNumeric( pType->getBasicType() ) && !isArray() )
	{
		// both parameters are numeric, so we can possibly convert

		// only allow matrices to convert to matrices
		if ( isMatrix() != pType->isMatrix())
			return NOT_COMPATIBLE;

		// Check if this is a promotion from a smaller vector to
		// larger vector.  HLSL allows this on function calls and
		// pads the result to 0.0.  The work to make these promotions
		// happen is in TParseContext::promoteFunctionArguments
		if ( getRowsCount() < pType->getRowsCount())
		{
			if ( isVector() && pType->isVector() )
				return UPWARD_VECTOR_PROMOTION_EXISTS;
			else
				return NOT_COMPATIBLE;
		}

		if (getBasicType() == pType->getBasicType())
		{
			if ( getRowsCount() == pType->getRowsCount() &&
				 getColsCount() == pType->getColsCount())
				return MATCH_EXACTLY;
			else if ( getRowsCount() >= pType->getRowsCount() &&
					  getColsCount() >= pType->getColsCount())
				return PROMOTION_EXISTS;
			else
				return NOT_COMPATIBLE;
		}
		// changing the type also counts as a promotion
		else
		{
			// if size match, it's an implicit cast
			if ( getRowsCount() == pType->getRowsCount() &&
				 getColsCount() == pType->getColsCount())
				return IMPLICIT_CAST_EXISTS;
			// If the sizes don't match, then this is an implicit cast
			// with a promotion
			else if ( getRowsCount() >= pType->getRowsCount() &&
					  getColsCount() >= pType->getColsCount())
				return IMPLICIT_CAST_WITH_PROMOTION_EXISTS;
			else
				return NOT_COMPATIBLE;
		}
	}
	else if ( getBasicType() == pType->getBasicType() )
	{
		// base types match, make sure everything else is OK

		// structs are a special case, we need to look inside
		if ( getBasicType() == EbtStruct)
		{
			// make sure the struct is OK
			return NOT_COMPATIBLE;
		}
	}
	else
	{
		// This means that we have a conversion that crosses incompatible types
		// Presently, this means that we cannot handle sampler conversions
		return NOT_COMPATIBLE;
	}

	return MATCH_EXACTLY;
}

// Dump functions.
void TVariable::dump(TInfoSink& infoSink) const 
{
	infoSink.debug << getName().c_str() << ": " << type.getQualifierString() << " " << type.getBasicString();
	if (type.isArray())
	{
		infoSink.debug << "[0]";
	}
	infoSink.debug << "\n";
}

void TFunction::dump(TInfoSink &infoSink) const
{
	infoSink.debug << getName().c_str() << ": " <<  returnType.getBasicString() << " " << getMangledName().c_str() << "\n";
}

void TSymbolTableLevel::dump(TInfoSink &infoSink) const 
{
	tLevel::const_iterator it;
	for (it = level.begin(); it != level.end(); ++it)
		(*it).second->dump(infoSink);
}

void TSymbolTable::dump(TInfoSink &infoSink) const
{
	for (int level = currentLevel(); level >= 0; --level)
	{
		infoSink.debug << "LEVEL " << level << "\n";
		table[level]->dump(infoSink);
	}
}


TFunction::~TFunction()
{
	for (TParamList::iterator i = parameters.begin(); i != parameters.end(); ++i)
		delete (*i).type;
}

TSymbolTableLevel::~TSymbolTableLevel()
{
	for (tLevel::iterator it = level.begin(); it != level.end(); ++it)
		delete (*it).second;
}


// Change all function entries in the table with the non-mangled name
// to be related to the provided built-in operation.  This is a low
// performance operation, and only intended for symbol tables that
// live across a large number of compiles.
void TSymbolTableLevel::relateToOperator(const char* name, TOperator op) 
{
	tLevel::iterator it;
	for (it = level.begin(); it != level.end(); ++it)
	{
		if ((*it).second->isFunction())
		{
			TFunction* function = static_cast<TFunction*>((*it).second);
			if (function->getName() == name)
				function->relateToOperator(op);
		}
	}
}    


TSymbol::TSymbol(const TSymbol& copyOf)
{
	name = NewPoolTString(copyOf.name->c_str());
	uniqueId = copyOf.uniqueId;
}

TVariable::TVariable(const TVariable& copyOf, TStructureMap& remapper) : TSymbol(copyOf)
{
	type.copyType(copyOf.type, remapper);
	userType = copyOf.userType;
	// for builtIn symbol table level, unionArray and arrayInformation pointers should be NULL
	assert(copyOf.arrayInformationType == 0); 
	arrayInformationType = 0;
}

TVariable* TVariable::clone(TStructureMap& remapper) 
{
	TVariable *variable = new TVariable(*this, remapper);
	
	return variable;
}

TFunction::TFunction(const TFunction& copyOf, TStructureMap& remapper) : TSymbol(copyOf)
{
	for (unsigned int i = 0; i < copyOf.parameters.size(); ++i)
	{
		TParameter param;
		parameters.push_back(param);
		parameters.back().copyParam(copyOf.parameters[i], remapper);
	}
	
	returnType.copyType(copyOf.returnType, remapper);
	mangledName = copyOf.mangledName;
	op = copyOf.op;
	defined = copyOf.defined;
}

TFunction* TFunction::clone(TStructureMap& remapper) 
{
	TFunction *function = new TFunction(*this, remapper);
	
	return function;
}


TSymbolTableLevel* TSymbolTableLevel::clone(TStructureMap& remapper)
{
	TSymbolTableLevel *symTableLevel = new TSymbolTableLevel();
	tLevel::iterator iter;
	for (iter = level.begin(); iter != level.end(); ++iter)
	{
		symTableLevel->insert(*iter->second->clone(remapper));
	}
	
	return symTableLevel;
}

// This is the sort function for parameter matching in findCompatible method below
bool parameterSizeSortFunction(TParameter left, TParameter right) {
	// non-numeric types come first
	if (!IsNumeric(left.type->getBasicType()))
		return true;
	else if (IsNumeric(left.type->getBasicType()) && !IsNumeric(right.type->getBasicType()))
		return false;
	// then sort according to numeric type's dimension in descending order
	else return (left.type->getColsCount() >= right.type->getColsCount() && left.type->getRowsCount() >= right.type->getRowsCount());
}

// This function uses the matching rules as described in the Cg language doc (the closest
// thing we have to HLSL function matching description) to find a matching compatible function.  
TSymbol* TSymbolTableLevel::findCompatible (const TFunction *call, bool &ambiguous) const
{
	ambiguous = false;
	
	const TString &name = call->getName();   
	std::vector<TFunction*> funcList;
	
	// 1 and 2. Add all functions with matching names and argument count to the set to consider
	tLevel::const_iterator it = level.begin();
	while (it != level.end())
	{
		if (it->second->getName() == name && it->second->isFunction())
		{
			TFunction* func = (TFunction*)it->second;
			if (call->getParamCount() == func->getParamCount())
				funcList.push_back (func);
		}
		++it;
	}
		
	// HLSL follows different matching rules than Cg, e.g. step(float, float2) is matched as step(float2, float) by HLSL
	// while Cg matches step(float, float). Sort parameters by dimensions in descending order instead of left-to-right
	// to keep parameters promoting up.
	TVector<TParameter> sortedParameters;
	for ( int nParam = 0; nParam < call->getParamCount() ; nParam++ )
	{
		sortedParameters.push_back((*call)[nParam]);
	}
	std::sort(sortedParameters.begin(), sortedParameters.end(), parameterSizeSortFunction);
	
	// For each actual parameter expression, in the sequence:
	for ( int nParam = 0; nParam < sortedParameters.size() ; nParam++ )
	{
		const TType* type0 = sortedParameters[nParam].type;
		
		// From the Cg function matching rules, perform the following matching on each parameter
		//
		// 3. For each parameter in the expression, if the type matches exactly, remove
		// all functions which do not match exactly
		//
		// 4. If there is a defined promotion for the type of the actual parameter to the unqualified type
		// of the formal parameter of any function, remove all functions for which this is not true
		//
		// 5. If there is a implicit cast for the type of the actual parameter to the unqualified type
		// of the formal parameter of any function, remove all functions for which this is not true
		//
		// 6. *** Not part of Cg rules, but used to differentiate between an implicit cast and an
		//        implicit cast with promotion.  This additional rule favors implict casts over
		//        implicit casts that also require promotion ***
		//    If there is a implicit cast with a promotion for the type of the actual parameter to the unqualified type
		//    of the formal parameter of any function, remove all functions for which this is not true     
		//
		// 7. *** Not part of Cg rules, but used to allow HLSL upward promotion on function calls ***
		//    If there is an upward vector promotion for the type of the actual parameter to the unqualified type
		//    of the formal parameter of any function, remove all functions for which this is not true.
		const TType::ECompatibility eCompatType[] =
		{
			TType::MATCH_EXACTLY,
			TType::PROMOTION_EXISTS,
			TType::IMPLICIT_CAST_EXISTS,
			TType::IMPLICIT_CAST_WITH_PROMOTION_EXISTS,
			TType::UPWARD_VECTOR_PROMOTION_EXISTS
		};
		
		// Iterate over each matching type (declared above)
		for ( int nIter = 0; nIter < sizeof(eCompatType) / sizeof (TType::ECompatibility); nIter++ )
		{
			bool bMatchesCompatibility = false;
			
			// Grab the compatibility type for the test
			TType::ECompatibility eCompatibility = eCompatType[nIter];
			
			std::vector<TFunction*>::iterator funcIter = funcList.begin();
			while (funcIter != funcList.end())
			{
				const TFunction* curFunc = *(funcIter);
				const TType* type1 = (*curFunc)[nParam].type;
				
				// Check to see if the compatibility matches the compatibility type for this test
				if ( type0->determineCompatibility ( type1 ) == eCompatibility )
				{
					bMatchesCompatibility = true;
					break;               
				}
				
				funcIter++;
			}
			
			if ( bMatchesCompatibility )
			{
				// Remove all that don't match this compatibility test
				funcIter = funcList.begin();
				while ( funcIter != funcList.end() )
				{
					TFunction* curFunc = *(funcIter);
					const TType* type1 = (*curFunc)[nParam].type;
					
					if ( type0->determineCompatibility ( type1 ) != eCompatibility )
					{
						funcIter = funcList.erase ( funcIter );               
					}
					else
						funcIter++;
				}
			}
		}
	}
	
	
	// If the function list has 1 element, then we were successful
	if ( funcList.size() == 1 )
		return funcList.front();
	// If there is more than one element, it is ambiguous
	else if ( funcList.size () > 1 )
	{
		ambiguous = true;
		return NULL;
	}
	
	// No function found
	return NULL;
}

void TSymbolTable::copyTable(const TSymbolTable& copyOf)
{
	TStructureMap remapper;
	uniqueId = copyOf.uniqueId;
	for (unsigned int i = 0; i < copyOf.table.size(); ++i)
	{
		table.push_back(copyOf.table[i]->clone(remapper));
	}
}

} //namespace hlslang {

