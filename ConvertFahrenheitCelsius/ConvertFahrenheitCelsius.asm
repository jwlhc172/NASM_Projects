; ConvertFahrenheitCelsius.asm

; Constants used in program
sys_exit				equ		1
sys_read				equ		3
sys_write				equ		4
stdin				equ		0
stdout				equ		1
stderr				equ		3

decimal_places			equ		2
decimal				equ		'.'

section	.data		; Section for declaration of constants
	sString1			db		'Conversion of a temperature in Fahrenheit to Celsius'
	iString1Len		equ		$-sString1
	sString2			db		'Please enter a temperature in Fahrenheit: '
	iString2Len		equ		$-sString2
	sString3			db		'The Fahrenheit temperature entered in Celsius is: '
	iString3Len		equ		$-sString3
	
	sNewLine			db		10
	
	iTestInt			dd		25
	iTestInt2			dd		3456
	iTestInt3			dd		0

section	.bss			; Section for declaring reserved space for variables
	fGradFahrenheit	resq		1
	
	bTrueFalse		resb		1				; Generic variable for boolean use
	
	sInputBuffer		resb		255				; Buffer for text input
	iInputBufferLen	resb		1				; Length of buffer, 1 Byte because buffer max size is 255
	
	sNumberBuffer		resb		255				; Buffer for conversion of numbers to strings
	iNumberBufferLen	resb		1				; Length of buffer, 1 Byte because buffer max size is 255
	
	cClearBuffer		resb		1				; Byte to use to clear input buffer in case input exceeds 255 bytes

section	.text
	global	_start

_start:
	mov		ecx, sString1						; ecx = sString1 // ecx register = address of string to print
	mov		edx, iString1Len					; edx = iString1Len
	call		PrintStringLine						; print (ecx, edx); print ('\n', 1)
	call		PrintNewLine						; print ('\n', 1)
	
	mov		ecx, sString2						; ecx = sString2
	mov		edx, iString2Len					; edx = iString2Len
	call		PrintString						; print (ecx, edx)
	
	mov		ecx, sInputBuffer					; ecx = sInputBuffer
	mov		edx, 255							; edx = 255
	call		ReadFloat							; read (ecx, edx)
	
	call		PrintNewLine						; print ('\n', 1)
	
	mov		ecx, sString3
	mov		edx, iString3Len
	call		PrintString
	
	mov		eax, 32
	push	eax
	fisub	DWORD [esp]
	pop		eax
	mov		eax, 5
	push	eax
	fimul	DWORD [esp]
	pop		eax
	mov		eax, 9
	push	eax
	fidiv		DWORD [esp]
	pop		eax
	
	call		ConvertFloatToString
	mov		ecx, sNumberBuffer
	mov		edx, [iNumberBufferLen]
	call		PrintStringLine

	jmp		Exit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function Name: 
; Last Modified: April 6, 2014
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functional Description: 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters:
;
; Return:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Example Calling Sequence:
; 	call		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Register Usage in Function:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Algorithmic Description in Pseudocode:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ConvertIntegerToString:
	push	ebx
	push	ecx
	push	edx
	xor		ecx, ecx
ConvertIntegerToString_1:
	xor		edx, edx
	mov		ebx, 10
	div		ebx								; Quotient in eax, Remainder in edx
	dec		esp
	add		edx, 30h
	mov		BYTE [esp], dl
	inc		ecx
	test		eax, eax
	jnz		ConvertIntegerToString_1
	mov		BYTE [iNumberBufferLen], cl
ConvertIntegerToString_2:
	xor		eax, eax
	xor		ebx, ebx
	mov		al, BYTE [iNumberBufferLen]
	sub		eax, ecx
	mov		bl, BYTE [esp]
	mov		BYTE [sNumberBuffer+eax], bl
	inc		esp
	dec		ecx
	cmp		ecx, 0
	ja		ConvertIntegerToString_2
	pop		edx
	pop		ecx
	pop		ebx
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function Name: 
; Last Modified: April 6, 2014
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functional Description: 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters:
;
; Return:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Example Calling Sequence:
; 	call		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Register Usage in Function:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Algorithmic Description in Pseudocode:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ConvertFloatToString:
	push	ebx
	push	ecx
	push	edx
	xor		ecx, ecx
	mov		eax, 10
	mov		ebx, decimal_places
	call		CalculatePower
	push	eax
	fimul	DWORD [esp]
	pop		eax
	sub		esp, 4
	fistp		DWORD [esp]
	mov		eax, [esp]
	add		esp, 4
ConvertFloatToString_1:
	xor		edx, edx
	mov		ebx, 10
	div		ebx								; Quotient in eax, Remainder in edx
	dec		esp
	add		edx, 30h
	mov		BYTE [esp], dl
	inc		ecx
	cmp		ecx, decimal_places
	je		ConvertFloatToString_4				; add decimal character to stack
