;------------------------------------------------------------------------
;
;	TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;
;	ANO LECTIVO 2016/2017
;
; TRABALHO REALIZADO POR:
;
; DIOGO MIGUEL BRANCO SANTOS - 21210835
; JOÃO GASPAR - 2120


.8086
.model small
.stack 2048h

dseg    segment para public 'data'

	chIn             db    65
	oitoch           db    1
	string1          db    "Insira o nome do ficheiro:", 0
	fname	           db    'MAZEDEFA.TXT',0
	Buffer           db    2000 dup(0) ; Inicializa um array de 2000 posições(80*25) a 0 para depois serem gravados no ficheiro
	GChar            db    32 ; variavel para guardar o caracter
  Erro_Open        db    'Erro ao tentar abrir o ficheiro$'
  Erro_Ler_Msg     db    'Erro ao tentar ler do ficheiro$'
  Erro_Close       db    'Erro ao tentar fechar o ficheiro$'
	fhandle          dw	   0
	msgErrorCreate   db	   "Ocorreu um erro na criacao do ficheiro!$"
	msgErrorWrite	   db	   "Ocorreu um erro na escrita para ficheiro!$"
	msgErrorClose	   db	   "Ocorreu um erro no fecho do ficheiro!$"

  FichMenu         db    'menu.txt',0
	FichMazeConfig   db 	 'mconfig.txt',0
  FichDefaultMaze  db    'maze.txt',0
  HandleFich       dw    0
  car_fich         db    ?

  string	         db    "Teste pr�tico de T.I",0
  Car		           db	   32	; Guarda um caracter do Ecran
  Cor		           db	   7	; Guarda os atributos de cor do caracter
  POSy		         db	   18	; a linha pode ir de [1 .. 25]
  POSx		         db	   33	; POSx pode ir [1..80]
  POSya		         db	   5	; Posi��o anterior de y
  POSxa		         db	   10	; Posi��o anterior de x

  MazeX            db    1
  MazeY            db    1

dseg    ends

cseg    segment para public 'code'
assume  cs:cseg, ds:dseg

;*******************************INICIO DO PROGRAMA******************************

GOTO_XY MACRO		POSx,POSy

    mov		ah,02h
		mov		bh,0		; numero da p�gina
		mov		dl,POSx
		mov		dh,POSy
		int		10h

ENDM

APAGA_ECRAN	PROC  ; ------>LIMPA O ECRA<------
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
APAGA_ECRAN ENDP  ; ------>LIMPA O ECRA<------


GUARDA_ECRA PROC   ; ------>GUARDA ECRA NO BUFFER<------
		xor bx,bx
		xor si,si
		mov cx,25*80

copia:
		mov al, byte ptr es:[bx]
		mov	ah,	byte ptr es:[bx+1]
		mov Buffer[si], al
		mov Buffer[si+1], ah
		inc bx
		inc bx
		inc si
		inc si
		loop copia
		ret

GUARDA_ECRA ENDP  ; ------>GUARDA ECRA NO BUFFER<------

LE_TECLA	PROC   ; ------>LE UMA TECLA<------

	mov		ah,08h
	int		21h
	mov		ah,0
	cmp		al,0
	jne		SAI_TECLA
	mov		ah, 08h
	int		21h
	mov		ah,1

sai_tecla:
  ret

LE_TECLA	ENDP   ; ------>LE UMA TECLA<------

PEDENOMEF PROC  ; ------>PEDE NOME PARA SER ATRIBUIDO AO FICHEIRO<------
	mov		ax,0B800h
	mov		es,ax
	call	apaga_ecran

	mov posy, 1
	mov posx, 1
	goto_xy	POSx,POSy
	xor si, si ;si=0

puts:
	cmp string1[si], 0
	je scanf
	mov ah, 02h
	mov dl, string1[si]
	int 21h
	inc si
	jmp puts

scanf:
	mov posy, 2
	mov posx, 1
	goto_xy	POSx,POSy
	xor si, si ;si=0
	mov oitoch, 1

