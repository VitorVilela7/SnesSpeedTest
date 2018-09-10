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

.loop_back
	%cursor_pos(0) : jsr printinittext
	
	rep #$20
	lda #$4080
	sta $2116
	sep #$30
	
.current_test
	jsr .joy_test
	bcs .new_page
	
	lda $fe
	asl
	tax
	lda test_table+1,x
	sta $01
	lda test_table,x
	sta $00

	lda $ff
	tay
	clc
	adc #$03
	sta $ff
	
	lda ($00),y
	eor #$ff
	beq .end
	inc
	asl #3
	sec
	sbc #$1c
	sta $2110
	lda #$ff
	sta $2110
	
	iny
	lda ($00),y
	sta $02
	iny
	lda ($00),y
	sta $03
	
	pea.w .current_test-1
	jmp ($0002)

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
	sec
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
	clc
	rts
	
.left
	lda $fe
	dec
	bmi +
	sta $fe
+	rts

.right
	lda $fe
	inc
	cmp #$02
	beq +
	sta $fe
+	sec
	rts
	
test_table:
	dw test_table_page1
	dw test_table_page2
	
test_table_page1:
	db 1 : dw test_rom			; WRAM ROM
	db 2 : dw test_rom_parallel		; ROM ROM
	db 3 : dw test_iram			; WRAM IRAM
	db 4 : dw test_iram_rom			; ROM IRAM
	db 5 : dw test_bwram			; WRAM BWRAM
	db 6 : dw test_bwram_rom		; ROM BWRAM
	db 7 : dw test_iram_iram		; IRAM IRAM
	db 8 : dw test_bwram_bwram		; BWRAM BWRAM
	db 9 : dw test_hdma_rom			; HDMA-ROM ROM
	db 10 : dw test_hdma_wram		; HDMA-WRAM ROM
	db 11 : dw test_dma_rom			; DMA-ROM ROM
	db 12 : dw test_dma_iram		; DMA-ROM IRAM
	db 14 : dw test_scpu_rom		; SCPU ROM
	db 15 : dw test_scpu_wram		; SCPU WRAM
	db 16 : dw test_scpu_iram		; SCPU IRAM
	db 18 : dw test_scpu_hdma_rom		; SCPU ROM
	db 19 : dw test_scpu_hdma_wram		; SCPU WRAM
	db 20 : dw test_scpu_hdma_iram		; SCPU IRAM
	db $FF ; end.
	
test_table_page2:
	db 1 : dw test_rom_o			; WRAM ROM (odd address)
	db 2 : dw test_rom_parallel_o		; ROM ROM (odd address)
	db 3 : dw test_rom_16			; WRAM ROM (16 clock)
	db 4 : dw test_rom_parallel_16		; ROM ROM (16 clock)
	db 5 : dw test_rom_16o			; WRAM ROM (16 clock odd)
	db 6 : dw test_rom_parallel_16o		; ROM ROM (16 clock odd)
	db 7 : dw test_iram_iram_o		; IRAM IRAM (odd address)
	db 8 : dw test_bwram_bwram_o		; BWRAM BWRAM (odd address)
	db 9 : dw test_iram_iram_16		; IRAM IRAM (16 clock)
	db 10 : dw test_bwram_bwram_16		; BWRAM BWRAM (16 clock)
	db 11 : dw test_iram_iram_16o		; IRAM IRAM (16 clock odd)
	db 12 : dw test_bwram_bwram_16o		; BWRAM BWRAM (16 clock odd)
	db 13 : dw test_wram_rom_mmio		; WRAM ROM-MMIO
	db 14 : dw test_rdma_mmio		; RDMA-MMIO ROM-MMIO
	db 15 : dw test_wdma_mmio		; WDMA-MMIO ROM-MMIO
	db 16 : dw test_wdma_mmio2		; WDMA-MMIO ROM-MMIO 2 (targets $2223)
	db 17 : dw test_rdma_iram		; RDMA-IRAM IRAM
	db 18 : dw test_wdma_iram		; WDMA-IRAM IRAM
	db 19 : dw test_rdma_bwram		; WDMA-BWRAM BWRAM
	db 20 : dw test_wdma_bwram		; WDMA-BWRAM BWRAM
	db $FF ; end.

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
	
	lda #$01
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
	lda #$81
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
	ldx $3046
	stx $2118
	stz $2119

	lda $3044
	jsr HexDec
	
	; high number
	stx $2118
	stz $2119
	
	; dot [.]
	ldx #$24
	stx $2118
	stz $2119
	
	; low number
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
	
	; extra digit.
	lda $3048
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
	db " FAILED |",$ff
	
