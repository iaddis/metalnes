/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton implementation for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "2.3"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 1

/* Using locations.  */
#define YYLSP_NEEDED 0



/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     CONST_QUAL = 258,
     STATIC_QUAL = 259,
     BOOL_TYPE = 260,
     FLOAT_TYPE = 261,
     INT_TYPE = 262,
     STRING_TYPE = 263,
     FIXED_TYPE = 264,
     HALF_TYPE = 265,
     BREAK = 266,
     CONTINUE = 267,
     DO = 268,
     ELSE = 269,
     FOR = 270,
     IF = 271,
     DISCARD = 272,
     RETURN = 273,
     BVEC2 = 274,
     BVEC3 = 275,
     BVEC4 = 276,
     IVEC2 = 277,
     IVEC3 = 278,
     IVEC4 = 279,
     VEC2 = 280,
     VEC3 = 281,
     VEC4 = 282,
     HVEC2 = 283,
     HVEC3 = 284,
     HVEC4 = 285,
     FVEC2 = 286,
     FVEC3 = 287,
     FVEC4 = 288,
     MATRIX2x2 = 289,
     MATRIX2x3 = 290,
     MATRIX2x4 = 291,
     MATRIX3x2 = 292,
     MATRIX3x3 = 293,
     MATRIX3x4 = 294,
     MATRIX4x2 = 295,
     MATRIX4x3 = 296,
     MATRIX4x4 = 297,
     HMATRIX2x2 = 298,
     HMATRIX2x3 = 299,
     HMATRIX2x4 = 300,
     HMATRIX3x2 = 301,
     HMATRIX3x3 = 302,
     HMATRIX3x4 = 303,
     HMATRIX4x2 = 304,
     HMATRIX4x3 = 305,
     HMATRIX4x4 = 306,
     FMATRIX2x2 = 307,
     FMATRIX2x3 = 308,
     FMATRIX2x4 = 309,
     FMATRIX3x2 = 310,
     FMATRIX3x3 = 311,
     FMATRIX3x4 = 312,
     FMATRIX4x2 = 313,
     FMATRIX4x3 = 314,
     FMATRIX4x4 = 315,
     IN_QUAL = 316,
     OUT_QUAL = 317,
     INOUT_QUAL = 318,
     UNIFORM = 319,
     STRUCT = 320,
     VOID_TYPE = 321,
     WHILE = 322,
     SAMPLER1D = 323,
     SAMPLER2D = 324,
     SAMPLER3D = 325,
     SAMPLERCUBE = 326,
     SAMPLER1DSHADOW = 327,
     SAMPLER2DSHADOW = 328,
     SAMPLER2DARRAY = 329,
     SAMPLERRECTSHADOW = 330,
     SAMPLERRECT = 331,
     SAMPLER2D_HALF = 332,
     SAMPLER2D_FLOAT = 333,
     SAMPLERCUBE_HALF = 334,
     SAMPLERCUBE_FLOAT = 335,
     SAMPLERGENERIC = 336,
     VECTOR = 337,
     MATRIX = 338,
     REGISTER = 339,
     TEXTURE = 340,
     SAMPLERSTATE = 341,
     IDENTIFIER = 342,
     TYPE_NAME = 343,
     FLOATCONSTANT = 344,
     INTCONSTANT = 345,
     BOOLCONSTANT = 346,
     STRINGCONSTANT = 347,
     FIELD_SELECTION = 348,
     LEFT_OP = 349,
     RIGHT_OP = 350,
     INC_OP = 351,
     DEC_OP = 352,
     LE_OP = 353,
     GE_OP = 354,
     EQ_OP = 355,
     NE_OP = 356,
     AND_OP = 357,
     OR_OP = 358,
     XOR_OP = 359,
     MUL_ASSIGN = 360,
     DIV_ASSIGN = 361,
     ADD_ASSIGN = 362,
     MOD_ASSIGN = 363,
     LEFT_ASSIGN = 364,
     RIGHT_ASSIGN = 365,
     AND_ASSIGN = 366,
     XOR_ASSIGN = 367,
     OR_ASSIGN = 368,
     SUB_ASSIGN = 369,
     LEFT_PAREN = 370,
     RIGHT_PAREN = 371,
     LEFT_BRACKET = 372,
     RIGHT_BRACKET = 373,
     LEFT_BRACE = 374,
     RIGHT_BRACE = 375,
     DOT = 376,
     COMMA = 377,
     COLON = 378,
     EQUAL = 379,
     SEMICOLON = 380,
     BANG = 381,
     DASH = 382,
     TILDE = 383,
     PLUS = 384,
     STAR = 385,
     SLASH = 386,
     PERCENT = 387,
     LEFT_ANGLE = 388,
     RIGHT_ANGLE = 389,
     VERTICAL_BAR = 390,
     CARET = 391,
     AMPERSAND = 392,
     QUESTION = 393
   };
#endif
/* Tokens.  */
#define CONST_QUAL 258
#define STATIC_QUAL 259
#define BOOL_TYPE 260
#define FLOAT_TYPE 261
#define INT_TYPE 262
#define STRING_TYPE 263
#define FIXED_TYPE 264
#define HALF_TYPE 265
#define BREAK 266
#define CONTINUE 267
#define DO 268
#define ELSE 269
#define FOR 270
#define IF 271
#define DISCARD 272
#define RETURN 273
#define BVEC2 274
#define BVEC3 275
#define BVEC4 276
#define IVEC2 277
#define IVEC3 278
#define IVEC4 279
#define VEC2 280
#define VEC3 281
#define VEC4 282
#define HVEC2 283
#define HVEC3 284
#define HVEC4 285
#define FVEC2 286
#define FVEC3 287
#define FVEC4 288
#define MATRIX2x2 289
#define MATRIX2x3 290
#define MATRIX2x4 291
#define MATRIX3x2 292
#define MATRIX3x3 293
#define MATRIX3x4 294
#define MATRIX4x2 295
#define MATRIX4x3 296
#define MATRIX4x4 297
#define HMATRIX2x2 298
#define HMATRIX2x3 299
#define HMATRIX2x4 300
#define HMATRIX3x2 301
#define HMATRIX3x3 302
#define HMATRIX3x4 303
#define HMATRIX4x2 304
#define HMATRIX4x3 305
#define HMATRIX4x4 306
#define FMATRIX2x2 307
#define FMATRIX2x3 308
#define FMATRIX2x4 309
#define FMATRIX3x2 310
#define FMATRIX3x3 311
#define FMATRIX3x4 312
#define FMATRIX4x2 313
#define FMATRIX4x3 314
#define FMATRIX4x4 315
#define IN_QUAL 316
#define OUT_QUAL 317
#define INOUT_QUAL 318
#define UNIFORM 319
#define STRUCT 320
#define VOID_TYPE 321
#define WHILE 322
#define SAMPLER1D 323
#define SAMPLER2D 324
#define SAMPLER3D 325
#define SAMPLERCUBE 326
#define SAMPLER1DSHADOW 327
#define SAMPLER2DSHADOW 328
#define SAMPLER2DARRAY 329
#define SAMPLERRECTSHADOW 330
#define SAMPLERRECT 331
#define SAMPLER2D_HALF 332
#define SAMPLER2D_FLOAT 333
#define SAMPLERCUBE_HALF 334
#define SAMPLERCUBE_FLOAT 335
#define SAMPLERGENERIC 336
#define VECTOR 337
#define MATRIX 338
#define REGISTER 339
#define TEXTURE 340
#define SAMPLERSTATE 341
#define IDENTIFIER 342
#define TYPE_NAME 343
#define FLOATCONSTANT 344
#define INTCONSTANT 345
#define BOOLCONSTANT 346
#define STRINGCONSTANT 347
#define FIELD_SELECTION 348
#define LEFT_OP 349
#define RIGHT_OP 350
#define INC_OP 351
#define DEC_OP 352
#define LE_OP 353
#define GE_OP 354
#define EQ_OP 355
#define NE_OP 356
#define AND_OP 357
#define OR_OP 358
#define XOR_OP 359
#define MUL_ASSIGN 360
#define DIV_ASSIGN 361
#define ADD_ASSIGN 362
#define MOD_ASSIGN 363
#define LEFT_ASSIGN 364
#define RIGHT_ASSIGN 365
#define AND_ASSIGN 366
#define XOR_ASSIGN 367
#define OR_ASSIGN 368
#define SUB_ASSIGN 369
#define LEFT_PAREN 370
#define RIGHT_PAREN 371
#define LEFT_BRACKET 372
#define RIGHT_BRACKET 373
#define LEFT_BRACE 374
#define RIGHT_BRACE 375
#define DOT 376
#define COMMA 377
#define COLON 378
#define EQUAL 379
#define SEMICOLON 380
#define BANG 381
#define DASH 382
#define TILDE 383
#define PLUS 384
#define STAR 385
#define SLASH 386
#define PERCENT 387
#define LEFT_ANGLE 388
#define RIGHT_ANGLE 389
#define VERTICAL_BAR 390
#define CARET 391
#define AMPERSAND 392
#define QUESTION 393




/* Copy the first part of user declarations.  */
#line 7 "hlslang.y"


/* Based on:
ANSI C Yacc grammar

In 1985, Jeff Lee published his Yacc grammar (which is accompanied by a 
matching Lex specification) for the April 30, 1985 draft version of the 
ANSI C standard.  Tom Stockfisch reposted it to net.sources in 1987; that
original, as mentioned in the answer to question 17.25 of the comp.lang.c
FAQ, can be ftp'ed from ftp.uu.net, file usenet/net.sources/ansi.c.grammar.Z.
 
I intend to keep this version as close to the current C Standard grammar as 
possible; please let me know if you discover discrepancies. 

Jutta Degener, 1995 
*/

#include "SymbolTable.h"
#include "ParseHelper.h"
#include "../../include/hlsl2glsl.h"

using namespace hlslang;


namespace hlslang {
extern void yyerror(TParseContext&, const char*);
}

#define FRAG_ONLY(S, L) {                                                       \
    if (parseContext.language != EShLangFragment) {                             \
        parseContext.error(L, " supported in fragment shaders only ", S, "", "");          \
        parseContext.recover();                                                            \
    }                                                                           \
}

#define NONSQUARE_MATRIX_CHECK(S, L) { \
	if (parseContext.targetVersion < ETargetGLSL_120) { \
		parseContext.error(L, " not supported in pre-GLSL1.20", S, "", ""); \
		parseContext.recover(); \
	} \
}

#define UNSUPPORTED_FEATURE(S, L) {                                                       \
    parseContext.error(L, " not supported ", S, "", "");              \
    parseContext.recover();                                                            \
}

#define SET_BASIC_TYPE(RES,PAR,T,PREC) \
	TQualifier qual = parseContext.getDefaultQualifier(); \
	(RES).setBasic(T, qual, (PAR).line); \
	(RES).precision = PREC




/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* Enabling the token table.  */
#ifndef YYTOKEN_TABLE
# define YYTOKEN_TABLE 0
#endif

#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 61 "hlslang.y"
{
    struct {
        TSourceLoc line;
        union {
            TString *string;
            float f;
            int i;
            bool b;
        };
        TSymbol* symbol;
    } lex;
    struct {
        TSourceLoc line;
        TOperator op;
        union {
            TIntermNode* intermNode;
            TIntermNodePair nodePair;
            TIntermTyped* intermTypedNode;
            TIntermAggregate* intermAggregate;
			TIntermTyped* intermDeclaration;
        };
        union {
            TPublicType type;
            TQualifier qualifier;
            TFunction* function;
            TParameter param;
            TTypeLine typeLine;
            TTypeList* typeList;
	    TAnnotation* ann;
	    TTypeInfo* typeInfo;
        };
    } interm;
}
/* Line 193 of yacc.c.  */
#line 461 "hlslang_tab.cpp"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



/* Copy the second part of user declarations.  */
#line 95 "hlslang.y"

    extern int yylex(YYSTYPE*, TParseContext&);


/* Line 216 of yacc.c.  */
#line 477 "hlslang_tab.cpp"

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#elif (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
typedef signed char yytype_int8;
#else
typedef short int yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(e) ((void) (e))
#else
# define YYUSE(e) /* empty */
#endif

/* Identity function, used to suppress warnings about constant conditions.  */
#ifndef lint
# define YYID(n) (n)
#else
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static int
YYID (int i)
#else
static int
YYID (i)
    int i;
#endif
{
  return i;
}
#endif

#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#     ifndef _STDLIB_H
#      define _STDLIB_H 1
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (YYID (0))
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined _STDLIB_H \
       && ! ((defined YYMALLOC || defined malloc) \
	     && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef _STDLIB_H
#    define _STDLIB_H 1
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
	 || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss;
  YYSTYPE yyvs;
  };

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  YYSIZE_T yyi;				\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (YYID (0))
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (YYID (0))

