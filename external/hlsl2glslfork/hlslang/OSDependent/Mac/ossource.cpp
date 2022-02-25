// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "osinclude.h"


//
// Thread Local Storage Operations
//
OS_TLSIndex OS_AllocTLSIndex()
{
    OS_TLSIndex key;
    if (pthread_key_create(&key, NULL) != 0)
    {
        assert(0 && "OS_AllocTLSIndex(): Unable to allocate Thread Local Storage");
        return 0;
    }
    
    return key;
}


bool OS_SetTLSValue(OS_TLSIndex nIndex, void *lpvValue)
{
    if (pthread_setspecific(nIndex, lpvValue) != 0)
    {
		assert(0 && "OS_SetTLSValue(): Invalid TLS Key");
		return false;
	}

	return true;
}


bool OS_FreeTLSIndex(OS_TLSIndex nIndex)
{
    if (pthread_key_delete(nIndex) != 0)
    {
		assert(0 && "OS_SetTLSValue(): Invalid TLS Index");
		return false;
	}

	return true;
}
