// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


// Implementation of support library to generate GLSL functions to support HLSL
// functions that don't map to built-ins

#include <map>
#include "mslSupportLib.h"

namespace hlslang {
namespace MetalCodeGen {


//typedef std::map<TOperator,std::string> CodeMap;
    
//static CodeMap *_lib = 0;
//static CodeMap *libESOverrides = 0;

//typedef std::map< TOperator, std::pair<std::string,std::string> > CodeExtensionMap;
//static CodeExtensionMap *libExtensions = 0;
//static CodeExtensionMap *libExtensionsESOverrides = 0;

void insertPre130TextureLookups(CodeMap *lib)
{
    lib->insert(EOpTex1DBias,
        "float4 xll_tex1Dbias(sampler1D s, float4 coord) {\n"
        "  return texture1D( s, coord.x, coord.w);\n"
        "}\n\n"
        );

    lib->insert(EOpTex1DLod,
        "float4 xll_tex1Dlod(sampler1D s, float4 coord) {\n"
        "  return texture1DLod( s, coord.x, coord.w);\n"
        "}\n\n"
        );
//    libExtensions->insert (std::make_pair(EOpTex1DLod, std::make_pair("","GL_ARB_shader_texture_lod"));

    lib->insert(EOpTex1DGrad,
        "float4 xll_tex1Dgrad(sampler1D s, float coord, float ddx, float ddy) {\n"
        "  return texture1DGradARB( s, coord, ddx, ddy);\n"
        "}\n\n"
        );
//    libExtensions->insert (std::make_pair(EOpTex1DGrad, std::make_pair("GL_ARB_shader_texture_lod","GL_ARB_shader_texture_lod"));

    lib->insert(EOpTex2DBias,
        "float4 xll_tex2Dbias(sampler2D s, float4 coord) {\n"
        "  return texture2D( s, coord.xy, coord.w);\n"
        "}\n\n"
        );

    lib->insert(EOpTex2DLod,
        "float4 xll_tex2Dlod(sampler2D s, float4 coord) {\n"
        "   return texture2DLod( s, coord.xy, coord.w);\n"
        "}\n\n"
        );
//    libExtensions->insert (std::make_pair(EOpTex2DLod, std::make_pair("","GL_ARB_shader_texture_lod"));

//    libESOverrides->insert(EOpTex2DLod,
//        "float4 xll_tex2Dlod(sampler2D s, float4 coord) {\n"
//        "   return texture2DLodEXT( s, coord.xy, coord.w);\n"
//        "}\n\n"
//        );
//    libExtensionsESOverrides->insert (std::make_pair(EOpTex2DLod, std::make_pair("","GL_EXT_shader_texture_lod"));

    lib->insert(EOpTex2DGrad,
        "float4 xll_tex2Dgrad(sampler2D s, float2 coord, float2 ddx, float2 ddy) {\n"
        "   return texture2DGradARB( s, coord, ddx, ddy);\n"
        "}\n\n"
        );
//    libExtensions->insert (std::make_pair(EOpTex2DGrad, std::make_pair("GL_ARB_shader_texture_lod","GL_ARB_shader_texture_lod"));

//    libESOverrides->insert(EOpTex2DGrad,
//        "float4 xll_tex2Dgrad(sampler2D s, float2 coord, float2 ddx, float2 ddy) {\n"
//        "   return texture2DGradEXT( s, coord, ddx, ddy);\n"
//        "}\n\n"
//        );
//    libExtensionsESOverrides->insert (std::make_pair(EOpTex2DGrad, std::make_pair("GL_EXT_shader_texture_lod","GL_EXT_shader_texture_lod"));


    lib->insert(EOpTex3DBias,
        "float4 xll_tex3Dbias(sampler3D s, float4 coord) {\n"
        "  return texture3D( s, coord.xyz, coord.w);\n"
        "}\n\n"
        );

    lib->insert(EOpTex3DLod,
        "float4 xll_tex3Dlod(sampler3D s, float4 coord) {\n"
        "  return texture3DLod( s, coord.xyz, coord.w);\n"
        "}\n\n"
        );
//    libExtensions->insert (std::make_pair(EOpTex3DLod, std::make_pair("","GL_ARB_shader_texture_lod"));

    lib->insert(EOpTex3DGrad,
        "float4 xll_tex3Dgrad(sampler3D s, float3 coord, float3 ddx, float3 ddy) {\n"
        "  return texture3DGradARB( s, coord, ddx, ddy);\n"
        "}\n\n"
        );
//    libExtensions->insert (std::make_pair(EOpTex3DGrad, std::make_pair("GL_ARB_shader_texture_lod","GL_ARB_shader_texture_lod"));

    lib->insert(EOpTexCubeBias,
        "float4 xll_texCUBEbias(samplerCube s, float4 coord) {\n"
        "  return textureCube( s, coord.xyz, coord.w);\n"
        "}\n\n"
        );

    lib->insert(EOpTexCubeLod,
        "float4 xll_texCUBElod(samplerCube s, float4 coord) {\n"
        "  return textureCubeLod( s, coord.xyz, coord.w);\n"
        "}\n\n"
        );
//    libExtensions->insert (std::make_pair(EOpTexCubeLod, std::make_pair("","GL_ARB_shader_texture_lod"));

//    libESOverrides->insert(EOpTexCubeLod,
//        "float4 xll_texCUBElod(samplerCube s, float4 coord) {\n"
//        "  return textureCubeLodEXT( s, coord.xyz, coord.w);\n"
//        "}\n\n"
//        );
//    libExtensionsESOverrides->insert (std::make_pair(EOpTexCubeLod, std::make_pair("","GL_EXT_shader_texture_lod"));

//    lib->insert(EOpTexCubeGrad,
//        "float4 xll_texCUBEgrad(samplerCube s, float3 coord, float3 ddx, float3 ddy) {\n"
//        "  return textureCubeGradARB( s, coord, ddx, ddy);\n"
//        "}\n\n"
//        );
//    libExtensions->insert (std::make_pair(EOpTexCubeGrad, std::make_pair("GL_ARB_shader_texture_lod","GL_ARB_shader_texture_lod"));
//
//    libESOverrides->insert(EOpTexCubeGrad,
//        "float4 xll_texCUBEgrad(samplerCube s, float3 coord, float3 ddx, float3 ddy) {\n"
//        "  return textureCubeGradEXT( s, coord, ddx, ddy);\n"
//        "}\n\n"
//        );
//    libExtensionsESOverrides->insert (std::make_pair(EOpTexCubeGrad, std::make_pair("GL_EXT_shader_texture_lod","GL_EXT_shader_texture_lod"));

    // shadow2D / shadow2Dproj
//    lib->insert(EOpShadow2D,
//        "float xll_shadow2D(sampler2DShadow s, float3 coord) { return shadow2D (s, coord).r; }\n"
//        );
//    libESOverrides->insert(EOpShadow2D,
//        "float xll_shadow2D(sampler2DShadow s, float3 coord) { return shadow2DEXT (s, coord); }\n"
//        );
//    libExtensionsESOverrides->insert (std::make_pair(EOpShadow2D, std::make_pair("","GL_EXT_shadow_samplers"));
//
//    lib->insert(EOpShadow2DProj,
//        "float xll_shadow2Dproj(sampler2DShadow s, float4 coord) { return shadow2DProj (s, coord).r; }\n"
//        );
//    libESOverrides->insert(EOpShadow2DProj,
//        "float xll_shadow2Dproj(sampler2DShadow s, float4 coord) { return shadow2DProjEXT (s, coord); }\n"
//        );
//    libExtensionsESOverrides->insert (std::make_pair(EOpShadow2DProj, std::make_pair("","GL_EXT_shadow_samplers"));

	// texture arrays
//    lib->insert(EOpTex2DArray, "float4 xll_tex2DArray(sampler2DArray s, float3 coord) { return texture2DArray (s, coord); }\n");
//    libExtensions->insert (std::make_pair(EOpTex2DArray, std::make_pair("GL_EXT_texture_array","GL_EXT_texture_array"));
//    libESOverrides->insert(EOpTex2DArray, "float4 xll_tex2DArray(sampler2DArrayNV s, float3 coord) { return texture2DArrayNV (s, coord); }\n");
//    libExtensionsESOverrides->insert (std::make_pair(EOpTex2DArray, std::make_pair("GL_NV_texture_array","GL_NV_texture_array"));

//    lib->insert(EOpTex2DArrayLod, "float4 xll_tex2DArrayLod(sampler2DArray s, float4 coord) { return texture2DArrayLod (s, coord.xyz, coord.w); }\n");
//    libExtensions->insert (std::make_pair(EOpTex2DArrayLod, std::make_pair("GL_EXT_texture_array","GL_EXT_texture_array"));
//    libESOverrides->insert(EOpTex2DArrayLod, "float4 xll_tex2DArrayLod(sampler2DArrayNV s, float4 coord) { return texture2DArrayLodNV (s, coord.xyz, coord.w); }\n");
//    libExtensionsESOverrides->insert (std::make_pair(EOpTex2DArrayLod, std::make_pair("GL_NV_texture_array","GL_NV_texture_array"));

//    lib->insert(EOpTex2DArrayBias, "float4 xll_tex2DArrayBias(sampler2DArray s, float4 coord) { return texture2DArray (s, coord.xyz, coord.w); }\n");
//    libExtensions->insert (std::make_pair(EOpTex2DArrayBias, std::make_pair("GL_EXT_texture_array","GL_EXT_texture_array"));
//    libESOverrides->insert(EOpTex2DArrayBias, "float4 xll_tex2DArrayBias(sampler2DArrayNV s, float4 coord) { return texture2DArrayNV (s, coord.xyz, coord.w); }\n");
//    libExtensionsESOverrides->insert (std::make_pair(EOpTex2DArrayBias, std::make_pair("GL_NV_texture_array","GL_NV_texture_array"));
}

void insertPost120TextureLookups(CodeMap *lib)
{
//    lib->insert(EOpTex1DBias,
//        "float4 xll_tex1Dbias(sampler1D s, float4 coord) {\n"
//        "  return texture( s, coord.x, coord.w);\n"
//        "}\n\n"
//        );
//
//    lib->insert(EOpTex1DLod,
//        "float4 xll_tex1Dlod(sampler1D s, float4 coord) {\n"
//        "  return textureLod( s, coord.x, coord.w);\n"
//        "}\n\n"
//        );
////    libExtensions->insert (std::make_pair(EOpTex1DLod, std::make_pair("","GL_ARB_shader_texture_lod"));
//
//
//    lib->insert(EOpTex2DBias,
//        "float4 xll_tex2Dbias(sampler2D s, float4 coord) {\n"
//        "  return texture( s, coord.xy, coord.w);\n"
//        "}\n\n"
//        );
//
//    lib->insert(EOpTex2DLod,
//        "float4 xll_tex2Dlod(sampler2D s, float4 coord) {\n"
//        "   return textureLod( s, coord.xy, coord.w);\n"
//        "}\n\n"
//        );
//    //libExtensions->insert (std::make_pair(EOpTex2DLod, std::make_pair("","GL_ARB_shader_texture_lod"));
//
////    libESOverrides->insert(EOpTex2DLod,
////        "float4 xll_tex2Dlod(sampler2D s, float4 coord) {\n"
////        "   return textureLod( s, coord.xy, coord.w);\n"
////        "}\n\n"
////        );
//    //libExtensionsESOverrides->insert (std::make_pair(EOpTex2DLod, std::make_pair("","GL_EXT_shader_texture_lod"));
////    libExtensions->insert (std::make_pair(EOpTex1DLod, std::make_pair("","GL_ARB_shader_texture_lod"));
//
//    lib->insert(EOpTex1DGrad,
//        "float4 xll_tex1Dgrad(sampler1D s, float coord, float ddx, float ddy) {\n"
//        "   return textureGrad( s, coord, ddx, ddy);\n"
//        "}\n\n"
//        );
//    //libExtensions->insert (std::make_pair(EOpTex1DGrad, std::make_pair("GL_ARB_shader_texture_lod","GL_ARB_shader_texture_lod"));
//
//    lib->insert(EOpTex2DBias,
//        "float4 xll_tex2Dbias(sampler2D s, float4 coord) {\n"
//        "  return texture( s, coord.xy, coord.w);\n"
//        "}\n\n"
//        );
//
//    lib->insert(EOpTex2DGrad,
//        "float4 xll_tex2Dgrad(sampler2D s, float2 coord, float2 ddx, float2 ddy) {\n"
//        "   return textureGrad( s, coord, ddx, ddy);\n"
//        "}\n\n"
//        );
//    lib->insert(EOpTex2DLod,
//        "float4 xll_tex2Dlod(sampler2D s, float4 coord) {\n"
//        "   return textureLod( s, coord.xy, coord.w);\n"
//        "}\n\n"
//        );
//    //libExtensions->insert (std::make_pair(EOpTex2DGrad, std::make_pair("GL_ARB_shader_texture_lod","GL_ARB_shader_texture_lod"));
//    //libExtensions->insert (std::make_pair(EOpTex2DLod, std::make_pair("","GL_ARB_shader_texture_lod"));
//
//    //libExtensionsESOverrides->insert (std::make_pair(EOpTex2DGrad, std::make_pair("GL_EXT_shader_texture_lod","GL_EXT_shader_texture_lod"));
//    //libExtensionsESOverrides->insert (std::make_pair(EOpTex2DLod, std::make_pair("","GL_EXT_shader_texture_lod"));
//
//
//    lib->insert(EOpTex3DBias,
//        "float4 xll_tex3Dbias(sampler3D s, float4 coord) {\n"
//        "  return texture( s, coord.xyz, coord.w);\n"
//        "}\n\n"
//        );
//    lib->insert(EOpTex2DGrad,
//        "float4 xll_tex2Dgrad(sampler2D s, float2 coord, float2 ddx, float2 ddy) {\n"
//        "   return textureGrad( s, coord, ddx, ddy);\n"
//        "}\n\n"
//        );
//    //libExtensions->insert (std::make_pair(EOpTex2DGrad, std::make_pair("GL_ARB_shader_texture_lod","GL_ARB_shader_texture_lod"));
//
//    lib->insert(EOpTex3DLod,
//        "float4 xll_tex3Dlod(sampler3D s, float4 coord) {\n"
//        "  return textureLod( s, coord.xyz, coord.w);\n"
//        "}\n\n"
//        );
//    libESOverrides->insert(EOpTex2DGrad,
//        "float4 xll_tex2Dgrad(sampler2D s, float2 coord, float2 ddx, float2 ddy) {\n"
//        "   return textureGrad( s, coord, ddx, ddy);\n"
//        "}\n\n"
//        );
    //libExtensions->insert (std::make_pair(EOpTex3DLod, std::make_pair("","GL_ARB_shader_texture_lod"));
    //libExtensionsESOverrides->insert (std::make_pair(EOpTex2DGrad, std::make_pair("GL_EXT_shader_texture_lod","GL_EXT_shader_texture_lod"));

//    lib->insert(EOpTex3DGrad,
//        "float4 xll_tex3Dgrad(sampler3D s, float3 coord, float3 ddx, float3 ddy) {\n"
//        "  return textureGrad( s, coord, ddx, ddy);\n"
//        "}\n\n"
//        );
//    //libExtensions->insert (std::make_pair(EOpTex3DGrad, std::make_pair("GL_ARB_shader_texture_lod","GL_ARB_shader_texture_lod"));
//
//    lib->insert(EOpTex3DBias,
//        "float4 xll_tex3Dbias(sampler3D s, float4 coord) {\n"
//        "  return texture( s, coord.xyz, coord.w);\n"
//        "}\n\n"
//        );
//
//    lib->insert(EOpTexCubeBias,
//        "float4 xll_texCUBEbias(samplerCube s, float4 coord) {\n"
//        "  return texture( s, coord.xyz, coord.w);\n"
//        "}\n\n"
//        );
//    lib->insert(EOpTex3DLod,
//        "float4 xll_tex3Dlod(sampler3D s, float4 coord) {\n"
//        "  return textureLod( s, coord.xyz, coord.w);\n"
//        "}\n\n"
//        );
//
//    lib->insert(EOpTexCubeLod,
//        "float4 xll_texCUBElod(samplerCube s, float4 coord) {\n"
//        "  return textureLod( s, coord.xyz, coord.w);\n"
//        "}\n\n"
//        );
//    //libExtensions->insert (std::make_pair(EOpTexCubeLod, std::make_pair("","GL_ARB_shader_texture_lod"));
//
//    lib->insert(EOpTexCubeGrad,
//        "float4 xll_texCUBEgrad(samplerCube s, float3 coord, float3 ddx, float3 ddy) {\n"
//        "  return textureGrad( s, coord, ddx, ddy);\n"
//        "}\n\n"
//        );
//    //libExtensions->insert (std::make_pair(EOpTexCubeGrad, std::make_pair("GL_ARB_shader_texture_lod","GL_ARB_shader_texture_lod"));
//    //libExtensions->insert (std::make_pair(EOpTex3DLod, std::make_pair("","GL_ARB_shader_texture_lod"));
//
//    lib->insert(EOpTex3DGrad,
//        "float4 xll_tex3Dgrad(sampler3D s, float3 coord, float3 ddx, float3 ddy) {\n"
//        "  return textureGrad( s, coord, ddx, ddy);\n"
//        "}\n\n"
//        );
//    //libExtensions->insert (std::make_pair(EOpTex3DGrad, std::make_pair("GL_ARB_shader_texture_lod","GL_ARB_shader_texture_lod"));
//
//    lib->insert(EOpTexCubeBias,
//        "float4 xll_texCUBEbias(samplerCube s, float4 coord) {\n"
//        "  return texture( s, coord.xyz, coord.w);\n"
//        "}\n\n"
//        );

    // shadow2D / shadow2Dproj
//    lib->insert(EOpShadow2D,
//        "float xll_shadow2D(sampler2DShadow s, float3 coord) { return texture (s, coord); }\n"
//        );
//    libESOverrides->insert(EOpShadow2D,
//        "float xll_shadow2D(mediump sampler2DShadow s, float3 coord) { return texture (s, coord); }\n"
//        );
    //libExtensionsESOverrides->insert (std::make_pair(EOpShadow2D, std::make_pair("","GL_EXT_shadow_samplers"));

//    lib->insert(EOpShadow2DProj,
//        "float xll_shadow2Dproj(sampler2DShadow s, float4 coord) { return textureProj (s, coord); }\n"
//        );
//    libESOverrides->insert(EOpShadow2DProj,
//        "float xll_shadow2Dproj(mediump sampler2DShadow s, float4 coord) { return textureProj (s, coord); }\n"
//        );
    //libExtensionsESOverrides->insert (std::make_pair(EOpShadow2DProj, std::make_pair("","GL_EXT_shadow_samplers"));

	// texture arrays
//    lib->insert(EOpTex2DArray, "float4 xll_tex2DArray(sampler2DArray s, float3 coord) { return texture (s, coord); }\n");
//    lib->insert(EOpTex2DArrayLod, "float4 xll_tex2DArrayLod(sampler2DArray s, float4 coord) { return textureLod (s, coord.xyz, coord.w); }\n");
//    lib->insert(EOpTex2DArrayBias, "float4 xll_tex2DArrayBias(sampler2DArray s, float4 coord) { return texture (s, coord.xyz, coord.w); }\n");
}


CodeMap * createMetalSupportLibrary(ETargetVersion targetVersion)
{
	CodeMap *lib = new CodeMap();
    

    //ACS: some texture lookup types were deprecated after 1.20, and 1.40 won't accept them
    bool usePost120TextureLookups = false;
    if(targetVersion!=ETargetVersionCount) //default
    {
        usePost120TextureLookups = (targetVersion>ETargetGLSL_120);
    }

   // Initialize GLSL code for the op codes that require support helper functions

   lib->insert(EOpNull, "");

   lib->insert(EOpAbs,
      "float2x2 xll_abs(float2x2 m) {\n"
      "  return float2x2( abs(m[0]), abs(m[1]));\n"
      "}\n\n"
      "float3x3 xll_abs(float3x3 m) {\n"
      "  return float3x3( abs(m[0]), abs(m[1]), abs(m[2]));\n"
      "}\n\n"
      "float4x4 xll_abs(float4x4 m) {\n"
      "  return float4x4( abs(m[0]), abs(m[1]), abs(m[2]), abs(m[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpAcos,
      "float2x2 xll_acos(float2x2 m) {\n"
      "  return float2x2( acos(m[0]), acos(m[1]));\n"
      "}\n\n"
      "float3x3 xll_acos(float3x3 m) {\n"
      "  return float3x3( acos(m[0]), acos(m[1]), acos(m[2]));\n"
      "}\n\n"
      "float4x4 xll_acos(float4x4 m) {\n"
      "  return float4x4( acos(m[0]), acos(m[1]), acos(m[2]), acos(m[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpCos,
      "float2x2 xll_cos(float2x2 m) {\n"
      "  return float2x2( cos(m[0]), cos(m[1]));\n"
      "}\n\n"
      "float3x3 xll_cos(float3x3 m) {\n"
      "  return float3x3( cos(m[0]), cos(m[1]), cos(m[2]));\n"
      "}\n\n"
      "float4x4 xll_cos(float4x4 m) {\n"
      "  return float4x4( cos(m[0]), cos(m[1]), cos(m[2]), cos(m[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpAsin,
      "float2x2 xll_asin(float2x2 m) {\n"
      "  return float2x2( asin(m[0]), asin(m[1]));\n"
      "}\n\n"
      "float3x3 xll_asin(float3x3 m) {\n"
      "  return float3x3( asin(m[0]), asin(m[1]), asin(m[2]));\n"
      "}\n\n"
      "float4x4 xll_asin(float4x4 m) {\n"
      "  return float4x4( asin(m[0]), asin(m[1]), asin(m[2]), asin(m[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpSin,
      "float2x2 xll_sin(float2x2 m) {\n"
      "  return float2x2( sin(m[0]), sin(m[1]));\n"
      "}\n\n"
      "float3x3 xll_sin(float3x3 m) {\n"
      "  return float3x3( sin(m[0]), sin(m[1]), sin(m[2]));\n"
      "}\n\n"
      "float4x4 xll_sin(float4x4 m) {\n"
      "  return float4x4( sin(m[0]), sin(m[1]), sin(m[2]), sin(m[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpDPdx,
	  "float xll_dFdx(float f) {\n"
	  "  return dfdx(f);\n"
	  "}\n\n"
	  "float2 xll_dFdx(float2 v) {\n"
	  "  return dfdx(v);\n"
	  "}\n\n"
	  "float3 xll_dFdx(float3 v) {\n"
	  "  return dfdx(v);\n"
	  "}\n\n"
	  "float4 xll_dFdx(float4 v) {\n"
	  "  return dfdx(v);\n"
	  "}\n\n"
      "float2x2 xll_dFdx(float2x2 m) {\n"
      "  return float2x2( dfdx(m[0]), dfdx(m[1]));\n"
      "}\n\n"
      "float3x3 xll_dFdx(float3x3 m) {\n"
      "  return float3x3( dfdx(m[0]), dfdx(m[1]), dfdx(m[2]));\n"
      "}\n\n"
      "float4x4 xll_dFdx(float4x4 m) {\n"
      "  return float4x4( dfdx(m[0]), dfdx(m[1]), dfdx(m[2]), dfdx(m[3]));\n"
      "}\n\n"
      );

//    if (targetVersion < ETargetGLSL_ES_300)
//    libExtensionsESOverrides->insert (std::make_pair(EOpDPdx, std::make_pair("","GL_OES_standard_derivatives"));

   lib->insert(EOpDPdy,
	  "float xll_dFdy(float f) {\n"
	  "  return dfdy(f);\n"
	  "}\n\n"
	  "float2 xll_dFdy(float2 v) {\n"
	  "  return dfdy(v);\n"
	  "}\n\n"
	  "float3 xll_dFdy(float3 v) {\n"
	  "  return dfdy(v);\n"
	  "}\n\n"
	  "float4 xll_dFdy(float4 v) {\n"
	  "  return dfdy(v);\n"
	  "}\n\n"
      "float2x2 xll_dFdy(float2x2 m) {\n"
      "  return float2x2( dfdy(m[0]), dfdy(m[1]));\n"
      "}\n\n"
      "float3x3 xll_dFdy(float3x3 m) {\n"
      "  return float3x3( dfdy(m[0]), dfdy(m[1]), dfdy(m[2]));\n"
      "}\n\n"
      "float4x4 xll_dFdy(float4x4 m) {\n"
      "  return float4x4( dfdy(m[0]), dfdy(m[1]), dfdy(m[2]), dfdy(m[3]));\n"
      "}\n\n"
      );

//    if (targetVersion < ETargetGLSL_ES_300)
//    libExtensionsESOverrides->insert (std::make_pair(EOpDPdy, std::make_pair("","GL_OES_standard_derivatives"));

   lib->insert(EOpExp,
      "float2x2 xll_exp(float2x2 m) {\n"
      "  return float2x2( exp(m[0]), exp(m[1]));\n"
      "}\n\n"
      "float3x3 xll_exp(float3x3 m) {\n"
      "  return float3x3( exp(m[0]), exp(m[1]), exp(m[2]));\n"
      "}\n\n"
      "float4x4 xll_exp(float4x4 m) {\n"
      "  return float4x4( exp(m[0]), exp(m[1]), exp(m[2]), exp(m[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpExp2,
      "float2x2 xll_exp2(float2x2 m) {\n"
      "  return float2x2( exp2(m[0]), exp2(m[1]));\n"
      "}\n\n"
      "float3x3 xll_exp2(float3x3 m) {\n"
      "  return float3x3( exp2(m[0]), exp2(m[1]), exp2(m[2]));\n"
      "}\n\n"
      "float4x4 xll_exp2(float4x4 m) {\n"
      "  return float4x4( exp2(m[0]), exp2(m[1]), exp2(m[2]), exp2(m[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpLog,
      "float2x2 xll_log(float2x2 m) {\n"
      "  return float2x2( log(m[0]), log(m[1]));\n"
      "}\n\n"
      "float3x3 xll_log(float3x3 m) {\n"
      "  return float3x3( log(m[0]), log(m[1]), log(m[2]));\n"
      "}\n\n"
      "float4x4 xll_log(float4x4 m) {\n"
      "  return float4x4( log(m[0]), log(m[1]), log(m[2]), log(m[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpLog2,
      "float2x2 xll_log2(float2x2 m) {\n"
      "  return float2x2( log2(m[0]), log2(m[1]));\n"
      "}\n\n"
      "float3x3 xll_log2(float3x3 m) {\n"
      "  return float3x3( log2(m[0]), log2(m[1]), log2(m[2]));\n"
      "}\n\n"
      "float4x4 xll_log2(float4x4 m) {\n"
      "  return float4x4( log2(m[0]), log2(m[1]), log2(m[2]), log2(m[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpTan,
      "float2x2 xll_tan(float2x2 m) {\n"
      "  return float2x2( tan(m[0]), tan(m[1]));\n"
      "}\n\n"
      "float3x3 xll_tan(float3x3 m) {\n"
      "  return float3x3( tan(m[0]), tan(m[1]), tan(m[2]));\n"
      "}\n\n"
      "float4x4 xll_tan(float4x4 m) {\n"
      "  return float4x4( tan(m[0]), tan(m[1]), tan(m[2]), tan(m[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpAtan,
      "float2x2 xll_atan(float2x2 m) {\n"
      "  return float2x2( atan(m[0]), atan(m[1]));\n"
      "}\n\n"
      "float3x3 xll_atan(float3x3 m) {\n"
      "  return float3x3( atan(m[0]), atan(m[1]), atan(m[2]));\n"
      "}\n\n"
      "float4x4 xll_atan(float4x4 m) {\n"
      "  return float4x4( atan(m[0]), atan(m[1]), atan(m[2]), atan(m[3]));\n"
      "}\n\n"
      );

//   lib->insert(EOpDegrees,
//      "float2x2 xll_degrees(float2x2 m) {\n"
//      "  return float2x2( degrees(m[0]), degrees(m[1]));\n"
//      "}\n\n"
//      "float3x3 xll_degrees(float3x3 m) {\n"
//      "  return float3x3( degrees(m[0]), degrees(m[1]), degrees(m[2]));\n"
//      "}\n\n"
//      "float4x4 xll_degrees(float4x4 m) {\n"
//      "  return float4x4( degrees(m[0]), degrees(m[1]), degrees(m[2]), degrees(m[3]));\n"
//      "}\n\n"
//      );
//
//    lib->insert(EOpRadians,
//      "float2x2 xll_radians(float2x2 m) {\n"
//      "  return float2x2( radians(m[0]), radians(m[1]));\n"
//      "}\n\n"
//      "float3x3 xll_radians(float3x3 m) {\n"
//      "  return float3x3( radians(m[0]), radians(m[1]), radians(m[2]));\n"
//      "}\n\n"
//      "float4x4 xll_radians(float4x4 m) {\n"
//      "  return float4x4( radians(m[0]), radians(m[1]), radians(m[2]), radians(m[3]));\n"
//      "}\n\n"
//      );

    lib->insert(EOpSqrt,
      "float2x2 xll_sqrt(float2x2 m) {\n"
      "  return float2x2( sqrt(m[0]), sqrt(m[1]) );\n"
      "}\n\n"
      "float3x3 xll_sqrt(float3x3 m) {\n"
      "  return float3x3( sqrt(m[0]), sqrt(m[1]), sqrt(m[2]) );\n"
      "}\n\n"
      "float4x4 xll_sqrt(float4x4 m) {\n"
      "  return float4x4( sqrt(m[0]), sqrt(m[1]), sqrt(m[2]), sqrt(m[3]) );\n"
      "}\n\n"
      );

   lib->insert(EOpInverseSqrt,
      "float2x2 xll_inversesqrt(float2x2 m) {\n"
      "  return float2x2( rsqrt(m[0]), rsqrt(m[1]) );\n"
      "}\n\n"
      "float3x3 xll_inversesqrt(float3x3 m) {\n"
      "  return float3x3( rsqrt(m[0]), rsqrt(m[1]), rsqrt(m[2]) );\n"
      "}\n\n"
      "float4x4 xll_inversesqrt(float4x4 m) {\n"
      "  return float4x4( rsqrt(m[0]), rsqrt(m[1]), rsqrt(m[2]), rsqrt(m[3]) );\n"
      "}\n\n"
      );

   lib->insert(EOpFloor,
      "float2x2 xll_floor(float2x2 m) {\n"
      "  return float2x2( floor(m[0]), floor(m[1]));\n"
      "}\n\n"
      "float3x3 xll_floor(float3x3 m) {\n"
      "  return float3x3( floor(m[0]), floor(m[1]), floor(m[2]));\n"
      "}\n\n"
      "float4x4 xll_floor(float4x4 m) {\n"
      "  return float4x4( floor(m[0]), floor(m[1]), floor(m[2]), floor(m[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpSign,
      "float2x2 xll_sign(float2x2 m) {\n"
      "  return float2x2( sign(m[0]), sign(m[1]));\n"
      "}\n\n"
      "float3x3 xll_sign(float3x3 m) {\n"
      "  return float3x3( sign(m[0]), sign(m[1]), sign(m[2]));\n"
      "}\n\n"
      "float4x4 xll_sign(float4x4 m) {\n"
      "  return float4x4( sign(m[0]), sign(m[1]), sign(m[2]), sign(m[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpCeil,
      "float2x2 xll_ceil(float2x2 m) {\n"
      "  return float2x2( ceil(m[0]), ceil(m[1]));\n"
      "}\n\n"
      "float3x3 xll_ceil(float3x3 m) {\n"
      "  return float3x3( ceil(m[0]), ceil(m[1]), ceil(m[2]));\n"
      "}\n\n"
      "float4x4 xll_ceil(float4x4 m) {\n"
      "  return float4x4( ceil(m[0]), ceil(m[1]), ceil(m[2]), ceil(m[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpFract,
      "float2x2 xll_fract(float2x2 m) {\n"
      "  return float2x2( fract(m[0]), fract(m[1]));\n"
      "}\n\n"
      "float3x3 xll_fract(float3x3 m) {\n"
      "  return float3x3( fract(m[0]), fract(m[1]), fract(m[2]));\n"
      "}\n\n"
      "float4x4 xll_fract(float4x4 m) {\n"
      "  return float4x4( fract(m[0]), fract(m[1]), fract(m[2]), fract(m[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpFwidth,
	  "float xll_fwidth(float f) {\n"
	  "  return fwidth(f);\n"
	  "}\n\n"
	  "float2 xll_fwidth(float2 v) {\n"
	  "  return fwidth(v);\n"
	  "}\n\n"
	  "float3 xll_fwidth(float3 v) {\n"
	  "  return fwidth(v);\n"
	  "}\n\n"
	  "float4 xll_fwidth(float4 v) {\n"
	  "  return fwidth(v);\n"
	  "}\n\n"
      "float2x2 xll_fwidth(float2x2 m) {\n"
      "  return float2x2( fwidth(m[0]), fwidth(m[1]));\n"
      "}\n\n"
      "float3x3 xll_fwidth(float3x3 m) {\n"
      "  return float3x3( fwidth(m[0]), fwidth(m[1]), fwidth(m[2]));\n"
      "}\n\n"
      "float4x4 xll_fwidth(float4x4 m) {\n"
      "  return float4x4( fwidth(m[0]), fwidth(m[1]), fwidth(m[2]), fwidth(m[3]));\n"
      "}\n\n"
      );
//    if (targetVersion < ETargetGLSL_ES_300)
//    libExtensionsESOverrides->insert (std::make_pair(EOpFwidth, std::make_pair("","GL_OES_standard_derivatives"));

    /*
   lib->insert(EOpFclip,
	   "void xll_clip(float x) {\n"
	   "  if ( x<0.0 ) discard;\n"
	   "}\n"
	   "void xll_clip(float2 x) {\n"
	   "  if (any(lessThan(x,float2(0.0)))) discard;\n"
	   "}\n"
	   "void xll_clip(float3 x) {\n"
	   "  if (any(lessThan(x,float3(0.0)))) discard;\n"
	   "}\n"
	   "void xll_clip(float4 x) {\n"
	   "  if (any(lessThan(x,float4(0.0)))) discard;\n"
	   "}\n"
	);
     */

   lib->insert(EOpPow,
       "template<typename T, typename U> T xll_pow(T x, U y) {\n"
       "  return pow(abs(x), y);\n"
       "}\n\n"
    "float2x2 xll_pow(float2x2 m, float2x2 y) {\n"
      "  return float2x2( xll_pow(m[0],y[0]), xll_pow(m[1],y[1]));\n"
      "}\n\n"
      "float3x3 xll_pow(float3x3 m, float3x3 y) {\n"
      "  return float3x3( xll_pow(m[0],y[0]), xll_pow(m[1],y[1]), xll_pow(m[2],y[2]));\n"
      "}\n\n"
      "float4x4 xll_pow(float4x4 m, float4x4 y) {\n"
      "  return float4x4( xll_pow(m[0],y[0]), xll_pow(m[1],y[1]), xll_pow(m[2],y[2]), xll_pow(m[3],y[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpAtan2,
      "float2x2 xll_atan2(float2x2 m, float2x2 y) {\n"
      "  return float2x2( atan2(m[0],y[0]), atan2(m[1],y[1]));\n"
      "}\n\n"
      "float3x3 xll_atan2(float3x3 m, float3x3 y) {\n"
      "  return float3x3( atan2(m[0],y[0]), atan2(m[1],y[1]), atan2(m[2],y[2]));\n"
      "}\n\n"
      "float4x4 xll_atan2(float4x4 m, float4x4 y) {\n"
      "  return float4x4( atan2(m[0],y[0]), atan2(m[1],y[1]), atan2(m[2],y[2]), atan2(m[3],y[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpMin,
      "float2x2 xll_min(float2x2 m, float2x2 y) {\n"
      "  return float2x2( min(m[0],y[0]), min(m[1],y[1]));\n"
      "}\n\n"
      "float3x3 xll_min(float3x3 m, float3x3 y) {\n"
      "  return float3x3( min(m[0],y[0]), min(m[1],y[1]), min(m[2],y[2]));\n"
      "}\n\n"
      "float4x4 xll_min(float4x4 m, float4x4 y) {\n"
      "  return float4x4( min(m[0],y[0]), min(m[1],y[1]), min(m[2],y[2]), min(m[3],y[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpMax,
      "float2x2 xll_max(float2x2 m, float2x2 y) {\n"
      "  return float2x2( max(m[0],y[0]), max(m[1],y[1]));\n"
      "}\n\n"
      "float3x3 xll_max(float3x3 m, float3x3 y) {\n"
      "  return float3x3( max(m[0],y[0]), max(m[1],y[1]), max(m[2],y[2]));\n"
      "}\n\n"
      "float4x4 xll_max(float4x4 m, float4x4 y) {\n"
      "  return float4x4( max(m[0],y[0]), max(m[1],y[1]), max(m[2],y[2]), max(m[3],y[3]));\n"
      "}\n\n"
      );

   lib->insert(EOpTranspose,
        "float2x2 xll_transpose(float2x2 m) {\n"
        "  return float2x2( m[0][0], m[1][0], m[0][1], m[1][1]);\n"
        "}\n\n"
        "float3x3 xll_transpose(float3x3 m) {\n"
        "  return float3x3( m[0][0], m[1][0], m[2][0],\n"
        "               m[0][1], m[1][1], m[2][1],\n"
        "               m[0][2], m[1][2], m[2][2]);\n"
        "}\n\n"
        "float4x4 xll_transpose(float4x4 m) {\n"
        "  return float4x4( m[0][0], m[1][0], m[2][0], m[3][0],\n"
        "               m[0][1], m[1][1], m[2][1], m[3][1],\n"
        "               m[0][2], m[1][2], m[2][2], m[3][2],\n"
        "               m[0][3], m[1][3], m[2][3], m[3][3]);\n"
        "}\n"
        );

	// Note: constructing temporary vector and assigning individual components; seems to avoid
	// some GLSL bugs on AMD (Win7, Radeon HD 58xx, Catalyst 10.5).
	lib->insert(EOpMatrixIndex,
		"float2 xll_matrixindex(float2x2 m, int i) { float2 v; v.x=m[0][i]; v.y=m[1][i]; return v; }\n"
		"float3 xll_matrixindex(float3x3 m, int i) { float3 v; v.x=m[0][i]; v.y=m[1][i]; v.z=m[2][i]; return v; }\n"
		"float4 xll_matrixindex(float4x4 m, int i) { float4 v; v.x=m[0][i]; v.y=m[1][i]; v.z=m[2][i]; v.w=m[3][i]; return v; }\n"
		);

	// The GLSL ES implementation on NaCl does not support dynamic indexing
	// (except when the operand is a uniform in vertex shaders). The GLSL specification
	// leaves it open to vendors to support this or not. So, for NaCl we use if statements to
	// simulate the indexing.
	lib->insert(EOpMatrixIndexDynamic,
		"#if defined(SHADER_API_GLES) && defined(SHADER_API_DESKTOP)\n"
		"float2 xll_matrixindexdynamic(float2x2 m, int i) {\n"
		"	float2x2 m2 = xll_transpose_mf2x2(m);\n"
		"	return i==0?m2[0]:m2[1];\n"
		"}\n"
		"float3 xll_matrixindexdynamic(float3x3 m, int i) {\n"
		"	float3x3 m2 = xll_transpose_mf3x3(m);\n"
		"	return i < 2?(i==0?m2[0]:m2[1]):(m2[2]);\n"
		"}\n"
		"float4 xll_matrixindexdynamic(float4x4 m, int i) {\n"
		"	float4x4 m2 = xll_transpose_mf4x4(m);\n"
		"	return i < 2?(i==0?m2[0]:m2[1]):(i==3?m2[3]:m2[2]);\n"
		"}\n"
		"#else\n"
		"float2 xll_matrixindexdynamic(float2x2 m, int i) { return xll_matrixindex(m, i); }\n"
		"float3 xll_matrixindexdynamic(float3x3 m, int i) { return xll_matrixindex(m, i); }\n"
		"float4 xll_matrixindexdynamic(float4x4 m, int i) { return xll_matrixindex(m, i); }\n"
		"#endif\n"
		);

    
    lib->insert(EOpConstructFloat,
                            "inline float xll_construct_float( float f) {return f;} \n"
                            "inline float xll_construct_float( float2 v) {return v.x;} \n"
                            "inline float xll_construct_float( float3 v) {return v.x;} \n"
                            "inline float xll_construct_float( float4 v) {return v.x;} \n"
                       );

    lib->insert(EOpConstructVec2,
                                                "inline float2 xll_construct_float2( float f) {return float2(f,f);} \n"
                                                "inline float2 xll_construct_float2( float2 v) {return v;} \n"
                                                "inline float2 xll_construct_float2( float3 v) {return v.xy;} \n"
                                                "inline float2 xll_construct_float2( float4 v) {return v.xy;} \n"
                                                );
    lib->insert(EOpConstructVec3,
                                                "inline float3 xll_construct_float3( float f) {return float3(f,f,f);} \n"
                                                "inline float3 xll_construct_float3( float2 v) {return float3(v.xy,0);} \n"
                                                "inline float3 xll_construct_float3( float3 v) {return v;} \n"
                                                "inline float3 xll_construct_float3( float4 v) {return v.xyz;} \n"
                                                );
    lib->insert(EOpConstructVec4,
                                                "inline float4 xll_construct_float4( float f) {return float4(f,f,f,f);} \n"
                                                "inline float4 xll_construct_float4( float x,float y,float z, float w) {return float4(x,y,z,w);} \n"
                                                "inline float4 xll_construct_float4( float2 v) {return float4(v.xy,0,0);} \n"
                                                "inline float4 xll_construct_float4( float3 v) {return float4(v.xyz,0);} \n"
                                                "inline float4 xll_construct_float4( float3 v, float w) {return float4(v.xyz,w);} \n"
                                                "inline float4 xll_construct_float4( float4 v) {return v;} \n"
                                                );

    lib->insert(EOpConstructMat2x2,
                                                "float2x2 xll_construct_float2x2( float4 v) {\n"
                                                "  return float2x2( float2(v.x, v.y), float2(v.z, v.w));\n"
                                                "}\n"
                           );
    
	// Used in pre-GLSL 1.20
	lib->insert(EOpConstructMat2x2FromMat,
		"float2x2 xll_constructMat2(float3x3 m) {\n"
        "  return float2x2( float2( m[0].xy), float2( m[1].xy));\n"
        "}\n\n"
		"float2x2 xll_constructMat2(float4x4 m) {\n"
        "  return float2x2( float2( m[0].xy), float2( m[1].xy));\n"
        "}\n"
        );
	lib->insert(EOpConstructMat3x3FromMat,
		"float3x3 xll_constructMat3(float4x4 m) {\n"
        "  return float3x3( float3( m[0]), float3( m[1]), float3( m[2]));\n"
        "}\n"
        );

   lib->insert(EOpDeterminant,
        "float xll_determinant(float2x2 m) {\n"
        "    return m[0][0]*m[1][1] - m[0][1]*m[1][0];\n"
        "}\n\n"
        "float xll_determinant(float3x3 m) {\n"
        "    float3 temp;\n"
        "    temp.x = m[1][1]*m[2][2] - m[1][2]*m[2][1];\n"
        "    temp.y = - (m[0][1]*m[2][2] - m[0][2]*m[2][1]);\n"
        "    temp.z = m[0][1]*m[1][2] - m[0][2]*m[1][1];\n"
        "    return dot( m[0], temp);\n"
        "}\n\n"
        "float xll_determinant(float4x4 m) {\n"
        "    float4 temp;\n"
        "    temp.x = xll_determinant(float3x3( m[1].yzw, m[2].yzw, m[3].yzw));\n"
        "    temp.y = -xll_determinant(float3x3( m[0].yzw, m[2].yzw, m[3].yzw));\n"
        "    temp.z = xll_determinant(float3x3( m[0].yzw, m[1].yzw, m[3].yzw));\n"
        "    temp.w = -xll_determinant(float3x3( m[0].yzw, m[1].yzw, m[2].yzw));\n"
        "    return dot( m[0], temp);\n"
        "}\n"
        );

   lib->insert(EOpSaturate,
                                               /*
        "float xll_saturate_f( float x) {\n"
        "  return clamp( x, 0.0, 1.0);\n"
        "}\n\n"
        "float2 xll_saturate_vf2( float2 x) {\n"
        "  return clamp( x, 0.0, 1.0);\n"
        "}\n\n"
        "float3 xll_saturate_vf3( float3 x) {\n"
        "  return clamp( x, 0.0, 1.0);\n"
        "}\n\n"
        "float4 xll_saturate_vf4( float4 x) {\n"
        "  return clamp( x, 0.0, 1.0);\n"
        "}\n\n"
        "float2x2 xll_saturate(float2x2 m) {\n"
        "  return float2x2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0);\n"
        "}\n\n"
        "float3x3 xll_saturate(float3x3 m) {\n"
        "  return float3x3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0);\n"
        "}\n\n"
        "float4x4 xll_saturate(float4x4 m) {\n"
        "  return float4x4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0);\n"
        "}\n\n"
                                               */
                                             
                                               /*
                                               "float xll_saturate( float x) {\n"
                                               "  return clamp( x, 0.0, 1.0);\n"
                                               "}\n\n"
                                               "float2 xll_saturate( float2 x) {\n"
                                               "  return clamp( x, 0.0, 1.0);\n"
                                               "}\n\n"
                                               "float3 xll_saturate( float3 x) {\n"
                                               "  return clamp( x, 0.0, 1.0);\n"
                                               "}\n\n"
                                               "float4 xll_saturate( float4 x) {\n"
                                               "  return clamp( x, 0.0, 1.0);\n"
                                               "}\n\n"
                                               "float2x2 xll_saturate(float2x2 m) {\n"
                                               "  return float2x2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0);\n"
                                               "}\n\n"
                                               "float3x3 xll_saturate(float3x3 m) {\n"
                                               "  return float3x3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0);\n"
                                               "}\n\n"
                                               "float4x4 xll_saturate(float4x4 m) {\n"
                                               "  return float4x4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0);\n"
                                               "}\n\n"
*/
               

    "template<typename T> T xll_saturate( T x) {\n"
    "  return saturate(x);\n"
    "}\n\n"
               /*
               "float xll_saturate( float x) {\n"
               "  return clamp( x, 0.0, 1.0);\n"
               "}\n\n"
               "float2 xll_saturate( float2 x) {\n"
               "  return clamp( x, 0.0, 1.0);\n"
               "}\n\n"
               "float3 xll_saturate( float3 x) {\n"
               "  return clamp( x, 0.0, 1.0);\n"
               "}\n\n"
               "float4 xll_saturate( float4 x) {\n"
               "  return clamp( x, 0.0, 1.0);\n"
               "}\n\n"
               "float2x2 xll_saturate(float2x2 m) {\n"
               "  return float2x2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0));\n"
               "}\n\n"
               "float3x3 xll_saturate(float3x3 m) {\n"
               "  return float3x3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0));\n"
               "}\n\n"
               "float4x4 xll_saturate(float4x4 m) {\n"
               "  return float4x4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0));\n"
               "}\n\n"
               */
    
        );

    lib->insert(EOpNegative,
                            "inline float2x2 xll_negative( float2x2 m) {return float2x2( -m[0], -m[1]);}\n"
                            "inline float3x3 xll_negative( float3x3 m) {return float3x3( -m[0], -m[1], -m[2]);}\n"
                            "inline float4x4 xll_negative( float4x4 m) {return float4x4( -m[0], -m[1], -m[2], -m[3]);}\n"
       );
    
    lib->insert(EOpNormalize,
                                                "inline float normalize( float x) {\n"
                                                "  return 1.0f;\n"
                                                "}\n\n"
                           
                           );

    lib->insert(EOpLength,
                "inline float length( float x) {\n"
                "  return x;\n"
                "}\n\n"
                           );

    
	// \todo [pyry] There is mod() built-in in GLSL
   lib->insert(EOpMod,
               "template<typename T>\n"
               "T mod( T x, T y ) {\n"
               "  return fmod(x,y);\n"
               "}\n\n"
       "float xll_mod( float x, float y ) {\n"
	   "  float d = x / y;\n"
	   "  float f = fract (abs(d)) * y;\n"
	   "  return d >= 0.0 ? f : -f;\n"
	   "}\n\n"
	   "float2 xll_mod( float2 x, float2 y ) {\n"
	   "  float2 d = x / y;\n"
	   "  float2 f = fract (abs(d)) * y;\n"
	   "  return float2 (d.x >= 0.0 ? f.x : -f.x, d.y >= 0.0 ? f.y : -f.y);\n"
	   "}\n\n"
	   "float3 xll_mod( float3 x, float3 y ) {\n"
	   "  float3 d = x / y;\n"
	   "  float3 f = fract (abs(d)) * y;\n"
	   "  return float3 (d.x >= 0.0 ? f.x : -f.x, d.y >= 0.0 ? f.y : -f.y, d.z >= 0.0 ? f.z : -f.z);\n"
	   "}\n\n"
	   "float4 xll_mod( float4 x, float4 y ) {\n"
	   "  float4 d = x / y;\n"
	   "  float4 f = fract (abs(d)) * y;\n"
	   "  return float4 (d.x >= 0.0 ? f.x : -f.x, d.y >= 0.0 ? f.y : -f.y, d.z >= 0.0 ? f.z : -f.z, d.w >= 0.0 ? f.w : -f.w);\n"
	   "}\n\n"
	   
	   );

	// \todo [pyry] GLSL ES 3 includes built-in function for this
   /*
    lib->insert(EOpModf,
        "float xll_modf_f_i( float x,  int &ip) {\n"
		"  ip = int (x);\n"
		"  return x-float(ip);\n"
        "}\n\n"
        "float xll_modf_f_f( float x,float &ip) {\n"
		"  int i = int (x);\n"
		"  ip = float(i);\n"
		"  return x-ip;\n"
        "}\n\n"
		"float2 xll_modf_vf2_vi2( float2 x, ivec2 &ip) {\n"
		"  ip = ivec2 (x);\n"
		"  return x-float2(ip);\n"
		"}\n\n"
		"float2 xll_modf_vf2_vf2( float2 x, float2 &ip) {\n"
		"  ivec2 i = ivec2 (x);\n"
		"  ip = float2(i);\n"
		"  return x-ip;\n"
		"}\n\n"
		"float3 xll_modf_vf3_vi3( float3 x,  int3 &ip) {\n"
		"  ip = ivec3 (x);\n"
		"  return x-float3(ip);\n"
		"}\n\n"
		"float3 xll_modf_vf3_vf3( float3 x, float3 &ip) {\n"
		"  ivec3 i = ivec3 (x);\n"
		"  ip = float3(i);\n"
		"  return x-ip;\n"
		"}\n\n"
		"float4 xll_modf_vf4_vi4( float4 x, ivec4 &ip) {\n"
		"  ip = ivec4 (x);\n"
		"  return x-float4(ip);\n"
		"}\n\n"
        "float4 xll_modf_vf4_vf4( float4 x, float4 &ip) {\n"
		"  ivec4 i = ivec4 (x);\n"
		"  ip = float4(i);\n"
		"  return x-ip;\n"
		"}\n\n"
		
        );
*/
    lib->insert(EOpEqual,
                "bool  equal(float  a, float  b) {return a == b;}\n"
                "bool2 equal(float2 a, float2 b) {return a == b;}\n"
                "bool3 equal(float3 a, float3 b) {return a == b;}\n"
                "bool4 equal(float4 a, float4 b) {return a == b;}\n"
                );
    
    lib->insert(EOpNotEqual,
                "bool  notEqual(float  a, float  b) {return a != b;}\n"
                "bool2 notEqual(float2 a, float2 b) {return a != b;}\n"
                "bool3 notEqual(float3 a, float3 b) {return a != b;}\n"
                "bool4 notEqual(float4 a, float4 b) {return a != b;}\n"
                );
    
    lib->insert(EOpGreaterThan,
    "bool  greaterThan(float  a, float  b) {return a > b;}\n"
    "bool2 greaterThan(float2 a, float2 b) {return a > b;}\n"
    "bool3 greaterThan(float3 a, float3 b) {return a > b;}\n"
    "bool4 greaterThan(float4 a, float4 b) {return a > b;}\n"
                );
    
    lib->insert(EOpLessThan,
    "bool  lessThan(float  a, float  b) {return a < b;}\n"
    "bool2 lessThan(float2 a, float2 b) {return a < b;}\n"
    "bool3 lessThan(float3 a, float3 b) {return a < b;}\n"
    "bool4 lessThan(float4 a, float4 b) {return a < b;}\n"
                );
    lib->insert(EOpGreaterThanEqual,
    "bool  greaterThanEqual(float  a, float  b) {return a >= b;}\n"
    "bool2 greaterThanEqual(float2 a, float2 b) {return a >= b;}\n"
    "bool3 greaterThanEqual(float3 a, float3 b) {return a >= b;}\n"
    "bool4 greaterThanEqual(float4 a, float4 b) {return a >= b;}\n"
                );
    lib->insert(EOpLessThanEqual,
    "bool  lessThanEqual(float  a, float  b) {return a <= b;}\n"
    "bool2 lessThanEqual(float2 a, float2 b) {return a <= b;}\n"
    "bool3 lessThanEqual(float3 a, float3 b) {return a <= b;}\n"
    "bool4 lessThanEqual(float4 a, float4 b) {return a <= b;}\n"
                );
    
	// \todo [pyry] Built-in function exists in GLSL ES 3
	lib->insert(EOpRound,
		"float xll_round_f (float x) { return floor (x+0.5); }\n"
		"float2 xll_round_vf2 (float2 x) { return floor (x+float2(0.5)); }\n"
		"float3 xll_round_vf3 (float3 x) { return floor (x+float3(0.5)); }\n"
		"float4 xll_round(float4 x) { return floor (x+float4(0.5)); }\n"
	);

	// \todo [pyry] Built-in function exists in GLSL ES 3
	lib->insert(EOpTrunc,
		"float xll_trunc(float x) { return x < 0.0 ? -floor(-x) : floor(x); }\n"
		"float2 xll_trunc(float2 v) { return float2(\n"
		"  v.x < 0.0 ? -floor(-v.x) : floor(v.x),\n"
		"  v.y < 0.0 ? -floor(-v.y) : floor(v.y)\n"
		"); }\n"
		"float3 xll_trunc(float3 v) { return float3(\n"
		"  v.x < 0.0 ? -floor(-v.x) : floor(v.x),\n"
		"  v.y < 0.0 ? -floor(-v.y) : floor(v.y),\n"
		"  v.z < 0.0 ? -floor(-v.z) : floor(v.z)\n"
		"); }\n"
		"float4 xll_trunc(float4 v) { return float4(\n"
		"  v.x < 0.0 ? -floor(-v.x) : floor(v.x),\n"
		"  v.y < 0.0 ? -floor(-v.y) : floor(v.y),\n"
		"  v.z < 0.0 ? -floor(-v.z) : floor(v.z),\n"
		"  v.w < 0.0 ? -floor(-v.w) : floor(v.w)\n"
		"); }\n"
	);

	// \todo [pyry] Built-in function exists in GLSL ES 3
   lib->insert(EOpLdexp,
        "float xll_ldexp( float x, float expon) {\n"
        "  return x * exp2 ( expon );\n"
        "}\n\n"
        "float2 xll_ldexp( float2 x, float2 expon) {\n"
        "  return x * exp2 ( expon );\n"
        "}\n\n"
        "float3 xll_ldexp( float3 x, float3 expon) {\n"
        "  return x * exp2 ( expon );\n"
        "}\n\n"
        "float4 xll_ldexp( float4 x, float4 expon) {\n"
        "  return x * exp2 ( expon );\n"
        "}\n\n"
        "float2x2 xll_ldexp( float2x2 x, float2x2 expon) {\n"
        "  return x * float2x2( exp2 ( expon[0] ), exp2 ( expon[1] ) );\n"
        "}\n\n"
        "float3x3 xll_ldexp(float3x3 x, float3x3 expon) {\n"
        "  return x * float3x3( exp2 ( expon[0] ), exp2 ( expon[1] ), exp2 ( expon[2] ) );\n"
        "}\n\n"
        "float4x4 xll_ldexp(float4x4 x, float4x4 expon) {\n"
        "  return x * float4x4( exp2 ( expon[0] ), exp2 ( expon[1] ), exp2 ( expon[2] ), exp2 ( expon[3] ) );\n"
        "}\n\n"
        );

	// \todo [pyry] Built-in function exists in GLSL ES 3
/*
    lib->insert(EOpSinCos,
        "void xll_sincos_f_f_f( float x, float &s, float &c) {\n"
        "  s = sin(x); \n"
        "  c = cos(x); \n"
        "}\n\n"
        "void xll_sincos_vf2_vf2_vf2( float2 x, float2 &s, float2 &c) {\n"
        "  s = sin(x); \n"
        "  c = cos(x); \n"
        "}\n\n"
        "void xll_sincos_vf3_vf3_vf3( float3 x, float3 s, float3 &c) {\n"
        "  s = sin(x); \n"
        "  c = cos(x); \n"
        "}\n\n"
        "void xll_sincos_vf4_vf4_vf4( float4 x,  float4 &s, float4 &c) {\n"
        "  s = sin(x); \n"
        "  c = cos(x); \n"
        "}\n\n"
        "void xll_sincos( float2x2 x, float2x2 &s, float2x2 &c) {\n"
        "  s = float2x2( sin ( x[0] ), sin ( x[1] ) ); \n"
        "  c = float2x2( cos ( x[0] ), cos ( x[1] ) ); \n"
        "}\n\n"
        "void xll_sincos(float3x3 x, float3x3 &s, float3x3 &c) {\n"
        "  s = float3x3( sin ( x[0] ), sin ( x[1] ), sin ( x[2] ) ); \n"
        "  c = float3x3( cos ( x[0] ), cos ( x[1] ), cos ( x[2] ) ); \n"
        "}\n\n"
        "void xll_sincos(float4x4 x, float4x4 &s, float4x4 &c) {\n"
        "  s = float4x4( sin ( x[0] ), sin ( x[1] ), sin ( x[2] ), sin ( x[3] ) ); \n"
        "  c = float4x4( cos ( x[0] ), cos ( x[1] ), cos ( x[2] ), cos ( x[3] ) ); \n"
        "}\n\n"
        );
 */

//   lib->insert(EOpLog10,
//        "float xll_log10( float x ) {\n"
//        "  return log2 ( x ) / 3.32192809; \n"
//        "}\n\n"
//        "float2 xll_log10( float2 x ) {\n"
//        "  return log2 ( x ) / float2 ( 3.32192809 ); \n"
//        "}\n\n"
//        "float3 xll_log10( float3 x ) {\n"
//        "  return log2 ( x ) / float3 ( 3.32192809 ); \n"
//        "}\n\n"
//        "float4 xll_log10( float4 x ) {\n"
//        "  return log2 ( x ) / float4 ( 3.32192809 ); \n"
//        "}\n\n"
//        "float2x2 xll_log10(float2x2 m) {\n"
//        "  return float2x2( xll_log10_vf2(m[0]), xll_log10_vf2(m[1]));\n"
//        "}\n\n"
//        "float3x3 xll_log10(float3x3 m) {\n"
//        "  return float3x3( xll_log10_vf3(m[0]), xll_log10_vf3(m[1]), xll_log10_vf3(m[2]));\n"
//        "}\n\n"
//        "float4x4 xll_log10(float4x4 m) {\n"
//        "  return float4x4( xll_log10_vf4(m[0]), xll_log10_vf4(m[1]), xll_log10_vf4(m[2]), xll_log10_vf4(m[3]));\n"
//        "}\n\n"
//        );

    lib->insert(EOpLog10,
                "float xll_log10( float x ) {\n"
                "  return log10 ( x ); \n"
                "}\n\n"
                "float2 xll_log10( float2 x ) {\n"
                "  return log10 ( x ); \n"
                "}\n\n"
                "float3 xll_log10( float3 x ) {\n"
                "  return log10 ( x ); \n"
                "}\n\n"
                "float4 xll_log10( float4 x ) {\n"
                "  return log10 ( x ); \n"
                "}\n\n"
                "float2x2 xll_log10(float2x2 m) {\n"
                "  return float2x2( log10(m[0]), log10(m[1]));\n"
                "}\n\n"
                "float3x3 xll_log10(float3x3 m) {\n"
                "  return float3x3( log10(m[0]), log10(m[1]), log10(m[2]));\n"
                "}\n\n"
                "float4x4 xll_log10(float4x4 m) {\n"
                "  return float4x4( log10(m[0]), log10(m[1]), log10(m[2]), log10(m[3]));\n"
                "}\n\n"
                );

    
   lib->insert(EOpMix,
        "float2x2 xll_mix( float2x2 x, float2x2 y, float2x2 s ) {\n"
        "  return float2x2( mix(x[0],y[0],s[0]), mix(x[1],y[1],s[1]) ); \n"
        "}\n\n"
        "float3x3 xll_mix( float3x3 x, float3x3 y, float3x3 s ) {\n"
        "  return float3x3( mix(x[0],y[0],s[0]), mix(x[1],y[1],s[1]), mix(x[2],y[2],s[2]) ); \n"
        "}\n\n"
        "float4x4 xll_mix( float4x4 x, float4x4 y, float4x4 s ) {\n"
        "  return float4x4( mix(x[0],y[0],s[0]), mix(x[1],y[1],s[1]), mix(x[2],y[2],s[2]), mix(x[3],y[3],s[3]) ); \n"
        "}\n\n"
        );

   lib->insert(EOpLit,
        "float4 xll_lit( float n_dot_l, float n_dot_h, float m ) {\n"
        "   return float4(1, max(0.0, n_dot_l), pow(max(0.0, n_dot_h) * step(0.0, n_dot_l), m), 1.0);\n"
        "}\n\n"
        );

   lib->insert(EOpSmoothStep,
        "float2x2 xll_smoothstep( float2x2 x, float2x2 y, float2x2 s ) {\n"
        "  return float2x2( smoothstep(x[0],y[0],s[0]), smoothstep(x[1],y[1],s[1]) ); \n"
        "}\n\n"
        "float3x3 xll_smoothstep( float3x3 x, float3x3 y, float3x3 s ) {\n"
        "  return float3x3( smoothstep(x[0],y[0],s[0]), smoothstep(x[1],y[1],s[1]), smoothstep(x[2],y[2],s[2]) ); \n"
        "}\n\n"
        "float4x4 xll_smoothstep( float4x4 x, float4x4 y, float4x4 s ) {\n"
        "  return float4x4( smoothstep(x[0],y[0],s[0]), smoothstep(x[1],y[1],s[1]), smoothstep(x[2],y[2],s[2]), smoothstep(x[3],y[3],s[3]) ); \n"
        "}\n\n"
        );

   lib->insert(EOpClamp,
        "float2x2 xll_clamp( float2x2 x, float2x2 y, float2x2 s ) {\n"
        "  return float2x2( clamp(x[0],y[0],s[0]), clamp(x[1],y[1],s[1]) ); \n"
        "}\n\n"
        "float3x3 xll_clamp( float3x3 x, float3x3 y, float3x3 s ) {\n"
        "  return float3x3( clamp(x[0],y[0],s[0]), clamp(x[1],y[1],s[1]), clamp(x[2],y[2],s[2]) ); \n"
        "}\n\n"
        "float4x4 xll_clamp( float4x4 x, float4x4 y, float4x4 s ) {\n"
        "  return float4x4( clamp(x[0],y[0],s[0]), clamp(x[1],y[1],s[1]), clamp(x[2],y[2],s[2]), clamp(x[3],y[3],s[3]) ); \n"
        "}\n\n"
        );

   lib->insert(EOpStep,
      "float2x2 xll_step(float2x2 m, float2x2 y) {\n"
      "  return float2x2( step(m[0],y[0]), step(m[1],y[1]));\n"
      "}\n\n"
      "float3x3 xll_step(float3x3 m, float3x3 y) {\n"
      "  return float3x3( step(m[0],y[0]), step(m[1],y[1]), step(m[2],y[2]));\n"
      "}\n\n"
      "float4x4 xll_step(float4x4 m, float4x4 y) {\n"
      "  return float4x4( step(m[0],y[0]), step(m[1],y[1]), step(m[2],y[2]), step(m[3],y[3]));\n"
      "}\n\n"
      );
    
    lib->insert(EOpSub,
                                                "inline float2x2 operator-(float2x2 a, float b) {return float2x2( a[0] - b, a[1] - b);}\n"
                           
                           );

    
   //ACS: if we're post-1.20 use the newer, non-deprecated, texture lookups
//   if(usePost120TextureLookups) {
//       insertPost120TextureLookups(lib);
//   }
//   else {
//       insertPre130TextureLookups(lib);
//   }
//
//   lib->insert(EOpD3DCOLORtoUBYTE4,
//        "ivec4 xll_D3DCOLORtoUBYTE4(float4 x) {\n"
//        "  return ivec4 ( x.zyxw * 255.001953 );\n"
//        "}\n\n"
//        );
//
	lib->insert(EOpVecTernarySel,
		"float2 xll_vecTSel_vb2_vf2_vf2 (bool2 a, float2 b, float2 c) {\n"
		"  return float2 (a.x ? b.x : c.x, a.y ? b.y : c.y);\n"
		"}\n"
		"float3 xll_vecTSel_vb3_vf3_vf3 (bool3 a, float3 b, float3 c) {\n"
		"  return float3 (a.x ? b.x : c.x, a.y ? b.y : c.y, a.z ? b.z : c.z);\n"
		"}\n"
		"float4 xll_vecTSel_vb4_vf4_vf4 (bool4 a, float4 b, float4 c) {\n"
		"  return float4 (a.x ? b.x : c.x, a.y ? b.y : c.y, a.z ? b.z : c.z, a.w ? b.w : c.w);\n"
		"}\n\n"
		
   );
    return lib;
}

    
}
}
