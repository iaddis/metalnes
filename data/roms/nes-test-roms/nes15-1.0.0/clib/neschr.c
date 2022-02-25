/*
 * File: neschr.c
 * Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
 *
 * NES CHR image library implementation
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "binio.h"
#include "img8.h"

#include "neschr.h"



/*
 * Reads a CHR tile into the CHR image 'chr' at 'dst' from the 8bpp image 'img'
 * starting from the top-left corner 'sx' and 'sy'.
 *
 * Asserts:
 *	chr != NULL
 *	img != NULL
 *	dst < chr->size
 * 	sx >= 0 && sx < img->w && sy >= 0 && sy < img->h
 */
static void tile_from_img8(struct neschr_chr *chr,
	const struct img8_image *img, size_t dst, int sx, int sy);



struct neschr_chr *neschr_new(size_t size)
{
	struct neschr_chr *chr;

	assert(size > 0);

	if ((chr = malloc(sizeof *chr)) == NULL) {
		fprintf(stderr, "Unable to allocate new NES CHR\n");
		return NULL;
	}

	if ((chr->data = malloc(sizeof *chr->data * size)) == NULL) {
		fprintf(stderr, "Unable to allocate new NES CHR data\n");
		free(chr);
		return NULL;
	}

	chr->size = size;

	assert(chr->size == size);
	assert(chr->data != NULL);

	return chr;
}



void neschr_free(struct neschr_chr *chr)
{
	assert(chr != NULL);
	assert(chr->data != NULL);

	free(chr->data);
	free(chr);
}



struct neschr_chr *neschr_read_file(const char *file)
{
	struct neschr_chr *chr;
	unsigned char *data;
	size_t size;

	assert(file != NULL);

	if ((chr = malloc(sizeof *chr)) == NULL) {
		fprintf(stderr, "Unable to allocate new NES CHR\n");
		return NULL;
	}

	if ((data = binio_read_file(file, &size)) == NULL) {
		free(chr);
		return NULL;
	}

	chr->size = size;
	chr->data = data;

	assert(chr->size == size);
	assert(chr->data != NULL);

	return chr;
}



struct neschr_chr *neschr_read(struct binio_file *bf, size_t size)
{
	struct neschr_chr *chr;

	assert(bf != NULL);
	assert(size > 0);

	if ((chr = neschr_new(size)) == NULL) {
		return NULL;
	}

	binio_read(bf, chr->data, size);

	assert(chr->size == size);
	assert(chr->data != NULL);

	return chr;
}



int neschr_write_file(const char *file, const struct neschr_chr *chr)
{
	assert(file != NULL);
	assert(chr != NULL);

	return binio_write_file(file, chr->data, chr->size);
}



void neschr_write(struct binio_file *bf, const struct neschr_chr *chr)
{
	assert(bf != NULL);
	assert(chr != NULL);

	binio_write(bf, chr->data, chr->size);
}



struct neschr_chr *neschr_from_img8(const struct img8_image *img, int ver)
{
	struct neschr_chr *chr;
	int x, y;
	int w = (img->w + 7) / 8 * 8;
	int h = (img->h + 7) / 8 * 8;
	size_t i = 0;

	assert(img != NULL);

	if ((chr = neschr_new(img->w * img->h / (NESCHR_TILE_SIZE
		* NESCHR_TILE_SIZE) * NESCHR_TILE_BYTES)) == NULL) {
		return NULL;
	}

	if (!ver) {
		for (y = 0; y < h; y += NESCHR_TILE_SIZE) {
			for (x = 0; x < w; x += NESCHR_TILE_SIZE) {
				tile_from_img8(chr, img, i, x, y);
				i += NESCHR_TILE_BYTES;
			}
		}
	} else {
		for (x = 0; x < w; x += NESCHR_TILE_SIZE) {
			for (y = 0; y < h; y += NESCHR_TILE_SIZE) {
				tile_from_img8(chr, img, i, x, y);
				i += NESCHR_TILE_BYTES;
			}
		}
	}

	assert(chr->size == i);
	assert(chr->data != NULL);

	return chr;
}



int neschr_is_equal(const struct neschr_chr *chr1,
	const struct neschr_chr *chr2)
{
	assert(chr1 != NULL);
	assert(chr2 != NULL);

	if (chr1->size != chr2->size) {
		return 0;
	}

	return !memcmp(chr1->data, chr2->data, chr1->size);
}



static void tile_from_img8(struct neschr_chr *chr,
	const struct img8_image *img, size_t dst, int sx, int sy)
{
	int p;
	int x, y;
	unsigned char u8;

	assert(chr != NULL);
	assert(img != NULL);
	assert(dst < chr->size);
	assert(sx >= 0 && sx < img->w && sy >= 0 && sy < img->h);

	for (p = 0; p < NESCHR_NUM_PLANES; p++) {
		for (y = sy; y < sy + NESCHR_TILE_SIZE; y++) {
			u8 = 0;

			for (x = sx; x < sx + NESCHR_TILE_SIZE; x++) {
				u8 <<= 1;
				u8 |= (img->data[x + y * img->w] >> p) & 1;
			}

			chr->data[dst++] = u8;
		}
	}
}

