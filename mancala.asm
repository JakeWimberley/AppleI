; vim: set noexpandtab ts=9:
; Mancala for the Apple I
; Jake Wimberley, June 2016
;
; given bpp = 6 the naming convention for pits and stores is:
;   ns n5 n4 n3 n2 n1 n0
;      m0 m1 m2 m3 m4 m5 ms
; stored in memory in clockwise order beginning with m0

	.cr	6502
	.tf	mancala.bin,AP1,8
	.or	$0320	; page 02 is used by Woz Monitor
kbd	.eq	$D010	; keyboard input reg
kbdcr	.eq	$D011	; MSB thereof is 1 when a key has been pressed
dsp	.eq	$D012	; output char to display
getline	.eq	$FF1F	; entry point to monitor
echo	.eq	$FFEF	; print A to screen

; constants
bpp	.eq	6	; num pits per side (and beans per pit) MUST BE <= 9
m0	.eq	$0300	; ptr to board
ms	.eq	m0+bpp
n0	.eq	ms+1
ns	.eq	n0+bpp
choice	.eq	$0319

reset	ldx	#$ff	; init stack
	txs

clstores	lda	#0	; set stores to 0
	sta	ms
	sta	ns

	lda	#bpp
	tax		; set x=bpp (max offset from m0 or n0 is bpp-1)
fillpits	dex
	sta	m0,x
	sta	n0,x
	cpx	#0
	bne	fillpits

	jsr	printall

	jsr	choose

quit	jmp	getline	; END

; print the whole board
printall lda	#$0d
	jsr	echo	; print CR to start
	ldy	ns	; copy ns to y, print
	jsr	printpit
	ldx	#bpp	; set x=bpp (max offset from m0 or n0 is bpp-1)
.startn  dex		; start loop with x=bpp-1
	ldy	n0,x	; copy pit value to y, then call printpit
	jsr	printpit
	clc
	cpx	#0
	bne	.startn
	lda	#$0d	; finished printing the n pits,
	jsr	echo	; so print CR
	lda	#' '
	jsr	echo	; print spaces to line up 2nd line
	jsr	echo
	jsr	echo
	ldx	#0	; set x=0
.startm	ldy	m0,x	; print pit value as above
	jsr	printpit
	inx
	clc
	cpx	#bpp	; stop when x==bpp
	bne	.startm
	ldy	ms	; copy ms to y, print
	jsr	printpit
	rts

; print hex value of value in Y plus a trailing space
printpit lda	#0
.counter	.eq	$e0
	sta	.counter	; digit counter
	tya
	lsr		; get high nybble of Y
	lsr
	lsr
	lsr
.printdg	clc
	cmp	#$0a
	bcc	.decdig	; if A < $0a
	clc
	adc	#$37	; add $37 to get 'A'-'F' (NOTE a1 set 'A' == 0x01)
.decdig	clc
	adc	#$30	; add $30 to get '0'-'9'
	jsr	echo	; print digit
	lda	.counter ; check to see if we have printed both digits,
	clc		; and if so, exit subroutine
	cmp	#1	
	beq	.return
	inc	.counter
	tya
	and	#$0F	; get low nybble
	jmp	.printdg
.return	lda	#' '
	jsr	echo
	rts

; print pit prompt and accept choice
choose   lda	#' '
	jsr	echo
	lda	#'?'
	jsr	echo
.getkey	lda	kbdcr
	bpl	.getkey	; loop until key pressed
	lda	kbd
	and	#$3F	; wipe out 2 MSB of key value
	jsr	echo
	sbc	#$30	; subtract $30 to get integer value of key
	clc
	cmp	#0
	beq	.badkey	; if A == 0 fail
	clc
	cmp	#bpp
	bcc	.svchc	; if A < bpp, OK
	beq	.svchc	; else if A == bpp, OK
	jmp	.badkey	; else fail
.svchc	sta	choice	; user made valid choice, return
	rts
.badkey	lda	#$0d	; <CR>
	jsr	echo
	lda	#'1'
	jsr	echo
	lda	#'-'
	jsr	echo
	lda	#bpp
	clc
	adc	#$30	; ascii char for bpp
	jsr	echo
	jmp	choose
