REPO_ROOT = $(shell git rev-parse --show-toplevel)

TARGET = uart

PROGRAM     = $(TARGET)
PROGRAM_ELF = $(PROGRAM)

C_SRCS += uart.c

include $(REPO_ROOT)/sdk/script/compile.mk
