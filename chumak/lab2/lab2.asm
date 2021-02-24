TESTPC SEGMENT
	ASSUME CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
	ORG 100H

START: JMP BEGIN

MEMORY_ADDRESS db 'Memory address:     h', 0dh, 0ah, '$'
ENVIRONMENT_ADDRESS db 'Environment address:     h', 0dh, 0ah, '$'
TAIL db 'Tail:              ', 0dh, 0ah, '$'
EMPTY_TAIL db 'Empty tail', 0dh, 0ah, '$'
ENVIRONMENT_CONTENT db 'Content of the environment: ', 0dh, 0ah,  '$'
END_STRING db 0dh, 0ah, '$'
PATH db 'Path:  ', 0dh, 0ah, '$'

TETR_TO_HEX PROC near
	and al, 0Fh
	cmp al, 09
	jbe next
	add al, 07
next:
	add al, 30h
	ret
TETR_TO_HEX ENDP

BYTE_TO_HEX PROC near
	push cx
	mov ah, al
	call TETR_TO_HEX
	xchg al, ah
	mov cl, 4
	shr al, cl
	call TETR_TO_HEX
	pop cx
	ret
BYTE_TO_HEX ENDP

WRD_TO_HEX PROC near
	push bx
	mov bh, ah
	call BYTE_TO_HEX
	mov [di], ah
	dec di
	mov [di], al
	dec di
	mov al, bh
	call BYTE_TO_HEX
	mov [di], ah
	dec di
	mov [di], al
	pop bx
	ret
WRD_TO_HEX ENDP

BYTE_TO_DEC PROC near
	push cx
	push dx
	xor ah, ah
	xor dx, dx
	mov cx, 10
loop_bd:
	div cx
	or DL, 30h
	mov [SI], DL
	dec SI
	xor dx, dx
	cmp ax, 10
	jae loop_bd
	cmp al, 00h
	je end_l
	or al, 30h
	mov [SI], al
end_l:
	pop dx
	pop cx
	ret
BYTE_TO_DEC ENDP

PRINT_STRING PROC near
	mov ah, 09h
	int 21h
	ret
PRINT_STRING ENDP

;lab2_start
GET_MEMORY PROC near
	mov ax, ds:[02h]
	mov di, offset MEMORY_ADDRESS
	add di, 19
	call WRD_TO_HEX
	mov dx, offset MEMORY_ADDRESS
	call PRINT_STRING
	ret
GET_MEMORY ENDP

GET_ENVIRONMENT PROC near
	mov ax, ds:[2ch]
	mov di, offset ENVIRONMENT_ADDRESS
	add di, 24
	call WRD_TO_HEX
	mov dx, offset ENVIRONMENT_ADDRESS
	call PRINT_STRING
	ret
GET_ENVIRONMENT ENDP

GET_TAIL PROC near
	xor cx, cx
	mov cl, ds:[80h]
	mov si, offset TAIL
	add si, 5
	cmp cl, 0h
	je is_empty_tail
	xor di, di
	xor ax, ax
read_tail: 
	mov al, ds:[81h+di]
	inc di
	mov [si], al
	inc si
	loop read_tail
	mov dx, offset TAIL
	jmp end_tail
is_empty_tail:
	mov dx, offset EMPTY_TAIL
end_tail: 
	call PRINT_STRING 
	ret
GET_TAIL ENDP

GET_ENVIRONMENT_CONTENT PROC near
	mov dx, offset ENVIRONMENT_CONTENT
	call PRINT_STRING
	xor di,di
	mov ds, ds:[2ch]
read_string:
	cmp byte ptr [di], 00h
	jz end_str
	mov dl, [di]
	mov ah, 02h
	int 21h
	jmp find_end
end_str:
	cmp byte ptr [di+1],00h
	jz find_end
	push ds
	mov cx, cs
	mov ds, cx
	mov dx, offset END_STRING
	call PRINT_STRING
	pop ds
find_end:
	inc di
	cmp word ptr [di], 0001h
	jz read_path
	jmp read_string
read_path:
	push ds
	mov ax, cs
	mov ds, ax
	mov dx, offset PATH
	call PRINT_STRING
	pop ds
	add di, 2
loop_path:
	cmp byte ptr [di], 00h
	jz end_proc
	mov dl, [di]
	mov ah, 02h
	int 21h
	inc di
	jmp loop_path
end_proc:
	ret
GET_ENVIRONMENT_CONTENT ENDP
;lab2_end

BEGIN:
	call GET_MEMORY

	call GET_ENVIRONMENT

	call GET_TAIL

	call GET_ENVIRONMENT_CONTENT

	xor al,al
	mov ah,4ch
	int 21H

TESTPC ENDS
END START