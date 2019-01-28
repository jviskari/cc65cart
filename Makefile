#Set path to vice
VICE:=/mnt/c/WinVICE-3.2/x64.exe
#set cart type (cart8 or cart16)
CARTTYPE:=cart16

OUTDIR:=build

TARGET:=$(OUTDIR)/$(CARTTYPE).bin

CFG = $(wildcard $(CARTTYPE)/*.cfg)
ASRC = $(wildcard $(CARTTYPE)/*.s)

CSRC = $(wildcard src/*.c)

OBJ = $(CSRC:.c=.o) $(ASRC:.s=.o)

CL:=cl65
CA:=ca65
CC:=cc65
AR:=ar65
LD:=ld65

CFLAGS:=-Cl -Oris 

$(TARGET): $(CSRC) $(ASRC)
	$(CL) --config $(CFG) $(CFLAGS) -o $@ $^

run: $(TARGET)
	$(VICE) -$(CARTTYPE) $(TARGET)
.PHONY: clean
clean: 
	rm $(OBJ)
	rm $(TARGET)
