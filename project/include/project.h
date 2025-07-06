#ifndef PROJECT_H
#define PROJECT_H

#include <stddef.h>
#include <stdint.h>

typedef struct {
    size_t size;
    int32_t *data;
} SignalData;

size_t rle_compress(const int32_t *data, size_t size, int32_t *out);
size_t delta_compress(const int32_t *data, size_t size, int32_t *out);
size_t pattern_search(const int32_t *data, size_t size,
                      const int32_t *pattern, size_t pattern_size,
                      size_t *results, size_t max_results);

size_t calculate_compression_ratio(size_t original_size, size_t compressed_size);
void print_ascii_chart(const int32_t *data, size_t size);
void array_copy(const int32_t *src, int32_t *dest, size_t size);
void int_to_string(int64_t value, char *buffer);

void *allocate_buffer(size_t size);
void free_buffer(void *ptr);
void zero_memory(void *ptr, size_t size);

#endif // PROJECT_H
