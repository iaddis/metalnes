// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


//
// Create strings that declare built-in definitions, add built-ins that
// cannot be expressed in the files, and establish mappings between 
// built-in functions and operators.
//

#include "../Include/intermediate.h"
#include "Initialize.h"

#include "SymbolTable.h"
#include <sstream>

namespace hlslang {


static void appendMatrixType(std::stringstream& ss, unsigned rows, unsigned cols)
{
    ss << "float";
    if (rows > 1 && cols > 1)
        ss << rows << "x" << cols;
    else if (cols > 1)
        ss << cols;
    else if (rows > 1)
        ss << rows;
}

void TBuiltIns::initialize()
{
   // initialize the symbol table null semantic string
   TParameter::NullSemantic = NewPoolTString ( "" );

   //
   // Initialize all the built-in strings for parsing.
   //
   TString BuiltInFunctions;

   {
      //============================================================================
      //
      // Prototypes for built-in functions seen by both vertex and fragment shaders.
      //
      //============================================================================

      TString& s = BuiltInFunctions;

      //
      // Angle and Trigonometric Functions.
      //
      s.append(TString("float radians(float degrees);"));
      s.append(TString("float2  radians(float2  degrees);"));
      s.append(TString("float3  radians(float3  degrees);"));
      s.append(TString("float4  radians(float4  degrees);"));
      s.append(TString("float2x2  radians(float2x2  degrees);"));
      s.append(TString("float3x3  radians(float3x3  degrees);"));
      s.append(TString("float4x4  radians(float4x4  degrees);"));

      s.append(TString("float degrees(float radians);"));
      s.append(TString("float2  degrees(float2  radians);"));
      s.append(TString("float3  degrees(float3  radians);"));
      s.append(TString("float4  degrees(float4  radians);"));
      s.append(TString("float2x2  degrees(float2x2  radians);"));
      s.append(TString("float3x3  degrees(float3x3  radians);"));
      s.append(TString("float4x4  degrees(float4x4  radians);"));

      s.append(TString("float sin(float angle);"));
      s.append(TString("float2  sin(float2  angle);"));
      s.append(TString("float3  sin(float3  angle);"));
      s.append(TString("float4  sin(float4  angle);"));
      s.append(TString("float2x2  sin(float2x2  angle);"));
      s.append(TString("float3x3  sin(float3x3  angle);"));
      s.append(TString("float4x4  sin(float4x4  angle);"));

      s.append(TString("float cos(float angle);"));
      s.append(TString("float2  cos(float2  angle);"));
      s.append(TString("float3  cos(float3  angle);"));
      s.append(TString("float4  cos(float4  angle);"));
      s.append(TString("float2x2  cos(float2x2  angle);"));
      s.append(TString("float3x3  cos(float3x3  angle);"));
      s.append(TString("float4x4  cos(float4x4  angle);"));

      s.append(TString("float tan(float angle);"));
      s.append(TString("float2  tan(float2  angle);"));
      s.append(TString("float3  tan(float3  angle);"));
      s.append(TString("float4  tan(float4  angle);"));
      s.append(TString("float2x2  tan(float2x2  angle);"));
      s.append(TString("float3x3  tan(float3x3  angle);"));
      s.append(TString("float4x4  tan(float4x4  angle);"));

      s.append(TString("float asin(float x);"));
      s.append(TString("float2  asin(float2  x);"));
      s.append(TString("float3  asin(float3  x);"));
      s.append(TString("float4  asin(float4  x);"));
      s.append(TString("float2x2  asin(float2x2  x);"));
      s.append(TString("float3x3  asin(float3x3  x);"));
      s.append(TString("float4x4  asin(float4x4  x);"));

      s.append(TString("float acos(float x);"));
      s.append(TString("float2  acos(float2  x);"));
      s.append(TString("float3  acos(float3  x);"));
      s.append(TString("float4  acos(float4  x);"));
      s.append(TString("float2x2  acos(float2x2  x);"));
      s.append(TString("float3x3  acos(float3x3  x);"));
      s.append(TString("float4x4  acos(float4x4  x);"));

      s.append(TString("float atan2(float y, float x);")); 
      s.append(TString("float2  atan2(float2  y, float2  x);"));
      s.append(TString("float3  atan2(float3  y, float3  x);"));
      s.append(TString("float4  atan2(float4  y, float4  x);"));
      s.append(TString("float2x2  atan2(float2x2  y, float2x2  x);"));
      s.append(TString("float3x3  atan2(float3x3  y, float3x3  x);"));
      s.append(TString("float4x4  atan2(float4x4  y, float4x4  x);"));

      s.append(TString("float atan(float y_over_x);"));
      s.append(TString("float2  atan(float2  y_over_x);"));
      s.append(TString("float3  atan(float3  y_over_x);"));
      s.append(TString("float4  atan(float4  y_over_x);"));
      s.append(TString("float2x2  atan(float2x2  y_over_x);"));
      s.append(TString("float3x3  atan(float3x3  y_over_x);"));
      s.append(TString("float4x4  atan(float4x4  y_over_x);"));

      //
      // Exponential Functions.
      //
      s.append(TString("float pow(float x, float y);"));
      s.append(TString("float2  pow(float2  x, float2  y);"));
      s.append(TString("float3  pow(float3  x, float3  y);"));
      s.append(TString("float4  pow(float4  x, float4  y);"));
      s.append(TString("float2x2  pow(float2x2  x, float2x2  y);"));
      s.append(TString("float3x3  pow(float3x3  x, float3x3  y);"));
      s.append(TString("float4x4  pow(float4x4  x, float4x4  y);"));

      s.append(TString("float exp(float x);"));
      s.append(TString("float2  exp(float2  x);"));
      s.append(TString("float3  exp(float3  x);"));
      s.append(TString("float4  exp(float4  x);"));
      s.append(TString("float2x2  exp(float2x2  x);"));
      s.append(TString("float3x3  exp(float3x3  x);"));
      s.append(TString("float4x4  exp(float4x4  x);"));

      s.append(TString("float log(float x);"));
      s.append(TString("float2  log(float2  x);"));
      s.append(TString("float3  log(float3  x);"));
      s.append(TString("float4  log(float4  x);"));
      s.append(TString("float2x2  log(float2x2  x);"));
      s.append(TString("float3x3  log(float3x3  x);"));
      s.append(TString("float4x4  log(float4x4  x);"));

      s.append(TString("float exp2(float x);"));
      s.append(TString("float2  exp2(float2  x);"));
      s.append(TString("float3  exp2(float3  x);"));
      s.append(TString("float4  exp2(float4  x);"));
      s.append(TString("float2x2  exp2(float2x2  x);"));
      s.append(TString("float3x3  exp2(float3x3  x);"));
      s.append(TString("float4x4  exp2(float4x4  x);"));

      s.append(TString("float log2(float x);"));
      s.append(TString("float2  log2(float2  x);"));
      s.append(TString("float3  log2(float3  x);"));
      s.append(TString("float4  log2(float4  x);"));
      s.append(TString("float2x2  log2(float2x2  x);"));
      s.append(TString("float3x3  log2(float3x3  x);"));
      s.append(TString("float4x4  log2(float4x4  x);"));

      s.append(TString("float log10(float x);"));
      s.append(TString("float2  log10(float2  x);"));
      s.append(TString("float3  log10(float3  x);"));
      s.append(TString("float4  log10(float4  x);"));
      s.append(TString("float2x2  log10(float2x2  x);"));
      s.append(TString("float3x3  log10(float3x3  x);"));
      s.append(TString("float4x4  log10(float4x4  x);"));
      
      s.append(TString("float sqrt(float x);"));
      s.append(TString("float2  sqrt(float2  x);"));
      s.append(TString("float3  sqrt(float3  x);"));
      s.append(TString("float4  sqrt(float4  x);"));
      s.append(TString("float2x2  sqrt(float2x2  x);"));
      s.append(TString("float3x3  sqrt(float3x3  x);"));
      s.append(TString("float4x4  sqrt(float4x4  x);"));

      
      //DX HLSL versions
      s.append(TString("float   rsqrt(float x);"));
      s.append(TString("float2  rsqrt(float2  x);"));
      s.append(TString("float3  rsqrt(float3  x);"));
      s.append(TString("float4  rsqrt(float4  x);"));
      s.append(TString("float2x2  rsqrt(float2x2  x);"));
      s.append(TString("float3x3  rsqrt(float3x3  x);"));
      s.append(TString("float4x4  rsqrt(float4x4  x);"));

      //
      // Common Functions.
      //
      s.append(TString("float abs(float x);"));
      s.append(TString("float2  abs(float2  x);"));
      s.append(TString("float3  abs(float3  x);"));
      s.append(TString("float4  abs(float4  x);"));
      s.append(TString("float2x2  abs(float2x2  x);"));
      s.append(TString("float3x3  abs(float3x3  x);"));
      s.append(TString("float4x4  abs(float4x4  x);"));

      s.append(TString("float sign(float x);"));
      s.append(TString("float2  sign(float2  x);"));
      s.append(TString("float3  sign(float3  x);"));
      s.append(TString("float4  sign(float4  x);"));
      s.append(TString("float2x2  sign(float2x2  x);"));
      s.append(TString("float3x3  sign(float3x3  x);"));
      s.append(TString("float4x4  sign(float4x4  x);"));

      s.append(TString("float floor(float x);"));
      s.append(TString("float2  floor(float2  x);"));
      s.append(TString("float3  floor(float3  x);"));
      s.append(TString("float4  floor(float4  x);"));
      s.append(TString("float2x2  floor(float2x2  x);"));
      s.append(TString("float3x3  floor(float3x3  x);"));
      s.append(TString("float4x4  floor(float4x4  x);"));

      s.append(TString("float ceil(float x);"));
      s.append(TString("float2  ceil(float2  x);"));
      s.append(TString("float3  ceil(float3  x);"));
      s.append(TString("float4  ceil(float4  x);"));
      s.append(TString("float2x2  ceil(float2x2  x);"));
      s.append(TString("float3x3  ceil(float3x3  x);"));
      s.append(TString("float4x4  ceil(float4x4  x);"));

      //DX HLSL versions
      s.append(TString("float   frac(float x);"));
      s.append(TString("float2  frac(float2  x);"));
      s.append(TString("float3  frac(float3  x);"));
      s.append(TString("float4  frac(float4  x);"));
      s.append(TString("float2x2  frac(float2x2  x);"));
      s.append(TString("float3x3  frac(float3x3  x);"));
      s.append(TString("float4x4  frac(float4x4  x);"));

      s.append(TString("float fmod(float x, float y);"));
      s.append(TString("float2  fmod(float2  x, float2  y);"));
      s.append(TString("float3  fmod(float3  x, float3  y);"));
      s.append(TString("float4  fmod(float4  x, float4  y);"));
      
      s.append(TString("float min(float x, float y);"));
      s.append(TString("float2  min(float2  x, float2  y);"));
      s.append(TString("float3  min(float3  x, float3  y);"));
      s.append(TString("float4  min(float4  x, float4  y);"));
      s.append(TString("float2x2  min(float2x2  x, float2x2  y);"));
      s.append(TString("float3x3  min(float3x3  x, float3x3  y);"));
      s.append(TString("float4x4  min(float4x4  x, float4x4  y);"));

      s.append(TString("float max(float x, float y);"));
      s.append(TString("float2  max(float2  x, float2  y);"));
      s.append(TString("float3  max(float3  x, float3  y);"));
      s.append(TString("float4  max(float4  x, float4  y);"));
      s.append(TString("float2x2  max(float2x2  x, float2x2  y);"));
      s.append(TString("float3x3  max(float3x3  x, float3x3  y);"));
      s.append(TString("float4x4  max(float4x4  x, float4x4  y);"));

      s.append(TString("float clamp(float x, float minVal, float maxVal);"));
      s.append(TString("float2  clamp(float2  x, float2  minVal, float2  maxVal);"));
      s.append(TString("float3  clamp(float3  x, float3  minVal, float3  maxVal);"));
      s.append(TString("float4  clamp(float4  x, float4  minVal, float4  maxVal);"));
      s.append(TString("float2x2  clamp(float2x2  x, float2x2  minVal, float2x2  maxVal);"));
      s.append(TString("float3x3  clamp(float3x3  x, float3x3  minVal, float3x3  maxVal);"));
      s.append(TString("float4x4  clamp(float4x4  x, float4x4  minVal, float4x4  maxVal);"));

      //HLSL specific shortcut
      s.append(TString("float saturate(float x);"));
      s.append(TString("float2  saturate(float2  x);"));
      s.append(TString("float3  saturate(float3  x);"));
      s.append(TString("float4  saturate(float4  x);"));
      s.append(TString("float2x2  saturate(float2x2  x);"));
      s.append(TString("float3x3  saturate(float3x3  x);"));
      s.append(TString("float4x4  saturate(float4x4  x);"));

      // HLSL modf
      s.append(TString("float modf(float x, out int ip);"));
      s.append(TString("float modf(float x, out float ip);"));
	  s.append(TString("float2 modf(float2 x, out int2 ip);"));
	  s.append(TString("float2 modf(float2 x, out float2 ip);"));
	  s.append(TString("float3 modf(float3 x, out int3 ip);"));
	  s.append(TString("float3 modf(float3 x, out float3 ip);"));
	  s.append(TString("float4 modf(float4 x, out int4 ip);"));
	  s.append(TString("float4 modf(float4 x, out float4 ip);"));
	   
	   // HLSL round
	   s.append(TString("float round(float x);"));
	   s.append(TString("float2 round(float2 x);"));
	   s.append(TString("float3 round(float3 x);"));
	   s.append(TString("float4 round(float4 x);"));	   
	   
	   // HLSL trunc
	   s.append(TString("float trunc(float x);"));
	   s.append(TString("float2 trunc(float2 x);"));
	   s.append(TString("float3 trunc(float3 x);"));
	   s.append(TString("float4 trunc(float4 x);"));	   
	   
      // HLSL ldexp
      s.append(TString("float ldexp(float x, float expon);"));
      s.append(TString("float2 ldexp(float2 x, float2 expon);"));
      s.append(TString("float3 ldexp(float3 x, float3 expon);"));
      s.append(TString("float4 ldexp(float4 x, float4 expon);"));
      s.append(TString("float2x2 ldexp(float2x2 x, float2x2 expon);"));
      s.append(TString("float3x3 ldexp(float3x3 x, float3x3 expon);"));
      s.append(TString("float4x4 ldexp(float4x4 x, float4x4 expon);"));

      // HLSL sincos
      s.append(TString("void sincos(float x, out float s, out float c);"));
      s.append(TString("void sincos(float2 x, out float2 s, out float2 c);"));
      s.append(TString("void sincos(float3 x, out float3 s, out float3 c);"));
      s.append(TString("void sincos(float4 x, out float4 s, out float4 c);"));
      s.append(TString("void sincos(float2x2 x, out float2x2 s, out float2x2 c);"));
      s.append(TString("void sincos(float3x3 x, out float3x3 s, out float3x3 c);"));
      s.append(TString("void sincos(float4x4 x, out float4x4 s, out float4x4 c);"));        

      //DX HLSL versions
      s.append(TString("float   lerp(float x, float y, float a);"));
      s.append(TString("float2  lerp(float2  x, float2  y, float2  a);"));
      s.append(TString("float3  lerp(float3  x, float3  y, float3  a);"));
      s.append(TString("float4  lerp(float4  x, float4  y, float4  a);"));
      s.append(TString("float2x2  lerp(float2x2  x, float2x2  y, float2x2  a);"));
      s.append(TString("float3x3  lerp(float3x3  x, float3x3  y, float3x3  a);"));
      s.append(TString("float4x4  lerp(float4x4  x, float4x4  y, float4x4  a);"));

      s.append(TString("float step(float edge, float x);"));
      s.append(TString("float2  step(float2 edge, float2  x);"));
      s.append(TString("float3  step(float3 edge, float3  x);"));
      s.append(TString("float4  step(float4 edge, float4  x);"));
      s.append(TString("float2x2  step(float2x2 edge, float2x2  x);"));
      s.append(TString("float3x3  step(float3x3 edge, float3x3  x);"));
      s.append(TString("float4x4  step(float4x4 edge, float4x4  x);"));

      s.append(TString("float smoothstep(float edge0, float edge1, float x);"));
      s.append(TString("float2  smoothstep(float2  edge0, float2  edge1, float2  x);"));
      s.append(TString("float3  smoothstep(float3  edge0, float3  edge1, float3  x);"));
      s.append(TString("float4  smoothstep(float4  edge0, float4  edge1, float4  x);"));
      s.append(TString("float2x2  smoothstep(float2x2  edge0, float2x2  edge1, float2x2  x);"));
      s.append(TString("float3x3  smoothstep(float3x3  edge0, float3x3  edge1, float3x3  x);"));
      s.append(TString("float4x4  smoothstep(float4x4  edge0, float4x4  edge1, float4x4  x);"));
      

      s.append(TString("float4   lit(float n_dot_l, float n_dot_h, float m);"));

      //
      // Geometric Functions.
      //
      s.append(TString("float length(float x);"));
      s.append(TString("float length(float2  x);"));
      s.append(TString("float length(float3  x);"));
      s.append(TString("float length(float4  x);"));

      s.append(TString("float distance(float p0, float p1);"));
      s.append(TString("float distance(float2  p0, float2  p1);"));
      s.append(TString("float distance(float3  p0, float3  p1);"));
      s.append(TString("float distance(float4  p0, float4  p1);"));

      s.append(TString("float dot(float x, float y);"));
      s.append(TString("float dot(float2  x, float2  y);"));
      s.append(TString("float dot(float3  x, float3  y);"));
      s.append(TString("float dot(float4  x, float4  y);"));

      s.append(TString("float3 cross(float3 x, float3 y);"));
      s.append(TString("float normalize(float x);"));
      s.append(TString("float2  normalize(float2  x);"));
      s.append(TString("float3  normalize(float3  x);"));
      s.append(TString("float4  normalize(float4  x);"));

      s.append(TString("float faceforward(float N, float I, float Nref);"));
      s.append(TString("float2  faceforward(float2  N, float2  I, float2  Nref);"));
      s.append(TString("float3  faceforward(float3  N, float3  I, float3  Nref);"));
      s.append(TString("float4  faceforward(float4  N, float4  I, float4  Nref);"));

      s.append(TString("float reflect(float I, float N);"));
      s.append(TString("float2  reflect(float2  I, float2  N);"));
      s.append(TString("float3  reflect(float3  I, float3  N);"));
      s.append(TString("float4  reflect(float4  I, float4  N);"));

      s.append(TString("float refract(float I, float N, float eta);"));
      s.append(TString("float2  refract(float2  I, float2  N, float eta);"));
      s.append(TString("float3  refract(float3  I, float3  N, float eta);"));
      s.append(TString("float4  refract(float4  I, float4  N, float eta);"));

      //
      // Matrix Functions.
      //
      //s.append(TString("mat2 matrixCompMult(mat2 x, mat2 y);"));
      //s.append(TString("mat3 matrixCompMult(mat3 x, mat3 y);"));
      //s.append(TString("mat4 matrixCompMult(mat4 x, mat4 y);"));

      //
      // HLSL Matrix Functions.
      //

      for (unsigned cols = 2; cols <= 4; ++cols)
      {
          for (unsigned rows = 1; rows <= 4; ++rows)
          {
              std::stringstream ss;
              appendMatrixType(ss, rows, cols);
              ss << " mul(float x, ";
              appendMatrixType(ss, rows, cols);
              ss << " y);";

              appendMatrixType(ss, rows, cols);
              ss << " mul(";
              appendMatrixType(ss, rows, cols);
              ss << " x, float y);";
              for (unsigned othercols = 1; othercols <= 4; ++othercols)
              {
                  // matrix<rows, othercols> mul(matrix<rows, cols>, matrix<cols, othercols>)

                  appendMatrixType(ss, rows, othercols);
                  ss << " mul(";
                  appendMatrixType(ss, rows, cols);
                  ss << " x, ";
                  appendMatrixType(ss, cols, othercols);
                  ss << " y);";
              }
              s.append(TString(ss.str().c_str()));
          }
      }

      s.append(TString("float2x2 transpose(float2x2 m);"));
      s.append(TString("float3x3 transpose(float3x3 m);"));
      s.append(TString("float4x4 transpose(float4x4 m);"));
      s.append(TString("float determinant(float2x2 m);"));
      s.append(TString("float determinant(float3x3 m);"));
      s.append(TString("float determinant(float4x4 m);"));
      s.append(TString("float2x2 mul(float2x2 x, float2x2 y);"));

      //
      // Vector relational functions.
      //


      s.append(TString("bool any(bool2 x);"));
      s.append(TString("bool any(bool3 x);"));
      s.append(TString("bool any(bool4 x);"));

      s.append(TString("bool all(bool2 x);"));
      s.append(TString("bool all(bool3 x);"));
      s.append(TString("bool all(bool4 x);"));

      //s.append(TString("bvec2 not(bvec2 x);"));
      //s.append(TString("bvec3 not(bvec3 x);"));
      //s.append(TString("bvec4 not(bvec4 x);"));

      //
      // Texture Functions.
      //

      //DX HLSL texture functions
      s.append(TString("float4 tex1D(sampler1D s, float coord);"));
      s.append(TString("float4 tex1D(sampler1DShadow s, float2 coord);"));
      s.append(TString("float4 tex1D(sampler1D s, float coord, float ddx, float ddy);"));
      s.append(TString("float4 tex1Dproj(sampler1D s, float4 coord);"));
      s.append(TString("float4 tex1Dproj(sampler1DShadow s, float4 coord);"));
      s.append(TString("float4 tex1Dbias(sampler1D s, float4 coord);"));
      s.append(TString("float4 tex1Dlod(sampler1D s, float4 coord);"));
      s.append(TString("float4 tex1Dgrad(sampler1D s, float coord, float ddx, float ddy);"));

      s.append(TString("float4 tex2D(sampler2D s, float2 coord);"));
      s.append(TString("float4 tex2D(sampler2DShadow s, float3 coord);"));
      s.append(TString("float4 tex2D(sampler2D s, float2 coord, float2 ddx, float2 ddy);"));
      s.append(TString("float4 tex2Dproj(sampler2D s, float4 coord);"));
	  s.append(TString("float4 tex2Dproj(sampler2DShadow s, float4 coord);"));
      s.append(TString("float4 tex2Dbias(sampler2D s, float4 coord);"));
      s.append(TString("float4 tex2Dlod(sampler2D s, float4 coord);"));
      s.append(TString("float4 tex2Dgrad(sampler2D s, float2 coord2, float2 ddx, float2 ddy);"));

      s.append(TString("float4 tex3D(sampler3D s, float3 coord);"));
      s.append(TString("float4 tex3D(sampler3D s, float3 coord, float3 ddx, float3 ddy);"));
      s.append(TString("float4 tex3Dproj(sampler3D s, float4 coord);"));
      s.append(TString("float4 tex3Dbias(sampler3D s, float4 coord);"));
      s.append(TString("float4 tex3Dlod(sampler3D s, float4 coord);"));
      s.append(TString("float4 tex3Dgrad(sampler3D s, float3 coord, float3 ddx, float3 ddy);"));

      s.append(TString("float4 texCUBE(samplerCUBE s, float3 coord);"));
      s.append(TString("float4 texCUBE(samplerCUBE s, float3 coord, float3 ddx, float3 ddy);"));
      s.append(TString("float4 texCUBEproj(samplerCUBE s, float4 coord);"));
      s.append(TString("float4 texCUBEbias(samplerCUBE s, float4 coord);"));
      s.append(TString("float4 texCUBElod(samplerCUBE s, float4 coord);"));
      s.append(TString("float4 texCUBEgrad(samplerCUBE s, float3 coord, float3 ddx, float3 ddy);"));
	   
      s.append(TString("float4 texRECT(samplerRECT s, float2 coord);"));
      s.append(TString("float4 texRECT(samplerRECTShadow s, float3 coord);"));
      s.append(TString("float4 texRECTproj(samplerRECT s, float4 coord);"));
      s.append(TString("float4 texRECTproj(samplerRECTShadow s, float4 coord);"));
      s.append(TString("float4 texRECTproj(samplerRECT s, float3 coord);"));
	   
		s.append(TString("float shadow2D(sampler2DShadow s, float3 coord);"));
		s.append(TString("float shadow2Dproj(sampler2DShadow s, float4 coord);"));

	   s.append(TString("float4 tex2DArray(sampler2DArray s, float3 coord);"));
	   s.append(TString("float4 tex2DArraylod(sampler2DArray s, float4 coord);"));
	   s.append(TString("float4 tex2DArraybias(sampler2DArray s, float4 coord);"));
	   
      s.append(TString("float4 tex1D(sampler s, float coord);"));
      s.append(TString("float4 tex1D(sampler s, float coord, float ddx, float ddy);"));
      s.append(TString("float4 tex1Dproj(sampler s, float4 coord);"));
      s.append(TString("float4 tex1Dbias(sampler s, float4 coord);"));
      s.append(TString("float4 tex1Dlod(sampler s, float4 coord);"));
      s.append(TString("float4 tex1Dgrad(sampler s, float coord, float ddx, float ddy);"));

      s.append(TString("float4 tex2D(sampler s, float2 coord);"));
      s.append(TString("float4 tex2D(sampler s, float2 coord, float2 ddx, float2 ddy);"));
      s.append(TString("float4 tex2Dproj(sampler s, float4 coord);"));
      s.append(TString("float4 tex2Dbias(sampler s, float4 coord);"));
      s.append(TString("float4 tex2Dlod(sampler s, float4 coord);"));
      s.append(TString("float4 tex2Dgrad(sampler s, float2 coord2, float2 ddx, float2 ddy);"));

      s.append(TString("float4 tex3D(sampler s, float3 coord);"));
      s.append(TString("float4 tex3D(sampler s, float3 coord, float3 ddx, float3 ddy);"));
      s.append(TString("float4 tex3Dproj(sampler s, float4 coord);"));
      s.append(TString("float4 tex3Dbias(sampler s, float4 coord);"));
      s.append(TString("float4 tex3Dlod(sampler s, float4 coord);"));
      s.append(TString("float4 tex3Dgrad(sampler s, float3 coord, float3 ddx, float3 ddy);"));

      s.append(TString("float4 texCUBE(sampler s, float3 coord);"));
      s.append(TString("float4 texCUBE(sampler s, float3 coord, float3 ddx, float3 ddy);"));
      s.append(TString("float4 texCUBEproj(sampler s, float4 coord);"));
      s.append(TString("float4 texCUBEbias(sampler s, float4 coord);"));
      s.append(TString("float4 texCUBElod(sampler s, float4 coord);"));
      s.append(TString("float4 texCUBEgrad(sampler s, float3 coord, float3 ddx, float3 ddy);"));

	   s.append(TString("float4 texRECT(sampler s, float2 coord);"));
	   s.append(TString("float4 texRECTproj(sampler s, float4 coord);"));
	   s.append(TString("float4 texRECTproj(sampler s, float3 coord);"));
	   

      //
      // Noise functions.
      //
      s.append(TString("float noise(float x);"));
      s.append(TString("float noise(float2  x);"));
      s.append(TString("float noise(float3  x);"));
      s.append(TString("float noise(float4  x);"));

      s.append(TString("float ddx(float p);"));
      s.append(TString("float2  ddx(float2  p);"));
      s.append(TString("float3  ddx(float3  p);"));
      s.append(TString("float4  ddx(float4  p);"));
      s.append(TString("float2x2  ddx(float2x2  p);"));
      s.append(TString("float3x3  ddx(float3x3  p);"));
      s.append(TString("float4x4  ddx(float4x4  p);"));

      s.append(TString("float ddy(float p);"));
      s.append(TString("float2  ddy(float2  p);"));
      s.append(TString("float3  ddy(float3  p);"));
      s.append(TString("float4  ddy(float4  p);"));
      s.append(TString("float2x2  ddy(float2x2  p);"));
      s.append(TString("float3x3  ddy(float3x3  p);"));
      s.append(TString("float4x4  ddy(float4x4  p);"));

      s.append(TString("float fwidth(float p);"));
      s.append(TString("float2  fwidth(float2  p);"));
      s.append(TString("float3  fwidth(float3  p);"));
      s.append(TString("float4  fwidth(float4  p);"));
      s.append(TString("float2x2  fwidth(float2x2  p);"));
      s.append(TString("float3x3  fwidth(float3x3  p);"));
      s.append(TString("float4x4  fwidth(float4x4  p);"));

      //
      // Special HLSL functions
      //
      s.append(TString("int4 D3DCOLORtoUBYTE4(float4 x);"));
		s.append(TString("void clip(float x);"));
		s.append(TString("void clip(float2 x);"));
		s.append(TString("void clip(float3 x);"));
		s.append(TString("void clip(float4 x);"));

      s.append(TString("\n"));
   }

   builtInStrings[EShLangFragment].push_back(BuiltInFunctions.c_str());

   builtInStrings[EShLangVertex].push_back(BuiltInFunctions);

}


void IdentifyBuiltIns(EShLanguage language, TSymbolTable& symbolTable)
{


   //
   // Next, identify which built-ins from the already loaded headers have
   // a mapping to an operator.  Those that are not identified as such are
   // expected to be resolved through a library of functions, versus as
   // operations.
   //
   symbolTable.relateToOperator("fmod",             EOpMod); //HLSL version


   symbolTable.relateToOperator("radians",      EOpRadians);
   symbolTable.relateToOperator("degrees",      EOpDegrees);
   symbolTable.relateToOperator("sin",          EOpSin);
   symbolTable.relateToOperator("cos",          EOpCos);
   symbolTable.relateToOperator("tan",          EOpTan);
   symbolTable.relateToOperator("asin",         EOpAsin);
   symbolTable.relateToOperator("acos",         EOpAcos);
   symbolTable.relateToOperator("atan",         EOpAtan);
   symbolTable.relateToOperator("atan2",        EOpAtan2);
   symbolTable.relateToOperator("sincos",       EOpSinCos);

   symbolTable.relateToOperator("pow",          EOpPow);
   symbolTable.relateToOperator("exp2",         EOpExp2);
   symbolTable.relateToOperator("log",          EOpLog);
   symbolTable.relateToOperator("exp",          EOpExp);
   symbolTable.relateToOperator("log2",         EOpLog2);
   symbolTable.relateToOperator("log10",        EOpLog10);
   symbolTable.relateToOperator("sqrt",         EOpSqrt);
   symbolTable.relateToOperator("rsqrt",        EOpInverseSqrt); //HLSL version

   symbolTable.relateToOperator("abs",          EOpAbs);
   symbolTable.relateToOperator("sign",         EOpSign);
   symbolTable.relateToOperator("floor",        EOpFloor);
   symbolTable.relateToOperator("ceil",         EOpCeil);
   symbolTable.relateToOperator("frac",         EOpFract); //HLSL version
   symbolTable.relateToOperator("min",          EOpMin);
   symbolTable.relateToOperator("max",          EOpMax);
   symbolTable.relateToOperator("clamp",        EOpClamp);
   symbolTable.relateToOperator("lerp",         EOpMix);  //HLSL version
   symbolTable.relateToOperator("step",         EOpStep);
   symbolTable.relateToOperator("smoothstep",   EOpSmoothStep);

   symbolTable.relateToOperator("mul",          EOpMul); //HLSL mul function
   symbolTable.relateToOperator("transpose",    EOpTranspose);
   symbolTable.relateToOperator("determinant",  EOpDeterminant);

   symbolTable.relateToOperator("length",       EOpLength);
   symbolTable.relateToOperator("distance",     EOpDistance);
   symbolTable.relateToOperator("dot",          EOpDot);
   symbolTable.relateToOperator("cross",        EOpCross);
   symbolTable.relateToOperator("normalize",    EOpNormalize);
   symbolTable.relateToOperator("forward",      EOpFaceForward);
   symbolTable.relateToOperator("faceforward",  EOpFaceForward);
   symbolTable.relateToOperator("reflect",      EOpReflect);
   symbolTable.relateToOperator("refract",      EOpRefract);

   symbolTable.relateToOperator("any",          EOpAny);
   symbolTable.relateToOperator("all",          EOpAll);

   symbolTable.relateToOperator("tex1D",        EOpTex1D);
   symbolTable.relateToOperator("tex1Dproj",    EOpTex1DProj);
   symbolTable.relateToOperator("tex1Dlod",     EOpTex1DLod);
   symbolTable.relateToOperator("tex1Dbias",    EOpTex1DBias);
   symbolTable.relateToOperator("tex1Dgrad",    EOpTex1DGrad);
   symbolTable.relateToOperator("tex2D",        EOpTex2D);
   symbolTable.relateToOperator("tex2Dproj",    EOpTex2DProj);
   symbolTable.relateToOperator("tex2Dlod",     EOpTex2DLod);
   symbolTable.relateToOperator("tex2Dbias",    EOpTex2DBias);
   symbolTable.relateToOperator("tex2Dgrad",    EOpTex2DGrad);
   symbolTable.relateToOperator("tex3D",        EOpTex3D);
   symbolTable.relateToOperator("tex3Dproj",    EOpTex3DProj);
   symbolTable.relateToOperator("tex3Dlod",     EOpTex3DLod);
   symbolTable.relateToOperator("tex3Dbias",    EOpTex3DBias);
   symbolTable.relateToOperator("tex3Dgrad",    EOpTex3DGrad);
   symbolTable.relateToOperator("texRECT",      EOpTexRect);
   symbolTable.relateToOperator("texRECTproj",  EOpTexRectProj);
   symbolTable.relateToOperator("texCUBE",      EOpTexCube);
   symbolTable.relateToOperator("texCUBEproj",  EOpTexCubeProj);
   symbolTable.relateToOperator("texCUBElod",   EOpTexCubeLod);
   symbolTable.relateToOperator("texCUBEbias",  EOpTexCubeBias);
   symbolTable.relateToOperator("texCUBEgrad",  EOpTexCubeGrad);
	symbolTable.relateToOperator("shadow2D",        EOpShadow2D);
	symbolTable.relateToOperator("shadow2Dproj",    EOpShadow2DProj);
	symbolTable.relateToOperator("tex2DArray",      EOpTex2DArray);
	symbolTable.relateToOperator("tex2DArraylod",   EOpTex2DArrayLod);
	symbolTable.relateToOperator("tex2DArraybias",  EOpTex2DArrayBias);

   symbolTable.relateToOperator("saturate",     EOpSaturate);
   symbolTable.relateToOperator("modf",         EOpModf);
   symbolTable.relateToOperator("ldexp",        EOpLdexp);
	symbolTable.relateToOperator("round", EOpRound);
	symbolTable.relateToOperator("trunc", EOpTrunc);

   symbolTable.relateToOperator("lit",          EOpLit);

   symbolTable.relateToOperator("D3DCOLORtoUBYTE4", EOpD3DCOLORtoUBYTE4);

   switch (language)
   {
   
   case EShLangVertex:

   case EShLangFragment:
      symbolTable.relateToOperator("ddx",          EOpDPdx); // HLSL version
      symbolTable.relateToOperator("ddy",          EOpDPdy); // HLSL version
      symbolTable.relateToOperator("fwidth",       EOpFwidth);
	  symbolTable.relateToOperator("clip",         EOpFclip);

      break;

   default: assert(false && "Language not supported");
   }
}

}
