include mk/common.mk

CFLAGS += -O2 -std=c99
CFLAGS += -Wall -Wextra

.PHONY: run bootstrap clean

all: muxleq

muxleq: muxleq.c muxleq-dec.c
	$(VECHO) "  CC+LD\t$@\n"
	$(Q)$(CC) $(CFLAGS) -o $@ muxleq.c

run: muxleq muxleq.dec
	$(Q)./muxleq

muxleq-dec.c: muxleq.dec
	$(VECHO) "  EMBED\t$@\n"
	$(Q)sed 's/$$/,/' $^ > $@

muxleq.dec: muxleq.fth
	$(Q)gforth $< > $@

CHECK_FILES := \
	loops \
	radix \
	sqrt

EXPECTED_loops = *
EXPECTED_radix = 2730
EXPECTED_sqrt = 49

check: muxleq
	$(Q)$(foreach e,$(CHECK_FILES),\
	    $(PRINTF) "Running tests/$(e).fth ... "; \
	    if ./muxleq < tests/$(e).fth | grep -q "$(strip $(EXPECTED_$(e)))"; then \
	    $(call notice, [OK]); \
	    else \
	    $(PRINTF) "Failed.\n"; \
	    exit 1; \
	    fi; \
	)

# bootstrapping
bootstrap: muxleq.dec muxleq-stage1.dec
	$(Q)if diff muxleq.dec muxleq-stage1.dec; then \
	$(call notice, [OK]); \
	else \
	$(PRINTF) "Unable to bootstrap. Aborting"; \
	exit 1; \
	fi;

muxleq-stage1.dec: muxleq muxleq.fth muxleq.dec
	$(VECHO)  "Bootstrapping... "
	$(Q)./muxleq < muxleq.fth > $@

clean:
	$(RM) muxleq

distclean: clean
	$(RM) muxleq-dec.c muxleq.dec muxleq-stage1.dec
