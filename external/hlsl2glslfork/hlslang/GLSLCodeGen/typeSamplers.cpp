// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "typeSamplers.h"
#include "localintermediate.h"
#include "glslOutput.h"

namespace hlslang {


struct TSamplerTraverser : public TIntermTraverser 
{
	static void traverseSymbol(TIntermSymbol*, TIntermTraverser*);
	static void traverseParameterSymbol(TIntermSymbol *node, TIntermTraverser *it);
	static bool traverseBinary(bool preVisit, TIntermBinary*, TIntermTraverser*);
	static bool traverseUnary(bool preVisit, TIntermUnary*, TIntermTraverser*);
	static bool traverseSelection(bool preVisit, TIntermSelection*, TIntermTraverser*);
	static bool traverseAggregate(bool preVisit, TIntermAggregate*, TIntermTraverser*);
	static bool traverseLoop(bool preVisit, TIntermLoop*, TIntermTraverser*);
	static bool traverseBranch(bool preVisit, TIntermBranch*,  TIntermTraverser*);
	
	/// Set the type for the sampler
	void typeSampler( TIntermTyped *node, TBasicType samp);
	
	TInfoSink& infoSink;
	
	bool abort;
	
	// These are used to go into "typing mode"
	bool typing;
	int id;
	TBasicType sampType;
	
	std::map<std::string,TNodeArray* > functionMap;
	
	std::string currentFunction;
	
