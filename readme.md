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

Possible variants to pack as much functionality as possible in would include:

* Bit reversal, the resulting multiplexed value could have its bits reversed.
* Comparison, the result of comparing `m[a]` and `m[b]` could be stored in
  `m[a]`, useful comparisons would be `is zero?`, signed or unsigned less than
  or greater than. Any of those five would be useful.

This variant greatly speeds up loading, storing and the bitwise operations.

The old SUBLEQ only version of the Forth interpreter can be run with:

	make old

This is useful for speed tests.

# References

* <https://github.com/howerj/subleq>
* <https://github.com/howerj/subleq-vhdl>
* <https://esolangs.org/wiki/Subleq>
* <https://en.wikipedia.org/wiki/One-instruction_set_computer>
* <https://janders.eecg.utoronto.ca/pdfs/esl.pdf>
