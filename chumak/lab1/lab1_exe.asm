AStack    SEGMENT  STACK 
          DW 128 DUP(?)   
AStack    ENDS

DATA SEGMENT
PC_TYPE_PC db 'PC type: PC', 0dh, 0ah, '$'
PC_TYPE_PC_XT db 'PC type: PC/XT', 0dh, 0ah, '$'
PC_TYPE_AT db 'PC type: AT', 0dh, 0ah, '$'
PC_TYPE_PS2_30 db 'PC type: PS2 30', 0dh, 0ah, '$'
PC_TYPE_PS2_50_60 db 'PC type: PS2 50 or 60', 0dh, 0ah, '$'
PC_TYPE_PS2_80 db 'PC type: PS2 80', 0dh, 0ah, '$'
PC_TYPE_PС_JR db 'PC type: PСjr', 0dh, 0ah, '$'
PC_TYPE_PC_CONVERTIBLE db 'PC type: PC Convertible', 0dh, 0ah, '$'
DOS_VERSION db 'MS DOS version:  . ', 0dh, 0ah, '$'
OEM_NUMBER db 'OEM serial number:  ', 0dh, 0ah, '$'
USER_NUMBER db 'User serial number:       H $'
DATA ENDS

CODE SEGMENT
   ASSUME CS:CODE, DS:DATA, SS:AStack

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
	pop BX
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
	or dl, 30h
	mov [SI], dl
	dec SI
	xor dx, dx

	cmp AX, 10
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

PC_TYPE PROC near
	mov ax, 0f000h
	mov es, ax
	mov al, es:[0fffeh]

	cmp al, 0ffh
	je pc

	cmp al, 0feh
	je pc_xt

	cmp al, 0fbh
	je pc_xt

	cmp al, 0fch
	je pc_at

	cmp al, 0fah
	je pc_ps2_30

	cmp al, 0f8h
	je pc_ps2_80

	cmp al, 0fdh
	je pc_jr

	cmp al, 0f9h
	je pc_convertible
pc:
	mov dx, offset PC_TYPE_PC
	jmp print_type
pc_xt:
	mov dx, offset PC_TYPE_PC_XT
	jmp print_type
pc_at:
	mov dx, offset PC_TYPE_AT
	jmp print_type
pc_ps2_30:
	mov dx, offset PC_TYPE_PS2_30
	jmp print_type
pc_ps2_50_60:
	mov dx, offset PC_TYPE_PS2_50_60
	jmp print_type
pc_ps2_80:
	mov dx, offset PC_TYPE_PS2_80
	jmp print_type
pc_jr:
	mov dx, offset PC_TYPE_PС_JR
	jmp print_type
pc_convertible:
	mov dx, offset PC_TYPE_PC_CONVERTIBLE
	jmp print_type
print_type:
	call PRINT_STRING
	ret
PC_TYPE ENDP

OS_VERSION PROC near
	mov ah, 30h
	int 21h

	push ax
	mov si, offset DOS_VERSION
	add si, 16
	call BYTE_TO_DEC
	pop ax
	mov al, ah
	add si, 3
	call BYTE_TO_DEC
	mov dx, offset DOS_VERSION

	call PRINT_STRING
	
	mov si, offset OEM_NUMBER
	add si, 19
	mov al, bh
	call BYTE_TO_DEC
	mov dx, offset OEM_NUMBER

	call PRINT_STRING
	
	mov di, offset USER_NUMBER
	add di, 25
	mov ax, cx
	call WRD_TO_HEX
	mov al, bl
	call BYTE_TO_HEX
	sub di, 2
	mov [di], ax
	mov dx, offset USER_NUMBER

	call PRINT_STRING

	ret
OS_VERSION ENDP

Main PROC far
	mov ax, DATA
	mov ds, ax

	call PC_TYPE
	call OS_VERSION

	xor al,al
	mov ah,4Ch
	int 21H

Main ENDP

CODE ENDS
END Main
