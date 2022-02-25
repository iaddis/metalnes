// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.

#ifndef __OSINCLUDE_H
#define __OSINCLUDE_H

//
// This file contains any Linux specific functions.
//

#if !(defined(EMSCRIPTEN))
#error Trying to include a Emscripten specific file in a non-Emscripten build.
#endif

#include <pthread.h>
#include <semaphore.h>
#include <assert.h>
#include <errno.h>
#include "Include/InitializeGlobals.h"
#include "Include/PoolAlloc.h"

#define _vsnprintf vsnprintf
#define _stricmp strcasecmp

void DetachThreadLinux(void *);

//
// Thread Local Storage Operations
//
typedef unsigned int OS_TLSIndex;
#define OS_INVALID_TLS_INDEX 0xFFFFFFFF

OS_TLSIndex OS_AllocTLSIndex();
bool        OS_SetTLSValue(OS_TLSIndex nIndex, void *lpvValue);
bool        OS_FreeTLSIndex(OS_TLSIndex nIndex); 


inline void * OS_GetTLSValue(OS_TLSIndex nIndex)
{
	//
	// This function should return 0 if nIndex is invalid.
	//
	assert(nIndex != OS_INVALID_TLS_INDEX);
	return pthread_getspecific(nIndex); 
}

#endif // __OSINCLUDE_H
