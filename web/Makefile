CC ?= gcc
CFLAGS ?= -O3 -fPIC -Wall -Wextra -Wno-unused-function
LDFLAGS ?= -lm

ZOPFLI_SRCS = c_src/zopfli/blocksplitter.c \
              c_src/zopfli/cache.c \
              c_src/zopfli/deflate.c \
              c_src/zopfli/gzip_container.c \
              c_src/zopfli/hash.c \
              c_src/zopfli/katajainen.c \
              c_src/zopfli/lz77.c \
              c_src/zopfli/squeeze.c \
              c_src/zopfli/tree.c \
              c_src/zopfli/util.c \
              c_src/zopfli/zlib_container.c \
              c_src/zopfli/zopfli_lib.c

TARGET = priv/qdeflate_port

all: $(TARGET)

$(TARGET): c_src/qdeflate_port.c $(ZOPFLI_SRCS)
	@mkdir -p priv
	$(CC) $(CFLAGS) -Ic_src c_src/qdeflate_port.c $(ZOPFLI_SRCS) $(LDFLAGS) -o $(TARGET)

clean:
	rm -f $(TARGET)
