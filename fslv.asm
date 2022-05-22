; Fast Save Load Verify 2400 baud
; Sinclair Impuls 

; Jack Raats
; van Nispenstraat 7
; 4651 XH Steenbergen

			org		30000

#define		set_fast	$02ef
#define		ls_update	$01fc
#define		versn		$4009
#define		progr		$407d

save		call	set_fast
			ld		hl,versn-1
			ld		c,0
leader		ld		de,$1950
			call	pulses
			ld		b,$14
			dec		c
			jr		nz,leader
st_bit		call	ls_update
			ld		b,$0b
			ld		a,(hl)
			scf
			jr		one_bit
each_bit	ld		b,$11
			jr		c,zero_one
zero_bit	ld		de,$1900
zero_one	jr		nc,bits
			and		a
one_bit		ld		de,$3303	
bits		adc		a,a
			ex		af,af
out_bit		call	pulses
			ex		af,af
			jr		nz,each_bit
			jr		st_bit
pulses		djnz	pulses
			ld		b,d
			dec		e
			jr		z,high
to_lo		out		($ff),a
low			djnz	low
			ld		a,$7f
to_hi		in		a,($fe)
high		dec		e		
			ret		m
			ld		b,$16
			rra	
			jr		c,pulses
break		rst		$08
			db		$0c

; load must start on even address

load		nop
verify		call	set_fast
wait		ld		b,$20
findleader	call	signal
			jr		nc,wait
			djnz	findleader
			ld		hl,versn
st_bit1		call	signal
			jr		c,st_bit1
			ld		b,$08
reader		call	signal
			ccf
			rl		d
			djnz	reader							
			bit		0,c
			jr		z,in_byte
			ld		a,d
			cp		(hl)
			jr		z,update
skip		ld		de,progr
			and		a
			sbc		hl,de
			add		hl,de
			jr		c,update
			nop
			rst		$08
			db		$14
in_byte		ld		(hl),d
update		call	ls_update
			jr		st_bit1
signal		ld		e,$00
			ld		a,$7f
			in		a,($fe)
			out		($ff),a
			rra
			jr		nc,break
tape		in		a,($fe)
			inc		e
			rla
			jr		c,tape
			ld		a,e
			cp		$06
			jr		c,signal
			cp		$10
			ret

; end of file