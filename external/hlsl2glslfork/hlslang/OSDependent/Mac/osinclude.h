// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#ifndef __OSINCLUDE_H
#define __OSINCLUDE_H

//#include <Carbon/Carbon.h>
#include <assert.h>
#include <pthread.h>
#include <strings.h>

#define min(X,Y) ((X) < (Y) ? X : Y)
#define _vsnprintf vsnprintf
#define _stricmp strcasecmp

//
// Thread Local Storage Operations
//
#define OS_INVALID_TLS_INDEX 0

typedef pthread_key_t OS_TLSIndex;

OS_TLSIndex     OS_AllocTLSIndex();
bool            OS_SetTLSValue(OS_TLSIndex nIndex, void *lpvValue);
bool            OS_FreeTLSIndex(OS_TLSIndex nIndex);
inline void*    OS_GetTLSValue(OS_TLSIndex nIndex)
{
    return pthread_getspecific(nIndex);
}

#endif // __OSINCLUDE_H
