printendtext:
	%cursor_pos(22)
	rep #$20
	lda #.string
	sta $00
	stz $02
	jsl WriteASCII
	
	;sep #$20
	;lda $213e
	;and #$0f
	;sta $2118
	;stz $2119
	;rep #$20
	
	;lda #.string2
	;sta $00
	;stz $02
	;jsl WriteASCII
	
	;sep #$20
	;lda $213f
	;and #$0f
	;sta $2118
	;stz $2119
	;rep #$20
	
	;lda #.string3
	;sta $00
	;stz $02
	;jsl WriteASCII
	
	sep #$20
	;lda $4210
	;and #$0f
	;sta $2118
	;stz $2119
	;rep #$20
	
	lda #$80
	sta $2100
	
	ldy #$00
	
macro writereg(reg)
	lda <reg>
	lsr #4
	sta $2118
	sty $2119
	lda <reg>
	and #$0f
	sta $2118
	sty $2119
	tya
	eor #$04
	tay
endmacro
	%writereg($bf2200)
	%writereg($be2201)
	%writereg($bd2202)
	%writereg($bc2203)
	%writereg($bb2204)
	%writereg($ba2205)
	%writereg($b92206)
	%writereg($b82207)
	%writereg($b72208)
	%writereg($b62209)
	%writereg($b5220A)
	%writereg($b4220B)
	%writereg($b3220C)
	%writereg($b2220D)
	%writereg($b1220E)
	%writereg($b0220F)
	%writereg($bf2210)
	%writereg($be2211)
	%writereg($bd2212)
	%writereg($bc2213)
	%writereg($bb2214)
	%writereg($ba2215)
	%writereg($b92216)
	%writereg($b82217)
	%writereg($b72218)
	%writereg($b62219)
	%writereg($b5221A)
	%writereg($b4221B)
	%writereg($b3221C)
	%writereg($b2221D)
	%writereg($b1221E)
	%writereg($b0221F)
	%writereg($bf2220)
	%writereg($be2221)
	%writereg($bd2222)
	%writereg($bc2223)
	%writereg($bb2224)
	%writereg($ba2225)
	%writereg($b92226)
	%writereg($b82227)
	%writereg($b72228)
	%writereg($b62229)
	%writereg($b5222A)
	%writereg($b4222B)
	%writereg($b3222C)
	%writereg($b2222D)
	%writereg($b1222E)
	%writereg($b0222F)
	%writereg($bf2230)
	%writereg($be2231)
	%writereg($bd2232)
	%writereg($bc2233)
	%writereg($bb2234)
	%writereg($ba2235)
	%writereg($b92236)
	%writereg($b82237)
	%writereg($b72238)
	%writereg($b62239)
	%writereg($b5223A)
	%writereg($b4223B)
	%writereg($b3223C)
	%writereg($b2223D)
	%writereg($b1223E)
	%writereg($b0223F)
	%writereg($bf2240)
	%writereg($be2241)
	%writereg($bd2242)
	%writereg($bc2243)
	%writereg($bb2244)
	%writereg($ba2245)
	%writereg($b92246)
	%writereg($b82247)
	%writereg($b72248)
	%writereg($b62249)
	%writereg($b5224A)
	%writereg($b4224B)
	%writereg($b3224C)
	%writereg($b2224D)
	%writereg($b1224E)
	%writereg($b0224F)
	%writereg($bf2250)
	%writereg($be2251)
	%writereg($bd2252)
	%writereg($bc2253)
	%writereg($bb2254)
	%writereg($ba2255)
	%writereg($b92256)
	%writereg($b82257)
	%writereg($b72258)
	%writereg($b62259)
	%writereg($b5225A)
	%writereg($b4225B)
	%writereg($b3225C)
	%writereg($b2225D)
	%writereg($b1225E)
	%writereg($b0225F)
	%writereg($bf2260)
	%writereg($be2261)
	%writereg($bd2262)
	%writereg($bc2263)
	%writereg($bb2264)
	%writereg($ba2265)
	%writereg($b92266)
	%writereg($b82267)
	%writereg($b72268)
	%writereg($b62269)
	%writereg($b5226A)
	%writereg($b4226B)
	%writereg($b3226C)
	%writereg($b2226D)
	%writereg($b1226E)
	%writereg($b0226F)
	%writereg($bf2270)
	%writereg($be2271)
	%writereg($bd2272)
	%writereg($bc2273)
	%writereg($bb2274)
	%writereg($ba2275)
	%writereg($b92276)
	%writereg($b82277)
	%writereg($b72278)
	%writereg($b62279)
	%writereg($b5227A)
	%writereg($b4227B)
	%writereg($b3227C)
	%writereg($b2227D)
	%writereg($b1227E)
	%writereg($b0227F)
	%writereg($bf2200+128)
	%writereg($be2201+128)
	%writereg($bd2202+128)
	%writereg($bc2203+128)
	%writereg($bb2204+128)
	%writereg($ba2205+128)
	%writereg($b92206+128)
	%writereg($b82207+128)
	%writereg($b72208+128)
	%writereg($b62209+128)
	%writereg($b5220A+128)
	%writereg($b4220B+128)
	%writereg($b3220C+128)
	%writereg($b2220D+128)
	%writereg($b1220E+128)
	%writereg($b0220F+128)
	%writereg($bf2210+128)
	%writereg($be2211+128)
	%writereg($bd2212+128)
	%writereg($bc2213+128)
	%writereg($bb2214+128)
	%writereg($ba2215+128)
	%writereg($b92216+128)
	%writereg($b82217+128)
	%writereg($b72218+128)
	%writereg($b62219+128)
	%writereg($b5221A+128)
	%writereg($b4221B+128)
	%writereg($b3221C+128)
	%writereg($b2221D+128)
	%writereg($b1221E+128)
	%writereg($b0221F+128)
	%writereg($bf2220+128)
	%writereg($be2221+128)
	%writereg($bd2222+128)
	%writereg($bc2223+128)
	%writereg($bb2224+128)
	%writereg($ba2225+128)
	%writereg($b92226+128)
	%writereg($b82227+128)
	%writereg($b72228+128)
	%writereg($b62229+128)
	%writereg($b5222A+128)
	%writereg($b4222B+128)
	%writereg($b3222C+128)
	%writereg($b2222D+128)
	%writereg($b1222E+128)
	%writereg($b0222F+128)
	%writereg($bf2230+128)
	%writereg($be2231+128)
	%writereg($bd2232+128)
	%writereg($bc2233+128)
	%writereg($bb2234+128)
	%writereg($ba2235+128)
	%writereg($b92236+128)
	%writereg($b82237+128)
	%writereg($b72238+128)
	%writereg($b62239+128)
	%writereg($b5223A+128)
	%writereg($b4223B+128)
	%writereg($b3223C+128)
	%writereg($b2223D+128)
	%writereg($b1223E+128)
	%writereg($b0223F+128)
	%writereg($bf2240+128)
	%writereg($be2241+128)
	%writereg($bd2242+128)
	%writereg($bc2243+128)
	%writereg($bb2244+128)
	%writereg($ba2245+128)
	%writereg($b92246+128)
	%writereg($b82247+128)
	%writereg($b72248+128)
	%writereg($b62249+128)
	%writereg($b5224A+128)
	%writereg($b4224B+128)
	%writereg($b3224C+128)
	%writereg($b2224D+128)
	%writereg($b1224E+128)
	%writereg($b0224F+128)
	%writereg($bf2250+128)
	%writereg($be2251+128)
	%writereg($bd2252+128)
	%writereg($bc2253+128)
	%writereg($bb2254+128)
	%writereg($ba2255+128)
	%writereg($b92256+128)
	%writereg($b82257+128)
	%writereg($b72258+128)
	%writereg($b62259+128)
	%writereg($b5225A+128)
	%writereg($b4225B+128)
	%writereg($b3225C+128)
	%writereg($b2225D+128)
	%writereg($b1225E+128)
	%writereg($b0225F+128)
	%writereg($bf2260+128)
	%writereg($be2261+128)
	%writereg($bd2262+128)
	%writereg($bc2263+128)
	%writereg($bb2264+128)
	%writereg($ba2265+128)
	%writereg($b92266+128)
	%writereg($b82267+128)
	%writereg($b72268+128)
	%writereg($b62269+128)
	%writereg($b5226A+128)
	%writereg($b4226B+128)
	%writereg($b3226C+128)
	%writereg($b2226D+128)
	%writereg($b1226E+128)
	%writereg($b0226F+128)
	%writereg($bf2270+128)
	%writereg($be2271+128)
	%writereg($bd2272+128)
	%writereg($bc2273+128)
	%writereg($bb2274+128)
	%writereg($ba2275+128)
	%writereg($b92276+128)
	%writereg($b82277+128)
	%writereg($b72278+128)
	%writereg($b62279+128)
	%writereg($b5227A+128)
	%writereg($b4227B+128)
	%writereg($b3227C+128)
	%writereg($b2227D+128)
	%writereg($b1227E+128)
	%writereg($b0227F+128)
	
	rep #$20
	
	lda #.string5
	sta $00
	stz $02
	jsl WriteASCII
	
	sep #$20
	
