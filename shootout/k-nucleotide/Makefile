TOP = ../..
include $(TOP)/mk/boilerplate.mk

# These values are only used in this file and boot.sh.
# They are ignored by the executable itself.
FAST_OPTS =   60000
NORM_OPTS =  600000
SLOW_OPTS = 3000000

# Official shootout setting, takes about 45s in 2018
# SLOW_OPTS = 25000000

CLEAN_FILES += fasta-c k-nucleotide.*stdin

# The benchmark game also uses -fllvm, which we can't since it might
# not be available on the developer's machine.
SRC_DEPS = bytestring

#------------------------------------------------------------------
# Create input

# fasta-c : ../fasta/fasta-c.c
# 	$(CC) -std=gnu99 -O3 -fomit-frame-pointer $< -o $@

# k-nucleotide.faststdin : fasta-c
# 	./fasta-c $(FAST_OPTS) | tr -d '\r' > $@

# k-nucleotide.stdin : fasta-c
# 	./fasta-c $(NORM_OPTS) | tr -d '\r' > $@

# k-nucleotide.slowstdin : fasta-c
# 	./fasta-c $(SLOW_OPTS) | tr -d '\r' > $@

# Since we only decide here what the INPUT_FILE is, it's required to first run
# `make boot` and only than `make` (otherwise `make` doesn't "see" the file and
# doesn't call `runstdtest` correctly)
ifeq "$(mode)" "slow"
 INPUT_FILE = k-nucleotide.slowstdin
else
 ifeq "$(mode)" "fast"
  INPUT_FILE = k-nucleotide.faststdin
 else
  INPUT_FILE = k-nucleotide.stdin
 endif
endif

boot :: $(INPUT_FILE)

k-nucleotide.faststdin : boot.sh ../fasta/fasta-c.c
	./boot.sh . . ${HC} $(mode)

k-nucleotide.stdin : boot.sh ../fasta/fasta-c.c
	./boot.sh . . ${HC} $(mode)

k-nucleotide.slowstdin : boot.sh ../fasta/fasta-c.c
	./boot.sh . . ${HC} $(mode)

include $(TOP)/mk/target.mk
