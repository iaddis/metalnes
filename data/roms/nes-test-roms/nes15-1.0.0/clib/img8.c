/*
 * File: img8.c
 * Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
 *
 * 8bpp image library implementation
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "img8.h"



struct img8_image *img8_new(int w, int h)
{
	struct img8_image *img;

	assert(w > 0 && h > 0);

	if ((img = malloc(sizeof *img)) == NULL) {
		fprintf(stderr, "Unable to allocate new image\n");
		return NULL;
	}

	if ((img->data = malloc(sizeof *img->data * w * h)) == NULL) {
		fprintf(stderr, "Unable to allocate new image data\n");
		free(img);
		return NULL;
	}

	img->w = w;
	img->h = h;

	assert(img->w == w);
	assert(img->h == h);
	assert(img->data != NULL);

	return img;
}



void img8_free(struct img8_image *img)
{
	assert(img->data != NULL);
	assert(img != NULL);

	free(img->data);
	free(img);
}

