// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#ifndef _TYPES_INCLUDED
#define _TYPES_INCLUDED

#include "../Include/Common.h"
#include "../Include/BaseTypes.h"

namespace hlslang {

//
// Need to have association of line numbers to types in a list for building structs.
//
class TType;
struct TTypeLine
{
   TType* type;
   TSourceLoc line;
};
typedef TVector<TTypeLine> TTypeList;

inline TTypeList* NewPoolTTypeList()
{
   void* memory = GlobalPoolAllocator.allocate(sizeof(TTypeList));
   return new(memory) TTypeList;
}

//
// This is a workaround for a problem with the yacc stack,  It can't have
// types that it thinks have non-trivial constructors.  It should 
// just be used while recognizing the grammar, not anything else.  Pointers
// could be used, but also trying to avoid lots of memory management overhead.
//
// Not as bad as it looks, there is no actual assumption that the fields
// match up or are name the same or anything like that.
//
class TPublicType
{
public:
	TBasicType type;
	TQualifier qualifier;
	TPrecision precision;
	int matcols;
    int matrows;
	bool matrix;
	bool array;
	int arraySize;
	TType* userDef;
	TSourceLoc line;

	void setBasic(TBasicType bt, TQualifier q, const TSourceLoc& ln = gNullSourceLoc)
	{
		type = bt;
		qualifier = q;
		precision = EbpUndefined;
		matcols = 1;
		matrows = 1;
		matrix = false;
		array = false;
		arraySize = 0;
		userDef = 0;
		line = ln;
	}

	void setVector(int s)
	{
		matcols = 1;
		matrows = s;
		matrix = false;
	}

	void setMatrix(int columns, int rows)
	{
		matcols = columns;
		matrows = rows;
		matrix = true;
	}

	void setArray(bool a, int s = 0)
	{
		array = a;
		arraySize = s;
	}
};

typedef std::map<TTypeList*, TTypeList*> TStructureMap;


//
// Base class for things that have a type.
//
class TType
{
public:
   enum ECompatibility
   {
      NOT_COMPATIBLE = 0,
      MATCH_EXACTLY,
      PROMOTION_EXISTS,
      IMPLICIT_CAST_EXISTS,
      IMPLICIT_CAST_WITH_PROMOTION_EXISTS,
      UPWARD_VECTOR_PROMOTION_EXISTS
   };

   POOL_ALLOCATOR_NEW_DELETE(GlobalPoolAllocator)

   explicit TType() { }
   explicit TType(TBasicType t, TPrecision p, TQualifier q = EvqTemporary, int cols = 1, int rows = 1, bool m = false, bool a = false) :
      type(t), precision(p), qualifier(q), matcols(cols), matrows(rows), line(gNullSourceLoc), matrix(m), array(a), arraySize(0),
      structure(0), structureSize(0), maxArraySize(0), arrayInformationType(0), fieldName(0), mangled(0), typeName(0),
      semantic(0)
   {
      checkInvariants();
   }
   explicit TType(const TPublicType &p) :
      type(p.type), precision(p.precision), qualifier(p.qualifier), matrows(p.matrows), matcols(p.matcols), line(p.line), matrix(p.matrix),
      array(p.array), arraySize(p.arraySize), structure(0), structureSize(0), maxArraySize(0),
      arrayInformationType(0), fieldName(0), mangled(0), typeName(0), semantic(0)
   {
      if (p.userDef)
      {
         structure = p.userDef->getStruct();
		  line = p.userDef->line;
         typeName = NewPoolTString(p.userDef->getTypeName().c_str());
      }
      checkInvariants();
   }
   explicit TType(TTypeList* userDef, const TString& n, TPrecision p = EbpUndefined, const TSourceLoc& l = gNullSourceLoc) :
      type(EbtStruct), precision(p), qualifier(EvqTemporary), matrows(1), matcols(1), line(l), matrix(false), array(false), arraySize(0),
      structure(userDef), maxArraySize(0), arrayInformationType(0), fieldName(0), mangled(0), semantic(0)
   {
      typeName = NewPoolTString(n.c_str());
      checkInvariants();
   }

   TType(const TType& t) { *this = t; checkInvariants(); }