#endif

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  106
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   2692

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  139
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  93
/* YYNRULES -- Number of rules.  */
#define YYNRULES  325
/* YYNRULES -- Number of states.  */
#define YYNSTATES  497

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   393

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      65,    66,    67,    68,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,    90,    91,    92,    93,    94,
      95,    96,    97,    98,    99,   100,   101,   102,   103,   104,
     105,   106,   107,   108,   109,   110,   111,   112,   113,   114,
     115,   116,   117,   118,   119,   120,   121,   122,   123,   124,
     125,   126,   127,   128,   129,   130,   131,   132,   133,   134,
     135,   136,   137,   138
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint16 yyprhs[] =
{
       0,     0,     3,     5,     7,     9,    11,    13,    17,    19,
      24,    26,    30,    33,    36,    38,    40,    42,    46,    49,
      52,    55,    57,    60,    64,    67,    69,    71,    73,    75,
      78,    81,    84,    89,    91,    93,    95,    97,    99,   103,
     107,   111,   113,   117,   121,   123,   127,   131,   133,   137,
     141,   145,   149,   151,   155,   159,   161,   165,   167,   171,
     173,   177,   179,   183,   185,   189,   191,   195,   197,   203,
     205,   209,   211,   213,   215,   217,   219,   221,   223,   225,
     227,   229,   231,   233,   237,   239,   242,   245,   248,   253,
     255,   257,   260,   264,   268,   271,   276,   280,   285,   291,
     299,   303,   306,   310,   313,   314,   316,   318,   320,   322,
     324,   329,   336,   344,   353,   363,   370,   372,   376,   382,
     389,   397,   406,   412,   414,   417,   419,   421,   424,   427,
     429,   431,   436,   438,   440,   442,   444,   446,   448,   455,
     462,   469,   471,   473,   475,   477,   479,   481,   483,   485,
     487,   489,   491,   493,   495,   497,   499,   501,   503,   505,
     507,   509,   511,   513,   515,   517,   519,   521,   523,   525,
     527,   529,   531,   533,   535,   537,   539,   541,   543,   545,
     547,   549,   551,   553,   555,   557,   559,   561,   563,   565,
     567,   569,   571,   573,   575,   577,   579,   581,   583,   585,
     587,   593,   598,   600,   603,   607,   609,   613,   615,   619,
     624,   631,   633,   635,   637,   639,   641,   643,   645,   647,
     649,   651,   653,   656,   657,   658,   664,   666,   668,   671,
     675,   677,   680,   682,   685,   691,   695,   697,   699,   704,
     705,   712,   713,   722,   723,   731,   733,   735,   737,   738,
     741,   745,   748,   751,   754,   758,   761,   763,   766,   768,
     770,   772,   773,   777,   781,   786,   788,   790,   794,   798,
     801,   805,   807,   810,   816,   818,   820,   822,   824,   826,
     828,   830,   832,   834,   836,   838,   840,   842,   844,   846,
     848,   850,   852,   854,   856,   858,   860,   862,   864,   866,
     868,   870,   872,   877,   879,   883,   887,   893,   896,   897,
     899,   901,   903,   906,   909,   912,   916,   921,   925,   927,
     930,   935,   942,   949,   954,   961
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int16 yyrhs[] =
{
     211,     0,    -1,    87,    -1,   140,    -1,    90,    -1,    89,
      -1,    91,    -1,   115,   167,   116,    -1,   141,    -1,   142,
     117,   143,   118,    -1,   144,    -1,   142,   121,    93,    -1,
     142,    96,    -1,   142,    97,    -1,   167,    -1,   145,    -1,
     146,    -1,   142,   121,   146,    -1,   148,   116,    -1,   147,
     116,    -1,   149,    66,    -1,   149,    -1,   149,   165,    -1,
     148,   122,   165,    -1,   150,   115,    -1,   182,    -1,    87,
      -1,    93,    -1,   142,    -1,    96,   151,    -1,    97,   151,
      -1,   152,   151,    -1,   115,   183,   116,   151,    -1,   129,
      -1,   127,    -1,   126,    -1,   128,    -1,   151,    -1,   153,
     130,   151,    -1,   153,   131,   151,    -1,   153,   132,   151,
      -1,   153,    -1,   154,   129,   153,    -1,   154,   127,   153,
      -1,   154,    -1,   155,    94,   154,    -1,   155,    95,   154,
      -1,   155,    -1,   156,   133,   155,    -1,   156,   134,   155,
      -1,   156,    98,   155,    -1,   156,    99,   155,    -1,   156,
      -1,   157,   100,   156,    -1,   157,   101,   156,    -1,   157,
      -1,   158,   137,   157,    -1,   158,    -1,   159,   136,   158,
      -1,   159,    -1,   160,   135,   159,    -1,   160,    -1,   161,
     102,   160,    -1,   161,    -1,   162,   104,   161,    -1,   162,
      -1,   163,   103,   162,    -1,   163,    -1,   163,   138,   167,
     123,   165,    -1,   164,    -1,   151,   166,   165,    -1,   124,
      -1,   105,    -1,   106,    -1,   108,    -1,   107,    -1,   114,
      -1,   109,    -1,   110,    -1,   111,    -1,   112,    -1,   113,
      -1,   165,    -1,   167,   122,   165,    -1,   164,    -1,   170,
     125,    -1,   178,   125,    -1,   171,   116,    -1,   171,   116,
     123,    87,    -1,   173,    -1,   172,    -1,   173,   175,    -1,
     172,   122,   175,    -1,   180,    87,   115,    -1,   182,    87,
      -1,   182,    87,   124,   189,    -1,   182,    87,   226,    -1,
     182,    87,   123,    87,    -1,   182,    87,   117,   168,   118,
      -1,   182,    87,   117,   168,   118,   123,    87,    -1,   181,
     176,   174,    -1,   176,   174,    -1,   181,   176,   177,    -1,
     176,   177,    -1,    -1,    61,    -1,    62,    -1,    63,    -1,
     182,    -1,   179,    -1,   178,   122,    87,   228,    -1,   178,
     122,    87,   117,   118,   228,    -1,   178,   122,    87,   117,
     168,   118,   228,    -1,   178,   122,    87,   117,   118,   228,
     124,   189,    -1,   178,   122,    87,   117,   168,   118,   228,
     124,   189,    -1,   178,   122,    87,   228,   124,   189,    -1,
     180,    -1,   180,    87,   228,    -1,   180,    87,   117,   118,
     228,    -1,   180,    87,   117,   168,   118,   228,    -1,   180,
      87,   117,   118,   228,   124,   189,    -1,   180,    87,   117,
     168,   118,   228,   124,   189,    -1,   180,    87,   228,   124,
     189,    -1,   182,    -1,   181,   182,    -1,     3,    -1,     4,
      -1,     4,     3,    -1,     3,     4,    -1,    64,    -1,   183,
      -1,   183,   117,   168,   118,    -1,    66,    -1,     6,    -1,
      10,    -1,     9,    -1,     7,    -1,     5,    -1,    82,   133,
       6,   122,    90,   134,    -1,    82,   133,     7,   122,    90,
     134,    -1,    82,   133,     5,   122,    90,   134,    -1,    25,
      -1,    26,    -1,    27,    -1,    28,    -1,    29,    -1,    30,
      -1,    31,    -1,    32,    -1,    33,    -1,    19,    -1,    20,
      -1,    21,    -1,    22,    -1,    23,    -1,    24,    -1,    34,
      -1,    35,    -1,    36,    -1,    37,    -1,    38,    -1,    39,
      -1,    40,    -1,    41,    -1,    42,    -1,    43,    -1,    44,
      -1,    45,    -1,    46,    -1,    47,    -1,    48,    -1,    49,
      -1,    50,    -1,    51,    -1,    52,    -1,    53,    -1,    54,
      -1,    55,    -1,    56,    -1,    57,    -1,    58,    -1,    59,
      -1,    60,    -1,    85,    -1,    81,    -1,    68,    -1,    69,
      -1,    77,    -1,    78,    -1,    70,    -1,    71,    -1,    79,
      -1,    80,    -1,    76,    -1,    75,    -1,    72,    -1,    73,
      -1,    74,    -1,   184,    -1,    88,    -1,    65,    87,   119,
     185,   120,    -1,    65,   119,   185,   120,    -1,   186,    -1,
     185,   186,    -1,   182,   187,   125,    -1,   188,    -1,   187,
     122,   188,    -1,    87,    -1,    87,   123,    87,    -1,    87,
     117,   168,   118,    -1,    87,   117,   168,   118,   123,    87,
      -1,   165,    -1,   215,    -1,   229,    -1,   169,    -1,   193,
      -1,   192,    -1,   190,    -1,   199,    -1,   200,    -1,   203,
      -1,   210,    -1,   119,   120,    -1,    -1,    -1,   119,   194,
     198,   195,   120,    -1,   197,    -1,   192,    -1,   119,   120,
      -1,   119,   198,   120,    -1,   191,    -1,   198,   191,    -1,
     125,    -1,   167,   125,    -1,    16,   115,   167,   116,   201,
      -1,   191,    14,   191,    -1,   191,    -1,   167,    -1,   180,
      87,   124,   189,    -1,    -1,    67,   115,   204,   202,   116,
     196,    -1,    -1,    13,   205,   191,    67,   115,   167,   116,
     125,    -1,    -1,    15,   115,   206,   207,   209,   116,   196,
      -1,   199,    -1,   190,    -1,   202,    -1,    -1,   208,   125,
      -1,   208,   125,   167,    -1,    12,   125,    -1,    11,   125,
      -1,    18,   125,    -1,    18,   167,   125,    -1,    17,   125,
      -1,   212,    -1,   211,   212,    -1,   213,    -1,   169,    -1,
     125,    -1,    -1,   170,   214,   197,    -1,   119,   216,   120,
      -1,   119,   216,   122,   120,    -1,   165,    -1,   215,    -1,
     216,   122,   165,    -1,   216,   122,   215,    -1,   133,   134,
      -1,   133,   218,   134,    -1,   219,    -1,   218,   219,    -1,
     220,    87,   124,   221,   125,    -1,     6,    -1,    10,    -1,
       9,    -1,     7,    -1,     5,    -1,     8,    -1,    19,    -1,
      20,    -1,    21,    -1,    22,    -1,    23,    -1,    24,    -1,
      25,    -1,    26,    -1,    27,    -1,    28,    -1,    29,    -1,
      30,    -1,    31,    -1,    32,    -1,    33,    -1,   222,    -1,
      92,    -1,   223,    -1,   225,    -1,    90,    -1,    91,    -1,
      89,    -1,   220,   115,   224,   116,    -1,   222,    -1,   224,
     122,   222,    -1,   119,   224,   120,    -1,   123,    84,   115,
      87,   116,    -1,   123,    87,    -1,    -1,   227,    -1,   226,
      -1,   217,    -1,   227,   217,    -1,   227,   226,    -1,   226,
     217,    -1,   227,   226,   217,    -1,    86,   119,   230,   120,
      -1,    86,   119,   120,    -1,   231,    -1,   230,   231,    -1,
      87,   124,    87,   125,    -1,    87,   124,   133,    87,   134,
     125,    -1,    87,   124,   115,    87,   116,   125,    -1,    85,
     124,    87,   125,    -1,    85,   124,   133,    87,   134,   125,
      -1,    85,   124,   115,    87,   116,   125,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   179,   179,   217,   220,   225,   230,   235,   241,   244,
     308,   311,   398,   408,   421,   435,   551,   554,   572,   576,
     583,   587,   594,   603,   615,   623,   650,   662,   672,   675,
     685,   695,   713,   748,   749,   750,   751,   757,   758,   759,
     760,   764,   765,   766,   770,   771,   772,   776,   777,   778,
     779,   780,   784,   785,   786,   790,   791,   795,   796,   800,
     801,   805,   806,   810,   811,   815,   816,   820,   821,   836,
     837,   851,   852,   853,   854,   855,   856,   857,   858,   859,
     860,   861,   865,   868,   879,   887,   888,   892,   925,   962,
     965,   972,   980,  1001,  1033,  1044,  1057,  1069,  1081,  1099,
    1128,  1133,  1143,  1148,  1158,  1161,  1164,  1167,  1173,  1180,
    1183,  1201,  1225,  1253,  1280,  1313,  1347,  1350,  1368,  1391,
    1417,  1443,  1473,  1521,  1524,  1541,  1544,  1547,  1550,  1553,
    1561,  1564,  1579,  1582,  1585,  1588,  1591,  1594,  1597,  1608,
    1619,  1630,  1634,  1638,  1642,  1646,  1650,  1654,  1658,  1662,
    1666,  1670,  1674,  1678,  1682,  1686,  1690,  1694,  1699,  1704,
    1709,  1713,  1718,  1723,  1728,  1732,  1736,  1741,  1746,  1751,
    1755,  1760,  1765,  1770,  1774,  1778,  1783,  1788,  1793,  1797,
    1802,  1807,  1812,  1816,  1819,  1822,  1825,  1828,  1831,  1834,
    1837,  1840,  1843,  1846,  1849,  1852,  1855,  1858,  1861,  1865,
    1877,  1887,  1895,  1898,  1913,  1946,  1950,  1956,  1961,  1967,
    1977,  1993,  1994,  1995,  1999,  2003,  2004,  2010,  2011,  2012,
    2013,  2014,  2018,  2019,  2019,  2019,  2027,  2028,  2033,  2036,
    2044,  2047,  2053,  2054,  2058,  2066,  2070,  2080,  2085,  2102,
    2102,  2107,  2107,  2114,  2114,  2127,  2130,  2136,  2139,  2145,
    2149,  2156,  2163,  2170,  2177,  2197,  2208,  2212,  2219,  2222,
    2225,  2229,  2229,  2318,  2321,  2328,  2332,  2336,  2340,  2347,
    2351,  2357,  2361,  2368,  2374,  2375,  2376,  2377,  2378,  2379,
    2380,  2381,  2382,  2383,  2384,  2385,  2386,  2387,  2388,  2389,
    2390,  2391,  2392,  2393,  2394,  2398,  2399,  2400,  2401,  2405,
    2408,  2411,  2417,  2421,  2422,  2426,  2430,  2436,  2440,  2441,
    2442,  2443,  2444,  2445,  2446,  2447,  2451,  2456,  2461,  2462,
    2466,  2467,  2468,  2469,  2470,  2471
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "CONST_QUAL", "STATIC_QUAL", "BOOL_TYPE",
  "FLOAT_TYPE", "INT_TYPE", "STRING_TYPE", "FIXED_TYPE", "HALF_TYPE",
  "BREAK", "CONTINUE", "DO", "ELSE", "FOR", "IF", "DISCARD", "RETURN",
  "BVEC2", "BVEC3", "BVEC4", "IVEC2", "IVEC3", "IVEC4", "VEC2", "VEC3",
  "VEC4", "HVEC2", "HVEC3", "HVEC4", "FVEC2", "FVEC3", "FVEC4",
  "MATRIX2x2", "MATRIX2x3", "MATRIX2x4", "MATRIX3x2", "MATRIX3x3",
  "MATRIX3x4", "MATRIX4x2", "MATRIX4x3", "MATRIX4x4", "HMATRIX2x2",
  "HMATRIX2x3", "HMATRIX2x4", "HMATRIX3x2", "HMATRIX3x3", "HMATRIX3x4",
  "HMATRIX4x2", "HMATRIX4x3", "HMATRIX4x4", "FMATRIX2x2", "FMATRIX2x3",
  "FMATRIX2x4", "FMATRIX3x2", "FMATRIX3x3", "FMATRIX3x4", "FMATRIX4x2",
  "FMATRIX4x3", "FMATRIX4x4", "IN_QUAL", "OUT_QUAL", "INOUT_QUAL",
  "UNIFORM", "STRUCT", "VOID_TYPE", "WHILE", "SAMPLER1D", "SAMPLER2D",
  "SAMPLER3D", "SAMPLERCUBE", "SAMPLER1DSHADOW", "SAMPLER2DSHADOW",
  "SAMPLER2DARRAY", "SAMPLERRECTSHADOW", "SAMPLERRECT", "SAMPLER2D_HALF",
  "SAMPLER2D_FLOAT", "SAMPLERCUBE_HALF", "SAMPLERCUBE_FLOAT",
  "SAMPLERGENERIC", "VECTOR", "MATRIX", "REGISTER", "TEXTURE",
  "SAMPLERSTATE", "IDENTIFIER", "TYPE_NAME", "FLOATCONSTANT",
  "INTCONSTANT", "BOOLCONSTANT", "STRINGCONSTANT", "FIELD_SELECTION",
  "LEFT_OP", "RIGHT_OP", "INC_OP", "DEC_OP", "LE_OP", "GE_OP", "EQ_OP",
  "NE_OP", "AND_OP", "OR_OP", "XOR_OP", "MUL_ASSIGN", "DIV_ASSIGN",
  "ADD_ASSIGN", "MOD_ASSIGN", "LEFT_ASSIGN", "RIGHT_ASSIGN", "AND_ASSIGN",
  "XOR_ASSIGN", "OR_ASSIGN", "SUB_ASSIGN", "LEFT_PAREN", "RIGHT_PAREN",
  "LEFT_BRACKET", "RIGHT_BRACKET", "LEFT_BRACE", "RIGHT_BRACE", "DOT",
  "COMMA", "COLON", "EQUAL", "SEMICOLON", "BANG", "DASH", "TILDE", "PLUS",
  "STAR", "SLASH", "PERCENT", "LEFT_ANGLE", "RIGHT_ANGLE", "VERTICAL_BAR",
  "CARET", "AMPERSAND", "QUESTION", "$accept", "variable_identifier",
  "primary_expression", "postfix_expression", "int_expression",
  "function_call", "function_call_or_method", "function_call_generic",
  "function_call_header_no_parameters",
  "function_call_header_with_parameters", "function_call_header",
  "function_identifier", "unary_expression", "unary_operator",
  "mul_expression", "add_expression", "shift_expression", "rel_expression",
  "eq_expression", "and_expression", "xor_expression", "or_expression",
  "log_and_expression", "log_xor_expression", "log_or_expression",
  "cond_expression", "assign_expression", "assignment_operator",
  "expression", "const_expression", "declaration", "function_prototype",
  "function_declarator", "function_header_with_parameters",
  "function_header", "parameter_declarator", "parameter_declaration",
  "parameter_qualifier", "parameter_type_specifier",
  "init_declarator_list", "single_declaration", "fully_specified_type",
  "type_qualifier", "type_specifier", "type_specifier_nonarray",
  "struct_specifier", "struct_declaration_list", "struct_declaration",
  "struct_declarator_list", "struct_declarator", "initializer",
  "declaration_statement", "statement", "simple_statement",
  "compound_statement", "@1", "@2", "statement_no_new_scope",
  "compound_statement_no_new_scope", "statement_list",
  "expression_statement", "selection_statement",
  "selection_rest_statement", "condition", "iteration_statement", "@3",
  "@4", "@5", "for_init_statement", "conditionopt", "for_rest_statement",
  "jump_statement", "translation_unit", "external_declaration",
  "function_definition", "@6", "initialization_list", "initializer_list",
  "annotation", "annotation_list", "annotation_item", "ann_type",
  "ann_literal", "ann_numerical_constant", "ann_literal_constructor",
  "ann_value_list", "ann_literal_init_list", "register_specifier",
  "semantic", "type_info", "sampler_initializer", "sampler_init_list",
  "sampler_init_item", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,   293,   294,
     295,   296,   297,   298,   299,   300,   301,   302,   303,   304,
     305,   306,   307,   308,   309,   310,   311,   312,   313,   314,
     315,   316,   317,   318,   319,   320,   321,   322,   323,   324,
     325,   326,   327,   328,   329,   330,   331,   332,   333,   334,
     335,   336,   337,   338,   339,   340,   341,   342,   343,   344,
     345,   346,   347,   348,   349,   350,   351,   352,   353,   354,
     355,   356,   357,   358,   359,   360,   361,   362,   363,   364,
     365,   366,   367,   368,   369,   370,   371,   372,   373,   374,
     375,   376,   377,   378,   379,   380,   381,   382,   383,   384,
     385,   386,   387,   388,   389,   390,   391,   392,   393
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,   139,   140,   141,   141,   141,   141,   141,   142,   142,
     142,   142,   142,   142,   143,   144,   145,   145,   146,   146,
     147,   147,   148,   148,   149,   150,   150,   150,   151,   151,
     151,   151,   151,   152,   152,   152,   152,   153,   153,   153,
     153,   154,   154,   154,   155,   155,   155,   156,   156,   156,
     156,   156,   157,   157,   157,   158,   158,   159,   159,   160,
     160,   161,   161,   162,   162,   163,   163,   164,   164,   165,
     165,   166,   166,   166,   166,   166,   166,   166,   166,   166,
     166,   166,   167,   167,   168,   169,   169,   170,   170,   171,
     171,   172,   172,   173,   174,   174,   174,   174,   174,   174,
     175,   175,   175,   175,   176,   176,   176,   176,   177,   178,
     178,   178,   178,   178,   178,   178,   179,   179,   179,   179,
     179,   179,   179,   180,   180,   181,   181,   181,   181,   181,
     182,   182,   183,   183,   183,   183,   183,   183,   183,   183,
     183,   183,   183,   183,   183,   183,   183,   183,   183,   183,
     183,   183,   183,   183,   183,   183,   183,   183,   183,   183,
     183,   183,   183,   183,   183,   183,   183,   183,   183,   183,
     183,   183,   183,   183,   183,   183,   183,   183,   183,   183,
     183,   183,   183,   183,   183,   183,   183,   183,   183,   183,
     183,   183,   183,   183,   183,   183,   183,   183,   183,   183,
     184,   184,   185,   185,   186,   187,   187,   188,   188,   188,
     188,   189,   189,   189,   190,   191,   191,   192,   192,   192,
     192,   192,   193,   194,   195,   193,   196,   196,   197,   197,
     198,   198,   199,   199,   200,   201,   201,   202,   202,   204,
     203,   205,   203,   206,   203,   207,   207,   208,   208,   209,
     209,   210,   210,   210,   210,   210,   211,   211,   212,   212,
     212,   214,   213,   215,   215,   216,   216,   216,   216,   217,
     217,   218,   218,   219,   220,   220,   220,   220,   220,   220,
     220,   220,   220,   220,   220,   220,   220,   220,   220,   220,
     220,   220,   220,   220,   220,   221,   221,   221,   221,   222,
     222,   222,   223,   224,   224,   225,   226,   227,   228,   228,
     228,   228,   228,   228,   228,   228,   229,   229,   230,   230,
     231,   231,   231,   231,   231,   231
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     1,     1,     1,     1,     1,     3,     1,     4,
       1,     3,     2,     2,     1,     1,     1,     3,     2,     2,
       2,     1,     2,     3,     2,     1,     1,     1,     1,     2,
       2,     2,     4,     1,     1,     1,     1,     1,     3,     3,
       3,     1,     3,     3,     1,     3,     3,     1,     3,     3,
       3,     3,     1,     3,     3,     1,     3,     1,     3,     1,
       3,     1,     3,     1,     3,     1,     3,     1,     5,     1,
       3,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     3,     1,     2,     2,     2,     4,     1,
       1,     2,     3,     3,     2,     4,     3,     4,     5,     7,
       3,     2,     3,     2,     0,     1,     1,     1,     1,     1,
       4,     6,     7,     8,     9,     6,     1,     3,     5,     6,
       7,     8,     5,     1,     2,     1,     1,     2,     2,     1,
       1,     4,     1,     1,     1,     1,     1,     1,     6,     6,
       6,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       5,     4,     1,     2,     3,     1,     3,     1,     3,     4,
       6,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     2,     0,     0,     5,     1,     1,     2,     3,
       1,     2,     1,     2,     5,     3,     1,     1,     4,     0,
       6,     0,     8,     0,     7,     1,     1,     1,     0,     2,
       3,     2,     2,     2,     3,     2,     1,     2,     1,     1,
       1,     0,     3,     3,     4,     1,     1,     3,     3,     2,
       3,     1,     2,     5,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     4,     1,     3,     3,     5,     2,     0,     1,
       1,     1,     2,     2,     2,     3,     4,     3,     1,     2,
       4,     6,     6,     4,     6,     6
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint16 yydefact[] =
{
       0,   125,   126,   137,   133,   136,   135,   134,   150,   151,
     152,   153,   154,   155,   141,   142,   143,   144,   145,   146,
     147,   148,   149,   156,   157,   158,   159,   160,   161,   162,
     163,   164,   165,   166,   167,   168,   169,   170,   171,   172,
     173,   174,   175,   176,   177,   178,   179,   180,   181,   182,
     129,     0,   132,   185,   186,   189,   190,   195,   196,   197,
     194,   193,   187,   188,   191,   192,   184,     0,   183,   199,
     260,   259,   261,     0,    90,   104,     0,   109,   116,     0,
     123,   130,   198,     0,   256,   258,   128,   127,     0,     0,
       0,    85,     0,    87,   104,   105,   106,   107,    91,     0,
     104,     0,    86,   308,   124,     0,     1,   257,     0,     0,
       0,   202,     0,     0,     0,     0,   262,     0,    92,   101,
     103,   108,     0,   308,    93,     0,     0,     0,   311,   310,
     309,   117,     2,     5,     4,     6,    27,     0,     0,     0,
      35,    34,    36,    33,     3,     8,    28,    10,    15,    16,
       0,     0,    21,     0,    37,     0,    41,    44,    47,    52,
      55,    57,    59,    61,    63,    65,    67,    84,     0,    25,
       0,   207,     0,   205,   201,   203,     0,     0,     0,     0,
       0,   241,     0,     0,     0,     0,     0,   223,   228,   232,
      37,    69,    82,     0,   214,     0,   123,   217,   230,   216,
     215,     0,   218,   219,   220,   221,    88,    94,   100,   102,
       0,   110,   308,     0,     0,   307,   278,   274,   277,   279,
     276,   275,   280,   281,   282,   283,   284,   285,   286,   287,
     288,   289,   290,   291,   292,   293,   294,   269,     0,   271,
       0,   314,     0,   312,   313,     0,    29,    30,     0,   130,
      12,    13,     0,     0,    19,    18,     0,   132,    22,    24,
      31,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   131,   200,     0,     0,     0,   204,     0,     0,     0,
     252,   251,     0,   243,     0,   255,   253,     0,   239,   222,
       0,    72,    73,    75,    74,    77,    78,    79,    80,    81,
      76,    71,     0,     0,   233,   229,   231,     0,     0,     0,
      96,   308,     0,     0,   118,   308,     0,   270,   272,     0,
     315,     0,     0,   211,   122,   212,   213,     7,     0,     0,
      14,    26,    11,    17,    23,    38,    39,    40,    43,    42,
      45,    46,    50,    51,    48,    49,    53,    54,    56,    58,
      60,    62,    64,    66,     0,     0,   208,   206,   140,   138,
     139,     0,     0,     0,   254,     0,   224,    70,    83,     0,
      97,    95,   111,   308,   115,     0,   119,     0,     0,     0,
     265,   266,     0,    32,     9,     0,   209,     0,   246,   245,
     248,     0,   237,     0,     0,     0,    98,     0,   112,   120,
       0,   306,   301,   299,   300,   296,     0,     0,     0,   295,
     297,   298,     0,     0,   317,     0,   318,   263,     0,    68,
       0,     0,   247,     0,     0,   236,   234,     0,     0,   225,
       0,   113,     0,   121,   303,     0,     0,   273,     0,     0,
     316,   319,   264,   267,   268,   210,     0,   249,     0,     0,
       0,   227,   240,   226,    99,   114,   305,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   250,   244,   235,   238,
     304,   302,   323,     0,     0,   320,     0,     0,   242,     0,
       0,     0,     0,   325,   324,   322,   321
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,   144,   145,   146,   339,   147,   148,   149,   150,   151,
     152,   153,   190,   155,   156,   157,   158,   159,   160,   161,
     162,   163,   164,   165,   166,   191,   192,   312,   193,   168,
     194,   195,    73,    74,    75,   119,    98,    99,   120,    76,
      77,    78,    79,   169,    81,    82,   110,   111,   172,   173,
     334,   197,   198,   199,   200,   300,   405,   462,   463,   201,
     202,   203,   436,   404,   204,   375,   292,   372,   400,   433,
     434,   205,    83,    84,    85,    92,   335,   392,   128,   238,
     239,   240,   418,   444,   420,   445,   421,   129,   130,   131,
     336,   425,   426
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -387
static const yytype_int16 yypact[] =
{
    2208,    86,    36,  -387,  -387,  -387,  -387,  -387,  -387,  -387,
    -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,
    -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,
    -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,
    -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,
    -387,   -12,  -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,
    -387,  -387,  -387,  -387,  -387,  -387,  -387,   -14,  -387,  -387,
    -387,  -387,    32,    48,    38,    67,    11,  -387,    88,  2604,
    -387,    54,  -387,  1191,  -387,  -387,  -387,  -387,    72,  2604,
      45,  -387,    85,   118,    84,  -387,  -387,  -387,  -387,  2604,
     137,   202,  -387,    64,  -387,  1984,  -387,  -387,  2604,   207,
    2315,  -387,   174,   177,   189,   457,  -387,   225,  -387,  -387,
    -387,   227,  2604,    44,  -387,  1534,    39,     1,  -387,   182,
     -85,   192,   203,  -387,  -387,  -387,  -387,  1984,  1984,  1984,
    -387,  -387,  -387,  -387,  -387,  -387,    42,  -387,  -387,  -387,
     201,    46,  2095,   206,  -387,  1984,   115,   155,    58,   -22,
      40,   185,   187,   190,   222,   223,   -34,  -387,   208,  -387,
    2417,    57,    71,  -387,  -387,  -387,   238,   239,   240,   209,
     210,  -387,   216,   217,   215,  1648,   218,   221,  -387,  -387,
     196,  -387,  -387,    83,  -387,    32,   228,  -387,  -387,  -387,
    -387,   584,  -387,  -387,  -387,  -387,  -387,    26,  -387,  -387,
    1759,   220,   -32,   224,   230,  -387,  -387,  -387,  -387,  -387,
    -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,
    -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,    35,  -387,
     259,  -387,   263,  -387,   182,  1298,  -387,  -387,    66,   113,
    -387,  -387,  1984,  2519,  -387,  -387,  1984,   232,  -387,  -387,
    -387,  1984,  1984,  1984,  1984,  1984,  1984,  1984,  1984,  1984,
    1984,  1984,  1984,  1984,  1984,  1984,  1984,  1984,  1984,  1984,
    1984,  -387,  -387,  1984,   262,   207,  -387,   219,   226,   229,
    -387,  -387,   711,  -387,  1984,  -387,  -387,   114,  -387,  -387,
     711,  -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,  -387,
    -387,  -387,  1984,  1984,  -387,  -387,  -387,  1984,   156,  1298,
    -387,   -32,   233,  1298,   231,   -32,   265,  -387,  -387,   234,
    -387,   235,  1873,  -387,  -387,  -387,  -387,  -387,  1984,   241,
     242,  -387,   246,  -387,  -387,  -387,  -387,  -387,   115,   115,
     155,   155,    58,    58,    58,    58,   -22,   -22,    40,   185,
     187,   190,   222,   223,   136,   244,  -387,  -387,  -387,  -387,
    -387,   283,   965,    68,  -387,  1078,   711,  -387,  -387,   249,
    -387,  -387,   245,   -32,  -387,  1298,   250,   252,   247,    -3,
    -387,  -387,   122,  -387,  -387,  1984,   248,   255,  -387,  -387,
    1078,   711,   242,   269,   257,   237,   254,  1298,   256,  -387,
    1298,  -387,  -387,  -387,  -387,  -387,   160,   264,   253,  -387,
    -387,  -387,   258,   260,  -387,    31,  -387,  -387,  1409,  -387,
     278,  1984,  -387,   261,   267,   367,  -387,   266,   838,  -387,
     298,  -387,  1298,  -387,  -387,   163,   160,  -387,   -41,    -9,
    -387,  -387,  -387,  -387,  -387,  -387,    70,  1984,   838,   711,
    1298,  -387,  -387,  -387,  -387,  -387,  -387,   160,    73,   268,
     300,   301,   270,   302,   304,   271,   242,  -387,  -387,  -387,
    -387,  -387,  -387,   276,   272,  -387,   281,   273,  -387,   274,
     277,   279,   280,  -387,  -387,  -387,  -387
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -387,  -387,  -387,  -387,  -387,  -387,  -387,   141,  -387,  -387,
    -387,  -387,   -52,  -387,    23,    24,   -36,    25,   124,   128,
     132,   133,   131,   134,  -387,   -89,  -147,  -387,  -138,  -110,
      37,    49,  -387,  -387,  -387,   289,   318,   314,   293,  -387,
    -387,  -303,    50,     0,   282,  -387,   308,   -75,  -387,   135,
    -305,    47,  -198,  -304,  -387,  -387,  -387,   -40,   325,   123,
      52,  -387,  -387,    22,  -387,  -387,  -387,  -387,  -387,  -387,
    -387,  -387,  -387,   342,  -387,  -387,  -315,  -387,  -117,  -387,
     188,    41,  -387,  -386,  -387,   -19,  -387,  -111,  -387,  -119,
    -387,  -387,     3
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -90
static const yytype_int16 yytable[] =
{
      80,   248,   419,   316,   211,   258,   216,   217,   218,   219,
     220,   221,   241,   243,   381,   213,   167,   391,   384,   244,
     222,   223,   224,   225,   226,   227,   228,   229,   230,   231,
     232,   233,   234,   235,   236,   175,   167,    71,   242,    87,
     216,   217,   218,   219,   220,   221,   469,   297,   127,    72,
     112,   113,   114,   154,   222,   223,   224,   225,   226,   227,
     228,   229,   230,   231,   232,   233,   234,   235,   236,   279,
       1,     2,   403,   154,   470,    88,   268,   269,   472,   104,
     409,   480,   422,    80,   423,   246,   247,     1,     2,   109,
      86,   126,   471,   324,   371,   175,   320,   403,   333,   121,
     322,   127,   441,   260,   280,   443,   473,    89,   109,   344,
     109,   270,   271,   454,   340,   196,   422,   424,   423,    90,
      71,   167,   121,   214,   474,   100,   215,   330,    95,    96,
      97,    50,    72,   101,   461,   237,   102,   465,   250,   251,
     272,   273,   364,   317,   100,    95,    96,    97,    50,   318,
     319,   450,   266,   267,   461,   479,   373,    91,   154,   252,
      94,   210,   255,   253,    93,   377,   378,   126,   256,   327,
     109,   105,   333,   365,   283,   103,   333,   127,   316,   124,
     284,   125,   337,   -89,   401,   390,   475,   126,   313,   481,
     313,   108,   313,   285,   167,   467,   286,   127,    95,    96,
      97,   196,   382,   435,   115,   313,   386,   379,   314,   345,
     346,   347,   154,   154,   154,   154,   154,   154,   154,   154,
     154,   154,   154,   154,   154,   154,   154,   154,   167,   338,
     105,   154,   352,   353,   354,   355,   313,   402,   333,   374,
     214,   117,   427,   380,   428,   261,   262,   263,   429,   412,
     413,   414,   216,   217,   218,   219,   220,   221,   313,   395,
     333,   478,   402,   333,   408,   154,   222,   223,   224,   225,
     226,   227,   228,   229,   230,   231,   232,   233,   234,   235,
     236,   453,   264,   466,   265,   467,   393,   348,   349,   123,
     350,   351,   196,   456,   171,   333,   176,   356,   357,   177,
     196,   301,   302,   303,   304,   305,   306,   307,   308,   309,
     310,   178,   206,   333,   207,   127,   245,   254,   -26,   476,
     311,   259,   274,   275,   277,   276,   281,   278,   287,   288,
     289,   293,   294,   298,   290,   291,   412,   413,   414,   415,
     295,   299,   325,   -25,   323,   326,   329,   214,   -20,   366,
     397,   383,   387,   368,   389,   385,   437,   439,   388,   394,
     369,   -27,   396,   370,   313,   455,   416,   406,   411,   407,
     431,   430,   196,   438,   410,   196,   196,   440,   447,   446,
     442,   459,   448,   458,   449,   464,   457,   483,   484,   486,
     460,   487,   489,   482,   343,   485,   488,   491,   358,   493,
     196,   196,   494,   359,   495,   496,   490,   492,   360,   362,
     361,   208,   118,   363,   122,   209,   170,   116,   477,   398,
     367,   249,   432,   376,   399,   107,   328,   468,   451,   417,
       0,     0,     0,     0,     0,     0,     0,     0,   196,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   196,   196,
       1,     2,     3,     4,     5,     0,     6,     7,   179,   180,
     181,     0,   182,   183,   184,   185,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    41,
      42,    43,    44,    45,    46,    47,    48,    49,     0,     0,
       0,    50,    51,    52,   186,    53,    54,    55,    56,    57,
      58,    59,    60,    61,    62,    63,    64,    65,    66,    67,
       0,     0,    68,     0,   132,    69,   133,   134,   135,     0,
     136,     0,     0,   137,   138,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   139,     0,     0,     0,   187,   188,     0,     0,
       0,     0,   189,   140,   141,   142,   143,     1,     2,     3,
       4,     5,     0,     6,     7,   179,   180,   181,     0,   182,
     183,   184,   185,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,     0,     0,     0,    50,    51,
      52,   186,    53,    54,    55,    56,    57,    58,    59,    60,
      61,    62,    63,    64,    65,    66,    67,     0,     0,    68,
       0,   132,    69,   133,   134,   135,     0,   136,     0,     0,
     137,   138,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   139,
       0,     0,     0,   187,   315,     0,     0,     0,     0,   189,
     140,   141,   142,   143,     1,     2,     3,     4,     5,     0,
       6,     7,   179,   180,   181,     0,   182,   183,   184,   185,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    39,    40,    41,    42,    43,    44,    45,    46,    47,
      48,    49,     0,     0,     0,    50,    51,    52,   186,    53,
      54,    55,    56,    57,    58,    59,    60,    61,    62,    63,
      64,    65,    66,    67,     0,     0,    68,     0,   132,    69,
     133,   134,   135,     0,   136,     0,     0,   137,   138,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   139,     0,     0,     0,
     187,     0,     0,     0,     0,     0,   189,   140,   141,   142,
     143,     1,     2,     3,     4,     5,     0,     6,     7,   179,
     180,   181,     0,   182,   183,   184,   185,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    44,    45,    46,    47,    48,    49,     0,
       0,     0,    50,    51,    52,   186,    53,    54,    55,    56,
      57,    58,    59,    60,    61,    62,    63,    64,    65,    66,
      67,     0,     0,    68,     0,   132,    69,   133,   134,   135,
       0,   136,     0,     0,   137,   138,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   139,     0,     0,     0,   115,     0,     0,
       0,     0,     0,   189,   140,   141,   142,   143,     1,     2,
       3,     4,     5,     0,     6,     7,     0,     0,     0,     0,
       0,     0,     0,     0,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    40,    41,    42,    43,
      44,    45,    46,    47,    48,    49,     0,     0,     0,    50,
      51,    52,     0,    53,    54,    55,    56,    57,    58,    59,
      60,    61,    62,    63,    64,    65,    66,    67,     0,     0,
      68,     0,   132,    69,   133,   134,   135,     0,   136,     0,
       0,   137,   138,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     139,     1,     2,     3,     4,     5,     0,     6,     7,     0,
     189,   140,   141,   142,   143,     0,     0,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    44,    45,    46,    47,    48,    49,     0,
       0,     0,    50,    51,    52,     0,    53,    54,    55,    56,
      57,    58,    59,    60,    61,    62,    63,    64,    65,    66,
      67,     0,     0,    68,     0,   132,    69,   133,   134,   135,
       0,   136,     0,     0,   137,   138,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   106,     0,   139,     1,     2,     3,     4,     5,     0,
       6,     7,     0,     0,   140,   141,   142,   143,     0,     0,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    39,    40,    41,    42,    43,    44,    45,    46,    47,
      48,    49,     0,     0,     0,    50,    51,    52,     0,    53,
      54,    55,    56,    57,    58,    59,    60,    61,    62,    63,
      64,    65,    66,    67,     0,     0,    68,     0,     0,    69,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     3,     4,     5,     0,     6,     7,     0,
       0,     0,     0,     0,     0,     0,    70,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    44,    45,    46,    47,    48,    49,     0,
       0,     0,     0,    51,    52,     0,    53,    54,    55,    56,
      57,    58,    59,    60,    61,    62,    63,    64,    65,    66,
      67,     0,     0,    68,   331,   132,    69,   133,   134,   135,
       0,   136,     0,     0,   137,   138,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   139,     3,     4,     5,   332,     6,     7,
       0,     0,     0,     0,   140,   141,   142,   143,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      40,    41,    42,    43,    44,    45,    46,    47,    48,    49,
       0,     0,     0,     0,    51,    52,     0,    53,    54,    55,
      56,    57,    58,    59,    60,    61,    62,    63,    64,    65,
      66,    67,     0,     0,    68,     0,   132,    69,   133,   134,
     135,     0,   136,     0,     0,   137,   138,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   139,     0,     0,     0,   332,   452,
       0,     0,     0,     0,     0,   140,   141,   142,   143,     3,
       4,     5,     0,     6,     7,     0,     0,     0,     0,     0,
       0,     0,     0,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,     0,     0,     0,     0,    51,
      52,     0,    53,    54,    55,    56,    57,    58,    59,    60,
      61,    62,    63,    64,    65,    66,    67,     0,     0,    68,
       0,   132,    69,   133,   134,   135,     0,   136,     0,     0,
     137,   138,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   139,
       0,     0,   212,     3,     4,     5,     0,     6,     7,     0,
     140,   141,   142,   143,     0,     0,     0,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    44,    45,    46,    47,    48,    49,     0,
       0,     0,     0,    51,    52,     0,    53,    54,    55,    56,
      57,    58,    59,    60,    61,    62,    63,    64,    65,    66,
      67,     0,     0,    68,     0,   132,    69,   133,   134,   135,
       0,   136,     0,     0,   137,   138,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   139,     3,     4,     5,     0,     6,     7,
       0,     0,     0,   296,   140,   141,   142,   143,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      40,    41,    42,    43,    44,    45,    46,    47,    48,    49,
       0,     0,     0,     0,    51,    52,     0,    53,    54,    55,
      56,    57,    58,    59,    60,    61,    62,    63,    64,    65,
      66,    67,     0,     0,    68,     0,   132,    69,   133,   134,
     135,     0,   136,     0,     0,   137,   138,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   139,     0,     0,   321,     3,     4,
       5,     0,     6,     7,     0,   140,   141,   142,   143,     0,
       0,     0,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    41,    42,    43,    44,    45,
      46,    47,    48,    49,     0,     0,     0,     0,    51,    52,
       0,    53,    54,    55,    56,    57,    58,    59,    60,    61,
      62,    63,    64,    65,    66,    67,     0,     0,    68,     0,
     132,    69,   133,   134,   135,     0,   136,     0,     0,   137,
     138,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   139,     3,
       4,     5,   332,     6,     7,     0,     0,     0,     0,   140,
     141,   142,   143,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,     0,     0,     0,     0,    51,
      52,     0,    53,    54,    55,    56,    57,    58,    59,    60,
      61,    62,    63,    64,    65,    66,    67,     0,     0,    68,
       0,   132,    69,   133,   134,   135,     0,   136,     0,     0,
     137,   138,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   139,
       3,     4,     5,     0,     6,     7,     0,     0,     0,     0,
     140,   141,   142,   143,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    40,    41,    42,    43,
      44,    45,    46,    47,    48,    49,     0,     0,     0,     0,
      51,   257,     0,    53,    54,    55,    56,    57,    58,    59,
      60,    61,    62,    63,    64,    65,    66,    67,     0,     0,
      68,     0,   132,    69,   133,   134,   135,     0,   136,     0,
       0,   137,   138,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     139,     1,     2,     3,     4,     5,     0,     6,     7,     0,
       0,   140,   141,   142,   143,     0,     0,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    44,    45,    46,    47,    48,    49,     0,
       0,     0,    50,    51,    52,     0,    53,    54,    55,    56,
      57,    58,    59,    60,    61,    62,    63,    64,    65,    66,
      67,     0,     0,    68,     0,     0,    69,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       3,     4,     5,     0,     6,     7,     0,     0,     0,     0,
       0,     0,     0,    70,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    40,    41,    42,    43,
      44,    45,    46,    47,    48,    49,     0,     0,     0,     0,
      51,    52,     0,    53,    54,    55,    56,    57,    58,    59,
      60,    61,    62,    63,    64,    65,    66,    67,     0,     0,
      68,     0,     0,    69,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     3,     4,     5,     0,     6,     7,     0,     0,
       0,     0,     0,     0,     0,   174,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    41,
      42,    43,    44,    45,    46,    47,    48,    49,     0,     0,
       0,     0,    51,    52,     0,    53,    54,    55,    56,    57,
      58,    59,    60,    61,    62,    63,    64,    65,    66,    67,
       0,     0,    68,     0,     0,    69,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     3,     4,     5,     0,     6,     7,
       0,     0,     0,     0,     0,     0,     0,   282,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      40,    41,    42,    43,    44,    45,    46,    47,    48,    49,
       0,     0,     0,     0,    51,    52,     0,    53,    54,    55,
      56,    57,    58,    59,    60,    61,    62,    63,    64,    65,
      66,    67,     0,     0,    68,     0,   341,    69,     0,     3,
       4,     5,   342,     6,     7,     0,     0,     0,     0,     0,
       0,     0,     0,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,     0,     0,     0,     0,    51,
      52,     0,    53,    54,    55,    56,    57,    58,    59,    60,
      61,    62,    63,    64,    65,    66,    67,     0,     0,    68,
       0,     0,    69
};

static const yytype_int16 yycheck[] =
{
       0,   139,   388,   201,   123,   152,     5,     6,     7,     8,
       9,    10,   129,   130,   319,   125,   105,   332,   323,   130,
      19,    20,    21,    22,    23,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,   110,   125,     0,   123,     3,
       5,     6,     7,     8,     9,    10,    87,   185,   133,     0,
       5,     6,     7,   105,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,   103,
       3,     4,   375,   125,   115,    87,    98,    99,    87,    79,
     385,   467,    85,    83,    87,   137,   138,     3,     4,    89,
       4,   123,   133,   212,   292,   170,   207,   400,   245,    99,
     210,   133,   407,   155,   138,   410,   115,   119,   108,   256,
     110,   133,   134,   428,   252,   115,    85,   120,    87,   133,
      83,   210,   122,    84,   133,    75,    87,   244,    61,    62,
      63,    64,    83,   122,   438,   134,   125,   442,    96,    97,
     100,   101,   280,   117,    94,    61,    62,    63,    64,   123,
     124,   120,    94,    95,   458,   460,   294,   125,   210,   117,
     122,   117,   116,   121,   116,   312,   313,   123,   122,   134,
     170,   117,   319,   283,   117,    87,   323,   133,   376,   115,
     123,   117,   116,   116,   116,   332,   116,   123,   122,   116,
     122,   119,   122,   122,   283,   122,   125,   133,    61,    62,
      63,   201,   321,   401,   119,   122,   325,   317,   125,   261,
     262,   263,   264,   265,   266,   267,   268,   269,   270,   271,
     272,   273,   274,   275,   276,   277,   278,   279,   317,   116,
     117,   283,   268,   269,   270,   271,   122,   375,   385,   125,
      84,   123,   120,    87,   122,   130,   131,   132,   395,    89,
      90,    91,     5,     6,     7,     8,     9,    10,   122,   123,
     407,   459,   400,   410,   383,   317,    19,    20,    21,    22,
      23,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,   428,   127,   120,   129,   122,   338,   264,   265,    87,
     266,   267,   292,   431,    87,   442,   122,   272,   273,   122,
     300,   105,   106,   107,   108,   109,   110,   111,   112,   113,
     114,   122,    87,   460,    87,   133,   124,   116,   115,   457,
     124,   115,   137,   136,   102,   135,   118,   104,    90,    90,
      90,   115,   115,   115,   125,   125,    89,    90,    91,    92,
     125,   120,   118,   115,   124,   115,    87,    84,   116,    87,
      67,   118,    87,   134,   119,   124,    87,   120,   124,   118,
     134,   115,   118,   134,   122,    87,   119,   118,   116,   124,
     115,   123,   372,   116,   124,   375,   376,   123,   125,   115,
     124,    14,   124,   116,   124,    87,   125,    87,    87,    87,
     124,    87,   116,   125,   253,   125,   125,   116,   274,   125,
     400,   401,   125,   275,   125,   125,   134,   134,   276,   278,
     277,   122,    94,   279,   100,   122,   108,    92,   458,   372,
     285,   139,   400,   300,   372,    83,   238,   446,   425,   388,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   438,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   458,   459,
       3,     4,     5,     6,     7,    -1,     9,    10,    11,    12,
      13,    -1,    15,    16,    17,    18,    19,    20,    21,    22,
      23,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    41,    42,
      43,    44,    45,    46,    47,    48,    49,    50,    51,    52,
      53,    54,    55,    56,    57,    58,    59,    60,    -1,    -1,
      -1,    64,    65,    66,    67,    68,    69,    70,    71,    72,
      73,    74,    75,    76,    77,    78,    79,    80,    81,    82,
      -1,    -1,    85,    -1,    87,    88,    89,    90,    91,    -1,
      93,    -1,    -1,    96,    97,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   115,    -1,    -1,    -1,   119,   120,    -1,    -1,
      -1,    -1,   125,   126,   127,   128,   129,     3,     4,     5,
       6,     7,    -1,     9,    10,    11,    12,    13,    -1,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    41,    42,    43,    44,    45,
      46,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      56,    57,    58,    59,    60,    -1,    -1,    -1,    64,    65,
      66,    67,    68,    69,    70,    71,    72,    73,    74,    75,
      76,    77,    78,    79,    80,    81,    82,    -1,    -1,    85,
      -1,    87,    88,    89,    90,    91,    -1,    93,    -1,    -1,
      96,    97,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   115,
      -1,    -1,    -1,   119,   120,    -1,    -1,    -1,    -1,   125,
     126,   127,   128,   129,     3,     4,     5,     6,     7,    -1,
       9,    10,    11,    12,    13,    -1,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    41,    42,    43,    44,    45,    46,    47,    48,
      49,    50,    51,    52,    53,    54,    55,    56,    57,    58,
      59,    60,    -1,    -1,    -1,    64,    65,    66,    67,    68,
      69,    70,    71,    72,    73,    74,    75,    76,    77,    78,
      79,    80,    81,    82,    -1,    -1,    85,    -1,    87,    88,
      89,    90,    91,    -1,    93,    -1,    -1,    96,    97,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,
     119,    -1,    -1,    -1,    -1,    -1,   125,   126,   127,   128,
     129,     3,     4,     5,     6,     7,    -1,     9,    10,    11,
      12,    13,    -1,    15,    16,    17,    18,    19,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    41,
      42,    43,    44,    45,    46,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    57,    58,    59,    60,    -1,
      -1,    -1,    64,    65,    66,    67,    68,    69,    70,    71,
      72,    73,    74,    75,    76,    77,    78,    79,    80,    81,
      82,    -1,    -1,    85,    -1,    87,    88,    89,    90,    91,
      -1,    93,    -1,    -1,    96,    97,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   115,    -1,    -1,    -1,   119,    -1,    -1,
      -1,    -1,    -1,   125,   126,   127,   128,   129,     3,     4,
       5,     6,     7,    -1,     9,    10,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    -1,    -1,    -1,    64,
      65,    66,    -1,    68,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    -1,    -1,
      85,    -1,    87,    88,    89,    90,    91,    -1,    93,    -1,
      -1,    96,    97,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     115,     3,     4,     5,     6,     7,    -1,     9,    10,    -1,
     125,   126,   127,   128,   129,    -1,    -1,    19,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    41,
      42,    43,    44,    45,    46,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    57,    58,    59,    60,    -1,
      -1,    -1,    64,    65,    66,    -1,    68,    69,    70,    71,
      72,    73,    74,    75,    76,    77,    78,    79,    80,    81,
      82,    -1,    -1,    85,    -1,    87,    88,    89,    90,    91,
      -1,    93,    -1,    -1,    96,    97,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,     0,    -1,   115,     3,     4,     5,     6,     7,    -1,
       9,    10,    -1,    -1,   126,   127,   128,   129,    -1,    -1,
      19,    20,    21,    22,    23,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    41,    42,    43,    44,    45,    46,    47,    48,
      49,    50,    51,    52,    53,    54,    55,    56,    57,    58,
      59,    60,    -1,    -1,    -1,    64,    65,    66,    -1,    68,
      69,    70,    71,    72,    73,    74,    75,    76,    77,    78,
      79,    80,    81,    82,    -1,    -1,    85,    -1,    -1,    88,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,     5,     6,     7,    -1,     9,    10,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   125,    19,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    41,
      42,    43,    44,    45,    46,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    57,    58,    59,    60,    -1,
      -1,    -1,    -1,    65,    66,    -1,    68,    69,    70,    71,
      72,    73,    74,    75,    76,    77,    78,    79,    80,    81,
      82,    -1,    -1,    85,    86,    87,    88,    89,    90,    91,
      -1,    93,    -1,    -1,    96,    97,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   115,     5,     6,     7,   119,     9,    10,
      -1,    -1,    -1,    -1,   126,   127,   128,   129,    19,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    44,    45,    46,    47,    48,    49,    50,
      51,    52,    53,    54,    55,    56,    57,    58,    59,    60,
      -1,    -1,    -1,    -1,    65,    66,    -1,    68,    69,    70,
      71,    72,    73,    74,    75,    76,    77,    78,    79,    80,
      81,    82,    -1,    -1,    85,    -1,    87,    88,    89,    90,
      91,    -1,    93,    -1,    -1,    96,    97,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,   119,   120,
      -1,    -1,    -1,    -1,    -1,   126,   127,   128,   129,     5,
       6,     7,    -1,     9,    10,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    19,    20,    21,    22,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    41,    42,    43,    44,    45,
      46,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      56,    57,    58,    59,    60,    -1,    -1,    -1,    -1,    65,
      66,    -1,    68,    69,    70,    71,    72,    73,    74,    75,
      76,    77,    78,    79,    80,    81,    82,    -1,    -1,    85,
      -1,    87,    88,    89,    90,    91,    -1,    93,    -1,    -1,
      96,    97,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   115,
      -1,    -1,   118,     5,     6,     7,    -1,     9,    10,    -1,
     126,   127,   128,   129,    -1,    -1,    -1,    19,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    41,
      42,    43,    44,    45,    46,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    57,    58,    59,    60,    -1,
      -1,    -1,    -1,    65,    66,    -1,    68,    69,    70,    71,
      72,    73,    74,    75,    76,    77,    78,    79,    80,    81,
      82,    -1,    -1,    85,    -1,    87,    88,    89,    90,    91,
      -1,    93,    -1,    -1,    96,    97,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   115,     5,     6,     7,    -1,     9,    10,
      -1,    -1,    -1,   125,   126,   127,   128,   129,    19,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    44,    45,    46,    47,    48,    49,    50,
      51,    52,    53,    54,    55,    56,    57,    58,    59,    60,
      -1,    -1,    -1,    -1,    65,    66,    -1,    68,    69,    70,
      71,    72,    73,    74,    75,    76,    77,    78,    79,    80,
      81,    82,    -1,    -1,    85,    -1,    87,    88,    89,    90,
      91,    -1,    93,    -1,    -1,    96,    97,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   115,    -1,    -1,   118,     5,     6,
       7,    -1,     9,    10,    -1,   126,   127,   128,   129,    -1,
      -1,    -1,    19,    20,    21,    22,    23,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    40,    41,    42,    43,    44,    45,    46,
      47,    48,    49,    50,    51,    52,    53,    54,    55,    56,
      57,    58,    59,    60,    -1,    -1,    -1,    -1,    65,    66,
      -1,    68,    69,    70,    71,    72,    73,    74,    75,    76,
      77,    78,    79,    80,    81,    82,    -1,    -1,    85,    -1,
      87,    88,    89,    90,    91,    -1,    93,    -1,    -1,    96,
      97,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   115,     5,
       6,     7,   119,     9,    10,    -1,    -1,    -1,    -1,   126,
     127,   128,   129,    19,    20,    21,    22,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    41,    42,    43,    44,    45,
      46,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      56,    57,    58,    59,    60,    -1,    -1,    -1,    -1,    65,
      66,    -1,    68,    69,    70,    71,    72,    73,    74,    75,
      76,    77,    78,    79,    80,    81,    82,    -1,    -1,    85,
      -1,    87,    88,    89,    90,    91,    -1,    93,    -1,    -1,
      96,    97,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   115,
       5,     6,     7,    -1,     9,    10,    -1,    -1,    -1,    -1,
     126,   127,   128,   129,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    -1,    -1,    -1,    -1,
      65,    66,    -1,    68,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    -1,    -1,
      85,    -1,    87,    88,    89,    90,    91,    -1,    93,    -1,
      -1,    96,    97,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     115,     3,     4,     5,     6,     7,    -1,     9,    10,    -1,
      -1,   126,   127,   128,   129,    -1,    -1,    19,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    41,
      42,    43,    44,    45,    46,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    57,    58,    59,    60,    -1,
      -1,    -1,    64,    65,    66,    -1,    68,    69,    70,    71,
      72,    73,    74,    75,    76,    77,    78,    79,    80,    81,
      82,    -1,    -1,    85,    -1,    -1,    88,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
       5,     6,     7,    -1,     9,    10,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   125,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    -1,    -1,    -1,    -1,
      65,    66,    -1,    68,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    -1,    -1,
      85,    -1,    -1,    88,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,     5,     6,     7,    -1,     9,    10,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   120,    19,    20,    21,    22,
      23,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    41,    42,
      43,    44,    45,    46,    47,    48,    49,    50,    51,    52,
      53,    54,    55,    56,    57,    58,    59,    60,    -1,    -1,
      -1,    -1,    65,    66,    -1,    68,    69,    70,    71,    72,
      73,    74,    75,    76,    77,    78,    79,    80,    81,    82,
      -1,    -1,    85,    -1,    -1,    88,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,     5,     6,     7,    -1,     9,    10,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   120,    19,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    44,    45,    46,    47,    48,    49,    50,
      51,    52,    53,    54,    55,    56,    57,    58,    59,    60,
      -1,    -1,    -1,    -1,    65,    66,    -1,    68,    69,    70,
      71,    72,    73,    74,    75,    76,    77,    78,    79,    80,
      81,    82,    -1,    -1,    85,    -1,    87,    88,    -1,     5,
       6,     7,    93,     9,    10,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    19,    20,    21,    22,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    41,    42,    43,    44,    45,
      46,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      56,    57,    58,    59,    60,    -1,    -1,    -1,    -1,    65,
      66,    -1,    68,    69,    70,    71,    72,    73,    74,    75,
      76,    77,    78,    79,    80,    81,    82,    -1,    -1,    85,
      -1,    -1,    88
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     3,     4,     5,     6,     7,     9,    10,    19,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    44,    45,    46,    47,    48,    49,    50,
      51,    52,    53,    54,    55,    56,    57,    58,    59,    60,
      64,    65,    66,    68,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    85,    88,
     125,   169,   170,   171,   172,   173,   178,   179,   180,   181,
     182,   183,   184,   211,   212,   213,     4,     3,    87,   119,
     133,   125,   214,   116,   122,    61,    62,    63,   175,   176,
     181,   122,   125,    87,   182,   117,     0,   212,   119,   182,
     185,   186,     5,     6,     7,   119,   197,   123,   175,   174,
     177,   182,   176,    87,   115,   117,   123,   133,   217,   226,
     227,   228,    87,    89,    90,    91,    93,    96,    97,   115,
     126,   127,   128,   129,   140,   141,   142,   144,   145,   146,
     147,   148,   149,   150,   151,   152,   153,   154,   155,   156,
     157,   158,   159,   160,   161,   162,   163,   164,   168,   182,
     185,    87,   187,   188,   120,   186,   122,   122,   122,    11,
      12,    13,    15,    16,    17,    18,    67,   119,   120,   125,
     151,   164,   165,   167,   169,   170,   182,   190,   191,   192,
     193,   198,   199,   200,   203,   210,    87,    87,   174,   177,
     117,   228,   118,   168,    84,    87,     5,     6,     7,     8,
       9,    10,    19,    20,    21,    22,    23,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,   134,   218,   219,
     220,   217,   123,   217,   226,   124,   151,   151,   167,   183,
      96,    97,   117,   121,   116,   116,   122,    66,   165,   115,
     151,   130,   131,   132,   127,   129,    94,    95,    98,    99,
     133,   134,   100,   101,   137,   136,   135,   102,   104,   103,
     138,   118,   120,   117,   123,   122,   125,    90,    90,    90,
     125,   125,   205,   115,   115,   125,   125,   167,   115,   120,
     194,   105,   106,   107,   108,   109,   110,   111,   112,   113,
     114,   124,   166,   122,   125,   120,   191,   117,   123,   124,
     226,   118,   168,   124,   228,   118,   115,   134,   219,    87,
     217,    86,   119,   165,   189,   215,   229,   116,   116,   143,
     167,    87,    93,   146,   165,   151,   151,   151,   153,   153,
     154,   154,   155,   155,   155,   155,   156,   156,   157,   158,
     159,   160,   161,   162,   167,   168,    87,   188,   134,   134,
     134,   191,   206,   167,   125,   204,   198,   165,   165,   168,
      87,   189,   228,   118,   189,   124,   228,    87,   124,   119,
     165,   215,   216,   151,   118,   123,   118,    67,   190,   199,
     207,   116,   167,   180,   202,   195,   118,   124,   228,   189,
     124,   116,    89,    90,    91,    92,   119,   220,   221,   222,
     223,   225,    85,    87,   120,   230,   231,   120,   122,   165,
     123,   115,   202,   208,   209,   191,   201,    87,   116,   120,
     123,   189,   124,   189,   222,   224,   115,   125,   124,   124,
     120,   231,   120,   165,   215,    87,   167,   125,   116,    14,
     124,   192,   196,   197,    87,   189,   120,   122,   224,    87,
     115,   133,    87,   115,   133,   116,   167,   196,   191,   189,
     222,   116,   125,    87,    87,   125,    87,    87,   125,   116,
     134,   116,   134,   125,   125,   125,   125
};

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK (1);						\
      goto yybackup;						\
    }								\
  else								\
    {								\
      yyerror (parseContext, YY_("syntax error: cannot back up")); \
      YYERROR;							\
    }								\
while (YYID (0))


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (YYID (N))                                                    \
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (YYID (0))
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
	      (Loc).first_line, (Loc).first_column,	\
	      (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (&yylval, YYLEX_PARAM)
#else
# define YYLEX yylex (&yylval, parseContext)
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (YYID (0))

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)			  \
do {									  \
  if (yydebug)								  \
    {									  \
      YYFPRINTF (stderr, "%s ", Title);					  \
      yy_symbol_print (stderr,						  \
		  Type, Value, parseContext); \
      YYFPRINTF (stderr, "\n");						  \
    }									  \
} while (YYID (0))


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, TParseContext& parseContext)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep, parseContext)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    TParseContext& parseContext;
#endif
{
  if (!yyvaluep)
    return;
  YYUSE (parseContext);
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# else
  YYUSE (yyoutput);
# endif
  switch (yytype)
    {
      default:
	break;
    }
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, TParseContext& parseContext)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep, parseContext)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    TParseContext& parseContext;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep, parseContext);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_stack_print (yytype_int16 *bottom, yytype_int16 *top)
#else
static void
yy_stack_print (bottom, top)
    yytype_int16 *bottom;
    yytype_int16 *top;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (; bottom <= top; ++bottom)
    YYFPRINTF (stderr, " %d", *bottom);
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (YYID (0))


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_reduce_print (YYSTYPE *yyvsp, int yyrule, TParseContext& parseContext)
#else
static void
yy_reduce_print (yyvsp, yyrule, parseContext)
    YYSTYPE *yyvsp;
    int yyrule;
    TParseContext& parseContext;