	TSamplerTraverser(TInfoSink &is) : infoSink(is), abort(false), typing(false), id(0), sampType(EbtSamplerGeneric) 
	{
		visitSymbol = traverseSymbol;
		//visitConstant = traverseConstant;
		visitBinary = traverseBinary;
		visitUnary = traverseUnary;
		visitSelection = traverseSelection;
		visitAggregate = traverseAggregate;
		visitLoop = traverseLoop;
		visitBranch = traverseBranch;
	}
};



void TSamplerTraverser::traverseSymbol( TIntermSymbol *node, TIntermTraverser *it )
{
   TSamplerTraverser* sit = static_cast<TSamplerTraverser*>(it);

   if (sit->abort)
      return;

   if (sit->typing && sit->id == node->getId())
   {
      TType* type = node->getTypePointer();
      // Technically most of these should never happen
	  type->setBasicType (sit->sampType);
   }
}


bool TSamplerTraverser::traverseBinary( bool preVisit, TIntermBinary *node, TIntermTraverser *it )
{
   TSamplerTraverser* sit = static_cast<TSamplerTraverser*>(it);

   if (sit->abort)
      return false;

   switch (node->getOp())
   {
   case EOpAssign:
      //believed to be disallowed on samplers...
      break;

   case EOpIndexDirect:
   case EOpIndexIndirect:
      //not planning to support arrays of samplers with different types 
      break;

   case EOpIndexDirectStruct:
      //Structs in samplers not supported
      break;

   default:
      break;
   }

   return !(sit->abort);
}


bool TSamplerTraverser::traverseUnary( bool preVisit, TIntermUnary *node, TIntermTraverser *it)
{
   TSamplerTraverser* sit = static_cast<TSamplerTraverser*>(it);

   return !(sit->abort);
}


bool TSamplerTraverser::traverseSelection( bool preVisit, TIntermSelection *node, TIntermTraverser *it)
{
   //TODO: might need to run down this rat hole for ?: operator
   TSamplerTraverser* sit = static_cast<TSamplerTraverser*>(it);

   return !(sit->abort);
}


bool TSamplerTraverser::traverseAggregate( bool preVisit, TIntermAggregate *node, TIntermTraverser *it)
{
   TSamplerTraverser* sit = static_cast<TSamplerTraverser*>(it);
   TInfoSink &infoSink = sit->infoSink;

   if (sit->abort)
      return false;

   if (! (sit->typing) )
   {
      switch (node->getOp())
      {
      
      case EOpFunction:
         // Store the current function name to use to setup the parameters
         sit->currentFunction = node->getName().c_str(); 
         break;

      case EOpParameters:
         // Store the parameters to the function in the map
         sit->functionMap[sit->currentFunction.c_str()] = &(node->getNodes());
         break;

      case EOpFunctionCall:
         {
            // This is a bit tricky.  Find the function in the map.  Loop over the parameters
            // and see if the parameters have been marked as a typed sampler.  If so, propagate
            // the sampler type to the caller
            if ( sit->functionMap.find ( node->getName().c_str() ) != sit->functionMap.end() )
            {
               // Get the sequence of function parameters
               TNodeArray *funcSequence = sit->functionMap[node->getName().c_str()];
               
               // Get the sequence of parameters being passed to function
               TNodeArray& nodes = node->getNodes();

               // Grab iterators to both sequences
               TNodeArray::iterator symit = nodes.begin();
               TNodeArray::iterator funcIt = funcSequence->begin();

               assert (nodes.size() == funcSequence->size());
               if (nodes.size() == funcSequence->size())
               {
                  while (symit != nodes.end())
                  {
                     TIntermSymbol *sym = (*symit)->getAsSymbolNode();
                     TIntermSymbol *funcSym = (*funcIt)->getAsSymbolNode();
                     
                     if ( sym != NULL && funcSym != NULL)
                     {
                        // If the parameter is generic, and the sampler to which
                        // it is being passed has been marked, propogate its sampler
                        // type to the caller.
                        if ( sym->getBasicType() == EbtSamplerGeneric &&
                             funcSym->getBasicType() != EbtSamplerGeneric )
                        {
                           sit->typeSampler ( sym, funcSym->getBasicType() );
                        }
                     }
                     symit++;
                     funcIt++;
                  }
               }
            }
         }
         break;

         //HLSL texture functions
      case EOpTex1D:
      case EOpTex1DProj:
      case EOpTex1DLod:
      case EOpTex1DBias:
      case EOpTex1DGrad:
         {
            TNodeArray& nodes = node->getNodes();
            assert(nodes.size());
            TIntermTyped *sampArg = nodes[0]->getAsTyped();
            if ( sampArg)
            {
               if (sampArg->getBasicType() == EbtSamplerGeneric)
               {
                  //type the sampler
                  sit->typeSampler( sampArg, EbtSampler1D);
               }
               else if (sampArg->getBasicType() != EbtSampler1D)
               {
                  //We have a sampler mismatch error
                  infoSink.info << "Error: " << node->getLine() << ": Sampler type mismatch, likely using a generic sampler as two types\n";
               }
            }
            else
            {
               assert(0);
            }

         }
         // We need to continue the traverse here, because the calls could be nested 
         break;


      case EOpTex2D:
      case EOpTex2DProj:
      case EOpTex2DLod:
      case EOpTex2DBias:
      case EOpTex2DGrad:
         {
            TNodeArray& nodes = node->getNodes();
            assert(nodes.size());
            TIntermTyped *sampArg = nodes[0]->getAsTyped();
            if ( sampArg)
            {
               if (sampArg->getBasicType() == EbtSamplerGeneric)
               {
                  //type the sampler
                  sit->typeSampler( sampArg, EbtSampler2D);
               }
               else if (sampArg->getBasicType() != EbtSampler2D)
               {
                  //We have a sampler mismatch error
                  infoSink.info << "Error: " << node->getLine() << ": Sampler type mismatch, likely using a generic sampler as two types\n";
               }
            }
            else
            {
               assert(0);
            }

         }
         // We need to continue the traverse here, because the calls could be nested 
         break;
			  
		case EOpShadow2D:
		case EOpShadow2DProj:
		{
			TNodeArray& nodes = node->getNodes();
			assert(nodes.size());
			TIntermTyped *sampArg = nodes[0]->getAsTyped();
			if (sampArg)
			{
				if (sampArg->getBasicType() == EbtSamplerGeneric)
					sit->typeSampler(sampArg, EbtSampler2DShadow);
				else if (sampArg->getBasicType() != EbtSampler2DShadow)
					infoSink.info << "Error: " << node->getLine() << ": Sampler type mismatch, likely using a generic sampler as two types\n";
			}
			else
			{
				assert(0);
			}
		}
		// We need to continue the traverse here, because the calls could be nested
		break;

		case EOpTex2DArray:
		case EOpTex2DArrayLod:
		case EOpTex2DArrayBias:
		{
			TNodeArray& nodes = node->getNodes();
			assert(nodes.size());
			TIntermTyped *sampArg = nodes[0]->getAsTyped();
			if (sampArg)
			{
				if (sampArg->getBasicType() == EbtSamplerGeneric)
					sit->typeSampler(sampArg, EbtSampler2DArray);
				else if (sampArg->getBasicType() != EbtSampler2DArray)
					infoSink.info << "Error: " << node->getLine() << ": Sampler type mismatch, likely using a generic sampler as two types\n";
			}
			else
			{
				assert(0);
			}
		  }
		
		// We need to continue the traverse here, because the calls could be nested 
		break;
			  
	  case EOpTexRect:
	  case EOpTexRectProj:
		  {
			  TNodeArray& nodes = node->getNodes();
			  assert(nodes.size());
			  TIntermTyped *sampArg = nodes[0]->getAsTyped();
			  if ( sampArg)
			  {
				  if (sampArg->getBasicType() == EbtSamplerGeneric)
				  {
					  //type the sampler
					  sit->typeSampler( sampArg, EbtSamplerRect);
				  }
				  else if (sampArg->getBasicType() != EbtSamplerRect)
				  {
					  //We have a sampler mismatch error
					  infoSink.info << "Error: " << node->getLine() << ": Sampler type mismatch, likely using a generic sampler as two types\n";
				  }
			  }
			  else
			  {
				  assert(0);
			  }
			  
		  }
		  // We need to continue the traverse here, because the calls could be nested 
		  break;
			  
			  
      case EOpTex3D:
      case EOpTex3DProj:
      case EOpTex3DLod:
      case EOpTex3DBias:
      case EOpTex3DGrad:
         {
            TNodeArray& nodes = node->getNodes();
            assert(nodes.size());
            TIntermTyped *sampArg = nodes[0]->getAsTyped();
            if ( sampArg)
            {
               if (sampArg->getBasicType() == EbtSamplerGeneric)
               {
                  //type the sampler
                  sit->typeSampler( sampArg, EbtSampler3D);
               }
               else if (sampArg->getBasicType() != EbtSampler3D)
               {
                  //We have a sampler mismatch error
                  infoSink.info << "Error: " << node->getLine() << ": Sampler type mismatch, likely using a generic sampler as two types\n";
               }
            }
            else
            {
               assert(0);
            }

         }
         // We need to continue the traverse here, because the calls could be nested 
         break;

      case EOpTexCube:
      case EOpTexCubeProj:
      case EOpTexCubeLod:
      case EOpTexCubeBias:
      case EOpTexCubeGrad:
         {
            TNodeArray& nodes = node->getNodes();
            assert(nodes.size());
            TIntermTyped *sampArg = nodes[0]->getAsTyped();
            if ( sampArg)
            {
               if (sampArg->getBasicType() == EbtSamplerGeneric)
               {
                  //type the sampler
                  sit->typeSampler( sampArg, EbtSamplerCube);
               }
               else if (sampArg->getBasicType() != EbtSamplerCube)
               {
                  //We have a sampler mismatch error
                  infoSink.info << "Error: " << node->getLine() << ": Sampler type mismatch, likely using a generic sampler as two types\n";
               }
            }
            else
            {
               assert(0);
            }

         }
         // We need to continue the traverse here, because the calls could be nested 
         break;

      default: 
         break;
      }
   }


   return !(sit->abort);
}


bool TSamplerTraverser::traverseLoop( bool preVisit, TIntermLoop *node, TIntermTraverser *it)
{
   TSamplerTraverser* sit = static_cast<TSamplerTraverser*>(it);

   return !(sit->abort);
}


bool TSamplerTraverser::traverseBranch( bool preVisit, TIntermBranch *node,  TIntermTraverser *it)
{
   TSamplerTraverser* sit = static_cast<TSamplerTraverser*>(it);

   return !(sit->abort);
}


void TSamplerTraverser::typeSampler( TIntermTyped *node, TBasicType samp )
{
   TIntermSymbol *symNode = node->getAsSymbolNode();

   if ( !symNode)
   {
      //TODO: add logic to handle sampler arrays and samplers as struct members

      //Don't try typing this one, it is a complex expression
      TIntermBinary *biNode = node->getAsBinaryNode();

      if ( biNode )
      {
         switch (biNode->getOp())
         {
         case EOpIndexDirect:
         case EOpIndexIndirect:
            infoSink.info << "Warning: " << node->getLine() <<  ": typing of sampler arrays presently unsupported\n";
            break;

         case EOpIndexDirectStruct:
            infoSink.info << "Warning: " << node->getLine() <<  ": typing of samplers as struct members presently unsupported\n";
            break;
         default:
            break;
         }
      }
      else
      {
         infoSink.info << "Warning: " << node->getLine() <<  ": unexpected expression type for sampler, cannot type\n";
      }
      abort = false;
   }
   else
   {
      // We really have something to type, abort this traverse and activate typing
      abort = true;
      id = symNode->getId();
      sampType = samp;
   }
}


void PropagateSamplerTypes (TIntermNode* root, TInfoSink &info)
{
   TSamplerTraverser st(info);

   do
   {
      st.abort = false;
      root->traverse( &st);

      // If we aborted, try to type the node we aborted for
      if (st.abort)
      {
         st.typing = true;
         st.abort = false;
         root->traverse( &st);
         st.typing = false;
         st.abort = true;
      }
   } while (st.abort);
}

}
