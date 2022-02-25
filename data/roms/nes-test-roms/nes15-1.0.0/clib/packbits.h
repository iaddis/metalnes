/*
 * File: packbits.h
 * Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
 *
 * Packbits encoding and decoding library
 *
 * A PackBits data stream consists of packets with a one-byte header followed
 * by data. The header is a signed byte; the data is treated as an unsigned
 * char.
 *
 * 	Header byte	Data following the header byte
 *
 *	 0 to  127	(1 + n) literal bytes of data
 *	-1 to -127	One byte of data, repeated (1 - n) times in the
 * 			decompressed output
 *	-128		Marks the end of the encoded data
 *
 * Note that the PackBits encoding used here differs somewhat from the
 * original. The header byte -128 is used to mark the end of the encoded data
 * instead of indicating a no-op or a run.
 */

#ifndef PACKBITS_H
#define PACKBITS_H

#include <stdio.h>



struct binio_file;


/*
 * Reads the entire Packbits encoded file 'file' into a newly allocated buffer.
 *
 * Returns: If the buffer was successfully created and read into, it is
 * returned and 'size' is set to the size of the buffer. Otherwise, NULL is
 * returned and an error message is printed to 'stderr'.
 *
 * Asserts:
 *	file != NULL
 * 	size != NULL
 */
unsigned char *packbits_read_file(const char *file, size_t *size);

/*
 * Reads 'size' bytes of decoded data from the PackBits encoded binary file
 * 'bf' from its current position forward into 'data'. If the end of the file
 * was reached before reading is complete, the file handle's 'eof' member will
 * be set to a non-zero value. If an error occurred while reading, the file
 * handle's 'error' member will be set to a non-zero value and an error message
 * will be printed to 'stderr'.
 *
 * Asserts:
 *	bf != NULL
 *	data != NULL
 *	size > 0
 */
void packbits_read(struct binio_file *bf, unsigned char *data, size_t size);


/*
 * Writes the binary data in 'data' with the size 'size' to the file 'file' in
 * PackBits encoding.
 *
 * Returns: If the binary data was compressed and successfully written, the
 * size of the encoded data is returned. Otherwise, zero is returned and an
 * error message is printed to 'stderr'.
 *
 * Asserts:
 *	file != NULL
 *	data != NULL
 *	size > 0
 */
size_t packbits_write_file(const char *file, const unsigned char *data,
	size_t size);

/*
 * Writes 'size' bytes to the binary file 'bf' from its current position
 * forward from the buffer 'data' in PackBits encoding. If an error occurs
 * while writing, the file handle's 'error' member will be set to a non-zero
 * value and an error message will be printed to 'stderr'.
 *
 * Returns: If the binary data was compressed and successfully written, the
 * size of the encoded data is returned, otherwise zero is returned.
 *
 * Asserts:
 *	bf != NULL
 *	data != NULL
 *	size > 0
 */
size_t packbits_write(struct binio_file *bf, const unsigned char *data,
	size_t size);

/*
 * Gets the number of bytes (after decoding) left to be read in the PackBits
 * encoded binary file 'bf', then resets the binary file's position back to the
 * beginning of the file.
 *
 * Returns: If successful, the number of bytes left (after decoding) in the
 * file is returned. Otherwise, if an error occurs or there where no bytes left
 * to read, zero is returned. If an error does occur, the file handle's 'error'
 * member will  be set to a non-zero value and an error message will be printed
 * to 'stderr'.
 *
 * Asserts:
 *	bf != NULL
 */
size_t packbits_get_size(struct binio_file *bf);

#endif /* PACKBITS_H */

