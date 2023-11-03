;====================================================================
; Processor		: ATmega8515
; Compiler		: AVRASM
;====================================================================

;====================================================================
; DEFINITIONS
;====================================================================

.include "m8515def.inc"
.def colorMode = r20	; registers for colorMode
;(0 = all color, 1 = red green yellow, 2 = red green, 3 = red

;====================================================================
; RESET and INTERRUPT VECTORS
;====================================================================

.org $00 	; JUMP to MAIN to initialze
rjmp MAIN
.org $07	; When Timer0 overflows, jump to ISR_TOV0
rjmp ISR_TOV0

;====================================================================
; CODE SEGMENT
;====================================================================

START:
	ldi colorMode, 0	; Default colorMode (all lights are on)
	ldi r21, 0			; Register to determine if the colorMode must
						; increase or decrease

; Initialize stack pointer
MAIN:
	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16


; Setup LED PORT
SET_LED:
	ser r16			; Load $FF to temp
	out DDRA, r16	; Set PORTA to output		
	out DDRB, r16	; Set PORTB to output
	out DDRC, r16	; Set PORTC to output
	out DDRD, r16	; Set PORTD to output

; Setup Overflow Timer0
SET_TIMER:
	; Timer speed = clock/1024 (set CS02 and CS00 in TCCR0)
	ldi r16, (1<<CS02) | (1<<CS00)
	out TCCR0, r16

	; Execute an internal interrupt when Timer0 overflows
	ldi r16, (1<<TOV0)
	out TIFR, r16

	; Set Timer0 overflow as the timer
	ldi r16, (1<<TOIE0)
	out TIMSK, r16

	; Set global interrupt flag
	sei

; Check Color Mode
CHECK_LED:
	cpi colorMode, 0	; if colorMode == 0, go to MODE_0
	breq MODE_0
	cpi colorMode, 1	; if colorMode == 1, go to MODE_1
	breq MODE_1
	cpi colorMode, 2	; if colorMode == 2, go to MODE_2
	breq MODE_2
	cpi colorMode, 3	; if colorMode == 3, go to MODE_3
	breq MODE_3

; All LED on
MODE_0:		
	ldi r16, 0xFF
	out PORTA, r16
	out PORTB, r16
	out PORTC, r16
	out PORTD, r16
	rcall DELAY
	rjmp FINISH

; Red, Green, and Yellow LED on
MODE_1:		
	ldi r16, 0xFF
	out PORTA, r16
	out PORTB, r16
	out PORTC, r16
	ldi r16, 0x00
	out PORTD, r16
	rcall DELAY
	rjmp FINISH

; Red and Green LED on
MODE_2:		
	ldi r16, 0xFF
	out PORTA, r16
	out PORTB, r16
	ldi r16, 0x00
	out PORTC, r16
	out PORTD, r16
	rcall DELAY
	rjmp FINISH

; Only Red LED on
MODE_3:		
	ldi r16, 0xFF
	out PORTA, r16
	ldi r16, 0x00
	out PORTB, r16
	out PORTC, r16
	out PORTD, r16
	rcall DELAY
	rjmp FINISH

; Finish one mode
FINISH:
	reti

; Program executed on timer overflow
ISR_TOV0:
	cpi r21, 1
	breq DECREMENT_colorMode	; if r21 == 1, go to DECREMENT_colorMode
	INCREMENT_colorMode:		; else go to INCREMENT_colorMode
		inc colorMode			; increment colorMode
		cpi colorMode, 3		
		breq CHANGE_TO_DECREMENT; if colorMode == 3, go to CHANGE_TO_DECREMENT
		rjmp MAIN

	DECREMENT_colorMode:
		dec colorMode			; decrement colorMode
		cpi colorMode, 0
		breq CHANGE_TO_INCREMENT; if colorMode == 0, go to CHANGE_TO_INCREMENT
		rjmp MAIN
	
	CHANGE_TO_INCREMENT:
		ldi r21, 0				; set r21 = 0 so that the colorMode is increasing
		rjmp MAIN

	CHANGE_TO_DECREMENT:
		ldi r21, 1				; set r21 = 1 so that the colorMode is decreasing
		rjmp MAIN

; Delay so that the program doesn't stop while waiting for the interrupt
DELAY:	
    ldi  r22, 5
    ldi  r23, 15
    ldi  r24, 242
L1: dec  r24
    brne L1
    dec  r23
    brne L1
    dec  r22
    brne L1
	ret
