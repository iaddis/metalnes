/*
 * File: packbits.c
 * Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
 *
 * Packbits encoding and decoding library implementation
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "binio.h"

#include "packbits.h"



unsigned char *packbits_read_file(const char *file, size_t *size)
{
	struct binio_file *bf;
	unsigned char *data;
	int success;

	assert(file != NULL);
	assert(size != NULL);

	if ((bf = binio_from_file(file, "rb")) == NULL) {
		return NULL;
	}

	if ((*size = packbits_get_size(bf)) == 0) {
		binio_close(bf);
		return NULL;
	}

	if ((data = malloc(sizeof *data * *size)) == NULL) {
		fprintf(stderr, "Unable to allocate decoded PackBits data\n");
		binio_close(bf);
		return NULL;
	}

	packbits_read(bf, data, *size);
	success = !(bf->error || bf->eof);

	if (bf->eof) {
		fprintf(stderr, "Error reading \"%s\", File truncated\n",
			bf->name);
	}

	binio_close(bf);

	if (!success) {
		free(data);
		return NULL;
	}

	return data;
}



void packbits_read(struct binio_file *bf, unsigned char *data, size_t size)
{
	signed char header;
	unsigned char *data_end = data + size;
	unsigned char u8;
	int i;

	assert(bf != NULL);
	assert(data != NULL);
	assert(size > 0);

	while ((header = binio_read_s8(bf)) != -128 && data != data_end) {
		if (header >= 0) {
			for (i = header + 1; i > 0; i--) {
				*data++ = binio_read_u8(bf);
			}
		} else {
			u8 = binio_read_u8(bf);

			for (i = 1 - header; i > 0; i--) {
				*data++ = u8;
			}
		}
	}
}



size_t packbits_write_file(const char *file, const unsigned char *data,
	size_t size)
{
	struct binio_file *bf;
	size_t out_size;

	assert(file != NULL);
	assert(data != NULL);
	assert(size > 0);

	if ((bf = binio_from_file(file, "wb")) == NULL) {
		return 0;
	}

	out_size = packbits_write(bf, data, size);
	binio_close(bf);

	return out_size;
}



size_t packbits_write(struct binio_file *bf, const unsigned char *data,
	size_t size)
{
	const unsigned char *data_end = data + size;
	const unsigned char *curr;
	size_t dst_size = 0;

	assert(bf != NULL);
	assert(data != NULL);
	assert(size > 0);

	while (data < data_end) {
		if (data < data_end - 1 && *data == *(data + 1)) {
			curr = data + 1;

			while (curr != data_end) {
				if (*curr != *(curr - 1)) {
					break;
				}

				if (curr - data >= 128) {
					break;
				}

				curr++;
			}

			binio_write_s8(bf, 1 - (curr - data));
			binio_write_u8(bf, *data);
			data = curr;
			dst_size += 2;
		} else {
			curr = data + 1;

			while (curr != data_end) {
				if (*curr == *(curr + 1)) {
					break;
				}

				if (curr - data >= 128) {
					break;
				}

				curr++;
			}

			binio_write_s8(bf, curr - data - 1);
			dst_size++;

			while (data < curr) {
				binio_write_u8(bf, *data++);
				dst_size++;
			}
		}
	}

	binio_write_s8(bf, -128);
	dst_size++;

	if (bf->error) {
		return 0;
	}

	return dst_size;
}



size_t packbits_get_size(struct binio_file *bf)
{
	size_t size = 0;
	signed char header;
	int i;

	assert(bf != NULL);

	while ((header = binio_read_s8(bf)) != -128 && !bf->eof) {
		if (header >= 0) {
			for (i = header + 1; i > 0; i--) {
				binio_read_u8(bf);
				size++;
			}
		} else {
			binio_read_u8(bf);
			size += 1 - header;
		}

	}

	binio_rewind(bf);

	if (bf->error) {
		return 0;
	}

	return size;
}

