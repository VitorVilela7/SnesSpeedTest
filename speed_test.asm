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
	
	lda #$fc
	sta $210e
	stz $210e
	stz $210d
	stz $210d
	
	lda #$0f
	sta $2100
	
	lda #$fb
	sta $210f
	lda #$ff
	sta $210f
	
	sei
	stz $4200
	
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

.SeeAgain
	%cursor_pos(0) : jsr printinittext
	
	rep #$20
	lda #$4080
	sta $2116
	sep #$30
	%cursor_pos(1) : jsr test_rom
	%cursor_pos(2) : jsr test_rom_parallel
	%cursor_pos(3) : jsr test_iram
	%cursor_pos(4) : jsr test_iram_rom
	%cursor_pos(5) : jsr test_bwram
	%cursor_pos(6) : jsr test_bwram_rom
	%cursor_pos(7) : jsr test_iram_iram
	%cursor_pos(8) : jsr test_bwram_bwram
	%cursor_pos(9) : jsr test_hdma_rom
	%cursor_pos(10) : jsr test_hdma_wram
	%cursor_pos(11) : jsr test_dma_rom
	%cursor_pos(12) : jsr test_dma_iram
	%cursor_pos(14) : jsr test_scpu_rom
	%cursor_pos(15) : jsr test_scpu_wram
	%cursor_pos(16) : jsr test_scpu_iram
	%cursor_pos(18) : jsr test_scpu_hdma_rom
	%cursor_pos(19) : jsr test_scpu_hdma_wram
	%cursor_pos(20) : jsr test_scpu_hdma_iram
	
	jsr printendtext
	
	sep #$20
	
	jmp .SeeAgain

; attempts to recover after a crash.

recover:
	phb
	rep #$30
	lda #$7fff
	ldx #$8000
	ldy #$8000
	mvn $7f, $01
	sep #$30
	plb

	rep #$20
	stz $3042
	stz $3044
	lda #recover_sa1
	sta $2207
	sep #$20
	stz $3080
	lda #$80
	sta $2200
-	lda $3080
	beq -
	rtl
	
recover_sa1:
	clc
	xce
	cld
	rep #$30
	lda #$07ff
	tcs
	pea $0000
	pld
	pea $0000
	plb
	plb
	sep #$10
	lda #$0000
	ldx #$f0
	stx $3080
	cli
-	bra -
	
break:
	rep #$20
	lda #$1fff
	tcs
	sep #$20
	
	lda #$00
	sta $004200
	sei
	
	%transfer(NMI, $0A00)
	
	lda #$80
	sta $002132
	lda #$34
	sta $002132
	
	lda #$ff
	sta $002202
	sta $00220b
	lda.b #NMI_code3-NMI_code0
	sta $000a01
	lda #$80
	sta $004200
	cli
	rep #$20
	sep #$10
	lda #$0000
	ldx #$f0
	jmp $0a00
-	bra -

incsrc src\init.asm
incsrc src\text.asm

write_text:
	sta $00
	stz $02
	
	jsl WriteASCII
	
	sep #$20
	lda $3081
	ora $3080
	cmp #$69
	bne .no_error
	
	rep #$20
	lda #.error_text
	sta $00
	stz $02
	jsl WriteASCII
	sep #$20
	rts
	
.no_error
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
	rts
	
.error_text
	db "  ERROR   |",$ff
	
test_rom:
	jsl Speed_Test_9|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   WRAM   |  ROM  | ",$ff

test_rom_parallel:
	jsl Speed_Test_9
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   ROM    |  ROM  | ",$ff

test_bwram:
	jsl Speed_Test_10|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   WRAM   |BW-RAM | ",$ff

test_bwram_rom:
	jsl Speed_Test_10
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   ROM    |BW-RAM | ",$ff

test_iram:
	jsl Speed_Test_11|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   WRAM   | I-RAM | ",$ff

test_iram_rom:
	jsl Speed_Test_11
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   ROM    | I-RAM | ",$ff

test_iram_iram:
	jsl Speed_Test_12
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|  I-RAM   | I-RAM | ",$ff