test_rdma_iram:			; RDMA-IRAM IRAM
	jsl Speed_Test_26|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|RDMA I-RAM|  I-RAM  |~",$ff

test_wdma_iram:			; WDMA-IRAM IRAM
	jsl Speed_Test_27|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|WDMA I-RAM|  I-RAM  |~",$ff

test_rdma_bwram:		; WDMA-BWRAM BWRAM
	jsl Speed_Test_28|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|RDMA BWRAM| BW-RAM  |~",$ff

test_wdma_bwram:		; WDMA-BWRAM BWRAM
	jsl Speed_Test_29|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|WDMA BWRAM| BW-RAM  |~",$ff
	
test_wram_rom_mmio:		; WRAM ROM-MMIO
	jsl Speed_Test_22|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   WRAM   |ROM MMIO | ",$ff

test_rdma_mmio:			; RDMA-MMIO ROM-MMIO
	jsl Speed_Test_23|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| RDMA MMIO|ROM MMIO |~",$ff

test_wdma_mmio:			; WDMA-MMIO ROM-MMIO
	jsl Speed_Test_24|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| WDMA MMIO|ROM MMIO |~",$ff
	
test_wdma_mmio2:		; WDMA-MMIO ROM-MMIO (targets $2223)
	jsl Speed_Test_25|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| WDMA SMMC|ROM MMIO |~",$ff
	
test_rom_o:
	jsl Speed_Test_8|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   WRAM   | ROM-ODD | ",$ff

test_rom_parallel_o:
	jsl Speed_Test_8
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   ROM    | ROM-ODD | ",$ff

test_rom_16:
	jsl Speed_Test_7|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   WRAM   | ROM-16C | ",$ff

test_rom_parallel_16o:
	jsl Speed_Test_6
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   ROM    | ROM-16O | ",$ff

test_rom_16o:
	jsl Speed_Test_6|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   WRAM   | ROM-16O | ",$ff

test_rom_parallel_16:
	jsl Speed_Test_7
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   ROM    | ROM-16C | ",$ff
	
test_rom:
	jsl Speed_Test_9|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   WRAM   |   ROM   | ",$ff

test_rom_parallel:
	jsl Speed_Test_9
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   ROM    |   ROM   | ",$ff

test_bwram:
	jsl Speed_Test_10|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   WRAM   |  BW-RAM | ",$ff

test_bwram_rom:
	jsl Speed_Test_10
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   ROM    |  BW-RAM | ",$ff

test_iram:
	jsl Speed_Test_11|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   WRAM   |  I-RAM  | ",$ff

test_iram_rom:
	jsl Speed_Test_11
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|   ROM    |  I-RAM  | ",$ff

test_iram_iram:
	jsl Speed_Test_12
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|  I-RAM   |  I-RAM  | ",$ff

test_bwram_bwram:
	jsl Speed_Test_13
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|  BW-RAM  |  BW-RAM | ",$ff

test_iram_iram_o:
	jsl Speed_Test_4;12
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|  I-RAM   | I-RAM-O | ",$ff

test_bwram_bwram_o:
	jsl Speed_Test_5;13
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|  BW-RAM  | BW-RAM-O| ",$ff

test_iram_iram_16:
	jsl Speed_Test_2;12
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|  I-RAM   | I-RAM16C| ",$ff

test_bwram_bwram_16:
	jsl Speed_Test_3;13
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|  BW-RAM  |BW-RAM16C| ",$ff

test_iram_iram_16o:
	jsl Speed_Test_0;12
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|  I-RAM   | I-RAM16O| ",$ff

test_bwram_bwram_16o:
	jsl Speed_Test_1;13
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "|  BW-RAM  |BW-RAM16O| ",$ff



test_hdma_rom:
	jsl Speed_Test_14|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| HDMA ROM |   ROM   | ",$ff

test_hdma_wram:
	jsl Speed_Test_15|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| HDMA WRAM|   ROM   | ",$ff

test_dma_rom:
	jsl Speed_Test_16|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| DMA ROM  |   ROM   |~",$ff

test_dma_iram:
	jsl Speed_Test_17|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| DMA ROM  |  I-RAM  |~",$ff

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
	
