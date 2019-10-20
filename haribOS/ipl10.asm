; hello-os
; TAB=4

CYLS	EQU	10				; CYLS = 10 を定義
OS_BODY	EQU	0xc200			; OS_BODY = 0xc200を設定. OS本体が読み込まれている相対アドレス

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
; 10(シリンダー) * 2(表裏) * 18(sector) * 512(byte/sector) = 184,320バイト = 180KB を読み込む
entry:
	MOV		AX, 0			; アキュムレータレジスタの初期化
	MOV		SS, AX			; SSはスタックセグメント
	MOV		SP, 0x7c00		; スタックポインタを 0x7c00 へ移動
	MOV		DS, AX			; DSはデータセグメント

	; INT 0x13 はディスクからの読込、書込、セクタのベリファイ、及びシーク
	;     読み込み: AH = 0x02
	;     書き込み: AH = 0x03
	;     ベリファイ: AH = 0x04
	;     シーク: AH = 0x0c
	; 今回はAH = 0x02 に設定しているの読み込み
	; ドライブは0, シリンダは0, セクタは2, ヘッドは表(0) から1セクタ分を読む
	; バッファアドレスはディスクからメモリのどこへプログラムをロードするかのアドレス
	;     処理するセクタ数->AL, シリンダ番号->CH, セクタ番号->CL,
	;     ヘッド番号->DH, ドライブ番号->DL, バッファアドレス->ES:BX
	MOV		AX, 0x0820
	MOV		ES, AX			; ESはエクストラセグメント
	MOV		CH, 0			; シリンダ0
	MOV		DH, 0			; ヘッド0
	MOV		CL, 2			; セクタ2

readloop:
	MOV		SI, 0			; 失敗回数を数えるためのレジスタ

retry:
	MOV		AH, 0x02		; AH=0x02 : ディスク読み込み
	MOV		AL, 1			; 1セクタ
	MOV		BX, 0
	MOV		DL, 0x00		; A ドライブ
	INT		0x13			; ディスクBIOSの呼び出し
	JNC		next			; carry フラグが1じゃない = 失敗じゃない → fin
	ADD		SI, 1			; 失敗回数のIncrement
	CMP		SI, 5			; 5回になっているか
	JAE		error			; if SI >= 5 then error. (jump if above or equal)
	MOV		AH, 0x00
	MOV		DL, 0x00		; Aドライブ
	INT		0x13			; ドライブのリセット
	JMP		retry			; ループ

next:
	MOV		AX, ES			; アドレスを 0x0020進める. バッファアドレスは ES * 16 + BX
	ADD		AX, 0x0020		; 1セクタ512バイトなので 0x0020 * 16 = 32 * 16 = 512 分だけバッファアドレスを進めたい
	MOV		ES, AX			; バッファアドレスで使用されるEXをすすめる 
	ADD		CL, 1			; CLに1足して、次のセクタをよむ用にする
	CMP		CL, 18			; CLと18を比較
	JBE		readloop		; CL <= 18 だったらreadloop

	; セクタを18まで読み終わった時
	MOV		CL, 1			; セクタを1に戻す
	ADD		DH, 1			; ヘッドに1足す => ヘッドを1にして裏面を読む
	CMP		DH, 2			; 裏面を読み終わっているかどうかのチェック
	JB		readloop		; DH < 2 だったら readloop

	; 裏面を読み終わった時
	MOV		DH, 0			; ヘッドを表に戻す
	ADD		CH, 1			; シリンダ番号をIncrement	
	CMP		CH, CYLS		; シリンダを読み終えたかどうか
	JB		readloop		; CH < CYLS だっらreadloop

	JMP		OS_BODY			; ブーとセクタの読み込みが終わったのでOS本体を実行

fin:
	HLT						; 何かあるまでCPUを停止
	JMP		fin				; 無限ループ

error:
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

msg:
	DB		0x0a, 0x0a
	DB		"load, error"
	DB		0x0a
	DB		0

	TIMES	0x7dfe-0x7c00-($-$$) DB 0		; 0x7dfeまでを0x00で埋める

	DB		0x55, 0xaa

; ブート以外の処理

;	DB		0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
;	TIMES	4600 DB 0
;	DB		0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
;	TIMES	1469432 DB 0
