#define _CRT_SECURE_NO_WARNINGS
#include <cstdio>
#include <string>
#include <vector>
#include <time.h>
#include <assert.h>

#define USE_REAL_OPENGL_TO_CHECK 1

static const bool kDumpShaderAST = false;


#ifdef _MSC_VER
#include <windows.h>
#include <gl/GL.h>
#include <cstdarg>

extern "C" {
typedef char GLchar;		/* native character */
#define GL_VERTEX_SHADER              0x8B31
#define GL_FRAGMENT_SHADER            0x8B30
#define GL_COMPILE_STATUS      0x8B81
typedef void (WINAPI * PFNGLDELETESHADERPROC) (GLuint obj);
typedef GLuint (WINAPI * PFNGLCREATESHADERPROC) (GLenum shaderType);
typedef void (WINAPI * PFNGLSHADERSOURCEPROC) (GLuint shaderObj, GLsizei count, const GLchar* *string, const GLint *length);
typedef void (WINAPI * PFNGLCOMPILESHADERPROC) (GLuint shaderObj);
typedef void (WINAPI * PFNGLGETSHADERINFOLOGPROC) (GLuint obj, GLsizei maxLength, GLsizei *length, GLchar *infoLog);
typedef void (WINAPI * PFNGLGETSHADERIVPROC) (GLuint obj, GLenum pname, GLint *params);
static PFNGLDELETESHADERPROC glDeleteShader;
static PFNGLCREATESHADERPROC glCreateShader;
static PFNGLSHADERSOURCEPROC glShaderSource;
static PFNGLCOMPILESHADERPROC glCompileShader;
static PFNGLGETSHADERINFOLOGPROC glGetShaderInfoLog;
static PFNGLGETSHADERIVPROC glGetShaderiv;
}

// forks stdio to debug console so when you hit a breakpoint you can more easily see what test is running:
static void logf(const char* format, ...)
{
    va_list args = NULL;
    va_start(args, format);
    vprintf(format, args);
    va_end(args); //lint !e1924: C-style cast
    
    char buffer[4096];
    const size_t bufferSize = sizeof(buffer) - 1;

    args = NULL;
    va_start(args, format);
    int rc = _vsnprintf(buffer, bufferSize, format, args);
    va_end(args); //lint !e1924: C-style cast
    
    size_t outputLen = (rc <= 0) ? 0 : static_cast<size_t>(rc);
    buffer[outputLen] = '\0';

    OutputDebugStringA(buffer);
}

#define printf logf
#define snprintf _snprintf


#elif defined(__APPLE__)

#include <OpenGL/OpenGL.h>
#include <OpenGL/gl.h>
#include <OpenGL/CGLTypes.h>
#include <dirent.h>
#include <unistd.h>

#else

#include <unistd.h>
#include <stdlib.h>
#include <dirent.h>
#include <string.h>
#include <GL/glew.h>
#include <GL/glut.h>

#endif
#include "../../include/hlsl2glsl.h"

static void replace_string (std::string& target, const std::string& search, const std::string& replace, size_t startPos);


bool EndsWith (const std::string& str, const std::string& sub)
{
	return (str.size() >= sub.size()) && (strncmp (str.c_str()+str.size()-sub.size(), sub.c_str(), sub.size())==0);
}


typedef std::vector<std::string> StringVector;

static StringVector GetFiles (const std::string& folder, const std::string& endsWith)
{
	StringVector res;

	#ifdef _MSC_VER
	WIN32_FIND_DATAA FindFileData;
	HANDLE hFind = FindFirstFileA ((folder+"/*"+endsWith).c_str(), &FindFileData);
	if (hFind == INVALID_HANDLE_VALUE)
		return res;

	do {
		res.push_back (FindFileData.cFileName);
	} while (FindNextFileA (hFind, &FindFileData));

	FindClose (hFind);
	
	#else
	
	DIR *dirp;
	struct dirent *dp;

	if ((dirp = opendir(folder.c_str())) == NULL)
		return res;

	while ( (dp = readdir(dirp)) )
	{
		std::string fname = dp->d_name;
		if (fname == "." || fname == "..")
			continue;
		if (!EndsWith (fname, endsWith))
			continue;
		res.push_back (fname);
	}
	closedir(dirp);
	
	#endif

	return res;
}