.str	db "| S-CPU   ROM Access | ",$ff

	;   0123456789abcdef0123456789abcdef
.string	db "#__________*_________%_________$",$ff

test_scpu_wram:
	jsl Speed_Test_18|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| S-CPU  WRAM Access | ",$ff

test_scpu_iram:
	jsl Speed_Test_19
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| S-CPU I-RAM Access | ",$ff

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
	
.str	db "| S-CPU   ROM Access | ",$ff

	;   0123456789abcdef0123456789abcdef
.string	db "#_____________{HDMA  #_________$",$ff

test_scpu_hdma_wram:
	jsl Speed_Test_20|$7f0000
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| S-CPU  WRAM Access | ",$ff

test_scpu_hdma_iram:
	jsl Speed_Test_21
	rep #$20
	lda #.str
	jsr write_text
	rts
	
.str	db "| S-CPU I-RAM Access | ",$ff
	
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

sa1_clock_mmio:
	stx $81		; \ "small insignificant noise"
	stx $220b	;  |
	cli		; /
	
print "ROM test position (should be even): $", pc

-	bit $2306	; 5 cycles     \ 16 cycles
	bit $2308	; 5 cycles      |
	adc #$0001	; 3 mem cycles  |
	jmp -		; 3 mem cycles /
.end

sa1_clock:
	stx $81		; \ "small insignificant noise"
	stx $220b	;  |
	cli		; /
	
print "ROM test position (should be even): $", pc

-	adc #$0000	; 3 mem cycles \ 15 cycles
	adc #$0000	; 3 mem cycles  |
	adc #$0000	; 3 mem cycles  |
	adc #$0001	; 3 mem cycles  |
	jmp -		; 3 mem cycles /
.end

sa1_clock_odd:
	stx $81		; \ "small insignificant noise"
	stx $220b	;  |
	cli		; /
	
print "ROM test position (should be odd):  $", pc

-	adc #$0000	; 3 mem cycles \ 15 cycles
	adc #$0000	; 3 mem cycles  |
	adc #$0000	; 3 mem cycles  |
	adc #$0001	; 3 mem cycles  |
	jmp -		; 3 mem cycles /
.end

sa1_clock_16:
	stx $81		; \ "small insignificant noise"
	stx $220b	;  |
	cli		; /
	
print "ROM test position (should be even): $", pc

-	cpx #$ff	; 2 mem cycles \ 16 cycles
	cpx #$ff	; 2 mem cycles  |
	adc #$0000	; 3 mem cycles  |
	adc #$0000	; 3 mem cycles  |
	adc #$0001	; 3 mem cycles  |
	jmp -		; 3 mem cycles /
.end


NOP	; shift.

sa1_clock_16_odd:
	stx $81		; \ "small insignificant noise"
	stx $220b	;  |
	cli		; /
	
print "ROM test position (should be odd):  $", pc

-	cpx #$ff	; 2 mem cycles \ 16 cycles
	cpx #$ff	; 2 mem cycles  |
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

sa1_clock_bwram_odd:
base $7f01
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

sa1_clock_iram_odd:
base $3601
	stx $81		; \ "small insignificant noise"
	stx $220b	;  |
	cli		; /
	
-	adc #$0000	; 3 mem cycles \ 15 cycles
	adc #$0000	; 3 mem cycles  |
	adc #$0000	; 3 mem cycles  |
	adc #$0001	; 3 mem cycles  |
	jmp -		; 3 mem cycles /
base off
sa1_clock_iram_odd_end:

sa1_clock_bwram_16:
base $7f00
	stx $81		; \ "small insignificant noise"
	stx $220b	;  |
	cli		; /
	
-	cpx #$ff	; 2 mem cycles \ 16 cycles
	cpx #$ff	; 2 mem cycles  |
	adc #$0000	; 3 mem cycles  |
	adc #$0000	; 3 mem cycles  |
	adc #$0001	; 3 mem cycles  |
	jmp -		; 3 mem cycles /
base off
.end

sa1_clock_iram_16:
base $3600
	stx $81		; \ "small insignificant noise"
	stx $220b	;  |
	cli		; /
	
-	cpx #$ff	; 2 mem cycles \ 16 cycles
	cpx #$ff	; 2 mem cycles  |
	adc #$0000	; 3 mem cycles  |
	adc #$0000	; 3 mem cycles  |
	adc #$0001	; 3 mem cycles  |
	jmp -		; 3 mem cycles /
