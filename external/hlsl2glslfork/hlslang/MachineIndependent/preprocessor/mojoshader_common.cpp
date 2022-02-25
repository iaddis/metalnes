#define __MOJOSHADER_INTERNAL__ 1
#include "mojoshader_internal.h"

// Stripped down code from Mojoshader, originally under zlib license.


// this is djb's xor hashing function.
static inline uint32 hash_string_djbxor(const char *str, size_t len)
{
    register uint32 hash = 5381;
    while (len--)
        hash = ((hash << 5) + hash) ^ *(str++);
    return hash;
} // hash_string_djbxor

static inline uint32 hlmojo_hash_string(const char *str, size_t len)
{
    return hash_string_djbxor(str, len);
} // hlmojo_hash_string



// The string cache...   !!! FIXME: use StringMap internally for this.

typedef struct hlmojo_StringBucket
{
    char *string;
    struct hlmojo_StringBucket *next;
} hlmojo_StringBucket;

struct hlmojo_StringCache
{
    hlmojo_StringBucket **hashtable;
    uint32 table_size;
    MOJOSHADER_hlslang_malloc m;
    MOJOSHADER_hlslang_free f;
    void *d;
};


const char *hlmojo_stringcache(hlmojo_StringCache *cache, const char *str)
{
    return hlmojo_stringcache_len(cache, str, strlen(str));
} // hlmojo_stringcache

static const char *hlmojo_stringcache_len_internal(hlmojo_StringCache *cache,
                                            const char *str,
                                            const unsigned int len,
                                            const int addmissing)
{
    const uint8 hash = hlmojo_hash_string(str, len) & (cache->table_size-1);
    hlmojo_StringBucket *bucket = cache->hashtable[hash];
    hlmojo_StringBucket *prev = NULL;
    while (bucket)
    {
        const char *bstr = bucket->string;
        if ((strncmp(bstr, str, len) == 0) && (bstr[len] == 0))
        {
            // Matched! Move this to the front of the list.
            if (prev != NULL)
            {
                assert(prev->next == bucket);
                prev->next = bucket->next;
                bucket->next = cache->hashtable[hash];
                cache->hashtable[hash] = bucket;
            } // if
            return bstr; // already cached
        } // if
        prev = bucket;
        bucket = bucket->next;
    } // while

    // no match!
    if (!addmissing)
        return NULL;

    // add to the table.
    bucket = (hlmojo_StringBucket *) cache->m(sizeof (hlmojo_StringBucket), cache->d);
    if (bucket == NULL)
        return NULL;
    bucket->string = (char *) cache->m(len + 1, cache->d);
    if (bucket->string == NULL)
    {
        cache->f(bucket, cache->d);
        return NULL;
    } // if
    memcpy(bucket->string, str, len);
    bucket->string[len] = '\0';
    bucket->next = cache->hashtable[hash];
    cache->hashtable[hash] = bucket;
    return bucket->string;
} // hlmojo_stringcache_len_internal

const char *hlmojo_stringcache_len(hlmojo_StringCache *cache, const char *str,
                            const unsigned int len)
{
    return hlmojo_stringcache_len_internal(cache, str, len, 1);
} // hlmojo_stringcache_len


hlmojo_StringCache *hlmojo_stringcache_create(MOJOSHADER_hlslang_malloc m, MOJOSHADER_hlslang_free f, void *d)
{
    const uint32 initial_table_size = 256;
    const size_t tablelen = sizeof (hlmojo_StringBucket *) * initial_table_size;
    hlmojo_StringCache *cache = (hlmojo_StringCache *) m(sizeof (hlmojo_StringCache), d);
    if (!cache)
        return NULL;
    memset(cache, '\0', sizeof (hlmojo_StringCache));

    cache->hashtable = (hlmojo_StringBucket **) m(tablelen, d);
    if (!cache->hashtable)
    {
        f(cache, d);
        return NULL;
    } // if
    memset(cache->hashtable, '\0', tablelen);

    cache->table_size = initial_table_size;
    cache->m = m;
    cache->f = f;
    cache->d = d;
    return cache;
} // hlmojo_stringcache_create

void hlmojo_stringcache_destroy(hlmojo_StringCache *cache)
{
    if (cache == NULL)
        return;

    MOJOSHADER_hlslang_free f = cache->f;
    void *d = cache->d;
    size_t i;

    for (i = 0; i < cache->table_size; i++)
    {
        hlmojo_StringBucket *bucket = cache->hashtable[i];
        cache->hashtable[i] = NULL;
        while (bucket)
        {
            hlmojo_StringBucket *next = bucket->next;
            f(bucket->string, d);
            f(bucket, d);
            bucket = next;
        } // while
    } // for

    f(cache->hashtable, d);
    f(cache, d);
} // hlmojo_stringcache_destroy



typedef struct hlmojo_BufferBlock
{
    uint8 *data;
    size_t bytes;
    struct hlmojo_BufferBlock *next;
} hlmojo_BufferBlock;

struct hlmojo_Buffer
{
    size_t total_bytes;
    hlmojo_BufferBlock *head;
    hlmojo_BufferBlock *tail;
    size_t block_size;
    MOJOSHADER_hlslang_malloc m;
    MOJOSHADER_hlslang_free f;
    void *d;
};