ConvertFloatToString_2:
	test		eax, eax
	jnz		ConvertFloatToString_1
	mov		BYTE [iNumberBufferLen], cl
ConvertFloatToString_3:
	xor		eax, eax
	xor		ebx, ebx
	mov		al, BYTE [iNumberBufferLen]
	sub		eax, ecx
	mov		bl, BYTE [esp]
	mov		BYTE [sNumberBuffer+eax], bl
	inc		esp
	dec		ecx
	cmp		ecx, 0
	ja		ConvertFloatToString_3
	pop		edx
	pop		ecx
	pop		ebx
	ret
ConvertFloatToString_4:
	dec		esp
	inc		ecx
	mov		BYTE [esp], decimal
	jmp		ConvertFloatToString_2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function Name: CalculatePower ( iBase, iPower )
; Last Modified: April 6, 2014
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functional Description: Calculate iBase raised to the power iPower.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters:
;	eax		Base integer
;	ebx		Power
;
; Return:
;	eax
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Example Calling Sequence:
; 	mov		eax, 10
;	mov		ebx, 2
;	call		CalculatePower		(10 ^ 2)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Register Usage in Function:
;	eax			Base number and result
;	ebx			Power to raise to
;	ecx			Saving original value of eax, so eax can store result
;	edx			Must be zeroed for MUL instruction ( edx:eax )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Algorithmic Description in Pseudocode:
;	if ( ebx == 0 )
;		eax = 1
;		return
;
;	if ( ebx == 1 )
;		return
;
;	ecx = eax
;	ebx = ebx - 1
;	do
;		eax = eax * ecx
;		ebx = ebx - 1
;	while ( ebx > 0 )
;
;	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CalculatePower:
	test		ebx, ebx
	jz		CalculatePower_3
	cmp		ebx, 1
	je		CalculatePower_2
	push	ecx
	push	edx
	mov		ecx, eax
	dec		ebx
	xor		edx, edx
CalculatePower_1:
	mul		ecx
	dec		ebx
	test		ebx, ebx
	jnz		CalculatePower_1
	pop		edx
	pop		ecx
CalculatePower_2:
	ret
CalculatePower_3:
	mov		eax, 1
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function Name: 
; Last Modified: April 6, 2014
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functional Description: 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters:
;
; Return:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Example Calling Sequence:
; 	call		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Register Usage in Function:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Algorithmic Description in Pseudocode:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintString:
	mov		eax, sys_write
	mov		ebx, stdout
	int		80h
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function Name: 
; Last Modified: April 6, 2014
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functional Description: 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters:
;
; Return:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Example Calling Sequence:
; 	call		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Register Usage in Function:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Algorithmic Description in Pseudocode:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintNewLine:
	mov		ecx, sNewLine
	mov		edx, 1
	mov		eax, sys_write
	mov		ebx, stdout
	int		80h
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function Name: 
; Last Modified: April 6, 2014
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functional Description: 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters:
;
; Return:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Example Calling Sequence:
; 	call		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Register Usage in Function:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Algorithmic Description in Pseudocode:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintStringLine:
	mov		eax, sys_write
	mov		ebx, stdout
	int		80h
	call		PrintNewLine
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function Name: int ReadString ( string* sInput, int iLength )
; Last Modified: April 6, 2014
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functional Description: Reads a string up to iLength bytes in length from 
; STDIN to memory pointed to by sInput. Returns the number of bytes read.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters:
;	ecx		string* sInput
;	edx		int iLength
;
; Return:
;	eax		number of bytes read
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Example Calling Sequence:
;	mov		ecx, sInput
;	mov		edx, [iLength]
; 	call		ReadString
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Register Usage in Function:
;	edx		maximum number of bytes to save in buffer
;	eax		number of bytes actually read
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Algorithmic Description in Pseudocode:
;	eax = read ( sInput, iLength )
;	if ( eax < iLength )
;		return
;
;	if ( sInput[iLength - 1] == 0x0A )
;		return
;	else
;		sInput[iLength - 1] = 0x0A
;		ClearTerminal ()
;
;	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ReadString:
	mov		eax, sys_read
	mov		ebx, stdin
	int		80h
	dec		eax								; discard EOL (\n) in the entered string
	push	eax								; save number of bytes read, minus 1 to truncate EOL character temporarily to stack
	inc		eax
	cmp		eax, edx
	jl		ReadString_1
	cmp		BYTE [ecx + edx - 1], 10
	je		ReadString_1
	mov		BYTE [ecx + edx - 1], 10
	call		ClearTerminal