CICLO:
	mov chIn, 65 ;
	call 		LE_TECLA
	cmp		ah, 1
	je		ciclo
	CMP 		AL, 13		; enter
	jne backspace
	mov fname[si], 46 ;colocar a terminaçao do fich no fim do vetor
	inc si
	mov fname[si], 116 ;t
	inc si
	mov fname[si], 120 ;x
	inc si
	mov fname[si], 116 ;t
	inc si
	mov fname[si], 0
	ret

backspace:
	cmp		AL, 8  ;BACKSPACE
	jne limitesup
	cmp oitoch, 2
	jb ciclo   ; so continua se estiver dentro do lim inferior
	mov		ah, 02h
	mov		dl, 8 ;backspace pa andar pa traz
	int		21H
	mov		ah, 02h
	mov		dl, 32 ;espaço pa limpar
	int		21H
	mov		ah, 02h
	mov		dl, 8 ;backspace pa andar pa traz
	int		21H
	dec oitoch
	dec si ;anda pa traz no nomefich
	jmp ciclo

limitesup:
	cmp oitoch, 8
	ja ciclo    ; so continua se estiver dentro do lim superior

tryagain:
	cmp al, chIn
	jne	incrementar
	mov bl, chIn
	mov	Car, 	bl
	mov	ah, 02h      ;WRITE CHARACTER TO STANDARD OUTPUT
	mov	dl, Car
	int	21H
	inc oitoch
	mov fname[si], bl  ;coloca na variavel
	inc si
	jmp	CICLO

incrementar:
	cmp chIn, 90
	je minusculas
	inc chIn
	jmp tryagain

minusculas:
	mov 	chIn, 97

tryagainmin:
	cmp	al, chIn
	jne	incrementarmin
	mov bl, chIn
	mov	Car, 	bl
	mov	ah, 02h      ;WRITE CHARACTER TO STANDARD OUTPUT
	mov	dl, Car
	int	21H
	inc oitoch
	mov fname[si], bl  ;coloca na variavel
	inc si
	jmp	CICLO

incrementarmin:
	cmp chin, 122
	je ciclo
	inc chIn
	jmp tryagainmin

PEDENOMEF ENDP ; ------>PEDE NOME PARA SER ATRIBUIDO AO FICHEIRO<------

CRIA_FICHEIRO PROC  ; ------>CRIA UM FICHEIRO<------

  mov	ah, 3ch			; abrir ficheiro para escrita
	mov	cx, 00H			; tipo de ficheiro

	lea	dx, fname		; dx contem endereco do nome do ficheiro
	int	21h					; abre efectivamente e AX vai ficar com o Handle do ficheiro

	jnc	escreve			; se não acontecer erro vamos escrever

	mov	ah, 09h			; Aconteceu erro na leitura
	lea	dx, msgErrorCreate
	int	21h
	ret

escreve:
	mov	bx, ax			; para escrever BX deve conter o Handle
	mov	ah, 40h			; indica que vamos escrever

	lea	dx, Buffer			; Vamos escrever o que estiver no endereço DX
	mov	cx, 4000			; vamos escrever multiplos bytes duma vez só

	int	21h				; faz a escrita
	jnc	close				; se não acontecer erro fecha o ficheiro

	mov	ah, 09h
	lea	dx, msgErrorWrite
	int	21h

close:
	mov	ah,3eh			; indica que vamos fechar
	int	21h				; fecha mesmo
	ret				; se não acontecer erro termina

	mov	ah, 09h
	lea	dx, msgErrorClose
	int	21h

CRIA_FICHEIRO ENDP  ; ------>CRIA UM FICHEIRO<------


MENUDESENHAR PROC  ;##########################----CRIACAO DE LABIRINTO---####################################
		call pedeNomeF
		mov		ax,0B800h
		mov		es,ax
		call		apaga_ecran
		mov		Car, 32		;ESPA�O
		mov		ah, 02h      ;WRITE CHARACTER TO STANDARD OUTPUT
		mov		dl, car  ; espaco
		int		21H
		mov posx, 3
		mov posy, 3
		goto_xy posx, posy

