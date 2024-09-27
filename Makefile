TARGETS = apple2
PROGRAM := fnclk.system

export DEBUG := false
export FUJINET_LIB_VERSION := 4.7.2

SUB_TASKS := clean disk test release
.PHONY: all help $(SUB_TASKS)

all:
	@for target in $(TARGETS); do \
		echo "-------------------------------------"; \
		echo "Building $$target"; \
		echo "-------------------------------------"; \
		$(MAKE) --no-print-directory -f ./makefiles/build.mk CURRENT_TARGET=$$target PROGRAM=$(PROGRAM) $(MAKECMDGOALS); \
	done

$(SUB_TASKS): _do_all
$(SUB_TASKS):
	@:

_do_all: all

help:
	@echo "Makefile for $(PROGRAM)"
	@echo ""
	@echo "Available tasks:"
	@echo "all       - do all compilation tasks, create app in build directory"
	@echo "clean     - remove all build artifacts"
	@echo "release   - create a release of the executable in the build/ dir"
	@echo "disk      - generate platform specific disk images in dist/ dir"
	@echo "            specific platforms may expose additional variables to run with"
	@echo "            different emulators, see makefiles/custom-<platform>.mk"
	