test_bwram_bwram:
	jsl Speed_Test_13
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|  BW-RAM  |BW-RAM | ",$ff

test_hdma_rom:
	jsl Speed_Test_14|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| HDMA ROM |  ROM  | ",$ff

test_hdma_wram:
	jsl Speed_Test_15|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| HDMA WRAM|  ROM  | ",$ff

test_dma_rom:
	jsl Speed_Test_16|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| DMA ROM  |  ROM  |~",$ff

test_dma_iram:
	jsl Speed_Test_17|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| DMA ROM  | I-RAM |~",$ff

test_scpu_rom:
	jsl Speed_Test_18
	rep #$20
	
	lda #.string
	sta $00
	stz $02
	jsl WriteASCII
	
	lda #.str
	jsr write_text
	rts
	
.str	db "| S-CPU   ROM Speed| ",$ff

	;   0123456789abcdef0123456789abcdef
.string	db "#__________*_______%___________$",$ff

test_scpu_wram:
	jsl Speed_Test_18|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| S-CPU  WRAM Speed| ",$ff

test_scpu_iram:
	jsl Speed_Test_19
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| S-CPU I-RAM Speed| ",$ff

test_scpu_hdma_rom:
	jsl Speed_Test_20
	rep #$20
	
	lda #.string
	sta $00
	stz $02
	jsl WriteASCII
	
	lda #.str
	jsr write_text
	rts
	
.str	db "| S-CPU   ROM Speed| ",$ff

	;   0123456789abcdef0123456789abcdef
.string	db "#_____________{HDMA#___________$",$ff

test_scpu_hdma_wram:
	jsl Speed_Test_20|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| S-CPU  WRAM Speed| ",$ff

test_scpu_hdma_iram:
	jsl Speed_Test_21
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| S-CPU I-RAM Speed| ",$ff
	
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
	sep #$10

	cli
	
	; stay 16-bit A
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

sa1_clock:
	stx $81		; \ "small insignificant noise"
	stx $220b	;  |
	cli		; /
	
-	adc #$0000	; 3 mem cycles \ 15 cycles
	adc #$0000	; 3 mem cycles  |
	adc #$0000	; 3 mem cycles  |
	adc #$0001	; 3 mem cycles  |
	jmp -		; 3 mem cycles /
.end

sa1_clock_bwram:
base $7f00
	stx $81		; \ "small insignificant noise"
	stx $220b	;  |
	cli		; /
	
-	adc #$0000	; 3 mem cycles \ 15 cycles
	adc #$0000	; 3 mem cycles  |
	adc #$0000	; 3 mem cycles  |
	adc #$0001	; 3 mem cycles  |
	jmp -		; 3 mem cycles /
base off
.end

sa1_clock_iram:
base $3600
	stx $81		; \ "small insignificant noise"
	stx $220b	;  |
	cli		; /
	
snes_clock_iram:
-	adc #$0000	; 3 mem cycles \ 15 cycles
	adc #$0000	; 3 mem cycles  |
	adc #$0000	; 3 mem cycles  |
	adc #$0001	; 3 mem cycles  |
	jmp -		; 3 mem cycles /
base off
sa1_clock_iram_end:
	
sa1_clock_finish:
	stz $2250
	sta $46
	sta $2251
	asl
	lda.w #5908	; 8.16 fixed point. ==> 315.0 / 88.0 * 1000000 * 6 / (262 * 1364) * 15 / 10000 * 65536
	sta $2253
	ldy #$01
	bcs +
	lda #$0000
+	clc
	adc $2308
	cmp #$0000
	clv
	bpl +
	sep #$40
+	sty $2250
	sta $2251
	lda.w #100
	sta $2253
	nop
	xba
	lda $2308	; YY.XX MHz
	sta $42		; XX part
	lda $2306
	sta $44		; YY part

	bvc +
	lda #$63
	sta $42
	sta $44
+
	
	sty $80		; data ready.
	
	stx $220b
	cli
	pla
	pla
	lda #$0000
	rti
	
evil_nmi_sa1_3:
	lda $3084
	pha
	pha
	jmp sa1_clock_finish
	
