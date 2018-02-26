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

sampleSize		DWORD	?			;how many random numbers to generate. User-entered value.
sampleArr		DWORD	200 DUP(?)


.code
main PROC
	call	Introduction
	push	OFFSET sampleSize		;Pass sample size to GetData
	call	GetData


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

; (insert additional procedures here)

END main
