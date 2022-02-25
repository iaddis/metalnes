/*
 * File: pcx2chr.c
 * Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
 *
 * PCX file to NES CHR file converter
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "img8.h"
#include "neschr.h"



/*
 * Processes the argument 'arg' passed to the program, setting options based on
 * what was read.
 *
 * Returns: If a valid argument was passed and processed, then zero is
 * returned. Otherwise, a non-zero value is returned and an error message is
 * printed to 'stderr'.
 *
 * Asserts:
 *	arg != NULL
 */
static int process_arg(const char *arg);

/*
 * Converts the PCX file stored in 'src_file' to the NES CHR file stored in
 * 'dst_file'. If 'vertical' is set to a non-zero value, then the PCX file
 * will be read from top to bottom.
 *
 * Returns: If the conversion was successfully done, then a non-zero value is
 * returned. Otherwise, zero is returned and an error message is printed to
 * 'stderr'.
 *
 * Asserts:
 *	src_file != NULL
 *	dst_file != NULL
 */
static int pcx2chr(void);



static const char help_str[] =
	"Usage: pcx2chr [OPTION]... [PCXFILE] [CHRFILE]\n"
	"\nOptions:\n"
	"\t-V, --vertical\tread from PCX file vertically\n"
	"\t-h, -?, --help\tdisplay this help and exit\n";

static const char *src_file = NULL;
static const char *dst_file = NULL;
static int vertical = 0;
static int print_help = 0;



int main(int argc, char *argv[])
{
	int i;

	for (i = 1; i < argc; i++) {
		if (!process_arg(argv[i])) {
			return EXIT_FAILURE;
		}

		if (print_help) {
			printf(help_str);
			return EXIT_SUCCESS;
		}
	}

	if (src_file == NULL) {
		printf(help_str);
		return EXIT_SUCCESS;
	}

	if (dst_file == NULL) {
		fprintf(stderr, "Output file required\n");
		return EXIT_FAILURE;
	}

	if (!pcx2chr()) {
		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}



static int process_arg(const char *arg)
{
	const char *p;

	assert(arg != NULL);

	if (arg[0] != '-' || arg[1] == '\0') {
		if (src_file == NULL) {
			src_file = arg;
		} else if (dst_file == NULL) {
			dst_file = arg;
		}

		return 1;
	}

	p = arg;

	while (*++p != '\0') {
		switch (*p) {
			case 'V':
				vertical = 1;
				break;
			case 'h':
			case '?':
				print_help = 1;
				break;
			case '-':
				if (!strcmp(arg, "--help")) {
					print_help = 1;
				} else if (!strcmp(arg, "--vertical")) {
					vertical = 1;
				} else {
					fprintf(stderr, "Unrecognized "
						"option '%s'\n", arg);

					return 0;
				}

				return 1;
			default:
				fprintf(stderr, "Unrecognized option '%c'\n",
					*p);
				return 0;
		}
	}

	return 1;
}



static int pcx2chr(void)
{
	struct img8_image *img;
	struct neschr_chr *chr;
	int success;

	assert(src_file != NULL);
	assert(dst_file != NULL);

	if ((img = img8_read_pcx_file(src_file, NULL)) == NULL) {
		return 0;
	}

	chr = neschr_from_img8(img, vertical);
	img8_free(img);

	if (chr == NULL) {
		return 0;
	}

	success = neschr_write_file(dst_file, chr);
	neschr_free(chr);

	return success;
}

