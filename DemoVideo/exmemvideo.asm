.8086
.model small
.stack 2048

cseg	segment para public 'code'
	assume  cs:cseg

Main  proc
	mov   ax,0b800h
	mov   es,ax
;************
	mov al, linha
	mov bl, 160
	mul bl
	mov bx,ax

	mov al, linha
	add al, 15
	mov dl, 160
	mul dl
	mov si, ax

	ciclo:
	mov ax, es:[bx]
	add bx, 2
	mov es:[si], ax
	add si,2
	loop ciclo
;************
	mov	al,0h
	mov	ah,'*'
	mov	bx,0
	mov	cx,25*80

ciclo:
	mov	es:[bx],ah
	mov	es:[bx+1],al
	inc	bx
	inc	bx
	inc	al
	loop	 ciclo

	mov     ah,4CH
	int     21H
main	endp

cseg    ends
end     main
