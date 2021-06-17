###############################################################################
# Makefile for the project AVR
###############################################################################

## General Flags
DEV_TYPE = IRPS
PROJECT  = indicator-driver
TARGET   = $(PROJECT)
MCU      = atmega168p
FUSE_E   = 0xFF
FUSE_H   = 0xD4
FUSE_L   = 0xD7

DESCRIPTION =

include $(subst \,/,$(EMLIB))/avr/base/makedefs

## Options common to compile, link and assembly rules
COMMON   = -mmcu=$(MCU)

## Compile options common for all C compilation units.
CFLAGS   = $(COMMON)
CFLAGS  += ${patsubst %,-I%,${subst :, ,${IPATH}}}
CFLAGS  += -ffreestanding -Os
CFLAGS  += -g -gdwarf-2
CFLAGS  += -std=gnu99 -W -Wall
CFLAGS  += -pedantic -Wstrict-prototypes
CFLAGS  += -Wimplicit-fallthrough=0
CFLAGS  += -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
CFLAGS  += -mcall-prologues -fno-tree-scev-cprop
CFLAGS  += -ffunction-sections -fdata-sections
CFLAGS  += -Wp,-M,-MP,-MT,$(*F).o,-MF,$(BINDIR)/dep/$(@F).d

## Assembly specific flags
ASFLAGS  = $(COMMON)
ASFLAGS += $(patsubst %,-I%,$(IPATH))
ASFLAGS += -x assembler-with-cpp

## Linker flags
LDFLAGS  = $(COMMON)
LDFLAGS += -Wl,-gc-sections

## Objects that must be built in order to link
VPATH   = .                         \
          lib                       \
          comm                       \
          drivers                   \
          drivers/indicator         \
          system                    \
          proc                      

IPATH   =  .                        \
           lib                      \
           comm                       \
           drivers                  \
           drivers/indicator        \
           system                   \
           proc                     

##Link
$(BINDIR)/$(TARGET).elf: $(OBJDIR)/indicator.o
$(BINDIR)/$(TARGET).elf: $(OBJDIR)/main.o

## Other dependencies
-include $(shell mkdir $(BINDIR)/dep 2>/dev/null) $(wildcard $(BINDIR)/dep/*)

