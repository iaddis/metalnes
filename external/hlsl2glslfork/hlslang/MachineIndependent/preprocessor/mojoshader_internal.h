#ifndef _INCLUDE_MOJOSHADER_INTERNAL_H_
#define _INCLUDE_MOJOSHADER_INTERNAL_H_

// Stripped down code from Mojoshader, originally under zlib license.

#ifndef __MOJOSHADER_INTERNAL__
#error Do not include this header from your applications.
#endif

#ifdef __cplusplus
extern "C" {
#endif


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <assert.h>

#include "mojoshader.h"

#define DEBUG_LEXER 0
#define DEBUG_PREPROCESSOR 0
#define DEBUG_TOKENIZER \
    (DEBUG_PREPROCESSOR || DEBUG_LEXER)


// Get basic wankery out of the way here...


#ifdef _MSC_VER
#include <malloc.h>
#define va_copy(a, b) a = b
#define snprintf _snprintf  // !!! FIXME: not a safe replacement!
#define vsnprintf _vsnprintf  // !!! FIXME: not a safe replacement!
#define strcasecmp stricmp
#define strncasecmp strnicmp
typedef unsigned __int8 uint8;
typedef unsigned __int16 uint16;
typedef unsigned __int32 uint32;
typedef unsigned __int64 uint64;
typedef __int32 int32;
typedef __int64 int64;
#ifdef _WIN64
typedef __int64 ssize_t;
#elif defined _WIN32
typedef __int32 ssize_t;
#else
#error Please define your platform.
#endif
// Warning Level 4 considered harmful.  :)
#pragma warning(disable: 4100)  // "unreferenced formal parameter"
#pragma warning(disable: 4389)  // "signed/unsigned mismatch"
#else
#include <stdint.h>
typedef uint8_t uint8;
typedef uint16_t uint16;
typedef uint32_t uint32;
typedef int32_t int32;
typedef int64_t int64;
typedef uint64_t uint64;
#endif

#ifdef sun
#include <alloca.h>
#endif

#ifdef __GNUC__
#define ISPRINTF(x,y) __attribute__((format (printf, x, y)))
#else
#define ISPRINTF(x,y)
#endif

#define STATICARRAYLEN(x) ( (sizeof ((x))) / (sizeof ((x)[0])) )



static inline int Min(const int a, const int b)
{
    return ((a < b) ? a : b);
} // Min



// String caching...

typedef struct hlmojo_StringCache hlmojo_StringCache;
hlmojo_StringCache *hlmojo_stringcache_create(MOJOSHADER_hlslang_malloc m,MOJOSHADER_hlslang_free f,void *d);
const char *hlmojo_stringcache(hlmojo_StringCache *cache, const char *str);
const char *hlmojo_stringcache_len(hlmojo_StringCache *cache, const char *str,
                            const unsigned int len);
void hlmojo_stringcache_destroy(hlmojo_StringCache *cache);


// Dynamic buffers...

typedef struct hlmojo_Buffer hlmojo_Buffer;
hlmojo_Buffer *hlmojo_buffer_create(size_t blksz,MOJOSHADER_hlslang_malloc m,MOJOSHADER_hlslang_free f,void *d);
int hlmojo_buffer_append(hlmojo_Buffer *buffer, const void *_data, size_t len);
int hlmojo_buffer_append_fmt(hlmojo_Buffer *buffer, const char *fmt, ...) ISPRINTF(2,3);
int hlmojo_buffer_append_va(hlmojo_Buffer *buffer, const char *fmt, va_list va);
size_t hlmojo_buffer_size(hlmojo_Buffer *buffer);
void hlmojo_buffer_empty(hlmojo_Buffer *buffer);
char *hlmojo_buffer_flatten(hlmojo_Buffer *buffer);
void hlmojo_buffer_destroy(hlmojo_Buffer *buffer);



// #define this to force app to supply an allocator, so there's no reference
//  to the C runtime's malloc() and free()...
#if MOJOSHADER_hlslang_FORCE_ALLOCATOR
#define MOJOSHADER_hlslang_internal_malloc NULL
#define MOJOSHADER_hlslang_internal_free NULL
#else
void *MOJOSHADER_hlslang_internal_malloc(int bytes, void *d);
void MOJOSHADER_hlslang_internal_free(void *ptr, void *d);
#endif

#if MOJOSHADER_hlslang_FORCE_INCLUDE_CALLBACKS
#define MOJOSHADER_hlslang_internal_include_open NULL
#define MOJOSHADER_hlslang_internal_include_close NULL
#else
int MOJOSHADER_hlslang_internal_include_open(MOJOSHADER_hlslang_includeType inctype,
                                     const char *fname, const char *parent,
                                     const char **outdata,
                                     unsigned int *outbytes,
                                     MOJOSHADER_hlslang_malloc m, MOJOSHADER_hlslang_free f,
                                     void *d);

void MOJOSHADER_hlslang_internal_include_close(const char *data, MOJOSHADER_hlslang_malloc m,
                                       MOJOSHADER_hlslang_free f, void *d);
#endif



extern MOJOSHADER_hlslang_error MOJOSHADER_hlslang_out_of_mem_error;


// preprocessor stuff.

typedef enum
{
    TOKEN_UNKNOWN = 256,  // start past ASCII character values.

    // These are all C-like constructs. Tokens < 256 may be single
    //  chars (like '+' or whatever). These are just multi-char sequences
    //  (like "+=" or whatever).
    TOKEN_IDENTIFIER,
    TOKEN_INT_LITERAL,
    TOKEN_FLOAT_LITERAL,
    TOKEN_STRING_LITERAL,
    TOKEN_RSHIFTASSIGN,
    TOKEN_LSHIFTASSIGN,
    TOKEN_ADDASSIGN,
    TOKEN_SUBASSIGN,
    TOKEN_MULTASSIGN,
    TOKEN_DIVASSIGN,
    TOKEN_MODASSIGN,
    TOKEN_XORASSIGN,
    TOKEN_ANDASSIGN,
    TOKEN_ORASSIGN,
    TOKEN_INCREMENT,
    TOKEN_DECREMENT,
    TOKEN_RSHIFT,
    TOKEN_LSHIFT,
    TOKEN_ANDAND,
    TOKEN_OROR,
    TOKEN_LEQ,
    TOKEN_GEQ,
    TOKEN_EQL,
    TOKEN_NEQ,
    TOKEN_HASH,
    TOKEN_HASHHASH,

    // This is returned at the end of input...no more to process.
    TOKEN_EOI,

    // This is returned for char sequences we think are bogus. You'll have
    //  to judge for yourself. In most cases, you'll probably just fail with
    //  bogus syntax without explicitly checking for this token.
    TOKEN_BAD_CHARS,

    // This is returned if there's an error condition (the error is returned
    //  as a NULL-terminated string from hlmojo_preprocessor_nexttoken(), instead
    //  of actual token data). You can continue getting tokens after this
    //  is reported. It happens for things like missing #includes, etc.
    TOKEN_PREPROCESSING_ERROR,

    // These are all caught by the preprocessor. Caller won't ever see them,
    //  except TOKEN_PP_PRAGMA.
    //  They control the preprocessor (#includes new files, etc).
    TOKEN_PP_INCLUDE,
    TOKEN_PP_LINE,
    TOKEN_PP_DEFINE,
    TOKEN_PP_UNDEF,
    TOKEN_PP_IF,
    TOKEN_PP_IFDEF,
    TOKEN_PP_IFNDEF,
    TOKEN_PP_ELSE,
    TOKEN_PP_ELIF,
    TOKEN_PP_ENDIF,
    TOKEN_PP_ERROR,  // caught, becomes TOKEN_PREPROCESSING_ERROR
    TOKEN_PP_PRAGMA,
    TOKEN_INCOMPLETE_COMMENT,  // caught, becomes TOKEN_PREPROCESSING_ERROR
    TOKEN_PP_UNARY_MINUS,  // used internally, never returned.
    TOKEN_PP_UNARY_PLUS,   // used internally, never returned.
} Token;


// This is opaque.
struct hlmojo_Preprocessor;
typedef struct hlmojo_Preprocessor hlmojo_Preprocessor;

typedef struct hlmojo_Conditional
{
    Token type;
    int linenum;
    int skipping;
    int chosen;
    struct hlmojo_Conditional *next;
} hlmojo_Conditional;

typedef struct hlmojo_Define
{
    const char *identifier;
    const char *definition;
    const char *original;
    const char **parameters;
    int paramcount;
    struct hlmojo_Define *next;
} hlmojo_Define;

typedef struct hlmojo_IncludeState
{
    const char *filename;
    const char *source_base;
    const char *source;
    const char *token;
    unsigned int tokenlen;
    Token tokenval;
    int pushedback;
    const unsigned char *lexer_marker;
    int report_whitespace;
    unsigned int orig_length;
    unsigned int bytes_left;
    unsigned int line;
    hlmojo_Conditional *conditional_stack;
    MOJOSHADER_hlslang_includeClose close_callback;
    struct hlmojo_IncludeState *next;
} hlmojo_IncludeState;

Token hlmojo_preprocessor_lexer(hlmojo_IncludeState *s);

// This will only fail if the allocator fails, so it doesn't return any
//  error code...NULL on failure.
hlmojo_Preprocessor *hlmojo_preprocessor_start(const char *fname, const char *source,
                            unsigned int sourcelen,
                            MOJOSHADER_hlslang_includeOpen open_callback,
                            MOJOSHADER_hlslang_includeClose close_callback,
                            const MOJOSHADER_hlslang_preprocessorDefine *defines,
                            unsigned int define_count,
                            MOJOSHADER_hlslang_malloc m, MOJOSHADER_hlslang_free f, void *d);

void hlmojo_preprocessor_end(hlmojo_Preprocessor *pp);
int hlmojo_preprocessor_outofmemory(hlmojo_Preprocessor *pp);
const char *hlmojo_preprocessor_nexttoken(hlmojo_Preprocessor *_ctx,
                                   unsigned int *_len, Token *_token);
const char *hlmojo_preprocessor_sourcepos(hlmojo_Preprocessor *pp, unsigned int *pos);


void MOJOSHADER_hlslang_print_debug_token(const char *subsystem, const char *token,
                                  const unsigned int tokenlen,
                                  const Token tokenval);
	
#ifdef __cplusplus
}
#endif


#endif  // _INCLUDE_MOJOSHADER_INTERNAL_H_

// end of mojoshader_internal.h ...
