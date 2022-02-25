/*
 * File: neschr.h
 * Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
 *
 * NES CHR image library
 */

#ifndef NESCHR_H
#define NESCHR_H

#include <stdlib.h>



#define NESCHR_BPP		2
#define NESCHR_TILE_SIZE	8
#define NESCHR_NUM_PLANES	2
#define NESCHR_TILE_BYTES	(NESCHR_TILE_SIZE * NESCHR_NUM_PLANES)



struct binio_file;
struct img8_image;

/*
 * CHR image created and freed by the library. Its members are considered
 * read-only.
 */
struct neschr_chr {
	size_t size;
	unsigned char *data;
};



/*
 * Creates a new CHR image with the size 'size'.
 *
 * Returns: If the CHR image was created successfully, it is returned.
 * Otherwise, NULL is returned and an error message is printed to 'stderr'.
 *
 * Asserts:
 *	size > 0
 * 	Returned 'neschr_chr' is valid
 */
struct neschr_chr *neschr_new(size_t size);

/*
 * Frees the CHR image 'chr'.
 *
 * Asserts:
 *	chr != NULL
 *	chr->data != NULL
 */
void neschr_free(struct neschr_chr *chr);

/*
 * Reads a new CHR image from the file 'file'.
 *
 * Returns: If the CHR image was successfully created and read, it is
 * returned. Otherwise, NULL is returned and an error message is printed to
 * 'stderr'.
 *
 * Asserts:
 *	file != NULL
 * 	Returned 'neschr_chr' is valid
 */
struct neschr_chr *neschr_read_file(const char *file);

/*
 * Reads a new CHR image from the file 'bf' with the size 'size'. If the end of
 * the file was reached before reading is complete, the file handle's 'eof'
 * member will be set to a non-zero value. If an error occurred while reading,
 * the file handle's 'error' member will be set to a non-zero value and an
 * error message will be printed to 'stderr'.
 *
 * Returns: If the CHR image was successfully created, it is returned.
 * Otherwise, NULL is returned and an error message is printed to 'stderr'.
 *
 * Asserts:
 *	bf != NULL
 *	size > 0
 * 	Returned 'neschr_chr' is valid
 */
struct neschr_chr *neschr_read(struct binio_file *bf, size_t size);

/*
 * Writes the CHR image 'chr' to the file 'file'.
 *
 * Returns: If the CHR image was successfully written, a non-zero value is
 * returned. Otherwise, zero is returned and an error message is printed to
 * 'stderr'.
 *
 * Asserts:
 *	file != NULL
 *	chr != NULL
 */
int neschr_write_file(const char *file, const struct neschr_chr *chr);

/*
 * Writes the CHR image 'chr' to the binary file 'bf'. If an error occurs while
 * writing, the file handle's 'error' member will be set to a non-zero value
 * and an error message will be printed to 'stderr'.
 *
 * Asserts:
 *	bf != NULL
 *	chr != NULL
 */
void neschr_write(struct binio_file *bf, const struct neschr_chr *chr);

/*
 * Creates a new CHR image from the 8bpp image 'img'. If 'ver' is set to a
 * non-zero value, the 8bpp image is read from top to bottom as opposed to left
 * to right.
 *
 * Returns: If the CHR image was created successfully, it is returned.
 * Otherwise, NULL is returned and an error message is printed to 'stderr'.
 *
 * Asserts:
 *	img != NULL
 * 	Returned 'neschr_chr' is valid
 */
struct neschr_chr *neschr_from_img8(const struct img8_image *img, int ver);

/*
 * Tests if the CHR image 'chr1' contains the same data as the CHR image
 * 'chr2'.
 *
 * Returns: If both images contain the same data, then a non-zero value is
 * returned. Otherwise, zero is returned.
 *
 * Asserts:
 *	chr1 != NULL
 *	chr2 != NULL
 */
int neschr_is_equal(const struct neschr_chr *chr1,
	const struct neschr_chr *chr2);

#endif /* NESCHR_H */

