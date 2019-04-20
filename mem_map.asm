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
	stz $f0
	stz $f1
	stz $f2
	stz $f3

.loop_back
	%cursor_pos(0) : jsr printinittext
	
	rep #$20
	lda #$4080
	sta $2116
	sep #$30
	
.current_test
	jsr .joy_test
	
	jsr pick_method
	rep #$10
	
	ldy #$0000
	sty $f5
	ldy #$3700
	sty $f4
	
	ldy #$0000
	ldx #$0000
	
	pei ($f0)
	
	rep 16 : jsr print_line
	rep #$20
	pla
	sta $f0
	sep #$30
	
	; lda $fe
	; asl
	; tax
	; lda test_table+1,x
	; sta $01
	; lda test_table,x
	; sta $00

	; lda $ff
	; tay
	; clc
	; adc #$03
	; sta $ff
	
	; lda ($00),y
	; eor #$ff
	; beq .end
	; inc
	; asl #3
	; sec
	; sbc #$1c
	; sta $2110
	; lda #$ff
	; sta $2110
	
	; iny
	; lda ($00),y
	; sta $02
	; iny
	; lda ($00),y
	; sta $03
	
	; pea.w .current_test-1
	; jmp ($0002)

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
	eor #$ff
	tax
	eor #$ff
	and $fd
	stx $fd
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
	inc $f0
+	bit #$40
	beq +
	lda #$10
	clc
	adc $f0
	sta $f0
+
	
	rts
	
.b	dec $f2
	rts
.y	inc $f2
	rts
	
.st
	lda $f3
	cmp.b #$25+4
	beq +
	inc $f3
+	rts
.sl
	lda $f3
	beq +
	dec $f3
+	rts
	
.left
	rep #$20
	lda.w #$ff80
	clc
	adc $f0
	sta $f0
	sep #$20
	bcs +
	dec $f2
+	rts

.right
	rep #$20
	lda #$0080
	clc
	adc $f0
	sta $f0
	sep #$20
	bcc +
	inc $f2
+	rts
	
.down
	rep #$20
	lda.w #$f000
	clc
	adc $f0
	sta $f0
	sep #$20
	bcs +
	dec $f2
+	rts

.up
	rep #$20
	lda #$1000
	clc
	adc $f0
	sta $f0
	sep #$20
	bcc +
	inc $f2
+	rts
	
	
; X tilemap position
; Y memory map position
; local memory filled $3700-$377F ...
print_line:
	lda #$29
	sta $1000,x
	stz $1001,x
	inx #2
	lda #$6a
	sta $1000,x
	stz $1001,x
	inx #2
	
	lda $f1
	and #$0f
	sta $1002,x
	stz $1003,x
	lda $f1
	and #$f0
	lsr #4
	sta $1000,x
	stz $1001,x
	inx #4
	
	lda $f0
	and #$0f
	sta $1002,x
	stz $1003,x
	lda $f0
	and #$f0
	lsr #4
	sta $1000,x
	stz $1001,x
	inx #4
	
	lda #$34
	sta $1000,x
	stz $1001,x
	inx #2
	lda #$29
	sta $1000,x
	stz $1001,x
	inx #2
	
	
macro print_byte()
	lda [$f4],y
	and #$0f
	sta $1002,x
	stz $1003,x
	lda [$f4],y
	and #$f0
	lsr #4
	sta $1000,x
	stz $1001,x
	lda #$29
	sta $1004,x
	stz $1005,x
	inx #6
	iny
endmacro

	%print_byte()
	
	%print_byte()
	
	%print_byte()
	
	%print_byte()
	
	%print_byte()
	
	%print_byte()
	
	%print_byte()
	
	%print_byte()
	
	rep #$20
	tya
	clc
	adc $f0
	sta $f0
	tya
	clc
	adc $f4
	sta $f4
	ldy #$0000
	sep #$20
	
	rts
	
pick_method:
	stz $3780
	stz $3781
	
	lda $f3
	sta $30f3
	asl
	tax
	jsr (.ptrs,x)
	
	sep #$30
	rts
.ptrs
	dw .snes
	dw .sa1
	rep 16 : dw .sa1vbr
	rep 16 : dw .sa1vbr2
	rep 4 : dw .sa1dma
	rep 4 : dw .sa1dma
	
	
