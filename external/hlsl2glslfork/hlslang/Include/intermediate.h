// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


// Definition of the in-memory high-level intermediate representation
// of shaders.  This is a tree that parser creates.
//
// Nodes in the tree are defined as a hierarchy of classes derived from 
// TIntermNode. Each is a node in a tree.  There is no preset branching factor;
// each node can have it's own type of list of children.

#ifndef __INTERMEDIATE_H
#define __INTERMEDIATE_H

#include "../Include/Common.h"
#include "../Include/Types.h"
#include "../../include/hlsl2glsl.h"

namespace hlslang {


struct TParseContext;

//
// Operators used by the high-level (parse tree) representation.
//
enum TOperator
{
	EOpNull,            // if in a node, should only mean a node is still being built
	EOpSequence,        // denotes a list of statements, or parameters, etc.
	EOpFunctionCall,    
	EOpFunction,        // For function definition
	EOpParameters,      // an aggregate listing the parameters to a function

	//
	// Unary operators
	//

	EOpNegative,
	EOpLogicalNot,
	EOpVectorLogicalNot,
	EOpBitwiseNot,

	EOpPostIncrement,
	EOpPostDecrement,
	EOpPreIncrement,
	EOpPreDecrement,

	EOpConvIntToBool,
	EOpConvFloatToBool,
	EOpConvBoolToFloat,
	EOpConvIntToFloat,
	EOpConvFloatToInt,
	EOpConvBoolToInt,

	//
	// binary operations
	//

	EOpAdd,
	EOpSub,
	EOpMul,
	EOpDiv,
	EOpMod,
	EOpRightShift,
	EOpLeftShift,
	EOpAnd,
	EOpInclusiveOr,
	EOpExclusiveOr,
	EOpEqual,
	EOpNotEqual,
	EOpVectorEqual,
	EOpVectorNotEqual,
	EOpLessThan,
	EOpGreaterThan,
	EOpLessThanEqual,
	EOpGreaterThanEqual,
	EOpComma,

	EOpVectorTimesScalar,
	EOpVectorTimesMatrix,
	EOpMatrixTimesVector,
	EOpMatrixTimesScalar,

	EOpLogicalOr,
	EOpLogicalXor,
	EOpLogicalAnd,

	EOpIndexDirect,
	EOpIndexIndirect,
	EOpIndexDirectStruct,

	EOpVectorSwizzle,
	EOpMatrixSwizzle,

	//
	// Built-in functions potentially mapped to operators
	//

	EOpRadians,
	EOpDegrees,
	EOpSin,
	EOpCos,
	EOpTan,
	EOpAsin,
	EOpAcos,
	EOpAtan,
	EOpAtan2,
	EOpSinCos,

	EOpPow,
	EOpExp,
	EOpLog,
	EOpExp2,
	EOpLog2,
	EOpLog10,
	EOpSqrt,
	EOpInverseSqrt,

	EOpAbs,
	EOpSign,
	EOpFloor,
	EOpCeil,
	EOpFract,
	EOpMin,
	EOpMax,
	EOpClamp,
	EOpMix,
	EOpStep,
	EOpSmoothStep,

	EOpLength,
	EOpDistance,
	EOpDot,
	EOpCross,
	EOpNormalize,
	EOpFaceForward,
	EOpReflect,
	EOpRefract,

	EOpLit,

	EOpDPdx,
	EOpDPdy,
	EOpFwidth,
	EOpFclip,

	EOpTex1D,
	EOpTex1DProj,
	EOpTex1DLod,
	EOpTex1DBias,
	EOpTex1DGrad,
	EOpTex2D,
	EOpTex2DProj,
	EOpTex2DLod,
	EOpTex2DBias,
	EOpTex2DGrad,
	EOpTex3D,
	EOpTex3DProj,
	EOpTex3DLod,
	EOpTex3DBias,
	EOpTex3DGrad,
	EOpTexCube,
	EOpTexCubeProj,
	EOpTexCubeLod,
	EOpTexCubeBias,
	EOpTexCubeGrad,
	EOpTexRect,
	EOpTexRectProj,
	EOpShadow2D,
	EOpShadow2DProj,
	EOpTex2DArray,
	EOpTex2DArrayLod,
	EOpTex2DArrayBias,

