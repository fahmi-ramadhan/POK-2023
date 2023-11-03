;====================================================================
; Processor		: ATmega8515
; Compiler		: AVRASM
;====================================================================

;====================================================================
; DEFINITIONS
;====================================================================

.include "m8515def.inc"
.def temp = r16 ; temporary register
.def EW = r23 ; for PORTA
.def PB = r24 ; for PORTB
.def A  = r25
.def count = r21

;====================================================================
; RESET and INTERRUPT VECTORS
;====================================================================

.org $00
rjmp MAIN
.org $01
rjmp ext_int0

;====================================================================
; CODE SEGMENT
;====================================================================

MAIN:

INIT_STACK:
	ldi temp, low(RAMEND)
	ldi temp, high(RAMEND)
	out SPH, temp

rjmp INIT_LCD_MAIN

EXIT:
	rjmp EXIT

INPUT_TEXT:
	ldi ZH,high(2*message) ; Load high part of byte address into ZH
	ldi ZL,low(2*message) ; Load low part of byte address into ZL
	ret

INIT_LCD_MAIN:
	rcall INIT_LCD

	ser temp
	out DDRA,temp ; Set port A as output
	out DDRB,temp ; Set port B as output

	rcall INPUT_TEXT

INIT_INTERRUPT:
	ldi temp,0b00001010
	out MCUCR,temp
	ldi temp,0b11000000
	out GICR,temp
	sei

LOADBYTE_PHASE1:
	lpm ; Load byte from program memory into r0

	cpi count, 3 ; Check if we've reached the end for the first line
	breq PAUSE1 ; If so, change line

	mov A, r0 ; Put the character onto Port B
	rcall WRITE_TEXT
	inc count
	adiw ZL,1 ; Increase Z registers
	rjmp LOADBYTE_PHASE1

PAUSE1:
	rcall DELAY_02
	ldi count, 0

SET_LINE:
	cbi PORTA,1 ; CLR RS
	ldi PB,0xA7 ; MOV DATA,0xA7 --> set DDRAM Address to line 2
	out PORTB,PB ; Set data
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	sbiw ZL, 1	; Decrease Z registers

LOADBYTE_PHASE2:
	lpm ; Load byte from program memory into r0

	cpi count, 11 ; Check if we've reached the end for the second line
	breq EXIT ; If so, EXIT

	mov A, r0 ; Put the character onto Port B
	rcall WRITE_TEXT
	inc count
	adiw ZL,1 ; Increase Z registers
	rjmp LOADBYTE_PHASE2

PAUSE2:
	rcall DELAY_02
	ldi count, 0

LOOP_LCD:
	rjmp MAIN

INIT_LCD:
	cbi PORTA,1 ; CLR RS
	ldi PB,0x38 ; MOV DATA,0x38 --> 8bit, 2line, 5x7
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	rcall DELAY_01

	cbi PORTA,1 ; CLR RS
	ldi PB,$0E ; MOV DATA,0x0E --> disp ON, cursor ON, blink OFF
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	rcall DELAY_01

	rcall CLEAR_LCD ; CLEAR LCD

	cbi PORTA,1 ; CLR RS
	ldi PB,$06 ; MOV DATA,0x06 --> increase cursor, display sroll OFF
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	rcall DELAY_01
	ret

CLEAR_LCD:
	cbi PORTA,1 ; CLR RS
	ldi PB,$01 ; MOV DATA,0x01
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	rcall DELAY_01
	ret

WRITE_TEXT:
	sbi PORTA,1 ; SETB RS
	out PORTB, A
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	rcall DELAY_01
	ret

; handler interupt 0
ext_int0:
sbis PIND, 2
rjmp MAIN		; restart to main if button 0 pressed
reti

MAIN2:

INIT_STACK2:
	ldi temp, low(RAMEND)
	ldi temp, high(RAMEND)
	out SPH, temp

rjmp INIT_LCD_MAIN2

EXIT2:
	rjmp EXIT2

INPUT_TEXT2:
	ldi ZH,high(2*message2) ; Load high part of byte address into ZH
	ldi ZL,low(2*message2) ; Load low part of byte address into ZL
	ret

INIT_LCD_MAIN2:
	rcall INIT_LCD2

	ser temp
	out DDRA,temp ; Set port A as output
	out DDRB,temp ; Set port B as output

	rcall INPUT_TEXT2

LOADBYTE_PHASE3:
	lpm ; Load byte from program memory into r0

	cpi count, 4 ; Check if we've reached the end for the third line
	breq PAUSE3 ; If so, change line

	mov A, r0 ; Put the character onto Port B
	rcall WRITE_TEXT
	inc count
	adiw ZL,1 ; Increase Z registers
	rjmp LOADBYTE_PHASE3

PAUSE3:
	rcall DELAY_02
	ldi count, 0

SET_LINE2:
	cbi PORTA,1 ; CLR RS
	ldi PB,0xA7 ; MOV DATA,0xA7 --> set DDRAM Address to line 2
	out PORTB,PB ; Set data
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	sbiw ZL, 1	; Decrease Z registers

LOADBYTE_PHASE4:
	lpm ; Load byte from program memory into r0

	tst r0 ; Check if we've reached the end of the message
	breq EXIT2 ; If so, quit

	mov A, r0 ; Put the character onto Port B
	rcall WRITE_TEXT
	adiw ZL,1 ; Increase Z registers
	rjmp LOADBYTE_PHASE4

INIT_LCD2:
	cbi PORTA,1 ; CLR RS
	ldi PB,0x38 ; MOV DATA,0x38 --> 8bit, 2line, 5x7
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	rcall DELAY_01

	cbi PORTA,1 ; CLR RS
	ldi PB,$0E ; MOV DATA,0x0E --> disp ON, cursor ON, blink OFF
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	rcall DELAY_01

	rcall CLEAR_LCD2 ; CLEAR LCD

	cbi PORTA,1 ; CLR RS
	ldi PB,$06 ; MOV DATA,0x06 --> increase cursor, display sroll OFF
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	rcall DELAY_01
	ret

CLEAR_LCD2:
	cbi PORTA,1 ; CLR RS
	ldi PB,$01 ; MOV DATA,0x01
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	rcall DELAY_01
	ret

WRITE_TEXT2:
	sbi PORTA,1 ; SETB RS
	out PORTB, A
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	rcall DELAY_01
	ret


; handler interupt 1
ext_int1:
rcall MAIN2		; restart to main if button 1 pressed
reti

;====================================================================
; DELAYS	[ Generated by delay loop calculator at	  ]
; 		[ http://www.bretmulvey.com/avrdelay.html ]
;====================================================================

DELAY_00:				; Delay 4 000 cycles
						; 500us at 8.0 MHz	
	    ldi  r18, 6
	    ldi  r19, 49
	L0: dec  r19
	    brne L0
	    dec  r18
	    brne L0
	ret

DELAY_01:				; DELAY_CONTROL 40 000 cycles
						; 5ms at 8.0 MHz
	    ldi  r18, 52
	    ldi  r19, 242
	L1: dec  r19
	    brne L1
	    dec  r18
	    brne L1
	    nop
	ret

DELAY_02:				; Delay 160 000 cycles
						; 20ms at 8.0 MHz
	    ldi  r18, 208
	    ldi  r19, 202
	L2: dec  r19
	    brne L2
	    dec  r18
	    brne L2
	    nop
	ret

;====================================================================
; DATA
;====================================================================

message:
.db "NPM2206026473", 0
message2:
.db "NAMAFAHMI", 0
