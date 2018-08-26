LOROM

org $8000
fillbyte $00 : fill $010000

org $ffb0
dw $0000
dd $0000
db $00,$00,$00,$00,$00,$00,$00
db $00
db $00
db $00
;   123456789012345678901
db "SA-1 Support Test    "
db $23,$35
db $09
db $05

db $00
db $33
db $01

dw $0000
dw $ffff

dd $00000000
dw null_irq
dw null_irq
dw null_irq
dw null_irq
dw null_irq
dw null_irq
dd $00000000
dw null_irq
dw null_irq
dw null_irq
dw null_irq
dw Reset
dw null_irq

org $008000
Reset:
	sei						;\ irq disabled
	clc						;|
	xce						;| disable 6506 emulation
	stz $4200				;|
	stz $420b				;|
	stz $420c				;|
	stz $2140				;|
	stz $2141				;|
	stz $2142				;|
	stz $2143				;| disable dma, h-dma, nmi, auto-joy, "spc700"
	rep #$38				;| disable decimal, a/x/y
	lda #$01ff				;|
	tcs						;| stack pointer = 1fff
	lda #$0000				;|
	tcd						;| zero direct page
	pha						;|
	plb						;|
	plb						;| program bank = 00
	sep #$30				;/
	
	lda #$00				;\ fastrom off
	sta $420d				;/
	
	ldx #$00
-	stz $2100,x
	dex
	bne -
	
	lda #$80				;\ f-blank on
	sta $2100				;/
	
	jsr supermmc			;\ setup sa-1 super mmc
	jsr setupsa1			;| setup sa1
	jsr initram				;| init ram
	jsr initirqnmi			;/ init nmi/irq
	
	lda #$80
	sta $2100
	
	lda #$80
	sta $2115
	stz $2116
	stz $2117
	
	rep #$20
	lda #$aabb
-	cmp $3000
	bne -
	sep #$20

	; init ppu
	stz $2101
	stz $2102
	stz $2103
	stz $2105 ; mode 0, 256x256 tilemap
	stz $2106
	
	lda #$40
	sta $2107 ; layer 1 = tilemap $8000, 256x256 tilemap
	
	stz $210b ; l1 character data = $0000
	
	; setup palette
	; color 0 = $0000
	; color 1 = $7fff
	; color 2 = $0000
	
	lda #$00
	sta $2121
	stz $2122
	stz $2122
	lda #$ff
	sta $2122
	lda #$7f
	sta $2122
	stz $2122
	stz $2122
	
	; cgadsub
	lda #$20
	sta $2131
	
	lda #$20
	sta $2132
	
	lda #$40
	sta $2132
	
	lda #$8d
	sta $2132
	
	; dma graphics
	rep #$20
	stz $2116
	lda #$1801
	sta $4300
	lda #Graphics
	sta $4302
	stz $4304
	lda #$1000
	sta $4305
	ldy #$01
	sty $420b
	
	; dma tilemap
	lda #$4000
	sta $2116
	lda #$1809
	sta $4300
	lda #$8000
	sta $4302
	lda #$0800
	sta $4305
	sty $420b
	sep #$20
	
	; mvn bank 01
	php
	phb
	rep #$30
	lda #$7fff
	ldx #$8000
	ldy #$8000
	mvn $7f, $01
	plb
	plp
	
	lda #$01
	sta $212c
	stz $212d
	
	lda #$fc
	sta $210e
	stz $210e
	stz $210d
	stz $210d
	
	lda #$0f
	sta $2100
	
	sei
	stz $4200
	
	
	.SeeAgain
	
	jsr printinittext
	
	rep #$20
	lda #$4080
	sta $2116
	php
	sep #$30
	jsr test1
	jsr test2
	jsr test3
	jsr test4
	jsr test5
	jsr test6
	jsr test7
	jsr test8
	plp
	
	sep #$20
	
	;lda #$4080
	;sta $2116
	;php
	;sep #$30
	;jsr test2
	;plp
	;sep #$20
	
	lda #$0f
	sta $2100
	
	;lda #$80
	;sta $2100
	jmp .SeeAgain

null_irq:
	rti
	


incsrc src\lib.asm
incsrc src\init.asm
incsrc src\text.asm
	
