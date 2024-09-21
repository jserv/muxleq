/*
 * A MUXLEQ virtual machine implementation.
 *
 * This program reads instructions from a memory array and executes them.
 * It supports input, output, MUX operations, and SUBLEQ (Subtract and Branch
 * if Less or Equal to Zero) instructions.
 */

#include <stdint.h>
#include <stdio.h>

/* branch predictor hints */
#if defined(__GNUC__) || defined(__clang__)
#define unlikely(x) __builtin_expect(!!(x), 0)
#else
#define unlikely(x) (x)
#endif

/* Define memory size and masks */
#define SZ (1 << 15)
#define MASK (SZ - 1)
#define IO_MARKER (uint16_t) (~0U)

/* The memory array of the virtual machine */
static uint16_t m[SZ] = {
#include "stage0.c"
};

int main()
{
    /* Disable buffering for stdout to ensure immediate output */
    if (setvbuf(stdout, NULL, _IONBF, 0) < 0)
        return 1;

    for (uint16_t pc = 0;;) { /* main loop */
        /* Fetch instruction operands */
        uint16_t a = m[pc + 0], b = m[pc + 1], c = m[pc + 2];

        /* Check if operands are not I/O markers */
        if (unlikely(a == IO_MARKER || b == IO_MARKER)) {
            /* Handle I/O operations */
            if (a == IO_MARKER) {
                /* Input operation: read a byte and store in memory */
                int input = getchar();
                if (unlikely(input == EOF))
                    break;
                m[b] = (uint16_t) input;
            } else {
                /* Output operation: write the byte from memory */
                if (putchar(m[a]) < 0)
                    return 3;
            }
            pc += 3;
            continue;
        }

        /* Check if MUX operation */
        if (c & SZ && c != IO_MARKER) {
            /* Perform bitwise multiplexing */
            uint16_t mc = m[c & MASK]; /* MUX condition */
            m[b] = (m[a] & ~mc) | (m[b] & mc);
            pc += 3;
        } else {
            /* SUBLEQ operation: subtract and conditionally branch */
            const uint16_t r = m[b] - m[a];
            if (r == 0 || r & SZ) {    /* If result is zero or negative */
                pc = c;                /* Branch to address c */
                if (unlikely(pc & SZ)) /* Exit loop if pc exceeds bounds */
                    break;
            } else {
                pc += 3;
            }
            m[b] = r; /* Store result */
        }
    }
    return 0;
}
