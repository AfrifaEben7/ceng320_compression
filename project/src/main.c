#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "project.h"

#define MAX_DATA_POINTS 10000
#define MAX_PATTERN 64
#define MAX_RESULTS 256

static int load_csv(const char *path, int32_t *buffer, size_t *size)
{
    FILE *fp = fopen(path, "r");
    if (!fp)
        return -1;
    char line[128];
    size_t count = 0;
    /* skip header */
    if (fgets(line, sizeof(line), fp) == NULL) {
        fclose(fp);
        return -1;
    }
    while (fgets(line, sizeof(line), fp) && count < MAX_DATA_POINTS) {
        char *comma = strchr(line, ',');
        if (!comma)
            continue;
        int value = atoi(comma + 1);
        buffer[count++] = value;
    }
    fclose(fp);
    *size = count;
    return 0;
}

int main(int argc, char **argv)
{
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <file> [options]\n", argv[0]);
        return 1;
    }

    const char *file = argv[1];
    int use_rle = 0;
    int use_delta = 0;
    int show_stats = 0;
    int32_t pattern[MAX_PATTERN];
    size_t pattern_size = 0;

    for (int i = 2; i < argc; ++i) {
        if (strcmp(argv[i], "-rle") == 0) {
            use_rle = 1;
        } else if (strcmp(argv[i], "-delta") == 0) {
            use_delta = 1;
        } else if (strcmp(argv[i], "-stats") == 0) {
            show_stats = 1;
        } else if (strcmp(argv[i], "-search") == 0 && i + 1 < argc) {
            char *tok = strtok(argv[++i], " ");
            while (tok && pattern_size < MAX_PATTERN) {
                pattern[pattern_size++] = atoi(tok);
                tok = strtok(NULL, " ");
            }
        } else {
            fprintf(stderr, "Unknown option: %s\n", argv[i]);
        }
    }

    int32_t *data = allocate_buffer(MAX_DATA_POINTS * sizeof(int32_t));
    size_t data_size = 0;
    if (load_csv(file, data, &data_size) != 0) {
        fprintf(stderr, "Failed to load %s\n", file);
        free_buffer(data);
        return 1;
    }

    int32_t *compressed = allocate_buffer(data_size * 2 * sizeof(int32_t));
    size_t compressed_size = 0;

    if (use_rle) {
        compressed_size = rle_compress(data, data_size, compressed);
        printf("Compression Method: Run-Length Encoding\n");
    } else if (use_delta) {
        compressed_size = delta_compress(data, data_size, compressed);
        printf("Compression Method: Delta Encoding\n");
    } else {
        printf("No compression selected.\n");
    }

    if (show_stats && (use_rle || use_delta)) {
        size_t ratio = calculate_compression_ratio(data_size * sizeof(int32_t),
                                                  compressed_size * sizeof(int32_t));
        printf("Original Size: %zu bytes\n", data_size * sizeof(int32_t));
        printf("Compressed Size: %zu bytes\n", compressed_size * sizeof(int32_t));
        printf("Compression Ratio: %zu%%\n", ratio);
    }

    const int32_t *search_base = data;
    size_t search_size = data_size;
    if (use_rle) {
        search_base = compressed;
        search_size = compressed_size;
    }

    if (pattern_size > 0) {
        size_t results[MAX_RESULTS];
        size_t found = pattern_search(search_base,
                                      search_size,
                                      pattern, pattern_size, results, MAX_RESULTS);
        printf("Pattern Search Results (%zu found):\n", found);
        for (size_t i = 0; i < found; ++i) {
            printf("  - Index %zu\n", results[i]);
        }
    }

    if (show_stats) {
        print_ascii_chart(data, data_size > 20 ? 20 : data_size);
    }

    free_buffer(data);
    free_buffer(compressed);
    return 0;
}

