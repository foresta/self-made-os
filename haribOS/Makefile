OSNAME := haribote

QEMU		= qemu-system-i386
QEMU_ARGS	= -L . -m 32 -rtc base=localtime -vga std -drive file=${OSNAME}.img,index=0,if=floppy,format=raw

.DEFAULT_GOAL: all
.PHONY: all
all: img

ipl10.bin: ipl10.asm

${OSNAME}.sys: ${OSNAME}.asm

%.bin: %.asm
	nasm $^ -o $@ -l $*.lst

%.sys: %.asm
	nasm $^ -o $@ -l $*.lst

${OSNAME}.img: ipl10.bin ${OSNAME}.sys
	# 1440KBのフロッピディスクに書き込む
	mformat -f 1440 -C -B ipl10.bin -i $@ ::
	# OS本体をイメージに書き込む
	mcopy -i $@ ${OSNAME}.sys ::

.PHONY: asm
asm:
	make ipl10.bin

.PHONY: img
img:
	make ${OSNAME}.img

.PHONY: run
run:
	make img
	$(QEMU) $(QEMU_ARGS)	

.PHONY: clean
clean:
	@rm *.img *.bin
