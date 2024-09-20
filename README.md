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

A single SUBLEQ instruction is structured as follows:
```
SUBLEQ a, b, c
```

Since SUBLEQ is the only available instruction, it is often abbreviated simply
as:
```
a b c
```

The three operands `a`, `b`, and `c` are stored in three consecutive memory
locations. Each operand represents an address in memory. The SUBLEQ instruction
performs the following operations in pseudo-code:
```python
    r = m[b] - m[a]
    if r <= 0:
        pc = c
    m[b] = r
```

There are three notable exceptions to the standard operation:
1. Halting Execution: If the address `c` is negative or refers to an invalid
   memory location outside the addressable range, the program halts.
2. Input Operation: If the address `a` is `-1`, a byte is read from the input
   and stored at address `b`.
3. Output Operation: If the address `b` is negative, a byte from address `a` is
   sent to the output.

The SUBLEQ specification does not dictate how numbers are represented. Key
considerations include:
- Bit Length: Numbers can be 8-bit, 16-bit, 32-bit, 64-bit, or even arbitrary
  precision.
- Negative Numbers: Typically implemented using two's complement, but other
  methods like sign-magnitude can also be used.

Despite its minimalist instruction set, SUBLEQ is Turing complete, meaning that,
given unlimited memory and time, it can perform any computation that a more
complex instruction set can achieve.

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

## eForth
`muxleq.fth` serves as both a cross-compiler and an eForth interpreter
specifically designed for a SUBLEQ variant. This Forth implementation
originates from an eForth version crafted for a 16-bit bit-serial CPU. The
cross-compiler, which is compatible with Gforth, has undergone comprehensive
testing and is fully operational. The cross-compilation process functions as
outlined below:
1. SUBLEQ assembler: A specialized assembler for the SUBLEQ architecture enables
   low-level machine code generation tailored to the SUBLEQ instruction set.
2. Virtual machine: Leveraging the SUBLEQ assembler, a virtual machine is
   constructed. This VM is capable of supporting higher-level programming
   constructs, facilitating the seamless execution of Forth code within the
   SUBLEQ environment.
3. Forth word definitions: These definitions are instrumental in building
   a full-fledged Forth interpreter, allowing for the creation, compilation,
   and execution of Forth programs.
4. Forth image: The finalized Forth image, encapsulating the interpreter and
   its environment, is output to the standard output stream. This image
   initializes the VM with the necessary configurations and word definitions to
   operate effectively.

The eForth image possesses the capability to dynamically ascertain the size of
the underlying SUBLEQ variant machine and adjust its operations accordingly.
This flexibility eliminates the requirement for a power-of-two integer width,
allowing for more versatile machine configurations. Additionally, an intriguing
enhancement would be to adapt this eForth implementation to operate on a SUBLEQ
machine utilizing bignums for each cell. Such an adaptation would necessitate
the re-engineering of functions like bitwise AND, OR, and XOR, as these
operations rely on a fixed cell width to function efficiently.

It is noteworthy that approximately half of the memory allocated is dedicated to
the virtual machine, which facilitates the writing and execution of Forth code.
The `BLOCK` word-set within this implementation does not interact directly with
mass storage. Instead, it maps blocks to memory, enabling efficient memory
management and access.

## License
This package is released under the Public Domain and was initially written
by [Richard James Howe](https://github.com/howerj).

## Reference
* [SUBLEQ EFORTH: Forth Metacompilation for a SUBLEQ Machine](https://www.amazon.com/dp/B0B5VZWXPL)
