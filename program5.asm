TITLE Program 5     (program5.asm)

; Author: Matthew Anderson			 anderma8@oregonstate.edu
; CS 271 - Program 5                 Date: March 1, 2018
;
; Description: Generates a sample of N random numbers in [100, 999], where N
; is a user-entered value in [10, 200]. Populates an array with these numbers,
; and sorts the array into descending order. Prints contents of both the sorted
; and unsorted arrays. Finally, computes and displays the median value of the
; sorted array.

INCLUDE Irvine32.inc

MIN_SAMPLE_SIZE = 10
MAX_SAMPLE_SIZE = 200
RANGE_MIN = 100
RANGE_MAX = 999

.data

progTitle		BYTE	"Random Number Generator", 0
myName			BYTE	"Written By: Matthew Anderson",0
instructions1	BYTE	"I will generate N random numbers in [100, 999], where",0
instructions2	BYTE	"N is a number of your choice in [10, 200]. Then, I will ",0
instructions3	BYTE	"display the generated numbers, sort them in",0
instructions4	BYTE	"descending order, and compute the median value.",0

dataPrompt		BYTE	"Enter sample size in [10, 200]: ",0
dataErr			BYTE	"Value must be in in [10, 200]! Try again: ",0

unsorted		BYTE	"Unsorted Array: ",0
sorted			BYTE	"Sorted Array (descending): ",0
gutter			BYTE	"  ",0
medianStr		BYTE	"The median is: ",0

sampleSize		DWORD	?			;how many random numbers to generate. User-entered value.
sampleArr		DWORD	200 DUP(?)
theMedian		DWORD ?


.code
main PROC
	call	Randomize				;Seed random generator.
	call	Introduction
	push	OFFSET sampleSize	
	call	GetData					;sampleSize = value entered by user.

	push	OFFSET sampleArr		
	push	sampleSize
	call	FillArray				;sampleArr = array of random numbers.

	;Print unsorted array.
	push	OFFSET sampleArr
	push	sampleSize
	push	OFFSET unsorted
	call	Display

	;Sort the array.
	push	OFFSET sampleArr
	push	sampleSize
	call	SortArray

	;Print the sorted array.
	push	OFFSET sampleArr
	push	sampleSize
	push	OFFSET sorted
	call	Display

	;Calculate the median.
	push	OFFSET sampleArr
	push	sampleSize
	push	OFFSET theMedian
	call	GetMedian

	;Report the median
	push	theMedian
	push	OFFSET medianStr
	call	PrintMedian

	exit	; exit to operating system
main ENDP

;--------------------------------------------------
Introduction PROC
;
; Prints a greeting message and program
; instructions.
;
;--------------------------------------------------
	mov		edx, OFFSET progTitle
	call	WriteString
	call	CrLf
	mov		edx, OFFSET myName
	call	WriteString
	call	CrLf
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
	test	eax, 0				;Input is valid. Unset ZF.

invalid:						;ZF = 1 since JL or JG caused a jump.
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
	call	CrLf
	call	CrLf

	pop		ebp
	ret 12

Display ENDP

;--------------------------------------------------
SortArray PROC
; Sorts an array into descending order. Assumes
; type DWORD. Implemented using selection sort.
;
; Receives stack parameters (A, N):
;	A: address of the array to sort.
;	N: size of the array.
;
;--------------------------------------------------
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp + 12]			;ESI contains address of the array.
	mov		ecx, [ebp + 8]			;ECX contains size of the array.

	;Load last address into EAX. This will be used for comparisons when iterating.
	;Last address = @ + (N-1 * 4)
	mov		eax, ecx
	mov		ebx, 4
	mul		ebx						
	add		eax, esi			;EAX contains address of last element of the array.

outer:
	;Check if we're done: i >= (size of array) - 1
	mov		ebx, eax				;EAX is address of the last element of the array.
	sub		ebx, 4					;Last element - 1
	cmp		esi, ebx				;ESI = i
	jge		sortDone

	mov		ebx, esi				;EBX will hold current max index. Starts as i.
	mov		edi, esi				
	add		edi, 4					;EDIT = j for the inner loop: j = i + 1

inner:
	cmp		edi, eax				;Check if j is at the last element of the array.
	jge		doneInner				;Done inner loop when j = @ arr[N-1]

	mov		ecx, [ebx]				;ECX = value at current max index
	cmp		ecx, [edi]				;EDI = @j.

	jge		innerAgain
	mov		ebx, edi				;arr[maxIndex] < arr[j]. Update max index = j.

