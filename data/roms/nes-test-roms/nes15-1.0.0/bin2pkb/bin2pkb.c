/*
 * File: bin2pkb.c
 * Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
 *
 * Binary file to Packbits encoded file converter
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "binio.h"
#include "packbits.h"



/*
 * Reads the binary data stored in 'src_file' and writes it out in Packbits
 * encoding to 'dst_file'.
 *
 * Returns: If the conversion was successfully done, then a non-zero value is
 * returned. Otherwise, zero is returned and an error message is printed to
 * 'stderr'.
 *
 * Asserts:
 *	src_file != NULL
 *	dst_file != NULL
 */
static int bin2pkb(void);



static const char *src_file = NULL;
static const char *dst_file = NULL;



int main(int argc, char *argv[])
{
	if (argc == 1) {
		printf("Usage: bin2pkb [INFILE] [OUTFILE]\n");
		return EXIT_SUCCESS;
	}

	if (argc == 2) {
		fprintf(stderr, "Output file required\n");
		return EXIT_FAILURE;
	}

	src_file = argv[1];
	dst_file = argv[2];

	if (!bin2pkb()) {
		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}



static int bin2pkb(void)
{
	unsigned char *data;
	size_t size = 0;

	assert(src_file != NULL);
	assert(dst_file != NULL);

	if ((data = binio_read_file(src_file, &size)) == NULL) {
		return 0;
	}

	printf("Compressing \"%s\" (%lu bytes)\n", src_file,
		(unsigned long)size);

	if ((size = packbits_write_file(dst_file, data, size)) > 0) {
		printf("Output \"%s\" (%lu bytes)\n", dst_file,
			(unsigned long)size);
	}

	free(data);

	return size > 0;
}

