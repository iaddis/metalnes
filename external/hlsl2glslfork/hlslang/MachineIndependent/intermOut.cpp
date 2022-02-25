// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "localintermediate.h"

namespace hlslang {

//
// Two purposes:
// 1.  Show an example of how to iterate tree.  Functions can
//     also directly call Traverse() on children themselves to
//     have finer grained control over the process than shown here.
//     See the last function for how to get started.
// 2.  Print out a text based description of the tree.
//

//
// Use this class to carry along data from node to node in 
// the traversal
//
class TOutputTraverser : public TIntermTraverser
{
public:
   TOutputTraverser(TInfoSink& i) : infoSink(i)
   {
   }
   TInfoSink& infoSink;
};

TString TType::getCompleteString() const
{
   char buf[100];
   char *p = &buf[0];

   if (qualifier != EvqTemporary && qualifier != EvqGlobal)
      p += sprintf(p, "%s ", getQualifierString());

   sprintf(p, "%s", getBasicString());
   if (array)
      p += sprintf(p, " array");
   if (matrix)
      p += sprintf(p, "matrix%dX%d", matcols, matrows);
   else if (matrows > 1)
      p += sprintf(p, "vec%d", matrows);

   return TString(buf);
}   

//
// Helper functions for printing, not part of traversing.
//

void OutputTreeText(TInfoSink& infoSink, TIntermNode* node, const int depth)
{
   int i;

   infoSink.debug << node->getLine();

   for (i = 0; i < depth; ++i)
      infoSink.debug << "  ";
}

//
// The rest of the file are the traversal functions.  The last one
// is the one that starts the traversal.
//
// Return true from interior nodes to have the external traversal
// continue on to children.  If you process children yourself,
// return false.
//

void OutputSymbol(TIntermSymbol* node, TIntermTraverser* it)
{
   TOutputTraverser* oit = static_cast<TOutputTraverser*>(it);

   OutputTreeText(oit->infoSink, node, oit->depth);

   char buf[100];
   sprintf(buf, "'%s' (%s)\n",
           node->getSymbol().c_str(),
           node->getCompleteString().c_str());

   oit->infoSink.debug << buf;
}

bool OutputBinary(bool, /* preVisit */ TIntermBinary* node, TIntermTraverser* it)
{
   TOutputTraverser* oit = static_cast<TOutputTraverser*>(it);
   TInfoSink& out = oit->infoSink;

   OutputTreeText(out, node, oit->depth);

   switch (node->getOp())
   {
   case EOpAssign:                   out.debug << "=";      break;
   case EOpAddAssign:                out.debug << "+=";     break;
   case EOpSubAssign:                out.debug << "-=";     break;
   case EOpMulAssign:                out.debug << "*=";     break;
   case EOpVectorTimesMatrixAssign:  out.debug << "vec *= matrix";  break;
   case EOpVectorTimesScalarAssign:  out.debug << "vec *= scalar"; break;
   case EOpMatrixTimesScalarAssign:  out.debug << "matrix *= scalar"; break;
   case EOpMatrixTimesMatrixAssign:  out.debug << "matrix *= matrix"; break;
   case EOpDivAssign:                out.debug << "/=";  break;
   case EOpModAssign:                out.debug << "%=";  break;
   case EOpAndAssign:                out.debug << "&=";  break;
   case EOpInclusiveOrAssign:        out.debug << "|=";  break;
   case EOpExclusiveOrAssign:        out.debug << "^=";  break;
   case EOpLeftShiftAssign:          out.debug << "<<="; break;
   case EOpRightShiftAssign:         out.debug << ">>="; break;

   case EOpIndexDirect:   out.debug << "index";   break;
   case EOpIndexIndirect: out.debug << "indirect index"; break;
   case EOpIndexDirectStruct:   out.debug << "struct index";   break;
   case EOpVectorSwizzle: out.debug << "swizzle"; break;

   case EOpAdd:    out.debug << "+"; break;
   case EOpSub:    out.debug << "-"; break;
   case EOpMul:    out.debug << "*"; break;
   case EOpDiv:    out.debug << "/"; break;
   case EOpMod:    out.debug << "%"; break;
   case EOpRightShift:  out.debug << ">>";  break;
   case EOpLeftShift:   out.debug << "<<";  break;
   case EOpAnd:         out.debug << "&"; break;
   case EOpInclusiveOr: out.debug << "|"; break;
   case EOpExclusiveOr: out.debug << "^"; break;
   case EOpEqual:            out.debug << "=="; break;
   case EOpNotEqual:         out.debug << "!="; break;
   case EOpLessThan:         out.debug << "<";  break;
   case EOpGreaterThan:      out.debug << ">";  break;
   case EOpLessThanEqual:    out.debug << "<="; break;
   case EOpGreaterThanEqual: out.debug << ">="; break;

   case EOpVectorTimesScalar: out.debug << "vec*scalar";    break;
   case EOpVectorTimesMatrix: out.debug << "vec*matrix";    break;
   case EOpMatrixTimesVector: out.debug << "matrix*vec";    break;
   case EOpMatrixTimesScalar: out.debug << "matrix*scalar"; break;
   case EOpMatrixTimesMatrix: out.debug << "matrix*matrix"; break;

   case EOpLogicalOr:  out.debug << "||";   break;
   case EOpLogicalXor: out.debug << "^^"; break;
   case EOpLogicalAnd: out.debug << "&&"; break;
   default: out.debug << "<unknown op>";
   }

   out.debug << " (" << node->getCompleteString() << ")";

   out.debug << "\n";

   return true;
}

bool OutputUnary(bool, /* preVisit */ TIntermUnary* node, TIntermTraverser* it)
{
   TOutputTraverser* oit = static_cast<TOutputTraverser*>(it);
   TInfoSink& out = oit->infoSink;

   OutputTreeText(out, node, oit->depth);

   switch (node->getOp())
   {
   case EOpNegative:       out.debug << "Negate value";         break;
   case EOpVectorLogicalNot:
   case EOpLogicalNot:     out.debug << "Negate conditional";   break;
   case EOpBitwiseNot:     out.debug << "Bitwise not";          break;

   case EOpPostIncrement:  out.debug << "Post-Increment";       break;
   case EOpPostDecrement:  out.debug << "Post-Decrement";       break;
   case EOpPreIncrement:   out.debug << "Pre-Increment";        break;
   case EOpPreDecrement:   out.debug << "Pre-Decrement";        break;

   case EOpConvIntToBool:  out.debug << "Convert int to bool";  break;
   case EOpConvFloatToBool:out.debug << "Convert float to bool";break;
   case EOpConvBoolToFloat:out.debug << "Convert bool to float";break;
   case EOpConvIntToFloat: out.debug << "Convert int to float"; break;
   case EOpConvFloatToInt: out.debug << "Convert float to int"; break;
   case EOpConvBoolToInt:  out.debug << "Convert bool to int";  break;

   case EOpRadians:        out.debug << "radians";              break;
   case EOpDegrees:        out.debug << "degrees";              break;
   case EOpSin:            out.debug << "sine";                 break;
   case EOpCos:            out.debug << "cosine";               break;
   case EOpTan:            out.debug << "tangent";              break;
   case EOpAsin:           out.debug << "arc sine";             break;
   case EOpAcos:           out.debug << "arc cosine";           break;
   case EOpAtan:           out.debug << "arc tangent";          break;
   case EOpAtan2:          out.debug << "arc tangent 2";        break;

   case EOpExp:            out.debug << "exp";                  break;
   case EOpLog:            out.debug << "log";                  break;
   case EOpExp2:           out.debug << "exp2";                 break;
   case EOpLog2:           out.debug << "log2";                 break;
   case EOpLog10:          out.debug << "log10";                 break;
   case EOpSqrt:           out.debug << "sqrt";                 break;
   case EOpInverseSqrt:    out.debug << "inverse sqrt";         break;

   case EOpAbs:            out.debug << "Absolute value";       break;
   case EOpSign:           out.debug << "Sign";                 break;
   case EOpFloor:          out.debug << "Floor";                break;
   case EOpCeil:           out.debug << "Ceiling";              break;
   case EOpFract:          out.debug << "Fraction";             break;

   case EOpLength:         out.debug << "length";               break;
   case EOpNormalize:      out.debug << "normalize";            break;
   case EOpDPdx:           out.debug << "dPdx";                 break;               
   case EOpDPdy:           out.debug << "dPdy";                 break;   
   case EOpFwidth:         out.debug << "fwidth";               break;   
   case EOpFclip:           out.debug << "clip";               break; 

   case EOpAny:            out.debug << "any";                  break;
   case EOpAll:            out.debug << "all";                  break;

   case EOpD3DCOLORtoUBYTE4: out.debug << "D3DCOLORtoUBYTE4";   break;

   default: out.debug.message(EPrefixError, "Bad unary op");
   }

   out.debug << " (" << node->getCompleteString() << ")";

   out.debug << "\n";

   return true;
}

bool OutputAggregate(bool, /* preVisit */ TIntermAggregate* node, TIntermTraverser* it)
{
   TOutputTraverser* oit = static_cast<TOutputTraverser*>(it);
   TInfoSink& out = oit->infoSink;

   if (node->getOp() == EOpNull)
   {
      out.debug.message(EPrefixError, "node is still EOpNull!");
      return true;
   }

   OutputTreeText(out, node, oit->depth);

   switch (node->getOp())
   {
   case EOpSequence:      out.debug << "Sequence\n"; return true;
   case EOpComma:         out.debug << "Comma\n"; return true;
   case EOpFunction:      out.debug << "Func Def: " << node->getName(); break;
   case EOpFunctionCall:  out.debug << "Func Call: " << node->getName(); break;
   case EOpParameters:    out.debug << "Func Params: ";              break;

   case EOpConstructFloat: out.debug << "Construct float"; break;
   case EOpConstructVec2:  out.debug << "Construct vec2";  break;
   case EOpConstructVec3:  out.debug << "Construct vec3";  break;
   case EOpConstructVec4:  out.debug << "Construct vec4";  break;
   case EOpConstructBool:  out.debug << "Construct bool";  break;
   case EOpConstructBVec2: out.debug << "Construct bvec2"; break;
   case EOpConstructBVec3: out.debug << "Construct bvec3"; break;
   case EOpConstructBVec4: out.debug << "Construct bvec4"; break;
   case EOpConstructInt:   out.debug << "Construct int";   break;
   case EOpConstructIVec2: out.debug << "Construct ivec2"; break;
   case EOpConstructIVec3: out.debug << "Construct ivec3"; break;
   case EOpConstructIVec4: out.debug << "Construct ivec4"; break;

   case EOpConstructMat2x2:  out.debug << "Construct mat2x2";  break;
   case EOpConstructMat2x3:  out.debug << "Construct mat2x3";  break;
   case EOpConstructMat2x4:  out.debug << "Construct mat2x4";  break;
   case EOpConstructMat3x2:  out.debug << "Construct mat3x2";  break;
   case EOpConstructMat3x3:  out.debug << "Construct mat3x3";  break;
   case EOpConstructMat3x4:  out.debug << "Construct mat3x4";  break;
   case EOpConstructMat4x2:  out.debug << "Construct mat4x2";  break;
   case EOpConstructMat4x3:  out.debug << "Construct mat4x3";  break;
   case EOpConstructMat4x4:  out.debug << "Construct mat4x4";  break;
   case EOpConstructStruct:  out.debug << "Construct struc";  break;
   case EOpConstructMat2x2FromMat: out.debug << "Construct mat2 from mat"; break;
   case EOpConstructMat3x3FromMat: out.debug << "Construct mat3 from mat"; break;
   case EOpMatrixIndex: out.debug << "Matrix index"; break;
   case EOpMatrixIndexDynamic: out.debug << "Matrix index dynamic"; break;

   case EOpLessThan:         out.debug << "Compare Less Than";             break;
   case EOpGreaterThan:      out.debug << "Compare Greater Than";          break;
   case EOpLessThanEqual:    out.debug << "Compare Less Than or Equal";    break;
   case EOpGreaterThanEqual: out.debug << "Compare Greater Than or Equal"; break;
   case EOpVectorEqual:      out.debug << "Equal";                         break;
   case EOpVectorNotEqual:   out.debug << "NotEqual";                      break;

   case EOpMod:           out.debug << "mod";         break;
   case EOpPow:           out.debug << "pow";         break;

   case EOpAtan:          out.debug << "atan"; break;
   case EOpAtan2:         out.debug << "atan2"; break;

   case EOpSinCos:        out.debug << "sincos";      break;

   case EOpMin:           out.debug << "min";         break;
   case EOpMax:           out.debug << "max";         break;
   case EOpClamp:         out.debug << "clamp";       break;
   case EOpMix:           out.debug << "mix";         break;
   case EOpStep:          out.debug << "step";        break;
   case EOpSmoothStep:    out.debug << "smoothstep";  break;
   case EOpLit:           out.debug << "lit";  break;

   case EOpDistance:      out.debug << "distance";                break;
   case EOpDot:           out.debug << "dot";             break;
   case EOpCross:         out.debug << "cross";           break;
   case EOpFaceForward:   out.debug << "faceforward";            break;
   case EOpReflect:       out.debug << "reflect";                 break;
   case EOpRefract:       out.debug << "refract";                 break;
   case EOpMul:           out.debug << "mul";                     break;

   case EOpTex1D:		out.debug << "tex1D"; break;
   case EOpTex1DProj:	out.debug << "tex1Dproj"; break;
   case EOpTex1DLod:	out.debug << "tex1Dlod"; break;
   case EOpTex1DBias:	out.debug << "tex1Dbias"; break;
   case EOpTex1DGrad:	out.debug << "tex1Dgrad"; break;
   case EOpTex2D:		out.debug << "tex2D"; break;
   case EOpTex2DProj:	out.debug << "tex2Dproj"; break;
   case EOpTex2DLod:	out.debug << "tex2Dlod"; break;
   case EOpTex2DBias:	out.debug << "tex2Dbias"; break;
   case EOpTex2DGrad:	out.debug << "tex2Dgrad"; break;
   case EOpTex3D:		out.debug << "tex3D"; break;
   case EOpTex3DProj:	out.debug << "tex3Dproj"; break;
   case EOpTex3DLod:	out.debug << "tex3Dlod"; break;
   case EOpTex3DBias:	out.debug << "tex3Dbias"; break;
   case EOpTex3DGrad:	out.debug << "tex3Dgrad"; break;
   case EOpTexCube:		out.debug << "texCUBE"; break;
   case EOpTexCubeProj:	out.debug << "texCUBEproj"; break;
   case EOpTexCubeLod:	out.debug << "texCUBElod"; break;
   case EOpTexCubeBias:	out.debug << "texCUBEbias"; break;
   case EOpTexCubeGrad:	out.debug << "texCUBEgrad"; break;
   case EOpTexRect:		out.debug << "texRECT"; break;
   case EOpTexRectProj:	out.debug << "texRECTproj"; break;
   case EOpShadow2D:	out.debug << "shadow2D"; break;
   case EOpShadow2DProj:out.debug << "shadow2Dproj"; break;
   case EOpTex2DArray:		out.debug << "tex2DArray"; break;
   case EOpTex2DArrayLod:	out.debug << "tex2DArrayLod"; break;
   case EOpTex2DArrayBias:	out.debug << "tex2DArrayBias"; break;
 
   default: out.debug.message(EPrefixError, "Bad aggregation op");
   }

   if (node->getOp() != EOpSequence && node->getOp() != EOpParameters)
      out.debug << " (" << node->getCompleteString() << ")";

   out.debug << "\n";

   return true;
}

bool OutputSelection(bool, /* preVisit */ TIntermSelection* node, TIntermTraverser* it)
{
   TOutputTraverser* oit = static_cast<TOutputTraverser*>(it);
   TInfoSink& out = oit->infoSink;

   OutputTreeText(out, node, oit->depth);

   out.debug << "ternary ?:";
   out.debug << " (" << node->getCompleteString() << ")\n";

   ++oit->depth;

   OutputTreeText(oit->infoSink, node, oit->depth);
   out.debug << "Condition\n";
   node->getCondition()->traverse(it);

   OutputTreeText(oit->infoSink, node, oit->depth);
   if (node->getTrueBlock())
   {
      out.debug << "true case\n";
      node->getTrueBlock()->traverse(it);
   }
   else
      out.debug << "true case is null\n";

   if (node->getFalseBlock())
   {
      OutputTreeText(oit->infoSink, node, oit->depth);
      out.debug << "false case\n";
      node->getFalseBlock()->traverse(it);
   }

   --oit->depth;

   return false;
}

void OutputConstant(TIntermConstant* node, TIntermTraverser* it)
{
   TOutputTraverser* oit = static_cast<TOutputTraverser*>(it);
   TInfoSink& out = oit->infoSink;

   int size = node->getCount();

   for (int i = 0; i < size; i++)
   {
      OutputTreeText(out, node, oit->depth);
      switch (node->getValue(i).type)
      {
      case EbtBool:
         if (node->toBool(i))
            out.debug << "true";
         else
            out.debug << "false";

         out.debug << " (" << "const bool" << ")";

         out.debug << "\n";
         break;
      case EbtFloat:
         {
            char buf[300];
            sprintf(buf, "%f (%s)", node->toFloat(i), "const float");

            out.debug << buf << "\n";
         }
         break;
      case EbtInt:
         {
            char buf[300];
            sprintf(buf, "%d (%s)", node->toInt(i), "const int");

            out.debug << buf << "\n";
            break;
         }
      default: 
         out.info.message(EPrefixInternalError, "Unknown constant", node->getLine());
         break;
      }
   }
}

bool OutputLoop(bool, /* preVisit */ TIntermLoop* node, TIntermTraverser* it)
{
   TOutputTraverser* oit = static_cast<TOutputTraverser*>(it);
   TInfoSink& out = oit->infoSink;

   OutputTreeText(out, node, oit->depth);

   out.debug << "Loop with condition ";
   if (node->getType() == ELoopDoWhile)
      out.debug << "not ";
   out.debug << "tested first\n";

   ++oit->depth;

   OutputTreeText(oit->infoSink, node, oit->depth);
   if (node->getCondition())
   {
      out.debug << "Loop Condition\n";
      node->getCondition()->traverse(it);
   }
   else
      out.debug << "No loop condition\n";

   OutputTreeText(oit->infoSink, node, oit->depth);
   if (node->getBody())
   {
      out.debug << "Loop Body\n";
      node->getBody()->traverse(it);
   }
   else
      out.debug << "No loop body\n";

   if (node->getExpression())
   {
      OutputTreeText(oit->infoSink, node, oit->depth);
      out.debug << "Loop Terminal Expression\n";
      node->getExpression()->traverse(it);
   }

   --oit->depth;

   return false;
}

bool OutputBranch(bool, /* previsit*/ TIntermBranch* node, TIntermTraverser* it)
{
   TOutputTraverser* oit = static_cast<TOutputTraverser*>(it);
   TInfoSink& out = oit->infoSink;

   OutputTreeText(out, node, oit->depth);

   switch (node->getFlowOp())
   {
   case EOpKill:      out.debug << "Branch: Kill";           break;
   case EOpBreak:     out.debug << "Branch: Break";          break;
   case EOpContinue:  out.debug << "Branch: Continue";       break;
   case EOpReturn:    out.debug << "Branch: Return";         break;
   default:               out.debug << "Branch: Unknown Branch"; break;
   }

   if (node->getExpression())
   {
      out.debug << " with expression\n";
      ++oit->depth;
      node->getExpression()->traverse(it);
      --oit->depth;
   }
   else
      out.debug << "\n";

   return false;
}


void ir_output_tree(TIntermNode* root, TInfoSink& infoSink)
{
   if (root == 0)
      return;

   TOutputTraverser it(infoSink);

   it.visitAggregate = OutputAggregate;
   it.visitBinary = OutputBinary;
   it.visitConstant = OutputConstant;
   it.visitSelection = OutputSelection;
   it.visitSymbol = OutputSymbol;
   it.visitUnary = OutputUnary;
   it.visitLoop = OutputLoop;
   it.visitBranch = OutputBranch;

   root->traverse(&it);
}
}

