// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#pragma once

#include "mslCommon.h"

namespace hlslang {
namespace MetalCodeGen {
    
class MslStruct;

class StructMember : public MslSymbolOrStructMemberBase
{
public:
	StructMember(const std::string &n, const std::string &s, EMslSymbolType t, EMslQualifier q, TPrecision prec, int as, MslStruct* st, const std::string &bn);
	const MslStruct* getStruct() const { return structType; }
	MslStruct* getStruct() { return structType; }

	MslStruct* structType; // NULL if type != EgstStruct
};

class MslStruct
{
public:
	MslStruct (const std::string &n, const TSourceLoc& line) : name(n), m_Line(line) {}

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

}}

