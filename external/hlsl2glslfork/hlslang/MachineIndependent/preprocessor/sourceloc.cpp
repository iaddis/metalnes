#include "sourceloc.h"
#include "../../Include/Common.h"

namespace hlslang {

void SetLineNumber(TSourceLoc line, TSourceLoc& outLine)
{
	outLine.file = NULL;
	outLine.line = line.line;
	
	if (line.file && line.file[0])
	{
		// GLSL does not permit quoted strings in #line directives
		
		if(line.file[0] == '"')
		{
			TString stripped(line.file + 1);
			size_t len = stripped.size();
			if(stripped[len - 1] == '"')
			{
				stripped.resize(len - 1);
			}
			
			outLine.file = NewPoolTString(stripped.c_str())->c_str();
		}
		else
		{
			outLine.file = NewPoolTString(line.file)->c_str();
		}
	}
}

}