base off
.end

sa1_clock_bwram_16o:
base $7f01
	stx $81		; \ "small insignificant noise"
	stx $220b	;  |
	cli		; /
	
-	cpx #$ff	; 2 mem cycles \ 16 cycles
	cpx #$ff	; 2 mem cycles  |
	adc #$0000	; 3 mem cycles  |
	adc #$0000	; 3 mem cycles  |
	adc #$0001	; 3 mem cycles  |
	jmp -		; 3 mem cycles /
base off
.end

sa1_clock_iram_16o:
base $3601
	stx $81		; \ "small insignificant noise"
	stx $220b	;  |
	cli		; /
	
-	cpx #$ff	; 2 mem cycles \ 16 cycles
	cpx #$ff	; 2 mem cycles  |
	adc #$0000	; 3 mem cycles  |
	adc #$0000	; 3 mem cycles  |
	adc #$0001	; 3 mem cycles  |
	jmp -		; 3 mem cycles /
base off
.end

sa1_clock_finish_16:
	stz $2250
	inc
	sta $46
	sta $2251
	asl
	lda.w #63018	; 8.16 fixed point. ==> 315.0 / 88.0 * 1000000 * 6 / (262 * 1364) * 16 / 1000 * 65536
	bra sa1_clock_finish_continue
	
sa1_clock_finish:
	stz $2250
	inc
	sta $46
	sta $2251
	asl
	lda.w #59079	; 8.16 fixed point. ==> 315.0 / 88.0 * 1000000 * 6 / (262 * 1364) * 15 / 1000 * 65536
.continue		; +/- 0.9 kHz resolution (or 0.00090 MHz)
	sta $2253
	ldy #$01
	bcs +
	lda $46
+	ldx $2307
	stx $48
	ldx $2306
	clc
	adc $2308
	sty $2250
	sta $2251
	lda.w #10000
	sta $2253
	nop
	xba
	lda $2306
	sta $46
	lda $2308
	sta $2251
	lda.w #100
	sta $2253
	nop
	xba
	lda $2306
	sta $44
	lda $2308
	sta $42
	
	stz $2250
	stx $2251
	ldx $48
	php
	stx $2252
	lda.w #100
	sta $2253
	plp
	bmi +
	lda #$0000
+	clc
	adc $2308
	sta $48
	
	sty $80		; data ready.
	
	ldx #$f0
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

Speed_Test_29: ; bwram + wdma
	%transfer(sa1_clock_bwram, $7f00)
	rep #$20
	lda #$7f00
	sta $2207
	lda #sa1_clock_finish
	sta $f0
	lda #$2000
	sta $2181
	ldy #$00
	sty $2183
	lda #$7e00 ; bwram address
	sta $4322
	lda #$8088 ; write
	jmp Speed_Test_23_continue
Speed_Test_28: ; bwram + rdma
	%transfer(sa1_clock_bwram, $7f00)
	rep #$20
	lda #$7f00
	sta $2207
	lda #sa1_clock_finish
	sta $f0
	lda #$2000
	sta $2181
	ldy #$00
	sty $2183
	lda #$7e00 ; bwram address
	sta $4322
	lda #$8088 ; read
	jmp Speed_Test_23_continue
Speed_Test_27: ; iram + wdma
	%transfer(sa1_clock_iram, $3600)
	rep #$20
	lda #$3600
	sta $2207
	lda #sa1_clock_finish
	sta $f0
	lda #$2000
	sta $2181
	ldy #$00
	sty $2183
	lda #$3200 ; iram address
	sta $4322
	lda #$8088 ; write
	jmp Speed_Test_23_continue
Speed_Test_26: ; iram + rdma
	%transfer(sa1_clock_iram, $3600)
	rep #$20
	lda #$3600
	sta $2207
	lda #sa1_clock_finish
	sta $f0
	lda #$2000
	sta $2181
	ldy #$00
	sty $2183
	lda #$3200 ; iram address
	sta $4322
	lda #$8008 ; read
	jmp Speed_Test_23_continue

Speed_Test_22:
	rep #$20
	lda #sa1_clock_mmio
	sta $2207
	lda #sa1_clock_finish_16
	sta $f0
	sep #$20

	lda #$01
	sta $4200
	
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	
	stz $3080
	stz $3081
	
	lda #$81
	sta $4200
	
	lda #$00		; \ Wait for timer over.
