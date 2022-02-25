// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "mslStruct.h"

namespace hlslang {
namespace MetalCodeGen {


StructMember::StructMember(const std::string &n, const std::string &s, EMslSymbolType t, EMslQualifier q, TPrecision prec, int as, MslStruct* st, const std::string &bn) :
MslSymbolOrStructMemberBase(n, s, t, q, prec, as, bn),
structType(st)
{
}

std::string MslStruct::getDecl() const
{
	std::stringstream out;
	
	out << "struct " << name << " {\n";
	
	for (std::vector<StructMember>::const_iterator it = memberList.begin(); it != memberList.end(); ++it) 
	{
		out << "    ";
		writeType (out, it->type, it->structType, it->precision);
		out << " " << it->name;
		
		if (it->arraySize > 0)
			out << "[" << it->arraySize << "]";
		
		out << ";\n";
	}
	
	out << "};\n";
	
	return out.str();
}
    
}}