org $018000

Speed_Test_21:
	rep #$20
	ldx #$70
-	lda #$1143
	sta $4300,x
	lda.w #hdma_tbl|$7f0000
	sta $4302,x
	lda.w #hdma_tbl|$7f0000>>8
	sta $4304,x
	sep #$20
	lda.b #hdma_tbl|$7f0000>>16
	sta $4307,x
	txa
	sec
	sbc #$10
	tax
	rep #$20
	bpl -
	sep #$20
	lda #$ff
	sta $420c
	phk
	jsr Speed_Test_19
	stz $420c
	stz $4200
	stz $0a01
	rtl

Speed_Test_20:
	rep #$20
	ldx #$70
-	lda #$1143
	sta $4300,x
	lda.w #hdma_tbl|$7f0000
	sta $4302,x
	lda.w #hdma_tbl|$7f0000>>8
	sta $4304,x
	sep #$20
	lda.b #hdma_tbl|$7f0000>>16
	sta $4307,x
	txa
	sec
	sbc #$10
	tax
	rep #$20
	bpl -
	sep #$20
	lda #$ff
	sta $420c
	phk
	jsr Speed_Test_18
	stz $420c
	stz $4200
	stz $0a01
	rtl

; S-CPU test.
Speed_Test_19:
	stz $4200
	
	lda.b #NMI_code1-NMI_code0
	sta $0a01
	stz $3081
	stz $3080
	
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	
	rep #$21
	lda #$0000
	ldx #$80
	stx $4200
	jmp.w snes_clock_iram
	
; S-CPU test.
Speed_Test_18:
	stz $4200
	
	lda.b #NMI_code1-NMI_code0
	sta $0a01
	stz $3081
	stz $3080
	
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	
	rep #$21
	lda #$0000
	ldx #$80
	stx $4200
	
-	adc #$0000	; 3 mem cycles \ 15 cycles
	adc #$0000	; 3 mem cycles  |
	adc #$0000	; 3 mem cycles  |
	adc #$0001	; 3 mem cycles  |
	jmp -		; 3 mem cycles /

Speed_Test_17:
	%transfer(sa1_clock_iram, $3600)

	rep #$20
	lda #$3600
	sta $2207
	jmp Speed_Test_16_continue
	
Speed_Test_16:
	rep #$20
	lda #sa1_clock
	sta $2207
.continue
	
	lda #$2000
	sta $2181
	ldy #$00
	sty $2183
	lda #$8000
	sta $4320
	stz $4322
	ldy #$c0
	sty $4324
	stz $4325
	sep #$20
	
	stz $4200
	
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	
	stz $3080
	stz $3081

	ldy #$04
	lda #$80
	sta $4200
	lda #$00		; \ Wait for timer over.
	
-	sty $4326
	sty $2182
	sty $420b
	cmp #$00		;  |
	bmi +			;  |
	jmp -			; /
+
	
-	lda $3080
	beq -
	
	stz $4200
	stz $0a01
	rtl

hdma_tbl:
	rep 224 : dl hdma_data_ptr<<8|$01
	db $00
hdma_data_ptr:
	dw $0000, $0000

Speed_Test_15:
	stz $4200
	
	rep #$20
	lda #sa1_clock
	sta $2207
	
	
	ldx #$70
-	lda #$1143
	sta $4300,x
	lda.w #hdma_tbl|$7f0000
	sta $4302,x
	lda.w #hdma_tbl|$7f0000>>8
	sta $4303,x
	sep #$20
	lda.b #hdma_tbl|$7f0000>>16
	sta $4307,x
	txa
	sec
	sbc #$10
	tax
	rep #$20
	bpl -
	sep #$20
	bra Speed_Test_14_continue
	
Speed_Test_14:
	stz $4200
	
	rep #$20
	lda #sa1_clock
	sta $2207
	
	
	ldx #$70
-	lda #$1143
	sta $4300,x
	lda.w #hdma_tbl
	sta $4302,x
	lda.w #hdma_tbl>>8
	sta $4303,x
	sep #$20
	lda.b #hdma_tbl>>16
	sta $4307,x
	txa
	sec
	sbc #$10
	tax
	rep #$20
	bpl -
	sep #$20
