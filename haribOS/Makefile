QEMU		= qemu-system-i386
QEMU_ARGS	= -L . -m 32 -rtc base=localtime -vga std -drive file=boot.img,index=0,if=floppy,format=raw

.DEFAULT_GOAL: all
.PHONY: all
all: img

ipl.bin: ipl.asm

%.bin: %.asm
	nasm $^ -o $@ -l $*.lst

boot.img: ipl.bin
	cat $^ > $@


.PHONY: img
img:
	make boot.img

.PHONY: run

run: ipl.bin
	make img
	$(QEMU) $(QEMU_ARGS)	

.PHONY: clean
clean:
	@rm *.img *.bin
