printendtext:
-	bit $4212
	bmi -
-	bit $4212
	bpl -
	
	rep #$20
	lda #$1801
	sta $4300
	lda #$1000
	sta $4302
	ldy #$7e
	sty $4304
	lda #$0400
	sta $4305
	ldy #$01
	sty $420b
	
	
	rep #$20
	lda #$0029
	rep 33 : sta $2118
	lda #.string
	sta $00
	stz $02
	jsl WriteASCII
	
	lda $3781
	and #$00f0
	lsr #4
	sta $2118
	lda $3781
	and #$000f
	sta $2118
	
	lda $3780
	and #$00f0
	lsr #4
	sta $2118
	lda $3780
	and #$000f
	sta $2118
	
	
	rts
	
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
.string		db "RETURN STATUS: ",$6a,$ff
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
	
	sep #$20
	lda $f2
	and #$f0
	lsr #4
	sta $2118
	stz $2119
	lda $f2
	and #$0f
	sta $2118
	stz $2119
	rep #$20
	
	lda $f3
	and #$00ff
	asl
	tax
	lda .type,x
	sta $00
	stz $02
	jsl WriteASCII

	lda #.stringa
	sta $00
	stz $02
	jsl WriteASCII
	
	;lda #$4060
	;sta $2116
	;lda #.string3
	;sta $00
	;stz $02
	;jsl WriteASCII
	sep #$20
	rts
	
		;   0123456789abcdef0123456789abcdef
.string		db "<__{Memory Map Explorer v1.0}__>"
		db "| Bank ",$6a,$ff
		
.type
	dw .string1, .string2
	dw .string40
	dw .string41
	dw .string42
	dw .string43
	dw .string44
	dw .string45
	dw .string46
	dw .string47
	dw .string48
	dw .string49
	dw .string4a
	dw .string4b
	dw .string4c
	dw .string4d
	dw .string4e
	dw .string4f
	dw .string50
	dw .string51
	dw .string52
	dw .string53
	dw .string54
	dw .string55
	dw .string56
	dw .string57
	dw .string58
	dw .string59
	dw .string5a
	dw .string5b
	dw .string5c
	dw .string5d
	dw .string5e
	dw .string5f
	dw .string30
	dw .string31
	dw .string32
	dw .string33
	dw .string34
	dw .string35
	dw .string36
	dw .string37
	
	
	

.string1	db " - Source: SNES CPU  |",$ff
.string2	db " - Source: SA-1 CPU  |",$ff
.string40	db " - Source: SA-1 VDF:0|",$ff ;02
.string41	db " - Source: SA-1 VDF:1|",$ff
.string42	db " - Source: SA-1 VDF:2|",$ff
.string43	db " - Source: SA-1 VDF:3|",$ff
.string44	db " - Source: SA-1 VDF:4|",$ff
.string45	db " - Source: SA-1 VDF:5|",$ff
.string46	db " - Source: SA-1 VDF:6|",$ff
.string47	db " - Source: SA-1 VDF:7|",$ff
.string48	db " - Source: SA-1 VDF:8|",$ff
.string49	db " - Source: SA-1 VDF:9|",$ff
.string4a	db " - Source: SA-1 VDF:A|",$ff
.string4b	db " - Source: SA-1 VDF:B|",$ff
.string4c	db " - Source: SA-1 VDF:C|",$ff
.string4d	db " - Source: SA-1 VDF:D|",$ff
.string4e	db " - Source: SA-1 VDF:E|",$ff
.string4f	db " - Source: SA-1 VDF:F|",$ff
.string50	db " - Source: SA-1 VDA:0|",$ff ;12
.string51	db " - Source: SA-1 VDA:1|",$ff
.string52	db " - Source: SA-1 VDA:2|",$ff
.string53	db " - Source: SA-1 VDA:3|",$ff
.string54	db " - Source: SA-1 VDA:4|",$ff
.string55	db " - Source: SA-1 VDA:5|",$ff
.string56	db " - Source: SA-1 VDA:6|",$ff
.string57	db " - Source: SA-1 VDA:7|",$ff
.string58	db " - Source: SA-1 VDA:8|",$ff
.string59	db " - Source: SA-1 VDA:9|",$ff
.string5a	db " - Source: SA-1 VDA:A|",$ff
.string5b	db " - Source: SA-1 VDA:B|",$ff
.string5c	db " - Source: SA-1 VDA:C|",$ff
.string5d	db " - Source: SA-1 VDA:D|",$ff
.string5e	db " - Source: SA-1 VDA:E|",$ff
.string5f	db " - Source: SA-1 VDA:F|",$ff
.string30	db " - Source: C-DMA ROM |",$ff ;22
.string31	db " - Source: C-DMA BWR |",$ff
.string32	db " - Source: C-DMA IR  |",$ff
.string33	db " - Source: C-DMA UNK |",$ff
.string34	db " - Source: L-DMA ROM |",$ff ;22
.string35	db " - Source: L-DMA BWR |",$ff
.string36	db " - Source: L-DMA IR  |",$ff
.string37	db " - Source: L-DMA UNK |",$ff


.stringa	db "[______________________________]",$ff
;.string3	db "|   SNES   |   SA-1  |Speed@MHz|",$ff
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
	db $00,$0a,$0b,$0c,$0d,$0e,$0f,$10,$11,$12,$6a,$14,$15,$16,$17,$18 ; 6x
	db $19,$1a,$1b,$1c,$1d,$1e,$1f,$20,$21,$22,$23,$60,$35,$61,$36,$00 ; 7x