#endif
{
  int yynrhs = yyr2[yyrule];
  int yyi;
  unsigned long int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
	     yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      fprintf (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr, yyrhs[yyprhs[yyrule] + yyi],
		       &(yyvsp[(yyi + 1) - (yynrhs)])
		       		       , parseContext);
      fprintf (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, Rule, parseContext); \
} while (YYID (0))

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static YYSIZE_T
yystrlen (const char *yystr)
#else
static YYSIZE_T
yystrlen (yystr)
    const char *yystr;
#endif
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static char *
yystpcpy (char *yydest, const char *yysrc)
#else
static char *
yystpcpy (yydest, yysrc)
    char *yydest;
    const char *yysrc;
#endif
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
	switch (*++yyp)
	  {
	  case '\'':
	  case ',':
	    goto do_not_strip_quotes;

	  case '\\':
	    if (*++yyp != '\\')
	      goto do_not_strip_quotes;
	    /* Fall through.  */
	  default:
	    if (yyres)
	      yyres[yyn] = *yyp;
	    yyn++;
	    break;

	  case '"':
	    if (yyres)
	      yyres[yyn] = '\0';
	    return yyn;
	  }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into YYRESULT an error message about the unexpected token
   YYCHAR while in state YYSTATE.  Return the number of bytes copied,
   including the terminating null byte.  If YYRESULT is null, do not
   copy anything; just return the number of bytes that would be
   copied.  As a special case, return 0 if an ordinary "syntax error"
   message will do.  Return YYSIZE_MAXIMUM if overflow occurs during
   size calculation.  */