	EOpTranspose,
	EOpDeterminant,
	EOpSaturate,
	EOpModf,
	EOpLdexp,
	EOpRound,
	EOpTrunc,

	EOpMatrixTimesMatrix,

	EOpAny,
	EOpAll,

	// Branches
	EOpKill,
	EOpReturn,
	EOpBreak,
	EOpContinue,

	// Constructors
	EOpConstructInt,
	EOpConstructBool,
	EOpConstructFloat,
	EOpConstructVec2,
	EOpConstructVec3,
	EOpConstructVec4,
	EOpConstructBVec2,
	EOpConstructBVec3,
	EOpConstructBVec4,
	EOpConstructIVec2,
	EOpConstructIVec3,
	EOpConstructIVec4,
	EOpConstructMat2x2,
	EOpConstructMat2x3,
	EOpConstructMat2x4,
	EOpConstructMat3x2,
	EOpConstructMat3x3,
	EOpConstructMat3x4,
	EOpConstructMat4x2,
	EOpConstructMat4x3,
	EOpConstructMat4x4,
	EOpConstructStruct,
	EOpConstructArray,

	// pre-GLSL1.20 matrix downcasts
	EOpConstructMat2x2FromMat,
	EOpConstructMat3x3FromMat,

	EOpMatrixIndex,
	EOpMatrixIndexDynamic,

	// Assignments
	EOpAssign,
	EOpAddAssign,
	EOpSubAssign,
	EOpMulAssign,
	EOpVectorTimesMatrixAssign,
	EOpVectorTimesScalarAssign,
	EOpMatrixTimesScalarAssign,
	EOpMatrixTimesMatrixAssign,
	EOpDivAssign,
	EOpModAssign,
	EOpAndAssign,
	EOpInclusiveOrAssign,
	EOpExclusiveOrAssign,
	EOpLeftShiftAssign,
	EOpRightShiftAssign,

	// Array operators
	EOpArrayLength,

	// Special HLSL functions
	EOpD3DCOLORtoUBYTE4,

	// Ternary selection on vector
	EOpVecTernarySel,
};

class TIntermTraverser;
class TIntermAggregate;
class TIntermBinary;
class TIntermConstant;
class TIntermSelection;
class TIntermOperator;
class TIntermTyped;
class TIntermSymbol;
class TInfoSink;
class TIntermDeclaration;

//
// Base class for the tree nodes
//
class TIntermNode
{
public:
	POOL_ALLOCATOR_NEW_DELETE(GlobalPoolAllocator)

	TIntermNode() : line(gNullSourceLoc)
	{
	}

	const TSourceLoc& getLine() const { return line; }
	void setLine(const TSourceLoc& l) { line = l; }

	virtual void traverse(TIntermTraverser*) = 0;

	virtual TIntermTyped*     getAsTyped() { return 0; }
	virtual TIntermOperator*  getAsOperatorNode() { return 0; }
	virtual TIntermConstant*     getAsConstant() { return 0; }
	virtual TIntermAggregate* getAsAggregate() { return 0; }
	virtual TIntermBinary*    getAsBinaryNode() { return 0; }
	virtual TIntermSelection* getAsSelectionNode() { return 0; }
	virtual TIntermSymbol*    getAsSymbolNode() { return 0; }
	virtual TIntermDeclaration* getAsDeclaration() { return 0; }
	virtual ~TIntermNode() { }

protected:
	TSourceLoc line;
};

// This is just to help yacc.
struct TIntermNodePair
{
	TIntermNode* node1;
	TIntermNode* node2;
};

class TIntermSymbol;
class TIntermBinary;

//
// Intermediate class for nodes that have a type.
//
class TIntermTyped : public TIntermNode
{
public:
	TIntermTyped(const TType& t) : type(t)
	{
	}

	virtual TIntermTyped* getAsTyped() { return this; }

