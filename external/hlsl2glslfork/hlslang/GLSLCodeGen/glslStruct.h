// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#ifndef GLSL_STRUCT_H
#define GLSL_STRUCT_H

#include "glslCommon.h"

namespace hlslang {


class GlslStruct;

class StructMember : public GlslSymbolOrStructMemberBase
{
public:
	StructMember(const std::string &n, const std::string &s, EGlslSymbolType t, EGlslQualifier q, TPrecision prec, int as, GlslStruct* st, const std::string &bn);
	const GlslStruct* getStruct() const { return structType; }
	GlslStruct* getStruct() { return structType; }

	GlslStruct* structType; // NULL if type != EgstStruct
};

class GlslStruct
{
public:
	GlslStruct (const std::string &n, const TSourceLoc& line) : name(n), m_Line(line) {}

	const std::string& getName() const { return name; }
	const TSourceLoc& getLine() const { return m_Line; }

	void addMember(const StructMember& m) { memberList.push_back(m); }
	const StructMember& getMember( int which ) const { return memberList[which]; }
	int memberCount() const { return int(memberList.size()); }

	std::string getDecl() const;

private:
	std::vector<StructMember> memberList;
	std::string name;
	TSourceLoc m_Line;
};

}

#endif //GLSL_STRUCT_H
