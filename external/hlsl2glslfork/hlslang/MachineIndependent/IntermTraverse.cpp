// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "../Include/intermediate.h"

namespace hlslang {

//
// Traverse the intermediate representation tree, and
// call a node type specific function for each node.
// Done recursively through the member function Traverse().
// Node types can be skipped if their function to call is 0,
// but their subtree will still be traversed.
// Nodes with children can have their whole subtree skipped
// if preVisit is turned on and the type specific function
// returns false.
//
// preVisit, postVisit control what order
// nodes are visited in.
//

//
// Traversal functions for terminals are straighforward....
//
void TIntermSymbol::traverse(TIntermTraverser* it)
{
   if (it->visitSymbol)
      it->visitSymbol(this, it);
}

void TIntermDeclaration::traverse(TIntermTraverser* it)
{	
	if (it->preVisit && it->visitDeclaration && !it->visitDeclaration(true, this, it))
		return;
	
	_declaration->traverse(it);
	
	if (it->postVisit && it->visitDeclaration)
		it->visitDeclaration(false, this, it);
}

void TIntermConstant::traverse(TIntermTraverser* it)
{
   if (it->visitConstant)
      it->visitConstant(this, it);
}

//
// Traverse a binary node.
//
void TIntermBinary::traverse(TIntermTraverser* it)
{
   bool visit = true;

   //
   // visit the node before children if pre-visiting.
   //
   if (it->preVisit && it->visitBinary)
      visit = it->visitBinary(true, this, it);

   //
   // Visit the children, in the right order.
   //
   if (visit)
   {
      ++it->depth;
      if (left)
         left->traverse(it);
      if (right)
         right->traverse(it);
      --it->depth;
   }

   //
   // Visit the node after the children, if requested and the traversal
   // hasn't been cancelled yet.
   //
   if (visit && it->postVisit && it->visitBinary)
      it->visitBinary(false, this, it);
}

//
// Traverse a unary node.  Same comments in binary node apply here.
//
void TIntermUnary::traverse(TIntermTraverser* it)
{
   bool visit = true;

   if (it->preVisit && it->visitUnary)
      visit = it->visitUnary(true, this, it);

   if (visit)
   {
      ++it->depth;
      operand->traverse(it);
      --it->depth;
   }

   if (visit && it->postVisit && it->visitUnary)
      it->visitUnary(false, this, it);
}

//
// Traverse an aggregate node.  Same comments in binary node apply here.
//
void TIntermAggregate::traverse(TIntermTraverser* it)
{
   bool visit = true;

   if (it->preVisit && it->visitAggregate)
      visit = it->visitAggregate(true, this, it);

   if (visit)
   {
      ++it->depth;

      TNodeArray::iterator sit;
      for (sit = nodes.begin(); sit != nodes.end(); ++sit)
         (*sit)->traverse(it);

      --it->depth;
   }

   if (visit && it->postVisit && it->visitAggregate)
      it->visitAggregate(false, this, it);
}

//
// Traverse a selection node.  Same comments in binary node apply here.
//
void TIntermSelection::traverse(TIntermTraverser* it)
{
   bool visit = true;

   if (it->preVisit && it->visitSelection)
      visit = it->visitSelection(true, this, it);

   if (visit)
   {
      ++it->depth;
      condition->traverse(it);
      if (trueBlock)
         trueBlock->traverse(it);
      if (falseBlock)
         falseBlock->traverse(it);
      --it->depth;
   }

   if (visit && it->postVisit && it->visitSelection)
      it->visitSelection(false, this, it);
}

// Traverse a loop node.  Same comments in binary node apply here.
void TIntermLoop::traverse(TIntermTraverser* it)
{
   bool visit = true;

   if (it->preVisit && it->visitLoop)
      visit = it->visitLoop(true, this, it);

   if (visit)
   {
      ++it->depth;
      if (cond)
         cond->traverse(it);
      if (body)
         body->traverse(it);
      if (expr)
         expr->traverse(it);
      --it->depth;
   }

   if (visit && it->postVisit && it->visitLoop)
      it->visitLoop(false, this, it);
}

//
// Traverse a branch node.  Same comments in binary node apply here.
//
void TIntermBranch::traverse(TIntermTraverser* it)
{
   bool visit = true;

   if (it->preVisit && it->visitBranch)
      visit = it->visitBranch(true, this, it);

   if (visit && expression)
   {
      ++it->depth;
      expression->traverse(it);
      --it->depth;
   }

   if (visit && it->postVisit && it->visitBranch)
      it->visitBranch(false, this, it);
}


}
