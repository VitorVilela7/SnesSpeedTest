macro transfer(label, ram)
	php
	phb
	rep #$30
	lda.w #<label>_end-<label>-1
	ldx.w #<label>
	ldy.w #<ram>
	mvn <ram>>>16, <label>>>16
	plb
	plp
endmacro

TransferROMtoRAM:
	lda $00
	sta $2181
	ldy $02
	sty $2183
	lda #$8000
	sta $4300
	lda $03
	sta $4302
	ldy $05
	sty $4304
	lda $06
	sta $4305
	ldy #$01
	sty $420b
	rts