static void DeleteFile (const std::string& path)
{
	#ifdef _MSC_VER
	DeleteFileA (path.c_str());
	#else
	unlink (path.c_str());
	#endif
}

static bool ReadStringFromFile (const char* pathName, std::string& output)
{
#	ifdef _MSC_VER
	wchar_t widePath[MAX_PATH];
	int res = ::MultiByteToWideChar (CP_UTF8, 0, pathName, -1, widePath, MAX_PATH);
	if (res == 0)
		widePath[0] = 0;
	FILE* file = _wfopen(widePath, L"rb");
#	else // ifdef _MSC_VER
	FILE* file = fopen(pathName, "rb");
#	endif // !ifdef _MSC_VER

	if (file == NULL)
		return false;
	
	fseek(file, 0, SEEK_END);
	long length = ftell(file);
	fseek(file, 0, SEEK_SET);
	if (length < 0)
	{
		fclose( file );
		return false;
	}
	
	output.resize(length);
	size_t readLength = fread(&*output.begin(), 1, length, file);
	
	fclose(file);
	
	if (readLength != length)
	{
		output.clear();
		return false;
	}

	replace_string(output, "\r\n", "\n", 0);
	
	return true;
}


#if defined(__APPLE__)
static CGLContextObj s_GLContext;
static CGLContextObj s_GLContext3;
static bool s_GL3Active = false;
#endif


static bool InitializeOpenGL ()
{
	#if !USE_REAL_OPENGL_TO_CHECK
	return false;
	#endif
	
	bool hasGLSL = false;

#ifdef _MSC_VER
	// setup minimal required GL
	HWND wnd = CreateWindowA(
		"STATIC",
		"GL",
		WS_OVERLAPPEDWINDOW | WS_CLIPSIBLINGS |	WS_CLIPCHILDREN,
		0, 0, 16, 16,
		NULL, NULL,
		GetModuleHandle(NULL), NULL );
	HDC dc = GetDC( wnd );

	PIXELFORMATDESCRIPTOR pfd = {
		sizeof(PIXELFORMATDESCRIPTOR), 1,
		PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL,
		PFD_TYPE_RGBA, 32,
		0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0,
		16, 0,
		0, PFD_MAIN_PLANE, 0, 0, 0, 0
	};

	int fmt = ChoosePixelFormat( dc, &pfd );
	SetPixelFormat( dc, fmt, &pfd );

	HGLRC rc = wglCreateContext( dc );
	wglMakeCurrent( dc, rc );

#elif defined(__APPLE__)
	CGLPixelFormatAttribute attributes[] = {
		kCGLPFAAccelerated,   // no software rendering
		(CGLPixelFormatAttribute) 0
	};
	CGLPixelFormatAttribute attributes3[] = {
		kCGLPFAAccelerated,   // no software rendering
		kCGLPFAOpenGLProfile, // core profile with the version stated below
		(CGLPixelFormatAttribute) kCGLOGLPVersion_3_2_Core,
		(CGLPixelFormatAttribute) 0
	};
	GLint num;
	CGLPixelFormatObj pix;
	
	// create legacy context
	CGLChoosePixelFormat(attributes, &pix, &num);
	if (pix == NULL)
		return false;
	CGLCreateContext(pix, NULL, &s_GLContext);
	if (s_GLContext == NULL)
		return false;
	CGLDestroyPixelFormat(pix);
	CGLSetCurrentContext(s_GLContext);
	
	// create core 3.2 context
	CGLChoosePixelFormat(attributes3, &pix, &num);
	if (pix == NULL)
		return false;
	CGLCreateContext(pix, NULL, &s_GLContext3);
	if (s_GLContext3 == NULL)
		return false;
	CGLDestroyPixelFormat(pix);
	
#else
        int argc = 0;
        char** argv = NULL;
        glutInit(&argc, argv);
        glutCreateWindow("hlsl2glsltest");
        glewInit();
#endif
	
	// check if we have GLSL
	const char* extensions = (const char*)glGetString(GL_EXTENSIONS);
	hasGLSL = extensions != NULL && strstr(extensions, "GL_ARB_shader_objects") && strstr(extensions, "GL_ARB_vertex_shader") && strstr(extensions, "GL_ARB_fragment_shader");
	
	#if defined(__APPLE__)
	// using core profile; always has GLSL
	hasGLSL = true;
	#endif
	
	
#ifdef _MSC_VER
	if (hasGLSL)
	{
		glDeleteShader = (PFNGLDELETESHADERPROC)wglGetProcAddress("glDeleteShader");
		glCreateShader = (PFNGLCREATESHADERPROC)wglGetProcAddress("glCreateShader");
		glShaderSource = (PFNGLSHADERSOURCEPROC)wglGetProcAddress("glShaderSource");
		glCompileShader = (PFNGLCOMPILESHADERPROC)wglGetProcAddress("glCompileShader");
		glGetShaderInfoLog = (PFNGLGETSHADERINFOLOGPROC)wglGetProcAddress("glGetShaderInfoLog");
		glGetShaderiv = (PFNGLGETSHADERIVPROC)wglGetProcAddress("glGetShaderiv");
	}
#endif
	
	#ifdef _MSC_VER	
	ReleaseDC(wnd, dc);
	#endif
	return hasGLSL;
}

