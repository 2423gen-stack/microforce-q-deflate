#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include "zopfli/zopfli.h"

int read_exact(int fd, unsigned char *buf, size_t len) {
    size_t total = 0;
    while (total < len) {
        ssize_t n = read(fd, buf + total, len - total);
        if (n <= 0) return -1;
        total += n;
    }
    return 0;
}

int write_exact(int fd, const unsigned char *buf, size_t len) {
    size_t total = 0;
    while (total < len) {
        ssize_t n = write(fd, buf + total, len - total);
        if (n <= 0) return -1;
        total += n;
    }
    return 0;
}

int main(void) {
    ZopfliOptions options;
    ZopfliInitOptions(&options);
    options.numiterations = 15;
    options.blocksplitting = 1;

    while (1) {
        uint32_t net_len = 0;
        if (read_exact(STDIN_FILENO, (unsigned char*)&net_len, 4) < 0) {
            break; // EOF or error
        }
        uint32_t len = ((net_len & 0xFF) << 24) |
                       (((net_len >> 8) & 0xFF) << 16) |
                       (((net_len >> 16) & 0xFF) << 8) |
                       ((net_len >> 24) & 0xFF);

        // 動的イテレーション調整: 小さいファイルは極限まで追い込み、大きいファイルは応答速度を優先
        if (len < 50000) {
            options.numiterations = 15;
        } else if (len < 500000) {
            options.numiterations = 8;
        } else {
            options.numiterations = 3;
        }

        unsigned char *in = (unsigned char*)malloc(len);
        if (!in) break;
        if (read_exact(STDIN_FILENO, in, len) < 0) {
            free(in);
            break;
        }

        unsigned char *out = NULL;
        size_t outsize = 0;
        ZopfliCompress(&options, ZOPFLI_FORMAT_GZIP, in, len, &out, &outsize);
        free(in);

        uint32_t out_len = (uint32_t)outsize;
        uint32_t net_out_len = ((out_len & 0xFF) << 24) |
                               (((out_len >> 8) & 0xFF) << 16) |
                               (((out_len >> 16) & 0xFF) << 8) |
                               ((out_len >> 24) & 0xFF);

        if (write_exact(STDOUT_FILENO, (unsigned char*)&net_out_len, 4) < 0 ||
            write_exact(STDOUT_FILENO, out, outsize) < 0) {
            free(out);
            break;
        }
        free(out);
    }
    return 0;
}
