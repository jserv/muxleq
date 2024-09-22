include mk/common.mk

CFLAGS += -O2 -std=c99
CFLAGS += -Wall -Wextra

.PHONY: run bootstrap clean

BIN := muxleq

all: $(BIN)

$(BIN): muxleq.c stage0.c
	$(VECHO) "  CC+LD\t$@\n"
	$(Q)$(CC) $(CFLAGS) -o $@ muxleq.c

run: $(BIN)
	$(Q)./$(BIN)

stage0.c: stage0.dec
	$(Q)sed 's/$$/,/' $^ > $@

stage0.dec: muxleq.fth
	$(VECHO) "  FORTH\t$@\n"
	$(Q)gforth $< > $@

CHECK_FILES := \
	loops \
	radix \
	sqrt

EXPECTED_loops = *
EXPECTED_radix = 2730
EXPECTED_sqrt = 49

check: $(BIN)
	$(Q)$(foreach e,$(CHECK_FILES),\
	    $(PRINTF) "Running tests/$(e).fth ... "; \
	    if ./$(BIN) < tests/$(e).fth | grep -q "$(strip $(EXPECTED_$(e)))"; then \
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

stage1.dec: $(BIN) muxleq.fth
	$(VECHO)  "Bootstrapping... "
	$(Q)./$(BIN) < muxleq.fth > $@

TIME = 5000
TMPDIR := $(shell mktemp -d)
bench: $(BIN)
	$(VECHO)  "Benchmarking... "
	$(Q)(echo "${TIME} ms bye" | time -p ./$(BIN) > /dev/null) 2> $(TMPDIR)/bench ; \
	if grep -q real $(TMPDIR)/bench; then \
	$(call notice, [OK]); \
	cat $(TMPDIR)/bench; \
	else \
	$(PRINTF) "Failed.\n"; \
	exit 1; \
	fi;

clean:
	$(RM) $(BIN)

distclean: clean
	$(RM) stage0.c stage0.dec stage1.dec
