;------------------------------------------------------------------------
;
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;
;	ANO LECTIVO 2016/2017
;--------------------------------------------------------------
;
;	Programa de demostração de leitura dum ficheiro de texto
;	Lê um ficheiro e imprime o conteudo no ecran
;
;--------------------------------------------------------------


.8086
.model small
.stack 2048h

dseg    segment para public 'data'
        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'

        FichMenu         	  db      'menu.txt',0
		    FichMazeConfig      db 	    'mconfig.txt',0
        FichDefaultMaze     db      'maze.txt',0

        HandleFich      dw      0
        car_fich        db      ?

        string	db	"Teste pr�tico de T.I",0
    		Car		db	32	; Guarda um caracter do Ecran
    		Cor		db	7	; Guarda os atributos de cor do caracter
    		POSy		db	18	; a linha pode ir de [1 .. 25]
    		POSx		db	33	; POSx pode ir [1..80]
    		POSya		db	5	; Posi��o anterior de y
    		POSxa		db	10	; Posi��o anterior de x

        MazeX db 1
        MazeY db 1

dseg    ends

cseg    segment para public 'code'
assume  cs:cseg, ds:dseg

;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da p�gina
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

;********************************************************************************
;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
    push bx
		push ax
		push cx
    push si
    xor bx,bx
		mov cx,24*80
		mov bx,160
    mov si,bx
apaga:
		mov	al,' '
    mov byte ptr es:[bx],al
		mov byte ptr es:[bx+1],7
		inc bx
		inc bx
		inc si
		loop apaga
		pop si
		pop cx
		pop ax
		pop bx
		ret
apaga_ecran endp
;********************************************************************************
; LE UMA TECLA

le_tecla	proc

		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
sai_tecla:	ret
le_tecla	endp


