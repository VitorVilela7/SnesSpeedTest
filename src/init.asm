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
	
initirqnmi:
	%transfer(NMI, $0A00)
	rts
	
NMI:
	bra .code0

.code0
	lda $4210	; 3x8 + 6 clocks
	lda.b #.code3-.code0
	sta $0a01
	lda $3081
	beq +
	lda #$80
	sta $2200
-	lda $3081
	beq -
	rep #$20
	lda $f0
	sta $2207
	sep #$20
	lda #$ff
	rti
	
+	lda #$80
	sta $2200
-	lda $3081
	beq -
	stz $2200
	rep #$20
	lda $f0
	sta $2207
	sep #$20
	lda.b #.code0-.code0
	sta $0a01
	lda #$00
	rti
	
.code1
	ldx $4210
	ldx.b #.code2-.code0
	stx $0a01
	lda #$0001
	rti

.code2
	ldx $4210
	ldx.b #.code0-.code0
	stx $0a01
	sta $3084
	lda #evil_nmi_sa1_3
	sta $2207
	ldx #$80
	stx $2200
-	ldx $3080
	beq -
	pla
	pla
	cli
	sep #$30
	stz $4200
	rtl

.code3
	; error handler...
	sep #$10
	ldx $4210
	rep #$20
	lda #$01fa
	tcs
	sep #$20
	lda #$00
	pha
	plb
	
	stz $4200
	stz $0a01
	jsl recover
	lda #$69
	sta $3080
	sta $3081
	lda #$48
	sta $2132
	cli
	rtl
	
.end