	void setType(const TType& t) { type = t; }
	TType getType() const { return type; }
	TType* getTypePointer() { return &type; }

	TBasicType getBasicType() const { return type.getBasicType(); }
	TQualifier getQualifier() const { return type.getQualifier(); }
	TPrecision getPrecision() const { return type.getPrecision(); }
	int getColsCount() const { return type.getColsCount(); }
	int getRowsCount() const { return type.getRowsCount(); }
	int getSize() const { return type.getInstanceSize(); }
	bool isMatrix() const { return type.isMatrix(); }
	bool isArray()  const { return type.isArray(); }
	bool isVector() const { return type.isVector(); }
	bool isScalar() const { return type.isScalar(); }
	const char* getBasicString() const { return type.getBasicString(); }
	const char* getQualifierString() const { return type.getQualifierString(); }
	TString getCompleteString() const { return type.getCompleteString(); }

protected:
	TType type;
};


enum TLoopType
{
	ELoopFor,
	ELoopWhile,
	ELoopDoWhile,
};

// Handle for, do-while, and while loops.
class TIntermLoop : public TIntermNode
{
public:
	TIntermLoop(TLoopType aType, TIntermTyped* aCond, TIntermTyped* aExpr, TIntermNode* aBody) : 
	type(aType),
	cond(aCond),
	expr(aExpr),
	body(aBody)
	{
	}
	virtual void traverse(TIntermTraverser*);

	TLoopType getType() const { return type; }
	TIntermTyped* getCondition() { return cond; }
	TIntermTyped* getExpression() { return expr; }
	TIntermNode*  getBody() { return body; }
	
protected:
	TLoopType	type;
	TIntermTyped* cond;  // loop exit condition, could be 0 for for-loops
	TIntermTyped* expr;  // for-loop expression
	TIntermNode* body;   // loop body
};

//
// Handle break, continue, return, and kill.
//
class TIntermBranch : public TIntermNode
{
public:
	TIntermBranch(TOperator op, TIntermTyped* e) :
	flowOp(op),
	expression(e)
	{
	}
	virtual void traverse(TIntermTraverser*);

	TOperator getFlowOp() { return flowOp; }
	TIntermTyped* getExpression() { return expression; }
protected:
	TOperator flowOp;
	TIntermTyped* expression;  // non-zero except for "return exp;" statements
};

//
// Nodes that correspond to symbols or constants in the source code.
//
class TIntermSymbol : public TIntermTyped
{
public:
	// if symbol is initialized as symbol(sym), the memory comes from the poolallocator of sym. If sym comes from
	// per process globalpoolallocator, then it causes increased memory usage per compile
	// it is essential to use "symbol = sym" to assign to symbol
	TIntermSymbol(int i, const TString& sym, const TType& t) : 
		TIntermTyped(t), id(i), info(0), global(false)
	{
		symbol = sym;
	} 
	TIntermSymbol(int i, const TString& sym, const TTypeInfo *inf, const TType& t) : 
		TIntermTyped(t), id(i), info(inf), global(false)
	{
		symbol = sym;
	} 

	int getId() const { return id; }
	const TString& getSymbol() const { return symbol; }
	bool isGlobal() const { return global; }
	void setGlobal(bool g) { global = g; }

	virtual const TTypeInfo* getInfo() const
	{
		return info;
	}
	virtual void traverse(TIntermTraverser*);
	virtual TIntermSymbol* getAsSymbolNode()
	{
		return this;
	}
protected:
	int id;
	bool global;
	TString symbol;
	const TTypeInfo *info;
};

class TIntermDeclaration : public TIntermTyped {
public:
	TIntermDeclaration(const TType& type) : TIntermTyped(type), _declaration(NULL) {
		
	}
	virtual void traverse(TIntermTraverser*);
	virtual TIntermDeclaration* getAsDeclaration() { return this; }
	
