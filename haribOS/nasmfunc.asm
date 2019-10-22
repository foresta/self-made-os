; nasmfunc
; TAB=4

section: .text
	GLOBAL	_io_hlt
	GLOBAL	_write_mem8

_io_hlt:	; void _io_hlt(void);
	HLT
	RET

_write_mem8:	; void _write_mem8(int addr, int data);
; int型 (4 Byte) の data の下位1Byteのみを addr に書き込む
	MOV		ECX, DWORD [ESP+4]	; [ESP+4] ~ [ESP+7] に (int)addr が入っている, 32bit アドレッシング
	MOV		AL,  BYTE  [ESP+8]	; [ESP+8] ~ [ESP+11] に (int) data が入っている. 

	MOV		BYTE [ECX], AL
	RET

