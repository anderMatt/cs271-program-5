TITLE Program 5     (program5.asm)

; Author: Matthew Anderson
; CS 271 - Program 5                 Date: February 26, 2018
; Description:

INCLUDE Irvine32.inc

; (insert constant definitions here)
MIN_SAMPLE_SIZE = 10
MAX_SAMPLE_SIZE = 200
RANGE_MIN = 100
RANGE_MAX = 999

.data

; (insert variable definitions here)
progTitle		BYTE	"Random Number Generator", 0
myName			BYTE	"Written By: Matthew Anderson",0
instructions1	BYTE	"I will generate N random numbers in [100, 999], where",0
instructions2	BYTE	"N is a number of your choice in [10, 200]. Then, I will ",0
instructions3	BYTE	"display the generated numbers, their median, and sort them in",0
instructions4	BYTE	"descending order.",0

dataPrompt		BYTE	"Enter sample size in [10, 200]: ",0
dataErr			BYTE	"Value must be in in [10, 200]! Try again: ",0

unsorted		BYTE	"Unsorted Array: ",0
sorted			BYTE	"Sorted Array: ",0
gutter			BYTE	"  ",0

sampleSize		DWORD	?			;how many random numbers to generate. User-entered value.
sampleArr		DWORD	200 DUP(?)


.code
main PROC
	call	Randomize				;Seed random generator.
	call	Introduction
	push	OFFSET sampleSize		;Pass sample size to GetData.
	call	GetData
	push	OFFSET sampleArr		;Pass array and size to FillArray.
	push	sampleSize
	call	FillArray

	push	OFFSET sampleArr
	push	sampleSize
	push	OFFSET unsorted
	call	Display

	;------------------------------
	;TEST SWAPPING FIRST AND SECOND ARRAY ELEMENTS.
	;------------------------------
	;push	OFFSET sampleArr
	;mov		eax, OFFSET sampleArr
	;add		eax, 4
	;push	eax
	;call	Swap
	
	;push	OFFSET sampleArr
	;push	sampleSize
	;push	OFFSET sorted
	;call	Display
	;------------------------------
	;------------------------------


	exit	; exit to operating system
main ENDP

;--------------------------------------------------
Introduction PROC
;
; Prints a greeting message and
; instructions.
;
;--------------------------------------------------
	mov		edx, OFFSET progTitle
	call	WriteString
	call	CrLf
	mov		edx, OFFSET myName
	call	WriteString
	call	CrLf
	mov		edx, OFFSET instructions1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET instructions2
	call	WriteString
	call	CrLf
	mov		edx, OFFSET instructions3
	call	WriteString
	call	CrLf
	mov		edx, OFFSET instructions4
	call	WriteString
	call	CrLf
	ret

Introduction ENDP

;--------------------------------------------------
GetData PROC
;
; Prompts user to enter a number N in 
; [MIN_SAMPLE_SIZE, MAX_SAMPLE_SIZE]. If input is 
; outside of this range, prints error message and
; prompts again.
;
; Receives: Address of output variable on system stack.
; Returns: Output variable contains N.
;--------------------------------------------------
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp + 8]		;ESI contains address of output variable.

	; Prompt input.
	mov		edx, OFFSET dataPrompt
	call	WriteString

getNum:
	call	ReadInt
	call	IsValidSampleSize
	jz		isValid

	;Input was not valid. Print error, and try again.
	mov		edx, OFFSET dataErr
	call	CrLf
	call	WriteString
	jmp		getNum

isValid:
	call	CrLf
	mov		[esi], eax		;Place entered number in output variable.
	pop		ebp
	ret 4					;Remove output variable from stack.

GetData ENDP

;--------------------------------------------------
IsValidSampleSize PROC
;
; Validates user-entered sample size to be within
; [MIN_SAMPLE_SIZE, MAX_SAMPLE_SIZE].
;
; Receives: EAX = user-entered sample size.
; Returns: ZF = 1 if sample size is in the valid
; range; else ZF = 0.
;--------------------------------------------------
	cmp		eax, MIN_SAMPLE_SIZE
	jl		invalid 
	cmp		eax, MAX_SAMPLE_SIZE
	jg		invalid 
	test	eax, 0		;Input is valid. Unset ZF.

invalid:
	ret

IsValidSampleSize ENDP

;--------------------------------------------------
FillArray PROC
;
; Fills an array with N random numbers, each in
; the range [100, 999].
;
; Receives stack parameters (A, N):
;	A: address of the array to fill.
;   N: random number sample size.
;
; Returns: A[0...N-1] contains random numbers.
;--------------------------------------------------
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp + 12]		;Load address of output array.
	mov		ecx, [ebp + 8]		;Load sample size.

putNext:						;Loads next element with a random number.

	;Load EAX with range for RandomRange call: HI - LO + 1
	mov		eax, RANGE_MAX 
	mov		ebx, RANGE_MIN
	sub		eax, ebx
	inc		eax

	call	RandomRange
	add		eax, RANGE_MIN		;Get generated number into [MIN, MAX]

	;Place random number into next element.
	mov		[edi], eax
	add		edi, TYPE DWORD	;Increment to next element.
	loop	putNext

	pop		ebp
	ret 8

FillArray ENDP

;--------------------------------------------------
Display PROC
;
; Prints the contents of an array, 10 elements per
; line.
;
; Receives stack parameters (A, N, T):
;	A: address of the array.
;   N: size of the array.
;   T: title of the array.
;--------------------------------------------------
	push	ebp
	mov		ebp, esp

	;Print array title.
	mov		edx, [ebp + 8]					;Load title for printing.
	;mov	edx, OFFSET unsorted
	call	WriteString
	call	CrLf

	;Loop through the array, printing each element.
	mov		ecx, [ebp + 12]					;Load size of array.
	mov		esi, [ebp + 16]					;Load the array.
	mov		edi, 0							;Keep track of numbers printed so far on current line.

	call	CrLf

printNext:
	;Print space between numbers.
	mov		edx, OFFSET gutter
	call	WriteString

	inc		edi
	mov		eax, [esi]
	call	WriteDec
	add		esi, TYPE DWORD				;Advance to next element.

	;Check if we need to print a new line - 10 numbers per line.
	xor		edx, edx
	mov		ebx, 10
	mov		eax, edi
	div		ebx
	cmp		edx, 0
	jne		doLoop						;Less than 10 numbers printed on current line.

	call	CrLf						;Divisible by 10. Add a new line.
	mov		edi, 0						;Reset print count for current line.

doLoop:
	loop	printNext

	pop		ebp
	ret 12

Display ENDP


;--------------------------------------------------
Swap PROC
;
; Swaps the values of two memory addresses. Assumes
; DWORD type.
;
; Receives stack parameters (A, B):
;	A: address of first variable
;	B: address of second variable
;	
;	Returns: [A] = [B], [B] = [A]
;--------------------------------------------------
	push	ebp
	mov		ebp, esp
	mov		eax, [ebp + 12]			;eax contains address of first variable. Add 40 because of pushad.
	mov		ebx, [eax]				;ebx contains VALUE of first variable.

	mov		ecx, [ebp + 8]			;ecx contains address of second variable.
	mov		edx, [ecx]				;edx contains VALUE of second variable.

	mov		[eax], edx
	mov		[ecx], ebx

	pop		ebp
	ret 8							;remove two memory addresses from stack.
Swap ENDP
END main