.continue
	
-	bit $4212
	bpl -
	lda #$ff
	sta $420c
-	bit $4212
	bmi -
	
	stz $3080
	stz $3081
	
	lda #$80
	sta $4200
	
	lda #$00		; \ Wait for timer over.
-	cmp #$00		;  |
	bmi +			;  |
	jmp -			; /
+

-	lda $3080
	beq -

	stz $4200
	stz $420c
	stz $0a01
	rtl

Speed_Test_13:
	%transfer(sa1_clock_bwram, $7f00)
	%transfer(snes_test_bwram, $7e00)

	rep #$20
	lda #$7f00
	sta $2207
	sep #$20
	
	stz $4200
	
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	
	stz $3080
	stz $3081
	
	lda #$80
	sta $4200
	
	jsr $7e00
	
	stz $4200
	stz $0a01
	rtl
	
snes_test_bwram:
base $7e00
	lda #$00		; \ Wait for timer over.
-	cmp #$00		;  |
	bmi +			;  |
	jmp -			; /
+

-	lda $3080
	beq -
	rts
base off
.end

Speed_Test_12:
	%transfer(sa1_clock_iram, $3600)
	%transfer(snes_test_iram, $3500)

	rep #$20
	lda #$3600
	sta $2207
	sep #$20
	
	stz $4200
	
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	
	stz $3080
	stz $3081
		
	rep #$20
	lda $3046
	sta $402000
	sep #$20
	
	lda #$80
	sta $4200
	
	jsr $3500
	
	stz $4200
	stz $0a01
	rtl
	
snes_test_iram:
base $3500
	lda #$00		; \ Wait for timer over.
-	cmp #$00		;  |
	bmi +			;  |
	jmp -			; /
+

-	lda $3080
	beq -
	rts
base off
.end

Speed_Test_11:
	%transfer(sa1_clock_iram, $3600)

	rep #$20
	lda #$3600
	sta $2207
	sep #$20
	
	stz $4200
	
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	
	stz $3080
	stz $3081
	
	lda #$80
	sta $4200
	
	lda #$00		; \ Wait for timer over.
-	cmp #$00		;  |
	bmi +			;  |
	jmp -			; /
+
	
-	lda $3080
	beq -
	stz $4200
	stz $0a01
	rtl
	
Speed_Test_10:
	%transfer(sa1_clock_bwram, $7f00)

	rep #$20
	lda #$7f00
	sta $2207
	sep #$20
	
	stz $4200
	
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	
	stz $3080
	stz $3081
	
	lda #$80
	sta $4200
	
	lda #$00		; \ Wait for timer over.
-	cmp #$00		;  |
	bmi +			;  |
	jmp -			; /
+

-	lda $3080
	beq -
	stz $4200
	stz $0a01
	rtl

Speed_Test_9:
	rep #$20
	lda #sa1_clock
	sta $2207
	sep #$20
	
	stz $4200
	
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	
	stz $3080
	stz $3081
	
	lda #$80
	sta $4200
	
	lda #$00		; \ Wait for timer over.
-	cmp #$00		;  |
	bmi +			;  |
	jmp -			; /
+

	
-	lda $3080
	beq -
	stz $4200
	stz $0a01
	rtl

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
	db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f ; 0x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 1x
	db $29,$63,$63,$3F,$5F,$37,$3D,$62,$2b,$2c,$3E,$00,$25,$5C,$24,$00 ; 2x
	db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$34,$00,$3A,$00,$3B,$00 ; 3x
	db $00,$40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E ; 4x
	db $4F,$64,$51,$52,$53,$54,$55,$56,$65,$66,$67,$39,$00,$38,$3C,$26 ; 5x
	db $00,$0a,$0b,$0c,$0d,$0e,$0f,$10,$11,$12,$13,$14,$15,$16,$17,$18 ; 6x
	db $19,$1a,$1b,$1c,$1d,$1e,$1f,$20,$21,$22,$23,$60,$35,$61,$36,$00 ; 7x