-	cmp #$00		;  |
	bmi +			;  |
	jmp -			; /
+

	
-	lda $3080
	beq -
	lda #$01
	sta $4200
	stz $0a01
	rtl

Speed_Test_23:
	rep #$20
	lda #sa1_clock_mmio
	sta $2207
	lda #sa1_clock_finish_16
	sta $f0
	
	lda #$2000
	sta $2181
	ldy #$00
	sty $2183
	lda #$2300
	sta $4322
	lda #$8008
.continue
	sta $4320
	ldy #$00
	sty $4324
	stz $4325
	sep #$20
	
	lda #$01
	sta $4200
	
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	
	stz $3080
	stz $3081
	
	lda #$81
	sta $4200
	
	ldy #$04
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
	lda #$01
	sta $4200
	stz $0a01
	rtl
	
Speed_Test_25:
	rep #$20
	lda #sa1_clock_mmio
	sta $2207
	lda #sa1_clock_finish_16
	sta $f0
	
	lda #$2000
	sta $2181
	ldy #$00
	sty $2183
	lda #$2223 ; a register that nobody cares (super mmc fxb)
	sta $4322
	lda #$8088
	jmp Speed_Test_23_continue
	
Speed_Test_24:
	rep #$20
	lda #sa1_clock_mmio
	sta $2207
	lda #sa1_clock_finish_16
	sta $f0
	
	lda #$2000
	sta $2181
	ldy #$00
	sty $2183
	lda #$2206 ; a register that nobody cares (sa-1 nmi vector)
	sta $4322
	lda #$8088
	jmp Speed_Test_23_continue

Speed_Test_21:
	rep #$20
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
	lda #sa1_clock_finish
	sta $f0
	sep #$20
	lda #$ff
	sta $420c
	phk
	jsr Speed_Test_19
	stz $420c
	lda #$01
	sta $4200
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
	lda #sa1_clock_finish
	sta $f0
	sep #$20
	lda #$ff
	sta $420c
	phk
	jsr Speed_Test_18
	stz $420c
	lda #$01
	sta $4200
	stz $0a01
	rtl

; S-CPU test.
Speed_Test_19:
	lda #$01
	sta $4200
	
	lda.b #NMI_code1-NMI_code0
	sta $0a01
	stz $3081
	stz $3080
	
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	
	rep #$21
	lda #sa1_clock_finish
	sta $f0
	lda #$0000
	ldx #$81
	stx $4200
	jmp.w snes_clock_iram
	
; S-CPU test.
Speed_Test_18:
	lda #$01
	sta $4200
	
	lda.b #NMI_code1-NMI_code0
	sta $0a01
	stz $3081
	stz $3080
	
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	
	rep #$21
	lda #sa1_clock_finish
	sta $f0
	lda #$0000
	ldx #$81
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
	lda #sa1_clock_finish
	sta $f0
	jmp Speed_Test_16_continue
	
Speed_Test_16:
	rep #$20
	lda #sa1_clock
	sta $2207
	lda #sa1_clock_finish
	sta $f0
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
	
	lda #$01
	sta $4200
	
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	
	stz $3080
	stz $3081

	ldy #$04
	lda #$81
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
	
	lda #$01
	sta $4200
	stz $0a01
	rtl

hdma_tbl:
	rep 224 : dl hdma_data_ptr<<8|$01
	db $00
hdma_data_ptr:
	dw $0000, $0000

Speed_Test_15:
	lda #$01
	sta $4200
	
	rep #$20
	lda #sa1_clock
	sta $2207
	lda #sa1_clock_finish
	sta $f0
	
	
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
	lda #$01
	sta $4200
	
	rep #$20
	lda #sa1_clock
	sta $2207
	lda #sa1_clock_finish
	sta $f0
	
	
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
	
	lda #$81
	sta $4200
	
	lda #$00		; \ Wait for timer over.
-	cmp #$00		;  |
	bmi +			;  |
	jmp -			; /
+

-	lda $3080
	beq -

	lda #$01
	sta $4200
	stz $420c
	stz $0a01
	rtl

Speed_Test_1:
	%transfer(sa1_clock_bwram_16o, $7f01)
	%transfer(snes_test_bwram, $7e00)

	rep #$20
	lda #$7f01
	sta $2207
	jmp Speed_Test_13_continue2

Speed_Test_3:
	%transfer(sa1_clock_bwram_16, $7f00)
	%transfer(snes_test_bwram, $7e00)

	rep #$20
	lda #$7f00
	sta $2207
	bra Speed_Test_13_continue2
	
