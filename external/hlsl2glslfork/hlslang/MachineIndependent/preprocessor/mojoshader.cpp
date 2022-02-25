// Stripped down code from Mojoshader, originally under zlib license.

/**
 * MojoShader; generate shader programs from bytecode of compiled
 *  Direct3D shaders.
 *
 * Please see the file LICENSE.txt in the source's root directory.
 *
 *  This file written by Ryan C. Gordon.
 */

#define __MOJOSHADER_INTERNAL__ 1
#include "mojoshader_internal.h"

// Convenience functions for allocators...
#if !MOJOSHADER_hlslang_FORCE_ALLOCATOR
void *MOJOSHADER_hlslang_internal_malloc(int bytes, void *d) { return malloc(bytes); }
void MOJOSHADER_hlslang_internal_free(void *ptr, void *d) { free(ptr); }
#endif

MOJOSHADER_hlslang_error MOJOSHADER_hlslang_out_of_mem_error = {
    "Out of memory", NULL, MOJOSHADER_hlslang_POSITION_NONE
};


// end of mojoshader.c ...