ReadString_1:
	pop		eax								; restore eax to number of bytes read
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function Name: ClearTerminal ()
; Last Modified: April 6, 2014
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functional Description: Clears input buffer for STDIN in case more characters
; were entered than the buffer had room for. Continues to read from input 
; buffer until the EOL (end of line) character, 0x0A hex or 10 dec, 
; is encountered.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters: None
;
; Return: None
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Example Calling Sequence:
; 	call		ClearTerminal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Register Usage in Function:
;	ecx		cClearBuffer
;	edx		1 [number of characters to read]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Algorithmic Description in Pseudocode:
;	edx = 1
;
;	do
;		read ( &cClearBuffer, 1 )
;	while ( cClearBuffer != 0x0A )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ClearTerminal:
	mov		edx, 1
	mov		ecx, cClearBuffer
	mov		ebx, stdin
	mov		eax, sys_read
	int		80h
	cmp		BYTE [ecx + edx - 1], 10
	jne		ClearTerminal
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function Name: ReadFloat()
; Last Modified: April 7, 2014
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functional Description: Read floating point number entered in the terminal 
; and convert this number from ASCII to floating point format, storing the 
; final result on the top of the floating point stack. (st0)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; No Parameters
;
; Return:
; 	st0		Float representation of string entered; top of float stack
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Example Calling Sequence:
; 	call		ReadFloat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Register Usage in Function:
;	eax			iNumber
;	ebx			[misc uses]
;	ecx
;		ch		iCount
;		cl		iCount2
;	edx			iDecimalPlaces
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Algorithmic Description in Pseudocode:
;	string	sInputBuffer (pointer to string with number in ASCII)
;	int		iInputBufferLen (length of string in ASCII bytes)
;	int		iCount = 0
;	int		iCount2 = 0
;	int		iDecimalPlaces = 0
;	int		iNumber = 0
;	bool		bTrueFalse = false
;
;	float		fNumber = {st0}
;
;	iInputBufferLen = ReadString (sInputBuffer, 255)
;
;	for ( iCount = 0; iCount < iInputBufferLen; iCount++ )
;		if ( sInputBuffer[iCount] == '.' )
;			bTrueFalse = true
;		else
;			iNumber = iNumber * 10
;			iNumber = iNumber + (sInputBuffer[iCount] - 0x30)
;			iCount2++
;			if ( bTrueFalse )
;				iDecimalPlaces++
;	fNumber = iNumber
;	fNumber = fNumber / CalculatePower(10, iDecimalPlaces)
;
;	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ReadFloat:
	push	eax
	push	ebx
	push	ecx
	push	edx
	mov		ecx, sInputBuffer
	mov		edx, 255
	call		ReadString						; read ( sInputBuffer, 255 ) - read up to 255 characters from STDIN
	mov		BYTE [iInputBufferLen], al			; iInputBufferLen = eax (result of read function; number of bytes read)
	xor		eax, eax							; eax = 0
	xor		ecx, ecx							; ecx = 0
	xor		edx, edx							; edx = 0
	mov		BYTE [bTrueFalse], 0					; bTrueFalse = false
ReadFloat_1:
	cmp		BYTE [iInputBufferLen], ch			; [iInputBufferLen] - ch
	jle		ReadFloat_2
	xor		ebx, ebx
	mov		bl, ch
	cmp		BYTE [sInputBuffer+ebx], decimal		; sInputBuffer[iCount] == '.'
	je		ReadFloat_3
	mov		ebx, 10							; ebx = 10
	push	edx								; save edx temporarily due to MUL operation
	xor		edx, edx							; edx = 0
	mul		ebx								; iNumber = iNumber * ebx (10)
	pop		edx								; restore edx
	xor		ebx, ebx
	mov		bl, ch
	mov		bl, BYTE [sInputBuffer+ebx]			; ebx = sInputBuffer[iCount]
	sub		ebx, 30h							; ebx = ebx - 0x30 (conversion from ASCII to integer
	add		eax, ebx							; iNumber = iNumber + ebx
	inc		cl								; iCount2++
	cmp		BYTE [bTrueFalse], 1
	je		ReadFloat_4
	inc		ch								; iCount++
	jmp		ReadFloat_1
ReadFloat_2:
	push	eax								; push eax (iNumber) onto stack for transfer to floating point stack
	fild		DWORD [esp]						; fNumber = iNumber
	pop		eax								; necessary to keep stack aligned
	mov		eax, 10							; eax = 10
	mov		ebx, edx							; ebx = iDecimalPlaces
	call		CalculatePower						; eax = CalculatePower ( 10, iDecimalPlaces )
	push	eax								; push eax, power, to fp stack
	fidiv		DWORD [esp]						; fNumber = fNumber / ( 10 ^ iDecimalPlaces )
	pop		eax
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	ret
ReadFloat_3:
	mov		BYTE [bTrueFalse], 1					; bTrueFalse = 1
	inc		ch								; iCount++
	jmp		ReadFloat_1
ReadFloat_4:
	inc		edx								; iDecimalPlaces++
	inc		ch								; iCount++
	jmp		ReadFloat_1

Exit:
	mov		eax, sys_exit
	xor		ebx, ebx							; ebx = 0
	int		80h