CICLO:  ;**************************************
	cmp posy, 21
		jne notdown
	mov posy, 1

notdown:					;manter o y dentro dos limites
	cmp posy, 0
		jne notup
	mov posy, 20

notup:
	cmp posx, 0			;manter o x dentro dos limites
		jne notleft
	mov posx, 40
notleft:
	cmp posx, 41
		jne notright
	mov posx, 1
notright:

;**************************************
	goto_xy	POSx,POSy

IMPRIME:
		mov		ah, 02h      ;WRITE CHARACTER TO STANDARD OUTPUT
		mov		dl, Car
		int		21H
		mov		GChar, al	; Guarda o Caracter que est� na posi��o do Cursor
		goto_xy	POSx,POSy

	;	call GUARDA_ECRA

		call CRIA_FICHEIRO

		call 		LE_TECLA ;***************************
		cmp		ah, 1
		je		ESTEND

		cmp al, 13  ;enter
			jne zero
		mov posx, 25 ;colocar o x no sitio onde vai aparece os menus
		mov posy, 6
		ret


ZERO:
  cmp 		AL, 48		; Tecla 0
	jne		UM
	mov		Car, 32		;ESPA�O
	jmp		CICLO

UM:
  cmp 		AL, 49		; Tecla 1
	jne		DOIS
	mov		Car, 219		;Caracter CHEIO
	jmp		CICLO

DOIS:
  cmp AL, 50		; Tecla 2
	jne	TRES
	mov Car, 73 ; Define Inicio CHAR 'I'
	jmp	CICLO

TRES:
  cmp	AL, 51		; Tecla 3
	jne	QUATRO
	mov Car, 70; Define Fim CHAR 'F'
	jmp	CICLO

QUATRO:
  cmp AL, 52		; Tecla 4
	jne	NOVE
	mov	Car, 32		;epaço, serve para apagar
	jmp	CICLO

NOVE:		jmp		CICLO

ESTEND:
  cmp 		al,48h
	jne		BAIXO
	dec		POSy		;cima
	jmp		CICLO

BAIXO:
	cmp		al,50h
	jne		ESQUERDA
	inc 		POSy		;Baixo
	jmp		CICLO

ESQUERDA:
	cmp		al,4Bh
	jne		DIREITA
	dec		POSx		;Esquerda
	jmp		CICLO

DIREITA:
	cmp		al,4Dh
	jne		CICLO
	inc		POSx		;Direita
	jmp		CICLO

MENUDESENHAR ENDP ;##########################----CRIACAO DE LABIRINTO---####################################

MENUCONFIG PROC  ;##########################----MENU DE CONFIGURACAO---####################################
inicio:
	mov		ax,0B800h       ; Apaga
	mov		es,ax				    ;	o
	call	apaga_ecran		  ; Ecran

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
;**************************************

	cmp posy, 12
	jne snake
	mov posy, 6

  snake:					;manter o 'x' dentro dos limites
	cmp posy, 5
	jne fimsnake
	mov posy, 11

  fimsnake:
;**************************************

	goto_xy	POSxa,POSya	; Vai para a posi��o anterior do cursor
		mov		ah, 02h
		mov		dl, Car	; Repoe Caracter guardado
		int		21H

	goto_xy	POSx,POSy	; Vai para nova possi��o
		mov 	ah, 08h
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
	mov 	POSya, al

LER_SETA:
	call 	le_tecla
	cmp		ah, 1
	je		ESTEND
	cmp 	al, 27	 ; ESCAPE
	je		FIM
	cmp al, 13		 ;enter
	jne estend
	cmp posy, 11   ; se o 'x' estiver no back
	jne createmaze
	mov posx, 33
	mov posy, 18
	ret

