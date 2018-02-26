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
progTitle	BYTE	"Random Number Generator", 0
myName		BYTE	"Written By: Matthew Anderson",0
instructions1	BYTE	"I will generate N random numbers in [100, 999], where",0
instructions2	BYTE	"N is a number of your choice in [10, 200]. Then, I will ",0
instructions3	BYTE	"display the generated numbers, their median, and sort them in",0
instructions4	BYTE	"descending order",0

.code
main PROC
	call	Introduction


	exit	; exit to operating system
main ENDP

;------------------------------
Introduction PROC
;
; Prints a greeting message and
; instructions.
;
;------------------------------
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

; (insert additional procedures here)

END main
