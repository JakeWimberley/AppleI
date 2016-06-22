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

quit	jmp	$FF1F	; END
