// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "mslLinker.h"

#include "mslFunction.h"
#include "mslCrossCompiler.h"

#include "mslSupportLib.h"
#include "osinclude.h"
#include <algorithm>
#include <string.h>
#include <set>
#include <iostream>

namespace hlslang {
namespace MetalCodeGen {


//static const char* kTargetVersionStrings[ETargetVersionCount] = {
//    "", // ES 1.00
//    "", // 1.10
//    "#version 120\n", // 1.20
//    "#version 140\n", // 1.40
//    "", // ES 3.0 - #version 300 es is added later in shader build pipe
//    "", // Metal
//};

static const char *xlt_prefix = "xlt_x";

// String table that maps attribute semantics to built-in GLSL attributes
static const char* attribString[EAttrSemCount] = {
	"",
	"gl_Vertex",
	"",
	"",
	"",
	"",
	"",
	"gl_Normal",
	"",
	"",
	"",
	"gl_Color",
	"gl_SecondaryColor",
	"",
	"",
	"gl_MultiTexCoord0",
	"gl_MultiTexCoord1",
	"gl_MultiTexCoord2",
	"gl_MultiTexCoord3",
	"gl_MultiTexCoord4",
	"gl_MultiTexCoord5",
	"gl_MultiTexCoord6",
	"gl_MultiTexCoord7",
	"",
	"",
	"xlat_attrib_tangent",
	"",
	"",
	"",
	"xlat_attrib_binorm",
	"",
	"",
	"",
	"xlat_attrib_blendweights",
	"",
	"",
	"",
	"xlat_attrib_blendindices",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"gl_VertexID",
	"gl_InstanceIDARB",
	"",
	""
};

// String table that maps attribute semantics to built-in GLSL output varyings
//static const char* varOutString[EAttrSemCount] = {
//    "",
//    "gl_Position",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "gl_FrontColor",
//    "gl_FrontSecondaryColor",
//    "",
//    "",
//    "gl_TexCoord[0]",
//    "gl_TexCoord[1]",
//    "gl_TexCoord[2]",
//    "gl_TexCoord[3]",
//    "gl_TexCoord[4]",
//    "gl_TexCoord[5]",
//    "gl_TexCoord[6]",
//    "gl_TexCoord[7]",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "gl_PointSize",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//};

//
//// String table that maps attribute semantics to built-in GLSL input varyings
static const char* varInString[EAttrSemCount] = {
    "",
    "",
    "",
    "",
    "",
    "gl_FragCoord",
    "(gl_FrontFacing ? 1.0 : -1.0)",
    "",
    "",
    "",
    "",
    "gl_Color",
    "gl_SecondaryColor",
    "",
    "",
    "gl_TexCoord[0]",
    "gl_TexCoord[1]",
    "gl_TexCoord[2]",
    "gl_TexCoord[3]",
    "gl_TexCoord[4]",
    "gl_TexCoord[5]",
    "gl_TexCoord[6]",
    "gl_TexCoord[7]",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "gl_PrimitiveID",
    "",
};
//
//// String table that maps attribute semantics to built-in GLSL fragment shader outputs
//static const char* resultString[EAttrSemCount] = {
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "gl_FragData[0]",
//    "gl_FragData[1]",
//    "gl_FragData[2]",
//    "gl_FragData[3]",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "",
//    "gl_FragDepth",
//    "",
//    "",
//    "",
//    "",
//    "gl_SampleMask[0]",
//};

static const char* kUserVaryingPrefix = "";


static inline void AddVertexOutput (std::stringstream& s, ETargetVersion targetVersion, TPrecision prec, const std::string& type, const std::string& name)
{
	//if (strstr (name.c_str(), kUserVaryingPrefix) == name.c_str())
    if (name == "POSITION") {
        s << " " << type << " " << name << " " <<  "[[position]]"  <<";\n";
        return;
    }
    
		s << " " << type << " " << name << ";\n";
}

static inline void AddFragmentInput (std::stringstream& s, ETargetVersion targetVersion, TPrecision prec, const std::string& type, const std::string& name)
{
    if (name == "POSITION") {
        s << " " << type << " " << name << " " <<  "[[position]]"  <<";\n";
        return;
    }

//	if (strstr (name.c_str(), kUserVaryingPrefix) == name.c_str())
		s << " " << type << " " << name << ";\n";
}

static inline void AddToVaryings (std::stringstream& s, EShLanguage language, ETargetVersion targetVersion, TPrecision prec, const std::string& type, const std::string& name)
{
	if (language == EShLangVertex)
		AddVertexOutput(s, targetVersion, prec, type, name);
	else
		AddFragmentInput(s, targetVersion, prec, type, name);
}

static inline bool UsesBuiltinAttribStrings(ETargetVersion targetVersion, unsigned options)
{
	if (options & ETranslateOpAvoidBuiltinAttribNames)
		return false;
	if (options & ETranslateOpForceBuiltinAttribNames)
		return true;
	
	// Later non-ES targets should also return false for this.
	return (targetVersion == ETargetGLSL_ES_100
		 || targetVersion == ETargetGLSL_ES_300)
		 ? false
		 : true;
}


MslLinker::MslLinker(TInfoSink& infoSink_)
: infoSink(infoSink_)
, m_Target(ETargetVersionCount)
, m_Options(0)
{
	for ( int i = 0; i < EAttrSemCount; i++)
	{
		userAttribString[i][0] = 0;
	}
}


MslLinker::~MslLinker()
{
	for ( std::vector<ShUniformInfo>::iterator it = uniforms.begin(); it != uniforms.end(); it++)
	{
		delete [] it->name;
		delete [] it->semantic;
		delete [] it->registerSpec;
		delete [] it->init;
	}
}

static const char* get_builtin_variable_from_semantic(EAttribSemantic sem, ETargetVersion targetVersion)
{
	if (sem == EAttrSemInstanceID)
	{
		if (targetVersion == ETargetGLSL_ES_100)
			return "gl_InstanceIDEXT";
		if (targetVersion <= ETargetGLSL_140)
			return "gl_InstanceIDARB";
		return "gl_InstanceID";
	}
	if (sem == EAttrSemVertexID)
	{
		if (targetVersion != ETargetGLSL_ES_100)
			return "gl_VertexID";
	}
	return NULL;
}


void MslLinker::getAttributeName( MslSymbolOrStructMemberBase const* symOrStructMember, std::string &outName, EAttribSemantic sem, int semanticOffset )
{
	const char* builtinName = get_builtin_variable_from_semantic(sem, m_Target);
	if (builtinName && semanticOffset == -1)
	{
		outName = builtinName;
		return;
	}
	
	if (m_Options & ETranslateOpPropogateOriginalAttribNames && !UsesBuiltinAttribStrings(m_Target, m_Options))
	{
		MslSymbolOrStructMemberBase const* dominant =	 (symOrStructMember->outputSuppressedBy())
														? symOrStructMember->outputSuppressedBy()
														: symOrStructMember;
		outName = dominant->baseName+dominant->name;
		if ( semanticOffset > 0 )
			outName += ( semanticOffset + '0' );
	}
	else
	{
		if ( semanticOffset > 0 )
			sem = (EAttribSemantic)((int)sem+semanticOffset);
		// If the user has specified a user attrib name, use a user attribute
		if ( userAttribString[sem][0] != '\0' )
		{
			outName = userAttribString[sem];
		}
		// Otherwise, use the built-in attribute name
		else
		{
			outName = UsesBuiltinAttribStrings(m_Target, m_Options) ? attribString[sem] : "\0";
			if ( sem == EAttrSemUnknown || outName[0] == '\0' )
			{
				//handle the blind data
				//outName = "xlat_attrib_";
                outName = "";
				outName += symOrStructMember->semantic;
			}
		}
	}
}


//static bool IsArgumentForFramebufferFetch(const MslSymbolOrStructMemberBase* sym, EAttribSemantic semantic, ETargetVersion target)
//{
//    return
//        ((sym->getQualifier() == EqtInOut) &&
//         (semantic >= EAttrSemColor0 && semantic <= EAttrSemColor3) &&
//         (target == ETargetGLSL_ES_100 || target == ETargetGLSL_ES_300));
//}
//

bool MslLinker::getArgumentData2( MslSymbolOrStructMemberBase const* symOrStructMember,
								 EClassifier c, std::string &outName, std::string &ctor, int &pad, int semanticOffset)
{
	int size;
	EMslSymbolType base = EgstVoid;
	// Get the type before suppression because we may not want all of the elements.
	// note, suppressedBy should *never* be smaller than the suppressed.
	EMslSymbolType type = symOrStructMember->type;
	MslSymbolOrStructMemberBase const* suppressedBy = symOrStructMember->outputSuppressedBy();
	if (suppressedBy)
		symOrStructMember = suppressedBy;
	EAttribSemantic sem = parseAttributeSemantic( symOrStructMember->semantic );
	const std::string& semantic = symOrStructMember->semantic;

	// Offset the semantic for the case of an array
	if ( semanticOffset > 0 )
		sem = static_cast<EAttribSemantic>( (int)sem + semanticOffset );

	//clear the return values
	outName = "";
	ctor = "";
	pad = 0;

	//compute the # of elements in the type
	switch (type)
	{
	case EgstBool:
	case EgstBool2:
	case EgstBool3:
	case EgstBool4:
		base = EgstBool;
		size = type - EgstBool + 1;
		break;

	case EgstInt:
	case EgstInt2:
	case EgstInt3:
	case EgstInt4:
		base = EgstInt;
		size = type - EgstInt + 1;
		break;

	case EgstFloat:
	case EgstFloat2:
	case EgstFloat3:
	case EgstFloat4:
		base = EgstFloat;
		size = type - EgstFloat + 1;
		break;

    default:
        return false;
	};

	if ( c != EClassUniform)
	{

		ctor = getTypeString( (EMslSymbolType)((int)base + size - 1)); //default constructor
		pad = 0;

		switch (c)
		{
		case EClassNone:
			return false;

		case EClassAttrib:
			getAttributeName( symOrStructMember, outName, sem, semanticOffset );
			break;

		case EClassVarOut:
			// Create varying name
//                outName = "varying.";
                outName = "";

//            if ( (sem != EAttrSemPosition && sem != EAttrSemPrimitiveID && sem != EAttrSemPSize) || varOutString[sem][0] == 0 )
			{
				outName += kUserVaryingPrefix;
				outName += semantic;
				// If an array element, add the semantic offset to the name
				if ( semanticOffset > 0 )
				{
					outName += "_";
					outName += ( semanticOffset + '0' );
				}
			}
//            else
//            {
//                // Use built-in varying name
//                outName += varOutString[sem];
//
//                // Always pad built-in varying outputs to 4 elements
//                // exception: psize must be kept float1
//                if(sem != EAttrSemPSize)
//                {
//                    pad = 4 - size;
//                    ctor = "float4";
//                }
//            }
			break;

		case EClassVarIn:
            {
//            // inout COLORn variables translate to framebuffer fetch for GLES
//            if (IsArgumentForFramebufferFetch(symOrStructMember, sem, m_Target))
//            {
//                int index = sem - EAttrSemColor0;
//                outName = (m_Target == ETargetGLSL_ES_100 ? "gl_LastFragData" : "gl_FragData");
//                outName += '[';
//                outName += char('0'+index);
//                outName += ']';
//                m_Extensions.insert("GL_EXT_shader_framebuffer_fetch");
//            }
            // Create user varying name
//            else
            if ( (sem != EAttrSemVPos && sem != EAttrSemVFace && sem != EAttrSemPrimitiveID) || varInString[sem][0] == 0 )
            {
//                outName = "varying.";
                outName = "";

                outName += kUserVaryingPrefix;
                outName += stripSemanticModifier (semantic, false);
                // If an array element, add the semantic offset to the name
                if ( semanticOffset > 0 )
                {
                    outName += "_";
                    outName += ( semanticOffset + '0' );
                }
            }
            else
            {
                            assert(0);

                // Use built-in varying name
//                outName = varInString[sem];
            }
			break;
            }

		case EClassRes:
            outName = "float4 metal_fragment_color";
//            outName = resultString[sem];
//            if (sem == EAttrSemDepth)
//            {
//                if (m_Target == ETargetGLSL_ES_100)
//                {
//                    outName = "gl_FragDepthEXT";
//                    m_Extensions.insert("GL_EXT_frag_depth");
//                }
//                ctor = "float";
//            }
//            else if (sem == EAttrSemCoverage)
//                ctor = "int";
//            else
//            {
//                pad = 4 - size;
//                ctor = "float4";
//                if (sem >= EAttrSemColor1 && sem <= EAttrSemColor3)
//                {
//                    if (m_Target == ETargetGLSL_ES_100)
//                        m_Extensions.insert("GL_EXT_draw_buffers");
//                }
//            }
//
//            if (outName.empty())
//                return false;
			break;

		case EClassUniform:
			assert(0); // this should have been stripped
			return false; 
		};


	}
	else
	{
		//these should always match exactly
		outName = "xlu_";
		outName += symOrStructMember->name;
	}

	return true;
}


bool MslLinker::getArgumentData( MslSymbol* sym, EClassifier c, std::string &outName,
								 std::string &ctor, int &pad)
{
	return getArgumentData2( sym, c, outName, ctor, pad, -1);
}



bool MslLinker::setUserAttribName ( EAttribSemantic eSemantic, const char *pName )
{
	if ( eSemantic >= EAttrSemPosition && eSemantic <= EAttrSemDepth )
	{
		if ( strlen ( pName ) > MAX_ATTRIB_NAME )
		{
			assert(0);
			infoSink.info << "Attribute name (" << pName << ") larger than max (" << MAX_ATTRIB_NAME << ")\n";
			return false;
		}
		strcpy ( userAttribString[eSemantic], pName );
		return true;
	}

	infoSink.info << "Semantic value " << eSemantic << " unknown \n";
	return false;
}



// Strip the semantic string of any modifiers
std::string MslLinker::stripSemanticModifier(const std::string &semantic, bool warn)
{
	std::string newSemantic = semantic;

	size_t centroidLoc = semantic.find ("_centroid");
	if (centroidLoc != std::string::npos)
	{
		if (warn)
			infoSink.info << "Warning: '" << semantic << "' contains centroid modifier.  Modifier ignored because GLSL v1.10 does not support centroid\n";       
		newSemantic = semantic.substr (0, centroidLoc);
	}

	return newSemantic;
}


struct AttrSemanticMapping {
	const char* name;
	EAttribSemantic sem;
};

static AttrSemanticMapping kAttributeSemantic[] = {	
	{ "position", EAttrSemPosition },
	{ "position0", EAttrSemPosition },
	{ "position1", EAttrSemPosition1 },
	{ "position2", EAttrSemPosition2 },
	{ "position3", EAttrSemPosition3 },
	{ "sv_position", EAttrSemPosition },
	{ "vpos", EAttrSemVPos },
	{ "vface", EAttrSemVFace },
	{ "normal", EAttrSemNormal },
	{ "normal0", EAttrSemNormal },
	{ "normal1", EAttrSemNormal1 },
	{ "normal2", EAttrSemNormal2 },
	{ "normal3", EAttrSemNormal3 },
	{ "tangent", EAttrSemTangent },
	{ "tangent0", EAttrSemTangent },
	{ "tangent1", EAttrSemTangent1 },
	{ "tangent2", EAttrSemTangent2 },
	{ "tangent3", EAttrSemTangent3 },
	{ "binormal", EAttrSemBinormal },
	{ "binormal0", EAttrSemBinormal },
	{ "binormal1", EAttrSemBinormal1 },
	{ "binormal2", EAttrSemBinormal2 },
	{ "binormal3", EAttrSemBinormal3 },
	{ "blendweight", EAttrSemBlendWeight },
	{ "blendweight0", EAttrSemBlendWeight },
	{ "blendweight1", EAttrSemBlendWeight1 },
	{ "blendweight2", EAttrSemBlendWeight2 },
	{ "blendweight3", EAttrSemBlendWeight3 },
	{ "blendindices", EAttrSemBlendIndices },
	{ "blendindices0", EAttrSemBlendIndices },
	{ "blendindices1", EAttrSemBlendIndices1 },
	{ "blendindices2", EAttrSemBlendIndices2 },
	{ "blendindices3", EAttrSemBlendIndices3 },
	{ "psize", EAttrSemPSize },
	{ "psize0", EAttrSemPSize },
	{ "psize1", EAttrSemPSize1 },
	{ "psize2", EAttrSemPSize2 },
	{ "psize3", EAttrSemPSize3 },
	{ "color", EAttrSemColor0 },
	{ "color0", EAttrSemColor0 },
	{ "color1", EAttrSemColor1 },
	{ "color2", EAttrSemColor2 },
	{ "color3", EAttrSemColor3 },
	{ "sv_target", EAttrSemColor0 },
	{ "sv_target0", EAttrSemColor0 },
	{ "sv_target1", EAttrSemColor1 },
	{ "sv_target2", EAttrSemColor2 },
	{ "sv_target3", EAttrSemColor3 },
	{ "texcoord", EAttrSemTex0 },
	{ "texcoord0", EAttrSemTex0 },
	{ "texcoord1", EAttrSemTex1 },
	{ "texcoord2", EAttrSemTex2 },
	{ "texcoord3", EAttrSemTex3 },
	{ "texcoord4", EAttrSemTex4 },
	{ "texcoord5", EAttrSemTex5 },
	{ "texcoord6", EAttrSemTex6 },
	{ "texcoord7", EAttrSemTex7 },
	{ "texcoord8", EAttrSemTex8 },
	{ "texcoord9", EAttrSemTex9 },
	{ "depth", EAttrSemDepth },
	{ "sv_vertexid", EAttrSemVertexID },
	{ "sv_primitiveid", EAttrSemPrimitiveID },
	{ "sv_instanceid", EAttrSemInstanceID },
	{ "sv_coverage", EAttrSemCoverage }
};

// Determine the GLSL attribute semantic for a given HLSL semantic
EAttribSemantic MslLinker::parseAttributeSemantic (const std::string &semantic)
{
	std::string curSemantic = stripSemanticModifier (semantic, true);
	for (size_t i = 0; i < sizeof(kAttributeSemantic)/sizeof(kAttributeSemantic[0]); ++i)
		if (!_stricmp(curSemantic.c_str(), kAttributeSemantic[i].name))
			return kAttributeSemantic[i].sem;
	return EAttrSemUnknown;
}



/// Add the functions called by a function to the function set
/// \param func
///   The function for which all called functions will be added
/// \param funcSet
///   The set of currently called functions
/// \param funcList
///   The list of all functions
/// \return
///   True if all functions are found in the funcList, false otherwise.
bool MslLinker::addCalledFunctions( MslFunction *func, FunctionSet& funcSet, std::vector<MslFunction*> &funcList )
{
	const std::set<std::string> &cf = func->getCalledFunctions();

	for (std::set<std::string>::const_iterator cit=cf.begin(); cit != cf.end(); cit++)
	{
		std::vector<MslFunction*>::iterator it = funcList.begin();

		//This might be better as a more efficient search
		while (it != funcList.end())
		{
			if ( *cit == (*it)->getMangledName())
				break;
			it++;
		}

		//check to see if it really exists
		if ( it == funcList.end())
		{
			infoSink.info << "Failed to find function '" << *cit <<"'\n";
			return false;
		}

		//add the function (if it's not there already) and recurse
		if (std::find (funcSet.begin(), funcSet.end(), *it) == funcSet.end())
			funcSet.push_back (*it);
		addCalledFunctions( *it, funcSet, funcList); 
	}

	return true;
}

typedef std::vector<MslFunction*> FunctionSet;

static void EmitCalledFunctions (std::stringstream& shader, const FunctionSet& functions)
{
	if (functions.empty())
		return;

	// Functions must be emitted in reverse order as they are sorted topologically in top to bottom.
	for (FunctionSet::const_reverse_iterator fit = functions.rbegin(); fit != functions.rend(); fit++)
	{
		shader << "\n";
//		OutputLineDirective(shader, (*fit)->getLine());
		shader << (*fit)->getPrototype() << " {\n";
		shader << (*fit)->getCode() << "\n"; //has embedded }
		shader << "\n";
	}
}

static void EmitIfNotEmpty (std::stringstream& out, const std::stringstream& str)
{
	if (str.str().size())
		out << str.str() << "\n";
}

static const char* GetEntryName (const char* entryFunc)
{
	if (!entryFunc)
		return "";
	if (!strcmp(entryFunc, "main"))
		return "xlat_main";
	return entryFunc;
}

static const char* kShaderTypeNames[2] = { "Vertex", "Fragment" };


//static void add_extension_from_semantic(EAttribSemantic sem, ETargetVersion targetVersion, ExtensionSet& extensions)
//{
//    if (targetVersion == ETargetGLSL_ES_300)
//    {
//        // \todo [2013-05-14 pyry] Not supported in any platform yet.
//        if (sem == EAttrSemPrimitiveID)
//            extensions.insert("GL_ARB_geometry_shader4");
//    }
//    else
//    {
//        if (sem == EAttrSemPrimitiveID || sem == EAttrSemVertexID)
//            extensions.insert("GL_EXT_gpu_shader4");
//        if (sem == EAttrSemInstanceID)
//        {
//            extensions.insert(targetVersion == ETargetGLSL_ES_100 ? "GL_EXT_draw_instanced" : "GL_ARB_draw_instanced");
//        }
//    }
//}


bool MslLinker::linkerSanityCheck(MslCrossCompiler* compiler, const char* entryFunc)
{
	if (!compiler)
	{
		infoSink.info << "No shader compiler provided\n";
		return false;
	}
	if (!entryFunc)
	{
		infoSink.info << "No shader entry function provided\n";
		return false;
	}
	return true;
}

typedef std::map<std::string, int> FunctionUseCounts;

static MslFunction* resolveFunctionByMangledName (const std::vector<MslFunction*>& functions, const std::string& mangledName)
{
	for (std::vector<MslFunction*>::const_iterator iter = functions.begin(); iter != functions.end(); ++iter)
	{
		if ((*iter)->getMangledName() == mangledName)
			return *iter;
	}
	return 0;
}

static bool sortFunctionsTopologically (std::vector<MslFunction*>& dst, const std::vector<MslFunction*>& src)
{
	dst.clear();

	// Build function use counts.
	FunctionUseCounts useCounts;
	for (std::vector<MslFunction*>::const_iterator funcIter = src.begin(); funcIter != src.end(); ++funcIter)
		useCounts[(*funcIter)->getMangledName()] = 0;

	for (std::vector<MslFunction*>::const_iterator funcIter = src.begin(); funcIter != src.end(); ++funcIter)
	{
		std::set<std::string> calledNames = (*funcIter)->getCalledFunctions();
		for (std::set<std::string>::const_iterator callIter = calledNames.begin(); callIter != calledNames.end(); ++callIter)
			useCounts[*callIter] += 1;
	}

	std::vector<MslFunction*> liveSet;

	// Init live set with functions that have use count 0 (should be only main())
	for (std::vector<MslFunction*>::const_iterator funcIter = src.begin(); funcIter != src.end(); ++funcIter)
	{
		if (useCounts[(*funcIter)->getMangledName()] == 0)
			liveSet.push_back(*funcIter);
	}

	// Process until live set is empty.
	while (!liveSet.empty())
	{
		MslFunction* curFunction = liveSet.back();
		liveSet.pop_back();

		dst.push_back(curFunction);

		// Decrement use counts and add to live set if reaches zero.
		std::set<std::string> calledNames = curFunction->getCalledFunctions();
		for (std::set<std::string>::const_iterator callIter = calledNames.begin(); callIter != calledNames.end(); ++callIter)
		{
			int& useCount = useCounts[*callIter];
			useCount -= 1;
			if (useCount == 0)
			{
				MslFunction* newLiveFunc = resolveFunctionByMangledName(src, *callIter);
				if (!newLiveFunc)
					return false; // Not found - why?
				liveSet.push_back(newLiveFunc);
			}
		}
	}

	// If dependency graph contains cycles, some functions will never end up in live set and from there
	// to sorted list. This checks if sort succeeded.
	return dst.size() == src.size();
}

bool MslLinker::buildFunctionLists(MslCrossCompiler* comp, EShLanguage lang, const std::string& entryPoint, MslFunction*& globalFunction, std::vector<MslFunction*>& functionList, FunctionSet& calledFunctions, MslFunction*& funcMain)
{
	// build the list of functions
	std::vector<MslFunction*> &fl = comp->functionList;
	
	for (std::vector<MslFunction*>::iterator fit = fl.begin(); fit < fl.end(); ++fit)
	{
		if ((*fit)->isGlobalScopeFunction())
		{
			assert(!globalFunction);
			globalFunction = *fit;
		}
		else
			functionList.push_back(*fit);
		
		if ((*fit)->getName() == entryPoint)
		{
			if (funcMain)
			{
				infoSink.info << kShaderTypeNames[lang] << " entry function cannot be overloaded\n";
				return false;
			}
			funcMain = *fit;
		}
	}
	
	// check to ensure that we found the entry function
	if (!funcMain)
	{
		infoSink.info << "Failed to find entry function: '" << entryPoint <<"'\n";
		return false;
	}

	//add all the called functions to the list
	std::vector<MslFunction*> functionsToSort;
	functionsToSort.push_back (funcMain);
	if (!addCalledFunctions (funcMain, functionsToSort, functionList))
		infoSink.info << "Failed to resolve all called functions in the " << kShaderTypeNames[lang] << " shader\n";

	if (!sortFunctionsTopologically (calledFunctions, functionsToSort))
	{
		infoSink.info << "Failed to sort functions topologically, shader may contain recursion\n";
		return false;
	}

	return true;
}

struct MslSymbolSorter {
	bool operator()(const MslSymbol* a, const MslSymbol* b) {
		return a->getName() < b->getName();
	}
};

void MslLinker::buildUniformsAndLibFunctions(const FunctionSet& calledFunctions, std::vector<MslSymbol*>& constants, std::set<TOperator>& libFunctions)
{
	for (FunctionSet::const_iterator it = calledFunctions.begin(); it != calledFunctions.end(); ++it) {
		const std::vector<MslSymbol*> &symbols = (*it)->getSymbols();

		unsigned n_symbols = symbols.size();
		for (unsigned i = 0; i != n_symbols; ++i) {
			MslSymbol* s = symbols[i];
			if (s->getQualifier() == EqtUniform || s->getQualifier() == EqtMutableUniform)
				constants.push_back(s);
		}
		
		//take each referenced library function, and add it to the set
		const std::set<TOperator> &referencedFunctions = (*it)->getLibFunctions();
		libFunctions.insert( referencedFunctions.begin(), referencedFunctions.end());
	}
	
    // std::unique only removes contiguous duplicates, so vector must be sorted to remove them all
    std::sort(constants.begin(), constants.end(), MslSymbolSorter());

	// Remove duplicates
	constants.resize(std::unique(constants.begin(), constants.end()) - constants.begin());
}


void MslLinker::emitLibraryFunctions(CodeMap *map, const std::set<TOperator>& libFunctions, EShLanguage lang, bool usePrecision)
{
	// library Functions & required extensions
	std::string shaderLibFunctions;
#if 1
	if (!libFunctions.empty())
	{
		for (std::set<TOperator>::const_iterator it = libFunctions.begin(); it != libFunctions.end(); it++)
		{
            const std::string &func = map->GetSupportCode(*it);
			if (!func.empty())
			{
				shaderLibFunctions += func;
				shaderLibFunctions += '\n';
			}
		}
    }
#else
        for (int i=0; i < (int)EOpVecTernarySel; i++)
        {
            std::string func = map->GetSupportCode( (TOperator)i);
            if (!func.empty())
            {
                shaderLibFunctions += func;
                shaderLibFunctions += '\n';
            }
        }
        
#endif
	shader << shaderLibFunctions;
}


void MslLinker::emitStructs(MslCrossCompiler* comp)
{
	// Presently, structures are not tracked per function, just dump them all
	// This could be improved by building a complete list of structures for the
	// shaders based on the variables in each function.
	
	std::vector<MslStruct*> &sList = comp->structList;
	if (!sList.empty())
	{
		for (std::vector<MslStruct*>::iterator it = sList.begin(); it < sList.end(); it++)
		{
			shader << "\n";
//			OutputLineDirective(shader, (*it)->getLine());
			shader << (*it)->getDecl() << "\n";
		}
	}
}


void MslLinker::emitGlobals(const MslFunction* globalFunction, const std::vector<MslSymbol*>& constants)
{
	// write global scope declarations (represented as a fake function)
	assert(globalFunction);
	shader << globalFunction->getCode();
//    globalFunction->addNeededExtensions (m_Extensions, m_Target);
	
	// write mutable uniform declarations
//    const unsigned n_constants = constants.size();
//    for (unsigned i = 0; i != n_constants; ++i) {
//        MslSymbol* s = constants[i];
//        if (s->getIsMutable()) {
//            s->writeDecl(shader, MslSymbol::kWriteDeclMutableDecl);
//            shader << ";\n";
//        }
//    }
}


void MslLinker::buildUniformReflection(const std::vector<MslSymbol*>& constants)
{
	const unsigned n_constants = constants.size();
	for (unsigned i = 0; i != n_constants; ++i) {
		MslSymbol* s = constants[i];
		
		ShUniformInfo info;
		const std::string& name = s->getName(false);
		info.name = new char[name.size()+1];
		strcpy(info.name, name.c_str());
		
		if (s->getSemantic() != "") {
			info.semantic = new char[s->getSemantic().size()+1];
			strcpy(info.semantic, s->getSemantic().c_str());
		}
		else
			info.semantic = 0;
		
		if (s->getRegister() != "") {
			info.registerSpec = new char[s->getRegister().size()+1];
			strcpy(info.registerSpec, s->getRegister().c_str());
		}
		else
			info.registerSpec = 0;
		
		info.type = (EShType)s->getType();
		info.arraySize = s->getArraySize();
		info.init = 0;
		uniforms.push_back(info);
	}
}


static void emitSymbolWithPad (std::stringstream& str, const std::string& ctor, const std::string& name, int pad)
{
	str << ctor << "(" << name;
	for (int i = 0; i < pad; ++i)
		str << ", 0.0";
	str << ")";
}


static void emitSingleInputVariable (EShLanguage lang, ETargetVersion targetVersion, const std::string& name, const std::string& ctor, EMslSymbolType type, TPrecision prec, std::stringstream& attrib, std::stringstream& varying)
{
	// vertex shader: emit custom attributes
	if (lang == EShLangVertex && strncmp(name.c_str(), "gl_", 3) != 0)
	{
//        int typeOffset = 0;
		
		// If the type is integer or bool based, we must convert to a float based
		// type. This is because GLSL does not allow int or bool based vertex attributes.
		//
		// NOTE: will need to be updated for more modern GLSL versions to allow this!
//        if (type >= EgstInt && type <= EgstInt4)
//            typeOffset += 4;
//        if (type >= EgstBool && type <= EgstBool4)
//            typeOffset += 8;
		
//        attrib << GetVertexInputQualifier(targetVersion) << " " <<  getTypeString((EMslSymbolType)(type + typeOffset)) << " " << name << ";\n";
        
        int index = -1;
        if (name == "POSITION") index  = 0;
        if (name == "COLOR") index  = 1;
        if (name == "TEXCOORD0") index  = 2;
        if (name == "TEXCOORD1") index  = 3;

        
        attrib << " " <<  getTypeString(type) << " " << name;
        
        if (index >= 0)
            attrib << " [[attribute(" << index << ")]]";

        attrib << ";\n";

    
    }
	
	// fragment shader: emit varying
	if (lang == EShLangFragment)
	{
		AddFragmentInput(varying, targetVersion, prec, ctor, name);
	}
}
	

void MslLinker::emitInputNonStructParam(MslSymbol* sym, EShLanguage lang, bool usePrecision, EAttribSemantic attrSem, std::stringstream& attrib, std::stringstream& varying, std::stringstream& preamble, std::stringstream& call)
{
	std::string name, ctor;
	int pad;
	
	if (!getArgumentData (sym, lang==EShLangVertex ? EClassAttrib : EClassVarIn, name, ctor, pad))
	{
		// should deal with fall through cases here
		assert(0);
		infoSink.info << "Unsupported type for shader entry parameter (";
		infoSink.info << getTypeString(sym->getType()) << ")\n";
		return;
	}
	
	
	// In fragment shader, pass zero for POSITION inputs
	if (lang == EShLangFragment && attrSem == EAttrSemPosition)
	{
		call << ctor << "(0.0)";
		return; // noting more to do
	}
	// For "in" parameters, just call directly to the main
	else if ( sym->getQualifier() != EqtInOut )
	{
		emitSymbolWithPad (call, ctor, name, pad);
	}
	// For "inout" parameters, declare a temp and initialize it
	else
	{
		preamble << "    ";
		writeType (preamble, sym->getType(), NULL, usePrecision?sym->getPrecision():EbpUndefined);
		preamble << " " << xlt_prefix << sym->getName() << " = ";
		emitSymbolWithPad (preamble, ctor, name, pad);
		preamble << ";\n";
	}

	if (!sym->outputSuppressedBy())
		emitSingleInputVariable (lang, m_Target, name, ctor, sym->getType(), sym->getPrecision(), attrib, varying);
}


static std::string GetFixedNestedVaryingSemantic(const std::string& parentStructSemantic, int ii)
{
	int baseIdx = 0;
	std::stringstream var;
	const size_t i = parentStructSemantic.find_first_of("0123456789");
	if (i != std::string::npos)
	{
		std::stringstream(&parentStructSemantic[i]) >> baseIdx;
		var << parentStructSemantic.substr(0, i);
	}
	else
		var << parentStructSemantic;

	var << (baseIdx + ii);

	return var.str();
}

// This function calls itself recursively if it finds structs in structs.
bool MslLinker::emitInputStruct(const MslStruct* str, std::string parentName, EShLanguage lang, std::stringstream& attrib, std::stringstream& varying, std::stringstream& preamble, const std::string& parentStructSemantic)
{
	// process struct members
	const int elem = str->memberCount();
	for (int jj=0; jj<elem; jj++)
	{
		const StructMember &current = str->getMember(jj);
		EAttribSemantic memberSem = parseAttributeSemantic (current.semantic);
		
//        add_extension_from_semantic(memberSem, m_Target, m_Extensions);
		
		// if member of the struct is an array, we have to loop over all array elements
		int arraySize = 1;
		bool isArray = false;
		if (current.arraySize > 0)
		{
			arraySize = current.arraySize;
			isArray = true;
		}
		
		std::string name, ctor;
		for (int idx = 0; idx < arraySize; ++idx)
		{
			int pad;
			if (!getArgumentData2 (&current, lang==EShLangVertex ? EClassAttrib : EClassVarIn, name, ctor, pad, isArray?idx:-1))
			{
				const MslStruct* subStruct = current.structType;
				if (subStruct)
				{
					//should deal with fall through cases here
					emitInputStruct(subStruct, parentName+current.name+std::string("."), lang, attrib, varying, preamble, current.getSemantic());
					continue;
				}
				else
				{
					infoSink.info << "Unsupported type for struct element in shader entry parameter (";
					infoSink.info << getTypeString(current.type) << ")\n";
					return false;
				}
			}

			// nested struct with a semantic, but no semantics on it's members - inherit from parent
			if (!parentStructSemantic.empty() && current.semantic.empty())
				name += GetFixedNestedVaryingSemantic(parentStructSemantic, jj); // "xlv_" += new_semantic

			preamble << "    ";
			preamble << parentName << current.name;
			
			if (isArray)
				preamble << "[" << idx << "]";
			
			// In fragment shader, pass zero for POSITION inputs
			if (lang == EShLangFragment && memberSem == EAttrSemPosition)
			{
				preamble << " = " << ctor << "(0.0);\n";
				//continue; // nothing more to do
			}
			else
			{
				preamble << " = ";
                
                emitSymbolWithPad (preamble, ctor, std::string("input.") + name, pad);
				preamble << ";\n";
			}

			if (!current.outputSuppressedBy())
				emitSingleInputVariable (lang, m_Target, name, ctor, current.type, current.precision, attrib, varying);
		}
	}
	return true;
}

void MslLinker::emitInputStructParam(MslSymbol* sym, EShLanguage lang, std::stringstream& attrib, std::stringstream& varying, std::stringstream& preamble, std::stringstream& call)
{
	MslStruct* str = sym->getStruct();
	assert(str);

	// temporary variable for the struct
	const std::string tempVar = xlt_prefix + sym->getName();
	preamble << "    " << str->getName() << " ";
	preamble << tempVar <<";\n";
	call << tempVar;
	emitInputStruct(str, xlt_prefix + sym->getName() + ".", lang, attrib, varying, preamble);
}


void MslLinker::emitOutputNonStructParam(MslSymbol* sym, EShLanguage lang, bool usePrecision, EAttribSemantic attrSem, std::stringstream& varying, std::stringstream& preamble, std::stringstream& postamble, std::stringstream& call)
{
	std::string name, ctor;
	int pad;
	
	if (!getArgumentData( sym, lang==EShLangVertex ? EClassVarOut : EClassRes, name, ctor, pad))
	{
		//should deal with fall through cases here
		assert(0);
		infoSink.info << "Unsupported type for shader entry parameter (";
		infoSink.info << getTypeString(sym->getType()) << ")\n";
		return;
	}
	
	// For "inout" parameters, the preamble was already written so no need to do it here.
	if (sym->getQualifier() != EqtInOut)
	{
		preamble << "    ";

        // UNITY CUSTOM: for vprog output with position semantic - force highp
        TPrecision prec = usePrecision ? sym->getPrecision() : EbpUndefined;
        if(sym->hasSemantic() && usePrecision)
        {
            const char* str = sym->getSemantic().c_str();
            int         len = sym->getSemantic().length();

            extern bool IsPositionSemantics(const char* sem, int len);
            if(IsPositionSemantics(str, len))
                prec = EbpHigh;
        }

        writeType (preamble, sym->getType(), NULL,prec);
		preamble << " " << xlt_prefix << sym->getName() << ";\n";
	}
	
	// In vertex shader, add to varyings
	if (lang == EShLangVertex)
		AddVertexOutput (varying, m_Target, sym->getPrecision(), ctor, name);
	
	call << xlt_prefix << sym->getName();
	
	postamble << "    ";
	postamble << name << " = ";
    emitSymbolWithPad (postamble, ctor, std::string(xlt_prefix) +sym->getName(), pad);
	postamble << ";\n";
}


void MslLinker::emitOutputStructParam(MslSymbol* sym, EShLanguage lang, bool usePrecision, EAttribSemantic attrSem, std::stringstream& varying, std::stringstream& preamble, std::stringstream& postamble, std::stringstream& call)
{
	//structs must pass the struct, then process per element
	MslStruct *Struct = sym->getStruct();
	assert(Struct);
	
	//first create the temp
	std::string tempVar = xlt_prefix + sym->getName();
	
	// For "inout" parmaeters the preamble and call were already written, no need to do it here
	if ( sym->getQualifier() != EqtInOut )
	{
		preamble << "    " << Struct->getName() << " ";
		preamble << tempVar <<";\n";
		call << tempVar;
	}
	
	const int elem = Struct->memberCount();
	for (int ii=0; ii<elem; ii++)
	{
		const StructMember &current = Struct->getMember(ii);
		std::string name, ctor;
		int pad;
		
		if (!getArgumentData2( &current, lang==EShLangVertex ? EClassVarOut : EClassRes, name, ctor, pad, -1))
		{
			//should deal with fall through cases here
			assert(0);
			infoSink.info << "Unsupported type in struct element for shader entry parameter (";
			infoSink.info << getTypeString(current.type) << ")\n";
			continue;
		}
		postamble << "    ";
		postamble << name << " = ";
		emitSymbolWithPad (postamble, ctor, tempVar+"."+current.name, pad);		
		postamble << ";\n";

		// In vertex shader, add to varyings
		if (lang == EShLangVertex)
			AddVertexOutput (varying, m_Target, current.precision, ctor, name);
	}
}


void MslLinker::emitMainStart(const MslCrossCompiler* compiler, const EMslSymbolType retType, MslFunction* funcMain, unsigned options, bool usePrecision, std::stringstream& preamble, const std::vector<MslSymbol*>& constants)
{
    
    if (compiler->IsVertex())
    {
        preamble << "vertex Buffer_Varying vertex_main(\n";
        preamble << "\tBuffer_Attribs input [[stage_in]]";
        preamble << ",\n";
        if (m_Options & ETranslateOpPointSize) {
        preamble << "\tconstant Buffer_Options & options [[ buffer(1) ]]";
        preamble << ",\n";
        }

    }
    else
    {
        preamble << "fragment float4 fragment_main(\n";
        preamble << "\tBuffer_Varying input [[stage_in]]";
        preamble << ",\n";
    }

    preamble << "\tconstant Buffer_Uniforms & uniforms [[ buffer(2) ]]";
    
    int textureId = 0;
    for (auto s : constants) {
        if (s->getType() >= EgstSamplerGeneric  && s->getType() <= EgstSampler2DArray ) {
            preamble << ",\n";
            
            preamble << "\t"
            << "thread "
            << "texture2d<float> "
            << s->getName() << "_texture"
            << " [[texture(" << textureId << ")]]";

            preamble << ",\n";

            preamble << "\t"
                    << "thread "
                    << "sampler "
                    << s->getName()
                    << " [[sampler(" << textureId << ")]]"
            ;
            
            textureId++;
        }
    }

    preamble << "\n";

    preamble << ")";
    preamble << "{\n";
	
	// initialize mutable uniforms with the original uniform values
//    const unsigned n_constants = constants.size();
//    for (unsigned i = 0; i != n_constants; ++i) {
//        MslSymbol* s = constants[i];
//        if (s->getIsMutable()) {
//            s->writeDecl(preamble, MslSymbol::kWriteDeclMutableInit);
//            preamble << ";\n";
//        }
//    }
//
    
	
    /*
	std::string arrayInit = compiler->m_DeferredArrayInit.str();
	if (!arrayInit.empty())
	{
		const bool emit_120_arrays = (m_Target >= ETargetGLSL_120);
		const bool emit_old_arrays = !emit_120_arrays || (options & ETranslateOpEmitGLSL120ArrayInitWorkaround);
		const bool emit_both = emit_120_arrays && emit_old_arrays;
		
		if (emit_both)
			preamble << "#if defined(HLSL2GLSL_ENABLE_ARRAY_120_WORKAROUND)" << std::endl;
		preamble << arrayInit;
		if (emit_both)
			preamble << "\n#endif" << std::endl;
	}
	std::string matrixInit = compiler->m_DeferredMatrixInit.str();
	if (!matrixInit.empty())
	{
		preamble << matrixInit;
	}
    */
	
	if (retType == EgstStruct)
	{
		MslStruct* retStruct = funcMain->getStruct();
		assert(retStruct);
		preamble << "    " << retStruct->getName() << " xl_retval;\n";
	}
	else if (retType != EgstVoid)
	{
		preamble << "    ";
		writeType (preamble, retType, NULL, usePrecision?funcMain->getPrecision():EbpUndefined);
		preamble << " xl_retval;\n";
	}
}

// This function calls itself recursively if it finds structs in structs.
bool MslLinker::emitReturnStruct(MslStruct *retStruct, std::string parentName, EShLanguage lang, std::stringstream& varying, std::stringstream& postamble, const std::string& parentStructSemantic)
{
    if (lang == EShLangVertex) {
        postamble  << "    "<< "Buffer_Varying output;\n";
        if (m_Options & ETranslateOpPointSize) 
            postamble << "    " <<  "output.point_size = options.point_size;\n";
    }
    
	const int elem = retStruct->memberCount();
	for (int ii=0; ii<elem; ii++)
	{
		const StructMember &current = retStruct->getMember(ii);
		std::string name, ctor;
		int pad;
		int arraySize = 1;
		bool isArray = false;

		if (lang == EShLangVertex) // vertex shader
		{
			// If it is an array, loop over each member
			if ( current.arraySize > 0 )
			{
				arraySize = current.arraySize;
				isArray = true;
			}
		}

		for (int idx = 0; idx < arraySize; ++idx)
		{
			if (!getArgumentData2( &current, lang==EShLangVertex ? EClassVarOut : EClassRes, name, ctor, pad, isArray?idx:-1))
			{
				MslStruct *subStruct = current.structType;
				if (subStruct)
				{
					if (!emitReturnStruct(current.structType, parentName+current.name+std::string("."), lang, varying, postamble, current.getSemantic()))
					{
						return false;
					}
				}
				else
				{
					infoSink.info << (lang==EShLangVertex ? "Unsupported element type in struct for shader return value (" : "Unsupported struct element type in return type for shader entry function (");
					infoSink.info << getTypeString(current.type) << ")\n";
					return false;
				}
			}
			else
			{
				if (!parentStructSemantic.empty() && current.semantic.empty())
					name += GetFixedNestedVaryingSemantic(parentStructSemantic, ii);

				postamble << "    ";
                if (lang == EShLangVertex)
                    postamble << "output.";
				postamble << name;
				postamble << " = " << ctor;
				postamble << "(" << parentName << current.name;
				if (isArray)
				{
					postamble << "[" << idx << "]";
				}
				for (int jj = 0; jj<pad; jj++)
					postamble << ", 0.0";

				postamble << ");\n";

				// In vertex shader, add to varyings
				if (lang == EShLangVertex)
					AddVertexOutput (varying, m_Target, current.precision, ctor, name);
			}
		}
	}
    
    if (lang == EShLangVertex)
        postamble << "    " << "return output;\n";

	return true;
}

bool MslLinker::emitReturnValue(const EMslSymbolType retType, MslFunction* funcMain, EShLanguage lang, std::stringstream& varying, std::stringstream& postamble)
{
	// void return type
	if (retType == EgstVoid)
	{
		if (lang == EShLangFragment) // fragment shader
		{
			// If no return type, close off the output
			postamble << ";\n";
		}
		return true;
	}
	
	// non-struct return type
	assert (retType != EgstVoid);
	if (retType != EgstStruct)
	{
		std::string name, ctor;
		int pad;
		
		MslSymbolOrStructMemberBase fakedMainSym("", funcMain->getSemantic(), retType, EqtNone, EbpMedium, 0);

		if (!getArgumentData2(&fakedMainSym, lang==EShLangVertex ? EClassVarOut : EClassRes,
								name, ctor, pad, -1))
		{
			TSourceLoc loc = { 0, 1 };
			std::string msg =
				std::string("Unsupported ") +
				(lang==EShLangVertex ? "type for shader return value" : "return type for shader entry function") +
				" (" + getTypeString(retType) + ")" +
				" or wrong semantic (" + funcMain->getSemantic() + ")";
			infoSink.info.message(EPrefixError, msg.c_str(), loc);
			return false;
		}
		
		postamble << "    ";
		postamble << name << " = ";
		emitSymbolWithPad (postamble, ctor, "xl_retval", pad);		
		postamble << ";\n";
		
		// In vertex shader, add to varyings
		if (lang == EShLangVertex)
			AddToVaryings (varying, lang, m_Target, funcMain->getPrecision(), ctor, name);
		return true;
	}
	
	// struct return type
	assert (retType == EgstStruct);
	MslStruct *retStruct = funcMain->getStruct();
	assert (retStruct);
	return emitReturnStruct(retStruct, std::string("xl_retval."), lang, varying, postamble);
}

// Called recursively and appends (to list) any symbols that have semantic sem.
void MslLinker::appendDuplicatedInSemantics(MslSymbolOrStructMemberBase* sym, EAttribSemantic sem, std::vector<MslSymbolOrStructMemberBase*>& list)
{
	EMslQualifier qual = sym->getQualifier();
	// fields in structures in structures can have EqtNone as a qualifier.
	if ( (qual == EqtIn || qual == EqtInOut || qual == EqtNone) && parseAttributeSemantic(sym->getSemantic()) == sem )
		list.push_back(sym);
	else if (sym->getStruct())
	{
		int mc = sym->getStruct()->memberCount();
		for (int i = 0; i < mc; ++i)
			appendDuplicatedInSemantics(const_cast<StructMember*>(&sym->getStruct()->getMember(i)),sem,list);
	}
}

// For each re-used semantic (e.g. TEXCOORD0) record the symbol for which it is output.
// This is so that you can specify the same semantic in multiple structures without
// having multiply defined attribute or varying symbols in the output. The one that is
// output is the one found with the largest dimension.
void MslLinker::markDuplicatedInSemantics(MslFunction* func)
{
	int pCount = func->getParameterCount();
	for (int ase = EAttrSemNone; ase < EAttrSemCount; ++ase)
	{
		std::vector<MslSymbolOrStructMemberBase*> symsUsingSem;
		for (int ii=0; ii<pCount; ii++)
		{
			MslSymbol *sym = func->getParameter(ii);
			appendDuplicatedInSemantics(sym, static_cast<EAttribSemantic>(ase), symsUsingSem);
		}
		if (symsUsingSem.size() > 1)
		{
			int index_of_largest = -1;
			int largest_array_size = 0;
			MslSymbolOrStructMemberBase* sym_of_largest = 0;
			for (unsigned int ii=0; ii < symsUsingSem.size(); ii++)
			{
				if (!ii || largest_array_size < getElements(symsUsingSem[ii]->type))
				{
					index_of_largest = ii;
					sym_of_largest = symsUsingSem[ii];
					largest_array_size = getElements(symsUsingSem[ii]->type);
				}
			}
			for (unsigned int ii=0; ii < symsUsingSem.size(); ii++)
			{
				if (ii != index_of_largest)
				{
					symsUsingSem[ii]->suppressOutput(sym_of_largest);
				}
			}
		}
	}
}

bool MslLinker::link(MslCrossCompiler* compiler, const char* entryFunc, ETargetVersion targetVersion, unsigned options)
{
	m_Target = targetVersion;
	m_Options = options;
//    m_Extensions.clear();
	if (!linkerSanityCheck(compiler, entryFunc))
		return false;
    

	
    const bool usePrecision = false; //Msl2Msl_VersionUsesPrecision(targetVersion);
	
	EShLanguage lang = compiler->getLanguage();
	std::string entryPoint = GetEntryName (entryFunc);
	
	
	// figure out all relevant functions
	MslFunction* globalFunction = NULL;
	std::vector<MslFunction*> functionList;
	FunctionSet calledFunctions;
	MslFunction* funcMain = NULL;
	if (!buildFunctionLists(compiler, lang, entryPoint, globalFunction, functionList, calledFunctions, funcMain))
		return false;
	assert(globalFunction);
	assert(funcMain);
	
	// uniforms and used built-in functions
	std::vector<MslSymbol*> constants;
	std::set<TOperator> libFunctions;
	buildUniformsAndLibFunctions(calledFunctions, constants, libFunctions);
	// add built-in functions possibly used by uniform initializers
	const std::set<TOperator>& referencedGlobalFunctions = globalFunction->getLibFunctions();
	libFunctions.insert (referencedGlobalFunctions.begin(), referencedGlobalFunctions.end());
	
	buildUniformReflection (constants);


	// print all the components collected above.

    shader <<
                     "#pragma clang diagnostic ignored \"-Wunused-variable\"\n"
                     "#pragma clang diagnostic ignored \"-Wunused-value\"\n"
                     "#pragma clang diagnostic ignored \"-Wparentheses-equality\"\n"
                     "#include <metal_stdlib>\n"
                     "#include <simd/simd.h>\n"
                     "using namespace metal;\n"
//                     "#define metal_texture(_name, _uv)  ((_name. _texture)->sample(*_name._sampler, _uv))\n"
    
    
         ;
    
    shader <<
    "using vec2 = float2;\n"
    "using vec3 = float3;\n"
    "using vec4 = float4;\n"
    "using ivec2 = int2;\n"
    "using ivec3 = int3;\n"
    "using ivec4 = int4;\n"
    "using bvec2 = bool2;\n"
    "using bvec3 = bool3;\n"
    "using bvec4 = bool4;\n"
    ;
    
    
    shader <<
   "struct Texture2DSampler { \n"
    "const thread texture2d<float>* _texture;"
    "const thread sampler* _sampler;\n"
   "};"

    "float4 metal_texture(const thread Texture2DSampler &ss, float2 uv) {return ss._texture->sample(*ss._sampler, uv);}\n"
    
    
    
    ;



    
    
    CodeMap *supportLibrary = createMetalSupportLibrary(targetVersion);
	emitLibraryFunctions (supportLibrary, libFunctions, lang, usePrecision);
    delete supportLibrary;

    emitStructs(compiler);
    
    
    shader << "struct Buffer_Uniforms {\n";
    for (auto s : constants) {
        if (s->getType() >= EgstSamplerGeneric  && s->getType() <= EgstSampler2DArray ) {
        } else
        //        if (!s->getIsMutable())
        {
            shader << "\t";
            s->writeDecl(shader, MslSymbol::kWriteDeclDefault);
            shader << ";\n";
        }
    }
    shader << "};\n\n";

    
    if (m_Options & ETranslateOpPointSize) {
    shader << "struct Buffer_Options {\n";
    shader << "\t" << "float point_size;" << "\n";
    shader << "};\n\n";
    }


    shader << "//////////  \n";

    shader << "struct Shader {\n";

    shader << "// globals \n";
    emitGlobals (globalFunction, constants);
    
    shader << "// uniforms \n";
    for (auto s : constants) {
        if (s->getType() >= EgstSamplerGeneric  && s->getType() <= EgstSampler2DArray ) {
            shader << "\t";
//            shader << "const thread ";
//            shader << "texture2d<float> *";
//            shader << s->getName() << "_texture";
//            shader << ";\n";
//
//            shader << "\t";
//            shader << "const thread ";
//            shader << "sampler *";
//            shader << s->getName();
//            shader << ";\n";


            shader << "\t";
            shader << "Texture2DSampler ";
            shader << s->getName();
            shader << ";\n";

            
        } else
//        if (!s->getIsMutable())
        {
            shader << "\t";
            s->writeDecl(shader, MslSymbol::kWriteDeclDefault);
            shader << ";\n";
        }
    }
    
    shader << "\n// functions \n";

	EmitCalledFunctions (shader, calledFunctions);

    //    EmitIfNotEmpty (shader, uniform);
    
    shader <<"\n";
    shader << "// constructor \n";

    shader << "Shader(constant Buffer_Uniforms & uniforms) { \n";

    std::string arrayInit = compiler->m_DeferredArrayInit.str();

    if (!arrayInit.empty())
    {
        shader << arrayInit;
    }
    
    std::string matrixInit = compiler->m_DeferredMatrixInit.str();
    if (!matrixInit.empty())
    {
        shader << arrayInit;
    }
    
    
    for (auto s : constants) {
        if (s->getType() >= EgstSamplerGeneric  && s->getType() <= EgstSampler2DArray ) {
        } else {
            shader << "\t" << "" << s->getName() << " = " << "uniforms." << s->getName() << ";"  << '\n';
        }
    }
    
    shader << "} \n";
    shader << "\n";
    
    
    shader << "};\n\n";

    

	// Generate a main function that calls the specified entrypoint.
	// That main function uses semantics on the arguments and return values to
	// connect items appropriately.	
	
	std::stringstream attrib;
	std::stringstream uniform;
	std::stringstream preamble;
	std::stringstream postamble;
	std::stringstream varying;
	std::stringstream call;

	markDuplicatedInSemantics(funcMain);

    
    
	// Declare return value
	const EMslSymbolType retType = funcMain->getReturnType();
	emitMainStart(compiler, retType, funcMain, m_Options, usePrecision, preamble, constants);
	

    
	// Call the entry point
    call << "    ";
    call << "Shader shader(uniforms);\n";
    
    
    for (auto s : constants) {
        if (s->getType() >= EgstSamplerGeneric  && s->getType() <= EgstSampler2DArray ) {
            call << "\t"
            << "shader." << s->getName() << "._texture"
            << " = "
            << "&"
            << s->getName() << "_texture"
            << ";";
            call << '\n';
            
            call << "\t"
            << "shader." << s->getName() << "._sampler"
            << " = "
            << "&"
            << s->getName()
            << ";";
            /*
            call << "\t"
            << "shader." << s->getName() << "_texture"
            << " = "
            << "&"
            << s->getName() << "_texture"
            << ";";
            call << '\n';

            call << "\t"
            << "shader."
            << s->getName()
            << " = "
            << "&"
            << s->getName()
            << ";";
             */
        } else {
//            call << "\t" << "shader." << s->getName() << " = " << "uniforms." << s->getName() << ";";
        }
        call << '\n';
    }
    
	call << "    ";
	if (retType != EgstVoid)
		call << "xl_retval = ";
	call << "shader." << funcMain->getName() << "( ";
	

	// Entry point parameters
	const int pCount = funcMain->getParameterCount();
	for (int ii=0; ii<pCount; ii++)
	{
        if (ii > 0)
            call << ",\n";
        
		MslSymbol *sym = funcMain->getParameter(ii);
		EAttribSemantic attrSem = parseAttributeSemantic( sym->getSemantic());
		
//        add_extension_from_semantic(attrSem, m_Target, m_Extensions);

		switch (sym->getQualifier())
		{

		// -------- IN & OUT parameters
		case EqtIn:
		case EqtInOut:
		case EqtConst:
			if (sym->getType() != EgstStruct)
			{
				emitInputNonStructParam(sym, lang, usePrecision, attrSem, attrib, varying, preamble, call);
			}
			else
			{
				emitInputStructParam(sym, lang, attrib, varying, preamble, call);
			}

			// NOTE: for "inout" parameters need to fallthrough to the next case
			if (sym->getQualifier() != EqtInOut)
			{
				break;
			}


		// -------- OUT parameters; also fall-through for INOUT (see the check above)
		case EqtOut:

			if ( sym->getType() != EgstStruct)
			{
				emitOutputNonStructParam(sym, lang, usePrecision, attrSem, varying, preamble, postamble, call);
			}
			else
			{
				emitOutputStructParam(sym, lang, usePrecision, attrSem, varying, preamble, postamble, call);
			}
			break;

		case EqtUniform:
			uniform << "uniform ";
			writeType (uniform, sym->getType(), NULL, usePrecision?sym->getPrecision():EbpUndefined);
			uniform << " xlu_" << sym->getName();
			if(sym->getArraySize())
				uniform << "[" << sym->getArraySize() << "]";
			uniform << ";\n";
			call << "xlu_" << sym->getName();
			break;

		default:
			assert(0);
		};
	
	}
    


	call << ");\n";


	// Entry point return value
	if (!emitReturnValue(retType, funcMain, lang, varying, postamble))
		return false;
    
    if (lang == EShLangVertex)
    {
//        postamble << "gl_Position.y *= xlu_yscale;\n";
        // map from 0.0 -> 1.0 to -1.0 -> 1.0
//        postamble << "gl_Position.z  = (gl_Position.z * 2.0) - gl_Position.w;\n";
        
    }
    else
    {
        postamble << "    " <<  "return metal_fragment_color;\n";
    }

    
    
	postamble << "}\n\n";
	
	
	// Generate final code of the pieces above.
    
//    shader << "struct Buffer_Uniforms {\n";
//    EmitIfNotEmpty (shader, uniform);
//    shader << "};\n";

    if (lang == EShLangVertex) {
        shader << "struct Buffer_Attribs {\n";
        EmitIfNotEmpty (shader, attrib);
        shader << "};\n\n";
    }

        
    shader << "struct Buffer_Varying {\n";
	EmitIfNotEmpty (shader, varying);

    if (m_Options & ETranslateOpPointSize) {
    if (lang == EShLangVertex) {
        shader << " " << "float point_size [[point_size]];\n";
    }
    }

    shader << "};\n\n";
    
        
	shader << preamble.str() << "\n";
	shader << call.str() << "\n";
	shader << postamble.str() << "\n";

	return true;
}


static std::string CleanupShaderText (const std::string& prefix, const std::string& str)
{
	std::string res = prefix;
	size_t n = str.size();
	res.reserve (n + prefix.size());
	char cc = 0;
	for (size_t i = 0; i < n; ++i)
	{
		char c = str[i];
		// Next line used to have str[i-1] instead of cc, but that produces some bug on OSX Lion
		// with Xcode 4.3 (i686-apple-darwin11-llvm-gcc-4.2 (GCC) 4.2.1) in release config; str[i-1]
		// always returns zero.
		if (c != '\n' || i==0 || cc != '\n')
			res.push_back(c);
		cc = c;
	}
	return res;
}



const char* MslLinker::getShaderText() const
{
	bs = CleanupShaderText (shaderPrefix.str(), shader.str());
	return bs.c_str();
}


}}
