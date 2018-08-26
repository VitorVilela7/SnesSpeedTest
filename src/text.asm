printinittext:
	rep #$20
	lda #$4000
	sta $2116
	lda #.string
	sta $00
	stz $02
	jsl WriteASCII
	
	lda #$4040
	sta $2116
	lda #.string2
	sta $00
	stz $02
	jsl WriteASCII
	
	lda #$4060
	sta $2116
	lda #.string3
	sta $00
	stz $02
	jsl WriteASCII
	sep #$20
	rts
	
		;   0123456789abcdef0123456789abcdef
.string		db "----- SA-1 Speed Test v2.0 -----",$ff
.string2	db "|Current Operation | SA-1 Core |",$ff
.string3	db "|   SNES   |  SA-1 | Speed     |",$ff
;;;;;;;;;;;;;;;;;;;;|DMA BW-RAM|DMA ROM
;;;;;;;;;;;;;;;;;;;;|DMA I-RAM|
	
SpeedSymbol:
	db " MHz |",$ff
