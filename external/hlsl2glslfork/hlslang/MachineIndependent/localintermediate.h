// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#ifndef _LOCAL_INTERMEDIATE_INCLUDED_
#define _LOCAL_INTERMEDIATE_INCLUDED_

#include "../Include/intermediate.h"
#include "../../include/hlsl2glsl.h"
#include "SymbolTable.h"

namespace hlslang {

struct TVectorFields
{
   int offsets[4];
   int num;
};

//
// Set of helper functions to help parse and build the tree.
//
class TInfoSink;

TIntermSymbol* ir_add_symbol(const TVariable* var, TSourceLoc);
TIntermSymbol* ir_add_symbol_internal(int id, const TString& name, const TTypeInfo *info, const TType& type, TSourceLoc line);
TIntermConstant* ir_add_constant(const TType&, TSourceLoc);
TIntermTyped* ir_add_index(TOperator op, TIntermTyped* base, TIntermTyped* index, TSourceLoc);
TIntermTyped* ir_add_comma(TIntermTyped* left, TIntermTyped* right, TSourceLoc);

TIntermTyped* ir_add_unary_math(TOperator op, TIntermNode* child, TSourceLoc, TParseContext& ctx);
TIntermTyped* ir_add_binary_math(TOperator op, TIntermTyped* left, TIntermTyped* right, TSourceLoc, TParseContext& ctx);
TIntermNode*  ir_add_selection(TIntermTyped* cond, TIntermNodePair code, TSourceLoc, TInfoSink& infoSink);
TIntermTyped* ir_add_selection(TIntermTyped* cond, TIntermTyped* trueBlock, TIntermTyped* falseBlock, TSourceLoc, TInfoSink& infoSink);
TIntermBranch* ir_add_branch(TOperator, TSourceLoc);
TIntermBranch* ir_add_branch(TOperator, TIntermTyped*, TSourceLoc);
TIntermNode* ir_add_loop(TLoopType type, TIntermTyped* cond, TIntermTyped* expr, TIntermNode* body, TSourceLoc line);
TIntermTyped* ir_add_swizzle(TVectorFields&, TSourceLoc);
TIntermTyped* ir_add_vector_swizzle(TVectorFields& fields, TIntermTyped* arg, TSourceLoc lineDot, TSourceLoc lineIndex);
TIntermTyped* ir_add_assign(TOperator op, TIntermTyped* left, TIntermTyped* right, TSourceLoc, TParseContext& ctx);
TIntermDeclaration* ir_add_declaration(TIntermSymbol* symbol, TIntermTyped* initializer, TSourceLoc line, TParseContext& ctx);
TIntermDeclaration* ir_add_declaration(TSymbol* symbol, TIntermTyped* initializer, TSourceLoc line, TParseContext& ctx);

TIntermTyped* ir_add_conversion(TOperator, const TType&, TIntermTyped*, TInfoSink& infoSink);

TIntermTyped* ir_promote_constant(TBasicType, TIntermConstant*, TInfoSink& infoSink);
TIntermAggregate* ir_grow_aggregate(TIntermNode* left, TIntermNode* right, TSourceLoc, TOperator expectedOp = EOpNull);
TIntermAggregate* ir_make_aggregate(TIntermNode* node, TSourceLoc);
TIntermAggregate* ir_set_aggregate_op(TIntermNode*, TOperator, TSourceLoc);
TIntermAggregate* ir_grow_declaration(TIntermTyped* declaration, TIntermSymbol* symbol, TIntermTyped* initializer, TParseContext& ctx);
TIntermAggregate* ir_grow_declaration(TIntermTyped* declaration, TSymbol* symbol, TIntermTyped* initializer, TParseContext& ctx);

TOperator ir_get_constructor_op_float(const TPublicType& t, TParseContext& ctx);
TOperator ir_get_constructor_op(const TPublicType& t, TParseContext& ctx, bool allowStruct);


void ir_output_tree(TIntermNode* root, TInfoSink& infoSink);

static inline TPublicType ir_get_decl_type_noarray(TIntermTyped* decl)
{
	TType& t = *decl->getTypePointer();
	TPublicType p = {
		t.getBasicType(),
		t.getQualifier(),
		t.getPrecision(),
		t.getColsCount(),
		t.getRowsCount(),
		t.isMatrix(),
		false,
		0,
		t.getBasicType() == EbtStruct ? &t : NULL,
		t.getLine()
	};
	return p;
}

}

#endif // _LOCAL_INTERMEDIATE_INCLUDED_