static void CleanupOpenGL()
{
	#if defined(__APPLE__)
	CGLSetCurrentContext(NULL);
	if (s_GLContext)
		CGLDestroyContext(s_GLContext);
	if (s_GLContext3)
		CGLDestroyContext(s_GLContext3);
	#endif
}


static void replace_string (std::string& target, const std::string& search, const std::string& replace, size_t startPos)
{
	if (search.empty())
		return;
	
	std::string::size_type p = startPos;
	while ((p = target.find (search, p)) != std::string::npos)
	{
		target.replace (p, search.size (), replace);
		p += replace.size ();
	}
}


static bool CheckGLSL (bool vertex, ETargetVersion version, const std::string& source)
{
	const char* sourcePtr = source.c_str();
	std::string newSrc;

	
#	ifdef __APPLE__
	// Mac core context does not accept any older shader versions, so need to switch to
	// either legacy context or core one.
	const bool need3 = (version >= ETargetGLSL_ES_300);
	if (need3)
	{
		if (!s_GL3Active)
			CGLSetCurrentContext(s_GLContext3);
		s_GL3Active = true;
	}
	else
	{
		if (s_GL3Active)
			CGLSetCurrentContext(s_GLContext);
		s_GL3Active = false;
	}
#	endif
	
	
	if (version == ETargetGLSL_ES_100 || version == ETargetGLSL_ES_300)
	{
		newSrc.reserve(source.size());
		if (version == ETargetGLSL_ES_300)
		{
			newSrc += "#version 150\n";
		}
		newSrc += "#define lowp\n";
		newSrc += "#define mediump\n";
		newSrc += "#define highp\n";
		if (version == ETargetGLSL_ES_300)
		{
			newSrc += "#define gl_Vertex _glesVertex\n";
			newSrc += "#define gl_Normal _glesNormal\n";
			newSrc += "#define gl_Color _glesColor\n";
			newSrc += "#define gl_MultiTexCoord0 _glesMultiTexCoord0\n";
			newSrc += "#define gl_MultiTexCoord1 _glesMultiTexCoord1\n";
			newSrc += "#define gl_MultiTexCoord2 _glesMultiTexCoord2\n";
			newSrc += "#define gl_MultiTexCoord3 _glesMultiTexCoord3\n";
			newSrc += "in highp vec4 _glesVertex;\n";
			newSrc += "in highp vec3 _glesNormal;\n";
			newSrc += "in lowp vec4 _glesColor;\n";
			newSrc += "in highp vec4 _glesMultiTexCoord0;\n";
			newSrc += "in highp vec4 _glesMultiTexCoord1;\n";
			newSrc += "in highp vec4 _glesMultiTexCoord2;\n";
			newSrc += "in highp vec4 _glesMultiTexCoord3;\n";
			newSrc += "#define gl_FragData _glesFragData\n";
			newSrc += "out lowp vec4 _glesFragData[4];\n";
		}
		if (version < ETargetGLSL_ES_300)
		{
			newSrc += "#define texture2DLodEXT texture2DLod\n";
			newSrc += "#define texture2DProjLodEXT texture2DProjLod\n";
			newSrc += "#define texture2DGradEXT texture2DGradARB\n";
			newSrc += "#define textureCubeLodEXT textureCubeLod\n";
			newSrc += "#define textureCubeGradEXT textureCubeGradARB\n";
			newSrc += "#define gl_FragDepthEXT gl_FragDepth\n";
			newSrc += "#define gl_LastFragData _glesLastFragData\n";
			newSrc += "varying lowp vec4 _glesLastFragData[4];\n";
			newSrc += "float shadow2DEXT (sampler2DShadow s, vec3 p) { return shadow2D(s,p).r; }\n";
			newSrc += "float shadow2DProjEXT (sampler2DShadow s, vec4 p) { return shadow2DProj(s,p).r; }\n";
			newSrc += "#define sampler2DArrayNV sampler2DArray\n";
			newSrc += "#define texture2DArrayNV texture2DArray\n";
			newSrc += "#define texture2DArrayLodNV texture2DArrayLod\n";
		}
		newSrc += source;
		replace_string (newSrc, "GL_EXT_shader_texture_lod", "GL_ARB_shader_texture_lod", 0);
		replace_string (newSrc, "#extension GL_OES_standard_derivatives : require", "", 0);
		replace_string (newSrc, "#extension GL_EXT_shadow_samplers : require", "", 0);
		replace_string (newSrc, "#extension GL_EXT_frag_depth : require", "", 0);
		replace_string (newSrc, "#extension GL_EXT_shader_framebuffer_fetch : require", "", 0);
		replace_string (newSrc, "#extension GL_EXT_draw_buffers : require", "", 0);
		replace_string (newSrc, "GL_EXT_draw_instanced", "GL_ARB_draw_instanced", 0);
		replace_string (newSrc, "GL_NV_texture_array", "GL_EXT_texture_array", 0);
		replace_string (newSrc, "gl_InstanceIDEXT", "gl_InstanceIDARB", 0);
		
		sourcePtr = newSrc.c_str();
	}
	
	GLuint shader = glCreateShader (vertex ? GL_VERTEX_SHADER : GL_FRAGMENT_SHADER);
	glShaderSource (shader, 1, &sourcePtr, NULL);
	glCompileShader (shader);
	GLint status;
	glGetShaderiv (shader, GL_COMPILE_STATUS, &status);
	bool res = true;
	if (status == 0)
	{
		char log[4096];
		GLsizei logLength;
		glGetShaderInfoLog (shader, sizeof(log), &logLength, log);
		printf ("  glsl compile error:\n%s\n", log);
		res = false;
	}
	glDeleteShader (shader);
	GLenum err = glGetError();
	if (err != GL_NO_ERROR)
	{
		printf("  GL error: 0x%x\n", err);
		res = false;
	}
	return res;
}

