// memory.s - memory management wrappers in ARM64 assembly
    .text
    .global allocate_buffer
    .type allocate_buffer, %function
// void *allocate_buffer(size_t size)
allocate_buffer:
    stp x29, x30, [sp, -16]!
    mov x29, sp
    bl malloc
    ldp x29, x30, [sp], #16
    ret

    .global free_buffer
    .type free_buffer, %function
// void free_buffer(void *ptr)
free_buffer:
    stp x29, x30, [sp, -16]!
    mov x29, sp
    bl free
    ldp x29, x30, [sp], #16
    ret

    .global zero_memory
    .type zero_memory, %function
// void zero_memory(void *ptr, size_t size)
zero_memory:
    stp x29, x30, [sp, -16]!
    mov x29, sp
    mov x2, x1          // size
    mov x1, #0          // value
    bl memset
    ldp x29, x30, [sp], #16
    ret
