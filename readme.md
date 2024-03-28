# MUXLEQ

* Author: Richard James Howe
* License: The Unlicense / Public Domain
* Email: <mailto:howe.r.j.89@gmail.com>
* Repo: <https://github.com/howerj/muxleq>

A faster SUBLEQ variant called MUXLEQ. SUBLEQ is a single instruction machine, 
this is a two instruction machine. By just adding one instruction is becomes possible to
speed up the system dramatically whilst also reducing the program size. The
machine is not much more complex, and it would still be trivial to implement the
system in hardware.

SUBLEQ programs can (usually) run unaltered on the MUXLEQ CPU.

MUXLEQ runs a Forth interpreter, a programming language, as a test program. 
To run, type:

	make run

This requires a C compiler and make to be installed.

The pseudo code for this SUBLEQ variant, MUXLEQ, is:

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

Removing the line `else if c != -1 and c < 0:` along with the clause turns
this variant back into a SUBLEQ machine.

Possible variants to pack as much functionality as possible in would include:

* Bit reversal, the resulting multiplexed value could have its bits reversed.
  This could be folded into the `mux` instruction.
* Right shift, even if only by one place.
* Comparison, the result of comparing `m[a]` and `m[b]` could be stored in
  `m[a]`, useful comparisons would be `is zero?`, signed or unsigned less than
  or greater than. Any of those five would be useful.
* The paper <https://janders.eecg.utoronto.ca/pdfs/esl.pdf> "Subleq(?): An 
  Area-Efficient Two-Instruction-Set Computer" extends SUBLEQ in a different
  way using bit-reversal that should lend itself to a hardware implementation
  that uses minimal extra resources as the structure of the new instruction
  is very similar SUBLEQ. If the `c` operand is negative it computes 
  `r = reverse(reverse(m[b]) - reverse(m[a]))`. This turns the less than or
  equal to zero branch into a branch on evenness, allowing a quicker right
  shift to be implemented using minimal resources. `reverse` reverses all
  bits in a cell.

This variant greatly speeds up loading, storing and the bitwise operations,
even with minimal effort. There are a few features missing from this MUXLEQ
variant (such as the "self-interpreter") and as such have been disabled. No
doubt if more effort was expended many more performance gains could be made.

The old SUBLEQ only version of the Forth interpreter can be run with:

	make old

This is useful for speed tests.

This project could contain alternative SUBLEQ instructions and improvements
in the future, `altleq` might be a better name for the project.

gforth can be used to build the images from either `muxleq.fth` or
`subleq.fth`, but the Forth systems are self-hosting so you can use
them to build the new images if you modify either Forth source file.

# References

* <https://github.com/howerj/subleq>
* <https://github.com/howerj/subleq-vhdl>
* <https://github.com/howerj/subleq-python>
* <https://github.com/howerj/subleq-perl>
* <https://github.com/howerj/subleq-forth>
* <https://github.com/howerj/subleq-js>
* <https://github.com/howerj/subleq-nodejs>
* <https://esolangs.org/wiki/Subleq>
* <https://en.wikipedia.org/wiki/One-instruction_set_computer>
* <https://janders.eecg.utoronto.ca/pdfs/esl.pdf>
* <https://www.gnu.org/software/gforth/>

