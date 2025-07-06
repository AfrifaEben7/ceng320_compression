// compression.s - RLE and Delta encoding for ARM64

    .text
    .global rle_compress
    .type rle_compress, %function
// size_t rle_compress(const int32_t *data, size_t size, int32_t *out)
rle_compress:
    stp x29, x30, [sp, -16]!
    stp x19, x20, [sp, -16]!
    stp x21, x22, [sp, -16]!
    mov x29, sp

    mov x19, x0           // preserve input pointer
    mov x20, x2           // preserve output start
    mov x21, x1           // preserve original size
    cbz x1, .return_zero  // if size == 0 return 0
    mov x3, #0            // index
    mov x4, x2            // out pointer
    ldr w5, [x0], #4      // current value
    mov x6, #1            // run length

1:  add x3, x3, #1
    cmp x3, x1
    b.eq 3f                // last element -> flush after loop
    ldr w7, [x0], #4       // next value
    cmp w7, w5
    b.eq 4f                // continue run

    // flush run
    str w5, [x4], #4
    str w6, [x4], #4
    mov w5, w7             // new value
    mov x6, #1
    b 1b

4:  add x6, x6, #1
    b 1b

3:  // flush final run
    str w5, [x4], #4
    str w6, [x4], #4
    // calculate compressed size (words)
    sub x0, x4, x20        // out_ptr - start (bytes)
    lsr x0, x0, #2         // convert to 32-bit words
    // if not smaller than original size, copy original
    cmp x0, x21
    b.lt .return
    // fallback - copy original data
    mov x0, x19            // src
    mov x1, x20            // dest
    mov x2, x21            // size
    bl array_copy
    mov x0, x21            // word count
    b .done

.return:
    b .done

.return_zero:
    mov x0, #0
    b .cleanup

.done:
    // x0 already holds byte count
.cleanup:
    ldp x19, x20, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x29, x30, [sp], #16
    ret

    .global delta_compress
    .type delta_compress, %function
// size_t delta_compress(const int32_t *data, size_t size, int32_t *out)
delta_compress:
    stp x29, x30, [sp, -16]!
    stp x19, x20, [sp, -16]!
    stp x21, x22, [sp, -16]!
    mov x29, sp

    mov x19, x0            // save input pointer
    mov x20, x2            // save output start
    mov x21, x1            // preserve original size
    cbz x1, .dret_zero

    ldr w3, [x0], #4       // first value
    str w3, [x2], #4
    mov w4, w3             // previous value
    mov x5, #1             // index
    mov x6, #4             // bytes written

.dloop:
    cmp x5, x1
    b.ge .dend
    ldr w7, [x0], #4       // current value
    sub w8, w7, w4         // delta
    mov w4, w7             // update prev
    mov w9, #0x7FFF
    cmp w8, w9
    b.gt .dfallback
    mov w9, #-32768
    cmp w8, w9
    b.lt .dfallback
    strh w8, [x2], #2
    add x6, x6, #2
    add x5, x5, #1
    b .dloop

.dend:
    mov x0, x6             // bytes written
    add x0, x0, #3
    lsr x0, x0, #2         // convert to word count rounding up
    cmp x0, x21
    b.lt .dsuccess
.dfallback:
    mov x0, x19            // src pointer
    mov x1, x20            // dest pointer
    mov x2, x21            // size
    bl array_copy
    mov x0, x21            // word count
    b .dcleanup
.dsuccess:
    // compressed data already in buffer and x0 holds bytes
    b .dcleanup
.dret_zero:
    mov x0, #0
.dcleanup:
    ldp x19, x20, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x29, x30, [sp], #16
    ret
