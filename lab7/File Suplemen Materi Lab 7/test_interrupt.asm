;====================================================================
; Processor		: ATmega8515
; Compiler		: AVRASM
;====================================================================

;====================================================================
; DEFINITIONS
;====================================================================

.include "m8515def.inc"
.def temp = r16 ; temporary register
.def led_data = r17

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

INIT_LED:

	ser temp ; load $FF to temp
	out DDRC,temp ; Set PORTA to output

INIT_INTERRUPT:
	ldi temp,0b00000010
	out MCUCR,temp
	ldi temp,0b01000000
	out GICR,temp
	sei

LED_LOOP:
	;ldi led_data,0x00
	;out PORTC,led_data ; Update LEDS
	;rcall DELAY_01
	ldi led_data,0x01
	out PORTC,led_data ; Update LEDS
	rcall DELAY_01
	ldi led_data,0x02
	out PORTC,led_data ; Update LEDS
	rcall DELAY_01
	ldi led_data,0x04
	out PORTC,led_data ; Update LEDS
	rcall DELAY_01
	ldi led_data,0x08
	out PORTC,led_data ; Update LEDS
	rcall DELAY_01
	ldi led_data,0x10
	out PORTC,led_data ; Update LEDS
	rcall DELAY_01
	ldi led_data,0x20
	out PORTC,led_data ; Update LEDS
	rcall DELAY_01
	ldi led_data,0x40
	out PORTC,led_data ; Update LEDS
	rcall DELAY_01
	ldi led_data,0x80
	out PORTC,led_data ; Update LEDS
	rcall DELAY_01
	rjmp LED_LOOP

ext_int0:
	sbis	PIND, 4			; use Button 2 to continue
	rjmp	ext_int0
	reti

DELAY_00:
	; Generated by delay loop calculator
	; at http://www.bretmulvey.com/avrdelay.html
	;
	; Delay 4 000 cycles
	; 500us at 8.0 MHz

	    ldi  r18, 6
	    ldi  r19, 49
	L0: dec  r19
	    brne L0
	    dec  r18
	    brne L0
	ret


DELAY_01:
	; Generated by delay loop calculator
	; at http://www.bretmulvey.com/avrdelay.html
	;
	; DELAY_CONTROL 40 000 cycles
	; 5ms at 8.0 MHz

	    ldi  r18, 52
	    ldi  r19, 242
	L1: dec  r19
	    brne L1
	    dec  r18
	    brne L1
	    nop
	ret

DELAY_02:
; Generated by delay loop calculator
; at http://www.bretmulvey.com/avrdelay.html
;
; Delay 160 000 cycles
; 20ms at 8.0 MHz

	    ldi  r18, 208
	    ldi  r19, 202
	L2: dec  r19
	    brne L2
	    dec  r18
	    brne L2
	    nop
		ret
