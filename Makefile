CFLAGS=-Wall -Wextra -O2 -std=c99

.PHONY: run bootstrap clean

all: muxleq

muxleq: muxleq.c muxleq-dec.c
	$(CC) $(CFLAGS) -o $@ muxleq.c

run: muxleq muxleq.dec
	./muxleq

muxleq-dec.c: muxleq.dec
	sed 's/$$/,/' $^ > $@

muxleq.dec: muxleq.fth
	gforth $< > $@

# Simple checks
check: muxleq
	@echo "words bye" | ./muxleq
	@echo

# bootstrapping
bootstrap: muxleq-stage1.dec
	@if ! diff muxleq.dec muxleq-stage1.dec; then \
	echo "Unable to bootstrap. Aborting"; false; \
	fi

muxleq-stage1.dec: muxleq muxleq.fth muxleq.dec
	@echo "Bootstrapping..."
	./muxleq muxleq.dec < muxleq.fth > $@

clean:
	$(RM) muxleq

distclean: clean
	$(RM) muxleq-dec.c muxleq.dec muxleq-stage1.dec