   void copyType(const TType& copyOf, TStructureMap& remapper)
   {
      type = copyOf.type;
	  precision = copyOf.precision;
      qualifier = copyOf.qualifier;
      matrows = copyOf.matrows;
      matcols = copyOf.matcols;
      matrix = copyOf.matrix;
      array = copyOf.array;
      arraySize = copyOf.arraySize;
	   line = copyOf.line;

      TStructureMap::iterator iter;
      if (copyOf.structure)
      {
         if ((iter = remapper.find(structure)) == remapper.end())
         {
            // create the new structure here
            structure = NewPoolTTypeList();
            for (unsigned int i = 0; i < copyOf.structure->size(); ++i)
            {
               TTypeLine typeLine;
               typeLine.line = (*copyOf.structure)[i].line;
               typeLine.type = (*copyOf.structure)[i].type->clone(remapper);
               structure->push_back(typeLine);
            }
         }
         else
         {
            structure = iter->second;
         }
      }
      else
         structure = 0;

      fieldName = 0;
      if (copyOf.fieldName)
         fieldName = NewPoolTString(copyOf.fieldName->c_str());
      typeName = 0;
      if (copyOf.typeName)
         typeName = NewPoolTString(copyOf.typeName->c_str());
      semantic = 0;
      if (copyOf.semantic)
         semantic = NewPoolTString(copyOf.semantic->c_str());

      mangled = 0;
      if (copyOf.mangled)
         mangled = NewPoolTString(copyOf.mangled->c_str());

      structureSize = copyOf.structureSize;
      maxArraySize = copyOf.maxArraySize;
      assert(copyOf.arrayInformationType == 0);
      arrayInformationType = 0; // arrayInformationType should not be set for builtIn symbol table level

      checkInvariants();
   }

   TType* clone(TStructureMap& remapper)
   {
      TType *newType = new TType();
      newType->copyType(*this, remapper);

      return newType;
   }

   void setType(TBasicType t, int cols, int rows, bool m, bool a, int aS = 0)
   {
      type = t; matcols = cols; matrows = rows; matrix = m; array = a; arraySize = aS;
   }
   void setType(TBasicType t, int cols, int rows, bool m, TType* userDef = 0)
   {
      type = t; 
      matcols = cols; 
      matrows = rows; 
      matrix = m; 
      if (userDef)
         structure = userDef->getStruct();
      // leave array information intact.
   }
   void setTypeName(const TString& n)
   {
      typeName = NewPoolTString(n.c_str());
   }
   void setFieldName(const TString& n)
   {
      fieldName = NewPoolTString(n.c_str());
   }
   const TString& getTypeName() const
   {
      assert(typeName);          
      return *typeName; 
   }

   const TString& getFieldName() const
   {
      assert(fieldName);
      return *fieldName; 
   }

   TBasicType getBasicType() const { return type; }
   TPrecision getPrecision() const { return precision; }
   TQualifier getQualifier() const { return qualifier; }
   const TSourceLoc& getLine() const { return line; }

   void setBasicType(TBasicType t) { type = t; }
   void setPrecision(TPrecision p) { precision = p; }
   void changeQualifier(TQualifier q) { qualifier = q; }

   int getColsCount() const { return matcols; }
   void setColsCount(int count) { matcols = count; }

   int getRowsCount() const { return matrows; }
   void setRowsCount(int count) { matrows = count; }

   // Full-dimensional size of single instance of type
   int getInstanceSize() const
   {
      if (matrix)
         return matrows * matcols;
      else
      {
          assert(matcols == 1);
          return matrows;
      }
   }

   bool isScalar() const
   {
       return !isMatrix() && !isArray() && !isVector();
   }

   bool isMatrix() const { return matrix ? true : false; }
   void setMatrix(bool m) { matrix = m; }
   void setArray(bool is_array) { array = is_array; }
   bool isArray() const { return array ? true : false; }
   int getArraySize() const { return arraySize; }
   void setArraySize(int s) { array = true; arraySize = s; }
   void setMaxArraySize (int s) { maxArraySize = s; }
   int getMaxArraySize () const { return maxArraySize; }
   void clearArrayness() { array = false; arraySize = 0; maxArraySize = 0; }
   void setArrayInformationType(TType* t) { arrayInformationType = t; }
   TType* getArrayInformationType() { return arrayInformationType; }
   bool isVector() const { return matrows > 1 && !matrix; }
   static const char* getBasicString(TBasicType t)
   {
      switch (t)
      {
      case EbtVoid:              return "void";              break;
      case EbtFloat:             return "float";             break;
      case EbtInt:               return "int";               break;
      case EbtBool:              return "bool";              break;
      case EbtSampler1D:         return "sampler1D";         break;
      case EbtSampler2D:         return "sampler2D";         break;
      case EbtSampler3D:         return "sampler3D";         break;
      case EbtSamplerCube:       return "samplerCube";       break;
      case EbtSampler1DShadow:   return "sampler1DShadow";   break;
      case EbtSampler2DShadow:   return "sampler2DShadow";   break;
      case EbtSampler2DArray:    return "sampler2DArray";   break;
      case EbtSamplerRect:       return "samplerRect";       break; // ARB_texture_rectangle
      case EbtSamplerRectShadow: return "samplerRectShadow"; break; // ARB_texture_rectangle
      case EbtStruct:            return "structure";         break;
      default:                   return "unknown type";
      }
   }
   TTypeList* getStruct() const { return structure; }
   void setStruct(TTypeList* s) { structure = s; }
	
