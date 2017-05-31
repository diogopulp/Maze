.8086
.model small
.stack 2048

cseg	segment para public 'code'
	assume  cs:cseg

Main  proc
	mov   ax,0b800h
	mov   es,ax

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
