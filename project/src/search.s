// search.s - pattern matching in ARM64 assembly
    .text
    .global pattern_search
    .type pattern_search, %function
// size_t pattern_search(const int32_t *data, size_t size,
//                       const int32_t *pattern, size_t pattern_size,
//                       size_t *results, size_t max_results)
pattern_search:
    stp x29, x30, [sp, -16]!
    mov x29, sp

    cbz x3, .done         // if pattern_size == 0 return 0
    cbz x1, .done         // if size == 0 return 0

    mov x8, x0            // data pointer
    mov x9, x2            // pattern pointer
    mov x10, x4           // results pointer
    mov x11, #0           // matches count
    mov x12, #0           // index

.outer_loop:
    cmp x12, x1
    b.ge .done
    // check remaining length
    sub x13, x1, x12
    cmp x13, x3
    b.lt .advance

    // compare pattern
    mov x14, #0          // pattern index
.inner_loop:
    ldr w15, [x8, x14, lsl #2]
    ldr w16, [x9, x14, lsl #2]
    cmp w15, w16
    b.ne .advance
    add x14, x14, #1
    cmp x14, x3
    b.lt .inner_loop

    // pattern matched
    cmp x11, x5
    b.ge .advance        // reached max_results
    str x12, [x10, x11, lsl #3]
    add x11, x11, #1

.advance:
    add x12, x12, #1
    add x8, x0, x12, lsl #2
    b .outer_loop

.done:
    mov x0, x11
    ldp x29, x30, [sp], #16
    ret