menuconfig proc
		mov		ax,0B800h           ; Apaga
		mov		es,ax				;	o
		call		apaga_ecran		; Ecran


	;abre ficheiro
		mov     ah,3dh			    ; vamos abrir ficheiro para leitura
		mov     al,0			      ; tipo de ficheiro
		lea     dx,FichMazeConfig			    ; nome do ficheiro
		int     21h			        ; abre para leitura
		jc      erro_abrir		  ; pode aconter erro a abrir o ficheiro
		mov     HandleFich,ax		; ax devolve o Handle para o ficheiro
		jmp     ler_ciclo		    ; depois de aberto vamos ler o ficheiro

	erro_abrir:
		mov     ah,09h
		lea     dx,Erro_Open
		int     21h
	;    jmp     sai

	ler_ciclo:
		mov     ah,3fh			    ; indica que vai ser lido um ficheiro
		mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto
		mov     cx,1			      ; numero de bytes a ler
		lea     dx,car_fich		  ; vai ler para o local de memoria apontado por dx (car_fich)
		int     21h				      ; faz efectivamente a leitura
		  jc	    erro_ler		    ; se carry é porque aconteceu um erro
		  cmp	    ax,0			      ; EOF?	verifica se já estamos no fim do ficheiro
		  je	    fecha_ficheiro	; se EOF fecha o ficheiro
		mov     ah,02h			    ; coloca o caracter no ecran
		  mov	    dl,car_fich		  ; este é o caracter a enviar para o ecran
		  int	    21h				      ; imprime no ecran
		  jmp	    ler_ciclo		    ; continua a ler o ficheiro

	erro_ler:
		mov     ah,09h
		lea     dx,Erro_Ler_Msg
		int     21h

	fecha_ficheiro:					        ; vamos fechar o ficheiro
		mov     ah,3eh
		mov     bx,HandleFich
		int     21h
		;    jnc     sai

		;    mov     ah,09h			    ; o ficheiro pode não fechar correctamente
		;    lea     dx,Erro_Close
		;    Int     21h


		;sai:
		 ;       mov     ah,4ch
		  ;      int     21h

	; Nova parte do Programa

		mov		ax, dseg
		mov		ds,ax
		mov		ax,0B800h
		mov		es,ax

	goto_xy	POSx,POSy	; Vai para nova possi��o
		mov 	ah, 08h	; Guarda o Caracter que est� na posi��o do Cursor
		mov		bh,0		; numero da p�gina
		int		10h
		mov		Car, al	; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah	; Guarda a cor que est� na posi��o do Cursor

	CICLO:
	;********************************************************


		cmp posy, 12
			jne snake
		mov posy, 6
		snake:					;manter o 'x' dentro dos limites

		cmp posy, 5
			jne fimsnake
		mov posy, 11
		fimsnake:
	;**********************************************************************************

		goto_xy	POSxa,POSya	; Vai para a posi��o anterior do cursor
			mov		ah, 02h
			mov		dl, Car	; Repoe Caracter guardado
			int		21H

		goto_xy	POSx,POSy	; Vai para nova possi��o
			mov 		ah, 08h
			mov		bh,0		; numero da p�gina
			int		10h
			mov		Car, al	; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah	; Guarda a cor que est� na posi��o do Cursor

		goto_xy	78,0		; Mostra o caractr que estava na posi��o do AVATAR
			mov		ah, 02h	; IMPRIME caracter da posi��o no canto
			mov		dl, Car
			int		21H

			goto_xy	POSx,POSy	; Vai para posi��o do cursor

	IMPRIME:
		mov		ah, 02h
			mov		dl, 120	; Coloca AVATAR x -> 120
			int		21H
			goto_xy	POSx,POSy	; Vai para posi��o do cursor

			mov		al, POSx	; Guarda a posi��o do cursor
			mov		POSxa, al
			mov		al, POSy	; Guarda a posi��o do cursor
			mov 		POSya, al

	LER_SETA:
		call 	le_tecla
		cmp		ah, 1
		je		ESTEND
		cmp 	al, 27	; ESCAPE
		je		FIM
	;*************************************************************************
	; 				ler opcao
		cmp al, 32					 ; epaco
			jne vamosveroenter
		cmp posy, 11 ; se o 'x' estiver no back
			jne notback
		mov posx, 33
		mov posy, 18
			call menu
		notback:

		vamosveroenter:
		cmp al, 13					;enter
			jne estend
		cmp posy, 11 ; se o 'x' estiver no back
			jne estend
		mov posx, 33
		mov posy, 18
			call menu
	;******************************************************************
		jmp		LER_SETA

	ESTEND:
		cmp 		al,48h
			jne		BAIXO
		dec		POSy		;cima
		jmp		CICLO

	BAIXO:
		cmp		al,50h
		jne		ciclo
		inc 		POSy		;Baixo
		jmp		CICLO


	fim:
			mov		ah,4CH
			int		21H



	menuconfig endp
;******************************************************
; PLAY Imprime o jogo e move o avatar
  play proc

  mov		ax,0B800h           ; Apaga
  mov		es,ax				;	o
  call apaga_ecran


  goto_xy	MazeX,MazeY

  mov     ah,3dh			; vamos abrir ficheiro para leitura
  mov     al,0			; tipo de ficheiro
  lea     dx,FichDefaultMaze			; nome do ficheiro
  int     21h			; abre para leitura
  jc      erro_abrir		; pode aconter erro a abrir o ficheiro
  mov     HandleFich,ax		; ax devolve o Handle para o ficheiro
  jmp     ler_ciclo		; depois de abero vamos ler o ficheiro

erro_abrir:
  mov     ah,09h
  lea     dx,Erro_Open
  int     21h

  ret

ler_ciclo:
  mov     ah,3fh			; indica que vai ser lido um ficheiro
  mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto
  mov     cx,1			; numero de bytes a ler
  lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
  int     21h				; faz efectivamente a leitura
  jc	    erro_ler		; se carry é porque aconteceu um erro
  cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro
  je	    fecha_ficheiro	; se EOF fecha o ficheiro
  mov     ah,02h			; coloca o caracter no ecran
  mov	    dl,car_fich		; este é o caracter a enviar para o ecran
  int	    21h				; imprime no ecran
  jmp	    ler_ciclo		; continua a ler o ficheiro

