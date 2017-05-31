.8086
.model small
.stack 2048

dseg segment para public 'data'
	coluna db 3
dseg ends

cseg	segment para public 'code'
	assume  cs:cseg, ds: dseg

Main  proc
	mov   ax, dsegutili

	mov   ds,ax

	mov ax, 0B800h
	mov es, ax

	mov cx, 25
	mov al, coluna
	mov bl, 2
	mul bl
	mov bx,ax
	mov si, bx
	add si, 40

ciclo:
	mov ax,es:[bx]
	mov dx, es:[bx+2]
	add bx, 160
	mov es:[si], ax
	mov es:[si+2], dx
	add si,160
	loop ciclo

	mov     ah,4CH
	int     21H
main	endp

cseg    ends
end     main
