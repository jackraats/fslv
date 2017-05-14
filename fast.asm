; fslv.asm
; 
; Jack Raats
; van Nispenstraat 7
; 4651 XH Steenbergen
; Then Netherlands
; Tel: 31-167-540044
; E-mail: jack@raats.org

#include "zx81.inc"

#code _BASIC

; some rom routines and definitions

#define set_fast	$02ef	; fast 1 in ROM
#define ls_update	$01fc	; update in ROM (inc hl until E-LINE)
#define program		$407d	; program start

; start program and code

lineno	dw	0		; line no 0
length	dw	einde-start	; length of line
start	db	234		; REM
	db	118,118		; to hide code
start1	ld	hl,savecod	
	ld	de,save
	ld	bc,einde-savecod
	ldir			; move code to workplace above ramtop
	ld 	hl,tekst	; print text
loop1	ld	a,(hl)	
	cp	$ff
	ret	z
	push	hl
	rst	$10
	pop	hl
	inc	hl
	jr	loop1
tekst	dm	"F/S/L/V ROUTINES INSTALLED"
	db	118
	dm	"SAVE:   RAND USR 32000"
	db	118
	dm	"LOAD:   RAND USR 32074"
	db	118
	db	"VERIFY: RAND USR 32075"
	db	118,118
	db	"(C) JACK RAATS"
	db	118,255
savecod	equ	$

	.phase	32000

save	call	set_fast
	ld	hl,VERSN-1
	ld	c,0
leader1	ld	de,$1950
	call	pulses
	ld	b,$14
	dec	c
	jr	nz,leader1
st_bit	call	ls_update
	ld	b,$0b
	ld	a,(hl)
	scf
	jr	onebit
eachbit	ld	b,$11
	jr	c,zeroone
zerobit	ld	de,$1900
zeroone	jr	nc,bits
	and	a
onebit	ld	de,$3303
bits	adc	a,a
	ex	af,af
outbit	call	pulses
	ex	af,af
	jr	nz,eachbit
	jr	st_bit
pulses	djnz	pulses
	ld	b,d
	dec	e
	jr	z,high                                        
to_lo	out	($ff),a
low	djnz	low
	ld	a,$7f
to_hi	in	a,($fe)
high	dec	e
	ret	m
	ld	b,$16
	rra
	jr	c,pulses
break	rst	$08
	db	$0c

; load must start on even address

	align	2

load	nop
verify	call	set_fast
wait	ld	b,$20
leader	call	signal
	jr	nc,wait
	djnz	leader
	ld	hl,VERSN
st_bit1	call	signal
	jr	c,st_bit1
	ld	b,$08
reader	call	signal
	ccf
	rl	d
	djnz	reader
	bit	0,c
	jr	z,in_byte
	ld	a,d
	cp	(hl)
	jr	z,update
skip	ld	de,program
	and	a
	sbc	hl,de
	add	hl,de
	jr	c,update
	nop
	rst	$08
	db	$14
in_byte	ld	(hl),d
update	call	ls_update
	jr	st_bit1
signal	ld	e,$00
	ld	a,$7f
	in	a,($fe)
	out	($ff),a
	rra
	jr	nc,break
tape	in	a,($fe)
	inc	e
	rla
	jr	c,tape
	ld	a,e
	cp	$06
	jr	c,signal
	cp	$10
	ret

codend	equ	$

	.dephase

einde	equ	$

#end