erro_ler:
  mov     ah,09h
  lea     dx,Erro_Ler_Msg
  int     21h

fecha_ficheiro:					; vamos fechar o ficheiro
  mov     ah,3eh
  mov     bx,HandleFich
  int     21h


  mov		ax, dseg
  mov		ds,ax
  mov		ax,0B800h
  mov		es,ax

  goto_xy	MazeX,MazeY	; Vai para nova possi��o
  mov 		ah, 08h	; Guarda o Caracter que est� na posi��o do Cursor
  mov		bh,0		; numero da p�gina
  int		10h
  mov		Car, al	; Guarda o Caracter que est� na posi��o do Cursor
  mov		Cor, ah	; Guarda a cor que est� na posi��o do Cursor


CICLO:	goto_xy	POSxa,POSya	; Vai para a posi��o anterior do cursor
  mov		ah, 02h
  mov		dl, Car	; Repoe Caracter guardado
  int		21H

  goto_xy	MazeX,MazeY	; Vai para nova possi��o
  mov 		ah, 08h
  mov		bh,0		; numero da p�gina
  int		10h
  mov		Car, al	; Guarda o Caracter que est� na posi��o do Cursor
  mov		Cor, ah	; Guarda a cor que est� na posi��o do Cursor

  goto_xy	78,0		; Mostra o caractr que estava na posi��o do AVATAR
  mov		ah, 02h	; IMPRIME caracter da posi��o no canto
  mov		dl, Car
  int		21H

  goto_xy	MazeX,MazeY	; Vai para posi��o do cursor
IMPRIME:	mov		ah, 02h
  mov		dl, 233	; Coloca AVATAR
  int		21H
  goto_xy	MazeX,MazeY	; Vai para posi��o do cursor

  mov		al, MazeX	; Guarda a posi��o do cursor
  mov		POSxa, al
  mov		al, MazeY	; Guarda a posi��o do cursor
  mov 		POSya, al

LER_SETA:	call 		LE_TECLA
  cmp		ah, 1
  je		ESTEND
  CMP 		AL, 27	; ESCAPE
  JE		FIM
  jmp		LER_SETA

ESTEND:	cmp 		al,48h
  jne		BAIXO
  dec		MazeY		;cima
  jmp		CICLO

BAIXO:	cmp		al,50h
  jne		ESQUERDA
  inc 		MazeY		;Baixo
  jmp		CICLO

ESQUERDA:
  cmp		al,4Bh
  jne		DIREITA
  dec		MazeX		;Esquerda
  jmp		CICLO

DIREITA:
  cmp		al,4Dh
  jne		LER_SETA
  inc		MazeX		;Direita
  jmp		CICLO

  fim:
  		mov		ah,4CH
  		INT		21H

  play endp
