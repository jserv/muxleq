# MUXLEQ

```
       ______         _   _
       |  ____|       | | | |
  ___  | |__ ___  _ __| |_| |__
 / _ \ |  __/ _ \| '__| __| '_ \
|  __/ | | | (_) | |  | |_| | | |
 \___| |_|  \___/|_|   \__|_| |_|
```

## Introduction
This project features a 16-bit virtual machine with a two-instruction set
architecture called MUXLEQ, capable of running [Forth](https://www.forth.com/forth/).
MUXLEQ is an enhancement of the [SUBLEQ](https://en.wikipedia.org/wiki/One-instruction_set_computer)
one-instruction machine, offering an additional instruction that improves
performance and reduces program size. The MUXLEQ system retains simplicity,
making it nearly as straightforward to implement in hardware as SUBLEQ.
Existing SUBLEQ programs typically run on MUXLEQ without alterations. This VM,
which integrates eForth, serves as an experimental platform for demonstrating
execution of high-level programming languages with minimal effort.

## Build and Run
This setup requires the installation of a C compiler, [Gforth](https://gforth.org/),
and GNU Make.
* macOS: `brew install gforth`
* Ubuntu Linux / Debian: `sudo apt-get install gforth build-essential`

To run eForth on MUXLEQ, type `make run`. Below is an example session:
```
words
21 21 + . cr
: hello ." Hello World!" cr ;
hello
bye
```

This allows you to operate eForth on the system. For a directory of available
commands, enter `words` and press enter. Numbers should be inputted in Reverse
Polish Notation; for example, inputting `2 2 + . cr` will display "4". To define
new functions, use the following format:
```
: hello cr ." Hello, World" ;
```

Spaces are crucial in the syntax. After defining a function, enter `hello` to
execute it.

The system is self-hosting, meaning it can generate new eForth images using
the current eForth image and source code. While Gforth is used to compile the
image from `muxleq.fth`, the Forth system's self-hosting capability also allows
for building new images after modifying any Forth source files. To initiate
self-hosting and validation, run `make bootstrap`.

## MUXLEQ
The MUXLEQ architecture is an enhancement of the classic SUBLEQ one-instruction
set computer (OISC). MUXLEQ introduces an additional instruction that improves 
performance while maintaining the simplicity of SUBLEQ. Below is the pseudo code
for the MUXLEQ variant:
```python
while pc >= 0:
    a = m[pc + 0]
    b = m[pc + 1]
    c = m[pc + 2]
    pc += 3
    if a == -1:
        m[b] = get_byte()  # Input a byte to memory at address b
    elif b == -1:
        put_byte(m[a])     # Output the byte stored at memory address a
    elif c != -1 and c < 0:
        m[b] = (m[a] & ~m[c]) | (m[b] & m[c])  # Multiplex operation
    else:
        r = m[b] - m[a]   # SUBLEQ subtraction
        if r <= 0:
            pc = c        # Branch if the result is less than or equal to zero
        m[b] = r

```

Removing the `elif c != -1 and c < 0:` clause effectively reverts MUXLEQ to a
typical SUBLEQ machine, as this conditional handles the multiplexing logic unique
to MUXLEQ.

The simplicity of the MUXLEQ design allows for further optimizations by packing
additional functionality into the instruction set.
Some possible variants include:
* Bit Reversal: The multiplexed value could have its bits reversed during the
  operation. This functionality could be integrated into the `mux` instruction,
  allowing for efficient bit manipulation.
* Right Shift: Incorporating a right shift operation, even by just one position,
  would significantly enhance the arithmetic capabilities of the system.
* Comparison, the result of comparing `m[a]` and `m[b]` could be stored in
  `m[a]`, useful comparisons would be `is zero?`, signed or unsigned less than
  or greater than. Any of those five would be useful.
* The paper "[Subleq: An Area-Efficient Two-Instruction-Set Computer](https://janders.eecg.utoronto.ca/pdfs/esl.pdf)"
  introduces bit-reversal to enhance hardware efficiency. When the c operand is
  negative, the operation `r = reverse(reverse(m[b]) - reverse(m[a]))` is
  performed, where `reverse` flips the bits of a value. This modification turns
  the "less than or equal to zero" branch into a branch on evenness, allowing
  an efficient right shift with minimal additional hardware resources.

Although the current MUXLEQ variant already demonstrates considerable
improvements over SUBLEQ, there are a few missing features, such as the
"self-interpreter" feature found in some extended SUBLEQ variants. With further
effort, additional performance gains and capabilities could be implemented,
further closing the gap between minimalistic architecture and more conventional
designs.

## License
This package is released under the Public Domain and was initially written
by [Richard James Howe](https://github.com/howerj).

## Reference
* [SUBLEQ EFORTH: Forth Metacompilation for a SUBLEQ Machine](https://www.amazon.com/dp/B0B5VZWXPL)
