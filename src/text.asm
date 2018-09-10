printendtext:
	%cursor_pos(22)
	rep #$20
	lda #.string
	sta $00
	stz $02
	jsl WriteASCII
	
	sep #$20
	lda $213e
	and #$0f
	sta $2118
	stz $2119
	rep #$20
	
	lda #.string2
	sta $00
	stz $02
	jsl WriteASCII
	
	sep #$20
	lda $213f
	and #$0f
	sta $2118
	stz $2119
	rep #$20
	
	lda #.string3
	sta $00
	stz $02
	jsl WriteASCII
	
	sep #$20
	lda $4210
	and #$0f
	sta $2118
	stz $2119
	rep #$20
	
	lda #.string4
	sta $00
	stz $02
	jsl WriteASCII
	
	sep #$20
	
	lda $300e
	bpl .ok0
	lda #$5c
	sta $2118
	stz $2119
	sta $2118
	stz $2119
	bra .skip0
.ok0
	lda $300f
	lsr #4
	sta $2118
	stz $2119
	lda $300f
	and #$0f
	sta $2118
	stz $2119
.skip0
	
	lda $bf230e
	cmp #$bf
	bne .ok1
	lda $be230e
	cmp #$be
	bne .ok1
	lda #$5c
	sta $2118
	stz $2119
	sta $2118
	stz $2119
	bra .skip1
.ok1
	lda $230e
	lsr #4
	sta $2118
	stz $2119
	lda $230e
	and #$0f
	sta $2118
	stz $2119
.skip1

	rep #$20
	
	lda #.string5
	sta $00
	stz $02
	jsl WriteASCII
	
		
	sep #$20
	rts
	
		;   0123456789abcdef0123456789abcdef
.string		db "#______________QX__*___________$"
		db "| 5C77 VER: 0",$ff
.string2	db                  "h'!5C78 VER:  0",$ff
.string3	db "h|| 5A22 VER: 0",$ff
.string4	db                 "h'!SA-1 VER:",$ff
.string5	db                             "h|"
		db "[______________YZ______________]"

printinittext:
	rep #$20
	lda #$4000
	sta $2116
	lda #.string
	sta $00
	stz $02
	jsl WriteASCII
	
	ldx $fe
	inx
	stx $2118
	ldx #$00
	stx $2119
	
	lda #.string1
	sta $00
	stz $02
	jsl WriteASCII

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
.string		db "<__{SNES-SA1 Speed Test v3.5}__>"
		db "|Current Operation    PAGE ",$ff
.string1	db                             "/1 |",$ff
.string2	db "#__________&_______&___________$",$ff
.string3	db "|   SNES   |  SA-1 |   Speed   |",$ff
;;;;;;;;;;;;;;;;;;;;|DMA BW-RAM|DMA ROM
;;;;;;;;;;;;;;;;;;;;|DMA I-RAM|
;;;;;;;;;;;;;;;;;;;;|HDMA BWRAM|
	
SpeedSymbol:
	db " MHz |",$ff