static YYSIZE_T
yysyntax_error (char *yyresult, int yystate, int yychar)
{
  int yyn = yypact[yystate];

  if (! (YYPACT_NINF < yyn && yyn <= YYLAST))
    return 0;
  else
    {
      int yytype = YYTRANSLATE (yychar);
      YYSIZE_T yysize0 = yytnamerr (0, yytname[yytype]);
      YYSIZE_T yysize = yysize0;
      YYSIZE_T yysize1;
      int yysize_overflow = 0;
      enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
      char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
      int yyx;

# if 0
      /* This is so xgettext sees the translatable formats that are
	 constructed on the fly.  */
      YY_("syntax error, unexpected %s");
      YY_("syntax error, unexpected %s, expecting %s");
      YY_("syntax error, unexpected %s, expecting %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s");
# endif
      char *yyfmt;
      char const *yyf;
      static char const yyunexpected[] = "syntax error, unexpected %s";
      static char const yyexpecting[] = ", expecting %s";
      static char const yyor[] = " or %s";
      char yyformat[sizeof yyunexpected
		    + sizeof yyexpecting - 1
		    + ((YYERROR_VERBOSE_ARGS_MAXIMUM - 2)
		       * (sizeof yyor - 1))];
      char const *yyprefix = yyexpecting;

      /* Start YYX at -YYN if negative to avoid negative indexes in
	 YYCHECK.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;

      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yycount = 1;

      yyarg[0] = yytname[yytype];
      yyfmt = yystpcpy (yyformat, yyunexpected);

      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	  {
	    if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
	      {
		yycount = 1;
		yysize = yysize0;
		yyformat[sizeof yyunexpected - 1] = '\0';
		break;
	      }
	    yyarg[yycount++] = yytname[yyx];
	    yysize1 = yysize + yytnamerr (0, yytname[yyx]);
	    yysize_overflow |= (yysize1 < yysize);
	    yysize = yysize1;
	    yyfmt = yystpcpy (yyfmt, yyprefix);
	    yyprefix = yyor;
	  }

      yyf = YY_(yyformat);
      yysize1 = yysize + yystrlen (yyf);
      yysize_overflow |= (yysize1 < yysize);
      yysize = yysize1;

      if (yysize_overflow)
	return YYSIZE_MAXIMUM;

      if (yyresult)
	{
	  /* Avoid sprintf, as that infringes on the user's name space.
	     Don't have undefined behavior even if the translation
	     produced a string with the wrong number of "%s"s.  */
	  char *yyp = yyresult;
	  int yyi = 0;
	  while ((*yyp = *yyf) != '\0')
	    {
	      if (*yyp == '%' && yyf[1] == 's' && yyi < yycount)
		{
		  yyp += yytnamerr (yyp, yyarg[yyi++]);
		  yyf += 2;
		}
	      else
		{
		  yyp++;
		  yyf++;
		}
	    }
	}
      return yysize;
    }
}
#endif /* YYERROR_VERBOSE */


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep, TParseContext& parseContext)
#else
static void
yydestruct (yymsg, yytype, yyvaluep, parseContext)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
    TParseContext& parseContext;
#endif
{
  YYUSE (yyvaluep);
  YYUSE (parseContext);

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {

      default:
	break;
    }
}


/* Prevent warnings from -Wmissing-prototypes.  */

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (TParseContext& parseContext);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */






/*----------.
| yyparse.  |
`----------*/

#ifdef YYPARSE_PARAM
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void *YYPARSE_PARAM)
#else
int
yyparse (YYPARSE_PARAM)
    void *YYPARSE_PARAM;
#endif
#else /* ! YYPARSE_PARAM */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (TParseContext& parseContext)
#else
int
yyparse (parseContext)
    TParseContext& parseContext;
#endif
#endif
{
  /* The look-ahead symbol.  */
int yychar;

/* The semantic value of the look-ahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;

  int yystate;
  int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Look-ahead token as an internal (translated) token number.  */
  int yytoken = 0;
#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack.  */
  yytype_int16 yyssa[YYINITDEPTH];
  yytype_int16 *yyss = yyssa;
  yytype_int16 *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  YYSTYPE *yyvsp;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;


  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack.  Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	yytype_int16 *yyss1 = yyss;


	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),

		    &yystacksize);

	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	yytype_int16 *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyexhaustedlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);

#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;


      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     look-ahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to look-ahead token.  */
  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a look-ahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid look-ahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the look-ahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  yystate = yyn;
  *++yyvsp = yylval;

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:
#line 179 "hlslang.y"
    {
        // The symbol table search was done in the lexical phase
        const TSymbol* symbol = (yyvsp[(1) - (1)].lex).symbol;
        const TVariable* variable;
        if (symbol == 0) {
            parseContext.error((yyvsp[(1) - (1)].lex).line, "undeclared identifier", (yyvsp[(1) - (1)].lex).string->c_str(), "");
            parseContext.recover();
            TType type(EbtFloat, EbpUndefined);
            TVariable* fakeVariable = new TVariable((yyvsp[(1) - (1)].lex).string, type);
            parseContext.symbolTable.insert(*fakeVariable);
            variable = fakeVariable;
        } else {
            // This identifier can only be a variable type symbol 
            if (! symbol->isVariable()) {
                parseContext.error((yyvsp[(1) - (1)].lex).line, "variable expected", (yyvsp[(1) - (1)].lex).string->c_str(), "");
                parseContext.recover();
            }
            variable = static_cast<const TVariable*>(symbol);
        }

        // don't delete $1.string, it's used by error recovery, and the pool
        // pop will reclaim the memory
		
		if (variable->getType().getQualifier() == EvqConst && variable->constValue)
		{
			TIntermConstant* c = ir_add_constant(variable->getType(), (yyvsp[(1) - (1)].lex).line);
			c->copyValuesFrom(*variable->constValue);
			(yyval.interm.intermTypedNode) = c;
		}
		else
		{
			TIntermSymbol* sym = ir_add_symbol(variable, (yyvsp[(1) - (1)].lex).line);
			(yyval.interm.intermTypedNode) = sym;
		}
    ;}
    break;

  case 3:
#line 217 "hlslang.y"
    {
        (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode);
    ;}
    break;

  case 4:
#line 220 "hlslang.y"
    {
        TIntermConstant* constant = ir_add_constant(TType(EbtInt, EbpUndefined, EvqConst), (yyvsp[(1) - (1)].lex).line);
		constant->setValue((yyvsp[(1) - (1)].lex).i);
		(yyval.interm.intermTypedNode) = constant;
    ;}
    break;

  case 5:
#line 225 "hlslang.y"
    {
        TIntermConstant* constant = ir_add_constant(TType(EbtFloat, EbpUndefined, EvqConst), (yyvsp[(1) - (1)].lex).line);
		constant->setValue((yyvsp[(1) - (1)].lex).f);
		(yyval.interm.intermTypedNode) = constant;
    ;}
    break;

  case 6:
#line 230 "hlslang.y"
    {
        TIntermConstant* constant = ir_add_constant(TType(EbtBool, EbpUndefined, EvqConst), (yyvsp[(1) - (1)].lex).line);
		constant->setValue((yyvsp[(1) - (1)].lex).b);
		(yyval.interm.intermTypedNode) = constant;
    ;}
    break;

  case 7:
#line 235 "hlslang.y"
    {
        (yyval.interm.intermTypedNode) = (yyvsp[(2) - (3)].interm.intermTypedNode);
    ;}
    break;

  case 8:
#line 241 "hlslang.y"
    { 
        (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode);
    ;}
    break;

  case 9:
#line 244 "hlslang.y"
    {
        if (!(yyvsp[(1) - (4)].interm.intermTypedNode)) {
            parseContext.error((yyvsp[(2) - (4)].lex).line, " left of '[' is null ", "expression", "");
            YYERROR;
        }
        if (!(yyvsp[(1) - (4)].interm.intermTypedNode)->isArray() && !(yyvsp[(1) - (4)].interm.intermTypedNode)->isMatrix() && !(yyvsp[(1) - (4)].interm.intermTypedNode)->isVector()) {
            if ((yyvsp[(1) - (4)].interm.intermTypedNode)->getAsSymbolNode())
                parseContext.error((yyvsp[(2) - (4)].lex).line, " left of '[' is not of type array, matrix, or vector ", (yyvsp[(1) - (4)].interm.intermTypedNode)->getAsSymbolNode()->getSymbol().c_str(), "");
            else
                parseContext.error((yyvsp[(2) - (4)].lex).line, " left of '[' is not of type array, matrix, or vector ", "expression", "");
            parseContext.recover();
        }
		if ((yyvsp[(3) - (4)].interm.intermTypedNode)->getQualifier() == EvqConst) {
			if (((yyvsp[(1) - (4)].interm.intermTypedNode)->isVector() || (yyvsp[(1) - (4)].interm.intermTypedNode)->isMatrix()) && (yyvsp[(1) - (4)].interm.intermTypedNode)->getType().getRowsCount() <= (yyvsp[(3) - (4)].interm.intermTypedNode)->getAsConstant()->toInt() && !(yyvsp[(1) - (4)].interm.intermTypedNode)->isArray() ) {
				parseContext.error((yyvsp[(2) - (4)].lex).line, "", "[", "field selection out of range '%d'", (yyvsp[(3) - (4)].interm.intermTypedNode)->getAsConstant()->toInt());
				parseContext.recover();
			} else {
				if ((yyvsp[(1) - (4)].interm.intermTypedNode)->isArray()) {
					if ((yyvsp[(1) - (4)].interm.intermTypedNode)->getType().getArraySize() == 0) {
						if ((yyvsp[(1) - (4)].interm.intermTypedNode)->getType().getMaxArraySize() <= (yyvsp[(3) - (4)].interm.intermTypedNode)->getAsConstant()->toInt()) {
							if (parseContext.arraySetMaxSize((yyvsp[(1) - (4)].interm.intermTypedNode)->getAsSymbolNode(), (yyvsp[(1) - (4)].interm.intermTypedNode)->getTypePointer(), (yyvsp[(3) - (4)].interm.intermTypedNode)->getAsConstant()->toInt(), true, (yyvsp[(2) - (4)].lex).line))
								parseContext.recover(); 
						} else {
							if (parseContext.arraySetMaxSize((yyvsp[(1) - (4)].interm.intermTypedNode)->getAsSymbolNode(), (yyvsp[(1) - (4)].interm.intermTypedNode)->getTypePointer(), 0, false, (yyvsp[(2) - (4)].lex).line))
								parseContext.recover(); 
						}
					} else if ( (yyvsp[(3) - (4)].interm.intermTypedNode)->getAsConstant()->toInt() >= (yyvsp[(1) - (4)].interm.intermTypedNode)->getType().getArraySize()) {
						parseContext.error((yyvsp[(2) - (4)].lex).line, "", "[", "array index out of range '%d'", (yyvsp[(3) - (4)].interm.intermTypedNode)->getAsConstant()->toInt());
						parseContext.recover();
					}
				}
				(yyval.interm.intermTypedNode) = ir_add_index(EOpIndexDirect, (yyvsp[(1) - (4)].interm.intermTypedNode), (yyvsp[(3) - (4)].interm.intermTypedNode), (yyvsp[(2) - (4)].lex).line);
			}
		} else {
			if ((yyvsp[(1) - (4)].interm.intermTypedNode)->isArray() && (yyvsp[(1) - (4)].interm.intermTypedNode)->getType().getArraySize() == 0) {
				parseContext.error((yyvsp[(2) - (4)].lex).line, "", "[", "array must be redeclared with a size before being indexed with a variable");
				parseContext.recover();
			}
			
			(yyval.interm.intermTypedNode) = ir_add_index(EOpIndexIndirect, (yyvsp[(1) - (4)].interm.intermTypedNode), (yyvsp[(3) - (4)].interm.intermTypedNode), (yyvsp[(2) - (4)].lex).line);
		}
        if ((yyval.interm.intermTypedNode) == 0) {
            TIntermConstant* constant = ir_add_constant(TType(EbtFloat, EbpUndefined, EvqConst), (yyvsp[(2) - (4)].lex).line);
			constant->setValue(0.f);
			(yyval.interm.intermTypedNode) = constant;
        } else if ((yyvsp[(1) - (4)].interm.intermTypedNode)->isArray()) {
            if ((yyvsp[(1) - (4)].interm.intermTypedNode)->getType().getStruct())
                (yyval.interm.intermTypedNode)->setType(TType((yyvsp[(1) - (4)].interm.intermTypedNode)->getType().getStruct(), (yyvsp[(1) - (4)].interm.intermTypedNode)->getType().getTypeName(), EbpUndefined, (yyvsp[(1) - (4)].interm.intermTypedNode)->getLine()));
            else
                (yyval.interm.intermTypedNode)->setType(TType((yyvsp[(1) - (4)].interm.intermTypedNode)->getBasicType(), (yyvsp[(1) - (4)].interm.intermTypedNode)->getPrecision(), EvqTemporary, (yyvsp[(1) - (4)].interm.intermTypedNode)->getColsCount(),(yyvsp[(1) - (4)].interm.intermTypedNode)->getRowsCount(),  (yyvsp[(1) - (4)].interm.intermTypedNode)->isMatrix()));
                
            if ((yyvsp[(1) - (4)].interm.intermTypedNode)->getType().getQualifier() == EvqConst)
                (yyval.interm.intermTypedNode)->getTypePointer()->changeQualifier(EvqConst);
        } else if ((yyvsp[(1) - (4)].interm.intermTypedNode)->isMatrix() && (yyvsp[(1) - (4)].interm.intermTypedNode)->getType().getQualifier() == EvqConst)         
            (yyval.interm.intermTypedNode)->setType(TType((yyvsp[(1) - (4)].interm.intermTypedNode)->getBasicType(), (yyvsp[(1) - (4)].interm.intermTypedNode)->getPrecision(), EvqConst, 1, (yyvsp[(1) - (4)].interm.intermTypedNode)->getColsCount()));
        else if ((yyvsp[(1) - (4)].interm.intermTypedNode)->isMatrix())            
            (yyval.interm.intermTypedNode)->setType(TType((yyvsp[(1) - (4)].interm.intermTypedNode)->getBasicType(), (yyvsp[(1) - (4)].interm.intermTypedNode)->getPrecision(), EvqTemporary, 1, (yyvsp[(1) - (4)].interm.intermTypedNode)->getColsCount()));
        else if ((yyvsp[(1) - (4)].interm.intermTypedNode)->isVector() && (yyvsp[(1) - (4)].interm.intermTypedNode)->getType().getQualifier() == EvqConst)          
            (yyval.interm.intermTypedNode)->setType(TType((yyvsp[(1) - (4)].interm.intermTypedNode)->getBasicType(), (yyvsp[(1) - (4)].interm.intermTypedNode)->getPrecision(), EvqConst));
        else if ((yyvsp[(1) - (4)].interm.intermTypedNode)->isVector())       
            (yyval.interm.intermTypedNode)->setType(TType((yyvsp[(1) - (4)].interm.intermTypedNode)->getBasicType(), (yyvsp[(1) - (4)].interm.intermTypedNode)->getPrecision(), EvqTemporary));
        else
            (yyval.interm.intermTypedNode)->setType((yyvsp[(1) - (4)].interm.intermTypedNode)->getType());
    ;}
    break;

  case 10:
#line 308 "hlslang.y"
    {
        (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode);
    ;}
    break;

  case 11:
#line 311 "hlslang.y"
    {
        if (!(yyvsp[(1) - (3)].interm.intermTypedNode)) {
            parseContext.error((yyvsp[(3) - (3)].lex).line, "field selection on null object", ".", "");
            YYERROR;
        }
        if ((yyvsp[(1) - (3)].interm.intermTypedNode)->isArray()) {
            parseContext.error((yyvsp[(3) - (3)].lex).line, "cannot apply dot operator to an array", ".", "");
            parseContext.recover();
        }

        if ((yyvsp[(1) - (3)].interm.intermTypedNode)->isVector()) {
            TVectorFields fields;
            if (! parseContext.parseVectorFields(*(yyvsp[(3) - (3)].lex).string, (yyvsp[(1) - (3)].interm.intermTypedNode)->getRowsCount(), fields, (yyvsp[(3) - (3)].lex).line)) {
                fields.num = 1;
                fields.offsets[0] = 0;
                parseContext.recover();
            }

			(yyval.interm.intermTypedNode) = ir_add_vector_swizzle(fields, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, (yyvsp[(3) - (3)].lex).line);
        } else if ((yyvsp[(1) - (3)].interm.intermTypedNode)->isMatrix()) {
            TVectorFields fields;
            if (!parseContext.parseMatrixFields(*(yyvsp[(3) - (3)].lex).string, (yyvsp[(1) - (3)].interm.intermTypedNode)->getColsCount(), (yyvsp[(1) - (3)].interm.intermTypedNode)->getRowsCount(), fields, (yyvsp[(3) - (3)].lex).line)) {
                fields.num = 1;
                fields.offsets[0] = 0;
                parseContext.recover();
            }

            TString vectorString = *(yyvsp[(3) - (3)].lex).string;
            TIntermTyped* index = ir_add_swizzle(fields, (yyvsp[(3) - (3)].lex).line);                
            (yyval.interm.intermTypedNode) = ir_add_index(EOpMatrixSwizzle, (yyvsp[(1) - (3)].interm.intermTypedNode), index, (yyvsp[(2) - (3)].lex).line);
            (yyval.interm.intermTypedNode)->setType(TType((yyvsp[(1) - (3)].interm.intermTypedNode)->getBasicType(), (yyvsp[(1) - (3)].interm.intermTypedNode)->getPrecision(), EvqTemporary, 1, fields.num));
                    
        } else if ((yyvsp[(1) - (3)].interm.intermTypedNode)->getBasicType() == EbtStruct) {
            bool fieldFound = false;
            TTypeList* fields = (yyvsp[(1) - (3)].interm.intermTypedNode)->getType().getStruct();
            if (fields == 0) {
                parseContext.error((yyvsp[(2) - (3)].lex).line, "structure has no fields", "Internal Error", "");
                parseContext.recover();
                (yyval.interm.intermTypedNode) = (yyvsp[(1) - (3)].interm.intermTypedNode);
            } else {
                unsigned int i;
                for (i = 0; i < fields->size(); ++i) {
                    if ((*fields)[i].type->getFieldName() == *(yyvsp[(3) - (3)].lex).string) {
                        fieldFound = true;
                        break;
                    }
                }
                if (fieldFound) {
					TIntermConstant* index = ir_add_constant(TType(EbtInt, EbpUndefined, EvqConst), (yyvsp[(3) - (3)].lex).line);
					index->setValue(i);
					(yyval.interm.intermTypedNode) = ir_add_index(EOpIndexDirectStruct, (yyvsp[(1) - (3)].interm.intermTypedNode), index, (yyvsp[(2) - (3)].lex).line);                
					(yyval.interm.intermTypedNode)->setType(*(*fields)[i].type);
                } else {
                    parseContext.error((yyvsp[(2) - (3)].lex).line, " no such field in structure", (yyvsp[(3) - (3)].lex).string->c_str(), "");
                    parseContext.recover();
                    (yyval.interm.intermTypedNode) = (yyvsp[(1) - (3)].interm.intermTypedNode);
                }
            }
        } else if ((yyvsp[(1) - (3)].interm.intermTypedNode)->isScalar()) {

            // HLSL allows ".xxxx" field selection on single component floats.  Handle that here.
            TVectorFields fields;

            // Check to make sure only the "x" component is accessed.
            if (! parseContext.parseVectorFields(*(yyvsp[(3) - (3)].lex).string, 1, fields, (yyvsp[(3) - (3)].lex).line))
			{
                fields.num = 1;
                fields.offsets[0] = 0;
                parseContext.recover();
				(yyval.interm.intermTypedNode) = (yyvsp[(1) - (3)].interm.intermTypedNode);
            }
			else
			{
				// Create the appropriate constructor based on the number of ".x"'s there are in the selection field
				TString vectorString = *(yyvsp[(3) - (3)].lex).string;
				TQualifier qualifier = (yyvsp[(1) - (3)].interm.intermTypedNode)->getType().getQualifier() == EvqConst ? EvqConst : EvqTemporary;
				TType type((yyvsp[(1) - (3)].interm.intermTypedNode)->getBasicType(), (yyvsp[(1) - (3)].interm.intermTypedNode)->getPrecision(), qualifier, 1, (int) vectorString.size());
				(yyval.interm.intermTypedNode) = parseContext.constructBuiltIn(&type, parseContext.getConstructorOp(type),
												   (yyval.interm.intermTypedNode), (yyvsp[(1) - (3)].interm.intermTypedNode)->getLine(), false);
			}
        } else {
            parseContext.error((yyvsp[(2) - (3)].lex).line, " field selection requires structure, vector, or matrix on left hand side", (yyvsp[(3) - (3)].lex).string->c_str(), "");
            parseContext.recover();
            (yyval.interm.intermTypedNode) = (yyvsp[(1) - (3)].interm.intermTypedNode);
        }
        // don't delete $3.string, it's from the pool
    ;}
    break;

  case 12:
#line 398 "hlslang.y"
    {
        if (parseContext.lValueErrorCheck((yyvsp[(2) - (2)].lex).line, "++", (yyvsp[(1) - (2)].interm.intermTypedNode)))
            parseContext.recover();
        (yyval.interm.intermTypedNode) = ir_add_unary_math(EOpPostIncrement, (yyvsp[(1) - (2)].interm.intermTypedNode), (yyvsp[(2) - (2)].lex).line, parseContext);
        if ((yyval.interm.intermTypedNode) == 0) {
            parseContext.unaryOpError((yyvsp[(2) - (2)].lex).line, "++", (yyvsp[(1) - (2)].interm.intermTypedNode)->getCompleteString());
            parseContext.recover();
            (yyval.interm.intermTypedNode) = (yyvsp[(1) - (2)].interm.intermTypedNode);
        }
    ;}
    break;

  case 13:
#line 408 "hlslang.y"
    {
        if (parseContext.lValueErrorCheck((yyvsp[(2) - (2)].lex).line, "--", (yyvsp[(1) - (2)].interm.intermTypedNode)))
            parseContext.recover();
        (yyval.interm.intermTypedNode) = ir_add_unary_math(EOpPostDecrement, (yyvsp[(1) - (2)].interm.intermTypedNode), (yyvsp[(2) - (2)].lex).line, parseContext);
        if ((yyval.interm.intermTypedNode) == 0) {
            parseContext.unaryOpError((yyvsp[(2) - (2)].lex).line, "--", (yyvsp[(1) - (2)].interm.intermTypedNode)->getCompleteString());
            parseContext.recover();
            (yyval.interm.intermTypedNode) = (yyvsp[(1) - (2)].interm.intermTypedNode);
        }
    ;}
    break;

  case 14:
#line 421 "hlslang.y"
    {
        if (parseContext.scalarErrorCheck((yyvsp[(1) - (1)].interm.intermTypedNode), "[]"))
            parseContext.recover();
        TType type(EbtInt, EbpUndefined);
        (yyval.interm.intermTypedNode) = parseContext.constructBuiltIn(&type, EOpConstructInt, (yyvsp[(1) - (1)].interm.intermTypedNode), (yyvsp[(1) - (1)].interm.intermTypedNode)->getLine(), true);
        if ((yyval.interm.intermTypedNode) == 0) {
            parseContext.error((yyvsp[(1) - (1)].interm.intermTypedNode)->getLine(), "cannot convert to index", "[]", "");
            parseContext.recover();
            (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode);
        }
    ;}
    break;

  case 15:
#line 435 "hlslang.y"
    {
        TFunction* fnCall = (yyvsp[(1) - (1)].interm).function;
        TOperator op = fnCall->getBuiltInOp();

        if (op == EOpArrayLength) {
            if ((yyvsp[(1) - (1)].interm).intermNode->getAsTyped() == 0 || (yyvsp[(1) - (1)].interm).intermNode->getAsTyped()->getType().getArraySize() == 0) {
                parseContext.error((yyvsp[(1) - (1)].interm).line, "", fnCall->getName().c_str(), "array must be declared with a size before using this method");
                parseContext.recover();
            }

			TIntermConstant* constant = ir_add_constant(TType(EbtInt, EbpUndefined, EvqConst), (yyvsp[(1) - (1)].interm).line);
			constant->setValue((yyvsp[(1) - (1)].interm).intermNode->getAsTyped()->getType().getArraySize());
            (yyval.interm.intermTypedNode) = constant;
        } else if (op != EOpNull) {
            //
            // Then this should be a constructor.
            // Don't go through the symbol table for constructors.
            // Their parameters will be verified algorithmically.
            //
            TType type(EbtVoid, EbpUndefined);  // use this to get the type back
            if (parseContext.constructorErrorCheck((yyvsp[(1) - (1)].interm).line, (yyvsp[(1) - (1)].interm).intermNode, *fnCall, op, &type)) {
                (yyval.interm.intermTypedNode) = 0;
            } else {
                //
                // It's a constructor, of type 'type'.
                //
                (yyval.interm.intermTypedNode) = parseContext.addConstructor((yyvsp[(1) - (1)].interm).intermNode, &type, op, fnCall, (yyvsp[(1) - (1)].interm).line);
            }

            if ((yyval.interm.intermTypedNode) == 0) {
                parseContext.recover();
                (yyval.interm.intermTypedNode) = ir_set_aggregate_op(0, op, (yyvsp[(1) - (1)].interm).line);
				(yyval.interm.intermTypedNode)->setType(type);
            }
        } else {
            //
            // Not a constructor.  Find it in the symbol table.
            //
            const TFunction* fnCandidate;
            bool builtIn;
            fnCandidate = parseContext.findFunction((yyvsp[(1) - (1)].interm).line, fnCall, &builtIn);

            if ( fnCandidate && fnCandidate->getMangledName() != fnCall->getMangledName()) {
                //add constructors to arguments to ensure that they have proper types
                TIntermNode *temp = parseContext.promoteFunctionArguments( (yyvsp[(1) - (1)].interm).intermNode,
                                      fnCandidate);
                if (temp)
                    (yyvsp[(1) - (1)].interm).intermNode = temp;
                else {
                    parseContext.error( (yyvsp[(1) - (1)].interm).intermNode->getLine(), " unable to suitably promote arguments to function",
                                        fnCandidate->getName().c_str(), "");
                    fnCandidate = 0;
                }
            }

            if (fnCandidate) {
                //
                // A declared function.  But, it might still map to a built-in
                // operation.
                //
                op = fnCandidate->getBuiltInOp();
                if (builtIn && op != EOpNull) {
                    //
                    // A function call mapped to a built-in operation.
                    //
                    if (fnCandidate->getParamCount() == 1) {
                        //
                        // Treat it like a built-in unary operator.
                        //
                        (yyval.interm.intermTypedNode) = ir_add_unary_math(op, (yyvsp[(1) - (1)].interm).intermNode, gNullSourceLoc, parseContext);
                        if ((yyval.interm.intermTypedNode) == 0)  {
                            parseContext.error((yyvsp[(1) - (1)].interm).intermNode->getLine(), " wrong operand type", "Internal Error",
                                "built in unary operator function.  Type: %s",
                                static_cast<TIntermTyped*>((yyvsp[(1) - (1)].interm).intermNode)->getCompleteString().c_str());
                            YYERROR;
                        }
                    } else {
                        (yyval.interm.intermTypedNode) = ir_set_aggregate_op((yyvsp[(1) - (1)].interm).intermAggregate, op, (yyvsp[(1) - (1)].interm).line);
						(yyval.interm.intermTypedNode)->setType(fnCandidate->getReturnType());
                    }
                } else {
                    // This is a real function call
                    
                    (yyval.interm.intermTypedNode) = ir_set_aggregate_op((yyvsp[(1) - (1)].interm).intermAggregate, EOpFunctionCall, (yyvsp[(1) - (1)].interm).line);
                    (yyval.interm.intermTypedNode)->setType(fnCandidate->getReturnType());                   
                    
                    (yyval.interm.intermTypedNode)->getAsAggregate()->setName(fnCandidate->getMangledName());
                    (yyval.interm.intermTypedNode)->getAsAggregate()->setPlainName(fnCandidate->getName());

                    TQualifier qual;
                    for (int i = 0; i < fnCandidate->getParamCount(); ++i) {
                        qual = (*fnCandidate)[i].type->getQualifier();
                        if (qual == EvqOut || qual == EvqInOut) {
                            if (parseContext.lValueErrorCheck((yyval.interm.intermTypedNode)->getLine(), "assign", (yyval.interm.intermTypedNode)->getAsAggregate()->getNodes()[i]->getAsTyped())) {
                                parseContext.error((yyvsp[(1) - (1)].interm).intermNode->getLine(), "Constant value cannot be passed for 'out' or 'inout' parameters.", "Error", "");
                                parseContext.recover();
                            }
                        }
                    }
                }
                (yyval.interm.intermTypedNode)->setType(fnCandidate->getReturnType());
            } else {
                // error message was put out by PaFindFunction()
                // Put on a dummy node for error recovery
                
				TIntermConstant* constant = ir_add_constant(TType(EbtFloat, EbpUndefined, EvqConst), (yyvsp[(1) - (1)].interm).line);
				constant->setValue(0.f);
				(yyval.interm.intermTypedNode) = constant;
                parseContext.recover();
            }
        }
        delete fnCall;
    ;}
    break;

  case 16:
#line 551 "hlslang.y"
    {
        (yyval.interm) = (yyvsp[(1) - (1)].interm);
    ;}
    break;

  case 17:
#line 554 "hlslang.y"
    {
        if ((yyvsp[(1) - (3)].interm.intermTypedNode)->isArray() && (yyvsp[(3) - (3)].interm).function->getName() == "length") {
            //
            // implement array.length()
            //
            (yyval.interm) = (yyvsp[(3) - (3)].interm);
            (yyval.interm).intermNode = (yyvsp[(1) - (3)].interm.intermTypedNode);
            (yyval.interm).function->relateToOperator(EOpArrayLength);

        } else {
            parseContext.error((yyvsp[(3) - (3)].interm).line, "methods are not supported", "", "");
            parseContext.recover();
            (yyval.interm) = (yyvsp[(3) - (3)].interm);
        }
    ;}
    break;

  case 18:
#line 572 "hlslang.y"
    {
        (yyval.interm) = (yyvsp[(1) - (2)].interm);
        (yyval.interm).line = (yyvsp[(2) - (2)].lex).line;
    ;}
    break;

  case 19:
#line 576 "hlslang.y"
    {
        (yyval.interm) = (yyvsp[(1) - (2)].interm);
        (yyval.interm).line = (yyvsp[(2) - (2)].lex).line;
    ;}
    break;

  case 20:
#line 583 "hlslang.y"
    {
        (yyval.interm).function = (yyvsp[(1) - (2)].interm.function);
        (yyval.interm).intermNode = 0;
    ;}
    break;

  case 21:
#line 587 "hlslang.y"
    {
        (yyval.interm).function = (yyvsp[(1) - (1)].interm.function);
        (yyval.interm).intermNode = 0;
    ;}
    break;

  case 22:
#line 594 "hlslang.y"
    {
		if (!(yyvsp[(2) - (2)].interm.intermTypedNode)) {
          YYERROR;
		}
		TParameter param = { 0, 0, new TType((yyvsp[(2) - (2)].interm.intermTypedNode)->getType()) };
        (yyvsp[(1) - (2)].interm.function)->addParameter(param);
        (yyval.interm).function = (yyvsp[(1) - (2)].interm.function);
        (yyval.interm).intermNode = (yyvsp[(2) - (2)].interm.intermTypedNode);
    ;}
    break;

  case 23:
#line 603 "hlslang.y"
    {
		if (!(yyvsp[(3) - (3)].interm.intermTypedNode)) {
          YYERROR;
		}
        TParameter param = { 0, 0, new TType((yyvsp[(3) - (3)].interm.intermTypedNode)->getType()) };
        (yyvsp[(1) - (3)].interm).function->addParameter(param);
        (yyval.interm).function = (yyvsp[(1) - (3)].interm).function;
        (yyval.interm).intermNode = ir_grow_aggregate((yyvsp[(1) - (3)].interm).intermNode, (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line);
    ;}
    break;

  case 24:
#line 615 "hlslang.y"
    {
        (yyval.interm.function) = (yyvsp[(1) - (2)].interm.function);
    ;}
    break;

  case 25:
#line 623 "hlslang.y"
    {
        //
        // Constructor
        //
        if ((yyvsp[(1) - (1)].interm.type).array) {
            //TODO : figure out how to deal with array constructors
        }

        if ((yyvsp[(1) - (1)].interm.type).userDef) {
            TString tempString = "";
            TType type((yyvsp[(1) - (1)].interm.type));
            TFunction *function = new TFunction(&tempString, type, EOpConstructStruct);
            (yyval.interm.function) = function;
        } else {
            TOperator op = ir_get_constructor_op((yyvsp[(1) - (1)].interm.type), parseContext, false);
            if (op == EOpNull) {
                parseContext.error((yyvsp[(1) - (1)].interm.type).line, "cannot construct this type", TType::getBasicString((yyvsp[(1) - (1)].interm.type).type), "");
                parseContext.recover();
                (yyvsp[(1) - (1)].interm.type).type = EbtFloat;
                op = EOpConstructFloat;
            }
            TString tempString = "";
            TType type((yyvsp[(1) - (1)].interm.type));
            TFunction *function = new TFunction(&tempString, type, op);
            (yyval.interm.function) = function;
        }
    ;}
    break;

  case 26:
#line 650 "hlslang.y"
    {
		if (parseContext.reservedErrorCheck((yyvsp[(1) - (1)].lex).line, *(yyvsp[(1) - (1)].lex).string)) 
			parseContext.recover();
		TType type(EbtVoid, EbpUndefined);
		const TString *mangled;
		if ( *(yyvsp[(1) - (1)].lex).string == "main")
			mangled = NewPoolTString("xlat_main");
		else
			mangled = (yyvsp[(1) - (1)].lex).string;
		TFunction *function = new TFunction( mangled, type);
		(yyval.interm.function) = function;
	;}
    break;

  case 27:
#line 662 "hlslang.y"
    {
		if (parseContext.reservedErrorCheck((yyvsp[(1) - (1)].lex).line, *(yyvsp[(1) - (1)].lex).string)) 
			parseContext.recover();
		TType type(EbtVoid, EbpUndefined);
		TFunction *function = new TFunction((yyvsp[(1) - (1)].lex).string, type);
		(yyval.interm.function) = function;
    ;}
    break;

  case 28:
#line 672 "hlslang.y"
    {
		(yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode);
    ;}
    break;

  case 29:
#line 675 "hlslang.y"
    {
		if (parseContext.lValueErrorCheck((yyvsp[(1) - (2)].lex).line, "++", (yyvsp[(2) - (2)].interm.intermTypedNode)))
			parseContext.recover();
		(yyval.interm.intermTypedNode) = ir_add_unary_math(EOpPreIncrement, (yyvsp[(2) - (2)].interm.intermTypedNode), (yyvsp[(1) - (2)].lex).line, parseContext);
		if ((yyval.interm.intermTypedNode) == 0) {
			parseContext.unaryOpError((yyvsp[(1) - (2)].lex).line, "++", (yyvsp[(2) - (2)].interm.intermTypedNode)->getCompleteString());
			parseContext.recover();
			(yyval.interm.intermTypedNode) = (yyvsp[(2) - (2)].interm.intermTypedNode);
		}
    ;}
    break;

  case 30:
#line 685 "hlslang.y"
    {
        if (parseContext.lValueErrorCheck((yyvsp[(1) - (2)].lex).line, "--", (yyvsp[(2) - (2)].interm.intermTypedNode)))
            parseContext.recover();
		(yyval.interm.intermTypedNode) = ir_add_unary_math(EOpPreDecrement, (yyvsp[(2) - (2)].interm.intermTypedNode), (yyvsp[(1) - (2)].lex).line, parseContext);
		if ((yyval.interm.intermTypedNode) == 0) {
			parseContext.unaryOpError((yyvsp[(1) - (2)].lex).line, "--", (yyvsp[(2) - (2)].interm.intermTypedNode)->getCompleteString());
			parseContext.recover();
			(yyval.interm.intermTypedNode) = (yyvsp[(2) - (2)].interm.intermTypedNode);
		}
    ;}
    break;

  case 31:
#line 695 "hlslang.y"
    {
		if ((yyvsp[(1) - (2)].interm).op != EOpNull) {
			(yyval.interm.intermTypedNode) = ir_add_unary_math((yyvsp[(1) - (2)].interm).op, (yyvsp[(2) - (2)].interm.intermTypedNode), (yyvsp[(1) - (2)].interm).line, parseContext);
			if ((yyval.interm.intermTypedNode) == 0) {
				const char* errorOp = "";
				switch((yyvsp[(1) - (2)].interm).op) {
					case EOpNegative:   errorOp = "-"; break;
					case EOpLogicalNot: errorOp = "!"; break;
					case EOpBitwiseNot: errorOp = "~"; break;
					default: break;
				}
				parseContext.unaryOpError((yyvsp[(1) - (2)].interm).line, errorOp, (yyvsp[(2) - (2)].interm.intermTypedNode)->getCompleteString());
				parseContext.recover();
				(yyval.interm.intermTypedNode) = (yyvsp[(2) - (2)].interm.intermTypedNode);
			}
		} else
			(yyval.interm.intermTypedNode) = (yyvsp[(2) - (2)].interm.intermTypedNode);
    ;}
    break;

  case 32:
#line 713 "hlslang.y"
    {
        // cast operator, insert constructor
        TOperator op = ir_get_constructor_op((yyvsp[(2) - (4)].interm.type), parseContext, true);
        if (op == EOpNull) {
            parseContext.error((yyvsp[(2) - (4)].interm.type).line, "cannot cast this type", TType::getBasicString((yyvsp[(2) - (4)].interm.type).type), "");
            parseContext.recover();
            (yyvsp[(2) - (4)].interm.type).type = EbtFloat;
            op = EOpConstructFloat;
        }
        TString tempString = "";
        TType type((yyvsp[(2) - (4)].interm.type));
        TFunction *function = new TFunction(&tempString, type, op);
        TParameter param = { 0, 0, new TType((yyvsp[(4) - (4)].interm.intermTypedNode)->getType()) };
        function->addParameter(param);
        TType type2(EbtVoid, EbpUndefined);  // use this to get the type back
        if (parseContext.constructorErrorCheck((yyvsp[(2) - (4)].interm.type).line, (yyvsp[(4) - (4)].interm.intermTypedNode), *function, op, &type2)) {
            (yyval.interm.intermTypedNode) = 0;
        } else {
            //
            // It's a constructor, of type 'type'.
            //
            (yyval.interm.intermTypedNode) = parseContext.addConstructor((yyvsp[(4) - (4)].interm.intermTypedNode), &type2, op, function, (yyvsp[(2) - (4)].interm.type).line);
        }

        if ((yyval.interm.intermTypedNode) == 0) {
            parseContext.recover();
            (yyval.interm.intermTypedNode) = ir_set_aggregate_op(0, op, (yyvsp[(2) - (4)].interm.type).line);
        } else {
			(yyval.interm.intermTypedNode)->setType(type2);
		}
	;}
    break;

  case 33:
#line 748 "hlslang.y"
    { (yyval.interm).line = (yyvsp[(1) - (1)].lex).line; (yyval.interm).op = EOpNull; ;}
    break;

  case 34:
#line 749 "hlslang.y"
    { (yyval.interm).line = (yyvsp[(1) - (1)].lex).line; (yyval.interm).op = EOpNegative; ;}
    break;

  case 35:
#line 750 "hlslang.y"
    { (yyval.interm).line = (yyvsp[(1) - (1)].lex).line; (yyval.interm).op = EOpLogicalNot; ;}
    break;

  case 36:
#line 751 "hlslang.y"
    { UNSUPPORTED_FEATURE("~", (yyvsp[(1) - (1)].lex).line);
              (yyval.interm).line = (yyvsp[(1) - (1)].lex).line; (yyval.interm).op = EOpBitwiseNot; ;}
    break;

  case 37:
#line 757 "hlslang.y"
    { (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode); ;}
    break;

  case 38:
#line 758 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpMul, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, "*", false); ;}
    break;

  case 39:
#line 759 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpDiv, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, "/", false); ;}
    break;

  case 40:
#line 760 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpMod, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, "%", false); ;}
    break;

  case 41:
#line 764 "hlslang.y"
    { (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode); ;}
    break;

  case 42:
#line 765 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpAdd, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, "+", false); ;}
    break;

  case 43:
#line 766 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpSub, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, "-", false); ;}
    break;

  case 44:
#line 770 "hlslang.y"
    { (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode); ;}
    break;

  case 45:
#line 771 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpLeftShift, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, "<<", false); ;}
    break;

  case 46:
#line 772 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpRightShift, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, ">>", false); ;}
    break;

  case 47:
#line 776 "hlslang.y"
    { (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode); ;}
    break;

  case 48:
#line 777 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpLessThan, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, "<", true); ;}
    break;

  case 49:
#line 778 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpGreaterThan, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, ">", true); ;}
    break;

  case 50:
#line 779 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpLessThanEqual, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, "<=", true); ;}
    break;

  case 51:
#line 780 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpGreaterThanEqual, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, ">=", true); ;}
    break;

  case 52:
#line 784 "hlslang.y"
    { (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode); ;}
    break;

  case 53:
#line 785 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpEqual, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, "==", true); ;}
    break;

  case 54:
#line 786 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpNotEqual, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, "!=", true); ;}
    break;

  case 55:
#line 790 "hlslang.y"
    { (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode); ;}
    break;

  case 56:
#line 791 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpAnd, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, "&", false); ;}
    break;

  case 57:
#line 795 "hlslang.y"
    { (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode); ;}
    break;

  case 58:
#line 796 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpExclusiveOr, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, "^", false); ;}
    break;

  case 59:
#line 800 "hlslang.y"
    { (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode); ;}
    break;

  case 60:
#line 801 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpInclusiveOr, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, "|", false); ;}
    break;

  case 61:
#line 805 "hlslang.y"
    { (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode); ;}
    break;

  case 62:
#line 806 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpLogicalAnd, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, "&&", true); ;}
    break;

  case 63:
#line 810 "hlslang.y"
    { (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode); ;}
    break;

  case 64:
#line 811 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpLogicalXor, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, "^^", true); ;}
    break;

  case 65:
#line 815 "hlslang.y"
    { (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode); ;}
    break;

  case 66:
#line 816 "hlslang.y"
    { (yyval.interm.intermTypedNode) = parseContext.add_binary(EOpLogicalOr, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line, "||", true); ;}
    break;

  case 67:
#line 820 "hlslang.y"
    { (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode); ;}
    break;

  case 68:
#line 821 "hlslang.y"
    {
       if (parseContext.boolOrVectorErrorCheck((yyvsp[(2) - (5)].lex).line, (yyvsp[(1) - (5)].interm.intermTypedNode)))
            parseContext.recover();
       
		(yyval.interm.intermTypedNode) = ir_add_selection((yyvsp[(1) - (5)].interm.intermTypedNode), (yyvsp[(3) - (5)].interm.intermTypedNode), (yyvsp[(5) - (5)].interm.intermTypedNode), (yyvsp[(2) - (5)].lex).line, parseContext.infoSink);
           
        if ((yyval.interm.intermTypedNode) == 0) {
            parseContext.binaryOpError((yyvsp[(2) - (5)].lex).line, ":", (yyvsp[(3) - (5)].interm.intermTypedNode)->getCompleteString(), (yyvsp[(5) - (5)].interm.intermTypedNode)->getCompleteString());
            parseContext.recover();
            (yyval.interm.intermTypedNode) = (yyvsp[(5) - (5)].interm.intermTypedNode);
        }
    ;}
    break;

  case 69:
#line 836 "hlslang.y"
    { (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode); ;}
    break;

  case 70:
#line 837 "hlslang.y"
    {        
        if (parseContext.lValueErrorCheck((yyvsp[(2) - (3)].interm).line, "assign", (yyvsp[(1) - (3)].interm.intermTypedNode)))
            parseContext.recover();
        (yyval.interm.intermTypedNode) = parseContext.addAssign((yyvsp[(2) - (3)].interm).op, (yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].interm).line);
        if ((yyval.interm.intermTypedNode) == 0) {
            parseContext.assignError((yyvsp[(2) - (3)].interm).line, "assign", (yyvsp[(1) - (3)].interm.intermTypedNode)->getCompleteString(), (yyvsp[(3) - (3)].interm.intermTypedNode)->getCompleteString());
            parseContext.recover();
            (yyval.interm.intermTypedNode) = (yyvsp[(1) - (3)].interm.intermTypedNode);
        } else if (((yyvsp[(1) - (3)].interm.intermTypedNode)->isArray() || (yyvsp[(3) - (3)].interm.intermTypedNode)->isArray()))
            parseContext.recover();
    ;}
    break;

  case 71:
#line 851 "hlslang.y"
    { (yyval.interm).line = (yyvsp[(1) - (1)].lex).line; (yyval.interm).op = EOpAssign; ;}
    break;

  case 72:
#line 852 "hlslang.y"
    { (yyval.interm).line = (yyvsp[(1) - (1)].lex).line; (yyval.interm).op = EOpMulAssign; ;}
    break;

  case 73:
#line 853 "hlslang.y"
    { (yyval.interm).line = (yyvsp[(1) - (1)].lex).line; (yyval.interm).op = EOpDivAssign; ;}
    break;

  case 74:
#line 854 "hlslang.y"
    { UNSUPPORTED_FEATURE("%=", (yyvsp[(1) - (1)].lex).line);  (yyval.interm).line = (yyvsp[(1) - (1)].lex).line; (yyval.interm).op = EOpModAssign; ;}
    break;

  case 75:
#line 855 "hlslang.y"
    { (yyval.interm).line = (yyvsp[(1) - (1)].lex).line; (yyval.interm).op = EOpAddAssign; ;}
    break;

  case 76:
#line 856 "hlslang.y"
    { (yyval.interm).line = (yyvsp[(1) - (1)].lex).line; (yyval.interm).op = EOpSubAssign; ;}
    break;

  case 77:
#line 857 "hlslang.y"
    { UNSUPPORTED_FEATURE("<<=", (yyvsp[(1) - (1)].lex).line); (yyval.interm).line = (yyvsp[(1) - (1)].lex).line; (yyval.interm).op = EOpLeftShiftAssign; ;}
    break;

  case 78:
#line 858 "hlslang.y"
    { UNSUPPORTED_FEATURE("<<=", (yyvsp[(1) - (1)].lex).line); (yyval.interm).line = (yyvsp[(1) - (1)].lex).line; (yyval.interm).op = EOpRightShiftAssign; ;}
    break;

  case 79:
#line 859 "hlslang.y"
    { UNSUPPORTED_FEATURE("&=",  (yyvsp[(1) - (1)].lex).line); (yyval.interm).line = (yyvsp[(1) - (1)].lex).line; (yyval.interm).op = EOpAndAssign; ;}
    break;

  case 80:
#line 860 "hlslang.y"
    { UNSUPPORTED_FEATURE("^=",  (yyvsp[(1) - (1)].lex).line); (yyval.interm).line = (yyvsp[(1) - (1)].lex).line; (yyval.interm).op = EOpExclusiveOrAssign; ;}
    break;

  case 81:
#line 861 "hlslang.y"
    { UNSUPPORTED_FEATURE("|=",  (yyvsp[(1) - (1)].lex).line); (yyval.interm).line = (yyvsp[(1) - (1)].lex).line; (yyval.interm).op = EOpInclusiveOrAssign; ;}
    break;

  case 82:
#line 865 "hlslang.y"
    {
        (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode);
    ;}
    break;

  case 83:
#line 868 "hlslang.y"
    {
        (yyval.interm.intermTypedNode) = ir_add_comma((yyvsp[(1) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(2) - (3)].lex).line);
        if ((yyval.interm.intermTypedNode) == 0) {
            parseContext.binaryOpError((yyvsp[(2) - (3)].lex).line, ",", (yyvsp[(1) - (3)].interm.intermTypedNode)->getCompleteString(), (yyvsp[(3) - (3)].interm.intermTypedNode)->getCompleteString());
            parseContext.recover();
            (yyval.interm.intermTypedNode) = (yyvsp[(3) - (3)].interm.intermTypedNode);
        }
    ;}
    break;

  case 84:
#line 879 "hlslang.y"
    {
        if (parseContext.constErrorCheck((yyvsp[(1) - (1)].interm.intermTypedNode)))
            parseContext.recover();
        (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode);
    ;}
    break;

  case 85:
#line 887 "hlslang.y"
    { (yyval.interm.intermDeclaration) = 0; ;}
    break;

  case 86:
#line 888 "hlslang.y"
    { (yyval.interm.intermDeclaration) = (yyvsp[(1) - (2)].interm.intermDeclaration); ;}
    break;

  case 87:
#line 892 "hlslang.y"
    {
        //
        // Multiple declarations of the same function are allowed.
        //
        // If this is a definition, the definition production code will check for redefinitions
        // (we don't know at this point if it's a definition or not).
        //
        // Redeclarations are allowed.  But, return types and parameter qualifiers must match.
        //
        TFunction* prevDec = static_cast<TFunction*>(parseContext.symbolTable.find((yyvsp[(1) - (2)].interm.function)->getMangledName()));
        if (prevDec) {
            if (prevDec->getReturnType() != (yyvsp[(1) - (2)].interm.function)->getReturnType()) {
                parseContext.error((yyvsp[(2) - (2)].lex).line, "overloaded functions must have the same return type", (yyvsp[(1) - (2)].interm.function)->getReturnType().getBasicString(), "");
                parseContext.recover();
            }
            for (int i = 0; i < prevDec->getParamCount(); ++i) {
                if ((*prevDec)[i].type->getQualifier() != (*(yyvsp[(1) - (2)].interm.function))[i].type->getQualifier()) {
                    parseContext.error((yyvsp[(2) - (2)].lex).line, "overloaded functions must have the same parameter qualifiers", (*(yyvsp[(1) - (2)].interm.function))[i].type->getQualifierString(), "");
                    parseContext.recover();
                }
            }
        }

        //
        // If this is a redeclaration, it could also be a definition,
        // in which case, we want to use the variable names from this one, and not the one that's
        // being redeclared.  So, pass back up this declaration, not the one in the symbol table.
        //
        (yyval.interm).function = (yyvsp[(1) - (2)].interm.function);
        (yyval.interm).line = (yyvsp[(2) - (2)].lex).line;

        parseContext.symbolTable.insert(*(yyval.interm).function);
    ;}
    break;

  case 88:
#line 925 "hlslang.y"
    {
        //
        // Multiple declarations of the same function are allowed.
        //
        // If this is a definition, the definition production code will check for redefinitions
        // (we don't know at this point if it's a definition or not).
        //
        // Redeclarations are allowed.  But, return types and parameter qualifiers must match.
        //
        TFunction* prevDec = static_cast<TFunction*>(parseContext.symbolTable.find((yyvsp[(1) - (4)].interm.function)->getMangledName()));
        if (prevDec) {
            if (prevDec->getReturnType() != (yyvsp[(1) - (4)].interm.function)->getReturnType()) {
                parseContext.error((yyvsp[(2) - (4)].lex).line, "overloaded functions must have the same return type", (yyvsp[(1) - (4)].interm.function)->getReturnType().getBasicString(), "");
                parseContext.recover();
            }
            for (int i = 0; i < prevDec->getParamCount(); ++i) {
                if ((*prevDec)[i].type->getQualifier() != (*(yyvsp[(1) - (4)].interm.function))[i].type->getQualifier()) {
                    parseContext.error((yyvsp[(2) - (4)].lex).line, "overloaded functions must have the same parameter qualifiers", (*(yyvsp[(1) - (4)].interm.function))[i].type->getQualifierString(), "");
                    parseContext.recover();
                }
            }
        }

        //
        // If this is a redeclaration, it could also be a definition,
        // in which case, we want to use the variable names from this one, and not the one that's
        // being redeclared.  So, pass back up this declaration, not the one in the symbol table.
        //
        (yyval.interm).function = (yyvsp[(1) - (4)].interm.function);
        (yyval.interm).line = (yyvsp[(2) - (4)].lex).line;
        (yyval.interm).function->setInfo(new TTypeInfo(*(yyvsp[(4) - (4)].lex).string, 0));

        parseContext.symbolTable.insert(*(yyval.interm).function);
    ;}
    break;

  case 89:
#line 962 "hlslang.y"
    {
        (yyval.interm.function) = (yyvsp[(1) - (1)].interm.function);
    ;}
    break;

  case 90:
#line 965 "hlslang.y"
    {
        (yyval.interm.function) = (yyvsp[(1) - (1)].interm.function);
    ;}
    break;

  case 91:
#line 972 "hlslang.y"
    {
        // Add the parameter
        (yyval.interm.function) = (yyvsp[(1) - (2)].interm.function);
        if ((yyvsp[(2) - (2)].interm).param.type->getBasicType() != EbtVoid)
            (yyvsp[(1) - (2)].interm.function)->addParameter((yyvsp[(2) - (2)].interm).param);
        else
            delete (yyvsp[(2) - (2)].interm).param.type;
    ;}
    break;

  case 92:
#line 980 "hlslang.y"
    {
        //
        // Only first parameter of one-parameter functions can be void
        // The check for named parameters not being void is done in parameter_declarator
        //
        if ((yyvsp[(3) - (3)].interm).param.type->getBasicType() == EbtVoid) {
            //
            // This parameter > first is void
            //
            parseContext.error((yyvsp[(2) - (3)].lex).line, "cannot be an argument type except for '(void)'", "void", "");
            parseContext.recover();
            delete (yyvsp[(3) - (3)].interm).param.type;
        } else {
            // Add the parameter
            (yyval.interm.function) = (yyvsp[(1) - (3)].interm.function);
            (yyvsp[(1) - (3)].interm.function)->addParameter((yyvsp[(3) - (3)].interm).param);
        }
    ;}
    break;

  case 93:
#line 1001 "hlslang.y"
    {
        if ((yyvsp[(1) - (3)].interm.type).qualifier != EvqGlobal && (yyvsp[(1) - (3)].interm.type).qualifier != EvqTemporary) {
			if ((yyvsp[(1) - (3)].interm.type).qualifier == EvqConst || (yyvsp[(1) - (3)].interm.type).qualifier == EvqStatic)
			{
				(yyvsp[(1) - (3)].interm.type).qualifier = EvqTemporary;
			}
			else
			{
				parseContext.error((yyvsp[(2) - (3)].lex).line, "no qualifiers allowed for function return", getQualifierString((yyvsp[(1) - (3)].interm.type).qualifier), "");
				parseContext.recover();
			}
        }
        // make sure a sampler is not involved as well...
        if (parseContext.structQualifierErrorCheck((yyvsp[(2) - (3)].lex).line, (yyvsp[(1) - (3)].interm.type)))
            parseContext.recover();

        // Add the function as a prototype after parsing it (we do not support recursion)
        TFunction *function;
        TType type((yyvsp[(1) - (3)].interm.type));
    const TString* mangled = 0;
    if ( *(yyvsp[(2) - (3)].lex).string == "main")
        mangled = NewPoolTString( "xlat_main");
    else
        mangled = (yyvsp[(2) - (3)].lex).string;

        function = new TFunction(mangled, type);
        (yyval.interm.function) = function;
    ;}
    break;

  case 94:
#line 1033 "hlslang.y"
    {
        if ((yyvsp[(1) - (2)].interm.type).type == EbtVoid) {
            parseContext.error((yyvsp[(2) - (2)].lex).line, "illegal use of type 'void'", (yyvsp[(2) - (2)].lex).string->c_str(), "");
            parseContext.recover();
        }
        if (parseContext.reservedErrorCheck((yyvsp[(2) - (2)].lex).line, *(yyvsp[(2) - (2)].lex).string))
            parseContext.recover();
        TParameter param = {(yyvsp[(2) - (2)].lex).string, 0, new TType((yyvsp[(1) - (2)].interm.type))};
        (yyval.interm).line = (yyvsp[(2) - (2)].lex).line;
        (yyval.interm).param = param;
    ;}
    break;

  case 95:
#line 1044 "hlslang.y"
    {
        if ((yyvsp[(1) - (4)].interm.type).type == EbtVoid) {
            parseContext.error((yyvsp[(2) - (4)].lex).line, "illegal use of type 'void'", (yyvsp[(2) - (4)].lex).string->c_str(), "");
            parseContext.recover();
        }
        if (parseContext.reservedErrorCheck((yyvsp[(2) - (4)].lex).line, *(yyvsp[(2) - (4)].lex).string))
            parseContext.recover();
        TParameter param = {(yyvsp[(2) - (4)].lex).string, 0, new TType((yyvsp[(1) - (4)].interm.type))};
        (yyval.interm).line = (yyvsp[(2) - (4)].lex).line;
        (yyval.interm).param = param;

        //TODO: add initializer support
    ;}
    break;

  case 96:
#line 1057 "hlslang.y"
    {
        // Parameter with register
        if ((yyvsp[(1) - (3)].interm.type).type == EbtVoid) {
            parseContext.error((yyvsp[(2) - (3)].lex).line, "illegal use of type 'void'", (yyvsp[(2) - (3)].lex).string->c_str(), "");
            parseContext.recover();
        }
        if (parseContext.reservedErrorCheck((yyvsp[(2) - (3)].lex).line, *(yyvsp[(2) - (3)].lex).string))
            parseContext.recover();
        TParameter param = {(yyvsp[(2) - (3)].lex).string, new TTypeInfo("", *(yyvsp[(3) - (3)].lex).string, 0), new TType((yyvsp[(1) - (3)].interm.type))};
        (yyval.interm).line = (yyvsp[(2) - (3)].lex).line;
        (yyval.interm).param = param; 
    ;}
    break;

  case 97:
#line 1069 "hlslang.y"
    {
        //Parameter with semantic
        if ((yyvsp[(1) - (4)].interm.type).type == EbtVoid) {
            parseContext.error((yyvsp[(2) - (4)].lex).line, "illegal use of type 'void'", (yyvsp[(2) - (4)].lex).string->c_str(), "");
            parseContext.recover();
        }
        if (parseContext.reservedErrorCheck((yyvsp[(2) - (4)].lex).line, *(yyvsp[(2) - (4)].lex).string))
            parseContext.recover();
        TParameter param = {(yyvsp[(2) - (4)].lex).string, new TTypeInfo(*(yyvsp[(4) - (4)].lex).string, 0), new TType((yyvsp[(1) - (4)].interm.type))};
        (yyval.interm).line = (yyvsp[(2) - (4)].lex).line;
        (yyval.interm).param = param;
    ;}
    break;

  case 98:
#line 1081 "hlslang.y"
    {
        // Check that we can make an array out of this type
        if (parseContext.arrayTypeErrorCheck((yyvsp[(3) - (5)].lex).line, (yyvsp[(1) - (5)].interm.type)))
            parseContext.recover();

        if (parseContext.reservedErrorCheck((yyvsp[(2) - (5)].lex).line, *(yyvsp[(2) - (5)].lex).string))
            parseContext.recover();

        int size;
        if (parseContext.arraySizeErrorCheck((yyvsp[(3) - (5)].lex).line, (yyvsp[(4) - (5)].interm.intermTypedNode), size))
            parseContext.recover();
        (yyvsp[(1) - (5)].interm.type).setArray(true, size);

        TType* type = new TType((yyvsp[(1) - (5)].interm.type));
        TParameter param = { (yyvsp[(2) - (5)].lex).string, 0, type };
        (yyval.interm).line = (yyvsp[(2) - (5)].lex).line;
        (yyval.interm).param = param;
    ;}
    break;

  case 99:
#line 1099 "hlslang.y"
    {
        // Check that we can make an array out of this type
        if (parseContext.arrayTypeErrorCheck((yyvsp[(3) - (7)].lex).line, (yyvsp[(1) - (7)].interm.type)))
            parseContext.recover();

        if (parseContext.reservedErrorCheck((yyvsp[(2) - (7)].lex).line, *(yyvsp[(2) - (7)].lex).string))
            parseContext.recover();

        int size;
        if (parseContext.arraySizeErrorCheck((yyvsp[(3) - (7)].lex).line, (yyvsp[(4) - (7)].interm.intermTypedNode), size))
            parseContext.recover();
        (yyvsp[(1) - (7)].interm.type).setArray(true, size);

        TType* type = new TType((yyvsp[(1) - (7)].interm.type));
        TParameter param = { (yyvsp[(2) - (7)].lex).string, new TTypeInfo(*(yyvsp[(7) - (7)].lex).string, 0), type };
        (yyval.interm).line = (yyvsp[(2) - (7)].lex).line;
        (yyval.interm).param = param;
    ;}
    break;

  case 100:
#line 1128 "hlslang.y"
    {
        (yyval.interm) = (yyvsp[(3) - (3)].interm);
        if (parseContext.paramErrorCheck((yyvsp[(3) - (3)].interm).line, (yyvsp[(1) - (3)].interm.type).qualifier, (yyvsp[(2) - (3)].interm.qualifier), (yyval.interm).param.type))
            parseContext.recover();
    ;}
    break;

  case 101:
#line 1133 "hlslang.y"
    {
        (yyval.interm) = (yyvsp[(2) - (2)].interm);
        if (parseContext.parameterSamplerErrorCheck((yyvsp[(2) - (2)].interm).line, (yyvsp[(1) - (2)].interm.qualifier), *(yyvsp[(2) - (2)].interm).param.type))
            parseContext.recover();
        if (parseContext.paramErrorCheck((yyvsp[(2) - (2)].interm).line, EvqTemporary, (yyvsp[(1) - (2)].interm.qualifier), (yyval.interm).param.type))
            parseContext.recover();
    ;}
    break;

  case 102:
#line 1143 "hlslang.y"
    {
        (yyval.interm) = (yyvsp[(3) - (3)].interm);
        if (parseContext.paramErrorCheck((yyvsp[(3) - (3)].interm).line, (yyvsp[(1) - (3)].interm.type).qualifier, (yyvsp[(2) - (3)].interm.qualifier), (yyval.interm).param.type))
            parseContext.recover();
    ;}
    break;

  case 103:
#line 1148 "hlslang.y"
    {
        (yyval.interm) = (yyvsp[(2) - (2)].interm);
        if (parseContext.parameterSamplerErrorCheck((yyvsp[(2) - (2)].interm).line, (yyvsp[(1) - (2)].interm.qualifier), *(yyvsp[(2) - (2)].interm).param.type))
            parseContext.recover();
        if (parseContext.paramErrorCheck((yyvsp[(2) - (2)].interm).line, EvqTemporary, (yyvsp[(1) - (2)].interm.qualifier), (yyval.interm).param.type))
            parseContext.recover();
    ;}
    break;

  case 104:
#line 1158 "hlslang.y"
    {
        (yyval.interm.qualifier) = EvqIn;
    ;}
    break;

  case 105:
#line 1161 "hlslang.y"
    {
        (yyval.interm.qualifier) = EvqIn;
    ;}
    break;

  case 106:
#line 1164 "hlslang.y"
    {
        (yyval.interm.qualifier) = EvqOut;
    ;}
    break;

  case 107:
#line 1167 "hlslang.y"
    {
        (yyval.interm.qualifier) = EvqInOut;
    ;}
    break;

  case 108:
#line 1173 "hlslang.y"
    {
        TParameter param = { 0, 0, new TType((yyvsp[(1) - (1)].interm.type)) };
        (yyval.interm).param = param;
    ;}
    break;

  case 109:
#line 1180 "hlslang.y"
    {
        (yyval.interm.intermDeclaration) = (yyvsp[(1) - (1)].interm.intermDeclaration);
    ;}
    break;

  case 110:
#line 1183 "hlslang.y"
    {
		TPublicType type = ir_get_decl_type_noarray((yyvsp[(1) - (4)].interm.intermDeclaration));
		
        if (parseContext.structQualifierErrorCheck((yyvsp[(3) - (4)].lex).line, type))
            parseContext.recover();
        
        if (parseContext.nonInitConstErrorCheck((yyvsp[(3) - (4)].lex).line, *(yyvsp[(3) - (4)].lex).string, type))
            parseContext.recover();

        if (parseContext.nonInitErrorCheck((yyvsp[(3) - (4)].lex).line, *(yyvsp[(3) - (4)].lex).string, (yyvsp[(4) - (4)].interm.typeInfo), type))
            parseContext.recover();
		
		TSymbol* sym = parseContext.symbolTable.find(*(yyvsp[(3) - (4)].lex).string);
		if (!sym)
			(yyval.interm.intermDeclaration) = (yyvsp[(1) - (4)].interm.intermDeclaration);
		else
			(yyval.interm.intermDeclaration) = ir_grow_declaration((yyvsp[(1) - (4)].interm.intermDeclaration), sym, NULL, parseContext);
    ;}
    break;

  case 111:
#line 1201 "hlslang.y"
    {
		TPublicType type = ir_get_decl_type_noarray((yyvsp[(1) - (6)].interm.intermDeclaration));
		
        if (parseContext.structQualifierErrorCheck((yyvsp[(3) - (6)].lex).line, type))
            parseContext.recover();
            
        if (parseContext.nonInitConstErrorCheck((yyvsp[(3) - (6)].lex).line, *(yyvsp[(3) - (6)].lex).string, type))
            parseContext.recover();
        
        if (parseContext.arrayTypeErrorCheck((yyvsp[(4) - (6)].lex).line, type) || parseContext.arrayQualifierErrorCheck((yyvsp[(4) - (6)].lex).line, type))
            parseContext.recover();
        else {
            TVariable* variable;
            if (parseContext.arrayErrorCheck((yyvsp[(4) - (6)].lex).line, *(yyvsp[(3) - (6)].lex).string, (yyvsp[(6) - (6)].interm.typeInfo), type, variable))
                parseContext.recover();
		
			if (!variable)
				(yyval.interm.intermDeclaration) = (yyvsp[(1) - (6)].interm.intermDeclaration);
			else {
				variable->getType().setArray(true);
				(yyval.interm.intermDeclaration) = ir_grow_declaration((yyvsp[(1) - (6)].interm.intermDeclaration), variable, NULL, parseContext);
			}
        }
    ;}
    break;

  case 112:
#line 1225 "hlslang.y"
    {
		TPublicType type = ir_get_decl_type_noarray((yyvsp[(1) - (7)].interm.intermDeclaration));
		
        if (parseContext.structQualifierErrorCheck((yyvsp[(3) - (7)].lex).line, type))
            parseContext.recover();
            
        if (parseContext.nonInitConstErrorCheck((yyvsp[(3) - (7)].lex).line, *(yyvsp[(3) - (7)].lex).string, type))
            parseContext.recover();

        if (parseContext.arrayTypeErrorCheck((yyvsp[(4) - (7)].lex).line, type) || parseContext.arrayQualifierErrorCheck((yyvsp[(4) - (7)].lex).line, type))
            parseContext.recover();
        else {
            int size;
            if (parseContext.arraySizeErrorCheck((yyvsp[(4) - (7)].lex).line, (yyvsp[(5) - (7)].interm.intermTypedNode), size))
                parseContext.recover();
            type.setArray(true, size);
			
            TVariable* variable;
            if (parseContext.arrayErrorCheck((yyvsp[(4) - (7)].lex).line, *(yyvsp[(3) - (7)].lex).string, (yyvsp[(7) - (7)].interm.typeInfo), type, variable))
                parseContext.recover();
			
			if (!variable)
				(yyval.interm.intermDeclaration) = (yyvsp[(1) - (7)].interm.intermDeclaration);
			else {
				(yyval.interm.intermDeclaration) = ir_grow_declaration((yyvsp[(1) - (7)].interm.intermDeclaration), variable, NULL, parseContext);
			}
        }
    ;}
    break;

  case 113:
#line 1253 "hlslang.y"
    {
		TPublicType type = ir_get_decl_type_noarray((yyvsp[(1) - (8)].interm.intermDeclaration));
		
        if (parseContext.structQualifierErrorCheck((yyvsp[(3) - (8)].lex).line, type))
            parseContext.recover();
            
        TVariable* variable = 0;
        if (parseContext.arrayTypeErrorCheck((yyvsp[(4) - (8)].lex).line, type) || parseContext.arrayQualifierErrorCheck((yyvsp[(4) - (8)].lex).line, type))
            parseContext.recover();
        else if (parseContext.arrayErrorCheck((yyvsp[(4) - (8)].lex).line, *(yyvsp[(3) - (8)].lex).string, type, variable))
			parseContext.recover();
		
        {
            TIntermSymbol* symbol;
            type.setArray(true, (yyvsp[(8) - (8)].interm.intermTypedNode)->getType().getArraySize());
            if (!parseContext.executeInitializer((yyvsp[(3) - (8)].lex).line, *(yyvsp[(3) - (8)].lex).string, (yyvsp[(6) - (8)].interm.typeInfo), type, (yyvsp[(8) - (8)].interm.intermTypedNode), symbol, variable)) {
                if (!variable)
					(yyval.interm.intermDeclaration) = (yyvsp[(1) - (8)].interm.intermDeclaration);
				else {
					(yyval.interm.intermDeclaration) = ir_grow_declaration((yyvsp[(1) - (8)].interm.intermDeclaration), variable, (yyvsp[(8) - (8)].interm.intermTypedNode), parseContext);
				}
            } else {
                parseContext.recover();
                (yyval.interm.intermDeclaration) = 0;
            }
        }
    ;}
    break;

  case 114:
#line 1280 "hlslang.y"
    {
		TPublicType type = ir_get_decl_type_noarray((yyvsp[(1) - (9)].interm.intermDeclaration));
		int array_size;
		
        if (parseContext.structQualifierErrorCheck((yyvsp[(3) - (9)].lex).line, type))
            parseContext.recover();
            
        TVariable* variable = 0;
        if (parseContext.arrayTypeErrorCheck((yyvsp[(4) - (9)].lex).line, type) || parseContext.arrayQualifierErrorCheck((yyvsp[(4) - (9)].lex).line, type))
            parseContext.recover();
        else {
            if (parseContext.arraySizeErrorCheck((yyvsp[(4) - (9)].lex).line, (yyvsp[(5) - (9)].interm.intermTypedNode), array_size))
                parseContext.recover();
			
            type.setArray(true, array_size);
            if (parseContext.arrayErrorCheck((yyvsp[(4) - (9)].lex).line, *(yyvsp[(3) - (9)].lex).string, (yyvsp[(7) - (9)].interm.typeInfo), type, variable))
                parseContext.recover();
        }

        {
            TIntermSymbol* symbol;
            if (!parseContext.executeInitializer((yyvsp[(3) - (9)].lex).line, *(yyvsp[(3) - (9)].lex).string, (yyvsp[(7) - (9)].interm.typeInfo), type, (yyvsp[(9) - (9)].interm.intermTypedNode), symbol, variable)) {
				if (!variable)
					(yyval.interm.intermDeclaration) = (yyvsp[(1) - (9)].interm.intermDeclaration);
				else {
					(yyval.interm.intermDeclaration) = ir_grow_declaration((yyvsp[(1) - (9)].interm.intermDeclaration), variable, (yyvsp[(9) - (9)].interm.intermTypedNode), parseContext);
				}
            } else {
                parseContext.recover();
                (yyval.interm.intermDeclaration) = 0;
            }
        }
    ;}
    break;

  case 115:
#line 1313 "hlslang.y"
    {
		TPublicType type = ir_get_decl_type_noarray((yyvsp[(1) - (6)].interm.intermDeclaration));
		
        if (parseContext.structQualifierErrorCheck((yyvsp[(3) - (6)].lex).line, type))
            parseContext.recover();
			
        TIntermSymbol* symbol;
		if ( !IsSampler(type.type)) {
			if (!parseContext.executeInitializer((yyvsp[(3) - (6)].lex).line, *(yyvsp[(3) - (6)].lex).string, (yyvsp[(4) - (6)].interm.typeInfo), type, (yyvsp[(6) - (6)].interm.intermTypedNode), symbol)) {
				TSymbol* variable = parseContext.symbolTable.find(*(yyvsp[(3) - (6)].lex).string);
				if (!variable)
					(yyval.interm.intermDeclaration) = (yyvsp[(1) - (6)].interm.intermDeclaration);
				else 				
					(yyval.interm.intermDeclaration) = ir_grow_declaration((yyvsp[(1) - (6)].interm.intermDeclaration), variable, (yyvsp[(6) - (6)].interm.intermTypedNode), parseContext);
			} else {
				parseContext.recover();
				(yyval.interm.intermDeclaration) = 0;
			}
		} else {
			//Special code to skip initializers for samplers
			(yyval.interm.intermDeclaration) = (yyvsp[(1) - (6)].interm.intermDeclaration);
			if (parseContext.structQualifierErrorCheck((yyvsp[(3) - (6)].lex).line, type))
				parseContext.recover();
			
			if (parseContext.nonInitConstErrorCheck((yyvsp[(3) - (6)].lex).line, *(yyvsp[(3) - (6)].lex).string, type))
				parseContext.recover();
			
			if (parseContext.nonInitErrorCheck((yyvsp[(3) - (6)].lex).line, *(yyvsp[(3) - (6)].lex).string, (yyvsp[(4) - (6)].interm.typeInfo), type))
				parseContext.recover();
		}
	;}
    break;

  case 116:
#line 1347 "hlslang.y"
    {
		(yyval.interm.intermDeclaration) = 0;
    ;}
    break;

  case 117:
#line 1350 "hlslang.y"
    {				
		bool error = false;
        if (error &= parseContext.structQualifierErrorCheck((yyvsp[(2) - (3)].lex).line, (yyvsp[(1) - (3)].interm.type)))
            parseContext.recover();
        
        if (error &= parseContext.nonInitConstErrorCheck((yyvsp[(2) - (3)].lex).line, *(yyvsp[(2) - (3)].lex).string, (yyvsp[(1) - (3)].interm.type)))
            parseContext.recover();

        if (error &= parseContext.nonInitErrorCheck((yyvsp[(2) - (3)].lex).line, *(yyvsp[(2) - (3)].lex).string, (yyvsp[(3) - (3)].interm.typeInfo), (yyvsp[(1) - (3)].interm.type)))
            parseContext.recover();
		
		TSymbol* symbol = parseContext.symbolTable.find(*(yyvsp[(2) - (3)].lex).string);
		if (!error && symbol) {
			(yyval.interm.intermDeclaration) = ir_add_declaration(symbol, NULL, (yyvsp[(2) - (3)].lex).line, parseContext);
		} else {
			(yyval.interm.intermDeclaration) = 0;
		}
    ;}
    break;

  case 118:
#line 1368 "hlslang.y"
    {
        if (parseContext.structQualifierErrorCheck((yyvsp[(2) - (5)].lex).line, (yyvsp[(1) - (5)].interm.type)))
            parseContext.recover();

        if (parseContext.nonInitConstErrorCheck((yyvsp[(2) - (5)].lex).line, *(yyvsp[(2) - (5)].lex).string, (yyvsp[(1) - (5)].interm.type)))
            parseContext.recover();

        if (parseContext.arrayTypeErrorCheck((yyvsp[(3) - (5)].lex).line, (yyvsp[(1) - (5)].interm.type)) || parseContext.arrayQualifierErrorCheck((yyvsp[(3) - (5)].lex).line, (yyvsp[(1) - (5)].interm.type)))
            parseContext.recover();
        else {
            (yyvsp[(1) - (5)].interm.type).setArray(true);
            TVariable* variable;
            if (parseContext.arrayErrorCheck((yyvsp[(3) - (5)].lex).line, *(yyvsp[(2) - (5)].lex).string, (yyvsp[(5) - (5)].interm.typeInfo), (yyvsp[(1) - (5)].interm.type), variable))
                parseContext.recover();
        }
		
		TSymbol* symbol = parseContext.symbolTable.find(*(yyvsp[(2) - (5)].lex).string);
		if (symbol) {
			(yyval.interm.intermDeclaration) = ir_add_declaration(symbol, NULL, (yyvsp[(2) - (5)].lex).line, parseContext);
		} else {
			(yyval.interm.intermDeclaration) = 0;
		}
    ;}
    break;

  case 119:
#line 1391 "hlslang.y"
    {
        if (parseContext.structQualifierErrorCheck((yyvsp[(2) - (6)].lex).line, (yyvsp[(1) - (6)].interm.type)))
            parseContext.recover();

        if (parseContext.nonInitConstErrorCheck((yyvsp[(2) - (6)].lex).line, *(yyvsp[(2) - (6)].lex).string, (yyvsp[(1) - (6)].interm.type)))
			parseContext.recover();
		
		TVariable* variable;
        if (parseContext.arrayTypeErrorCheck((yyvsp[(3) - (6)].lex).line, (yyvsp[(1) - (6)].interm.type)) || parseContext.arrayQualifierErrorCheck((yyvsp[(3) - (6)].lex).line, (yyvsp[(1) - (6)].interm.type)))
            parseContext.recover();
        else {
            int size;
            if (parseContext.arraySizeErrorCheck((yyvsp[(3) - (6)].lex).line, (yyvsp[(4) - (6)].interm.intermTypedNode), size))
                parseContext.recover();

            (yyvsp[(1) - (6)].interm.type).setArray(true, size);
            if (parseContext.arrayErrorCheck((yyvsp[(3) - (6)].lex).line, *(yyvsp[(2) - (6)].lex).string, (yyvsp[(6) - (6)].interm.typeInfo), (yyvsp[(1) - (6)].interm.type), variable))
                parseContext.recover();
			
			if (variable) {
				(yyval.interm.intermDeclaration) = ir_add_declaration(variable, NULL, (yyvsp[(2) - (6)].lex).line, parseContext);
			} else {
				(yyval.interm.intermDeclaration) = 0;
			}
        }
	;}
    break;

  case 120:
#line 1417 "hlslang.y"
    {
		if (parseContext.structQualifierErrorCheck((yyvsp[(2) - (7)].lex).line, (yyvsp[(1) - (7)].interm.type)))
			parseContext.recover();

		TVariable* variable = 0;
		if (parseContext.arrayTypeErrorCheck((yyvsp[(3) - (7)].lex).line, (yyvsp[(1) - (7)].interm.type)) || parseContext.arrayQualifierErrorCheck((yyvsp[(3) - (7)].lex).line, (yyvsp[(1) - (7)].interm.type)))
			parseContext.recover();
		else {
			(yyvsp[(1) - (7)].interm.type).setArray(true, (yyvsp[(7) - (7)].interm.intermTypedNode)->getType().getArraySize());
			if (parseContext.arrayErrorCheck((yyvsp[(3) - (7)].lex).line, *(yyvsp[(2) - (7)].lex).string, (yyvsp[(5) - (7)].interm.typeInfo), (yyvsp[(1) - (7)].interm.type), variable))
				parseContext.recover();
		}

		{        
			TIntermSymbol* symbol;
			if (!parseContext.executeInitializer((yyvsp[(2) - (7)].lex).line, *(yyvsp[(2) - (7)].lex).string, (yyvsp[(5) - (7)].interm.typeInfo), (yyvsp[(1) - (7)].interm.type), (yyvsp[(7) - (7)].interm.intermTypedNode), symbol, variable)) {
				if (variable)
					(yyval.interm.intermDeclaration) = ir_add_declaration(symbol, (yyvsp[(7) - (7)].interm.intermTypedNode), (yyvsp[(6) - (7)].lex).line, parseContext);
				else
					(yyval.interm.intermDeclaration) = 0;
			} else {
				parseContext.recover();
				(yyval.interm.intermDeclaration) = 0;
			}
		}
    ;}
    break;

  case 121:
#line 1443 "hlslang.y"
    {
        if (parseContext.structQualifierErrorCheck((yyvsp[(2) - (8)].lex).line, (yyvsp[(1) - (8)].interm.type)))
            parseContext.recover();

        TVariable* variable = 0;
        if (parseContext.arrayTypeErrorCheck((yyvsp[(3) - (8)].lex).line, (yyvsp[(1) - (8)].interm.type)) || parseContext.arrayQualifierErrorCheck((yyvsp[(3) - (8)].lex).line, (yyvsp[(1) - (8)].interm.type)))
            parseContext.recover();
        else {
            int size;
            if (parseContext.arraySizeErrorCheck((yyvsp[(3) - (8)].lex).line, (yyvsp[(4) - (8)].interm.intermTypedNode), size))
                parseContext.recover();

            (yyvsp[(1) - (8)].interm.type).setArray(true, size);
            if (parseContext.arrayErrorCheck((yyvsp[(3) - (8)].lex).line, *(yyvsp[(2) - (8)].lex).string, (yyvsp[(6) - (8)].interm.typeInfo), (yyvsp[(1) - (8)].interm.type), variable))
                parseContext.recover();
        }
        
		{        
			TIntermSymbol* symbol;
			if (!parseContext.executeInitializer((yyvsp[(2) - (8)].lex).line, *(yyvsp[(2) - (8)].lex).string, (yyvsp[(6) - (8)].interm.typeInfo), (yyvsp[(1) - (8)].interm.type), (yyvsp[(8) - (8)].interm.intermTypedNode), symbol, variable)) {
				if (variable)
					(yyval.interm.intermDeclaration) = ir_add_declaration(symbol, (yyvsp[(8) - (8)].interm.intermTypedNode), (yyvsp[(7) - (8)].lex).line, parseContext);
				else
					(yyval.interm.intermDeclaration) = 0;
			} else {
				parseContext.recover();
				(yyval.interm.intermDeclaration) = 0;
			}
		}       
    ;}
    break;

  case 122:
#line 1473 "hlslang.y"
    {
		if (parseContext.structQualifierErrorCheck((yyvsp[(2) - (5)].lex).line, (yyvsp[(1) - (5)].interm.type)))
			parseContext.recover();
		
		if (!IsSampler((yyvsp[(1) - (5)].interm.type).type)) {
			TIntermSymbol* symbol;
			if (!parseContext.executeInitializer((yyvsp[(2) - (5)].lex).line, *(yyvsp[(2) - (5)].lex).string, (yyvsp[(3) - (5)].interm.typeInfo), (yyvsp[(1) - (5)].interm.type), (yyvsp[(5) - (5)].interm.intermTypedNode), symbol)) {
				if (symbol)
					(yyval.interm.intermDeclaration) = ir_add_declaration(symbol, (yyvsp[(5) - (5)].interm.intermTypedNode), (yyvsp[(4) - (5)].lex).line, parseContext);
				else
					(yyval.interm.intermDeclaration) = 0;
			} else {
				parseContext.recover();
				(yyval.interm.intermDeclaration) = 0;
			}
		} else {
			if (parseContext.structQualifierErrorCheck((yyvsp[(2) - (5)].lex).line, (yyvsp[(1) - (5)].interm.type)))
				parseContext.recover();

			if (parseContext.nonInitConstErrorCheck((yyvsp[(2) - (5)].lex).line, *(yyvsp[(2) - (5)].lex).string, (yyvsp[(1) - (5)].interm.type)))
				parseContext.recover();

			if (parseContext.nonInitErrorCheck((yyvsp[(2) - (5)].lex).line, *(yyvsp[(2) - (5)].lex).string, (yyvsp[(3) - (5)].interm.typeInfo), (yyvsp[(1) - (5)].interm.type)))
				parseContext.recover();
				
			TSymbol* symbol = parseContext.symbolTable.find(*(yyvsp[(2) - (5)].lex).string);
			if (symbol) {
				(yyval.interm.intermDeclaration) = ir_add_declaration(symbol, NULL, (yyvsp[(2) - (5)].lex).line, parseContext);
			} else {
				(yyval.interm.intermDeclaration) = 0;
			}
		}
    ;}
    break;

  case 123:
#line 1521 "hlslang.y"
    {
        (yyval.interm.type) = (yyvsp[(1) - (1)].interm.type);
    ;}
    break;

  case 124:
#line 1524 "hlslang.y"
    {
        if ((yyvsp[(2) - (2)].interm.type).array && parseContext.arrayQualifierErrorCheck((yyvsp[(2) - (2)].interm.type).line, (yyvsp[(1) - (2)].interm.type))) {
            parseContext.recover();
            (yyvsp[(2) - (2)].interm.type).setArray(false);
        }

        if ((yyvsp[(1) - (2)].interm.type).qualifier == EvqAttribute &&
            ((yyvsp[(2) - (2)].interm.type).type == EbtBool || (yyvsp[(2) - (2)].interm.type).type == EbtInt)) {
            parseContext.error((yyvsp[(2) - (2)].interm.type).line, "cannot be bool or int", getQualifierString((yyvsp[(1) - (2)].interm.type).qualifier), "");
            parseContext.recover();
        }
        (yyval.interm.type) = (yyvsp[(2) - (2)].interm.type); 
        (yyval.interm.type).qualifier = (yyvsp[(1) - (2)].interm.type).qualifier;
    ;}
    break;

  case 125:
#line 1541 "hlslang.y"
    {
        (yyval.interm.type).setBasic(EbtVoid, EvqConst, (yyvsp[(1) - (1)].lex).line);
    ;}
    break;

  case 126:
#line 1544 "hlslang.y"
    {
        (yyval.interm.type).setBasic(EbtVoid, EvqStatic, (yyvsp[(1) - (1)].lex).line);
    ;}
    break;

  case 127:
#line 1547 "hlslang.y"
    {
        (yyval.interm.type).setBasic(EbtVoid, EvqConst, (yyvsp[(1) - (2)].lex).line); // same as "const" really
    ;}
    break;

  case 128:
#line 1550 "hlslang.y"
    {
        (yyval.interm.type).setBasic(EbtVoid, EvqConst, (yyvsp[(1) - (2)].lex).line); // same as "const" really
    ;}
    break;

  case 129:
#line 1553 "hlslang.y"
    {
        if (parseContext.globalErrorCheck((yyvsp[(1) - (1)].lex).line, parseContext.symbolTable.atGlobalLevel(), "uniform"))
            parseContext.recover();
        (yyval.interm.type).setBasic(EbtVoid, EvqUniform, (yyvsp[(1) - (1)].lex).line);
    ;}
    break;

  case 130:
#line 1561 "hlslang.y"
    {
        (yyval.interm.type) = (yyvsp[(1) - (1)].interm.type);
    ;}
    break;

  case 131:
#line 1564 "hlslang.y"
    {
        (yyval.interm.type) = (yyvsp[(1) - (4)].interm.type);

        if (parseContext.arrayTypeErrorCheck((yyvsp[(2) - (4)].lex).line, (yyvsp[(1) - (4)].interm.type)))
            parseContext.recover();
        else {
            int size;
            if (parseContext.arraySizeErrorCheck((yyvsp[(2) - (4)].lex).line, (yyvsp[(3) - (4)].interm.intermTypedNode), size))
                parseContext.recover();
            (yyval.interm.type).setArray(true, size);
        }
    ;}
    break;

  case 132:
#line 1579 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtVoid,EbpUndefined);
    ;}
    break;

  case 133:
#line 1582 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpHigh);
    ;}
    break;

  case 134:
#line 1585 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpMedium);
    ;}
    break;

  case 135:
#line 1588 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpLow);
    ;}
    break;

  case 136:
#line 1591 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtInt,EbpHigh);
    ;}
    break;

  case 137:
#line 1594 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtBool,EbpHigh);
    ;}
    break;

  case 138:
#line 1597 "hlslang.y"
    {
        TQualifier qual = parseContext.getDefaultQualifier();
        if ( (yyvsp[(5) - (6)].lex).i > 4 || (yyvsp[(5) - (6)].lex).i < 1 ) {
            parseContext.error((yyvsp[(2) - (6)].lex).line, "vector dimension out of range", "", "");
            parseContext.recover();
            (yyval.interm.type).setBasic(EbtFloat, qual, (yyvsp[(1) - (6)].lex).line);
        } else {
            (yyval.interm.type).setBasic(EbtFloat, qual, (yyvsp[(1) - (6)].lex).line);
            (yyval.interm.type).setVector((yyvsp[(5) - (6)].lex).i);
        }
    ;}
    break;

  case 139:
#line 1608 "hlslang.y"
    {
        TQualifier qual = parseContext.getDefaultQualifier();
        if ( (yyvsp[(5) - (6)].lex).i > 4 || (yyvsp[(5) - (6)].lex).i < 1 ) {
            parseContext.error((yyvsp[(2) - (6)].lex).line, "vector dimension out of range", "", "");
            parseContext.recover();
            (yyval.interm.type).setBasic(EbtInt, qual, (yyvsp[(1) - (6)].lex).line);
        } else {
            (yyval.interm.type).setBasic(EbtInt, qual, (yyvsp[(1) - (6)].lex).line);
            (yyval.interm.type).setVector((yyvsp[(5) - (6)].lex).i);
        }
    ;}
    break;

  case 140:
#line 1619 "hlslang.y"
    {
        TQualifier qual = parseContext.getDefaultQualifier();
        if ( (yyvsp[(5) - (6)].lex).i > 4 || (yyvsp[(5) - (6)].lex).i < 1 ) {
            parseContext.error((yyvsp[(2) - (6)].lex).line, "vector dimension out of range", "", "");
            parseContext.recover();
            (yyval.interm.type).setBasic(EbtBool, qual, (yyvsp[(1) - (6)].lex).line);
        } else {
            (yyval.interm.type).setBasic(EbtBool, qual, (yyvsp[(1) - (6)].lex).line);
            (yyval.interm.type).setVector((yyvsp[(5) - (6)].lex).i);
        }
    ;}
    break;

  case 141:
#line 1630 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpHigh);
        (yyval.interm.type).setVector(2);
    ;}
    break;

  case 142:
#line 1634 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpHigh);
        (yyval.interm.type).setVector(3);
    ;}
    break;

  case 143:
#line 1638 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpHigh);
        (yyval.interm.type).setVector(4);
    ;}
    break;

  case 144:
#line 1642 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpMedium);
        (yyval.interm.type).setVector(2);
    ;}
    break;

  case 145:
#line 1646 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpMedium);
        (yyval.interm.type).setVector(3);
    ;}
    break;

  case 146:
#line 1650 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpMedium);
        (yyval.interm.type).setVector(4);
    ;}
    break;

  case 147:
#line 1654 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpLow);
        (yyval.interm.type).setVector(2);
    ;}
    break;

  case 148:
#line 1658 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpLow);
        (yyval.interm.type).setVector(3);
    ;}
    break;

  case 149:
#line 1662 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpLow);
        (yyval.interm.type).setVector(4);
    ;}
    break;

  case 150:
#line 1666 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtBool,EbpHigh);
        (yyval.interm.type).setVector(2);
    ;}
    break;

  case 151:
#line 1670 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtBool,EbpHigh);
        (yyval.interm.type).setVector(3);
    ;}
    break;

  case 152:
#line 1674 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtBool,EbpHigh);
        (yyval.interm.type).setVector(4);
    ;}
    break;

  case 153:
#line 1678 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtInt,EbpHigh);
        (yyval.interm.type).setVector(2);
    ;}
    break;

  case 154:
#line 1682 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtInt,EbpHigh);
        (yyval.interm.type).setVector(3);
    ;}
    break;

  case 155:
#line 1686 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtInt,EbpHigh);
        (yyval.interm.type).setVector(4);
    ;}
    break;

  case 156:
#line 1690 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpHigh);
        (yyval.interm.type).setMatrix(2, 2);
    ;}
    break;

  case 157:
#line 1694 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("float2x3", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpHigh);
        (yyval.interm.type).setMatrix(3, 2);
    ;}
    break;

  case 158:
#line 1699 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("float2x4", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpHigh);
        (yyval.interm.type).setMatrix(4, 2);
    ;}
    break;

  case 159:
#line 1704 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("float3x2", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpHigh);
        (yyval.interm.type).setMatrix(2, 3);
    ;}
    break;

  case 160:
#line 1709 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpHigh);
        (yyval.interm.type).setMatrix(3, 3);
    ;}
    break;

  case 161:
#line 1713 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("float3x4", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpHigh);
        (yyval.interm.type).setMatrix(4, 3);
    ;}
    break;

  case 162:
#line 1718 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("float4x2", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpHigh);
        (yyval.interm.type).setMatrix(2, 4);
    ;}
    break;

  case 163:
#line 1723 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("float4x3", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpHigh);
        (yyval.interm.type).setMatrix(3, 4);
    ;}
    break;

  case 164:
#line 1728 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpHigh);
        (yyval.interm.type).setMatrix(4, 4);
    ;}
    break;

  case 165:
#line 1732 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpMedium);
        (yyval.interm.type).setMatrix(2, 2);
    ;}
    break;

  case 166:
#line 1736 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("half2x3", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpMedium);
        (yyval.interm.type).setMatrix(3, 2);
    ;}
    break;

  case 167:
#line 1741 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("half2x4", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpMedium);
        (yyval.interm.type).setMatrix(4, 2);
    ;}
    break;

  case 168:
#line 1746 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("half3x2", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpMedium);
        (yyval.interm.type).setMatrix(2, 3);
    ;}
    break;

  case 169:
#line 1751 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpMedium);
        (yyval.interm.type).setMatrix(3, 3);
    ;}
    break;

  case 170:
#line 1755 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("half3x4", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpMedium);
        (yyval.interm.type).setMatrix(4, 3);
    ;}
    break;

  case 171:
#line 1760 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("half4x2", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpMedium);
        (yyval.interm.type).setMatrix(2, 4);
    ;}
    break;

  case 172:
#line 1765 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("half4x3", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpMedium);
        (yyval.interm.type).setMatrix(3, 4);
    ;}
    break;

  case 173:
#line 1770 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpMedium);
        (yyval.interm.type).setMatrix(4, 4);
    ;}
    break;

  case 174:
#line 1774 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpLow);
        (yyval.interm.type).setMatrix(2, 2);
    ;}
    break;

  case 175:
#line 1778 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("fixed2x3", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpLow);
        (yyval.interm.type).setMatrix(3, 2);
    ;}
    break;

  case 176:
#line 1783 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("fixed2x4", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpLow);
        (yyval.interm.type).setMatrix(4, 2);
    ;}
    break;

  case 177:
#line 1788 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("fixed3x2", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpLow);
        (yyval.interm.type).setMatrix(2, 3);
    ;}
    break;

  case 178:
#line 1793 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpLow);
        (yyval.interm.type).setMatrix(3, 3);
    ;}
    break;

  case 179:
#line 1797 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("fixed3x4", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpLow);
        (yyval.interm.type).setMatrix(4, 3);
    ;}
    break;

  case 180:
#line 1802 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("fixed4x2", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpLow);
        (yyval.interm.type).setMatrix(2, 4);
    ;}
    break;

  case 181:
#line 1807 "hlslang.y"
    {
		NONSQUARE_MATRIX_CHECK("fixed4x3", (yyvsp[(1) - (1)].lex).line);
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpLow);
        (yyval.interm.type).setMatrix(3, 4);
    ;}
    break;

  case 182:
#line 1812 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtFloat,EbpLow);
        (yyval.interm.type).setMatrix(4, 4);
    ;}
    break;

  case 183:
#line 1816 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtTexture,EbpUndefined);
    ;}
    break;

  case 184:
#line 1819 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtSamplerGeneric,EbpUndefined);
    ;}
    break;

  case 185:
#line 1822 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtSampler1D,EbpUndefined);
    ;}
    break;

  case 186:
#line 1825 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtSampler2D,EbpUndefined);
    ;}
    break;

  case 187:
#line 1828 "hlslang.y"
    {
		SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtSampler2D,EbpMedium);
	;}
    break;

  case 188:
#line 1831 "hlslang.y"
    {
		SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtSampler2D,EbpHigh);
	;}
    break;

  case 189:
#line 1834 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtSampler3D,EbpLow);
    ;}
    break;

  case 190:
#line 1837 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtSamplerCube,EbpUndefined);
    ;}
    break;

  case 191:
#line 1840 "hlslang.y"
    {
		SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtSamplerCube,EbpMedium);
	;}
    break;

  case 192:
#line 1843 "hlslang.y"
    {
		SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtSamplerCube,EbpHigh);
	;}
    break;

  case 193:
#line 1846 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtSamplerRect,EbpUndefined);
    ;}
    break;

  case 194:
#line 1849 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtSamplerRectShadow,EbpLow); // ES3 doesn't have default precision for shadow samplers, so always emit lowp
    ;}
    break;

  case 195:
#line 1852 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtSampler1DShadow,EbpLow); // ES3 doesn't have default precision for shadow samplers, so always emit lowp
    ;}
    break;

  case 196:
#line 1855 "hlslang.y"
    {
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtSampler2DShadow,EbpLow); // ES3 doesn't have default precision for shadow samplers, so always emit lowp
    ;}
    break;

  case 197:
#line 1858 "hlslang.y"
    {
		SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtSampler2DArray,EbpLow);
	;}
    break;

  case 198:
#line 1861 "hlslang.y"
    {
        (yyval.interm.type) = (yyvsp[(1) - (1)].interm.type);
        (yyval.interm.type).qualifier = parseContext.getDefaultQualifier();
    ;}
    break;

  case 199:
#line 1865 "hlslang.y"
    {
        //
        // This is for user defined type names.  The lexical phase looked up the
        // type.
        //
        TType& structure = static_cast<TVariable*>((yyvsp[(1) - (1)].lex).symbol)->getType();
        SET_BASIC_TYPE((yyval.interm.type),(yyvsp[(1) - (1)].lex),EbtStruct,EbpUndefined);
        (yyval.interm.type).userDef = &structure;
    ;}
    break;

  case 200:
#line 1877 "hlslang.y"
    {
        TType* structure = new TType((yyvsp[(4) - (5)].interm.typeList), *(yyvsp[(2) - (5)].lex).string, EbpUndefined, (yyvsp[(2) - (5)].lex).line);
        TVariable* userTypeDef = new TVariable((yyvsp[(2) - (5)].lex).string, *structure, true);
        if (! parseContext.symbolTable.insert(*userTypeDef)) {
            parseContext.error((yyvsp[(2) - (5)].lex).line, "redefinition", (yyvsp[(2) - (5)].lex).string->c_str(), "struct");
            parseContext.recover();
        }
        (yyval.interm.type).setBasic(EbtStruct, EvqTemporary, (yyvsp[(1) - (5)].lex).line);
        (yyval.interm.type).userDef = structure;
    ;}
    break;

  case 201:
#line 1887 "hlslang.y"
    {
        TType* structure = new TType((yyvsp[(3) - (4)].interm.typeList), TString(""), EbpUndefined, (yyvsp[(1) - (4)].lex).line);
        (yyval.interm.type).setBasic(EbtStruct, EvqTemporary, (yyvsp[(1) - (4)].lex).line);
        (yyval.interm.type).userDef = structure;
    ;}
    break;

  case 202:
#line 1895 "hlslang.y"
    {
        (yyval.interm.typeList) = (yyvsp[(1) - (1)].interm.typeList);
    ;}
    break;

  case 203:
#line 1898 "hlslang.y"
    {
        (yyval.interm.typeList) = (yyvsp[(1) - (2)].interm.typeList);
        for (unsigned int i = 0; i < (yyvsp[(2) - (2)].interm.typeList)->size(); ++i) {
            for (unsigned int j = 0; j < (yyval.interm.typeList)->size(); ++j) {
                if ((*(yyval.interm.typeList))[j].type->getFieldName() == (*(yyvsp[(2) - (2)].interm.typeList))[i].type->getFieldName()) {
                    parseContext.error((*(yyvsp[(2) - (2)].interm.typeList))[i].line, "duplicate field name in structure:", "struct", (*(yyvsp[(2) - (2)].interm.typeList))[i].type->getFieldName().c_str());
                    parseContext.recover();
                }
            }
            (yyval.interm.typeList)->push_back((*(yyvsp[(2) - (2)].interm.typeList))[i]);
        }
    ;}
    break;

  case 204:
#line 1913 "hlslang.y"
    {
        (yyval.interm.typeList) = (yyvsp[(2) - (3)].interm.typeList);

        if (parseContext.voidErrorCheck((yyvsp[(1) - (3)].interm.type).line, (*(yyvsp[(2) - (3)].interm.typeList))[0].type->getFieldName(), (yyvsp[(1) - (3)].interm.type))) {
            parseContext.recover();
        }
        for (unsigned int i = 0; i < (yyval.interm.typeList)->size(); ++i) {
            //
            // Careful not to replace already know aspects of type, like array-ness
            //
            TType* type = (*(yyval.interm.typeList))[i].type;
            type->setBasicType((yyvsp[(1) - (3)].interm.type).type);
            type->setPrecision((yyvsp[(1) - (3)].interm.type).precision);
            type->setColsCount((yyvsp[(1) - (3)].interm.type).matcols);
            type->setRowsCount((yyvsp[(1) - (3)].interm.type).matrows);
            type->setMatrix((yyvsp[(1) - (3)].interm.type).matrix);
            
            // don't allow arrays of arrays
            if (type->isArray()) {
                if (parseContext.arrayTypeErrorCheck((yyvsp[(1) - (3)].interm.type).line, (yyvsp[(1) - (3)].interm.type)))
                    parseContext.recover();
            }
            if ((yyvsp[(1) - (3)].interm.type).array)
                type->setArraySize((yyvsp[(1) - (3)].interm.type).arraySize);
            if ((yyvsp[(1) - (3)].interm.type).userDef) {
                type->setStruct((yyvsp[(1) - (3)].interm.type).userDef->getStruct());
                type->setTypeName((yyvsp[(1) - (3)].interm.type).userDef->getTypeName());
            }
        }
    ;}
    break;

  case 205:
#line 1946 "hlslang.y"
    {
        (yyval.interm.typeList) = NewPoolTTypeList();
        (yyval.interm.typeList)->push_back((yyvsp[(1) - (1)].interm.typeLine));
    ;}
    break;

  case 206:
#line 1950 "hlslang.y"
    {
        (yyval.interm.typeList)->push_back((yyvsp[(3) - (3)].interm.typeLine));
    ;}
    break;

  case 207:
#line 1956 "hlslang.y"
    {
        (yyval.interm.typeLine).type = new TType(EbtVoid, EbpUndefined);
        (yyval.interm.typeLine).line = (yyvsp[(1) - (1)].lex).line;
        (yyval.interm.typeLine).type->setFieldName(*(yyvsp[(1) - (1)].lex).string);
    ;}
    break;

  case 208:
#line 1961 "hlslang.y"
    {
        (yyval.interm.typeLine).type = new TType(EbtVoid, EbpUndefined);
        (yyval.interm.typeLine).line = (yyvsp[(1) - (3)].lex).line;
        (yyval.interm.typeLine).type->setFieldName(*(yyvsp[(1) - (3)].lex).string);
        (yyval.interm.typeLine).type->setSemantic(*(yyvsp[(3) - (3)].lex).string);
    ;}
    break;

  case 209:
#line 1967 "hlslang.y"
    {
        (yyval.interm.typeLine).type = new TType(EbtVoid, EbpUndefined);
        (yyval.interm.typeLine).line = (yyvsp[(1) - (4)].lex).line;
        (yyval.interm.typeLine).type->setFieldName(*(yyvsp[(1) - (4)].lex).string);

        int size;
        if (parseContext.arraySizeErrorCheck((yyvsp[(2) - (4)].lex).line, (yyvsp[(3) - (4)].interm.intermTypedNode), size))
            parseContext.recover();
        (yyval.interm.typeLine).type->setArraySize(size);
    ;}
    break;

  case 210:
#line 1977 "hlslang.y"
    {
        (yyval.interm.typeLine).type = new TType(EbtVoid, EbpUndefined);
        (yyval.interm.typeLine).line = (yyvsp[(1) - (6)].lex).line;
        (yyval.interm.typeLine).type->setFieldName(*(yyvsp[(1) - (6)].lex).string);

        int size;
        if (parseContext.arraySizeErrorCheck((yyvsp[(2) - (6)].lex).line, (yyvsp[(3) - (6)].interm.intermTypedNode), size))
            parseContext.recover();
        (yyval.interm.typeLine).type->setArraySize(size);
        (yyval.interm.typeLine).type->setSemantic(*(yyvsp[(6) - (6)].lex).string);
    ;}
    break;

  case 211:
#line 1993 "hlslang.y"
    { (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode); ;}
    break;

  case 212:
#line 1994 "hlslang.y"
    { (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode); ;}
    break;

  case 213:
#line 1995 "hlslang.y"
    { (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode); ;}
    break;

  case 214:
#line 1999 "hlslang.y"
    { (yyval.interm.intermNode) = (yyvsp[(1) - (1)].interm.intermDeclaration); ;}
    break;

  case 215:
#line 2003 "hlslang.y"
    { (yyval.interm.intermNode) = (yyvsp[(1) - (1)].interm.intermAggregate); ;}
    break;

  case 216:
#line 2004 "hlslang.y"
    { (yyval.interm.intermNode) = (yyvsp[(1) - (1)].interm.intermNode); ;}
    break;

  case 217:
#line 2010 "hlslang.y"
    { (yyval.interm.intermNode) = (yyvsp[(1) - (1)].interm.intermNode); ;}
    break;

  case 218:
#line 2011 "hlslang.y"
    { (yyval.interm.intermNode) = (yyvsp[(1) - (1)].interm.intermNode); ;}
    break;

  case 219:
#line 2012 "hlslang.y"
    { (yyval.interm.intermNode) = (yyvsp[(1) - (1)].interm.intermNode); ;}
    break;

  case 220:
#line 2013 "hlslang.y"
    { (yyval.interm.intermNode) = (yyvsp[(1) - (1)].interm.intermNode); ;}
    break;

  case 221:
#line 2014 "hlslang.y"
    { (yyval.interm.intermNode) = (yyvsp[(1) - (1)].interm.intermNode); ;}
    break;

  case 222:
#line 2018 "hlslang.y"
    { (yyval.interm.intermAggregate) = 0; ;}
    break;

  case 223:
