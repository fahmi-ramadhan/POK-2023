.include "m8515def.inc"

.org $00
	rjmp RESET

.org $07
	rjmp ISR_TOV0

.org $0E
	rjmp ISR_TCOM0

RESET:
	ldi	r16,low(RAMEND)
	out	SPL,r16	            ;init Stack Pointer		
	ldi	r16,high(RAMEND)
	out	SPH,r16

	ldi r16,1<<CS00 ; 
	out TCCR0,r16			
	ldi r16,(1<<TOV0)|(1<<OCF0)
	out TIFR,r16		; Interrupt if overflow and compare true in T/C0
	ldi r16,(1<<TOIE0)|(1<<OCIE0)
	out TIMSK,r16		; Enable Timer/Counter0 overflow & compare int
	ldi r16,0b10000000
	out OCR0,r16		; Set compared value
	ser r16
	out DDRA,r16		; Set port A as output
	out DDRB,r16		; Set port B as output
	sei

forever:
	rjmp forever

ISR_TOV0:
	push r16
	in r16,SREG
	push r16
	in r16,PORTA	; read Port A
	com r16			; invert bits of r16 
	out PORTA,r16	; write Port A
	pop r16
	out SREG,r16
	pop r16
	reti

ISR_TCOM0:
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