createmaze:
  cmp posy, 8  ; se o 'x' estiver no create maze
	jne editmaze
	call menuDesenhar ; Call MenuDesenha PROC
	jmp inicio

editmaze:
	jmp		LER_SETA

ESTEND:
	cmp 	al,48h
	jne		BAIXO
	dec		POSy		;cima
	jmp		CICLO

BAIXO:
	cmp		al,50h
	jne		ciclo
	inc 	POSy		;Baixo
	jmp		CICLO

fim:
	mov		ah,4CH
	int		21H

MENUCONFIG ENDP ;##########################----MENU DE CONFIGURACAO---####################################

PLAY PROC ;##########################----INICIA O JOGO---####################################

  mov		ax,0B800h           ; Apaga
  mov		es,ax				;	o
  call apaga_ecran ; ecra

  mov MazeX, 1
  mov MazeY, 1
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

LER_SETA:
  call 		LE_TECLA
  cmp		ah, 1
  je		ESTEND
  cmp 	AL, 27	; ESCAPE
  je		FIM
  jmp		LER_SETA

ESTEND:
  cmp 	al,48h
  jne		BAIXO
  dec		MazeY		;cima
  cmp   Car, 219 ; Parede
  je    PAREDECIMA
  jmp		CICLO

BAIXO:
  cmp		al,50h
  jne		ESQUERDA
  inc 	MazeY		;Baixo
  cmp   Car, 219 ; Parede
  je    PAREDEBAIXO
  jmp		CICLO

ESQUERDA:
  cmp		al,4Bh
  jne		DIREITA
  dec		MazeX		;Esquerda
  cmp   Car, 219 ; Parede
  je    PAREDEESQUERDA
  jmp		CICLO

DIREITA:
  cmp		al,4Dh
  jne		LER_SETA
  inc		MazeX		;Direita
  cmp   Car, 219 ; Parede
  je    PAREDEDIREITA
  jmp		CICLO

PAREDECIMA:
  inc MazeY
  call menu

PAREDEBAIXO:
  dec MazeY
  call menu

PAREDEESQUERDA:
  inc MazeX
  call menu

PAREDEDIREITA:
  dec MazeX
  call menu


fim:
	mov		ah,4CH
	int		21H

PLAY ENDP ;##########################----INICIA O JOGO---#####################################

MENU PROC ;##########################----MENU PRINCIPAL---####################################
inicio:
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
	mov		ax, dseg
	mov		ds,ax
	mov		ax,0B800h
	mov		es,ax

goto_xy	POSx,POSy	  ; Vai para nova possi��o
	mov 	ah, 08h	    ; Guarda o Caracter que est� na posi��o do Cursor
	mov		bh,0		    ; numero da p�gina
	int		10h
	mov		Car, al	    ; Guarda o Caracter que est� na posi��o do Cursor
	mov		Cor, ah	    ; Guarda a cor que est� na posi��o do Cursor

CICLO:
;**************************************
	cmp posy, 22
		jne snake
	mov posy, 18
	snake:					;manter o 'x' dentro dos limites

	cmp posy, 17
		jne fimsnake
	mov posy, 21
	fimsnake:
;*************************************

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
;*************************************
; 						ler opcao

	cmp al, 13					;enter
		jne estend
  cmp posy, 18 ; se o 'x' estiver no play
    je play
	cmp posy, 21  ; se o 'x' estiver no exit
		je fim
	cmp posy, 20 ; se o 'x' estiver no maze config
		jne estend
	mov posx, 25 ;colocar o x no sitio onde vai aparece os menus
	mov posy, 6
	call menuconfig
	jmp inicio
;*************************************
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


MENU ENDP ;##########################----MENU PRINCIPAL---####################################

MAIN PROC ;###############################----MAIN---#########################################
  mov     ax,DSEG
  mov     ds,ax

  call MENU

MAIN  ENDP ;###############################----MAIN---########################################
CSEG ENDS
END MAIN