	bool hasInitialization() const { return _declaration->getAsBinaryNode() != NULL; }
	TIntermTyped*& getDeclaration() { return _declaration; }
	/* @TODO
	TPublicType getPublicType() {
		TType& t = *getTypePointer();
		TPublicType p = {
			t.getBasicType(),
			t.getQualifier(),
			t.getPrecision(),
			t.getColsCount(),
			t.getRowsCount(),
			t.isMatrix(),
			t.isArray(),
			t.getArraySize(),
			t.getBasicType() == EbtStruct ? &t : NULL,
			t.getLine()
		};
		return p;
	}
	*/
	bool containsArrayInitialization() const { return isArray() && hasInitialization(); }
	
private:
	TIntermTyped* _declaration;
};

class TIntermConstant : public TIntermTyped
{
public:
	TIntermConstant(const TType& t) : TIntermTyped(t)
	{
		grow(t.getObjectSize() - 1);
	}

	virtual TIntermConstant* getAsConstant()
	{
		return this;
	}

	struct Value {
		TBasicType type;
		union {
			int asInt;
			float asFloat;
			bool asBool;
		};
	};
	
	#define defset(i, t) Value& v = values[(i)]; v.as##t = (val); v.type = Ebt##t
	void setValue(unsigned val)			{ defset(0, Int); }
	void setValue(int val)				{ defset(0, Int); }
	void setValue(float val)			{ defset(0, Float); }
	void setValue(bool val)				{ defset(0, Bool); }
	void setValue(unsigned i, int val)	{ grow(i); defset(i, Int); }
	void setValue(unsigned i, float val){ grow(i); defset(i, Float); ;}
	void setValue(unsigned i, bool val) { grow(i); defset(i, Bool); }
	void setValue(unsigned i, const Value& val) { values[i] = val; }

	int toInt(unsigned i = 0) { return values[i].asInt; }
	float toFloat(unsigned i = 0) { return values[i].asFloat; }
	bool toBool(unsigned i = 0) { return values[i].asBool; }
	#undef defset
	
	const Value& getValue(unsigned i = 0) const { return values[i]; }
	Value& getValue(unsigned i = 0) { return values[i]; }
	
	unsigned getCount() {
		return values.size();
	}
	
	void copyValuesFrom(const TIntermConstant& c) { values = c.values; }

	virtual void traverse(TIntermTraverser* );
protected:
	void grow(unsigned ix) {
		if (values.size() <= ix)
			values.resize(ix + 1);
	}
	
	typedef TVector<Value> Values;
	Values values;
};

//
// Intermediate class for node types that hold operators.
//
class TIntermOperator : public TIntermTyped
{
public:
	TOperator getOp() const { return op; }
	bool modifiesState() const;
	bool isConstructor() const;
	virtual bool promote(TParseContext& ctx)
	{
		return true;
	}
	virtual TIntermOperator* getAsOperatorNode()
	{
		return this;
	}
	
protected:
	TIntermOperator(TOperator o) : TIntermTyped(TType(EbtFloat, EbpUndefined)), op(o) {}
	TIntermOperator(TOperator o, TType& t) : TIntermTyped(t), op(o) {}   
	TOperator op;
};

//
// Nodes for all the basic binary math operators.
//
class TIntermBinary : public TIntermOperator
{
public:
	TIntermBinary(TOperator o) : TIntermOperator(o)
	{
	}
	virtual void traverse(TIntermTraverser*);

	void setLeft(TIntermTyped* n) { left = n; }
	void setRight(TIntermTyped* n) { right = n; }
	TIntermTyped* getLeft() const { return left; }
	TIntermTyped* getRight() const { return right; }

	virtual TIntermBinary* getAsBinaryNode()
	{
		return this;
	}
	virtual bool promote(TParseContext& ctx);
	
protected:
	TIntermTyped* left;
	TIntermTyped* right;
};

//
// Nodes for unary math operators.
//
class TIntermUnary : public TIntermOperator
{
public:
	TIntermUnary(TOperator o, TType& t) : TIntermOperator(o, t), operand(0)
	{
	}
	TIntermUnary(TOperator o) : TIntermOperator(o), operand(0)
	{
	}
	virtual void traverse(TIntermTraverser*);

	void setOperand(TIntermTyped* o) { operand = o; }
	TIntermTyped* getOperand() { return operand; }

