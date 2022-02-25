/*
 * File: img8_pcx.c
 * Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
 *
 * PCX image loading and saving functions for 'img8'
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "binio.h"

#include "img8.h"



#define COLOR_MAP_SIZE	48
#define FILLER_SIZE	54



struct pcx_header {
	unsigned char man;
	unsigned char ver;
	unsigned char enc;
	unsigned char bpp;
	unsigned short x_min, y_min, x_max, y_max;
	unsigned short h_dpi, v_dpi;
	unsigned char color_map[COLOR_MAP_SIZE];
	unsigned char res;
	unsigned char num_planes;
	unsigned short bpl;
	unsigned short pal_info;
	unsigned short h_scr_size;
	unsigned short v_scr_size;
	unsigned char filler[FILLER_SIZE];
};



/*
 * Reads the PCX header from the binary file 'bf' and stores it in 'h'.
 *
 * Returns: If the PCX header was read successfully and is valid, then a
 * non-zero is returned. Otherwise, zero is returned and an error message is
 * printed to 'stderr'.
 *
 * Asserts:
 *	bf != NULL
 *	h != NULL
 */
static int read_pcx_header(struct binio_file *bf, struct pcx_header *h);



struct img8_image *img8_read_pcx_file(const char *file, struct img8_color *pal)
{
	struct binio_file *bf;
	struct img8_image *img;
	int success;

	assert(file != NULL);

	if ((bf = binio_from_file(file, "rb")) == NULL) {
		return NULL;
	}

	img = img8_read_pcx(bf, pal);
	binio_close(bf);

	if (img == NULL) {
		return NULL;
	}

	success = !(bf->error || bf->eof);

	if (bf->eof) {
		fprintf(stderr, "Error reading \"%s\", File truncated\n",
                        bf->name);
	}

	if (!success) {
		img8_free(img);
		return NULL;
	}

	return img;
}



struct img8_image *img8_read_pcx(struct binio_file *bf, struct img8_color *pal)
{
	struct pcx_header header;
	struct img8_image *img;
	unsigned char *dst;
	unsigned char u8;
	int h;
	int i;
	int c = 0;

	assert(bf != NULL);

	if (!read_pcx_header(bf, &header)) {
		return NULL;
	}

	if ((img = img8_new(header.x_max - header.x_min + 1,
		header.y_max - header.y_min + 1)) == NULL) {
		return NULL;
	}

	dst = img->data;

	for (h = 0; h < img->h; h++) {
		i = 0;

		while (i < header.bpl) {
			u8 = binio_read_u8(bf);

			if ((u8 & 0xC0) == 0xC0) {
				c = u8 & 0x3F;
				u8 = binio_read_u8(bf);
			} else {
				c = 1;
			}

			while (c-- > 0) {
				dst[i++] = u8;
			}
		}

		dst += img->w;
	}

	binio_read_u8(bf);

	if (pal != NULL) {
		for (i = 0; i < IMG8_PAL_SIZE; i++) {
			pal[i].r = binio_read_u8(bf);
			pal[i].g = binio_read_u8(bf);
			pal[i].b = binio_read_u8(bf);
		}
	}

	return img;
}



static int read_pcx_header(struct binio_file *bf, struct pcx_header *h)
{
	assert(bf != NULL);
	assert(h != NULL);

	h->man = binio_read_u8(bf);
	h->ver = binio_read_u8(bf);
	h->enc = binio_read_u8(bf);
	h->bpp = binio_read_u8(bf);
	h->x_min = binio_read_u16le(bf);
	h->y_min = binio_read_u16le(bf);
	h->x_max = binio_read_u16le(bf);
	h->y_max = binio_read_u16le(bf);
	h->h_dpi = binio_read_u16le(bf);
	h->v_dpi = binio_read_u16le(bf);

	binio_read(bf, h->color_map, COLOR_MAP_SIZE);

	h->res = binio_read_u8(bf);
	h->num_planes = binio_read_u8(bf);
	h->bpl = binio_read_u16le(bf);
	h->pal_info = binio_read_u16le(bf);
	h->h_scr_size = binio_read_u16le(bf);
	h->v_scr_size = binio_read_u16le(bf);

	binio_read(bf, h->filler, FILLER_SIZE);

	if (bf->error) {
		return 0;
	}

	if (bf->eof) {
		fprintf(stderr, "Error reading \"%s\", Header truncated\n",
                        bf->name);
		return 0;
	}

	if (h->man != 10 || h->ver != 5 || h->enc != 1 || h->bpp != 8
		|| h->num_planes != 1) {
		fprintf(stderr, "Error reading \"%s\", Not a valid 256 "
			"color PCX file\n", bf->name);
		return 0;
	}

	return 1;
}

