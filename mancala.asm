; vim: set noexpandtab ts=9:
; Mancala for the Apple I
; Jake Wimberley, June 2016
;
; given b = 6 the naming convention for pits and stores is:
;   ns n5 n4 n3 n2 n1 n0
;      m0 m1 m2 m3 m4 m5 ms
; stored in memory in clockwise order beginning with m0

	.cr	6502
	.tf	mancala.bin,AP1,8
	.or	$0320	; page 02 is used by Woz Monitor
dsp	.eq	$D012	; output char to display
getline	.eq	$FF1F	; entry point to monitor

; constants
b	.eq	6	; num pits per side (and beans per pit)
m0	.eq	$0300	; ptr to board
ms	.eq	m0+b
n0	.eq	ms+1
ns	.eq	n0+b

reset	ldx	#$ff	; init stack
	txs

clstores	lda	#0	; set stores to 0
	sta	ms
	sta	ns

	lda	#b
	tax		; set x=b (max offset from m0 or n0 is b-1)
fillpits	dex
	sta	m0,x
	sta	n0,x
	cpx	#0
	bne	fillpits

	jmp	printall

quit	jmp	getline	; END

; print the whole board
printall lda	#$0d
	sta	dsp	; print CR to start
	ldy	ns	; copy ns to y, print
	jsr	printpit
.startn	tax		; set x=b (max offset from m0 or n0 is b-1)
	dex		; start loop with x=b-1
	ldy	n0,x	; copy pit value to y, then call printpit
	jsr	printpit
	cpx	#0
	bne	.startn
	lda	#$0d
	sta	dsp	; print CR
	lda	#$20
	sta	dsp	; print spaces to line up 2nd line
	sta	dsp
	sta	dsp
.startm	ldx	#0	; set x=0
	ldy	m0,x	; print pit value as above
	jsr	printpit
	inx
	clc
	cpx	#b	; stop when x==b
	bcc	.startm
	ldy	ms	; copy ms to y, print
	jsr	printpit
	lda	#$3F
	sta	dsp
	rts

; print hex value of value in y
printpit lda	#0
.counter	.eq	$F0
	sta	.counter	; digit counter
	tya
	lsr		; get high nybble
	lsr
	lsr
	lsr
.printdg	clc
	cmp	#$0a
	bcc	.decdig	; if A < $0a
	clc
	adc	#$37	; add $37 to get 'A'-'F'
.decdig	clc
	adc	#$30	; add $30 to get '0'-'9'
	sta	dsp	; print digit
	lda	#$20
	sta	dsp	; print space
	clc
	cmp	#1	; return if this is second digit
	beq	.return  ;
	inc	.counter
	tya
	and	#$0F	; get low nybble
	jmp	.printdg
.return	rts
