; haribote-os
; TAB=4
; すぐ終了するだけの簡単なOS

	ORG		0xc200		; 0xc200 = 0x8000 + 0x4200. 0x8000 は ブートセクタの先頭がメモリの0x8000にくるようにディスクをメモリに読み込み終わってる

	MOV		AL, 0x13	; VGAグラフィックス, 320x200x8bitカラー
	MOV		AH, 0x00
	INT		0x10

fin:
	HLT
	JMP fin
