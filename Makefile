CFLAGS=-Wall -Wextra -O2 -std=c99

.PHONY: run test clean

run: muxleq muxleq.dec
	./muxleq muxleq.dec

muxleq.dec: muxleq.fth
	gforth $< > $@

1.dec: muxleq muxleq.fth muxleq.dec
	./muxleq muxleq.dec < muxleq.fth > $@

2.dec: muxleq muxleq.fth 1.dec
	./muxleq 1.dec < muxleq.fth > $@

test: 2.dec

clean:
	$(RM) muxleq
