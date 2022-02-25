// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "../Include/intermediate.h"
#include "RemoveTree.h"

// Code to recursively delete the intermediate tree.

namespace hlslang {

static void RemoveSymbol(TIntermSymbol* node, TIntermTraverser* it)
{
   delete node;
}

static bool RemoveBinary(bool  /*preVisit*/ , TIntermBinary* node, TIntermTraverser*)
{
   delete node;
   return true;
}

static bool RemoveUnary(bool, /*preVisit */ TIntermUnary* node, TIntermTraverser*)
{
   delete node;
   return true;
}

static bool RemoveAggregate(bool  /*preVisit*/ , TIntermAggregate* node, TIntermTraverser*)
{
   delete node;
   return true;
}

static bool RemoveSelection(bool  /*preVisit*/ , TIntermSelection* node, TIntermTraverser*)
{
   delete node;
   return true;
}

static void RemoveConstant(TIntermConstant* node, TIntermTraverser*)
{
   delete node;
}

void ir_remove_tree(TIntermNode* root)
{
	if (!root)
		return;
	
   TIntermTraverser it;

   it.visitAggregate     = RemoveAggregate;
   it.visitBinary        = RemoveBinary;
   it.visitConstant = RemoveConstant;
   it.visitSelection     = RemoveSelection;
   it.visitSymbol        = RemoveSymbol;
   it.visitUnary         = RemoveUnary;

   it.preVisit = false;
   it.postVisit = true;

   root->traverse(&it);
}

}
