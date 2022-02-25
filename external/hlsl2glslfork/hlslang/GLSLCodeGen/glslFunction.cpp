// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "glslFunction.h"

namespace hlslang {

GlslFunction::GlslFunction( const std::string &n, const std::string &m, EGlslSymbolType type, TPrecision prec, const std::string &s, const TSourceLoc& l)
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


GlslFunction::~GlslFunction()
{
	popDepth();
	delete active;
	for (std::vector<GlslSymbol*>::iterator it = symbols.begin(); it < symbols.end(); it++)
	{
		(*it)->releaseRef ();
		if ((*it)->getRef() == 0)
		{
			delete *it;
		}
	}
}

void GlslFunction::pushDepth(int d) { this->depth.push_back(d); }
void GlslFunction::popDepth() { depth.pop_back(); }

bool GlslFunction::hasSymbol( int id ) const
{
	if (symbolIdMap.find(id) != symbolIdMap.end())
		return true;
	return false;
}


GlslSymbol& GlslFunction::getSymbol( int id )
{
	return *symbolIdMap[id];
}


void GlslFunction::mangleSymbolName (GlslSymbol *sym)
{
	while (!symbolNameMap.empty() && symbolNameMap.find(sym->getName()) != symbolNameMap.end())
	{
		sym->mangleName();
	}
	symbolNameMap[sym->getName()] = sym;
}


void GlslFunction::addSymbol (GlslSymbol *sym)
{
	sym->addRef();

	mangleSymbolName(sym);

	symbols.push_back( sym);
	symbolIdMap[sym->getId()] = sym;
}


void GlslFunction::addParameter (GlslSymbol *sym)
{
	sym->addRef();

	sym->setIsParameter(true);

	mangleSymbolName(sym);

	symbols.push_back( sym);
	symbolIdMap[sym->getId()] = sym;
	parameters.push_back( sym);
}


std::string GlslFunction::getPrototype() const
{
	std::stringstream out;

	writeType (out, returnType, structPtr, precision);
	out << " " << name << "( ";
	
	for (std::vector<GlslSymbol*>::const_iterator it = parameters.begin(), itEnd = parameters.end(); it != itEnd; ++it)
	{
		if (it != parameters.begin())
			out << ", ";
		(*it)->writeDecl(out,GlslSymbol::kWriteDeclDefault);
	}
	
	out << " )";

	return out.str();
}


void GlslFunction::addNeededExtensions (ExtensionSet& extensions, ETargetVersion version) const
{
	for (size_t i = 0; i < symbols.size(); ++i)
	{
		const GlslSymbol* s = symbols[i];
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

}
