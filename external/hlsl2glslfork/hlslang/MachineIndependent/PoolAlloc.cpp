// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#include "../Include/PoolAlloc.h"
#include "../Include/Common.h"

#include "../Include/InitializeGlobals.h"
#include "osinclude.h"

static OS_TLSIndex s_TLSPoolAlloc;


void InitializeGlobalPools()
{
	TPoolAllocator* alloc = static_cast<TPoolAllocator*>(OS_GetTLSValue(s_TLSPoolAlloc));
	if (alloc)
		return;
	
	alloc = new TPoolAllocator();
	OS_SetTLSValue(s_TLSPoolAlloc, alloc);
	alloc->push();
}

void FreeGlobalPools()
{
	TPoolAllocator* alloc = static_cast<TPoolAllocator*>(OS_GetTLSValue(s_TLSPoolAlloc));
	if (!alloc)
		return;

	alloc->popAll();
	delete alloc;
	OS_SetTLSValue(s_TLSPoolAlloc, NULL);
}

bool InitializePoolIndex()
{
	if ((s_TLSPoolAlloc = OS_AllocTLSIndex()) == OS_INVALID_TLS_INDEX)
		return false;
	return true;
}

void FreePoolIndex()
{
	OS_FreeTLSIndex(s_TLSPoolAlloc);
}

TPoolAllocator& GetGlobalPoolAllocator()
{
	TPoolAllocator* alloc = static_cast<TPoolAllocator*>(OS_GetTLSValue(s_TLSPoolAlloc));
	return *alloc;
}

void SetGlobalPoolAllocatorPtr(TPoolAllocator* alloc)
{
	OS_SetTLSValue(s_TLSPoolAlloc, alloc);
}




struct TPoolAllocator::AllocHeader
{
	AllocHeader(AllocHeader* np, size_t pcount) : nextPage(np), pageCount(pcount) { }
	AllocHeader* nextPage;
	size_t pageCount;
};


TPoolAllocator::TPoolAllocator() :
pageSize(8*1024),
alignment(16),
freeList(0),
inUseList(0),
numCalls(0),
totalBytes(0)
{
   //
   // Don't allow page sizes we know are smaller than all common
   // OS page sizes.
   //
   if (pageSize < 4*1024)
      pageSize = 4*1024;

   //
   // A large currentPageOffset indicates a new page needs to
   // be obtained to allocate memory.
   //
   currentPageOffset = pageSize;

   //
   // Adjust alignment to be at least pointer aligned and
   // power of 2.
   //
   size_t minAlign = sizeof(void*);
   alignment &= ~(minAlign - 1);
   if (alignment < minAlign)
      alignment = minAlign;
   size_t a = 1;
   while (a < alignment)
      a <<= 1;
   alignment = a;
   alignmentMask = a - 1;

   //
   // Align header skip
   //
   headerSkip = minAlign;
   if (headerSkip < sizeof(AllocHeader))
   {
      headerSkip = (sizeof(AllocHeader) + alignmentMask) & ~alignmentMask;
   }
}

TPoolAllocator::~TPoolAllocator()
{
	assert(inUseList == NULL);

	// Always delete the free list memory - it can't be being
	// (correctly) referenced, whether the pool allocator was
	// global or not.
	while (freeList)
	{
		AllocHeader* next = freeList->nextPage;
		delete [] reinterpret_cast<char*>(freeList);
		freeList = next;
	}
}


void TPoolAllocator::push()
{
   AllocState state = { currentPageOffset, inUseList };

   stack.push_back(state);

   //
   // Indicate there is no current page to allocate from.
   //
   currentPageOffset = pageSize;
}

//
// Do a mass-deallocation of all the individual allocations
// that have occurred since the last push(), or since the
// last pop(), or since the object's creation.
//
// The deallocated pages are saved for future allocations.
//
void TPoolAllocator::pop()
{
   if (stack.size() < 1)
      return;

   AllocHeader* page = stack.back().page;
   currentPageOffset = stack.back().offset;

   while (inUseList != page)
   {
      // invoke destructor to free allocation list
      inUseList->~AllocHeader();

      AllocHeader* nextInUse = inUseList->nextPage;
      if (inUseList->pageCount > 1)
         delete [] reinterpret_cast<char*>(inUseList);
      else
      {
         inUseList->nextPage = freeList;
         freeList = inUseList;
      }
      inUseList = nextInUse;
   }

   stack.pop_back();
}

//
// Do a mass-deallocation of all the individual allocations
// that have occurred.
//
void TPoolAllocator::popAll()
{
   while (stack.size() > 0)
      pop();
}

void* TPoolAllocator::allocate(size_t numBytes)
{
   size_t allocationSize = numBytes;

   //
   // Just keep some interesting statistics.
   //
   ++numCalls;
   totalBytes += numBytes;

   //
   // Do the allocation, most likely case first, for efficiency.
   // This step could be moved to be inline sometime.
   //
   if (currentPageOffset + allocationSize <= pageSize)
   {
      //
      // Safe to allocate from currentPageOffset.
      //
      unsigned char* memory = reinterpret_cast<unsigned char *>(inUseList) + currentPageOffset;
      currentPageOffset += allocationSize;
      currentPageOffset = (currentPageOffset + alignmentMask) & ~alignmentMask;

      return memory;
   }

   if (allocationSize + headerSkip > pageSize)
   {
      //
      // Do a multi-page allocation.  Don't mix these with the others.
      // The OS is efficient and allocating and free-ing multiple pages.
      //
      size_t numBytesToAlloc = allocationSize + headerSkip;
      AllocHeader* memory = reinterpret_cast<AllocHeader*>(::new char[numBytesToAlloc]);
      if (memory == 0)
         return 0;

      // Use placement-new to initialize header
      new(memory) AllocHeader(inUseList, (numBytesToAlloc + pageSize - 1) / pageSize);
      inUseList = memory;

      currentPageOffset = pageSize;  // make next allocation come from a new page

      return reinterpret_cast<void*>(reinterpret_cast<UINT_PTR>(memory) + headerSkip);
   }

   //
   // Need a simple page to allocate from.
   //
   AllocHeader* memory;
   if (freeList)
   {
      memory = freeList;
      freeList = freeList->nextPage;
   }
   else
   {
      memory = reinterpret_cast<AllocHeader*>(::new char[pageSize]);
      if (memory == 0)
         return 0;
   }

   // Use placement-new to initialize header
   new(memory) AllocHeader(inUseList, 1);
   inUseList = memory;

   unsigned char* ret = reinterpret_cast<unsigned char *>(inUseList) + headerSkip;
   currentPageOffset = (headerSkip + allocationSize + alignmentMask) & ~alignmentMask;

   return ret;
}
