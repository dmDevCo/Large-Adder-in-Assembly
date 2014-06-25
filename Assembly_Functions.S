/*
 * AssemblyFunctions.s
 */
 
.section	.data
numberLength:
	.long	00
formatSTR1:
	.ascii	"%s"
	.byte	00
message1:
	.ascii	"First Number Please: "
	.byte	00
message2:
	.ascii	"Second Number Please: "
	.byte	00
message3:
	.ascii	"The result is : "
	.byte	00
.text
.globl  _addLarge
_addLarge:

	pushl 	%ebp
	movl	%esp, %ebp

	// Get first Number
	lea		message1,%ebx
	pushl	%ebx
	call	_printf
	add		$4,%esp

	// The following function calls  fflush(stdout)
	call	_flushBuffer

	movl	8(%ebp),%ebx
	// The address of number1 is in %ebx
	pushl 	%ebx
	call 	_getNumber
	add		$4, %esp


	lea		message2,%ebx
	pushl	%ebx
	call	_printf
	add		$4,%esp
// The following function calls  fflush(stdout)
	call	_flushBuffer

	// Get second number
	movl	12(%ebp),%ebx
	// The address of number2 is in %ebx
	pushl 	%ebx
	call 	_getNumber
	add		$4, %esp

	// Add the numbers
	movl	8(%ebp),%ebx
	// The address of number1 is in %ebx
	pushl 	%ebx
	movl	12(%ebp),%ebx
	// The address of number2 is in %ebx
	pushl 	%ebx
	movl	16(%ebp),%ebx
	// The address of result is in %ebx
	pushl 	%ebx
	call	_addNumbers
	addl	$12,%esp

	//Print   the result

	lea		message3,%ebx
	pushl	%ebx
	call	_printf
	add		$4,%esp
// The following function calls  fflush(stdout)

	call	_flushBuffer

	lea		formatSTR1,%ebx
	pushl	%ebx
	movl	16(%ebp),%ebx
	pushl	%ebx
	call	_printf
	add		$8,%esp

	popl 	%ebp
	ret


.section .data
mess:
	.ascii "Try again please -- No spaces or nonnumeric characters allowed :"
	.byte 00
.text
	.align 4
.globl _getNumber
_getNumber:
	pushl 	%ebp
	movl	%esp, %ebp

askAgain:
	movl	8(%ebp),%ebx
	// The address of number is in %ebx
	pushl 	%ebx
	lea		formatSTR1,%ebx
	pushl	%ebx
	call 	_scanf
	add		$8,%esp

	movl	8(%ebp),%ebx
	xorl	%esi,%esi
nextChar:
	cmpb	$0,(%ebx,%esi,1)
	je		numberValid
	cmpb	$0x30,(%ebx,%esi,1)
	jl		errorMess
	cmpb	$0x39,(%ebx,%esi,1)
	jg		errorMess
	inc		%esi
	jmp		nextChar
errorMess:
	lea		mess,%ebx
	pushl	%ebx
	call	_printf
	add		$4,%esp
	call	_flushBuffer
	jmp		askAgain
numberValid:
	popl 	%ebp
	ret



_addNumbers:
// Add numbers is called with three arguments
// in the order number1, number2 and result

	pushl 	%ebp
	movl	%esp, %ebp

	movl	16(%ebp),%ebx
	xorl	%esi,%esi
cont1:
	cmp		$0,(%ebx,%esi,1)
	jz		length1
	inc		%esi
	jmp		cont1
length1:

	movl	12(%ebp),%ebx
	xorl	%edi,%edi
cont2:
	cmp		$0,(%ebx,%edi,1)
	jz		length2
	inc		%edi
	jmp		cont2
length2:

	// esi has the length of number1 and edi has the length of number2
	lea		numberLength,%ebx
	movl	%esi,(%ebx)
	cmpl	%esi,%edi
	jg 		CO2
	movl	%edi,(%ebx)
CO2:
	// numberLength has the lenght of the longer number


	movl	16(%ebp),%ebx
	// The address of number1 is in %ebx
	pushl 	%ebx
	call 	_rightAlign
	add		$4, %esp

	movl	12(%ebp),%ebx
	// The address of number1 is in %ebx
	pushl 	%ebx
	call 	_rightAlign
	add		$4, %esp


	movl	16(%ebp),%ebx
	// The address of number1 is in %ebx
	pushl 	%ebx
	call 	_ascii2BCD
	add		$4, %esp


	movl	12(%ebp),%ebx
	// The address of number1 is in %ebx
	pushl 	%ebx
	call 	_ascii2BCD
	add		$4, %esp


	movl	12(%ebp),%edi
	add		$numberLength,%edi
	// The address of number1 is in %ebx
	movl	16(%ebp),%esi
	add		$numberLength,%esi
	movl	18(%ebp),%ebx
	add		$numberLength,%ebx

	mov		$numberLength,%ecx

	clc

addnextbyte:
	movb	(,%esi,1),%al
	adcb	( ,%edi,1),%al
	movb	%al,(,%ebx,1)
	dec		%edi
	dec		%esi
	loop 	addnextbyte

	movl	8(%ebp),%ebx
	// The address of number1 is in %ebx
	pushl 	%ebx
	call 	_BCD2ascii
	add		$4, %esp


	pop		%ebp
	ret


.globl 	_ascii2BCD
_ascii2BCD:

	pushl 	%ebp
	movl	%esp, %ebp
	movl	8(%ebp),%ebx
	movl	$numberLength,%esi
	movl	%esi,%ecx

back1:
	and		$0x0F,(%ebx,%esi,1)
	dec		%esi
	loop 	back1

	pop		%ebp
	ret

.globl 	_BSC2ascii

_BCD2ascii:
	pushl 	%ebp
	movl	%esp, %ebp
	movl	8(%ebp),%ebx
	movl	$numberLength,%esi
	movl	%esi,%ecx

back3:
	or		$0x30,(%ebx,%esi,1)
	dec		%esi
	loop 	back3

	pop		%ebp
	ret


.globl 	_rightAlign
_rightAlign:
	pushl 	%ebp
	movl	%esp, %ebp
	movl	8(%ebp),%ebx
	lea		numberLength,%edi

	xor		%ecx,%ecx
	xor		%esi,%esi
back2:
	cmpb	$0,(%ebx,%esi,1)
	je		endof
	inc		%esi
	inc		%ecx
	jmp 	back2
endof:
	cmp	%esi,%edi
	je 		out1

doit:
	movb	(%ebx,%esi,1), %al
	movb	%al,(%ebx,%edi,1)
	dec		%esi
	dec		%edi
	loop  	doit

	mov		%edi,%ecx
zerofil:
	movb	$0,	(%ebx,%ecx,1)
	loop	zerofil

out1:
	pop		%ebp
	ret

.globl	_flushBuffer
_flushBuffer:

	// The following function calls  fflush(stdout)
	movl	$0x77c5fca0,%ebx
	pushl	%ebx
	call	_fflush
	addl		$4,%esp
	ret

.globl	_printCRLF
_printCRLF:


	ret


