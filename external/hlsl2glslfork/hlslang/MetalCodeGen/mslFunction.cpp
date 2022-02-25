// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "mslFunction.h"

namespace hlslang {
namespace MetalCodeGen {


MslFunction::MslFunction( const std::string &n, const std::string &m, EMslSymbolType type, TPrecision prec, const std::string &s, const TSourceLoc& l)
: name(n)
, mangledName(m)
, returnType(type)
, precision(prec)
, semantic(s)
, line(l)
, structPtr(0)
, depth(0)
, inStatement(false)
{ 
	active = new std::stringstream();
	active->setf ( std::stringstream::showpoint );
	active->unsetf(std::ios::fixed);
	active->unsetf(std::ios::scientific);
	active->precision (6);
	pushDepth(0);
}


MslFunction::~MslFunction()
{
	popDepth();
	delete active;
	for (std::vector<MslSymbol*>::iterator it = symbols.begin(); it < symbols.end(); it++)
	{
		(*it)->releaseRef ();
		if ((*it)->getRef() == 0)
		{
			delete *it;
		}
	}
}

void MslFunction::pushDepth(int d) { this->depth.push_back(d); }
void MslFunction::popDepth() { depth.pop_back(); }

bool MslFunction::hasSymbol( int id ) const
{
	if (symbolIdMap.find(id) != symbolIdMap.end())
		return true;
	return false;
}


MslSymbol& MslFunction::getSymbol( int id )
{
	return *symbolIdMap[id];
}


void MslFunction::mangleSymbolName (MslSymbol *sym)
{
	while (!symbolNameMap.empty() && symbolNameMap.find(sym->getName()) != symbolNameMap.end())
	{
		sym->mangleName();
	}
	symbolNameMap[sym->getName()] = sym;
}


void MslFunction::addSymbol (MslSymbol *sym)
{
	sym->addRef();

	mangleSymbolName(sym);

	symbols.push_back( sym);
	symbolIdMap[sym->getId()] = sym;
}


void MslFunction::addParameter (MslSymbol *sym)
{
	sym->addRef();

	sym->setIsParameter(true);

	mangleSymbolName(sym);

	symbols.push_back( sym);
	symbolIdMap[sym->getId()] = sym;
	parameters.push_back( sym);
}


std::string MslFunction::getPrototype() const
{
	std::stringstream out;

	writeType (out, returnType, structPtr, precision);
	out << " " << name << "( ";
	
	for (std::vector<MslSymbol*>::const_iterator it = parameters.begin(), itEnd = parameters.end(); it != itEnd; ++it)
	{
		if (it != parameters.begin())
			out << ", ";
		(*it)->writeDecl(out,MslSymbol::kWriteDeclDefault);
	}
	
	out << " )";

	return out.str();
}


void MslFunction::addNeededExtensions (ExtensionSet& extensions, ETargetVersion version) const
{
	for (size_t i = 0; i < symbols.size(); ++i)
	{
		const MslSymbol* s = symbols[i];
		if (s->getType() == EgstSampler2DShadow && version == ETargetGLSL_ES_100)
		{
			extensions.insert("GL_EXT_shadow_samplers");
		}
		if (s->getType() == EgstSampler2DArray)
		{
			if (version == ETargetGLSL_ES_100)
				extensions.insert("GL_NV_texture_array");
			else if (version < ETargetGLSL_ES_300)
				extensions.insert("GL_EXT_texture_array");
		}
	}
}
    
}}