macro write_text(label1)
	rep #$20
	lda #<label1>
	sta $00
	stz $02
	
	jsl WriteASCII
	
	sep #$20
	lda $3044
	jsr HexDec
	
	; high number
	stx $2118
	stz $2119
	
	; low number
	sta $2118
	stz $2119
	
	; dot [.]
	lda #$24
	sta $2118
	stz $2119
	
	lda $3042
	jsr HexDec
	
	; high number
	stx $2118
	stz $2119
	
	; low number
	sta $2118
	stz $2119
	
	rep #$20
	lda #SpeedSymbol
	sta $00
	stz $02
	
	jsl WriteASCII
	
	sep #$20
endmacro

test1:
	jsl Speed_Test_1|$7f0000
	%write_text(.str)
	rts
	
.str	db "|   WRAM   |  ROM  | ",$ff

test2:
	jsl Speed_Test_1
	%write_text(.str)
	rts
	
.str	db "|   ROM    |  ROM  | ",$ff
	
test3:
	jsl Speed_Test_2|$7f0000
	%write_text(.str)
	rts
	
.str	db "|   WRAM   | I-RAM | ",$ff

test4:
	jsl Speed_Test_2
	%write_text(.str)
	rts
	
.str	db "|   ROM    | I-RAM | ",$ff
	
test5:
	jsl Speed_Test_3|$7f0000
	%write_text(.str)
	rts
	
.str	db "|   WRAM   |BW-RAM | ",$ff
	
test6:
	jsl Speed_Test_3
	%write_text(.str)
	rts
	
.str	db "|   ROM    |BW-RAM | ",$ff

test7:
	jsl Speed_Test_4
	%write_text(.str)
	rts
	
	;;;;;;;;;;;;;;;;
.str	db "| DMA ROM  |  ROM  |~",$ff

test8:
	jsl Speed_Test_5
	%write_text(.str)
	rts
	
	;;;;;;;;;;;;;;;;
.str	db "| DMA ROM  | I-RAM |~",$ff

	
SA1Reset:
	sei
	clc
	xce
	rep #$38
	lda #$07ff
	tcs
	lda #$0000
	tcd
	pha
	plb
	plb
	sep #$30
	
	stz $2209
	
	lda #$f0
	sta $220b
	sta $220a
	
	lda #$00
	sta $2210
	stz $2211
	
	stz $2225
	
	lda #$80
	sta $2227
	
	lda #$ff
	sta $222a
	
	stz $2230
	stz $2231
	stz $2250
	
	rep #$30
	ldx #$07fe
-	stz $00,x
	dex
	bpl -
	lda #$aabb
	sta $00
	sep #$30

	cli
	
.loop
	bra .loop
	
SA1NMI:
	rti
	
SA1IRQ:
	php
	rep #$30
	phb
	phd
	pha
	phx
	phy
	phk
	plb
	sep #$30
	
	lda $2301
	and #$0f
	asl a
	tax
	jsr (.msg,x)
	
	lda #$f0
	sta $220b
	sta $220a
	
	rep #$30
	ply
	plx
	pla
	pld
	plb
	plp
	rti
	
.msg
	dw speednew
	dw speediram
	dw speedbwram
	
speediram:
	%transfer(Speed_Test_1_SA1,$3600)
	jsl $003600
	rts

speedbwram:
	%transfer(Speed_Test_1_SA1,$6100)
	pea $6000
	pld
	jsl $006100
	pea $0000
	pld
	rts
	
speednew:
	jsl Speed_Test_1_SA1
	rts
	
Graphics:
	incbin gfx.bin
	
HexDec:
	LDX #$00
-	CMP #$0A
	BCC +
	SBC #$0A
	INX
	BRA -
+	RTS

org $018000
Speed_Test_1:
	stz $3080
	stz $3081
	lda #$80
	sta $2200
	lda #$01
-	bit $4212
	bmi -
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	sta $3080
	lda #$40
-	bit $4212
	bmi -
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	sta $3081
	
-	lda $3081			;\ wait for SA-1 CPU
	bpl -				;/
	
	rtl
	
Speed_Test_2:
	stz $3080
	stz $3081
	lda #$81
	sta $2200
	lda #$01
-	bit $4212
	bmi -
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	sta $3080
	lda #$40