Speed_Test_5:
	%transfer(sa1_clock_bwram_odd, $7f01)
	%transfer(snes_test_bwram, $7e00)

	rep #$20
	lda #$7f01
	sta $2207
	bra Speed_Test_13_continue
	
Speed_Test_13:
	%transfer(sa1_clock_bwram, $7f00)
	%transfer(snes_test_bwram, $7e00)

	rep #$20
	lda #$7f00
	sta $2207
.continue
	lda #sa1_clock_finish
	sta $f0
.continue2
	sep #$20
	
	lda #$01
	sta $4200
	
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	
	stz $3080
	stz $3081
	
	lda #$81
	sta $4200
	
	jsr $7e00
	
	lda #$01
	sta $4200
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

Speed_Test_0:
	%transfer(sa1_clock_iram_16o, $3601)
	%transfer(snes_test_iram, $3500)
	rep #$20
	lda #$3601
	sta $2207
	lda #sa1_clock_finish_16
	sta $f0
	jmp Speed_Test_12_continue2

Speed_Test_2:
	%transfer(sa1_clock_iram_16, $3600)
	%transfer(snes_test_iram, $3500)
	rep #$20
	lda #$3600
	sta $2207
	lda #sa1_clock_finish_16
	sta $f0
	bra Speed_Test_12_continue2

Speed_Test_4:
	%transfer(sa1_clock_iram_odd, $3601)
	%transfer(snes_test_iram, $3500)
	rep #$20
	lda #$3601
	sta $2207
	bra Speed_Test_12_continue
	
Speed_Test_12:
	%transfer(sa1_clock_iram, $3600)
	%transfer(snes_test_iram, $3500)

	rep #$20
	lda #$3600
	sta $2207
.continue
	lda #sa1_clock_finish
	sta $f0
.continue2
	sep #$20
	
	lda #$01
	sta $4200
	
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
	
	lda #$81
	sta $4200
	
	jsr $3500
	
	lda #$01
	sta $4200
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
	lda #sa1_clock_finish
	sta $f0
	sep #$20
	
	lda #$01
	sta $4200
	
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	
	stz $3080
	stz $3081
	
	lda #$81
	sta $4200
	
	lda #$00		; \ Wait for timer over.
-	cmp #$00		;  |
	bmi +			;  |
	jmp -			; /
+
	
-	lda $3080
	beq -
	lda #$01
	sta $4200
	stz $0a01
	rtl
	
Speed_Test_10:
	%transfer(sa1_clock_bwram, $7f00)

	rep #$20
	lda #$7f00
	sta $2207
	lda #sa1_clock_finish
	sta $f0
	sep #$20
	
	lda #$01
	sta $4200
	
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	
	stz $3080
	stz $3081
	
	lda #$81
	sta $4200
	
	lda #$00		; \ Wait for timer over.
-	cmp #$00		;  |
	bmi +			;  |
	jmp -			; /
+

-	lda $3080
	beq -
	lda #$01
	sta $4200
	stz $0a01
	rtl

Speed_Test_9:
	rep #$20
	lda #sa1_clock
	sta $2207
	lda #sa1_clock_finish
	sta $f0
	sep #$20
.continue
	
	lda #$01
	sta $4200
	
-	bit $4212
	bpl -
-	bit $4212
	bmi -
	
	stz $3080
	stz $3081
	
	lda #$81
	sta $4200
	
	lda #$00		; \ Wait for timer over.
-	cmp #$00		;  |
	bmi +			;  |
	jmp -			; /
+

	
-	lda $3080
	beq -
	lda #$01
	sta $4200
	stz $0a01
	rtl
	
Speed_Test_8:
	rep #$20
	lda #sa1_clock_odd
	sta $2207
	lda #sa1_clock_finish
	sta $f0
	sep #$20
	jmp Speed_Test_9_continue
	
Speed_Test_7:
	rep #$20
	lda #sa1_clock_16
	sta $2207
	lda #sa1_clock_finish_16
	sta $f0
	sep #$20
	jmp Speed_Test_9_continue
	
Speed_Test_6:
	rep #$20
	lda #sa1_clock_16_odd
	sta $2207
	lda #sa1_clock_finish_16
	sta $f0
	sep #$20
	jmp Speed_Test_9_continue

print "Bank 1: $", pc