enum TestRun {
	VERTEX,
	FRAGMENT,
	BOTH,
	VERTEX_120,
	FRAGMENT_120,
	VERTEX_FAILURES,
	FRAGMENT_FAILURES,
	NUM_RUN_TYPES
};

const bool kIsVertexShader[NUM_RUN_TYPES] = {
	true,
	false,
	false,
	true,
	false,
	true,
	false,
};

static const char* kTypeName[NUM_RUN_TYPES] = {
	"vertex",
	"fragment",
	"combined",
	"vertex-120",
	"fragment-120",
	"vertex-failures",
	"fragment-failures",
};

static const EShLanguage kTypeLangs[NUM_RUN_TYPES] = {
	EShLangVertex,
	EShLangFragment,
	EShLangCount,
	EShLangVertex,
	EShLangFragment,
	EShLangVertex,
	EShLangFragment,
};

static const ETargetVersion kTargets1[NUM_RUN_TYPES] = {
	ETargetGLSL_110,
	ETargetGLSL_110,
	ETargetGLSL_120,
	ETargetGLSL_120,
	ETargetGLSL_120,
	ETargetGLSL_110,
	ETargetGLSL_110,
};
static const ETargetVersion kTargets2[NUM_RUN_TYPES] = {
	ETargetGLSL_ES_100,
	ETargetGLSL_ES_100,
	ETargetVersionCount,
	ETargetVersionCount,
	ETargetVersionCount,
	ETargetVersionCount,
	ETargetVersionCount,
};
static const ETargetVersion kTargets3[NUM_RUN_TYPES] = {
	ETargetGLSL_ES_300,
	ETargetGLSL_ES_300,
	ETargetVersionCount,
	ETargetGLSL_ES_300,
	ETargetGLSL_ES_300,
	ETargetVersionCount,
	ETargetVersionCount,
};


