#ifndef __SOURCELOC_H
#define __SOURCELOC_H

namespace hlslang {

typedef struct 
{
    const char* file;
    int line;
} TSourceLoc;


} // namespace

#ifdef __cplusplus
extern "C" {
#endif

extern const hlslang::TSourceLoc gNullSourceLoc;

#ifdef __cplusplus
}
#endif


#ifdef __cplusplus
#include <sstream>

namespace hlslang {

void SetLineNumber(TSourceLoc line, TSourceLoc& outLine);


template<typename StreamType>
StreamType& operator<<(StreamType& s, const TSourceLoc& l)
{
	// report location as (line) or file(line)
	if(l.file)
	{
	    s << l.file;
	}
	
	s << '(';
    if(l.line > 0)
    {
        s << l.line;
    }
    else
    {
        s << '?';
    }    
    s << ')';
    
    return(s);
} 

inline void OutputLineDirective(std::stringstream& s, const TSourceLoc& l)
{
	s << "#line " << l.line;
	
	// GLSL spec (1.10 & 1.20) doesn't allow printing file name here; only an integer "string number".
	//if(l.file)
	//{
	//	s << " // ";
	//	s << l.file;
	//}
	
	s << '\n';
}

#endif

}

#endif /* __SOURCELOC_H */ 
