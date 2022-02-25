// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#ifndef _SYMBOL_TABLE_INCLUDED_
#define _SYMBOL_TABLE_INCLUDED_

//
// Symbol table for parsing.  Has these design characteristics:
//
// * Same symbol table can be used to compile many shaders, to preserve
//   effort of creating and loading with the large numbers of built-in
//   symbols.
//
// * Name mangling will be used to give each function a unique name
//   so that symbol table lookups are never ambiguous.  This allows
//   a simpler symbol table structure.
//
// * Pushing and popping of scope, so symbol table will really be a stack 
//   of symbol tables.  Searched from the top, with new inserts going into
//   the top.
//
// * Constants:  Compile time constant symbols will keep their values
//   in the symbol table.  The parser can substitute constants at parse
//   time, including doing constant folding and constant propagation.
//
// * No temporaries:  Temporaries made from operations (+, --, .xy, etc.)
//   are tracked in the intermediate representation, not the symbol table.
//

#include "../Include/Common.h"
#include "../Include/intermediate.h"
#include "../Include/InfoSink.h"
 
namespace hlslang {

//
// Symbol base class.  (Can build functions or variables out of these...)
//
class TSymbol {    
public:
	POOL_ALLOCATOR_NEW_DELETE(GlobalPoolAllocator)
	TSymbol(const TString *n) :  name(n), info(0), global(false) { }
	TSymbol(const TString *n, const TTypeInfo *i) :  name(n), info(i), global(false) { }
	virtual ~TSymbol() { /* don't delete name, it's from the pool */ }
	const TString& getName() const { return *name; }
	const TTypeInfo* getInfo() const { return info; }
	void setInfo( const TTypeInfo *i) {  info = i; }
	virtual const TString& getMangledName() const { return getName(); }
	virtual bool isFunction() const { return false; }
	virtual bool isVariable() const { return false; }
	void setUniqueId(int id) { uniqueId = id; }
	int getUniqueId() const { return uniqueId; }
	bool isGlobal() const { return global; }
	void setGlobal(bool g) { global = g; }
	virtual void dump(TInfoSink &infoSink) const = 0;	
	TSymbol(const TSymbol&);
	virtual TSymbol* clone(TStructureMap& remapper) = 0;

protected:
	bool global;
	const TString *name;
	const TTypeInfo *info;
	unsigned int uniqueId;      // For real comparing during code generation
};

//
// Variable class, meaning a symbol that's not a function.
// 
// There could be a separate class heirarchy for Constant variables;
// Only one of int, bool, or float, (or none) is correct for
// any particular use, but it's easy to do this way, and doesn't
// seem worth having separate classes, and "getConst" can't simply return
// different values for different types polymorphically, so this is 
// just simple and pragmatic.
//
class TVariable : public TSymbol {
public:
	TVariable(const TString *name, const TType& t, bool uT = false ) : TSymbol(name), type(t), userType(uT), arrayInformationType(0), constValue(0)
	{
		changeQualifier(type.getQualifier());
	}
	
	TVariable(const TString *name, const TTypeInfo* info, const TType& t, bool uT = false ) : TSymbol(name, info), type(t), userType(uT), arrayInformationType(0), constValue(0)
	{
		changeQualifier(type.getQualifier());
	}
	
	virtual ~TVariable() { }
	
	virtual bool isVariable() const { return true; }    
	TType& getType() { return type; }    
	const TType& getType() const { return type; }
	bool isUserType() const { return userType; }
	void changeQualifier(TQualifier qualifier) { type.changeQualifier(qualifier); }
	void updateArrayInformationType(TType *t) { arrayInformationType = t; }
	TType* getArrayInformationType() { return arrayInformationType; }
	
	virtual void dump(TInfoSink &infoSink) const;

	TVariable(const TVariable&, TStructureMap& remapper); // copy constructor
	virtual TVariable* clone(TStructureMap& remapper);

	TIntermConstant* constValue;
	
protected:
	TType type;
	bool userType;
	TType *arrayInformationType;  // this is used for updating maxArraySize in all the references to a given symbol
};

//
// The function sub-class of symbols and the parser will need to
// share this definition of a function parameter.
//
struct TParameter 
{
	TString *name;
	const TTypeInfo *info;
	TType* type;
	void copyParam(const TParameter& param, TStructureMap& remapper) 
	{
		name = NewPoolTString(param.name->c_str());      
		info = param.info; //sharing
		type = param.type->clone(remapper);
	}
	static TString* NullSemantic;
};

//
// The function sub-class of a symbol.  
//
class TFunction : public TSymbol 
{
public:
	TFunction(TOperator o) :
	TSymbol(0),
	returnType(TType(EbtVoid, EbpUndefined)),
	op(o),
	defined(false) { }
	TFunction(const TString *name, TType& retType, TOperator tOp = EOpNull) : 
	TSymbol(name), 
	returnType(retType),
	mangledName(*name + '('),
	op(tOp),
	defined(false) { }
	TFunction(const TString *name, const TTypeInfo* info, TType& retType, TOperator tOp = EOpNull) : 
	TSymbol(name, info), 
	returnType(retType),
	mangledName(*name + '('),
	op(tOp),
	defined(false) { }
	virtual ~TFunction();
	virtual bool isFunction() const { return true; }    
    
