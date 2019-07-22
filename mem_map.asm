LOROM

org $8000
fillbyte $FF : fill $8000

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
dw break
dw break
dw break
dw $0A00	; NMI stays on WRAM
dw break
dw break
dd $00000000
dw break
dw break
dw break
dw break
dw Reset
dw break

org $008000
Reset:
	sei						;\ irq disabled
	clc						;|
	xce						;| disable 6506 emulation
	stz $4200				;|
	bra +

db 0,0,0,0,0,0,0,0,0,0,00,00,00,00,00,00
db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
db 1,1,1,1,1,1,1,1,1,1,01,01,01,01,01,01
rep 8 : db $42
rep 64 : db 255
+	stz $420b				;|
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
	lda #$44
	sta $2108
	
	stz $210b ; l1 character data = $0000
	
	; setup palette
	; color 0 = $0000
	; color 1 = $7bde
	; color 2 = $0000
	; color 3 = $39ce
	
	ldy #$20
-	sty $2121
	stz $2122
	stz $2122
	lda #$de
	sta $2122
	lda #$7b
	sta $2122
	stz $2122
	stz $2122
	lda #$ce
	sta $2122
	lda #$39
	sta $2122
	
	cpy #$00
	beq +
	ldy #$00
	bra -
+
	
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
	lda #$1000
	sta $4305
	sty $420b
	
	lda #$4400
	sta $2116
	sep #$20
	lda #$6f
	sta $2118
	stz $2119
	
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
	
	stz $212a
	stz $212b
	
	lda #$02
	sta $212c
	sta $212e
	lda #$01
	sta $212f
	sta $212d
	
	lda #$02
	sta $2130
	
	lda #$fd
	sta $210e
	stz $210e
	stz $210d
	stz $210d
	
	lda #$0f
	sta $2100
	
	lda #$fc
	sta $210f
	lda #$ff
	sta $210f
	
	sei
	lda #$01
	sta $4200
	
macro cursor_pos(y)
	lda.b #-<y><<3-$001C
	sta $2110
	lda #$ff
	sta $2110
endmacro

macro transfer(label, ram)
	phb
	rep #$30
	lda.w #<label>_end-<label>-1
	ldx.w #<label>
	ldy.w #<ram>
	mvn <ram>>>16, <label>>>16
	sep #$30
	plb
endmacro

	stz $ff ; current test
	stz $fe ; current page
	lda #$ff
	sta $fd ; last controller state
	sta $fc
	
	; $f0-$f2 - 24-bit pointer
	; $f3 - copy source [00-snes,01-sa1,02-sa1 dma,03-sa1 vbr]
	; $f4-$f6 - $3700 buf
	stz $f0 ;$2251
	stz $f1 ;$2252
	stz $f2 ;$2253
	stz $f3 ;$2254
	
	stz $f4 ;$2250

.loop_back
	%cursor_pos(0) : jsr printinittext
	
	
	rep #$20
	lda #$4080
	sta $2116
	sep #$30
	
.current_test
	jsr .joy_test
	
	jsr main
.end
	jsr printendtext
	stz $ff
	
	jmp .loop_back
.new_page
-	bit $4212
	bmi -
-	bit $4212
	bpl -
	
	rep #$20
	lda #$4000
	sta $2116
	lda #$1809
	sta $4300
	lda #$8000
	sta $4302
	stz $4304
	lda #$0800
	sta $4305
	ldy #$01
	sty $420b
	sep #$20
	
	lda #$01
	sta $4200
	
	stz $ff
	jmp .loop_back
	
.joy_test
	lda $4219
	;eor #$ff
	;tax
	;eor #$ff
	;and $fd
	;stx $fd
	bit #$01
	bne .right
	bit #$02
	bne .left
	bit #$04
	bne .down
	bit #$08
	bne .up
	bit #$10
	bne .st
	bit #$20
	bne .sl
	bit #$40
	bne .y
	bit #$80
	bne .b
	
	LDA $4218
	eor #$ff
	tax
	eor #$ff
	and $fc
	stx $fc
	
	bit #$80
	beq +
	inc $f4
+	bit #$40
	beq +
	dec $f4
+
	
	rts
	
.b
	rep #$20
	dec $f2
	sep #$20
	rts
.y
	rep #$20
	inc $f2
	sep #$20
	rts
	
.st
	inc $f3
	rts
.sl
	dec $f3
	rts
	
.left
	dec $f1
	rts

.right
	inc $f1
	rts
	
.down
	rep #$20
	dec $f0
	sep #$20
	rts

.up
	rep #$20
	inc $f0
	sep #$20
	rts


break:
	rep #$20
	lda #$1fff
	tcs
	sep #$20
	sei
	
	lda #$80
	sta $002132
	lda #$34
	sta $002132
-	bra -

macro print_byte(v)
	lda.w <v>
	lsr #4
	sta $1000,x
	stz $1001,x
	lda.w <v>
	and #$0f
	sta $1002,x
	stz $1003,x
	inx #4
endmacro
macro print_char(v)
	lda #<v>
	sta $1000,x
	stz $1001,x
	inx #2
endmacro