static std::string GetCompiledShaderText(ShHandle parser)
{
	std::string txt = Hlsl2Glsl_GetShader (parser);
	
	int count = Hlsl2Glsl_GetUniformCount (parser);
	if (count > 0)
	{
		const ShUniformInfo* uni = Hlsl2Glsl_GetUniformInfo(parser);
		txt += "\n// uniforms:\n";
		for (int i = 0; i < count; ++i)
		{
			char buf[1000];
			snprintf(buf,1000,"// %s:%s type %d arrsize %d", uni[i].name, uni[i].semantic?uni[i].semantic:"<none>", uni[i].type, uni[i].arraySize);
			txt += buf;

			if (uni[i].registerSpec)
			{
				txt += " register ";
				txt += uni[i].registerSpec;
			}

			txt += "\n";
		}
	}
	
	return txt;
}


struct IncludeContext
{
	std::string currentFolder;
};


static bool C_DECL IncludeOpenCallback(bool isSystem, const char* fname, const char* parentfname, const char* parent, std::string& output, void* d)
{
	const IncludeContext* data = reinterpret_cast<IncludeContext*>(d);
	
	std::string pathName = data->currentFolder + "/" + fname;
	
	return ReadStringFromFile(pathName.c_str(), output);
}


static bool TestFile (TestRun type,
					  const std::string& inputPath,
					  const std::string& outputPath,
					  const char* entryPoint,
					  ETargetVersion version,
					  unsigned options,
					  bool doCheckGLSL)
{
	assert(version != ETargetVersionCount);
	
	std::string input;
	if (!ReadStringFromFile (inputPath.c_str(), input))
	{
		printf ("  failed to read input file\n");
		return false;
	}
	
	ShHandle parser = Hlsl2Glsl_ConstructCompiler (kTypeLangs[type]);

	const char* sourceStr = input.c_str();

	bool res = true;

	if (kDumpShaderAST)
		options |= ETranslateOpIntermediate;
	
	IncludeContext includeCtx;
	includeCtx.currentFolder = inputPath.substr(0, inputPath.rfind('/'));
	Hlsl2Glsl_ParseCallbacks includeCB;
	includeCB.includeOpenCallback = IncludeOpenCallback;
	includeCB.includeCloseCallback = NULL;
	includeCB.data = &includeCtx;
		
	int parseOk = Hlsl2Glsl_Parse (parser, sourceStr, version, &includeCB, options);
	const char* infoLog = Hlsl2Glsl_GetInfoLog( parser );
	if (kDumpShaderAST)
	{
		// write output
		FILE* f = fopen ((outputPath+"-ir.txt").c_str(), "wb");
		fwrite (infoLog, 1, strlen(infoLog), f);
		fclose (f);
	}
	if (parseOk)
	{
		static EAttribSemantic kAttribSemantic[] = {
			EAttrSemTangent,
		};
		static const char* kAttribString[] = {
			"TANGENT",
		};
		Hlsl2Glsl_SetUserAttributeNames (parser, kAttribSemantic, kAttribString, 1);
		
		int translateOk = Hlsl2Glsl_Translate (parser, entryPoint, version, options);
		const char* infoLog = Hlsl2Glsl_GetInfoLog( parser );
		if (translateOk)
		{
			std::string text = GetCompiledShaderText(parser);
			
			for (size_t i = 0, n = text.size(); i != n; ++i)
			{
			   char c = text[i];
			   
			   if (!isascii(c))
			   {
				   printf ("  contains non-ascii '%c' (0x%02X)\n", c, c);
				   res = false;
			   }
			}

			std::string output;
			ReadStringFromFile (outputPath.c_str(), output);

			if (text != output)
			{
				// write output
				FILE* f = fopen (outputPath.c_str(), "wb");
				fwrite (text.c_str(), 1, text.size(), f);
				fclose (f);
				printf ("  does not match expected output\n");
				res = false;
			}
			if (doCheckGLSL && !CheckGLSL (kIsVertexShader[type], version, text))
			{
				res = false;
			}
		}
		else
		{
			printf ("  translate error: %s\n", infoLog);
			res = false;
		}
	}
	else
	{
		printf ("  parse error: %s\n", infoLog);
		res = false;
	}

	Hlsl2Glsl_DestructCompiler (parser);

	return res;
}