innerAgain:
	add		edi, 4					;Advance j = j + 1.
	jmp		inner
	

doneInner:
	;Swap elements at arr[i], and arr[maxIndex].
	push	esi
	push	ebx						;EBX holds max index.
	call	Swap
	add		esi, 4					;Advance i = i+1
	jmp		outer

sortDone:
	pop		ebp

	ret 8

SortArray ENDP

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
	push	eax
	push	ebx
	push	ebp

	mov		ebp, esp
	mov		eax, [ebp + 20]			;eax contains address of first variable. Add 40 because of pushad.
	mov		ebx, [eax]				;ebx contains VALUE of first variable.

	mov		ecx, [ebp + 16]			;ecx contains address of second variable.
	mov		edx, [ecx]				;edx contains VALUE of second variable.

	mov		[eax], edx
	mov		[ecx], ebx

	pop		ebp
	pop		ebx
	pop		eax

	ret 8							;remove two memory addresses from stack.

Swap ENDP


;--------------------------------------------------
GetMedian PROC
;
; Finds the median value of an array.
; 
;
; Preconditions: The array is sorted.
; Receives stack parameters (A, N, O):
;	A: address of the array.
;	N: size of the array.
;	O: address of the output variable.
;
;--------------------------------------------------

;If array is odd length, median is arr[(N-1)/2.
;If array is even length, median is 
; arr[(N/2)-1] + arr[N/2]

	push	ebp
	mov		ebp, esp

	mov		esi, [ebp + 16]			;ESI = @ of array.
	mov		ecx, [ebp + 12]			;ECX = N.
	mov		edi, [ebp + 8]			;EDI = output variable.

	;Check if array is even or odd length.
	xor		edx, edx
	mov		eax, ecx
	mov		ebx, 2
	div		ebx
	cmp		edx, 0
	je		lenEven

	;Array is odd length. Median index is (N-1)/2
	mov		eax, ecx				;EAX = N
	dec		eax						;EAX = N - 1
	xor		edx, edx
	mov		ebx, 2
	div		ebx						;EAX = (N-1)/2
	mov		ebx, 4
	mul		ebx						;EAX = (N-1)/2 * 4, the memory offset of median.

	mov		ebx, esi				;EBX = @ array.
	add		ebx, eax				;EBX = @ of median element.
	mov		eax, [ebx]				;EAX = value of median element.
	mov		[edi], eax

	jmp		return

lenEven:
	;Get first middle number: N/2 - 1
	mov		eax, ecx				;EAX = N
	mov		ebx, 2					
	xor		edx, edx
	div		ebx						;EAX = (N/2)

	dec		eax						;EAX = (N/2) - 1, index of first middle number.
	mov		ebx, 4
	mul		ebx						;EAX = ((N/2)-1) * 4, mem. offset of middle element.

	mov		ebx, esi				;EBX = @ array.
	add		ebx, eax				;EBX = @ + offset = mem. address of middle element.
	mov		eax, [ebx]
	push	eax						;Save first middle number.

	;Get second middle number: N/2
	mov		eax, ecx				;EAX = N
	mov		ebx, 2
	xor		edx, edx
	mul		ebx						;EAX = (N/2)*4 = N * 2

	mov		ebx, esi				;EBX = @ of array.
	add		ebx, eax				;EBX = @ + offset = mem. address of middle element.
	mov		eax, [ebx]				;EAX = value of middle element.

	;Median is the average of the two middle numbers.
	pop		ebx						;Get first middle number.
	add		eax, ebx
	mov		ebx, 2
	xor		edx, edx
	div		ebx						;EAX = median value.

	mov		[edi], eax

return:
	pop		ebp
	ret		12

GetMedian ENDP

;--------------------------------------------------
PrintMedian PROC
;
;Reports the median of the array.
;
; Receives stack parameters: (N, S)
;	N: median value.
;	S: address of string message to print.
;--------------------------------------------------
	push	ebp
	mov		ebp, esp

	mov		eax, [ebp + 12]		;EAX = N.
	mov		edx, [ebp + 8]		;EDX = @ of string.

	call	WriteString
	call	WriteDec
	call	CrLf
	call	CrLf

	pop		ebp
	ret		8

PrintMedian ENDP

END main