macro space()
	lda #$29 : sta $1000,x : stz $1001,x : inx #2
endmacro

macro print_dword(v)
	%print_byte(<v>+3)
	%print_byte(<v>+2)
	%print_byte(<v>+1)
	%print_byte(<v>)
endmacro

main:

	rep #$20
	stz $3080
	lda #.sa1code
	sta $2207
	
	lda $f0
	sta $30f0
	lda $f2
	sta $30f2
	lda $f4
	sta $30f4
	sep #$20
	
	lda #$80
	sta $2200
-	lda $3080
	beq -
	
	rep #$10
	ldx #$0000
	
	%print_byte($3090)
	%space()
	%print_byte($3091)
	%space()
	%print_byte($3092)
	%space()
	%print_byte($3093)
	%space()
	%print_byte($3094)
	%space()
	
	%space()
	%space()
	%space()
	%space()
	%space()
	%space()
	%space()
	%space()
	%space()
	%space()
	%space()
	%space()
	%space()
	%space()
	%space()
	%space()
	%space()
	
	%print_char($6a)
	%print_dword($3098)
	%space()
	
	%print_char($6a)
	%print_dword($309C)
	%space()
	
	%print_char($6a)
	%print_dword($30A0)
	%space()
	%space()
	%space()
	
	%print_char($6a)
	%print_dword($30A4)
	%space()
	
	%print_char($6a)
	%print_dword($30A8)
	%space()
	
	%print_char($6a)
	%print_dword($30AC)
	%space()
	%space()
	%space()
	
	%print_char($6a)
	%print_dword($30B0)
	%space()
	
	%print_char($6a)
	%print_dword($30B4)
	%space()
	
	%print_char($6a)
	%print_dword($30B8)
	%space()
	%space()
	%space()
	
	
	
	
	sep #$10
	
	;rep #$20
	;lda #.string
	;sta $00
	;stz $02
	;jsl WriteASCII
	;asep #$20
	rts
	
.sa1code


	ldx $2250
	stx $3090
	ldx $2251
	stx $3091
	ldx $2252
	stx $3092
	ldx $2253
	stx $3093
	ldx $2254
	stx $3094
	
	
	;5 cycles
	ldx $30f4
	stx $2250
	lda $30f0
	sta $2251
	lda $30f2
	sta $2253
	nop
	xba
	lda $2306
print "word aligned: $", pc
	sta $3098
	lda $2308
	sta $309a
	
	;4 cycles
	ldx $30f4
	stx $2250
	lda $30f0
	sta $2251
	lda $30f2
	sta $2253
	nop
	nop
	lda $2306
print "word aligned: $", pc
	sta $309c
	lda $2308
	sta $309e
	
	;3 cycles
	nop ;align
	ldx $30f4
	stx $2250
	lda $30f0
	sta $2251
	lda $30f2
	sta $2253
	xba
	lda $2306
print "word aligned: $", pc
	sta $30a0
	lda $2308
	sta $30a2
	
	;2 cycles
	nop ;align
	ldx $30f4
	stx $2250
	lda $30f0
	sta $2251
	lda $30f2
	sta $2253
	nop
	lda $2306
print "word aligned: $", pc
	sta $30a4
	lda $2308
	sta $30a6
	
	;1 cycle
	nop ;dealign
	ldx $30f4
	stx $2250
	lda $30f0
	sta $2251
	lda $30f2
	sta $2253
	
	lda $2306
print "word misaligned: $", pc
	sta $30a8
	lda $2308
	sta $30aa
	
	;0 cycle
	nop
	ldx $30f4
	stx $2250
	lda $30f0
	sta $2251
	lda $30f2
	sta $2253
	
	lda $2306
print "word aligned: $", pc
	sta $30ac
	lda $2308
	sta $30ae
	
	phd
	pea $2300
	pld
	
	;-1 cycle
	ldx $30f4
	stx $2250
	lda $30f0
	sta $2251
	lda $30f2
	sta $2253
	
	lda $06
print "word aligned: $", pc
	sta $30b0
	lda $08
	sta $30b2
	
	;-1 cycle (but 2308 is read first)
	ldx $30f4
	stx $2250
	lda $30f0
	sta $2251
	lda $30f2
	sta $2253
	
	lda $08
print "word aligned: $", pc
	sta $30b6
	lda $06
	sta $30b4
	
	; 0, but 2308 is read first
	nop
	ldx $30f4
	stx $2250
	lda $30f0
	sta $2251
	lda $30f2
	sta $2253
	
	lda $2308
print "word aligned: $", pc
	sta $30ba
	lda $2306
	sta $30b8
	
	pld

	; finish code
	ldx #$b0
	stx $220b 
	stx $3080
	rti
	
.string
	db "hello world",$ff

incsrc src\init.asm
incsrc src\text.asm
	
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
	
	lda #$b0
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
	
	lda $230e
	sta $300f
	stz $300e
	cmp $230f
	bne .not_open_bus
	dec $300e
.not_open_bus	
	
	; stay 16-bit A
	rep #$20
	lda #$0000
	ldx #$f0 ; clear irq
	clc
.loop
	bra .loop
	
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
	
print "Bank 0: $", pc
