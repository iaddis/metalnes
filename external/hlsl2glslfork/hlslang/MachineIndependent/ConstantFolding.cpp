// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "../Include/intermediate.h"

namespace hlslang {

// Limited constant folding functionality; we mostly want it for array sizes
// with constant expressions.
// Returns the node to keep using, or NULL.


TIntermConstant* FoldBinaryConstantExpression(TOperator op, TIntermConstant* nodeA, TIntermConstant* nodeB)
{
	if (!nodeA || !nodeB)
		return NULL;
	if (nodeA->getType() != nodeB->getType())
		return NULL;
	
	// for now, only support integers and floats
	if (nodeA->getBasicType() != EbtInt && nodeA->getBasicType() != EbtFloat)
		return NULL;
		
	
	TIntermConstant* newNode = new TIntermConstant(nodeA->getType());

#define DO_FOLD_OP(oper) \
	if (nodeA->getBasicType() == EbtInt) \
		for (unsigned i = 0; i < newNode->getCount(); ++i) \
			newNode->setValue(i, nodeA->getValue(i).asInt oper nodeB->getValue(i).asInt); \
	else \
		for (unsigned i = 0; i < newNode->getCount(); ++i) \
			newNode->setValue(i, nodeA->getValue(i).asFloat oper nodeB->getValue(i).asFloat)

#define DO_FOLD_OP_INT(oper) \
	if (nodeA->getBasicType() == EbtInt) \
		for (unsigned i = 0; i < newNode->getCount(); ++i) \
		newNode->setValue(i, nodeA->getValue(i).asInt oper nodeB->getValue(i).asInt); \
	else { \
		delete newNode; \
		return NULL; \
	}

#define DO_FOLD_OP_ZERO(oper) \
	if (nodeA->getBasicType() == EbtInt) \
		for (unsigned i = 0; i < newNode->getCount(); ++i) \
			newNode->setValue(i, nodeB->getValue(i).asInt ? nodeA->getValue(i).asInt oper nodeB->getValue(i).asInt : 0); \
	else \
		for (unsigned i = 0; i < newNode->getCount(); ++i) \
			newNode->setValue(i, nodeB->getValue(i).asInt ? nodeA->getValue(i).asFloat oper nodeB->getValue(i).asFloat : 0)
	
	switch (op)
	{
		case EOpAdd: DO_FOLD_OP(+); break;
		case EOpSub: DO_FOLD_OP(-); break;
		case EOpMul: DO_FOLD_OP(*); break;
		case EOpDiv: DO_FOLD_OP_ZERO(/); break;
		case EOpMod:
			if (nodeA->getBasicType() == EbtInt)
			{
				for (unsigned i = 0; i < newNode->getCount(); ++i)
					newNode->setValue(i, nodeB->getValue(i).asInt ? nodeA->getValue(i).asInt % nodeB->getValue(i).asInt : 0);
			}
			else
			{
				delete newNode;
				return NULL;
			}
			break;
		case EOpRightShift: DO_FOLD_OP_INT(>>); break;
		case EOpLeftShift: DO_FOLD_OP_INT(<<); break;
		case EOpAnd: DO_FOLD_OP_INT(&); break;
		case EOpInclusiveOr: DO_FOLD_OP_INT(|); break;
		case EOpExclusiveOr: DO_FOLD_OP_INT(^); break;
		default:
			delete newNode;
			return NULL;
	}
	newNode->setLine(nodeA->getLine());
	delete nodeA;
	delete nodeB;
	return newNode;
}


TIntermConstant* FoldUnaryConstantExpression(TOperator op, TIntermConstant* node)
{
	if (!node)
		return NULL;
	
	// for now, only support integers and floats
	if (node->getBasicType() != EbtInt && node->getBasicType() != EbtFloat)
		return NULL;
	
	TIntermConstant* newNode = new TIntermConstant(node->getType());
	switch (op)
	{
		case EOpNegative:
			if (node->getBasicType() == EbtInt)
			{
				for (unsigned i = 0; i < newNode->getCount(); ++i)
					newNode->setValue(i, -node->getValue(i).asInt);
			}
			else
			{
				for (unsigned i = 0; i < newNode->getCount(); ++i)
					newNode->setValue(i, -node->getValue(i).asFloat);
			}
			break;
		default:
			delete newNode;
			return NULL;
	}
	newNode->setLine(node->getLine());
	delete node;
	return newNode;
}

}
