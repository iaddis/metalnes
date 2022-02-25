// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.

#include "propagateMutable.h"
#include <set>
#include "localintermediate.h"

namespace hlslang {


struct TPropagateMutable : public TIntermTraverser 
{
	static void traverseSymbol(TIntermSymbol*, TIntermTraverser*);
	
	TInfoSink& infoSink;
	
	bool abort;
	
	// These are used to go into "propagating mode"
	bool propagating;
	int id;
	
	std::set<int> fixedIds; // to prevent infinite loops
	
	
	TPropagateMutable(TInfoSink &is) : infoSink(is), abort(false), propagating(false), id(0)
	{
		visitSymbol = traverseSymbol;
	}
};



void TPropagateMutable::traverseSymbol( TIntermSymbol *node, TIntermTraverser *it )
{
	TPropagateMutable* sit = static_cast<TPropagateMutable*>(it);

	if (sit->abort)
		return;

	if (sit->propagating && sit->id == node->getId())
	{
		node->getTypePointer()->changeQualifier( EvqMutableUniform );
	}
	else if (!sit->propagating && sit->fixedIds.find(node->getId()) == sit->fixedIds.end())
	{
		if (node->getQualifier() == EvqMutableUniform)
		{
			sit->abort = true;
			sit->id = node->getId();
			sit->fixedIds.insert(sit->id);
		}
	}
}

void PropagateMutableUniforms (TIntermNode* root, TInfoSink &info)
{
	TPropagateMutable st(info);

	do
	{
		st.abort = false;
		root->traverse(&st);

		// If we aborted, try to type the node we aborted for
		if (st.abort)
		{
			st.propagating = true;
			st.abort = false;
			root->traverse(&st);
			st.propagating = false;
			st.abort = true;
		}
	} while (st.abort);
}

}
