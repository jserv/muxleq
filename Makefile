include mk/common.mk

CFLAGS += -O2 -std=c99
CFLAGS += -Wall -Wextra

.PHONY: run bootstrap clean

all: muxleq

muxleq: muxleq.c stage0.c
	$(VECHO) "  CC+LD\t$@\n"
	$(Q)$(CC) $(CFLAGS) -o $@ muxleq.c

run: muxleq stage0.dec
	$(Q)./muxleq

stage0.c: stage0.dec
	$(VECHO) "  EMBED\t$@\n"
	$(Q)sed 's/$$/,/' $^ > $@

stage0.dec: muxleq.fth
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
bootstrap: stage0.dec stage1.dec
	$(Q)if diff stage0.dec stage1.dec; then \
	$(call notice, [OK]); \
	else \
	$(PRINTF) "Unable to bootstrap. Aborting"; \
	exit 1; \
	fi;

stage1.dec: muxleq muxleq.fth stage0.dec
	$(VECHO)  "Bootstrapping... "
	$(Q)./muxleq < muxleq.fth > $@

clean:
	$(RM) muxleq

distclean: clean
	$(RM) stage0.c stage0.dec stage1.dec
