#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "project.h"

static size_t rle_decompress(const int32_t *data, size_t size, int32_t *out)
{
    if (size < 1)
        return 0;
    size_t original = data[0];
    if (size == original + 1) {
        for (size_t j = 0; j < original; ++j)
            out[j] = data[j + 1];
        return original;
    }
    size_t out_idx = 0;
    size_t i = 1;
    while (i + 1 < size && out_idx < original) {
        int32_t value = data[i];
        size_t count = data[i + 1];
        for (size_t j = 0; j < count && out_idx < original; ++j)
            out[out_idx++] = value;
        i += 2;
    }
    return out_idx;
}

static size_t delta_decompress(const int32_t *data, size_t size, int32_t *out)
{
    if (size < 2)
        return 0;
    size_t original = data[0];
    int32_t prev = data[1];
    out[0] = prev;
    const int16_t *diffs = (const int16_t *)(data + 2);
    size_t out_idx = 1;
    size_t diff_cap = (size * sizeof(int32_t) - 8) / 2;
    for (size_t i = 0; i < original - 1 && i < diff_cap; ++i) {
        prev = prev + diffs[i];
        out[out_idx++] = prev;
    }
    return out_idx;
}

static size_t bytepack_decompress(const int32_t *data, size_t size, int32_t *out)
{
    if (size < 1)
        return 0;
    size_t original = data[0];
    const uint8_t *bytes = (const uint8_t *)(data + 1);
    for (size_t i = 0; i < original; ++i)
        out[i] = bytes[i];
    return original;
}

int main(int argc, char **argv)
{
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <compressed> <output.csv>\n", argv[0]);
        return 1;
    }

    const char *in_path = argv[1];
    const char *out_path = argv[2];
    const char *ext = strrchr(in_path, '.');
    enum { ALG_RLE, ALG_DELTA, ALG_BP } alg;
    if (ext && strcmp(ext, ".rle") == 0)
        alg = ALG_RLE;
    else if (ext && strcmp(ext, ".delta") == 0)
        alg = ALG_DELTA;
    else if (ext && strcmp(ext, ".bp") == 0)
        alg = ALG_BP;
    else {
        fprintf(stderr, "Unknown file extension\n");
        return 1;
    }

    FILE *f = fopen(in_path, "rb");
    if (!f) {
        perror("fopen");
        return 1;
    }
    fseek(f, 0, SEEK_END);
    size_t bytes = ftell(f);
    fseek(f, 0, SEEK_SET);
    size_t words = bytes / 4;
    int32_t *compressed = allocate_buffer(words * sizeof(int32_t));
    if (!compressed) {
        fclose(f);
        return 1;
    }
    fread(compressed, sizeof(int32_t), words, f);
    fclose(f);

    size_t original = compressed[0];
    int32_t *out_data = allocate_buffer((original + 1) * sizeof(int32_t));
    if (!out_data) {
        free_buffer(compressed);
        return 1;
    }

    size_t out_size = 0;
    switch (alg) {
    case ALG_RLE:
        out_size = rle_decompress(compressed, words, out_data);
        break;
    case ALG_DELTA:
        out_size = delta_decompress(compressed, words, out_data);
        break;
    case ALG_BP:
        out_size = bytepack_decompress(compressed, words, out_data);
        break;
    }

    FILE *outf = fopen(out_path, "w");
    if (!outf) {
        perror("fopen");
        free_buffer(compressed);
        free_buffer(out_data);
        return 1;
    }
    fprintf(outf, "timestamp,signal_value\n");
    for (size_t i = 0; i < out_size; ++i)
        fprintf(outf, "%zu,%d\n", i, out_data[i]);
    fclose(outf);

    free_buffer(compressed);
    free_buffer(out_data);
    return 0;
}