static bool TestFileFailure (TestRun type,
	const std::string& inputPath,
	const std::string& outputPath)
{
	std::string input;
	if (!ReadStringFromFile (inputPath.c_str(), input))
	{
		printf ("  failed to read input file\n");
		return false;
	}

	ShHandle parser = Hlsl2Glsl_ConstructCompiler (kTypeLangs[type]);
	const ETargetVersion version = kTargets1[type];

	const char* sourceStr = input.c_str();

	bool res = true;

	unsigned options = 0;
	if (kDumpShaderAST)
		options |= ETranslateOpIntermediate;
	int parseOk = Hlsl2Glsl_Parse (parser, sourceStr, version, NULL, options);
	
	if (parseOk)
	{
		int translateOk = Hlsl2Glsl_Translate (parser, "main", version, options);
		
		if (translateOk) 
		{
			printf ("  translation was expected to fail\n");
		    res = false;
		}
    }
    
	std::string text = Hlsl2Glsl_GetInfoLog( parser );
	if (!res)
	{
		text += "\n// compiled shader:\n";
		text += Hlsl2Glsl_GetShader (parser);
	}
	std::string output;
	
	if (res)
	{
	    ReadStringFromFile (outputPath.c_str(), output);
    }
    
	if (!res || (text != output))
	{
		// write output
		FILE* f = fopen (outputPath.c_str(), "wb");
		fwrite (text.c_str(), 1, text.size(), f);
		fclose (f);
		printf ("  does not match expected output\n");
		res = false;
	}

	Hlsl2Glsl_DestructCompiler (parser);

	return res;
}

