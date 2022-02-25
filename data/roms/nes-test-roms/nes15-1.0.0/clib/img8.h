/*
 * File: img8.h
 * Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
 *
 * 8bpp image library
 */

#ifndef IMG8_H
#define IMG8_H

#define IMG8_PAL_SIZE		256



struct binio_file;

/*
 * 8bpp image created and freed by the library. Its members are considered
 * read-only.
 */
struct img8_image {
	int w, h;
	unsigned char *data;
};

/*
 * Used to represent palette entries for 8bpp images.
 */
struct img8_color {
	unsigned char r, g, b;
};



/*
 * Creates a new image with the width 'w' and the height 'h'.
 *
 * Returns: If the image was created successfully, it is returned. Otherwise,
 * NULL is returned and an error message is printed to 'stderr'.
 *
 * Asserts:
 *	w > 0 && h > 0
 * 	Returned 'img8_image' is valid
 */
struct img8_image *img8_new(int w, int h);

/*
 * Frees the image 'img'.
 *
 * Asserts:
 *	img != NULL
 *	img->data != NULL
 */
void img8_free(struct img8_image *img);

/*
 * Reads a new image from the 256 color PCX file 'bf' and stores the palette
 * read in pal. If 'pal' is NULL, then the palette will not be read. If the end
 * of the file was reached before reading is complete, the file handle's 'eof'
 * member will be set to a non-zero value. If an error occurred while reading,
 * the file handle's 'error' member will be set to a non-zero value and an
 * error message will be printed to 'stderr'.
 *
 * Returns: If the image was successfully created, it is returned. Otherwise,
 * NULL is returned and an error message is printed to 'stderr'.
 *
 * Asserts:
 *	file != NULL
 */
struct img8_image *img8_read_pcx_file(const char *file,
	struct img8_color *pal);

/*
 * Reads a new image from the 256 color PCX binary file 'bf' and stores the
 * palette read in 'pal'. If 'pal' is NULL, then the palette will not be read.
 *
 * Returns: If the image was successfully created and read, it is returned.
 * Otherwise, NULL is returned and an error message is printed to 'stderr'.
 *
 * Asserts:
 *	bf != NULL
 */
struct img8_image *img8_read_pcx(struct binio_file *bf,
	struct img8_color *pal);

#endif /* IMG8_H */

