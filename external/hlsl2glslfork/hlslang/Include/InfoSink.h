// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#ifndef _INFOSINK_INCLUDED_
#define _INFOSINK_INCLUDED_

#include "../Include/Common.h"
#include <math.h>

namespace hlslang {

// Returns the fractional part of the given floating-point number.
inline float fractionalPart(float f) {
	float intPart = 0.0f;
	return modff(f, &intPart);
}

//
// TPrefixType is used to centralize how info log messages start.
// See below.
//
enum TPrefixType
{
   EPrefixNone,
   EPrefixWarning,
   EPrefixError,
   EPrefixInternalError,
};

//
// Encapsulate info logs for all objects that have them.
//
// The methods are a general set of tools for getting a variety of
// messages and types inserted into the log.
//
class TInfoSinkBase
{
public:
   TInfoSinkBase()
   {
   }
   void erase()
   {
      sink.erase();
   }
   TInfoSinkBase& operator<<(const std::string& t)
   {
      append(t); return *this;
   }
   TInfoSinkBase& operator<<(char c)
   {
      append(1, c); return *this;
   }
   TInfoSinkBase& operator<<(const char* s)
   {
      append(s); return *this;
   }
   TInfoSinkBase& operator<<(int n)
   {
      append(String(n)); return *this;
   }
   TInfoSinkBase& operator<<(const unsigned int n)
   {
      append(String(n)); return *this;
   }
	
	// Make sure floats are written with correct precision.
	TInfoSinkBase& operator<<(float f) {
		// Make sure that at least one decimal point is written. If a number
		// does not have a fractional part, the default precision format does
		// not write the decimal portion which gets interpreted as integer by
		// the compiler.
		std::ostringstream stream;
		if (fractionalPart(f) == 0.0f) {
			stream.precision(1);
			stream << std::showpoint << std::fixed << f;
		} else {
			stream.unsetf(std::ios::fixed);
			stream.unsetf(std::ios::scientific);
			stream.precision(6);
			stream << f;
		}
		sink.append(stream.str());
		return *this;
	}
	
   TInfoSinkBase& operator+(const std::string& t)
   {
      append(t); return *this;
   }
   TInfoSinkBase& operator+(const TString& t)
   {
      append(t); return *this;
   }
   TInfoSinkBase& operator<<(const TString& t)
   {
      append(t); return *this;
   }
   TInfoSinkBase& operator+(const char* s)
   {
      append(s); return *this;
   }
   const char* c_str() const
   {
      return sink.c_str();
   }
   void prefix(TPrefixType message)
   {
      switch (message)
      {
      case EPrefixNone:                                      break;
      case EPrefixWarning:       append("WARNING: ");        break;
      case EPrefixError:         append("ERROR: ");          break;
      case EPrefixInternalError: append("INTERNAL ERROR: "); break;
      default:                   append("UNKOWN ERROR: ");   break;
      }
   }
   void location(TSourceLoc loc)
   {
      std::stringstream s;
      s << loc;
      append(s.str());
      append(": ");
   }
   void message(TPrefixType message, const char* s)
   {
      prefix(message);
      append(s);
      append("\n");
   }
   void message(TPrefixType message, const char* s, TSourceLoc loc)
   {
      location(loc);
      prefix(message);
      append(s);
      append("\n");
   }

   bool IsEmpty() const { return sink.empty(); }

private:
   void append(const char *s); 

   void append(int count, char c);
   void append(const std::string& t);
   void append(const TString& t);

   void checkMem(size_t growth)
   {
      if (sink.capacity() < sink.size() + growth + 2)
         sink.reserve(sink.capacity() +  sink.capacity() / 2);
   }
   void appendToStream(const char* s);
   std::string sink;
};

class TInfoSink
{
public:
   TInfoSinkBase info;
   TInfoSinkBase debug;
};

} // namespace

#endif // _INFOSINK_INCLUDED_