-	bit $4212
	bmi -
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	sta $3081
	
-	lda $3081			;\ wait for SA-1 CPU
	bpl -				;/
	
	rtl
	
Speed_Test_3:
	stz $6080
	stz $6081
	lda #$82
	sta $2200
	lda #$01
-	bit $4212
	bmi -
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	sta $6080
	lda #$40
-	bit $4212
	bmi -
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	sta $6081
	
-	lda $6081			;\ wait for SA-1 CPU
	bpl -				;/
	
	rep #$20
	lda $6042
	sta $3042
	lda $6044
	sta $3044
	sep #$20
	rtl
	
Speed_Test_4:
	rep #$30
	lda #$0200
	sta $2181
	stz $2183
	lda #$8000
	sta $4360
	lda #$8000
	sta $4362
	stz $4364
	ldy #$0080
	sty $4365
	sep #$20

	stz $3080
	stz $3081
	lda #$80
	sta $2200
	lda #$01
-	bit $4212
	bmi -
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	sta $3080
	
	lda #$40
-	bit $4212
	sty $4365
	sta $420b
	bmi -
-	bit $4212
	sty $4365
	sta $420b
	bpl -
-	bit $4212
	sty $4365
	sta $420b
	bmi -
	sta $3081
	
-	lda $3081			;\ wait for SA-1 CPU
	bpl -				;/
	
	sep #$10
	rtl
	
Speed_Test_5:
	rep #$30
	lda #$0200
	sta $2181
	stz $2183
	lda #$8000
	sta $4360
	lda #$8000
	sta $4362
	stz $4364
	ldy #$0080
	sty $4365
	sep #$20

	stz $3080
	stz $3081
	lda #$81
	sta $2200
	lda #$01
-	bit $4212
	bmi -
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	sta $3080
	
	lda #$40
-	bit $4212
	sty $4365
	sta $420b
	bmi -
-	bit $4212
	sty $4365
	sta $420b
	bpl -
-	bit $4212
	sty $4365
	sta $420b
	bmi -
	sta $3081
	
-	lda $3081			;\ wait for SA-1 CPU
	bpl -				;/
	
	sep #$10
	rtl
	
Speed_Test_1_SA1:
	rep #$20
	stz $00
	
-	lda $80
	beq -
	
	lda #$0000
	
-	bit $80
	inc
	bvc -
	
	inc #2
	sta $00
	
	stz $02
	stz $04
	
	ldx.b #27-1
-	lda $02
	clc
	adc $00
	sta $02
	lda $04
	adc #$0000
	sta $04
	dex
	bpl -
	
	rep #$10
	ldx #$0000
-	lda $04
	bne +
	lda $02
	cmp.w #500
	bcc ++
+	inx
	lda $02
	sec
	sbc.w #500
	sta $02
	lda $04
	sbc #$0000
	sta $04
	bra -
++	beq +
	inx
+	
	txa
	sep #$10
	sta $02
	
	lda.w #$0001
	sta $2250
	lda $02
	sta $40
	sta $2251
	lda.w #100
	sta $2253
	nop
	bra $00
	lda $2308
	sta $42
	lda $2306
	sta $44
	
	lda #$ffff
	sta $80
	sep #$20
	rtl
.end
	
WriteASCII:
	php
	phb
	phk
	plb
	sep #$30
-	bit $4212
	bmi -
-	bit $4212
	bpl -
	ldy #$00
-	lda [$00],y
	cmp #$ff
	beq +
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
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 00x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 10x
	db $29,$28,$00,$00,$00,$00,$00,$00,$2b,$2c,$00,$00,$25,$5C,$24,$00 ; 20x
	db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$34,$00,$00,$00,$00,$00 ; 30x
	db $00,$40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E ; 40x
	db $4F,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$00,$00,$00,$00,$00 ; 50x
	db $00,$0a,$0b,$0c,$0d,$0e,$0f,$10,$11,$12,$13,$14,$15,$16,$17,$18 ; 60x
	db $19,$1a,$1b,$1c,$1d,$1e,$1f,$20,$21,$22,$23,$00,$35,$00,$36,$00 ; 70x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 80x
 	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 90x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; A0x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; B0x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; C0x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; D0x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; E0x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; F0x