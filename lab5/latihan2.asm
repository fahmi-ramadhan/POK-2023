.include "m8515def.inc"		// include header for ATmega8515

DATA:
.db 12, 4
.db 0, 0

.def temp = r16				// define a temporary register for intermediate calculations
.def num1 = r2				// renaming register r1 to num1
.def num2 = r3				// renaming register r2 to num2
.def counter = r5			// define a resister to hold the counter
.def multResult = r20		// define a register to hold the multiplication result
.def result = r8			// define a register to hold the result (LCM value)

main:
	ldi ZH, HIGH(2*DATA)	// load the high byte value from 2*DATA to ZH register
	ldi ZL, LOW(2*DATA)		// load the low byte value from 2*DATA to ZL register
	lpm num1, Z+			// Load lower byte of DATA into num1 (r2)
	lpm num2, Z				// Load upper byte of DATA into num2 (r3)
	mul num1, num2			// Multiply value of num1 and num2 and store the result in R1:R0
	movw multResult, r0		// Move the 16-bit result from R1:R0 to R20:R21
		
checkEqual:		
	cp num1, num2			// compare num1 (r2) to num2 (r3)
	brne checkWhatsBigger	// branch to checkWhatsBigger if num1 != num2
	rjmp lcm				// jump to stop if num1 == num2	

checkWhatsBigger:			// Check the bigger number between the two
	brlt sub1				// branch to gcd1 if num1 < num2
	rjmp sub2				// jump to gcd2 if num2 < num1

sub1:						// branch to calculate gcd if num1 < num2
	sub num2, num1			// substract num1 from num2 (num2 = num2 - num1)
	rjmp checkEqual			// jump to checkEqual

sub2:						// branch to calculate gcd if num2 < num1
	sub num1, num2			// substract num2 from num1 (num1 = num1 - num2)
	rjmp checkEqual			// jump to checkEqual

lcm:
	cp multResult, num2		// compare multResult (r20) to num2/gcd result (r3)
	brlt stop				// jumps to stop if multResult < num2
	sub multResult, num2	// multResult = multResult - num2
	inc counter				// increment counter
	rjmp lcm				// jumps to lcm

stop:
	mov result, counter		// copy the content of num1 to the result variable
	rjmp forever			// jumps to forever

forever:				
	rjmp forever			// jumps to forever
