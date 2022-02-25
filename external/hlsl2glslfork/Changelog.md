hlsl2glsl Change Log
=========================


2016 10
-------

Fixes:

* Fixed a bug where an inout struct argument with COLOR semantic member, in some unrelated place,
  would wrongly translate to framebuffer fetch extension in the GLES2/GLES3 fragment shader.


2016 06
-------

Fixes:

* Fixed overload resolution rules to match HLSL, not Cg. E.g. before a,
`max(0, someFloat2)` was effectively doing a `max(0, someFloat2.x)` since it followed
Cg's "in case of ambiguity, use first argument type" rule. HLSL uses wider argument,
so we do that now.


2015 11
-------

Fixes:

* Fixed translation of shaders where HLSL semantic is added to whole struct of input/output data.

2015 08
-------

Goodies:

* register specifiers for samplers are supported, and can be queried in ShUniformInfo::registerSpec.
* Texture 2D array support: use `sampler2DArray` variables and `tex2DArray(sampler2DArray,float3)`,
  `tex2DArraybias(sampler2DArray,float4)`, `tex2DArraylod(sampler2DArray,float4)` functions to sample.

Fixes:

* Fixed a case where code such as functionCall(tex2D(tex,uv)) would fail to compile.
* Fixed parser/lexer compilation on modern Bison/Flex versions.

2015 06
-------

Fixes:

* Fixed SV_Position semantic to be recognized just like POSITION.
* Fixed SV_Target[n] semantic to be recognized just like COLOR[n].
* Fixed unknown/wrong pixel shader output semantics to not generate bogus GLSL, but to give proper errors instead.

2015 04
-------

Goodies:

* uint .. uint4 types can be parsed (they are turned into signed integers in GLSL though).
* SV_InstanceID translates properly to GLES2.0 (EXT_draw_instanced) and GLES3.0.

Fixes:

* Fixed HLSL log10.


2015 01
-------

Fixes:

* Float literals are printed with 7 significant digits now.


2014 10
-------

Fixes:

* Preprocessor now accepts block comments followed by preprocessor directive on the same line (valid in HLSL).
* Zero-initialization of structs with nested structs now works.


2014 09
-------

Goodies:

* Support for #include processing; pass in a non-NULL Hlsl2Glsl_ParseCallbacks to Hlsl2Glsl_Parse to get it.
  You need to provide a function that finds & reads a file given a name. Which folders to search etc. are all
  your responsibility.
* Support for MRT (output of COLOR1..COLOR3 from pixel shader) on GLES2.0 via GL_EXT_draw_buffers.

Changes:

* Hlsl2Glsl_Parse got a new argument for #include callbacks; pass NULL for old behavior (no #includes).

Fixes:

* VFACE now translates to +1 or -1, i.e. (gl_FrontFacing?1.0:-1.0).
* Fixed faceforward().


2014 08
-------

Goodies:

* Support for GL_EXT_shader_framebuffer_fetch. Use COLORn pixel shader semantic, and "inout"
  modifier. This will be translated to framebuffer fetch extension on GLES 2 & 3.

Changes:

* Removed Hlsl2Glsl_UseUserVaryings; it is always "true" now.


2014 06
-------

Fixes/Changes:

* Replaced old preprocessor with a Mojoshader-based one.
	* Fixes a bunch of token pasting cases (e.g. `a.##b` or `a##b##c` was not working).
	* Fixes a bunch of macro argument cases (e.g. passing `a.b` as argument was turned into just `a`).
	* Properly reports errors when undefining or redefining `__FILE__` / `__LINE__`.

2014 04
-------

Fixes:

* Fixed wrong translation of clip() with vector arguments.

2014 02
-------

Fixes:

* Fixed wrong translation of 2x2 and 3x3 matrix initializers from a scalar (e.g. float3x3 m = 0.0).

2013 11
-------

Fixes:

* Fixes to some global variable initializers.

2013 09
-------

Fixes:

* Avoid producing variable names with double underscores.
* "const static", "static const" qualifiers work now; as well as "static" and "const" on function return values.
* Fixed PSIZE semantic translation.


Earlier stuff
-------------

* Made it build with VS2010 on Windows and XCode 3.2 on Mac. Build as static library.
* Feature to produce OpenGL ES-like precision specifiers (fixed/half/float -> lowp/mediump/highp)
* Fixes to ternary vector selection (float4 ? float4 : float4)
* Fixes to bool->float promotion in arithmetic ops
* Fixes to matrix constructors & indexing (GLSL is transposed in regards to HLSL)
* Support clip()
* Support Cg-like samplerRECT, texRECT, texRECTproj
* Support VPOS and VFACE semantics
* Fix various crashes & infinite loops, mostly on shaders with errors
* Cleaner and more deterministic generated GLSL output
* Unit testing suite
* Simplified interface, code cleanup, unused code removal, merge copy-n-pasted code, simplify implementation etc.
* Added support for emission of const initializers (including struct and array initializers using GLSL 1.20 array syntax).
* Removed all constant folding functionality as it was completely broken.
* A myriad of smaller bug fixes.
* Support DX10 SV_VertexID, SV_PrimitiveID and SV_InstanceID semantics.
* Support for shadow sampler types (samplerRECTShadow/sampler2DShadow etc.) which generate appropriate shadow2DRect/shadow2D etc. calls.
* Fixed unaligned swizzled matrix access & assignments (view._m01_m02_m33 = value)
