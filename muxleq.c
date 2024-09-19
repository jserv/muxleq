#include <stdint.h>
#include <stdio.h>

static const uint16_t n = -1;

#define SZ (1 << 15)
#define MASK (SZ - 1)

static uint16_t m[SZ] = {
#include "muxleq-dec.c"
};

int main()
{
    if (setvbuf(stdout, NULL, _IONBF, 0) < 0)
        return 1;

    for (uint16_t pc = 0; pc < SZ;) {
        uint16_t a = m[pc++], b = m[pc++], c = m[pc++];
        if (a == n) {
            m[b] = getchar();
        } else if (b == n) {
            if (putchar(m[a]) < 0)
                return 3;
        } else if (c & SZ && c != n) {
            uint16_t mc = m[c & MASK];
            m[b] = (m[a] & ~mc) | (m[b] & mc);
        } else {
            uint16_t r = m[b] - m[a];
            if (r == 0 || r & 32768)
                pc = c;
            m[b] = r;
        }
    }
    return 0;
}