ldy #$00

	%writereg($bf2300)
	%writereg($be2301)
	%writereg($bd2302)
	%writereg($bc2303)
	%writereg($bb2304)
	%writereg($ba2305)
	%writereg($b92306)
	%writereg($b82307)
	%writereg($b72308)
	%writereg($b62309)
	%writereg($b5230A)
	%writereg($b4230B)
	%writereg($b3230C)
	%writereg($b2230D)
	%writereg($b1230E)
	%writereg($b0230F)
	%writereg($bf2310)
	%writereg($be2311)
	%writereg($bd2312)
	%writereg($bc2313)
	%writereg($bb2314)
	%writereg($ba2315)
	%writereg($b92316)
	%writereg($b82317)
	%writereg($b72318)
	%writereg($b62319)
	%writereg($b5231A)
	%writereg($b4231B)
	%writereg($b3231C)
	%writereg($b2231D)
	%writereg($b1231E)
	%writereg($b0231F)
	%writereg($bf2300+32)
	%writereg($be2301+32)
	%writereg($bd2302+32)
	%writereg($bc2303+32)
	%writereg($bb2304+32)
	%writereg($ba2305+32)
	%writereg($b92306+32)
	%writereg($b82307+32)
	%writereg($b72308+32)
	%writereg($b62309+32)
	%writereg($b5230A+32)
	%writereg($b4230B+32)
	%writereg($b3230C+32)
	%writereg($b2230D+32)
	%writereg($b1230E+32)
	%writereg($b0230F+32)
	%writereg($bf2310+32)
	%writereg($be2311+32)
	%writereg($bd2312+32)
	%writereg($bc2313+32)
	%writereg($bb2314+32)
	%writereg($ba2315+32)
	%writereg($b92316+32)
	%writereg($b82317+32)
	%writereg($b72318+32)
	%writereg($b62319+32)
	%writereg($b5231A+32)
	%writereg($b4231B+32)
	%writereg($b3231C+32)
	%writereg($b2231D+32)
	%writereg($b1231E+32)
	%writereg($b0231F+32)
	
		
	lda #$0f
	sta $2100
	sep #$20
	
	rep #$20
	lda #$0000
	ldy #$10
-	dec
	bne -
	dey
	bne -
	sep #$20
	rts
	
		;   0123456789abcdef0123456789abcdef
.string		db "#______________QX__*___________$",$ff
		;db "| 5C77 VER: 0",$ff
.string2	db                  "h'! 5C78 VER: 0",$ff
.string3	db "h|| 5A22 VER: 0",$ff
.string4	db                 "h'! SA1:",$ff
.string5	;   0123456789abcdef0123456789abcdef
		db "READ REGISTERS                  ",$ff

printinittext:
	rep #$20
	lda #$4000
	sta $2116
	lda #.string
	sta $00
	stz $02
	jsl WriteASCII
	
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
.string		db "<__{SNES-SA1 Speed Test v3.5}__>",$ff
.string1	db "|Current Operation             |",$ff
.string2	db "#__________&_______&___________$",$ff
.string3	db "|   SNES   |  SA-1 |   Speed   |",$ff
;;;;;;;;;;;;;;;;;;;;|DMA BW-RAM|DMA ROM
;;;;;;;;;;;;;;;;;;;;|DMA I-RAM|
;;;;;;;;;;;;;;;;;;;;|HDMA BWRAM|
	
SpeedSymbol:
	db " MHz |",$ff
