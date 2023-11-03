.include "m8515def.inc"		// include header for ATmega8515

.def rone = r1				// base case ketika n = 1
.def rtwo = r2				// base case ketika n = 2
.def input = r16			// rename register r16 jadi input
.def rslt = r17				// rename register r17 jadi rslt
.def num1 = r4				// rename register r4 jadi num1
.def num2 = r18				// rename register r18 jadi num2
.def temp = r19				// rename register r19 jadi temp

main:
	// Set stack pointer ke lokasi terakhir pada RAM internal
	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp

	ldi temp,1				// load 1 ke temp
	mov rone, temp			// move temp ke rone 
	
	ldi input, 5			// input n untuk P(n)
	rcall peokraSequence	// Call label peokraSequence dan store address instruksi selanjutnya ke stack
	sts $60, rslt			// Simpan data ke data memory $60

forever:
	rjmp forever

peokraSequence:
 	push input				// Push input ke stack
	push num1				// Push num1 ke stack
	push num2				// Push num2 ke stack
	push temp				// Push temp ke stack

	cpi input, 1			// Compare input dengan 1
	breq one				// jika input == 1, jump ke label one
	cpi input, 2			// Compare input dengan 2
	breq two				// jika input == 2, jump ke label two

	mov num1, input			// move input ke num1
	dec num1				// decrement num1 untuk dijadikan input di P(n-1)
	mov num2, input			// move input ke num2
	subi num2, 2			// num2 -= 2 untuk dijadikan input di P(n-2)
	
	// P(n-1)
	mov input, num1			// move num1 to input
	rcall peokraSequence	// Call label peokraSequence dan store address instruksi selanjutnya ke stack
	mov temp, rslt			// move rslt in P(n-1) to temp
	inc temp				// increment temp untuk mendapatkan nilai P(n-1)+1
	
	// P(n-2)
	mov input, num2			// move num2 to input
	rcall peokraSequence	// Call label peokraSequence dan store address instruksi selanjutnya ke stack
	add rslt, rslt			// multiply rslt untuk mendapatkan nilai P(n-1)*2
	add rslt, temp			// add temp to rslt
	rjmp done				// jump ke label done

one:
	ldi rslt, 1				// kasus ketika P(1)
	rjmp done				

two:
	ldi rslt, 2				// kasus ketika P(2)

done:
	// pop stack untuk mengambil value selanjutnya dan kembali ke instruksi sebelumnya di stack
	pop temp
	pop num2
	pop num1
	pop input
	ret	
	
