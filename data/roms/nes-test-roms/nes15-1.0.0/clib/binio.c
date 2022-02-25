/*
 * File: binio.c
 * Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
 *
 * Binary file I/O library implementation
 */

#include <assert.h>
#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "binio.h"



#if UCHAR_MAX > 0xFFU
#	error 'binio' requires 8 bit chars
#endif

typedef unsigned char uint8;
typedef signed char int8;

#if USHRT_MAX > 0xFFFFU
#	error 'binio' requires 16 bit shorts
#endif

typedef unsigned short uint16;
typedef short int16;

#if ULONG_MAX == 0xFFFFFFFFUL

typedef unsigned long uint32;
typedef long int32;

#elif UINT_MAX == 0xFFFFFFFFUL

typedef unsigned int uint32;
typedef int int32;

#else
#	error 'binio' requires either 32 bit longs or 32 bit ints
#endif



struct binio_file *binio_from_file(const char *file, const char *mode)
{
	struct binio_file *bf;

	assert(file != NULL);
	assert(mode != NULL);

	if ((bf = malloc(sizeof *bf)) == NULL) {
		fprintf(stderr, "Unable to allocate new file handle\n");
		return NULL;
	}

	if ((bf->fp = fopen(file, mode)) == NULL) {
		fprintf(stderr, "Error opening \"%s\", %s\n", file,
			strerror(errno));
		return NULL;
	}

	bf->name = file;
	bf->eof = bf->error = 0;

	assert(bf->fp != NULL);
	assert(bf->name == file);
	assert(bf->eof == 0);
	assert(bf->error == 0);

	return bf;
}



void binio_close(struct binio_file *bf)
{
	assert(bf != NULL);

	if (fclose(bf->fp) == EOF) {
		fprintf(stderr, "Error closing \"%s\", %s\n", bf->name,
			strerror(errno));
	}

	free(bf);
}



unsigned char *binio_read_file(const char *file, size_t *size)
{
	struct binio_file *bf;
	unsigned char *data;
	int success;

	assert(file != NULL);
	assert(size != NULL);

	if ((bf = binio_from_file(file, "rb")) == NULL) {
		return NULL;
	}

	if ((*size = binio_get_size(bf)) == 0) {
		binio_close(bf);
		return NULL;
	}

	if ((data = malloc(sizeof *data * *size)) == NULL) {
		fprintf(stderr, "Unable to allocate new binary buffer\n");
		binio_close(bf);
		return NULL;
	}

	binio_read(bf, data, *size);
	success = !(bf->error || bf->eof);

	if (bf->eof) {
		fprintf(stderr, "Error reading \"%s\", Unexpected EOF\n",
                        bf->name);
	}

	binio_close(bf);

	if (!success) {
		free(data);
		return NULL;
	}

	return data;
}



void binio_read(struct binio_file *bf, unsigned char *data, size_t size)
{
	size_t i;

	assert(bf != NULL);
	assert(data != NULL);
	assert(size > 0);

	for (i = 0; i < size; i++) {
		data[i] = binio_read_u8(bf);
	}
}



unsigned char binio_read_u8(struct binio_file *bf)
{
	uint8 u8;

	assert(bf != NULL);

	if (bf->eof || bf->error) {
		return 0;
	}

	if (fread(&u8, 1, 1, bf->fp) == 1) {
		return u8;
	}

	if (feof(bf->fp)) {
		bf->eof = 1;
	} else if (ferror(bf->fp)) {
		bf->error = 1;
		fprintf(stderr, "Error reading \"%s\", %s\n", bf->name,
			strerror(errno));
	}

	return 0;
}



signed char binio_read_s8(struct binio_file *bf)
{
	return (int8)binio_read_u8(bf);
}



unsigned short binio_read_u16le(struct binio_file *bf)
{
	uint16 u16;

	u16 = binio_read_u8(bf);
	u16 |= (uint16)binio_read_u8(bf) << 8;

	return u16;
}



short binio_read_s16le(struct binio_file *bf)
{
	return (int16)binio_read_u16le(bf);
}



unsigned short binio_read_u16be(struct binio_file *bf)
{
	uint16 u16;

	u16 = (uint16)binio_read_u8(bf) << 8;
	u16 |= binio_read_u8(bf);

	return u16;
}



short binio_read_s16be(struct binio_file *bf)
{
	return (int16)binio_read_u16be(bf);
}