;******************************************************

	menu proc
		mov		ax,0B800h           ; Apaga
		mov		es,ax				;	o
		call		apaga_ecran		; Ecran

		;abre ficheiro
		mov     ah,3dh			    ; vamos abrir ficheiro para leitura
		mov     al,0			      ; tipo de ficheiro
		lea     dx,FichMenu			    ; nome do ficheiro
		int     21h			        ; abre para leitura
		jc      erro_abrir		  ; pode aconter erro a abrir o ficheiro
		mov     HandleFich,ax		; ax devolve o Handle para o ficheiro
		jmp     ler_ciclo		    ; depois de aberto vamos ler o ficheiro

	erro_abrir:
		mov     ah,09h
		lea     dx,Erro_Open
		int     21h
	;    jmp     sai

	ler_ciclo:
		mov     ah,3fh			    ; indica que vai ser lido um ficheiro
		mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto
		mov     cx,1			      ; numero de bytes a ler
		lea     dx,car_fich		  ; vai ler para o local de memoria apontado por dx (car_fich)
		int     21h				      ; faz efectivamente a leitura
		  jc	    erro_ler		    ; se carry é porque aconteceu um erro
		  cmp	    ax,0			      ; EOF?	verifica se já estamos no fim do ficheiro
		  je	    fecha_ficheiro	; se EOF fecha o ficheiro
		mov     ah,02h			    ; coloca o caracter no ecran
		  mov	    dl,car_fich		  ; este é o caracter a enviar para o ecran
		  int	    21h				      ; imprime no ecran
		  jmp	    ler_ciclo		    ; continua a ler o ficheiro

	erro_ler:
		mov     ah,09h
		lea     dx,Erro_Ler_Msg
		int     21h

	fecha_ficheiro:					        ; vamos fechar o ficheiro
		mov     ah,3eh
		mov     bx,HandleFich
		int     21h
	;    jnc     sai

	;    mov     ah,09h			    ; o ficheiro pode não fechar correctamente
	;    lea     dx,Erro_Close
	;    Int     21h


	;sai:
	 ;       mov     ah,4ch
	  ;      int     21h

	; Nova parte do Programa

		mov		ax, dseg
		mov		ds,ax
		mov		ax,0B800h
		mov		es,ax

	goto_xy	POSx,POSy	; Vai para nova possi��o
		mov 	ah, 08h	; Guarda o Caracter que est� na posi��o do Cursor
		mov		bh,0		; numero da p�gina
		int		10h
		mov		Car, al	; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah	; Guarda a cor que est� na posi��o do Cursor

	CICLO:
	;********************************************************
		cmp posy, 22
			jne snake
		mov posy, 18
		snake:					;manter o 'x' dentro dos limites

		cmp posy, 17
			jne fimsnake
		mov posy, 21
		fimsnake:
	;**********************************************************************************

		goto_xy	POSxa,POSya	; Vai para a posi��o anterior do cursor
			mov		ah, 02h
			mov		dl, Car	; Repoe Caracter guardado
			int		21H

		goto_xy	POSx,POSy	; Vai para nova possi��o
			mov 		ah, 08h
			mov		bh,0		; numero da p�gina
			int		10h
			mov		Car, al	; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah	; Guarda a cor que est� na posi��o do Cursor

		goto_xy	78,0		; Mostra o caractr que estava na posi��o do AVATAR
			mov		ah, 02h	; IMPRIME caracter da posi��o no canto
			mov		dl, Car
			int		21H

			goto_xy	POSx,POSy	; Vai para posi��o do cursor

	IMPRIME:
		mov		ah, 02h
			mov		dl, 120	; Coloca AVATAR x -> 120
			int		21H
			goto_xy	POSx,POSy	; Vai para posi��o do cursor

			mov		al, POSx	; Guarda a posi��o do cursor
			mov		POSxa, al
			mov		al, POSy	; Guarda a posi��o do cursor
			mov 		POSya, al

	LER_SETA:
		call 	le_tecla
		cmp		ah, 1
		je		ESTEND
		cmp 	al, 27	; ESCAPE
		je		FIM
	;*************************************************************************
	; 						ler opcao
		cmp al, 32					 ; epaco
			jne vamosveroenter
    cmp posy, 18 ; se o 'x' estiver no play
      je play
		cmp posy, 21 ; se o 'x' estiver no exit
			je fim
		cmp posy, 20 ; se o 'x' estiver no maze config
			jne estend
		mov posx, 25
		mov posy, 6
		call menuconfig

		vamosveroenter:
		cmp al, 13					;enter
			jne estend
    cmp posy, 18 ; se o 'x' estiver no play
      je play
		cmp posy, 21  ; se o 'x' estiver no exit
			je fim
		cmp posy, 20 ; se o 'x' estiver no maze config
			jne estend
		mov posx, 25
		mov posy, 6
		call menuconfig
	;******************************************************************
		jmp		LER_SETA

	ESTEND:
		cmp 		al,48h
			jne		BAIXO
		dec		POSy		;cima
		jmp		CICLO

	BAIXO:
		cmp		al,50h
		jne		ciclo
		inc 		POSy		;Baixo
		jmp		CICLO


	fim:
			mov		ah,4CH
			int		21H


menu endp

;########################################################################

Main    Proc

    mov     ax,dseg
    mov     ds,ax

	call menu


Main    endp
cseg	ends
end     Main
