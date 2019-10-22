OSNAME := haribote

QEMU		= qemu-system-i386
QEMU_ARGS	= -L . -m 32 -rtc base=localtime -vga std -drive file=${OSNAME}.img,index=0,if=floppy,format=raw

.DEFAULT_GOAL: all
.PHONY: all
all: 
	make build-with-docker
	make run

build:
	make build-with-docker

.PHONY: run
run:
	$(QEMU) $(QEMU_ARGS)	


#==============================

.PHONY: build-with-docker
build-with-docker:
	docker build -t haribos .
	docker run -v `pwd`:/haribos haribos make img	

.PHONY: clean
clean:
	@rm *.img *.bin *.sys *.hrb

#==============================

ipl10.bin: ipl10.asm
asmhead.bin: asmhead.asm
%.bin: %.asm
	nasm $^ -o $@ -l $*.lst

bootpack.hrb: bootpack.c os.lds
	gcc -march=i486 -m32 -nostdlib \
		-T os.lds \
		-fno-pic \
		-o $@ \
		bootpack.c

${OSNAME}.sys: asmhead.bin bootpack.hrb
# asmhead.bin => bootpack.hrbの順番にバイナリを並べる
	cat $^ > $@


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