.snes
	rep #$10
	ldy #$0000
-	lda [$f0],y
	sta $3700,y
	iny
	cpy #$0080
	bne -
	rts
	
.sa1
	rep #$20
	stz $3080
	lda #.copy_data
	sta $2207
	
	lda $f0
	sta $30f0
	lda $f1
	sta $30f1
	sep #$20
	lda #$80
	sta $2200
-	lda $3080
	beq -
	rts
	
.copy_data
	phk
	plb
	rep #$10
	sep #$20
	ldy #$0000
-	lda [$f0],y
	sta $3700,y
	iny
	cpy #$0080
	bne -
	sep #$30
	inc $3080
	lda #$f0
	sta $220b
	rti
	
.sa1dma
	rep #$20
	stz $3080
	lda #.copy_data1
	sta $2207
	
	lda $f0
	sta $30f0
	lda $f1
	sta $30f1
	sep #$20
	lda #$80
	sta $2200
-	lda $3080
	beq -
	rts
	
.copy_data1
	phk
	plb
	sep #$30
	
	lda #$ff
	ldx #$00
-	sta $3700,x
	dec
	inx
	cpx #$80
	bne -

	LDA $F3
	SEC
	SBC #$22
	STA $F3
	STA $3781
	ORA.b #%11000000 			; \ Enable DMA, DMA Priority, ROM->iram
	BIT #$04
	BEQ +
	EOR #$44
+	STA $2230				; /
	STA $3781
	
	REP #$20				; 16-bit Accum
	LDA $F0 				; \ ROM source address
	STA $2232				; /
	LDX $F2 				; \ ROM source bank
	STX $2234				; /

	LDA #$0080				; \ Set size of transfer
	STA $2238				; /

	lda.w #.dma_ret
	sta $2207
	
	ldx #$f0
	stx $220b
	stx $3081
	cli

	LDA #$3700				; \ I-RAM destination address
	STA $2235				; /
	
	sep #$30
	rep #$10
	ldx #$0000
-	inx
	beq ++
	lda $3081
	bne -
	
	stx $3780
-	sep #$30
	STZ $2230
	inc $3080
	
	rti
	
++	lda #$ff
	sta $3780
	bra -
	
.dma_ret
	sep #$20
	lda #$f0
	sta $220b
	stz $3081
	rti
	
.sa1vbr
	rep #$20
	stz $3080
	lda #.copy_data2
	sta $2207
	
	lda $f0
	sta $30f0
	lda $f1
	sta $30f1
	sep #$20
	lda #$80
	sta $2200
-	lda $3080
	beq -
	rts
	
.copy_data2
	phk
	plb
	rep #$10
	sep #$20
	
	lda $f3
	sec
	sbc #$02
	sta $f3
	STA $3780
	
	STZ $2258				; Set Fixed Mode
	
	LDX $F0
	STX $2259
	LDA $F2
	STA $225B

	ldy #$0000
-
	lda $230c
	sta $3700,y
	lda $230d
	sta $3701,y
	lda $f3
	sta $2258 ;seek bits...
	iny
	iny
	cpy #$0080
	bne -
	sep #$30
	inc $3080
	lda #$f0
	sta $220b
	rti
	
.sa1vbr2
	rep #$20
	stz $3080
	lda #.copy_data3
	sta $2207
	
	lda $f0
	sta $30f0
	lda $f1
	sta $30f1
	sep #$20
	lda #$80
	sta $2200
-	lda $3080
	beq -
	rts
	
.copy_data3
	phk
	plb
	rep #$10
	sep #$20
	
	lda $f3
	sec
	sbc #$12
	sta $f3
	ora #$80
	sta $2258				; Set AUTO Mode
	STA $3780
	
	LDX $F0
	STX $2259
	LDA $F2
	STA $225B

	ldy #$0000
-
	lda $230c
	sta $3700,y
	lda $230d
	sta $3701,y
	;lda $f3
	;sta $2258 ;seek bits...
	;NOT needed here.
	iny
	iny
	cpy #$0080
	bne -
	sep #$30
	inc $3080
	lda #$f0
	sta $220b
	rti

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
