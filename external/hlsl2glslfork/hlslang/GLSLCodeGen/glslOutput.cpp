// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "glslOutput.h"

#include <cstdlib>
#include <cstring>

#ifdef _WIN32
	#define snprintf _snprintf
#endif

namespace hlslang {

//ACS: some texture lookup types were deprecated after 1.20, and 1.40 won't accept them
bool UsePost120TextureLookups(ETargetVersion targetVersion) {
    if(targetVersion<ETargetVersionCount) {
        return (targetVersion>ETargetGLSL_120); 
    }
    else {
        return false;
    }
}

void print_float (std::stringstream& out, float f)
{
	// Kind of roundabout way, but this is to satisfy two things:
	// * MSVC and gcc-based compilers differ a bit in how they treat float
	//   width/precision specifiers. Want to match for tests.
	// * GLSL (early version at least) require floats to have ".0" or
	//   exponential notation.
	char tmp[64];
	sprintf(tmp, "%.7g", f);

	char* posE = NULL;
	posE = strchr(tmp, 'e');
	if (!posE)
		posE = strchr(tmp, 'E');

	#if _MSC_VER
	// While gcc would print something like 1.0e+07, MSVC will print 1.0e+007 -
	// only for exponential notation, it seems, will add one extra useless zero. Let's try to remove
	// that so compiler output matches.
	if (posE != NULL)
	{
		if((posE[1] == '+' || posE[1] == '-') && posE[2] == '0')
		{
			char* p = posE+2;
			while (p[0])
			{
				p[0] = p[1];
				++p;
			}
		}
	}
	#endif

	out << tmp;

	// need to append ".0"?
	if (!strchr(tmp,'.') && (posE == NULL))
		out << ".0";
}


bool isShadowSampler(TBasicType t) {
	switch (t) {
		case EbtSampler1DShadow:
		case EbtSampler2DShadow:
		case EbtSamplerRectShadow:
			return true;
		default:
			return false;
	}
}

TString buildArrayConstructorString(const TType& type) {
	std::stringstream constructor;
	constructor << getTypeString(translateType(&type))
				<< '[' << type.getArraySize() << ']';

	return TString(constructor.str().c_str());
}


static void writeConstantConstructor (std::stringstream& out, EGlslSymbolType t, TPrecision prec, TIntermConstant *c, const GlslStruct *structure = 0)
{
	unsigned n_elems = getElements(t);
	bool construct = n_elems > 1 || structure != 0;

	if (construct) {
		writeType (out, t, structure, EbpUndefined);
		out << "(";
	}
	
	if (structure) {
		// compound type
		unsigned n_members = structure->memberCount();
		for (unsigned i = 0; i != n_members; ++i) {
			const StructMember &m = structure->getMember(i);
			if (construct && i > 0)
				out << ", ";
			writeConstantConstructor (out, m.type, m.precision, c, m.getStruct());
		}
	} else {
		// simple type
		unsigned n_constants = c->getCount();
		for (unsigned i = 0; i != n_elems; ++i) {
			unsigned v = Min(i, n_constants - 1);
			if (construct && i > 0)
				out << ", ";
			TBasicType basicType = c->getBasicType();
			if (basicType == EbtStruct)
			    basicType = c->getValue(v).type;
			switch (basicType) {
				case EbtBool:
					out << (c->toBool(v) ? "true" : "false");
					break;
				case EbtInt:
					out << c->toInt(v);
					break;
				case EbtFloat:
					print_float(out, c->toFloat(v));
					break;
				default:
					assert(0);
			}
		}
	}

	if (construct)
		out << ")";
}


void writeComparison( const TString &compareOp, const TString &compareCall, TIntermBinary *node, TGlslOutputTraverser* goit ) 
{
   GlslFunction *current = goit->current;    
   std::stringstream& out = current->getActiveOutput();
   bool bUseCompareCall = false;

   // Determine whether we need the vector or scalar comparison function
   if ( ( node->getLeft() && !node->getLeft()->isScalar()) ||
        ( node->getRight() && !node->getRight()->isScalar()) )
   {
      bUseCompareCall = true;
   }

   current->beginStatement ();

   // Output vector comparison
   if ( bUseCompareCall )
   {
      out << compareCall << "( ";

      if (node->getLeft())
      {
         // If it is a float, need to smear to the size of the right hand side
         if (node->getLeft()->isScalar())
         {
            out << "vec" <<  node->getRight()->getRowsCount() << "( ";

            node->getLeft()->traverse(goit);

            out << " )";                
         }
         else
         {
            node->getLeft()->traverse(goit);
         }         
      }
      out << ", ";

      if (node->getRight())
      {
         // If it is a float, need to smear to the size of the left hand side
         if (node->getRight()->isScalar())
         {
            out << "vec" <<  node->getLeft()->getRowsCount() << "( ";

            node->getRight()->traverse(goit);

            out << " )";             
         }
         else
         {
            node->getRight()->traverse(goit);
         }         
      }
      out << ")";
   }
   // Output scalar comparison
   else
   {
      out << "(";

      if (node->getLeft())
         node->getLeft()->traverse(goit);
      out << " " << compareOp << " ";
      if (node->getRight())
         node->getRight()->traverse(goit);

      out << ")";
   }
}


void writeFuncCall( const TString &name, TIntermAggregate *node, TGlslOutputTraverser* goit, bool bGenMatrix = false, bool mangleName = false )
{
   TNodeArray::iterator sit;
   TNodeArray& nodes = node->getNodes(); 
   GlslFunction *current = goit->current;
   std::stringstream& out = current->getActiveOutput();

   current->beginStatement();
   
   if ( bGenMatrix )
   {
      if ( node->isMatrix () )
      {
         out << "xll_";
         current->addLibFunction ( node->getOp() );
      }
   }      

   out << name;

	if (mangleName || (bGenMatrix && node->isMatrix()))
	{
		for (sit = nodes.begin(); sit != nodes.end(); ++sit)
		{
			TString mangledType;
			(*sit)->getAsTyped()->getType().buildMangledName(mangledType);
			out << "_" << mangledType;
		}
	}
   
   out << "( ";

	for (sit = nodes.begin(); sit != nodes.end(); ++sit)
	{
		if (sit !=nodes.begin())
			out << ", ";
		(*sit)->traverse(goit);
	}
	
   out << ")";
}


void setupUnaryBuiltInFuncCall( const TString &name, TIntermUnary *node, TString &opStr, bool &funcStyle, bool &prefix,
                                TGlslOutputTraverser* goit )
{
   GlslFunction *current = goit->current;   

   funcStyle = true;
   prefix = true;
   if ( node->isMatrix() )
   {
      current->addLibFunction( node->getOp() );
      opStr = "xll_" + name + "_";
	  node->getType().buildMangledName(opStr);
   }
   else
   {
      opStr = name;
   }   
}



void writeTex( const TString &name, TIntermAggregate *node, TGlslOutputTraverser* goit )
{
	TNodeArray& nodes = node->getNodes(); 
	TBasicType sampler_type = (*nodes.begin())->getAsTyped()->getBasicType();
	TString new_name;
	
    //ACS: do we need to change these for 1.40? 1.20-style texture lookups should just not show up at all, right?
	if (isShadowSampler(sampler_type)) {
		if (name == "texture2D")
			new_name = "shadow2D";
		else if (name == "texture2DProj")
			new_name = "shadow2DProj";
		else if (name == "texture1D")
			new_name = "shadow1D";
		else if (name == "texture1DProj")
			new_name = "shadow1DProj";
		else if (name == "texture2DRect")
			new_name = "shadow2DRect";
		else if (name == "texture2DRectProj")
			new_name = "shadow2DRectProj";
		else
			new_name = name;
	} else {
		new_name = name;
	}
	
	writeFuncCall(new_name, node, goit);
}

static bool SafeEquals(const char* a, const char* b)
{
    if((!a && b) || (a && !b))
    {
        return(false);
    }

    if(!a && !b)
    {
        return(true);
    }

    return(strcmp(a, b) == 0);
}

void TGlslOutputTraverser::outputLineDirective (const TSourceLoc& line)
{
	if (line.line <= 0 || !current)
		return;
	if (SafeEquals(line.file, m_LastLineOutput.file) && std::abs(line.line - m_LastLineOutput.line) < 4) // don't sprinkle too many #line directives ;)
		return;
	std::stringstream& out = current->getActiveOutput();
	out << '\n';
	current->indent(); // without this we could dry the code out further to put the preceeding CRLF in the shared function
	OutputLineDirective(out, line);
	m_LastLineOutput = line;
}



TGlslOutputTraverser::TGlslOutputTraverser(TInfoSink& i, std::vector<GlslFunction*> &funcList, std::vector<GlslStruct*> &sList, std::stringstream& deferredArrayInit, std::stringstream& deferredMatrixInit, ETargetVersion version, unsigned options)
: infoSink(i)
, generatingCode(true)
, functionList(funcList)
, structList(sList)
, m_DeferredArrayInit(deferredArrayInit)
, m_DeferredMatrixInit(deferredMatrixInit)
, swizzleAssignTempCounter(0)
, m_TargetVersion(version)
, m_UsePrecision(Hlsl2Glsl_VersionUsesPrecision(version))
, m_ArrayInitWorkaround(!!(options & ETranslateOpEmitGLSL120ArrayInitWorkaround))
{
	m_LastLineOutput.file = NULL;
	m_LastLineOutput.line = -1;
	visitSymbol = traverseSymbol;
	visitConstant = traverseConstant;
	visitBinary = traverseBinary;
	visitUnary = traverseUnary;
	visitSelection = traverseSelection;
	visitAggregate = traverseAggregate;
	visitLoop = traverseLoop;
	visitBranch = traverseBranch;
	visitDeclaration = traverseDeclaration;
	
	TSourceLoc oneSourceLoc;
	oneSourceLoc.file=NULL;
	oneSourceLoc.line=1;

	// Add a fake "global" function for declarations & initializers happening
	// at global scope.
	global = new GlslFunction( "__global__", "__global__", EgstVoid, EbpUndefined, "", oneSourceLoc);
	functionList.push_back(global);
	current = global;
}



void TGlslOutputTraverser::traverseArrayDeclarationWithInit(TIntermDeclaration* decl)
{
	assert(decl->containsArrayInitialization());
	
	std::stringstream* out = &current->getActiveOutput();
	TType& type = *decl->getTypePointer();
	EGlslSymbolType symbol_type = translateType(decl->getTypePointer());
	
	const bool emit_120_arrays = (m_TargetVersion >= ETargetGLSL_120);
	const bool emit_old_arrays = !emit_120_arrays || m_ArrayInitWorkaround;
	const bool emit_both = emit_120_arrays && emit_old_arrays;
	
	if (emit_both)
	{
		current->indent(*out);
		(*out) << "#if defined(HLSL2GLSL_ENABLE_ARRAY_120_WORKAROUND)" << std::endl;
		current->increaseDepth();
	}
	
	if (emit_old_arrays)
	{
		TQualifier q = type.getQualifier();
		if (q == EvqConst)
			q = EvqTemporary;
		
		current->beginStatement();
		if (q != EvqTemporary && q != EvqGlobal)
			(*out) << type.getQualifierString() << " ";
		
		TIntermBinary* assign = decl->getDeclaration()->getAsBinaryNode();
		TIntermSymbol* sym = assign->getLeft()->getAsSymbolNode();
		TNodeArray& init = assign->getRight()->getAsAggregate()->getNodes();
		
		writeType(*out, symbol_type, NULL, this->m_UsePrecision ? decl->getPrecision() : EbpUndefined);
		(*out) << " " << sym->getSymbol() << "[" << type.getArraySize() << "]";
		current->endStatement();

		std::stringstream* oldOut = out;
		if (sym->isGlobal())
		{
			current->pushDepth(0);
			out = &m_DeferredArrayInit;
			current->setActiveOutput(out);
		}
		
		unsigned n_vals = init.size();
		for (unsigned i = 0; i != n_vals; ++i) {
			current->beginStatement();
			sym->traverse(this);
			(*out) << "[" << i << "] = ";
			EGlslSymbolType init_type = translateType(init[i]->getAsTyped()->getTypePointer());

			bool diffTypes = (symbol_type != init_type);
			if (diffTypes) {
				writeType (*out, symbol_type, NULL, EbpUndefined);
				(*out) << "(";
			}
			init[i]->traverse(this);
			if (diffTypes) {
				(*out) << ")";
			}
			current->endStatement();
		}
		
		if (sym->isGlobal())
		{
			out = oldOut;
			current->setActiveOutput(oldOut);
			current->popDepth();
		}
	}
	
	if (emit_both)
	{
		current->decreaseDepth();
		current->indent(*out);
		(*out) << "#else" << std::endl;
		current->increaseDepth();
	}
	
	if (emit_120_arrays)
	{	
		current->beginStatement();
		
		if (type.getQualifier() != EvqTemporary && type.getQualifier() != EvqGlobal)
			(*out) << type.getQualifierString() << " ";
		
		if (type.getBasicType() == EbtStruct)
			(*out) << type.getTypeName();
		else
			writeType(*out, symbol_type, NULL, this->m_UsePrecision ? decl->getPrecision() : EbpUndefined);
		
		if (type.isArray())
			(*out) << "[" << type.getArraySize() << "]";
		
		(*out) << " ";
		
		decl->getDeclaration()->traverse(this);
		
		current->endStatement();
	}
	
	if (emit_both)
	{
		current->decreaseDepth();
		current->indent(*out);
		(*out) << "#endif" << std::endl;
	}
}



bool TGlslOutputTraverser::traverseDeclaration(bool preVisit, TIntermDeclaration* decl, TIntermTraverser* it)
{
	TGlslOutputTraverser* goit = static_cast<TGlslOutputTraverser*>(it);
	GlslFunction *current = goit->current;
	if (decl->containsArrayInitialization())
	{
		goit->traverseArrayDeclarationWithInit (decl);
		return false;
	}

	TType& type = *decl->getTypePointer();
	if (type.getBasicType() == EbtTexture)
	{
		// right now we can't do anything with "texture" type, just skip it
		return false;
	}
	
    
    std::stringstream* oldOut2 = nullptr;
    
    std::stringstream temp;
    if (current == goit->global /*&& !decl->hasInitialization()*/) {
        oldOut2 = &current->getActiveOutput();
        current->setActiveOutput(&temp);
    }
        
    
    std::stringstream& out = current->getActiveOutput();

	current->beginStatement();
	
	if (type.getQualifier() != EvqTemporary && type.getQualifier() != EvqGlobal)
		out << type.getQualifierString() << " ";
	
	if (type.getBasicType() == EbtStruct)
		out << type.getTypeName();
	else
	{
		EGlslSymbolType symbol_type = translateType(decl->getTypePointer());
		writeType(out, symbol_type, NULL, goit->m_UsePrecision ? decl->getPrecision() : EbpUndefined);
	}

	out << " ";

	// Pre-GLSL1.20 & GLSL ES, global variables can't have initializers.
	// So just print the symbol node itself.
	bool skipInitializer = false;
    const bool can_have_global_init = false; //(goit->m_TargetVersion >= ETargetGLSL_120 && goit->m_TargetVersion != ETargetGLSL_ES_300); //TODO: GLSL 3.1 won't support global initializers either
	if (!can_have_global_init && decl->hasInitialization() && type.getQualifier() != EvqConst)
	{
		TIntermBinary* initNode = decl->getDeclaration()->getAsBinaryNode();
		TIntermSymbol* symbol = initNode->getLeft()->getAsSymbolNode();
		if (symbol && symbol->isGlobal())
		{
			skipInitializer = true;
			symbol->traverse(goit);
			
			// If this isn't a uniform, and we couldn't just emit it's initialization,
			// then emit initialization for later until main().
			if (type.getQualifier() != EvqUniform)
			{
				std::stringstream* oldOut = &out;
				current->pushDepth(0);
				current->setActiveOutput(&goit->m_DeferredMatrixInit);

				decl->getDeclaration()->traverse(goit);
				goit->m_DeferredMatrixInit << ";\n";

				current->setActiveOutput(oldOut);
				current->popDepth();
			}
		}
	}
	
	if (!skipInitializer)
		decl->getDeclaration()->traverse(goit);
	
	if (type.isArray())
		out << "[" << type.getArraySize() << "]";
	
	current->endStatement();
    
    if (oldOut2)
    {
        current->setActiveOutput(oldOut2);
    }

	return false;
}


void TGlslOutputTraverser::traverseSymbol(TIntermSymbol *node, TIntermTraverser *it)
{
	TGlslOutputTraverser* goit = static_cast<TGlslOutputTraverser*>(it);
	GlslFunction *current = goit->current;
	std::stringstream& out = current->getActiveOutput();

	current->beginStatement();

	if ( ! current->hasSymbol( node->getId()))
	{

		//check to see if it is a global we can share
		if ( goit->global->hasSymbol( node->getId()))
		{
			current->addSymbol( &goit->global->getSymbol( node->getId()));
		}
		else
		{
			int array = node->getTypePointer()->isArray() ? node->getTypePointer()->getArraySize() : 0;
			const char* semantic = "";
			const char* registerSpec = "";

			if (node->getInfo())
			{
				semantic = node->getInfo()->getSemantic().c_str();
				registerSpec = node->getInfo()->getRegister().c_str();
			}
			
			GlslSymbol * sym = new GlslSymbol( node->getSymbol().c_str(), semantic, registerSpec, node->getId(),
				translateType(node->getTypePointer()), goit->m_UsePrecision?node->getPrecision():EbpUndefined, translateQualifier(node->getQualifier()), array);
			sym->setIsGlobal(node->isGlobal());

			current->addSymbol(sym);
			if (sym->getType() == EgstStruct)
			{
				GlslStruct *s = goit->createStructFromType( node->getTypePointer());
				sym->setStruct(s);
			}
		}
	}

	// If we're at the global scope, emit the non-mutable names of uniforms.
	bool globalScope = current == goit->global;
	out << current->getSymbol(node->getId()).getName(!globalScope);
}


void TGlslOutputTraverser::traverseParameterSymbol(TIntermSymbol *node, TIntermTraverser *it)
{
   TGlslOutputTraverser* goit = static_cast<TGlslOutputTraverser*>(it);
   GlslFunction *current = goit->current;

   int array = node->getTypePointer()->isArray() ? node->getTypePointer()->getArraySize() : 0;
   const char* semantic = "";
   const char* registerSpec = "";
   if (node->getInfo())
   {
      semantic = node->getInfo()->getSemantic().c_str();
      registerSpec = node->getInfo()->getRegister().c_str();
   }

    TPrecision prec = goit->m_UsePrecision ? node->getPrecision() : EbpUndefined;
    if(semantic[0] && goit->m_UsePrecision)
    {
        int len = ::strlen(semantic);

        extern bool IsPositionSemantics(const char* sem, int len);
        if(IsPositionSemantics(semantic, len))
            prec = EbpHigh;
    }

   GlslSymbol * sym = new GlslSymbol( node->getSymbol().c_str(), semantic, registerSpec, node->getId(),
                                      translateType(node->getTypePointer()), prec, translateQualifier(node->getQualifier()), array);
   current->addParameter(sym);

   if (sym->getType() == EgstStruct)
   {
      GlslStruct *s = goit->createStructFromType( node->getTypePointer());
      sym->setStruct(s);
   }
}


void TGlslOutputTraverser::traverseConstant( TIntermConstant *node, TIntermTraverser *it )
{
   TGlslOutputTraverser* goit = static_cast<TGlslOutputTraverser*>(it);
   GlslFunction *current = goit->current;
   std::stringstream& out = current->getActiveOutput();
   EGlslSymbolType type = translateType( node->getTypePointer());
   GlslStruct *str = 0;


   current->beginStatement();

   if (type == EgstStruct)
   {
      str = goit->createStructFromType( node->getTypePointer());
   }

   writeConstantConstructor (out, type, goit->m_UsePrecision?node->getPrecision():EbpUndefined, node, str);
}


void TGlslOutputTraverser::traverseImmediateConstant( TIntermConstant *c, TIntermTraverser *it )
{
   TGlslOutputTraverser* goit = static_cast<TGlslOutputTraverser*>(it);

   // These are all expected to be length 1
   assert(c->getSize() == 1);

   // Autotype the result
   switch (c->getBasicType())
   {
   case EbtBool:
      goit->indexList.push_back(c->toBool() ? 1 : 0);
      break;
   case EbtInt:
      goit->indexList.push_back(c->toInt());
      break;
   case EbtFloat:
      goit->indexList.push_back((int)c->toFloat());
      break;
   default:
      assert(false && "Invalid constant type. Only bool, int and float supported"); 
      goit->indexList.push_back(0);
   }
}


// Special case for matrix[idx1][idx2]: output as matrix[idx2][idx1]
static bool Check2DMatrixIndex (TGlslOutputTraverser* goit, std::stringstream& out, TIntermTyped* left, TIntermTyped* right)
{
	if (left->isVector() && !left->isArray())
	{
		TIntermBinary* leftBin = left->getAsBinaryNode();
		if (leftBin && (leftBin->getOp() == EOpIndexDirect || leftBin->getOp() == EOpIndexIndirect))
		{
			TIntermTyped* superLeft = leftBin->getLeft();
			TIntermTyped* superRight = leftBin->getRight();
			if (superLeft->isMatrix() && !superLeft->isArray())
			{
				superLeft->traverse (goit);
				out << "[";
				right->traverse(goit);
				out << "][";
				superRight->traverse(goit);
				out << "]";
				return true;
			}
		}
	}
	return false;
}

bool TGlslOutputTraverser::traverseBinary( bool preVisit, TIntermBinary *node, TIntermTraverser *it )
{
   TString op = "??";
   TGlslOutputTraverser* goit = static_cast<TGlslOutputTraverser*>(it);
   GlslFunction *current = goit->current;
   std::stringstream& out = current->getActiveOutput();
   bool infix = true;
   bool assign = false;
   bool needsParens = true;

   switch (node->getOp())
   {
   case EOpAssign:                   op = "=";   infix = true; needsParens = false; break;
   case EOpAddAssign:                op = "+=";  infix = true; needsParens = false; break;
   case EOpSubAssign:                op = "-=";  infix = true; needsParens = false; break;
   case EOpMulAssign:                op = "*=";  infix = true; needsParens = false; break;
   case EOpVectorTimesMatrixAssign:  op = "*=";  infix = true; needsParens = false; break;
   case EOpVectorTimesScalarAssign:  op = "*=";  infix = true; needsParens = false; break;
   case EOpMatrixTimesScalarAssign:  op = "*=";  infix = true; needsParens = false; break;
   case EOpMatrixTimesMatrixAssign:  op = "matrixCompMult";  infix = false; assign = true; break;
   case EOpDivAssign:                op = "/=";  infix = true; needsParens = false; break;
   case EOpModAssign:                op = "%=";  infix = true; needsParens = false; break;
   case EOpAndAssign:                op = "&=";  infix = true; needsParens = false; break;
   case EOpInclusiveOrAssign:        op = "|=";  infix = true; needsParens = false; break;
   case EOpExclusiveOrAssign:        op = "^=";  infix = true; needsParens = false; break;
   case EOpLeftShiftAssign:          op = "<<="; infix = true; needsParens = false; break;
   case EOpRightShiftAssign:         op = ">>="; infix = true; needsParens = false; break;

   case EOpIndexDirect:
      {
         TIntermTyped *left = node->getLeft();
         TIntermTyped *right = node->getRight();
         assert( left && right);

         current->beginStatement();

		 if (Check2DMatrixIndex (goit, out, left, right))
			 return false;

		 if (left->isMatrix() && !left->isArray())
		 {
			 if (right->getAsConstant())
			 {
				 current->addLibFunction (EOpMatrixIndex);
				 TString opName = "xll_matrixindex_";
				 left->getType().buildMangledName(opName);
				 opName += "_";
				 right->getType().buildMangledName(opName);
				 out << opName << " (";
				 left->traverse(goit);
				 out << ", ";
				 right->traverse(goit);
				 out << ")";
				 return false;
			 }
			 else
			 {
				 current->addLibFunction (EOpTranspose);
				 current->addLibFunction (EOpMatrixIndex);
				 current->addLibFunction (EOpMatrixIndexDynamic);
				 TString opName = "xll_matrixindexdynamic_";
				 left->getType().buildMangledName(opName);
				 opName += "_";
				 right->getType().buildMangledName(opName);
				 out << opName << " (";
				 left->traverse(goit);
				 out << ", ";
				 right->traverse(goit);
				 out << ")";
				 return false;
			 }
		 }

         left->traverse(goit);

         // Special code for handling a vector component select (this improves readability)
         if (left->isVector() && !left->isArray() && right->getAsConstant())
         {
            char swiz[] = "xyzw";
            goit->visitConstant = TGlslOutputTraverser::traverseImmediateConstant;
            goit->generatingCode = false;
            right->traverse(goit);
            assert( goit->indexList.size() == 1);
            assert( goit->indexList[0] < 4);
            out << "." << swiz[goit->indexList[0]];
            goit->indexList.clear();
            goit->visitConstant = TGlslOutputTraverser::traverseConstant;
            goit->generatingCode = true;
         }
         else
         {
            out << "[";
            right->traverse(goit);
            out << "]";
         }
         return false;
      }
   case EOpIndexIndirect:
      {
      TIntermTyped *left = node->getLeft();
      TIntermTyped *right = node->getRight();
      current->beginStatement();

	  if (Check2DMatrixIndex (goit, out, left, right))
		  return false;

	  if (left && right && left->isMatrix() && !left->isArray())
	  {
		  if (right->getAsConstant())
		  {
			  current->addLibFunction (EOpMatrixIndex);
			  TString opName = "xll_matrixindex_";
			  left->getType().buildMangledName(opName);
			  opName += "_";
			  right->getType().buildMangledName(opName);
			  out << opName << " (";
			  left->traverse(goit);
			  out << ", ";
			  right->traverse(goit);
			  out << ")";
			  return false;
		  }
		  else
		  {
			  current->addLibFunction (EOpTranspose);
			  current->addLibFunction (EOpMatrixIndex);
			  current->addLibFunction (EOpMatrixIndexDynamic);
			  TString opName = "xll_matrixindexdynamic_";
			  left->getType().buildMangledName(opName);
			  opName += "_";
			  right->getType().buildMangledName(opName);
			  out << opName << " (";
			  left->traverse(goit);
			  out << ", ";
			  right->traverse(goit);
			  out << ")";
			  return false;
		  }
	  }

      if (left)
         left->traverse(goit);
      out << "[";
      if (right)
         right->traverse(goit);
      out << "]";
      return false;
	  }

   case EOpIndexDirectStruct:
      {
         current->beginStatement();
         GlslStruct *s = goit->createStructFromType(node->getLeft()->getTypePointer());
         if (node->getLeft())
            node->getLeft()->traverse(goit);

         // The right child is always an offset into the struct, switch to get an
         // immediate constant, and put it back afterwords
         goit->visitConstant = TGlslOutputTraverser::traverseImmediateConstant;
         goit->generatingCode = false;

         if (node->getRight())
         {
            node->getRight()->traverse(goit);
            assert( goit->indexList.size() == 1);
            assert( goit->indexList[0] < s->memberCount());
            out << "." << s->getMember(goit->indexList[0]).name;

         }

         goit->indexList.clear();
         goit->visitConstant = TGlslOutputTraverser::traverseConstant;
         goit->generatingCode = true;
      }
      return false;

   case EOpVectorSwizzle:
      current->beginStatement();
      if (node->getLeft())
         node->getLeft()->traverse(goit);
      goit->visitConstant = TGlslOutputTraverser::traverseImmediateConstant;
      goit->generatingCode = false;
      if (node->getRight())
      {
         node->getRight()->traverse(goit);
         assert( goit->indexList.size() <= 4);
         out << '.';
         const char fields[] = "xyzw";
         for (int ii = 0; ii < (int)goit->indexList.size(); ii++)
         {
            int val = goit->indexList[ii];
            assert( val >= 0);
            assert( val < 4);
            out << fields[val];
         }
      }
      goit->indexList.clear();
      goit->visitConstant = TGlslOutputTraverser::traverseConstant;
      goit->generatingCode = true;
      return false;

	case EOpMatrixSwizzle:		   
		// This presently only works for swizzles as rhs operators
		if (node->getRight())
		{
			goit->visitConstant = TGlslOutputTraverser::traverseImmediateConstant;
			goit->generatingCode = false;

			node->getRight()->traverse(goit);

			goit->visitConstant = TGlslOutputTraverser::traverseConstant;
			goit->generatingCode = true;

			std::vector<int> elements = goit->indexList;
			goit->indexList.clear();
			
			if (elements.size() > 4 || elements.size() < 1) {
				goit->infoSink.info << "Matrix swizzle operations can must contain at least 1 and at most 4 element selectors.";
				return true;
			}

			unsigned column[4] = {0}, row[4] = {0};
			for (unsigned i = 0; i != elements.size(); ++i)
			{
				unsigned val = elements[i];
				column[i] = val % 4;
				row[i] = val / 4;
			}

			bool sameColumn = true;
			for (unsigned i = 1; i != elements.size(); ++i)
				sameColumn &= column[i] == column[i-1];

			static const char* fields = "xyzw";
			
			if (sameColumn)
			{				
				//select column, then swizzle row
				if (node->getLeft())
					node->getLeft()->traverse(goit);
				out << "[" << column[0] << "].";
				
				for (unsigned i = 0; i < elements.size(); ++i)
					out << fields[row[i]];
			}
			else
			{
				// Insert constructor, and dereference individually

				// Might need to account for different types here 
				assert( elements.size() != 1); //should have hit same collumn case
				out << "vec" << elements.size() << "(";
				if (node->getLeft())
					node->getLeft()->traverse(goit);
				out << "[" << column[0] << "].";
				out << fields[row[0]];
				
				for (unsigned i = 1; i < elements.size(); ++i)
				{
					out << ", ";
					if (node->getLeft())
						node->getLeft()->traverse(goit);
					out << "[" << column[i] << "].";
					out << fields[row[i]];
				}
				out << ")";
			}
		}
		return false;

   case EOpAdd:    op = "+"; infix = true; break;
   case EOpSub:    op = "-"; infix = true; break;
   case EOpMul:    op = "*"; infix = true; break;
   case EOpDiv:    op = "/"; infix = true; break;
   case EOpMod:    op = "mod"; infix = false; break;
   case EOpRightShift:  op = ">>"; infix = true; break;
   case EOpLeftShift:   op = "<<"; infix = true; break;
   case EOpAnd:         op = "&"; infix = true; break;
   case EOpInclusiveOr: op = "|"; infix = true; break;
   case EOpExclusiveOr: op = "^"; infix = true; break;
   case EOpEqual:       
      writeComparison ( "==", "equal", node, goit );
      return false;        

   case EOpNotEqual:        
      writeComparison ( "!=", "notEqual", node, goit );
      return false;               

   case EOpLessThan: 
      writeComparison ( "<", "lessThan", node, goit );
      return false;               

   case EOpGreaterThan:
      writeComparison ( ">", "greaterThan", node, goit );
      return false;               

   case EOpLessThanEqual:    
      writeComparison ( "<=", "lessThanEqual", node, goit );
      return false;               


   case EOpGreaterThanEqual: 
      writeComparison ( ">=", "greaterThanEqual", node, goit );
      return false;               


   case EOpVectorTimesScalar: op = "*"; infix = true; break;
   case EOpVectorTimesMatrix: op = "*"; infix = true; break;
   case EOpMatrixTimesVector: op = "*"; infix = true; break;
   case EOpMatrixTimesScalar: op = "*"; infix = true; break;
   case EOpMatrixTimesMatrix: op = "matrixCompMult"; infix = false; assign = false; break;

   case EOpLogicalOr:  op = "||"; infix = true; break;
   case EOpLogicalXor: op = "^^"; infix = true; break;
   case EOpLogicalAnd: op = "&&"; infix = true; break;
   default: assert(0);
   }

   current->beginStatement();

   if (infix)
   {
	   // special case for swizzled matrix assignment
	   if (node->getOp() == EOpAssign && node->getLeft() && node->getRight()) {
		   TIntermBinary* lval = node->getLeft()->getAsBinaryNode();
		   
		   if (lval && lval->getOp() == EOpMatrixSwizzle) {
			   static const char* vec_swizzles = "xyzw";
			   TIntermTyped* rval = node->getRight();
			   TIntermTyped* lexp = lval->getLeft();
			   
			   goit->visitConstant = TGlslOutputTraverser::traverseImmediateConstant;
			   goit->generatingCode = false;
			   
			   lval->getRight()->traverse(goit);
			   
			   goit->visitConstant = TGlslOutputTraverser::traverseConstant;
			   goit->generatingCode = true;
			   
			   std::vector<int> swizzles = goit->indexList;
			   goit->indexList.clear();
			   
			   char temp_rval[128];
			   unsigned n_swizzles = swizzles.size();
			   
			   if (n_swizzles > 1) {
				   snprintf(temp_rval, 128, "xlat_swiztemp%d", goit->swizzleAssignTempCounter++);
				   
				   current->beginStatement();
				   out << "vec" << n_swizzles << " " << temp_rval << " = ";
				   rval->traverse(goit);			   
				   current->endStatement();
			   }
			   
			   for (unsigned i = 0; i != n_swizzles; ++i) {
				   unsigned col = swizzles[i] / 4;
				   unsigned row = swizzles[i] % 4;
				   
				   current->beginStatement();
				   lexp->traverse(goit);
				   out << "[" << row << "][" << col << "] = ";
				   if (n_swizzles > 1)
					   out << temp_rval << "." << vec_swizzles[i];
				   else
					   rval->traverse(goit);
				   
				   current->endStatement();
			   }

			   return false;
		   }
	   }

      if (needsParens)
         out << '(';

      if (node->getLeft())
         node->getLeft()->traverse(goit);
      out << ' ' << op << ' ';
      if (node->getRight())
         node->getRight()->traverse(goit);

      if (needsParens)
         out << ')';
   }
   else
   {
      if (assign)
      {		  
         // Need to traverse the left child twice to allow for the assign and the op
         // This is OK, because we know it is an lvalue
         if (node->getLeft())
            node->getLeft()->traverse(goit);

         out << " = " << op << '(';

         if (node->getLeft())
            node->getLeft()->traverse(goit);
         out << ", ";
         if (node->getRight())
            node->getRight()->traverse(goit);

         out << ')';
      }
      else
      {
         out << op << '(';

         if (node->getLeft())
            node->getLeft()->traverse(goit);
         out << ", ";
         if (node->getRight())
            node->getRight()->traverse(goit);

         out << ')';
      }
   }

   return false;
}


bool TGlslOutputTraverser::traverseUnary( bool preVisit, TIntermUnary *node, TIntermTraverser *it )
{
   TString op("??");
   TGlslOutputTraverser* goit = static_cast<TGlslOutputTraverser*>(it);
   GlslFunction *current = goit->current;
   std::stringstream& out = current->getActiveOutput();
   bool funcStyle = false;
   bool prefix = true;
   char zero[] = "0";

   current->beginStatement();

   switch (node->getOp())
   {
   case EOpNegative:       op = "-";  funcStyle = false; prefix = true; break;
   case EOpVectorLogicalNot:
   case EOpLogicalNot:     op = "!";  funcStyle = false; prefix = true; break;
   case EOpBitwiseNot:     op = "~";  funcStyle = false; prefix = true; break;

   case EOpPostIncrement:  op = "++"; funcStyle = false; prefix = false; break;
   case EOpPostDecrement:  op = "--"; funcStyle = false; prefix = false; break;
   case EOpPreIncrement:   op = "++"; funcStyle = false; prefix = true; break;
   case EOpPreDecrement:   op = "--"; funcStyle = false; prefix = true; break;

   case EOpConvIntToBool:
   case EOpConvFloatToBool:
      op = "bool";
      if (node->getTypePointer()->isVector())
      {
         zero[0] += node->getTypePointer()->getRowsCount();
         op = TString("bvec") + zero; 
      }
      funcStyle = true;
      prefix = true;
      break;

   case EOpConvBoolToFloat:
   case EOpConvIntToFloat:
      op = "float";
      if (node->getTypePointer()->isVector())
      {
         zero[0] += node->getTypePointer()->getRowsCount();
         op = TString("vec") + zero; 
      }
      funcStyle = true;
      prefix = true;
      break;

   case EOpConvFloatToInt: 
   case EOpConvBoolToInt:
      op = "int";
      if (node->getTypePointer()->isVector())
      {
         zero[0] += node->getTypePointer()->getRowsCount();
         op = TString("ivec") + zero; 
      }
      funcStyle = true;
      prefix = true;
      break;

   case EOpRadians:        setupUnaryBuiltInFuncCall ( "radians", node, op, funcStyle, prefix, goit );  break;
   case EOpDegrees:        setupUnaryBuiltInFuncCall ( "degrees", node, op, funcStyle, prefix, goit ); break;
   case EOpSin:            setupUnaryBuiltInFuncCall ( "sin", node, op, funcStyle, prefix, goit ); break;
   case EOpCos:            setupUnaryBuiltInFuncCall ( "cos", node, op, funcStyle, prefix, goit ); break;
   case EOpTan:            setupUnaryBuiltInFuncCall ( "tan", node, op, funcStyle, prefix, goit ); break;
   case EOpAsin:           setupUnaryBuiltInFuncCall ( "asin", node, op, funcStyle, prefix, goit ); break;
   case EOpAcos:           setupUnaryBuiltInFuncCall ( "acos", node, op, funcStyle, prefix, goit ); break;
   case EOpAtan:           setupUnaryBuiltInFuncCall ( "atan", node, op, funcStyle, prefix, goit ); break;
   
   case EOpExp:            setupUnaryBuiltInFuncCall ( "exp", node, op, funcStyle, prefix, goit ); break;
   case EOpLog:            setupUnaryBuiltInFuncCall ( "log", node, op, funcStyle, prefix, goit ); break;
   case EOpExp2:           setupUnaryBuiltInFuncCall ( "exp2", node, op, funcStyle, prefix, goit ); break;
   case EOpLog2:           setupUnaryBuiltInFuncCall ( "log2", node, op, funcStyle, prefix, goit ); break;
   case EOpSqrt:           setupUnaryBuiltInFuncCall ( "sqrt", node, op, funcStyle, prefix, goit ); break;
   case EOpInverseSqrt:    setupUnaryBuiltInFuncCall ( "inversesqrt", node, op, funcStyle, prefix, goit ); break;

   case EOpAbs:            setupUnaryBuiltInFuncCall ( "abs", node, op, funcStyle, prefix, goit ); break;
   case EOpSign:           setupUnaryBuiltInFuncCall ( "sign", node, op, funcStyle, prefix, goit ); break;
   case EOpFloor:          setupUnaryBuiltInFuncCall ( "floor", node, op, funcStyle, prefix, goit ); break;
   case EOpCeil:           setupUnaryBuiltInFuncCall ( "ceil", node, op, funcStyle, prefix, goit ); break;
   case EOpFract:          setupUnaryBuiltInFuncCall ( "fract", node, op, funcStyle, prefix, goit ); break;

   case EOpLength:         op = "length";  funcStyle = true; prefix = true; break;
   case EOpNormalize:      op = "normalize";  funcStyle = true; prefix = true; break;
   case EOpDPdx:
	   current->addLibFunction(EOpDPdx);
	   op = "xll_dFdx_";
	   node->getOperand()->getType().buildMangledName(op);
	   funcStyle = true;
	   prefix = true;
	   break;
   case EOpDPdy:
	   current->addLibFunction(EOpDPdy);
	   op = "xll_dFdy_";
	   node->getOperand()->getType().buildMangledName(op);
	   funcStyle = true;
	   prefix = true;
	   break;
   case EOpFwidth:
	   current->addLibFunction(EOpFwidth);
	   op = "xll_fwidth_";
	   node->getOperand()->getType().buildMangledName(op);
	   funcStyle = true;
	   prefix = true;
	   break;
   case EOpFclip:		   
	  current->addLibFunction(EOpFclip);
      op = "xll_clip_";
	  node->getOperand()->getType().buildMangledName(op);
      funcStyle = true;
      prefix = true;
      break;    

	case EOpRound:
		current->addLibFunction(EOpRound);
		op = "xll_round_";
	    node->getOperand()->getType().buildMangledName(op);
		funcStyle = true;
		prefix = true;
		break;
	case EOpTrunc:
	   current->addLibFunction(EOpTrunc);
	   op = "xll_trunc_";
	   node->getOperand()->getType().buildMangledName(op);
	   funcStyle = true;
	   prefix = true;
	   break;
		   
   case EOpAny:            op = "any";  funcStyle = true; prefix = true; break;
   case EOpAll:            op = "all";  funcStyle = true; prefix = true; break;

      //these are HLSL specific and they map to the lib functions
   case EOpSaturate:
      current->addLibFunction(EOpSaturate);
      op = "xll_saturate_";
	  node->getOperand()->getType().buildMangledName(op);
      funcStyle = true;
      prefix = true;
      break;    

   case EOpTranspose:
      current->addLibFunction(EOpTranspose);
      op = "xll_transpose_";
	  node->getOperand()->getType().buildMangledName(op);
      funcStyle = true;
      prefix = true;
      break;

   case EOpDeterminant:
      current->addLibFunction(EOpDeterminant);
      op = "xll_determinant_";
	  node->getOperand()->getType().buildMangledName(op);
      funcStyle = true;
      prefix = true;
      break;

   case EOpLog10:        
      current->addLibFunction(EOpLog10);
      op = "xll_log10_";
	  node->getOperand()->getType().buildMangledName(op);
      funcStyle = true;
      prefix = true;
      break;       

   case EOpD3DCOLORtoUBYTE4:
      current->addLibFunction(EOpD3DCOLORtoUBYTE4);
      op = "xll_D3DCOLORtoUBYTE4";
      funcStyle = true;
      prefix = true;
      break;

   default:
      assert(0);
   }

   if (funcStyle)
      out << op << '(';
   else
   {
      out << '(';
      if (prefix)
         out << op;
   }

   node->getOperand()->traverse(goit);

   if (! funcStyle && !prefix)
      out << op;

   out << ')';

   return false;
}


bool TGlslOutputTraverser::traverseSelection( bool preVisit, TIntermSelection *node, TIntermTraverser *it )
{
	TGlslOutputTraverser* goit = static_cast<TGlslOutputTraverser*>(it);
	GlslFunction *current = goit->current;
	std::stringstream& out = current->getActiveOutput();

	current->beginStatement();

	if (node->getBasicType() == EbtVoid)
	{
		// if/else selection
		out << "if (";
		node->getCondition()->traverse(goit);
		out << ')';
		current->beginBlock();
		if (node->getTrueBlock())
    		node->getTrueBlock()->traverse(goit);
		current->endBlock();
		if (node->getFalseBlock())
		{
			current->indent();
			out << "else";
			current->beginBlock();
			node->getFalseBlock()->traverse(goit);
			current->endBlock();
		}
	}
	else if (node->isVector() && node->getCondition()->getAsTyped()->isVector())
	{
		// ?: selection on vectors, e.g. bvec4 ? vec4 : vec4
		// emulate HLSL's component-wise selection here
		current->addLibFunction(EOpVecTernarySel);
		// \todo [pyry] Somehow true and false blocks have invalid types and mangling fails.
		//				I don't have energy to investigate that so mangling is done manually here.
		int vecSize = node->getCondition()->getAsTyped()->getType().getRowsCount();
		out << "xll_vecTSel_vb" << vecSize << "_vf" << vecSize << "_vf" << vecSize << " (";
//		TString op = "xll_vecTSel_";
//		node->getCondition()->getAsTyped()->getType().buildMangledName(op);
//		op += "_";
//		node->getTrueBlock()->getAsTyped()->getType().buildMangledName(op);
//		op += "_";
//		node->getFalseBlock()->getAsTyped()->getType().buildMangledName(op);
//		out << op << " (";
		node->getCondition()->traverse(goit);
		out << ", ";
		assert(node->getTrueBlock());
		node->getTrueBlock()->traverse(goit);
		out << ", ";
		assert(node->getFalseBlock());
		node->getFalseBlock()->traverse(goit);
		out << ")";
	}
	else
	{
		// simple ?: selection
		out << "(( ";
		node->getCondition()->traverse(goit);
		out << " ) ? ( ";
		assert(node->getTrueBlock());
		node->getTrueBlock()->traverse(goit);
		out << " ) : ( ";
		assert(node->getFalseBlock());
		node->getFalseBlock()->traverse(goit);
		out << " ))";
	}

	return false;
}


bool TGlslOutputTraverser::traverseAggregate( bool preVisit, TIntermAggregate *node, TIntermTraverser *it )
{
   TGlslOutputTraverser* goit = static_cast<TGlslOutputTraverser*>(it);
   GlslFunction *current = goit->current;
   std::stringstream& out = current->getActiveOutput();
   int argCount = (int) node->getNodes().size();
   bool usePost120TextureLookups = UsePost120TextureLookups(goit->m_TargetVersion); 

   if (node->getOp() == EOpNull)
   {
      goit->infoSink.info << "node is still EOpNull!\n";
      return true;
   }


   switch (node->getOp())
   {
   case EOpSequence:
      if (goit->generatingCode)
      {
		  goit->outputLineDirective (node->getLine());
         TNodeArray::iterator sit;
         TNodeArray& nodes = node->getNodes(); 
		 for (sit = nodes.begin(); sit != nodes.end(); ++sit)
		 {
		   goit->outputLineDirective((*sit)->getLine());
		   (*sit)->traverse(it);
		   //out << ";\n";
		   current->endStatement();
		 }
      }
      else
      {
         TNodeArray::iterator sit;
         TNodeArray& nodes = node->getNodes(); 
		  for (sit = nodes.begin(); sit != nodes.end(); ++sit)
		  {
		    (*sit)->traverse(it);
		  }
      }

      return false;

   case EOpFunction:
      {
         GlslFunction *func = new GlslFunction( node->getPlainName().c_str(), node->getName().c_str(),
                                                translateType(node->getTypePointer()), goit->m_UsePrecision?node->getPrecision():EbpUndefined,
											   node->getSemantic().c_str(), node->getLine()); 
         if (func->getReturnType() == EgstStruct)
         {
            GlslStruct *s = goit->createStructFromType( node->getTypePointer());
            func->setStruct(s);
         }
         goit->functionList.push_back( func);
         goit->current = func;
         goit->current->beginBlock( false);
         TNodeArray::iterator sit;
         TNodeArray& nodes = node->getNodes(); 
		 for (sit = nodes.begin(); sit != nodes.end(); ++sit)
		 {
			 (*sit)->traverse(it);
		 }
         goit->current->endBlock();
         goit->current = goit->global;
         return false;
      }

   case EOpParameters:
      it->visitSymbol = traverseParameterSymbol;
      {
         TNodeArray::iterator sit;
         TNodeArray& nodes = node->getNodes(); 
		 for (sit = nodes.begin(); sit != nodes.end(); ++sit)
           (*sit)->traverse(it);
      }
      it->visitSymbol = traverseSymbol;
      return false;

   case EOpConstructFloat: writeFuncCall( "float", node, goit); return false;
   case EOpConstructVec2:  writeFuncCall( "vec2", node, goit); return false;
   case EOpConstructVec3:  writeFuncCall( "vec3", node, goit); return false;
   case EOpConstructVec4:  writeFuncCall( "vec4", node, goit); return false;
   case EOpConstructBool:  writeFuncCall( "bool", node, goit); return false;
   case EOpConstructBVec2: writeFuncCall( "bvec2", node, goit); return false;
   case EOpConstructBVec3: writeFuncCall( "bvec3", node, goit); return false;
   case EOpConstructBVec4: writeFuncCall( "bvec4", node, goit); return false;
   case EOpConstructInt:   writeFuncCall( "int", node, goit); return false;
   case EOpConstructIVec2: writeFuncCall( "ivec2", node, goit); return false;
   case EOpConstructIVec3: writeFuncCall( "ivec3", node, goit); return false;
   case EOpConstructIVec4: writeFuncCall( "ivec4", node, goit); return false;

   case EOpConstructMat2x2:  writeFuncCall( "mat2",   node, goit); return false;
   case EOpConstructMat2x3:  writeFuncCall( "mat2x3", node, goit); return false;
   case EOpConstructMat2x4:  writeFuncCall( "mat2x4", node, goit); return false;

   case EOpConstructMat3x2:  writeFuncCall( "mat3x2", node, goit); return false;
   case EOpConstructMat3x3:  writeFuncCall( "mat3",   node, goit); return false;
   case EOpConstructMat3x4:  writeFuncCall( "mat3x4", node, goit); return false;

   case EOpConstructMat4x2:  writeFuncCall( "mat4x2", node, goit); return false;
   case EOpConstructMat4x3:  writeFuncCall( "mat4x3", node, goit); return false;
   case EOpConstructMat4x4:  writeFuncCall( "mat4",   node, goit); return false;


   case EOpConstructMat2x2FromMat:
      current->addLibFunction(EOpConstructMat2x2FromMat);
      writeFuncCall("xll_constructMat2", node, goit, false, true);
      return false;

   case EOpConstructMat3x3FromMat:
      current->addLibFunction(EOpConstructMat3x3FromMat);
      writeFuncCall("xll_constructMat3", node, goit, false, true);
      return false;

   case EOpConstructStruct:  writeFuncCall( node->getTypePointer()->getTypeName(), node, goit); return false;
   case EOpConstructArray:  writeFuncCall( buildArrayConstructorString(*node->getTypePointer()), node, goit); return false;

   case EOpComma:
      {
         TNodeArray::iterator sit;
         TNodeArray& nodes = node->getNodes(); 
         for (sit = nodes.begin(); sit != nodes.end(); ++sit)
         {
            (*sit)->traverse(it);
            if ( sit+1 != nodes.end())
               out << ", ";
         }
      }
      return false;

   case EOpFunctionCall:
      current->addCalledFunction(node->getName().c_str());
      writeFuncCall( node->getPlainName(), node, goit);
      return false; 

   case EOpLessThan:         writeFuncCall( "lessThan", node, goit); return false;
   case EOpGreaterThan:      writeFuncCall( "greaterThan", node, goit); return false;
   case EOpLessThanEqual:    writeFuncCall( "lessThanEqual", node, goit); return false;
   case EOpGreaterThanEqual: writeFuncCall( "greaterThanEqual", node, goit); return false;
   case EOpVectorEqual:      writeFuncCall( "equal", node, goit); return false;
   case EOpVectorNotEqual:   writeFuncCall( "notEqual", node, goit); return false;

   case EOpMod:
	   current->addLibFunction(EOpMod);
	   writeFuncCall( "xll_mod", node, goit, false, true);
	   return false;

   case EOpPow:           writeFuncCall( "pow", node, goit, true); return false;

   case EOpAtan2:         writeFuncCall( "atan", node, goit, true); return false;

   case EOpMin:           writeFuncCall( "min", node, goit, true); return false;
   case EOpMax:           writeFuncCall( "max", node, goit, true); return false;
   case EOpClamp:         writeFuncCall( "clamp", node, goit, true); return false;
   case EOpMix:           writeFuncCall( "mix", node, goit, true); return false;
   case EOpStep:          writeFuncCall( "step", node, goit, true); return false;
   case EOpSmoothStep:    writeFuncCall( "smoothstep", node, goit, true); return false;

   case EOpDistance:      writeFuncCall( "distance", node, goit); return false;
   case EOpDot:           writeFuncCall( "dot", node, goit); return false;
   case EOpCross:         writeFuncCall( "cross", node, goit); return false;
   case EOpFaceForward:   writeFuncCall( "faceforward", node, goit); return false;
   case EOpReflect:       writeFuncCall( "reflect", node, goit); return false;
   case EOpRefract:       writeFuncCall( "refract", node, goit); return false;
   case EOpMul:
      {
         //This should always have two arguments
         assert(node->getNodes().size() == 2);
         current->beginStatement();                     

         out << '(';
         node->getNodes()[0]->traverse(goit);
         out << " * ";
         node->getNodes()[1]->traverse(goit);
         out << ')';

         return false;
      }

      //HLSL texture functions
   case EOpTex1D:
      if (argCount == 2)
         writeTex( "texture1D", node, goit);
      else
      {
         current->addLibFunction(EOpTex1DGrad);
         writeTex( "xll_tex1Dgrad", node, goit);
      }
      return false;

   case EOpTex1DProj:     
      writeTex( "texture1DProj", node, goit); 
      return false;

   case EOpTex1DLod:
      current->addLibFunction(EOpTex1DLod);
      writeTex( "xll_tex1Dlod", node, goit); 
      return false;

   case EOpTex1DBias:
      current->addLibFunction(EOpTex1DBias);
      writeTex( "xll_tex1Dbias", node, goit); 
      return false;

   case EOpTex1DGrad:     
      current->addLibFunction(EOpTex1DGrad);
      writeTex( "xll_tex1Dgrad", node, goit); 
      return false;

   case EOpTex2D:
      if (argCount == 2)
      {  
          if(usePost120TextureLookups) {       
              writeTex( "texture", node, goit);
          } else {
              writeTex( "texture2D", node, goit);
          }
      }
      else
      {
         current->addLibFunction(EOpTex2DGrad);
         writeTex( "xll_tex2Dgrad", node, goit);
      }
      return false;

   case EOpTex2DProj:     
      if(usePost120TextureLookups) {       
          writeTex( "textureProj", node, goit);
      } else {
          writeTex( "texture2DProj", node, goit);
      }
      return false;

   case EOpTex2DLod:      
      current->addLibFunction(EOpTex2DLod);
      writeTex( "xll_tex2Dlod", node, goit); 
      return false;

   case EOpTex2DBias:  
      current->addLibFunction(EOpTex2DBias);
      writeTex( "xll_tex2Dbias", node, goit); 
      return false;

   case EOpTex2DGrad:  
      current->addLibFunction(EOpTex2DGrad);
      writeTex( "xll_tex2Dgrad", node, goit); 
      return false;

   case EOpTex3D:
      if (argCount == 2)
      {
         if (usePost120TextureLookups) {
            writeTex( "texture", node, goit);
         } else {
            writeTex( "texture3D", node, goit);
         }
      }
      else
      {
         current->addLibFunction(EOpTex3DGrad);
         writeTex( "xll_tex3Dgrad", node, goit);            
      }
      return false;

   case EOpTex3DProj:    
      writeTex( "texture3DProj", node, goit); 
      return false;

   case EOpTex3DLod:     
      current->addLibFunction(EOpTex3DLod);
      writeTex( "xll_tex3Dlod", node, goit); 
      return false;

   case EOpTex3DBias:     
      current->addLibFunction(EOpTex3DBias);
      writeTex( "xll_tex3Dbias", node, goit); 
      return false;

   case EOpTex3DGrad:    
      current->addLibFunction(EOpTex3DGrad);
      writeTex( "xll_tex3Dgrad", node, goit); 
      return false;

   case EOpTexCube:
      if (argCount == 2)
	  {
          if (usePost120TextureLookups)
              writeTex("texture", node, goit);
          else
              writeTex("textureCube", node, goit);
	  }
      else
      {
         current->addLibFunction(EOpTexCubeGrad);
         writeTex( "xll_texCUBEgrad", node, goit);
      }
      return false;
   case EOpTexCubeProj:   
      writeTex( "textureCubeProj", node, goit); 
      return false;

   case EOpTexCubeLod:    
      current->addLibFunction(EOpTexCubeLod); 
      writeTex( "xll_texCUBElod", node, goit); 
      return false;

   case EOpTexCubeBias:   
      current->addLibFunction(EOpTexCubeBias); 
      writeTex( "xll_texCUBEbias", node, goit); 
      return false;

   case EOpTexCubeGrad:   
      current->addLibFunction(EOpTexCubeGrad);
      writeTex( "xll_texCUBEgrad", node, goit); 
      return false;

   case EOpTexRect:
	   writeTex( "texture2DRect", node, goit);
	   return false;
	   
   case EOpTexRectProj:
	   writeTex( "texture2DRectProj", node, goit);
	   return false;
		   
   case EOpShadow2D:		   
		current->addLibFunction(EOpShadow2D);
		writeTex("xll_shadow2D", node, goit);
		return false;
   case EOpShadow2DProj:
	   current->addLibFunction(EOpShadow2DProj);
	   writeTex("xll_shadow2Dproj", node, goit);
	   return false;
	case EOpTex2DArray:
		current->addLibFunction(EOpTex2DArray);
		writeTex("xll_tex2DArray", node, goit);
		return false;
	case EOpTex2DArrayLod:
		current->addLibFunction(EOpTex2DArrayLod);
		writeTex("xll_tex2DArrayLod", node, goit);
		return false;
	case EOpTex2DArrayBias:
		current->addLibFunction(EOpTex2DArrayBias);
		writeTex("xll_tex2DArrayBias", node, goit);
		return false;
		   
   case EOpModf:
      current->addLibFunction(EOpModf);
      writeFuncCall( "xll_modf", node, goit, false, true);
      break;

   case EOpLdexp:
      current->addLibFunction(EOpLdexp);
      writeFuncCall( "xll_ldexp", node, goit, false, true);
      break;

   case EOpSinCos:        
      current->addLibFunction(EOpSinCos);
      writeFuncCall ( "xll_sincos", node, goit, false, true);
      break;

   case EOpLit:
      current->addLibFunction(EOpLit);
      writeFuncCall( "xll_lit", node, goit, false, true);
      break;

   default: goit->infoSink.info << "Bad aggregation op\n";
   }


   return false;
}


bool TGlslOutputTraverser::traverseLoop( bool preVisit, TIntermLoop *node, TIntermTraverser *it )
{
   TGlslOutputTraverser* goit = static_cast<TGlslOutputTraverser*>(it);
   GlslFunction *current = goit->current;
   std::stringstream& out = current->getActiveOutput();

   current->beginStatement();

   TLoopType loopType = node->getType();
   if (loopType == ELoopFor)
   {
      // Process for loop, initial statement was promoted outside the loop
      out << "for ( ; ";
      if (node->getCondition())
         node->getCondition()->traverse(goit);
      out << "; ";
      if (node->getExpression())
         node->getExpression()->traverse(goit);
      out << ") ";
      current->beginBlock();
      if (node->getBody())
         node->getBody()->traverse(goit);
      current->endBlock();
   }
   else if (loopType == ELoopWhile)
      {
         // Process while loop
         out << "while ( ";
      node->getCondition()->traverse(goit);
         out << " ) ";
         current->beginBlock();
         if (node->getBody())
            node->getBody()->traverse(goit);
         current->endBlock();
      }
      else
      {
      assert(loopType == ELoopDoWhile);
         // Process do loop
         out << "do ";
         current->beginBlock();
         if (node->getBody())
            node->getBody()->traverse(goit);
         current->endBlock();
         current->indent();
         out << "while ( ";
      node->getCondition()->traverse(goit);
         out << " )\n";
      }
   return false;
}


bool TGlslOutputTraverser::traverseBranch( bool preVisit, TIntermBranch *node,  TIntermTraverser *it )
{
   TGlslOutputTraverser* goit = static_cast<TGlslOutputTraverser*>(it);
   GlslFunction *current = goit->current;
   std::stringstream& out = current->getActiveOutput();

   current->beginStatement();

   switch (node->getFlowOp())
   {
   case EOpKill:      out << "discard";           break;
   case EOpBreak:     out << "break";          break;
   case EOpContinue:  out << "continue";       break;
   case EOpReturn:    out << "return ";         break;
   default:           assert(0); break;
   }

   if (node->getExpression())
   {
      node->getExpression()->traverse(it);
   }

   return false;
}


GlslStruct *TGlslOutputTraverser::createStructFromType (TType *type)
{
   GlslStruct *s = 0;
   std::string structName = type->getTypeName().c_str();

   //check for anonymous structures
   if (structName.size() == 0)
   {
      std::stringstream temp;
      TTypeList &tList = *type->getStruct();

      //build a mangled name that is hopefully mangled enough to prevent collisions
      temp << "anonStruct";

      for (TTypeList::iterator it = tList.begin(); it != tList.end(); it++)
      {
         TString typeString;
         it->type->buildMangledName(typeString);
         temp << "_" << typeString.c_str();
      }

      structName = temp.str();
   }

   //try to find the struct name
   if ( structMap.find(structName) == structMap.end() )
   {
      //This is a new structure, build a type for it
      TTypeList &tList = *type->getStruct();

      s = new GlslStruct(structName, type->getLine());

      for (TTypeList::iterator it = tList.begin(); it != tList.end(); it++)
      {
         TPrecision prec = m_UsePrecision ? it->type->getPrecision() : EbpUndefined;
         if(it->type->hasSemantic() && m_UsePrecision)
         {
            const char* str = it->type->getSemantic().c_str();
            int         len = it->type->getSemantic().length();

            extern bool IsPositionSemantics(const char* sem, int len);
            if(IsPositionSemantics(str, len))
                prec = EbpHigh;
         }
         StructMember* m = new StructMember( it->type->getFieldName().c_str(),
                                            (it->type->hasSemantic()) ? it->type->getSemantic().c_str() : "",
                                             translateType(it->type),
                                             EqtNone,
                                             prec,
                                             it->type->isArray() ? it->type->getArraySize() : 0,
                                            (it->type->getBasicType() == EbtStruct) ? createStructFromType(it->type) : NULL,
                                             structName);
         s->addMember(*m);
		 delete m;
      }

      //add it to the list
      structMap[structName] = s;
      structList.push_back(s);
   }
   else
   {
      s = structMap[structName];
   }

   return s;
}

}
