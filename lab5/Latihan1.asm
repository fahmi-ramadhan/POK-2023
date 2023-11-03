.include "m8515def.inc"		// include header for ATmega8515
.def result = r2			// rename register r2 to result
							// final value after run: 0x07
main:
	ldi ZH, HIGH(2*DATA)	// load the high byte value from 2*DATA to ZH register
	ldi ZL, LOW(2*DATA)		// load the low byte value from 2*DATA to ZL register
loop:
	lpm						// load program memory (loads the byte data of Z register pair to r0
	tst r0					// tests register r0 for zero
	breq stop				// if r0 is zero, jump to the stop label
	mov r16, r0				// copy the content of r0 to r16
funct1:
	cpi r16, 3				// compares the value in r16 with immedeate value 3
	brlt funct2				// if (r16 < 3), jump to funct2
	subi r16, 3				// subtracts 3 from the value in r16 (decrement r16 by 3)
	rjmp funct1				// jumps to funct1
funct2:
	add r1, r16				// adds the value of r1 with the value of r16 (r1=r1+r16)
	adiw ZL, 1				// adds 1 to ZL register to access the next byte
	rjmp loop				// jumps to loop
stop:
	mov result, R1			// copy the content of r1 to the result variable
forever:
	rjmp forever			// jumps to forever
DATA:
.db 2, 11, 7, 8				
.db 0, 0