   int getObjectSize() const
   {
      int totalSize;

      if (getBasicType() == EbtStruct)
         totalSize = getStructSize();
      else if (matrix)
         totalSize = matrows * matcols;
      else
         totalSize = matrows;

      if (isArray())
         totalSize *= Max(getArraySize(), getMaxArraySize());

      return totalSize;
   }

   TString& getMangledName()
   {
      if (!mangled)
      {
         mangled = NewPoolTString("");
         buildMangledName(*mangled);            
         *mangled += ';' ;
      }

      return *mangled;
   }
   bool sameElementType(const TType& right) const
   {
      return      type == right.type &&
      matrows == right.matrows &&
      matcols == right.matcols &&
      matrix == right.matrix &&
      structure == right.structure;
   }
   bool operator==(const TType& right) const
   {
      return      type == right.type   &&
      matrows == right.matrows &&
      matcols == right.matcols &&
      matrix == right.matrix &&
      array == right.array  && (!array || arraySize == right.arraySize) &&
      structure == right.structure;
      // don't check the qualifier, it's not ever what's being sought after
   }
   bool operator!=(const TType& right) const
   {
      return !operator==(right);
   }
   const char* getBasicString() const { return TType::getBasicString(type); }
   const char* getQualifierString() const { return ::getQualifierString(qualifier); }
   TString getCompleteString() const;

   const TString& getSemantic() const { return *semantic; }
   void setSemantic( const TString &s) { semantic = NewPoolTString(s.c_str()); }
   bool hasSemantic() const { return semantic != 0; }

   void checkInvariants() const
   {
       if (matrix)
       {
           assert(matcols >= 2 && matcols <= 4);
           assert(matrows >= 2 && matrows <= 4);
       }
       else
       {
           assert(matcols == 1);
           assert(matrows >= 1 && matrows <= 4);
       }
   }

   void buildMangledName(TString&) const;

   // Determine the parameter compatibility between this type and the parameter type
   ECompatibility determineCompatibility ( const TType *pType ) const;

private:
   int getStructSize() const;

   TPrecision precision;
   TBasicType type      : 6;
   TQualifier qualifier : 7;
   int matrows          : 8;
   int matcols          : 8;
   unsigned int matrix  : 1;
   unsigned int array   : 1;
   int arraySize;
   TSourceLoc line;

   TTypeList* structure;      // 0 unless this is a struct
   mutable int structureSize;
   int maxArraySize;
   TType* arrayInformationType;
   TString *fieldName;         // for structure field names
   TString *mangled;
   TString *typeName;          // for structure field type name
   TString *semantic; //for semantics on structure fields
};


class TAnnotation
{
public:
	POOL_ALLOCATOR_NEW_DELETE(GlobalPoolAllocator)
	TAnnotation() { }

	size_t getKeyCount() const { return keys.size(); }
	const TString& getKey(size_t i) const { return keys[i]; }
	void addKey(const TString& key) { keys.push_back(key); }

private:
	TVector<TString> keys;
};



class TTypeInfo
{
public:
	POOL_ALLOCATOR_NEW_DELETE(GlobalPoolAllocator)
	TTypeInfo( const TString &s, TAnnotation *ann) : semantic(s), annotation(ann)
	{
	}
	TTypeInfo( const TString &s, const TString &r, TAnnotation *ann) : semantic(s), registerSpec(r), annotation(ann)
	{
	}
	~TTypeInfo() { } // deallocation should be handled by the pool

	const TString& getSemantic() const { return semantic; }
	const TString& getRegister() const { return registerSpec; }
	const TAnnotation* getAnnotation() const { return annotation; }

private:
	// forbid copying
	TTypeInfo();
	TTypeInfo(const TTypeInfo &);

	TString semantic;
	TString registerSpec;
	TAnnotation *annotation;
};

}

#endif // _TYPES_INCLUDED_
