; hello-os
; TAB=4

	ORG		0x7c00			; このプログラムがどこに読み込まれるか

; 以下は標準的なFAT12フォーマットフロッピーディスクのための記述
	JMP		entry
	DB		0x90
	DB		"HELLOIPL"		; ブーとセクタの名前を自由に書いてよい (8Byte)
	DW		512				; 1セクタの大きさ (512にしなければならない)
	DB		1				; クラスタの大きさ (1セクタにしなければならない)
	DW		1				; FATがどこから始まるか (普通は1セクタ目からにする)
	DB		2				; FATの個数 (2にしなければならない)
	DW		224				; ルートディレクトリ領域の大きさ (通常は224エントリにする)
	DW		2880			; このドライブの大きさ (2880セクタにしなければならない)
	DB		0xf0			; メディアタイプ (0xf0にしなければならない)
	DW		9				; FAT領域の長さ (9セクタにしなければならない)
	DW		18				; 1トラックに幾つのセクタがあるか (18セクタにしなければならない)
	DW		2				; ヘッドの数 (2にしなければならない)
	DD		0				; パーティションを使っていないので必ず0
	DD		2880			; このドライブの大きさをもう一度書く
	DB		0, 0, 0x29		; よくわからないけどこの値にしておくといいらしい
	DD		0xffffffff		; 多分ボリュームシリアル番号
	DB		"HELLO-OS   "	; ディスクの名前 (11Byte)
	DB		"FAT12   "		; フォーマットの名前 (8Byte)
	TIMES	18 DB 0			; とりあえず18バイト開けておく

; Program Main Body
entry:
	MOV		AX, 0			; アキュムレータレジスタの初期化
	MOV		SS, AX			; SSはスタックセグメント
	MOV		SP, 0x7c00		; スタックポインタを 0x7c00 へ移動
	MOV		DS, AX			; DSはデータセグメント
	MOV		ES, AX			; ESはエクストラセグメント

	MOV		SI, msg			; SIはソースインデックス (読み込みインデックス) msgのメモリアドレスをSIに設定

putloop:
	MOV		AL, [SI]		; メモリのSI番地の値を1バイト分 AL (Accumrator Low アキュムレータレジスタの下位8バイト) に読み込む
	ADD		SI, 1			; ソースインデックスをひとつ進める
	CMP		AL, 0			; AL (msgメモリないの値) == 0 ならば終了
	JE		fin
	MOV		AH, 0x0e		; 1文字表示ファンクション (AHはアキュムレータレジスタの上位8bit)
	MOV		BX, 15			; カラーコード (BXはベースレジスタ)
	INT		0x10			; ビデオBIOS呼び出し
	JMP		putloop

fin:
	HLT						; 何かあるまでCPUを停止
	JMP		fin				; 無限ループ

msg:
	DB		0x0a, 0x0a
	DB		"hello, world"
	DB		0x0a
	DB		0

	TIMES	0x7dfe-0x7c00-($-$$) DB 0		; 0x7dfeまでを0x00で埋める

	DB		0x55, 0xaa

; ブート以外の処理

;	DB		0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
;	TIMES	4600 DB 0
;	DB		0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
;	TIMES	1469432 DB 0