unsigned long binio_read_u32le(struct binio_file *bf)
{
	uint32 u32;

	u32 = binio_read_u8(bf);
	u32 |= (uint32)binio_read_u8(bf) << 8;
	u32 |= (uint32)binio_read_u8(bf) << 16;
	u32 |= (uint32)binio_read_u8(bf) << 24;

	return u32;
}



long binio_read_s32le(struct binio_file *bf)
{
	return (int32)binio_read_u32le(bf);
}



unsigned long binio_read_u32be(struct binio_file *bf)
{
	uint32 u32;

	u32 = (uint32)binio_read_u8(bf) << 24;
	u32 |= (uint32)binio_read_u8(bf) << 16;
	u32 |= (uint32)binio_read_u8(bf) << 8;
	u32 |= binio_read_u8(bf);

	return u32;
}



long binio_read_s32be(struct binio_file *bf)
{
	return (int32)binio_read_u32be(bf);
}



int binio_write_file(const char *file, const unsigned char *data, size_t size)
{
	struct binio_file *bf;
	int success;

	if ((bf = binio_from_file(file, "wb")) == NULL) {
		return 0;
	}

	binio_write(bf, data, size);
	success = !bf->error;
	binio_close(bf);

	return success;
}



void binio_write(struct binio_file *bf, const unsigned char *data, size_t size)
{
	size_t i;

	assert(bf != NULL);
	assert(data != NULL);
	assert(size > 0);

	for (i = 0; i < size; i++) {
		binio_write_u8(bf, data[i]);
	}
}



void binio_write_u8(struct binio_file *bf, unsigned char u8)
{
	assert(bf != NULL);

	if (bf->error) {
		return;
	}

	if (fwrite(&u8, 1, 1, bf->fp) == 1) {
		return;
	}

	bf->error = 1;

	if (ferror(bf->fp)) {
		fprintf(stderr, "Error writing \"%s\", %s\n", bf->name,
			strerror(errno));
	}
}



void binio_write_s8(struct binio_file *bf, signed char s8)
{
	binio_write_u8(bf, (uint8)s8);
}



void binio_write_u16le(struct binio_file *bf, unsigned short u16)
{
	binio_write_u8(bf, (uint16)(u16 & 0xFF));
	binio_write_u8(bf, (uint16)(u16 >> 8 & 0xFF));
}



void binio_write_s16le(struct binio_file *bf, short s16)
{
	binio_write_u16le(bf, (uint16)s16);
}



void binio_write_u16be(struct binio_file *bf, unsigned short u16)
{
	binio_write_u8(bf, (uint16)(u16 >> 8 & 0xFF));
	binio_write_u8(bf, (uint16)(u16 & 0xFF));
}



void binio_write_s16be(struct binio_file *bf, short s16)
{
	binio_write_u16be(bf, (uint16)s16);
}



void binio_write_u32le(struct binio_file *bf, unsigned long u32)
{
	binio_write_u8(bf, (uint32)(u32 & 0xFF));
	binio_write_u8(bf, (uint32)(u32 >> 8 & 0xFF));
	binio_write_u8(bf, (uint32)(u32 >> 16 & 0xFF));
	binio_write_u8(bf, (uint32)(u32 >> 24 & 0xFF));
}



void binio_write_s32le(struct binio_file *bf, long s32)
{
	binio_write_u32le(bf, (uint32)s32);
}



void binio_write_u32be(struct binio_file *bf, unsigned long u32)
{
	binio_write_u8(bf, (uint32)(u32 >> 24 & 0xFF));
	binio_write_u8(bf, (uint32)(u32 >> 16 & 0xFF));
	binio_write_u8(bf, (uint32)(u32 >> 8 & 0xFF));
	binio_write_u8(bf, (uint32)(u32 & 0xFF));
}



void binio_write_s32be(struct binio_file *bf, long s32)
{
	binio_write_u32be(bf, (uint32)s32);
}



void binio_rewind(struct binio_file *bf)
{
	assert(bf != NULL);

	if (fseek(bf->fp, 0L, SEEK_SET) == -1) {
		bf->error = 1;
		fprintf(stderr, "Error rewinding \"%s\", %s\n", bf->name,
			strerror(errno));
	} else {
		bf->eof = 0;
	}
}



size_t binio_get_size(struct binio_file *bf)
{
	size_t size = 0;

	assert(bf != NULL);

	binio_read_u8(bf);

	while (!bf->eof) {
		binio_read_u8(bf);
		size++;
	}

	binio_rewind(bf);

	if (bf->error) {
		return 0;
	}

	return size;
}

