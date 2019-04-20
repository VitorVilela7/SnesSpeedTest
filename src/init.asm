supermmc:
	lda #$80
	sta $2220
	sta $2222
	inc a
	sta $2221
	sta $2223
	rts
	
setupsa1:
	lda #$20
	;sta $2200

	lda #$a0
	sta $2202
	sta $2201
	
	rep #$20
	lda #SA1Reset
	sta $2203
	sta $2207
	sta $2205
	sep #$20
	
	stz $2224
	lda #$80
	sta $2226
	stz $2228
	lda #$ff
	sta $2229
	stz $2200
	rts
	
initram:
	rep #$20
	ldy #$00
	sty $2181
	sty $2183
	ldy #$02
	sty $2182
	
	lda #$8008
	sta $4300
	lda #.zero
	sta $4302
	sty $4304
	lda #$2000 ; do not clear stack.
	sta $4305
	ldy #$01
	sty $420b
	sep #$20
	rts
	
.zero
	db $00
	
NMI:
	STP

