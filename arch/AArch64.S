.globl hw_bswap16
.globl hw_bswap32
.globl hw_bswap64
.globl _cu_memcpy
.globl _cu_memmove
.globl _cu_memcmp
.globl _cu_memset
.globl cu_memzero
.globl cu_memtest
.globl cu_va_start
.globl cu_va_arg

.text

hw_bswap16:
    rev w0, w0
    mov w0, w0, lsr #16
    ret

hw_bswap32:
    rev w0, w0
    ret

hw_bswap64:
    rev x0, x0
    ret

_cu_memcpy:
    // x0 - dst, x1 - src, x2 - size
    mov x3, x2, lsr #3
    tst x3, x3
    beq .cpy1_
.cpy8:
    ldr x4, [x1], #8
    str x4, [x0], #8
    subs x3, x3, #1
    bne .cpy8
.cpy1_:
    and x3, x2, #7
    beq .cpy0
.cpy1:
    ldrb w4, [x1], #1
    strb w4, [x0], #1
    subs x3, x3, #1
    bne .cpy1
.cpy0:
    ret

_cu_memmove:
    // x0 - dst, x1 - src, x2 - size
    cmp x0, x1
    beq .move0
    blt .less1

    add x0, x0, x2
    add x1, x1, x2
    sub x0, x0, #1
    sub x1, x1, #1
.greater1:
    ldrb w3, [x1]
    strb w3, [x0]
    sub x0, x0, #1
    sub x1, x1, #1
    subs x2, x2, #1
    bne .greater1
    b .move0
.less1:
    ldrb w3, [x1], #1
    strb w3, [x0], #1
    subs x2, x2, #1
    bne .less1
.move0:
    ret

_cu_memcmp:
    // x0 - dst, x1 - src, x2 - size
    mov x3, x2, lsr #3
    tst x3, x3
    beq .cmp1_
.cmp8:
    ldr x4, [x0], #8
    ldr x5, [x1], #8
    cmp x4, x5
    bne .cmpnot
    subs x3, x3, #1
    bne .cmp8
.cmp1_:
    and x3, x2, #7
    beq .cmpok
.cmp1:
    ldrb w4, [x0], #1
    ldrb w5, [x1], #1
    cmp w4, w5
    bne .cmpnot
    subs x3, x3, #1
    bne .cmp1
.cmpok:
    mov x0, xzr
    ret
.cmpnot:
    mov x0, #1
    ret

_cu_memset:
    // x0 - dst, x1 - val, x2 - size
    orr x4, x1, x1, lsl #0
    orr x4, x4, x1, lsl #8
    orr x4, x4, x1, lsl #16
    orr x4, x4, x1, lsl #24
    orr x4, x4, x1, lsl #32
    orr x4, x4, x1, lsl #40
    orr x4, x4, x1, lsl #48
    orr x4, x4, x1, lsl #56

    mov x3, x2, lsr #3
    tst x3, x3
    beq .set1_
.set8:
    str x4, [x0], #8
    subs x3, x3, #1
    bne .set8
.set1_:
    and x3, x2, #7
    beq .set0
.set1:
    strb w4, [x0], #1
    subs x3, x3, #1
    bne .set1
.set0:
    ret

cu_memzero:
    // x0 - dst, x1 - size
    mov x2, x1, lsr #3
    tst x2, x2
    beq .zero1_
.zero8:
    str xzr, [x0], #8
    subs x2, x2, #1
    bne .zero8
.zero1_:
    and x2, x1, #7
    beq .zero0
.zero1:
    strb wzr, [x0], #1
    subs x2, x2, #1
    bne .zero1
.zero0:
    ret

cu_memtest:
    // x0 - src, x1 - size
    mov x2, x1, lsr #3
    tst x2, x2
    beq .test1_
.test8:
    ldr x3, [x0], #8
    cmp x3, xzr
    bne .testnot
    subs x2, x2, #1
    bne .test8
.test1_:
    and x2, x1, #7
    beq .testok
.test1:
    ldrb w3, [x0], #1
    cmp w3, wzr
    bne .testnot
    subs x2, x2, #1
    bne .test1
.testok:
    mov x0, xzr
    ret
.testnot:
    ret

cu_va_start:
    stp xzr, x1, [x0], #16
    stp x2,  x3, [x0], #16
    stp x4,  x5, [x0], #16
    stp x6,  x7, [x0], #16
    ret

cu_va_arg:
    // x0 - va_list, x1 - index
    mov x1, x1, lsl #3
    cmp x1, #56
    bgt .va_stack

    add x0, x0, x1
    ldr x0, [x0]
    ret
.va_stack:
    sub x1, x1, #48
    add x0, sp, x1
    ldr x0, [x0]
    ret