	void addParameter(TParameter& p) 
	{ 
		parameters.push_back(p);
		mangledName += p.type->getMangledName();
	}
    
	const TString& getMangledName() const { return mangledName; }
	const TType& getReturnType() const { return returnType; }
	void relateToOperator(TOperator o) { op = o; }
	TOperator getBuiltInOp() const { return op; }
	void setDefined() { defined = true; }
	bool isDefined() const { return defined; }
	
	int getParamCount() const { return static_cast<int>(parameters.size()); }    
	TParameter& operator [](int i)       { return parameters[i]; }
	const TParameter& operator [](int i) const { return parameters[i]; }
    
	virtual void dump(TInfoSink &infoSink) const;
	TFunction(const TFunction&, TStructureMap& remapper);
	virtual TFunction* clone(TStructureMap& remapper);
    
protected:
	typedef TVector<TParameter> TParamList;
	TParamList parameters;
	TType returnType;
	TString mangledName;
	TOperator op;
	bool defined;
};


class TSymbolTableLevel 
{
public:
	POOL_ALLOCATOR_NEW_DELETE(GlobalPoolAllocator)
	TSymbolTableLevel() { }
	~TSymbolTableLevel();
    
	bool insert(TSymbol& symbol);
	
	TSymbol* find(const TString& name) const
	{
		tLevel::const_iterator it = level.find(name);
		if (it == level.end())
			return 0;
		else
			return (*it).second;
	}
	
	// vector might be best switched to a special allocator
	TSymbol* findCompatible( const TFunction *call, bool &ambiguous) const;
	
	void relateToOperator(const char* name, TOperator op);
	void dump(TInfoSink &infoSink) const;
	TSymbolTableLevel* clone(TStructureMap& remapper);
    
protected:
	typedef std::map<TString, TSymbol*, std::less<TString>, pool_allocator<std::pair<const TString, TSymbol*> > > tLevel;
	typedef const tLevel::value_type tLevelPair;
	typedef std::pair<tLevel::iterator, bool> tInsertResult;
	
	tLevel level;
};


class TSymbolTable {
public:
	TSymbolTable() : uniqueId(0)
	{
		//
		// The symbol table cannot be used until push() is called, but
		// the lack of an initial call to push() can be used to detect
		// that the symbol table has not been preloaded with built-ins.
		//
	}

	TSymbolTable(TSymbolTable& symTable)
	{
		table.push_back(symTable.table[0]);
		uniqueId = symTable.uniqueId;
	}

	~TSymbolTable()
	{
		// level 0 is always built In symbols, so we never pop that out
		while (table.size() > 1)
		pop();
	}

	//
	// When the symbol table is initialized with the built-ins, there should
	// 'push' calls, so that built-ins are at level 0 and the shader
	// globals are at level 1.
	//
	bool isEmpty() const { return table.size() == 0; }
	bool atBuiltInLevel() const { return atSharedBuiltInLevel() || atDynamicBuiltInLevel(); }
	bool atSharedBuiltInLevel() const { return table.size() == 1; }	
	bool atGlobalLevel() const { return table.size() <= 3; }
	void push() 
	{ 
		table.push_back(new TSymbolTableLevel);
	}

	void pop() 
	{ 
		delete table[currentLevel()]; 
		table.pop_back(); 
	}

	bool insert(TSymbol& symbol)
	{
		symbol.setGlobal(atGlobalLevel());
		symbol.setUniqueId(++uniqueId);
		return table[currentLevel()]->insert(symbol);
	}

	TSymbol* find(const TString& name, bool* builtIn = 0, bool *sameScope = 0) 
	{
		int level = currentLevel();
		TSymbol* symbol;
		do 
		{
			symbol = table[level]->find(name);
			--level;
		} while (symbol == 0 && level >= 0);
		
		level++;
		if (builtIn)
			*builtIn = level == 0;
		if (sameScope)
			*sameScope = level == currentLevel();
		return symbol;
	}

	TSymbol* findCompatible(const TFunction* call, bool *builtIn, bool &ambiguous) 
	{
		int level = currentLevel();
		TSymbol *symbol = 0;
		ambiguous = false;

		do 
		{
			symbol = table[level]->findCompatible(call, ambiguous);
			--level;
		} while ( symbol == 0 && level >= 0 && !ambiguous);
			
		level++;
		if (builtIn)
			*builtIn = level == 0;
		return symbol;
	}

	TSymbolTableLevel* getGlobalLevel() { assert(table.size() >= 3); return table[2]; }
	void relateToOperator(const char* name, TOperator op) { table[0]->relateToOperator(name, op); }
	void dump(TInfoSink &infoSink) const;
	void copyTable(const TSymbolTable& copyOf);

protected:    
	int currentLevel() const { return static_cast<int>(table.size()) - 1; }
	bool atDynamicBuiltInLevel() const { return table.size() == 2; }

	std::vector<TSymbolTableLevel*> table;
	int uniqueId;     // for unique identification in code generation
};

}

#endif // _SYMBOL_TABLE_INCLUDED_
