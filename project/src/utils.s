// utils.s - miscellaneous utilities in ARM64 assembly
    .text
    .global calculate_compression_ratio
    .type calculate_compression_ratio, %function
// size_t calculate_compression_ratio(size_t original, size_t compressed)
calculate_compression_ratio:
    stp x29, x30, [sp, -16]!
    mov x29, sp
    cbz x0, .ratio_end
    mov x2, x0             // preserve original_size
    mov x0, x1             // x0 = compressed_size
    mov x3, #100
    mul x0, x0, x3         // compressed_size * 100
    udiv x0, x0, x2        // / original_size
.ratio_end:
    ldp x29, x30, [sp], #16
    ret

    .global print_ascii_chart
    .type print_ascii_chart, %function
// void print_ascii_chart(const int32_t *data, size_t size)
// prints "VALUE: *****" with star count scaled by value/10
print_ascii_chart:
    stp x29, x30, [sp, -16]!
    stp x19, x20, [sp, -16]!
    stp x21, x22, [sp, -16]!
    mov x29, sp

    mov x19, x0          // data pointer
    mov x20, x1          // element count
    mov x21, #0          // index
.chart_loop:
    cmp x21, x20
    b.ge .chart_done
    ldr w22, [x19, x21, lsl #2]   // load value

    // print "<value>: "
    adrp x0, fmt_val
    add x0, x0, :lo12:fmt_val
    mov w1, w22
    bl printf

    // star count = value / 10
    mov w23, w22
    mov w24, #10
    udiv w23, w23, w24
    cbz w23, .print_newline
.star_loop:
    adrp x0, fmt_star
    add x0, x0, :lo12:fmt_star
    bl printf
    sub w23, w23, #1
    cbnz w23, .star_loop

.print_newline:
    adrp x0, fmt_nl
    add x0, x0, :lo12:fmt_nl
    bl printf

    add x21, x21, #1
    b .chart_loop

.chart_done:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

    .data
fmt_val:
    .asciz "%d: "
fmt_star:
    .asciz "*"
fmt_nl:
    .asciz "\n"

    .text
    .global array_copy
    .type array_copy, %function
// void array_copy(const int32_t *src, int32_t *dest, size_t size)
array_copy:
    stp x29, x30, [sp, -16]!
    mov x29, sp
    cbz x2, .copy_done
    mov x3, #0
.copy_loop:
    ldr w4, [x0, x3, lsl #2]
    str w4, [x1, x3, lsl #2]
    add x3, x3, #1
    cmp x3, x2
    b.lt .copy_loop
.copy_done:
    ldp x29, x30, [sp], #16
    ret

    .global int_to_string
    .type int_to_string, %function
// void int_to_string(int64_t value, char *buffer)
int_to_string:
    stp x29, x30, [sp, -16]!
    mov x29, sp
    mov x2, x1
    mov x1, x0
    adrp x0, fmt_int
    add x0, x0, :lo12:fmt_int
    bl sprintf
    ldp x29, x30, [sp], #16
    ret

    .data
fmt_int:
    .asciz "%ld"