static bool TestCombinedFile(const std::string& inputPath, ETargetVersion version, bool checkGL)
{
	std::string outname = inputPath.substr (0,inputPath.size()-7);
	std::string frag_out, vert_out;
	
	if (version == ETargetGLSL_ES_100) {
		vert_out = outname + "-vertex-outES.txt";
		frag_out = outname + "-fragment-outES.txt";
	} else {
		vert_out = outname + "-vertex-out.txt";
		frag_out = outname + "-fragment-out.txt";
	}
	
	bool res = TestFile(VERTEX, inputPath, vert_out, "vs_main", version, 0, checkGL);
	return res & TestFile(FRAGMENT, inputPath, frag_out, "ps_main", version, 0, checkGL);
}


static bool TestFile (TestRun type,
					  const std::string& inputPath,
					  ETargetVersion version,
					  unsigned options,
					  bool checkGL)
{
	std::string outname = inputPath.substr (0,inputPath.size()-7);

	const char* suffix = "-out.txt";
	if (version == ETargetGLSL_ES_100)
		suffix = "-outES.txt";
	else if (version == ETargetGLSL_ES_300)
		suffix = "-outES3.txt";
	else if (options & ETranslateOpEmitGLSL120ArrayInitWorkaround)
		suffix = "-out120arr.txt";
	
	if (type == VERTEX_FAILURES || type == FRAGMENT_FAILURES) {
		return TestFileFailure(type, inputPath, outname + suffix);
	} else {
		return TestFile(type, inputPath, outname + suffix, "main", version, options, checkGL);
	}
	return false;
}


int main (int argc, const char** argv)
{
	if (argc < 2)
	{
		printf ("USAGE: hlsl2glsltest testfolder\n");
		return 1;
	}

	bool hasOpenGL = InitializeOpenGL ();
	if (!hasOpenGL)
		printf("NOTE: will not check GLSL with actual driver (no GL/GLSL)\n");
	
	clock_t time0 = clock();
	
	Hlsl2Glsl_Initialize ();

	std::string baseFolder = argv[1];

	size_t tests = 0;
	size_t errors = 0;
	for (int type = 0; type < NUM_RUN_TYPES; ++type)
	{
		printf ("TESTING %s...\n", kTypeName[type]);
		const ETargetVersion version1 = kTargets1[type];
		const ETargetVersion version2 = kTargets2[type];
		const ETargetVersion version3 = kTargets3[type];
		std::string testFolder = baseFolder + "/" + kTypeName[type];
		StringVector inputFiles = GetFiles (testFolder, "-in.txt");

		size_t n = inputFiles.size();
		tests += n;
		for (size_t i = 0; i < n; ++i)
		{
			std::string inname = inputFiles[i];
			//if (inname != "_zzz-in.txt")
			//	continue;
			const bool preprocessorTest = (inname.find("pp-") == 0);
			bool ok = true;
			
			printf ("test %s\n", inname.c_str());
			if (type == BOTH) {
				ok = TestCombinedFile(testFolder + "/" + inname, version1, hasOpenGL);
				if (ok && version2 != ETargetVersionCount)
					ok = TestCombinedFile(testFolder + "/" + inname, version2, hasOpenGL);
			} else {
				ok = TestFile(TestRun(type), testFolder + "/" + inname, version1, 0, hasOpenGL);
				if (!preprocessorTest)
				{
					if (ok && version2 != ETargetVersionCount)
						ok = TestFile(TestRun(type), testFolder + "/" + inname, version2, ETranslateOpEmitGLSL120ArrayInitWorkaround, hasOpenGL);
					if (ok && version3 != ETargetVersionCount)
						ok = TestFile(TestRun(type), testFolder + "/" + inname, version3, 0, hasOpenGL);
				}
			}
			
			if (!ok)
				++errors;
		}		
	}

	clock_t time1 = clock();
	float t = float(time1-time0) / float(CLOCKS_PER_SEC);
	if (errors != 0)
		printf ("%i tests, %i FAILED, %.2fs\n", (int)tests, (int)errors, t);
	else
		printf ("%i tests succeeded, %.2fs\n", (int)tests, t);
	
	Hlsl2Glsl_Shutdown();
	CleanupOpenGL();

	return errors ? 1 : 0;
}
