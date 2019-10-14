QEMU		= qemu-system-i386
QEMU_ARGS	= -L . -m 32 -rtc base=localtime -vga std -drive file=helloos.img,index=0,if=floppy,format=raw

run:
	$(QEMU) $(QEMU_ARGS)	