hlmojo_Buffer *hlmojo_buffer_create(size_t blksz, MOJOSHADER_hlslang_malloc m,
                      MOJOSHADER_hlslang_free f, void *d)
{
    hlmojo_Buffer *buffer = (hlmojo_Buffer *) m(sizeof (hlmojo_Buffer), d);
    if (buffer != NULL)
    {
        memset(buffer, '\0', sizeof (hlmojo_Buffer));
        buffer->block_size = blksz;
        buffer->m = m;
        buffer->f = f;
        buffer->d = d;
    } // if
    return buffer;
} // hlmojo_buffer_create


int hlmojo_buffer_append(hlmojo_Buffer *buffer, const void *_data, size_t len)
{
    const uint8 *data = (const uint8 *) _data;

    // note that we make the blocks bigger than blocksize when we have enough
    //  data to overfill a fresh block, to reduce allocations.
    const size_t blocksize = buffer->block_size;

    if (len == 0)
        return 1;

    if (buffer->tail != NULL)
    {
        const size_t tailbytes = buffer->tail->bytes;
        const size_t avail = (tailbytes >= blocksize) ? 0 : blocksize - tailbytes;
        const size_t cpy = (avail > len) ? len : avail;
        if (cpy > 0)
        {
            memcpy(buffer->tail->data + tailbytes, data, cpy);
            len -= cpy;
            data += cpy;
            buffer->tail->bytes += cpy;
            buffer->total_bytes += cpy;
            assert(buffer->tail->bytes <= blocksize);
        } // if
    } // if

    if (len > 0)
    {
        assert((!buffer->tail) || (buffer->tail->bytes >= blocksize));
        const size_t bytecount = len > blocksize ? len : blocksize;
        const size_t malloc_len = sizeof (hlmojo_BufferBlock) + bytecount;
        hlmojo_BufferBlock *item = (hlmojo_BufferBlock *) buffer->m(malloc_len, buffer->d);
        if (item == NULL)
            return 0;

        item->data = ((uint8 *) item) + sizeof (hlmojo_BufferBlock);
        item->bytes = len;
        item->next = NULL;
        if (buffer->tail != NULL)
            buffer->tail->next = item;
        else
            buffer->head = item;
        buffer->tail = item;

        memcpy(item->data, data, len);
        buffer->total_bytes += len;
    } // if

    return 1;
} // hlmojo_buffer_append

int hlmojo_buffer_append_fmt(hlmojo_Buffer *buffer, const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    const int retval = hlmojo_buffer_append_va(buffer, fmt, ap);
    va_end(ap);
    return retval;
} // hlmojo_buffer_append_fmt

int hlmojo_buffer_append_va(hlmojo_Buffer *buffer, const char *fmt, va_list va)
{
    char scratch[256];

    va_list ap;
    va_copy(ap, va);
    const int len = vsnprintf(scratch, sizeof (scratch), fmt, ap);
    va_end(ap);

    // If we overflowed our scratch buffer, heap allocate and try again.

    if (len == 0)
        return 1;  // nothing to do.
    else if (len < sizeof (scratch))
        return hlmojo_buffer_append(buffer, scratch, len);

    char *buf = (char *) buffer->m(len + 1, buffer->d);
    if (buf == NULL)
        return 0;
    va_copy(ap, va);
    vsnprintf(buf, len + 1, fmt, ap);  // rebuild it.
    va_end(ap);
    const int retval = hlmojo_buffer_append(buffer, scratch, len);
    buffer->f(buf, buffer->d);
    return retval;
} // hlmojo_buffer_append_va

size_t hlmojo_buffer_size(hlmojo_Buffer *buffer)
{
    return buffer->total_bytes;
} // hlmojo_buffer_size

void hlmojo_buffer_empty(hlmojo_Buffer *buffer)
{
    hlmojo_BufferBlock *item = buffer->head;
    while (item != NULL)
    {
        hlmojo_BufferBlock *next = item->next;
        buffer->f(item, buffer->d);
        item = next;
    } // while
    buffer->head = buffer->tail = NULL;
    buffer->total_bytes = 0;
} // hlmojo_buffer_empty

char *hlmojo_buffer_flatten(hlmojo_Buffer *buffer)
{
    char *retval = (char *) buffer->m(buffer->total_bytes + 1, buffer->d);
    if (retval == NULL)
        return NULL;
    hlmojo_BufferBlock *item = buffer->head;
    char *ptr = retval;
    while (item != NULL)
    {
        hlmojo_BufferBlock *next = item->next;
        memcpy(ptr, item->data, item->bytes);
        ptr += item->bytes;
        buffer->f(item, buffer->d);
        item = next;
    } // while
    *ptr = '\0';

    assert(ptr == (retval + buffer->total_bytes));

    buffer->head = buffer->tail = NULL;
    buffer->total_bytes = 0;

    return retval;
} // hlmojo_buffer_flatten

void hlmojo_buffer_destroy(hlmojo_Buffer *buffer)
{
    if (buffer != NULL)
    {
        MOJOSHADER_hlslang_free f = buffer->f;
        void *d = buffer->d;
        hlmojo_buffer_empty(buffer);
        f(buffer, d);
    } // if
} // hlmojo_buffer_destroy


// end of mojoshader_common.c ...

