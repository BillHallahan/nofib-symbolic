#################################################################################
#
#			target.mk
#
#		nofib standard target rules
#
#################################################################################


# Only do this in leaf directories (important, this)

nofib-dist-pre::
	-rm -rf $(SRC_DIST_DIR)
	-rm -f $(SRC_DIST_NAME).tar.gz
	(cd $(FPTOOLS_TOP_ABS)/nofib; find $(SRC_DIST_DIRS) -type d \( -name CVS -prune -o -name SRC -prune -o -name tests -prune -o -exec $(MKDIRHIER) $(SRC_DIST_DIR)/{} \; \) ; )
	(cd $(FPTOOLS_TOP_ABS)/nofib; find $(SRC_DIST_DIRS) -name CVS -prune -o -name SRC -prune -o -name tests -prune -o -name "*~" -prune -o -name ".cvsignore" -prune -o -type l -exec $(LN_S) $(FPTOOLS_TOP_ABS)/nofib/{} $(SRC_DIST_DIR)/{} \; )

ifeq "$(SUBDIRS)" ""
all ::
	@echo HC = $(HC)
	@echo HC_OPTS = $(HC_OPTS)
	@echo RUNTEST_OPTS = $(RUNTEST_OPTS)


all :: runtests
endif

# Bogosity needed here to cope with .exe suffix for strip & size files.
# (shouldn't have to be our problem.)
ifneq "$(HC_FAIL)" "YES"
ifneq "$(NoFibWithGHCi)" "YES"
$(NOFIB_PROG_WAY) : $(OBJS)
	@echo ==nofib== $(NOFIB_PROG): time to link $(NOFIB_PROG) follows...
	@$(TIME) $(HC) $(HC_OPTS) -o $@ $^ $(LIBS)
endif
endif


ifeq "$(STDIN_FILE)" ""
STDIN_FILE = $(wildcard $(NOFIB_PROG).stdin)
endif

ifeq "$(NoFibWithGHCi)" "YES"
STDIN = $(NOFIB_PROG).stdin.tmp
GHCI_HC_OPTS = $(filter-out -l% -Rghc-timing,$(HC_OPTS))

runtests ::
	@echo "==nofib== $(NOFIB_PROG): time to compile & run $(NOFIB_PROG) follows..."
	@$(RM) $(STDIN)
	@echo ":set args $(PROG_ARGS)" > $(STDIN)
	@echo "Main.main" >>$(STDIN) 
	@cat /dev/null $(STDIN_FILE) >> $(STDIN)
	@$(TIME) $(RUNTEST) $(GHC_INPLACE) --interactive -v0 -Wnot \
			-i $(STDIN) \
	  		$(addprefix -o1 ,$(wildcard $(NOFIB_PROG).stdout*)) \
	  		$(addprefix -o2 ,$(wildcard $(NOFIB_PROG).stderr*)) \
			$(RUNTEST_OPTS) $(GHCI_HC_OPTS) Main
	@$(RM) $(STDIN)
else 

ifneq "$(NOFIB_PROG_WAY)" ""
ifeq "$(way)" "mp"
# The parallel prg is actually a Perl skript => can't strip it -- HWL
size :: $(NOFIB_PROG_WAY)
	@echo ==nofib== $(NOFIB_PROG): cannot strip parallel program, omitting size info

runtests :: $(NOFIB_PROG_WAY) size
	@echo ==nofib== $(NOFIB_PROG): cannot do an automatic check of stdout with the parallel system, sorry
	@echo ==nofib== $(NOFIB_PROG): run the following command by hand
	@echo                          ./$< $(RUNTEST_OPTS) $(PROG_ARGS)
	@echo ==nofib== $(NOFIB_PROG): output should be
	@cat $(wildcard $(NOFIB_PROG).stdout*)
else

size :: $(NOFIB_PROG_WAY)
	@$(STRIP) $(NOFIB_PROG_WAY)$(exeext)
	@echo ==nofib== $(NOFIB_PROG): size of $(NOFIB_PROG) follows...
	@$(SIZE) $(NOFIB_PROG_WAY)$(exeext)

runtests :: $(NOFIB_PROG_WAY) size
	@echo ==nofib== $(NOFIB_PROG): time to run $(NOFIB_PROG) follows...
	@$(TIME) $(RUNTEST) ./$< \
	  $(addprefix -i,  $(STDIN_FILE)) \
	  $(addprefix -o1 ,$(wildcard $(NOFIB_PROG).stdout*)) \
	  $(addprefix -o2 ,$(wildcard $(NOFIB_PROG).stderr*)) \
	  $(RUNTEST_OPTS) $(PROG_ARGS)
endif

else
size ::
	@:
runtests ::
	@:
endif

endif # GHCI

# Include standard boilerplate
# We do this at the end for cosmetic reasons: it means that the "normal-way"
# runtests will precede the "other-way" recursive invocations of make

include $(FPTOOLS_TOP)/mk/target.mk