#line 2019 "hlslang.y"
    { parseContext.symbolTable.push(); ;}
    break;

  case 224:
#line 2019 "hlslang.y"
    { parseContext.symbolTable.pop(); ;}
    break;

  case 225:
#line 2019 "hlslang.y"
    {
        if ((yyvsp[(3) - (5)].interm.intermAggregate) != 0)
            (yyvsp[(3) - (5)].interm.intermAggregate)->setOperator(EOpSequence);
        (yyval.interm.intermAggregate) = (yyvsp[(3) - (5)].interm.intermAggregate);
    ;}
    break;

  case 226:
#line 2027 "hlslang.y"
    { (yyval.interm.intermNode) = (yyvsp[(1) - (1)].interm.intermNode); ;}
    break;

  case 227:
#line 2028 "hlslang.y"
    { (yyval.interm.intermNode) = (yyvsp[(1) - (1)].interm.intermNode); ;}
    break;

  case 228:
#line 2033 "hlslang.y"
    {
        (yyval.interm.intermNode) = 0;
    ;}
    break;

  case 229:
#line 2036 "hlslang.y"
    {
        if ((yyvsp[(2) - (3)].interm.intermAggregate))
            (yyvsp[(2) - (3)].interm.intermAggregate)->setOperator(EOpSequence);
        (yyval.interm.intermNode) = (yyvsp[(2) - (3)].interm.intermAggregate);
    ;}
    break;

  case 230:
#line 2044 "hlslang.y"
    {
        (yyval.interm.intermAggregate) = ir_make_aggregate((yyvsp[(1) - (1)].interm.intermNode), gNullSourceLoc); 
    ;}
    break;

  case 231:
#line 2047 "hlslang.y"
    { 
        (yyval.interm.intermAggregate) = ir_grow_aggregate((yyvsp[(1) - (2)].interm.intermAggregate), (yyvsp[(2) - (2)].interm.intermNode), gNullSourceLoc);
    ;}
    break;

  case 232:
#line 2053 "hlslang.y"
    { (yyval.interm.intermNode) = 0; ;}
    break;

  case 233:
#line 2054 "hlslang.y"
    { (yyval.interm.intermNode) = static_cast<TIntermNode*>((yyvsp[(1) - (2)].interm.intermTypedNode)); ;}
    break;

  case 234:
#line 2058 "hlslang.y"
    {
        if (parseContext.boolErrorCheck((yyvsp[(1) - (5)].lex).line, (yyvsp[(3) - (5)].interm.intermTypedNode)))
            parseContext.recover();
        (yyval.interm.intermNode) = ir_add_selection((yyvsp[(3) - (5)].interm.intermTypedNode), (yyvsp[(5) - (5)].interm.nodePair), (yyvsp[(1) - (5)].lex).line, parseContext.infoSink);
    ;}
    break;

  case 235:
#line 2066 "hlslang.y"
    {
        (yyval.interm.nodePair).node1 = (yyvsp[(1) - (3)].interm.intermNode);
        (yyval.interm.nodePair).node2 = (yyvsp[(3) - (3)].interm.intermNode);
    ;}
    break;

  case 236:
#line 2070 "hlslang.y"
    {
        (yyval.interm.nodePair).node1 = (yyvsp[(1) - (1)].interm.intermNode);
        (yyval.interm.nodePair).node2 = 0;
    ;}
    break;

  case 237:
#line 2080 "hlslang.y"
    {
        (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode);
        if (parseContext.boolErrorCheck((yyvsp[(1) - (1)].interm.intermTypedNode)->getLine(), (yyvsp[(1) - (1)].interm.intermTypedNode)))
            parseContext.recover();
    ;}
    break;

  case 238:
#line 2085 "hlslang.y"
    {
        TIntermSymbol* symbol;
        if (parseContext.structQualifierErrorCheck((yyvsp[(2) - (4)].lex).line, (yyvsp[(1) - (4)].interm.type)))
            parseContext.recover();
        if (parseContext.boolErrorCheck((yyvsp[(2) - (4)].lex).line, (yyvsp[(1) - (4)].interm.type)))
            parseContext.recover();

        if (!parseContext.executeInitializer((yyvsp[(2) - (4)].lex).line, *(yyvsp[(2) - (4)].lex).string, (yyvsp[(1) - (4)].interm.type), (yyvsp[(4) - (4)].interm.intermTypedNode), symbol)) {
			(yyval.interm.intermTypedNode) = ir_add_declaration(symbol, (yyvsp[(4) - (4)].interm.intermTypedNode), (yyvsp[(2) - (4)].lex).line, parseContext);
        } else {
            parseContext.recover();
            (yyval.interm.intermTypedNode) = 0;
        }
    ;}
    break;

  case 239:
#line 2102 "hlslang.y"
    { parseContext.symbolTable.push(); ++parseContext.loopNestingLevel; ;}
    break;

  case 240:
#line 2102 "hlslang.y"
    {
        parseContext.symbolTable.pop();
        (yyval.interm.intermNode) = ir_add_loop(ELoopWhile, (yyvsp[(4) - (6)].interm.intermTypedNode), 0, (yyvsp[(6) - (6)].interm.intermNode), (yyvsp[(1) - (6)].lex).line);
        --parseContext.loopNestingLevel;
    ;}
    break;

  case 241:
#line 2107 "hlslang.y"
    { ++parseContext.loopNestingLevel; ;}
    break;

  case 242:
#line 2107 "hlslang.y"
    {
        if (parseContext.boolErrorCheck((yyvsp[(8) - (8)].lex).line, (yyvsp[(6) - (8)].interm.intermTypedNode)))
            parseContext.recover();
                    
        (yyval.interm.intermNode) = ir_add_loop(ELoopDoWhile, (yyvsp[(6) - (8)].interm.intermTypedNode), 0, (yyvsp[(3) - (8)].interm.intermNode), (yyvsp[(4) - (8)].lex).line);
        --parseContext.loopNestingLevel;
    ;}
    break;

  case 243:
#line 2114 "hlslang.y"
    { parseContext.symbolTable.push(); ++parseContext.loopNestingLevel; ;}
    break;

  case 244:
#line 2114 "hlslang.y"
    {
        parseContext.symbolTable.pop();
        (yyval.interm.intermNode) = ir_make_aggregate((yyvsp[(4) - (7)].interm.intermNode), (yyvsp[(2) - (7)].lex).line);
        (yyval.interm.intermNode) = ir_grow_aggregate(
                (yyval.interm.intermNode),
                ir_add_loop(ELoopFor, reinterpret_cast<TIntermTyped*>((yyvsp[(5) - (7)].interm.nodePair).node1), reinterpret_cast<TIntermTyped*>((yyvsp[(5) - (7)].interm.nodePair).node2), (yyvsp[(7) - (7)].interm.intermNode), (yyvsp[(1) - (7)].lex).line),
                (yyvsp[(1) - (7)].lex).line);
        (yyval.interm.intermNode)->getAsAggregate()->setOperator(EOpSequence);
        --parseContext.loopNestingLevel;
    ;}
    break;

  case 245:
#line 2127 "hlslang.y"
    {
        (yyval.interm.intermNode) = (yyvsp[(1) - (1)].interm.intermNode);
    ;}
    break;

  case 246:
#line 2130 "hlslang.y"
    {
        (yyval.interm.intermNode) = (yyvsp[(1) - (1)].interm.intermNode);
    ;}
    break;

  case 247:
#line 2136 "hlslang.y"
    {
        (yyval.interm.intermTypedNode) = (yyvsp[(1) - (1)].interm.intermTypedNode);
    ;}
    break;

  case 248:
#line 2139 "hlslang.y"
    {
        (yyval.interm.intermTypedNode) = 0;
    ;}
    break;

  case 249:
#line 2145 "hlslang.y"
    {
        (yyval.interm.nodePair).node1 = (yyvsp[(1) - (2)].interm.intermTypedNode);
        (yyval.interm.nodePair).node2 = 0;
    ;}
    break;

  case 250:
#line 2149 "hlslang.y"
    {
        (yyval.interm.nodePair).node1 = (yyvsp[(1) - (3)].interm.intermTypedNode);
        (yyval.interm.nodePair).node2 = (yyvsp[(3) - (3)].interm.intermTypedNode);
    ;}
    break;

  case 251:
#line 2156 "hlslang.y"
    {
        if (parseContext.loopNestingLevel <= 0) {
            parseContext.error((yyvsp[(1) - (2)].lex).line, "continue statement only allowed in loops", "", "");
            parseContext.recover();
        }        
        (yyval.interm.intermNode) = ir_add_branch(EOpContinue, (yyvsp[(1) - (2)].lex).line);
    ;}
    break;

  case 252:
#line 2163 "hlslang.y"
    {
        if (parseContext.loopNestingLevel <= 0) {
            parseContext.error((yyvsp[(1) - (2)].lex).line, "break statement only allowed in loops", "", "");
            parseContext.recover();
        }        
        (yyval.interm.intermNode) = ir_add_branch(EOpBreak, (yyvsp[(1) - (2)].lex).line);
    ;}
    break;

  case 253:
#line 2170 "hlslang.y"
    {
        (yyval.interm.intermNode) = ir_add_branch(EOpReturn, (yyvsp[(1) - (2)].lex).line);
        if (parseContext.currentFunctionType->getBasicType() != EbtVoid) {
            parseContext.error((yyvsp[(1) - (2)].lex).line, "non-void function must return a value", "return", "");
            parseContext.recover();
        }
    ;}
    break;

  case 254:
#line 2177 "hlslang.y"
    {
        TIntermTyped *temp = (yyvsp[(2) - (3)].interm.intermTypedNode);
        if (parseContext.currentFunctionType->getBasicType() == EbtVoid) {
            parseContext.error((yyvsp[(1) - (3)].lex).line, "void function cannot return a value", "return", "");
            parseContext.recover();
        } else if (*(parseContext.currentFunctionType) != (yyvsp[(2) - (3)].interm.intermTypedNode)->getType()) {
            TOperator op = parseContext.getConstructorOp(*(parseContext.currentFunctionType));
            if (op != EOpNull)
                temp = parseContext.constructBuiltIn((parseContext.currentFunctionType), op, (yyvsp[(2) - (3)].interm.intermTypedNode), (yyvsp[(1) - (3)].lex).line, false);
            else
                temp = 0;
            if (temp == 0) {
                parseContext.error((yyvsp[(1) - (3)].lex).line, "function return is not matching type:", "return", "");
                parseContext.recover();
                temp = (yyvsp[(2) - (3)].interm.intermTypedNode);
            }
        }
        (yyval.interm.intermNode) = ir_add_branch(EOpReturn, temp, (yyvsp[(1) - (3)].lex).line);
        parseContext.functionReturnsValue = true;
    ;}
    break;

  case 255:
#line 2197 "hlslang.y"
    {
		// Jim: using discard when compiling vertex shaders should not be considered a syntactic error, instead,
		// we should issue a semantic error only if the code path is actually executed. (Not yet implemented)
        //FRAG_ONLY("discard", $1.line);
        (yyval.interm.intermNode) = ir_add_branch(EOpKill, (yyvsp[(1) - (2)].lex).line);
    ;}
    break;

  case 256:
#line 2208 "hlslang.y"
    {
        (yyval.interm.intermNode) = (yyvsp[(1) - (1)].interm.intermNode);
        parseContext.treeRoot = (yyval.interm.intermNode);
    ;}
    break;

  case 257:
#line 2212 "hlslang.y"
    {
        (yyval.interm.intermNode) = ir_grow_aggregate((yyvsp[(1) - (2)].interm.intermNode), (yyvsp[(2) - (2)].interm.intermNode), gNullSourceLoc);
        parseContext.treeRoot = (yyval.interm.intermNode);
    ;}
    break;

  case 258:
#line 2219 "hlslang.y"
    {
        (yyval.interm.intermNode) = (yyvsp[(1) - (1)].interm.intermNode);
    ;}
    break;

  case 259:
#line 2222 "hlslang.y"
    {
        (yyval.interm.intermNode) = (yyvsp[(1) - (1)].interm.intermDeclaration);
    ;}
    break;

  case 260:
#line 2225 "hlslang.y"
    { (yyval.interm.intermNode) = 0; ;}
    break;

  case 261:
#line 2229 "hlslang.y"
    {
        TFunction& function = *((yyvsp[(1) - (1)].interm).function);
        TFunction* prevDec = static_cast<TFunction*>(parseContext.symbolTable.find(function.getMangledName()));
        //
        // Note:  'prevDec' could be 'function' if this is the first time we've seen function
        // as it would have just been put in the symbol table.  Otherwise, we're looking up
        // an earlier occurance.
        //
        if (prevDec->isDefined()) {
            //
            // Then this function already has a body.
            //
            parseContext.error((yyvsp[(1) - (1)].interm).line, "function already has a body", function.getName().c_str(), "");
            parseContext.recover();
        }
        prevDec->setDefined();

        //
        // New symbol table scope for body of function plus its arguments
        //
        parseContext.symbolTable.push();

        //
        // Remember the return type for later checking for RETURN statements.
        //
        parseContext.currentFunctionType = &(prevDec->getReturnType());
        parseContext.functionReturnsValue = false;

        //
        // Insert parameters into the symbol table.
        // If the parameter has no name, it's not an error, just don't insert it
        // (could be used for unused args).
        //
        // Also, accumulate the list of parameters into the HIL, so lower level code
        // knows where to find parameters.
        //
        TIntermAggregate* paramNodes = new TIntermAggregate;
        for (int i = 0; i < function.getParamCount(); i++) {
            TParameter& param = function[i];
            if (param.name != 0) {
                TVariable *variable = new TVariable(param.name, param.info, *param.type);
                //
                // Insert the parameters with name in the symbol table.
                //
                if (! parseContext.symbolTable.insert(*variable)) {
                    parseContext.error((yyvsp[(1) - (1)].interm).line, "redefinition", variable->getName().c_str(), "");
                    parseContext.recover();
                    delete variable;
                }
                //
                // Transfer ownership of name pointer to symbol table.
                //
                param.name = 0;

                //
                // Add the parameter to the HIL
                //                
                paramNodes = ir_grow_aggregate(
                                               paramNodes, 
                                               ir_add_symbol(variable, (yyvsp[(1) - (1)].interm).line),
                                               (yyvsp[(1) - (1)].interm).line);
            } else {
                paramNodes = ir_grow_aggregate(paramNodes, ir_add_symbol_internal(0, "", param.info, *param.type, (yyvsp[(1) - (1)].interm).line), (yyvsp[(1) - (1)].interm).line);
            }
        }
        ir_set_aggregate_op(paramNodes, EOpParameters, (yyvsp[(1) - (1)].interm).line);
        (yyvsp[(1) - (1)].interm).intermAggregate = paramNodes;
        parseContext.loopNestingLevel = 0;
    ;}
    break;

  case 262:
#line 2298 "hlslang.y"
    {
        //?? Check that all paths return a value if return type != void ?
        //   May be best done as post process phase on intermediate code
        if (parseContext.currentFunctionType->getBasicType() != EbtVoid && ! parseContext.functionReturnsValue) {
            parseContext.error((yyvsp[(1) - (3)].interm).line, "function does not return a value:", "", (yyvsp[(1) - (3)].interm).function->getName().c_str());
            parseContext.recover();
        }
        parseContext.symbolTable.pop();
        (yyval.interm.intermNode) = ir_grow_aggregate((yyvsp[(1) - (3)].interm).intermAggregate, (yyvsp[(3) - (3)].interm.intermNode), gNullSourceLoc);
        ir_set_aggregate_op((yyval.interm.intermNode), EOpFunction, (yyvsp[(1) - (3)].interm).line);
        (yyval.interm.intermNode)->getAsAggregate()->setName((yyvsp[(1) - (3)].interm).function->getMangledName().c_str());
        (yyval.interm.intermNode)->getAsAggregate()->setPlainName((yyvsp[(1) - (3)].interm).function->getName().c_str());
        (yyval.interm.intermNode)->getAsAggregate()->setType((yyvsp[(1) - (3)].interm).function->getReturnType());
        
	if ( (yyvsp[(1) - (3)].interm).function->getInfo())
	    (yyval.interm.intermNode)->getAsAggregate()->setSemantic((yyvsp[(1) - (3)].interm).function->getInfo()->getSemantic());
    ;}
    break;

  case 263:
#line 2318 "hlslang.y"
    {
		(yyval.interm.intermTypedNode) = (yyvsp[(2) - (3)].interm.intermAggregate);
    ;}
    break;

  case 264:
#line 2321 "hlslang.y"
    {
		(yyval.interm.intermTypedNode) = (yyvsp[(2) - (4)].interm.intermAggregate);
    ;}
    break;

  case 265:
#line 2328 "hlslang.y"
    {
        //create a new aggNode
       (yyval.interm.intermAggregate) = ir_make_aggregate( (yyvsp[(1) - (1)].interm.intermTypedNode), (yyvsp[(1) - (1)].interm.intermTypedNode)->getLine());       
    ;}
    break;

  case 266:
#line 2332 "hlslang.y"
    {
       //take the inherited aggNode and return it
       (yyval.interm.intermAggregate) = (yyvsp[(1) - (1)].interm.intermTypedNode)->getAsAggregate();
    ;}
    break;

  case 267:
#line 2336 "hlslang.y"
    {
        // append to the aggNode
       (yyval.interm.intermAggregate) = ir_grow_aggregate( (yyvsp[(1) - (3)].interm.intermAggregate), (yyvsp[(3) - (3)].interm.intermTypedNode), (yyvsp[(3) - (3)].interm.intermTypedNode)->getLine());       
    ;}
    break;

  case 268:
#line 2340 "hlslang.y"
    {
       // append all children or $3 to $1
       (yyval.interm.intermAggregate) = parseContext.mergeAggregates( (yyvsp[(1) - (3)].interm.intermAggregate), (yyvsp[(3) - (3)].interm.intermTypedNode)->getAsAggregate());
    ;}
    break;

  case 269:
#line 2347 "hlslang.y"
    {
        //empty annotation
      (yyval.interm.ann) = 0;
    ;}
    break;

  case 270:
#line 2351 "hlslang.y"
    {
      (yyval.interm.ann) = (yyvsp[(2) - (3)].interm.ann);
    ;}
    break;

  case 271:
#line 2357 "hlslang.y"
    {
        (yyval.interm.ann) = new TAnnotation;
		(yyval.interm.ann)->addKey( *(yyvsp[(1) - (1)].lex).string);
    ;}
    break;

  case 272:
#line 2361 "hlslang.y"
    {
        (yyvsp[(1) - (2)].interm.ann)->addKey( *(yyvsp[(2) - (2)].lex).string);
		(yyval.interm.ann) = (yyvsp[(1) - (2)].interm.ann);
    ;}
    break;

  case 273:
#line 2368 "hlslang.y"
    {
        (yyval.lex).string = (yyvsp[(2) - (5)].lex).string;
    ;}
    break;

  case 274:
#line 2374 "hlslang.y"
    {;}
    break;

  case 275:
#line 2375 "hlslang.y"
    {;}
    break;

  case 276:
#line 2376 "hlslang.y"
    {;}
    break;

  case 277:
#line 2377 "hlslang.y"
    {;}
    break;

  case 278:
#line 2378 "hlslang.y"
    {;}
    break;

  case 279:
#line 2379 "hlslang.y"
    {;}
    break;

  case 280:
#line 2380 "hlslang.y"
    {;}
    break;

  case 281:
#line 2381 "hlslang.y"
    {;}
    break;

  case 282:
#line 2382 "hlslang.y"
    {;}
    break;

  case 283:
#line 2383 "hlslang.y"
    {;}
    break;

  case 284:
#line 2384 "hlslang.y"
    {;}
    break;

  case 285:
#line 2385 "hlslang.y"
    {;}
    break;

  case 286:
#line 2386 "hlslang.y"
    {;}
    break;

  case 287:
#line 2387 "hlslang.y"
    {;}
    break;

  case 288:
#line 2388 "hlslang.y"
    {;}
    break;

  case 289:
#line 2389 "hlslang.y"
    {;}
    break;

  case 290:
#line 2390 "hlslang.y"
    {;}
    break;

  case 291:
#line 2391 "hlslang.y"
    {;}
    break;

  case 292:
#line 2392 "hlslang.y"
    {;}
    break;

  case 293:
#line 2393 "hlslang.y"
    {;}
    break;

  case 294:
#line 2394 "hlslang.y"
    {;}
    break;

  case 295:
#line 2398 "hlslang.y"
    {;}
    break;

  case 296:
#line 2399 "hlslang.y"
    {;}
    break;

  case 297:
#line 2400 "hlslang.y"
    {;}
    break;

  case 298:
#line 2401 "hlslang.y"
    {;}
    break;

  case 299:
#line 2405 "hlslang.y"
    {
		(yyval.lex).f = (float)(yyvsp[(1) - (1)].lex).i;
	;}
    break;

  case 300:
#line 2408 "hlslang.y"
    {
		(yyval.lex).f = ((yyvsp[(1) - (1)].lex).b) ? 1.0f : 0.0f;
	;}
    break;

  case 301:
#line 2411 "hlslang.y"
    {
		(yyval.lex).f = (yyvsp[(1) - (1)].lex).f;
	;}
    break;

  case 302:
#line 2417 "hlslang.y"
    {;}
    break;

  case 303:
#line 2421 "hlslang.y"
    {;}
    break;

  case 304:
#line 2422 "hlslang.y"
    {;}
    break;

  case 305:
#line 2426 "hlslang.y"
    {;}
    break;

  case 306:
#line 2430 "hlslang.y"
    {
        (yyval.lex) = (yyvsp[(4) - (5)].lex);
    ;}
    break;

  case 307:
#line 2436 "hlslang.y"
    { (yyval.lex).string = (yyvsp[(2) - (2)].lex).string;;}
    break;

  case 308:
#line 2440 "hlslang.y"
    { (yyval.interm.typeInfo) = 0;;}
    break;

  case 309:
#line 2441 "hlslang.y"
    { (yyval.interm.typeInfo) = new TTypeInfo( *(yyvsp[(1) - (1)].lex).string, 0); ;}
    break;

  case 310:
#line 2442 "hlslang.y"
    { (yyval.interm.typeInfo) = new TTypeInfo( "", *(yyvsp[(1) - (1)].lex).string, 0); ;}
    break;

  case 311:
#line 2443 "hlslang.y"
    { (yyval.interm.typeInfo) = new TTypeInfo( "", (yyvsp[(1) - (1)].interm.ann)); ;}
    break;

  case 312:
#line 2444 "hlslang.y"
    { (yyval.interm.typeInfo) = new TTypeInfo( *(yyvsp[(1) - (2)].lex).string, (yyvsp[(2) - (2)].interm.ann)); ;}
    break;

  case 313:
#line 2445 "hlslang.y"
    { (yyval.interm.typeInfo) = new TTypeInfo( *(yyvsp[(1) - (2)].lex).string, *(yyvsp[(2) - (2)].lex).string, 0); ;}
    break;

  case 314:
#line 2446 "hlslang.y"
    { (yyval.interm.typeInfo) = new TTypeInfo( "", *(yyvsp[(1) - (2)].lex).string, (yyvsp[(2) - (2)].interm.ann)); ;}
    break;

  case 315:
#line 2447 "hlslang.y"
    { (yyval.interm.typeInfo) = new TTypeInfo( *(yyvsp[(1) - (3)].lex).string, *(yyvsp[(2) - (3)].lex).string, (yyvsp[(3) - (3)].interm.ann)); ;}
    break;

  case 316:
#line 2451 "hlslang.y"
    {
		TIntermConstant* constant = ir_add_constant(TType(EbtFloat, EbpUndefined, EvqConst, 1), (yyvsp[(1) - (4)].lex).line);
		constant->setValue(0.f);
		(yyval.interm.intermTypedNode) = constant;
	;}
    break;

  case 317:
#line 2456 "hlslang.y"
    {
	;}
    break;

  case 318:
#line 2461 "hlslang.y"
    { ;}
    break;

  case 319:
#line 2462 "hlslang.y"
    { ;}
    break;

  case 320:
#line 2466 "hlslang.y"
    {;}
    break;

  case 321:
#line 2467 "hlslang.y"
    {;}
    break;

  case 322:
#line 2468 "hlslang.y"
    {;}
    break;

  case 323:
#line 2469 "hlslang.y"
    {;}
    break;

  case 324:
#line 2470 "hlslang.y"
    {;}
    break;

  case 325:
#line 2471 "hlslang.y"
    {;}
    break;


/* Line 1267 of yacc.c.  */
#line 5969 "hlslang_tab.cpp"
      default: break;
    }
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;


  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (parseContext, YY_("syntax error"));
#else
      {
	YYSIZE_T yysize = yysyntax_error (0, yystate, yychar);
	if (yymsg_alloc < yysize && yymsg_alloc < YYSTACK_ALLOC_MAXIMUM)
	  {
	    YYSIZE_T yyalloc = 2 * yysize;
	    if (! (yysize <= yyalloc && yyalloc <= YYSTACK_ALLOC_MAXIMUM))
	      yyalloc = YYSTACK_ALLOC_MAXIMUM;
	    if (yymsg != yymsgbuf)
	      YYSTACK_FREE (yymsg);
	    yymsg = (char *) YYSTACK_ALLOC (yyalloc);
	    if (yymsg)
	      yymsg_alloc = yyalloc;
	    else
	      {
		yymsg = yymsgbuf;
		yymsg_alloc = sizeof yymsgbuf;
	      }
	  }

	if (0 < yysize && yysize <= yymsg_alloc)
	  {
	    (void) yysyntax_error (yymsg, yystate, yychar);
	    yyerror (parseContext, yymsg);
	  }
	else
	  {
	    yyerror (parseContext, YY_("syntax error"));
	    if (yysize != 0)
	      goto yyexhaustedlab;
	  }
      }
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse look-ahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
	{
	  /* Return failure if at end of input.  */
	  if (yychar == YYEOF)
	    YYABORT;
	}
      else
	{
	  yydestruct ("Error: discarding",
		      yytoken, &yylval, parseContext);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse look-ahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule which action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;


      yydestruct ("Error: popping",
		  yystos[yystate], yyvsp, parseContext);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  *++yyvsp = yylval;


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#ifndef yyoverflow
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (parseContext, YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEOF && yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval, parseContext);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp, parseContext);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  /* Make sure YYID is used.  */
  return YYID (yyresult);
}


#line 2474 "hlslang.y"


