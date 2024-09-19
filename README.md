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
architecture called MUXLEQ, capable of running Forth. MUXLEQ is an enhancement
of the [SUBLEQ](https://en.wikipedia.org/wiki/One-instruction_set_computer)
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

Gforth compiles the image from `muxleq.fth`, but as Forth systems are self-hosting,
they can also be used to build new images after modifying any Forth source file.

## MUXLEQ
The pseudo code for this SUBLEQ variant, MUXLEQ, is:
```
	while pc >= 0:
		a = m[pc + 0]
		b = m[pc + 1]
		c = m[pc + 2]
		pc = pc + 3
		if a == -1:
			m[b] = get_byte()
		else if b == -1:
			put_byte(m[a])
		else if c != -1 and c < 0:
			m[b] = (m[a] & ~m[c]) | (m[b] & m[c])
		else:
			r = m[b] - m[a]
			if r <= 0:
				pc = c
			m[b] = r
```

Removing the line `else if c != -1 and c < 0:` along with the clause turns
this variant back into a SUBLEQ machine.

Possible variants to pack as much functionality as possible in would include:
* Bit reversal, the resulting multiplexed value could have its bits reversed.
  This could be folded into the `mux` instruction.
* Right shift, even if only by one place.
* Comparison, the result of comparing `m[a]` and `m[b]` could be stored in
  `m[a]`, useful comparisons would be `is zero?`, signed or unsigned less than
  or greater than. Any of those five would be useful.
* The paper "[Subleq: An Area-Efficient Two-Instruction-Set Computer](https://janders.eecg.utoronto.ca/pdfs/esl.pdf)"
  extends SUBLEQ in a different way using bit-reversal that should lend itself
  to a hardware implementation that uses minimal extra resources as the
  structure of the new instruction is very similar SUBLEQ. If the `c` operand
  is negative it computes `r = reverse(reverse(m[b]) - reverse(m[a]))`. This
  turns the less than or equal to zero branch into a branch on evenness,
  allowing a quicker right shift to be implemented using minimal resources.
  `reverse` reverses all bits in a cell.

This variant greatly speeds up loading, storing and the bitwise operations,
even with minimal effort. There are a few features missing from this MUXLEQ
variant (such as the "self-interpreter") and as such have been disabled. No
doubt if more effort was expended many more performance gains could be made.

## License
This package is released under the Public Domain and was initially written
by [Richard James Howe](https://github.com/howerj).

## Reference
* [SUBLEQ EFORTH: Forth Metacompilation for a SUBLEQ Machine](https://www.amazon.com/dp/B0B5VZWXPL)
