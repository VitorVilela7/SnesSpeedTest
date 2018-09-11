printendtext:
	%cursor_pos(22)
	
-	bit $4212
	bmi -
-	bit $4212
	bpl -
	
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
.string		db "#______________QX____*_________$"
		db "| 5C77 VER: 0",$ff
.string2	db                  "h'!5C78 VER:  0",$ff
.string3	db "h|| 5A22 VER: 0",$ff
.string4	db                 "h'!SA-1 VER:",$ff
.string5	db                             "h|"
		db "[______________YZ______________]",$ff

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
.string		db "<__{SNES-SA1 Speed Test v5.1}__>"
		db "|Current Operation    PAGE ",$ff
.string1	db                             "/4 |",$ff
.string2	db "#__________&_________&_________$",$ff
.string3	db "|   SNES   |   SA-1  |Speed@MHz|",$ff
;;;;;;;;;;;;;;;;;;;;|DMA BW-RAM|DMA ROM
;;;;;;;;;;;;;;;;;;;;|DMA I-RAM|
;;;;;;;;;;;;;;;;;;;;|HDMA BWRAM|
	
SpeedSymbol:
	db "|",$ff

WriteASCII:
	php
	phb
	phk
	plb
	sep #$30
-	bit $4212
	bpl -
	ldy #$00
-	lda [$00],y
	bmi +
	tax
	lda.w ASCIITable,x
	sta $2118
	stz $2119
	iny
	bra -
+	plb
	plp
	rtl
	
ASCIITable:
	db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f ; 0x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 1x
	db $29,$63,$63,$3F,$5F,$37,$3D,$62,$2b,$2c,$3E,$00,$25,$5C,$24,$68 ; 2x
	db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$34,$00,$3A,$00,$3B,$00 ; 3x
	db $2D,$40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E ; 4x
	db $4F,$64,$51,$52,$53,$54,$55,$56,$65,$66,$67,$39,$69,$38,$3C,$26 ; 5x
	db $00,$0a,$0b,$0c,$0d,$0e,$0f,$10,$11,$12,$13,$14,$15,$16,$17,$18 ; 6x
	db $19,$1a,$1b,$1c,$1d,$1e,$1f,$20,$21,$22,$23,$60,$35,$61,$36,$00 ; 7x