	virtual bool promote(TParseContext& ctx);
	
private:
	TIntermTyped* operand;
};

typedef TVector<TIntermNode*> TNodeArray;


//
// Nodes that operate on an arbitrary sized set of children.
//
class TIntermAggregate : public TIntermOperator
{
public:
	TIntermAggregate() : TIntermOperator(EOpNull)
	{
	}
	TIntermAggregate(TOperator o) : TIntermOperator(o)
	{
	}
	~TIntermAggregate() { }

	virtual TIntermAggregate* getAsAggregate()
	{
		return this;
	}

	void setOperator(TOperator o) { op = o; }
	TNodeArray& getNodes() { return nodes; }
	void setName(const TString& n) { name = n; }
	void setPlainName(const TString& n) { plainName = n; }
	void setSemantic(const TString& s) { semantic = s; }
	const TString& getName() const { return name; }
	const TString& getPlainName() const { return plainName; }
	const TString& getSemantic() const { return semantic; }

	virtual void traverse(TIntermTraverser*);

private:
	// no copying
	TIntermAggregate(const TIntermAggregate&);
	TIntermAggregate& operator=(const TIntermAggregate&);
	
	TNodeArray nodes;
	TString name;
	TString plainName;
	TString semantic;
};

//
// For if tests.  Simplified since there is no switch statement.
//
class TIntermSelection : public TIntermTyped
{
public:
	TIntermSelection(TIntermTyped* cond, TIntermNode* trueB, TIntermNode* falseB)
	:	TIntermTyped(TType(EbtVoid,EbpUndefined)), condition(cond), trueBlock(trueB), falseBlock(falseB) { }
	TIntermSelection(TIntermTyped* cond, TIntermNode* trueB, TIntermNode* falseB, const TType& type)
	:	TIntermTyped(type), condition(cond), trueBlock(trueB), falseBlock(falseB) { }
	virtual void traverse(TIntermTraverser*);

	TIntermNode* getCondition() const { return condition; }
	TIntermNode* getTrueBlock() const { return trueBlock; }
	TIntermNode* getFalseBlock() const { return falseBlock; }
	TIntermSelection* getAsSelectionNode() { return this; }

	bool promoteTernary(TInfoSink&);
	
private:
   TIntermTyped* condition;
   TIntermNode* trueBlock;
   TIntermNode* falseBlock;
};

//
// For traversing the tree.  User should derive from this, 
// put their traversal specific data in it, and then pass
// it to a Traverse method.
//
// When using this, just fill in the methods for nodes you want visited.
// Return false from a pre-visit to skip visiting that node's subtree.
//
class TIntermTraverser
{
public:
	POOL_ALLOCATOR_NEW_DELETE(GlobalPoolAllocator)

	TIntermTraverser() : 
		visitSymbol(0), 
		visitConstant(0),
		visitBinary(0),
		visitUnary(0),
		visitSelection(0),
		visitAggregate(0),
		visitDeclaration(0),
		visitLoop(0),
		visitBranch(0),
		depth(0),
		preVisit(true),
		postVisit(false)
	{
	}

	bool (*visitDeclaration)(bool preVisit, TIntermDeclaration*, TIntermTraverser*);
	void (*visitSymbol)(TIntermSymbol*, TIntermTraverser*);
	void (*visitConstant)(TIntermConstant*, TIntermTraverser*);
	bool (*visitBinary)(bool preVisit, TIntermBinary*, TIntermTraverser*);
	bool (*visitUnary)(bool preVisit, TIntermUnary*, TIntermTraverser*);
	bool (*visitSelection)(bool preVisit, TIntermSelection*, TIntermTraverser*);
	bool (*visitAggregate)(bool preVisit, TIntermAggregate*, TIntermTraverser*);
	bool (*visitLoop)(bool preVisit, TIntermLoop*, TIntermTraverser*);
	bool (*visitBranch)(bool preVisit, TIntermBranch*,  TIntermTraverser*);

	int  depth;
	bool preVisit;
	bool postVisit;
};

} // namespace

#endif // __INTERMEDIATE_H

