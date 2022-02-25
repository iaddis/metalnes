// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#ifndef GLSL_FUNCTION_H
#define GLSL_FUNCTION_H

#include <set>

#include "glslCommon.h"
#include "glslStruct.h"
#include "glslSymbol.h"

namespace hlslang {

/// Represents all the data necessary to represent a
/// function for the linker to create a complete output program.
class GlslFunction 
{
public:
	GlslFunction (const std::string& n, const std::string& m, EGlslSymbolType type, TPrecision precision, const std::string &s, const TSourceLoc& line);
	virtual ~GlslFunction();

	void addSymbol( GlslSymbol *sym );   
	void addParameter( GlslSymbol *sym );

	bool isGlobalScopeFunction() const { return name == "__global__"; }

	bool hasSymbol( int id ) const;
	GlslSymbol& getSymbol( int id );

	std::string getPrototype() const;

	/// Returns the active scope
	std::string getCode() const { return active->str(); }

	int getParameterCount() { return (int)parameters.size();}   
	GlslSymbol* getParameter( int i ) { return parameters[i];}

	void addCalledFunction( const std::string& func ) { calledFunctions.insert(func); }
	const std::set<std::string>& getCalledFunctions() const  { return calledFunctions; }

	void addLibFunction( TOperator op ) { libFunctions.insert( op); }
	const std::set<TOperator>& getLibFunctions() const { return libFunctions; }

	const std::vector<GlslSymbol*>& getSymbols() const { return symbols; }

	void increaseDepth() { depth.back()++; }   
	void decreaseDepth() { depth.back() = depth.back() ? depth.back()-1 : depth.back(); }

	void pushDepth(int depth);
	void popDepth();

	void indent( std::stringstream &s ) { for (int ii = 0; ii < depth.back(); ii++) s << "    "; }
	void indent() { indent(*active); }

	void beginBlock( bool brace = true) { if (brace) *active << "{\n"; increaseDepth(); inStatement = false; }
	void endBlock() { endStatement(); decreaseDepth(); indent(); *active << "}\n";  }

	void beginStatement() { if (!inStatement) { indent(); inStatement = true;}}
	void endStatement() { if (inStatement) { *active << ";\n"; inStatement = false;}}

	const std::string& getName() const { return name; }
	const std::string& getMangledName() const { return mangledName; }

	EGlslSymbolType getReturnType() const { return returnType; }
	TPrecision getPrecision() const { return precision; }
	const std::string& getSemantic() const { return semantic; }    
	GlslStruct* getStruct() { return structPtr; }   
	void setStruct( GlslStruct *s ) { structPtr = s;}
	void setActiveOutput(std::stringstream* output) { active = output; }
	std::stringstream& getActiveOutput () { return *active; }
	const TSourceLoc& getLine() const { return line; }

	typedef std::set<std::string> ExtensionSet;
	void addNeededExtensions (ExtensionSet& extensions, ETargetVersion version) const;

private:
	void mangleSymbolName (GlslSymbol *sym);
	
private:

	// Function info
	std::string name;
	std::string mangledName;
	EGlslSymbolType returnType;
	TPrecision precision;
	std::string semantic;
	TSourceLoc line;

	// Structure return value
	GlslStruct *structPtr;  

	// Present indent depth
	std::vector<int> depth; 

	// These are the symbols referenced
	std::vector<GlslSymbol*> symbols;
	std::map<std::string,GlslSymbol*> symbolNameMap;
	std::map<int,GlslSymbol*> symbolIdMap;
	std::vector<GlslSymbol*> parameters;

	// Functions called by this function
	std::set<std::string> calledFunctions;

	// Built-in functions needing the support lib that were called
	std::set<TOperator> libFunctions;

	// Stores the active output of the function
	std::stringstream* active;

	bool inStatement;
};

}

#endif //GLSL_FUNCTION_H

