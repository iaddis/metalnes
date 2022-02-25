// Stripped down code from Mojoshader, originally under zlib license.

/**
 * MojoShader; generate shader programs from bytecode of compiled
 *  Direct3D shaders.
 *
 * Please see the file LICENSE.txt in the source's root directory.
 *
 *  This file written by Ryan C. Gordon.
 */

#ifndef _INCL_MOJOSHADER_H_
#define _INCL_MOJOSHADER_H_

#ifdef __cplusplus
extern "C" {
#endif
	
/*
 * These allocators work just like the C runtime's malloc() and free()
 *  (in fact, they probably use malloc() and free() internally if you don't
 *  specify your own allocator, but don't rely on that behaviour).
 * (data) is the pointer you supplied when specifying these allocator
 *  callbacks, in case you need instance-specific data...it is passed through
 *  to your allocator unmolested, and can be NULL if you like.
 */
typedef void *(*MOJOSHADER_hlslang_malloc)(int bytes, void *data);
typedef void (*MOJOSHADER_hlslang_free)(void *ptr, void *data);



/*
 * These are used with MOJOSHADER_hlslang_error as special case positions.
 */
#define MOJOSHADER_hlslang_POSITION_NONE (-3)
#define MOJOSHADER_hlslang_POSITION_BEFORE (-2)
#define MOJOSHADER_hlslang_POSITION_AFTER (-1)

typedef struct MOJOSHADER_hlslang_error
{
    /*
     * Human-readable error, if there is one. Will be NULL if there was no
     *  error. The string will be UTF-8 encoded, and English only. Most of
     *  these shouldn't be shown to the end-user anyhow.
     */
    const char *error;

    /*
     * Filename where error happened. This can be NULL if the information
     *  isn't available.
     */
    const char *filename;

    /*
     * Position of error, if there is one. Will be MOJOSHADER_hlslang_POSITION_NONE if
     *  there was no error, MOJOSHADER_hlslang_POSITION_BEFORE if there was an error
     *  before processing started, and MOJOSHADER_hlslang_POSITION_AFTER if there was
     *  an error during final processing. If >= 0, MOJOSHADER_hlslang_parse() sets
     *  this to the byte offset (starting at zero) into the bytecode you
     *  supplied, and MOJOSHADER_hlslang_assemble(), MOJOSHADER_hlslang_parseAst(), and
     *  MOJOSHADER_hlslang_compile() sets this to a a line number in the source code
     *  you supplied (starting at one).
     */
    int error_position;
} MOJOSHADER_hlslang_error;




/* hlmojo_Preprocessor interface... */

/*
 * Structure used to pass predefined macros. Maps to D3DXMACRO.
 *  You can have macro arguments: set identifier to "a(b, c)" or whatever.
 */
typedef struct MOJOSHADER_hlslang_preprocessorDefine
{
    const char *identifier;
    const char *definition;
} MOJOSHADER_hlslang_preprocessorDefine;

/*
 * Used with the MOJOSHADER_hlslang_includeOpen callback. Maps to D3DXINCLUDE_TYPE.
 */
typedef enum
{
    MOJOSHADER_hlslang_INCLUDETYPE_LOCAL,   /* local header: #include "blah.h" */
    MOJOSHADER_hlslang_INCLUDETYPE_SYSTEM   /* system header: #include <blah.h> */
} MOJOSHADER_hlslang_includeType;



/*
 * This callback allows an app to handle #include statements for the
 *  preprocessor. When the preprocessor sees an #include, it will call this
 *  function to obtain the contents of the requested file. This is optional;
 *  the preprocessor will open files directly if no callback is supplied, but
 *  this allows an app to retrieve data from something other than the
 *  traditional filesystem (for example, headers packed in a .zip file or
 *  headers generated on-the-fly).
 *
 * This function maps to ID3DXInclude::Open()
 *
 * (inctype) specifies the type of header we wish to include.
 * (fname) specifies the name of the file specified on the #include line.
 * (parentfname) specifies the path of the file containing the include.
 * (parent) is a string of the entire source file containing the include, in
 *  its original, not-yet-preprocessed state. Note that this is just the
 *  contents of the specific file, not all source code that the preprocessor
 *  has seen through other includes, etc.
 * (outdata) will be set by the callback to a pointer to the included file's
 *  contents. The callback is responsible for allocating this however they
 *  see fit (we provide allocator functions, but you may ignore them). This
 *  pointer must remain valid until the includeClose callback runs. This
 *  string does not need to be NULL-terminated.
 * (outbytes) will be set by the callback to the number of bytes pointed to
 *  by (outdata).
 * (m),(f), and (d) are the allocator details that the application passed to
 *  MojoShader. If these were NULL, MojoShader may have replaced them with its
 *  own internal allocators.
 *
 * The callback returns zero on error, non-zero on success.
 *
 * If you supply an includeOpen callback, you must supply includeClose, too.
 */
typedef int (*MOJOSHADER_hlslang_includeOpen)(MOJOSHADER_hlslang_includeType inctype,
                            const char *fname, const char *parentfname, const char *parent,
                            const char **outdata, unsigned int *outbytes,
                            MOJOSHADER_hlslang_malloc m, MOJOSHADER_hlslang_free f, void *d);

/*
 * This callback allows an app to clean up the results of a previous
 *  includeOpen callback.
 *
 * This function maps to ID3DXInclude::Close()
 *
 * (data) is the data that was returned from a previous call to includeOpen.
 *  It is now safe to deallocate this data.
 * (m),(f), and (d) are the same allocator details that were passed to your
 *  includeOpen callback.
 *
 * If you supply an includeClose callback, you must supply includeOpen, too.
 */
typedef void (*MOJOSHADER_hlslang_includeClose)(const char *data,
                            MOJOSHADER_hlslang_malloc m, MOJOSHADER_hlslang_free f, void *d);



#ifdef __cplusplus
}
#endif

#endif  /* include-once blocker. */

/* end of mojoshader.h ... */

