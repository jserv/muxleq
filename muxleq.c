/*
 * A MUXLEQ virtual machine implementation.
 *
 * This program reads instructions from a memory array and executes them.
 * It supports input, output, MUX operations, and SUBLEQ (Subtract and Branch
 * if Less or Equal to Zero) instructions.
 */

#include <stdint.h>
#include <stdio.h>

#define SZ (1 << 15)
#define MASK (SZ - 1)
#define IO_MARKER (uint16_t) (~0U)

/* the memory array of the virtual machine */
static uint16_t m[SZ] = {
#include "muxleq-dec.c"
};

int main()
{
    /* Disable buffering for stdout to ensure immediate output. */
    if (setvbuf(stdout, NULL, _IONBF, 0) < 0)
        return 1;

    for (uint16_t pc = 0; pc < SZ;) {
        /* instruction operands */
        uint16_t a = m[pc++], b = m[pc++], c = m[pc++];
        if (a == IO_MARKER) { /* Read a byte from input and store in memory */
            m[b] = getchar();
        } else if (b == IO_MARKER) {
            if (putchar(m[a]) < 0) /* Write the byte from memory to output */
                return 3;
        } else if (c & SZ && c != IO_MARKER) {
            /* Handles MUX operations by performing a bitwise multiplexing */
            uint16_t mc = m[c & MASK]; /* mux condition */
            m[b] = (m[a] & ~mc) | (m[b] & mc);
        } else {
            /* Handles SUBLEQ operations by subtracting one memory value from
             * another and conditionally branching.
             */
            uint16_t r = m[b] - m[a];
            if (r == 0 || r & SZ) /* Check if it is zero or negative */
                pc = c;
            m[b] = r;
        }
    }
    return 0;
}
