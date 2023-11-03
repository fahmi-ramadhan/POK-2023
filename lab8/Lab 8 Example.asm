;====================================================================
; Processor		: ATmega8515
; Compiler		: AVRASM
;====================================================================

;====================================================================
; DEFINITIONS
;====================================================================

.include "m8515def.inc"

;====================================================================
; RESET and INTERRUPT VECTORS
;====================================================================

.org $00 	; JUMP to MAIN to initialze
rjmp MAIN
.org $01	; When Button0 pressed, jump to ext_int0
rjmp ext_int0
.org $07	; When Timer0 overflows, jump to ISR_TOV0
rjmp ISR_TOV0

;====================================================================
; CODE SEGMENT
;====================================================================

; Initialize stack pointer
MAIN:
	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16

; Setup LED PORT
SET_LED:
	ser r16			; Load $FF to temp		
	out DDRB, r16	; Set PORTB to output	

; Setup Overflow Timer0
SET_TIMER:
	; Timer speed = clock/8 (set CS01 in TCCR0)
	ldi r16, (1<<CS01)
	out TCCR0, r16

	; Execute an internal interrupt when Timer0 overflows
	ldi r16, (1<<TOV0)
	out TIFR, r16

	; Set Timer0 overflow as the timer
	ldi r16, (1<<TOIE0)
	out TIMSK, r16

	; Set global interrupt flag
	sei

; While waiting for interrupt, loop infinitely
FOREVER:
	rjmp FOREVER

; Program executed on button press
ext_int0:
	reti

; Program executed on timer overflow
ISR_TOV0:
	push r16
	in r16, SREG
	push r16
	in r16, PORTB 	; Read Port B

	com r16			; Invert value in Port B

	out PORTB, r16	; Write to Port B
	pop r16
	out SREG, r16
	pop r16

	reti
