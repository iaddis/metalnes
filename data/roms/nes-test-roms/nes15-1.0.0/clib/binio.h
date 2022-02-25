/*
 * File: binio.h
 * Namespace: binio_ / BINIO_
 * Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
 *
 * Binary file I/O library
 *
 * Note that 'binio' assumes that the user will never write or expect to read a
 * value outside of minimums guaranteed by the C Standard. For example, nothing
 * greater than 255 for unsigned chars, or nothing less than -2147483647L for
 * longs.
 */

#ifndef BINIO_H
#define BINIO_H

#include <stdio.h>



/*
 * Binary file handle returned by 'binio_from*' and freed by 'binio_close'.
 */
struct binio_file {
	FILE *fp;		/* Private */
	const char *name;	/* Read-only */
	int eof;		/* Read-only */
	int error;		/* Read-only */
};



/*
 * Opens the file 'file' for use. The string 'mode' is passed to 'fopen' and
 * should always include the 'b' option.
 *
 * Returns: If the file was opened successfully, a new file handle is returned.
 * Otherwise, NULL returned and an error message is printed to 'stderr'.
 *
 * Asserts:
 * 	file != NULL
 * 	mode != NULL
 * 	Returned 'binio_file' is valid
 */
struct binio_file *binio_from_file(const char *file, const char *mode);

/*
 * Closes the binary file 'bf'. Note that the file handle is freed by this
 * function. If an error occurred while closing the file, an error message is
 * printed to 'stderr'.
 *
 * Asserts:
 * 	bf != NULL
 */
void binio_close(struct binio_file *bf);

/*
 * Reads the entire file 'file' into a newly allocated buffer.
 *
 * Returns: If the buffer was successfully created and read into, it is
 * returned and 'size' is set to the size of the buffer. Otherwise, NULL is
 * returned and an error message is printed to 'stderr'.
 *
 * Asserts:
 *	file != NULL
 * 	size != NULL
 */
unsigned char *binio_read_file(const char *file, size_t *size);

/*
 * Reads 'size' bytes from the binary file 'bf' from its current position
 * forward into the buffer 'data'. If the end of the file was reached before
 * reading is complete, the file handle's 'eof' member will be set to a
 * non-zero value. If an error occurred while reading, the file handle's
 * 'error' member will be set to a non-zero value and an error message will be
 * printed to 'stderr'.
 *
 * Asserts:
 *	bf != NULL
 *	data != NULL
 *	size > 0
 */
void binio_read(struct binio_file *bf, unsigned char *data, size_t size);

/*
 * The following input functions read binary values from the binary file 'bf'.
 * Functions with names that end with 'le' read data in little-endian format.
 * Functions with names that end with 'be' read data in big-endian format. If
 * the end of the input file is reached, the file handle's 'eof' member will be
 * set to a non-zero value. If an error occurs while reading, the file handle's
 * 'error' member will be set to a non-zero value and an error message will be
 * printed to 'stderr'.
 *
 * Returns: If successful, the value read from file is returned, otherwise
 * zero is returned.
 *
 * Asserts:
 * 	bf != NULL
 */
unsigned char binio_read_u8(struct binio_file *bf);
signed char binio_read_s8(struct binio_file *bf);
unsigned short binio_read_u16le(struct binio_file *bf);
short binio_read_s16le(struct binio_file *bf);
unsigned short binio_read_u16be(struct binio_file *bf);
short binio_read_s16be(struct binio_file *bf);
unsigned long binio_read_u32le(struct binio_file *bf);
long binio_read_s32le(struct binio_file *bf);
unsigned long binio_read_u32be(struct binio_file *bf);
long binio_read_s32be(struct binio_file *bf);

/*
 * Writes the binary data in 'data' with the size 'size' to the file 'file'.
 *
 * Returns: If the binary data was successfully written, zero is returned.
 * Otherwise, a non-zero value is returned and an error message is printed to
 * 'stderr'.
 *
 * Asserts:
 *	file != NULL
 *	data != NULL
 *	size > 0
 */
int binio_write_file(const char *file, const unsigned char *data, size_t size);

/*
 * Writes 'size' bytes to the binary file 'bf' from its current position
 * forward from the buffer 'data'. If an error occurs while writing, the file
 * handle's 'error' member will be set to a non-zero value and an error message
 * will be printed to 'stderr'.
 *
 * Asserts:
 *	bf != NULL
 *	data != NULL
 *	size > 0
 */
void binio_write(struct binio_file *bf, const unsigned char *data,
	size_t size);

/*
 * The following output functions write binary values to the binary file 'bf'.
 * Functions with names that end with 'le' write data in little-endian format.
 * Functions with names that end with 'be' write data in big-endian format. If
 * an error occurs while writing, the file handle's 'error' member will be set
 * to a non-zero value and an error message will be printed to 'stderr'.
 *
 * Asserts:
 * 	bf != NULL
 */
void binio_write_u8(struct binio_file *bf, unsigned char u8);
void binio_write_s8(struct binio_file *bf, signed char s8);
void binio_write_u16le(struct binio_file *bf, unsigned short u16);
void binio_write_s16le(struct binio_file *bf, short s16);
void binio_write_u16be(struct binio_file *bf, unsigned short u16);
void binio_write_s16be(struct binio_file *bf, short s16);
void binio_write_u32le(struct binio_file *bf, unsigned long u32);
void binio_write_s32le(struct binio_file *bf, long s32);
void binio_write_u32be(struct binio_file *bf, unsigned long u32);
void binio_write_s32be(struct binio_file *bf, long s32);

/*
 * Resets the current position of the binary file 'bf' to its beginning. If an
 * error occurs while rewinding, the file handle's 'error' member will be set
 * to a non-zero value and an error message will be printed to 'stderr'.
 *
 * Asserts:
 *	bf != NULL
 */
void binio_rewind(struct binio_file *bf);

/*
 * Gets the number of bytes left to be read in the binary file 'bf', then
 * resets the binary file's position back to the beginning of the file.
 *
 * Returns: If successful, the number of bytes left in the file is returned.
 * Otherwise, if an error occurs or there where no bytes left to read, zero
 * is returned. If an error does occur, the file handle's 'error' member will
 * be set to a non-zero value and an error message will be printed to 'stderr'.
 *
 * Asserts:
 *	bf != NULL
 */
size_t binio_get_size(struct binio_file *bf);

#endif /* BINIO_H */

