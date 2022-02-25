/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

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
/* Line 1529 of yacc.c.  */
#line 359 "hlslang_tab.hpp"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



