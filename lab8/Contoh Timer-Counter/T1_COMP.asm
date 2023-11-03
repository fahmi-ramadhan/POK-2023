.include "m8515def.inc"

.org $00
	rjmp RESET
.org $05
	rjmp ISR_TCOM1

RESET:
	ldi	r16,low(RAMEND)
	out	SPL,r16	            ;init Stack Pointer		
	ldi	r16,high(RAMEND)
	out	SPH,r16

	ldi r16, 1<<CS10 ; 
	out TCCR1B,r16			
	ldi r16,1<<OCF1B
	out TIFR,r16		; Interrupt if compare true in T/C0
	ldi r16,1<<OCIE1B
	out TIMSK,r16		; Enable Timer/Counter0 compare int
	ldi r16,0b11111111
	out OCR1BH,r16		; Set compared value
	ldi r16,0b00000000
	out OCR1BL,r16		; Set compared value
	ser r16
	out DDRB,r16		; Set port B as output
	sei

forever:
	rjmp forever

ISR_TCOM1:
	push r16
	in r16,SREG
	push r16
	in r16,PORTB	; read Port B
	com r16			; invert bits of r16 
	out PORTB,r16	; write Port B
	pop r16
	out SREG,r16
	pop r16
	reti
