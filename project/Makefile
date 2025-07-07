CC=aarch64-linux-gnu-gcc
AS=aarch64-linux-gnu-gcc
LD=aarch64-linux-gnu-gcc
CFLAGS=-Wall -g
ASFLAGS=-c -Wall -g

SRC_C=src/main.c src/decompress.c
SRC_S=src/compression.s src/search.s src/utils.s src/memory.s
OBJ=$(SRC_C:.c=.o) $(SRC_S:.s=.o)

TOOLS=decompress

all: sigscan decompress

sigscan: src/main.o src/compression.o src/search.o src/utils.o src/memory.o
	$(LD) -o $@ $^

decompress: src/decompress.o src/memory.o
	$(LD) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -Iinclude -c $< -o $@

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -f $(OBJ) sigscan decompress

.PHONY: all clean
