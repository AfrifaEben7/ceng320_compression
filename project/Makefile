CC=aarch64-linux-gnu-gcc
AS=aarch64-linux-gnu-gcc
LD=aarch64-linux-gnu-gcc
CFLAGS=-Wall -g
ASFLAGS=-c -Wall -g

SRC_C=src/main.c
SRC_S=src/compression.s src/search.s src/utils.s src/memory.s
OBJ=$(SRC_C:.c=.o) $(SRC_S:.s=.o)

all: sigscan

sigscan: $(OBJ)
	$(LD) -o $@ $(OBJ)

%.o: %.c
	$(CC) $(CFLAGS) -Iinclude -c $< -o $@

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -f $(OBJ) sigscan

.PHONY: all clean
