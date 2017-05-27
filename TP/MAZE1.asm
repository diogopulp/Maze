;------------------------------------------------------------------------
;
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;
;	ANO LECTIVO 2016/2017
;;--------------------------------------------------------------
; Imprime valor da tecla numa posi��o do ecran na posi��o linha,coluna
;--------------------------------------------------------------
;	Programa de demostra��o de v�rias rotinhas do sistema de
;	manipula��o do ecr�n
;	Imprime um de v�rios caracteres na localiza��o do cursor
; 	Caracteres s�o seleccionadas com as teclas: 1, 2, 3, 4, e SPACE
;
;		arrow keys to move
;		press ESC to exit
;--------------------------------------------------------------

.8086
.model small
.stack 2048

dseg	segment para public 'data'

		Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        FichMenu         	  db      'menu.txt',0
		FichMazeConfig db 	'mconfig.txt',0
        HandleFich      dw      0
        car_fich        db      ?



		string	db	"Teste pr�tico de T.I",0
		Car		db	32
		POSy		db	5	; a linha pode ir de [1 .. 25]
		POSx		db	10	; POSx pode ir [1..80]

		GChar db 32 ; variavel para guardar o caracter

		fname	db	'MAZE.TXT',0
		FichStrg1 db 'strg1.txt', 0

		fhandle dw	0
		msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$"
		msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$"
		msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$"


		Buffer db 2000 dup(0) ; Inicializa um array de 2000 posições(80*25) a 0 para depois serem gravados no ficheiro

	;	p_POSxy dw	40	; ponteiro para posicao de escrita
dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg

;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da p�gina
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

;########################################################################
;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
		xor		bx,bx
		mov		cx,25*80


apaga:
		mov		byte ptr es:[bx],' '
		mov		byte ptr es:[bx+1],7
		inc		bx
		inc 	bx
		loop	apaga
		ret
apaga_ecran	endp

;########################################################################
; GUARDA ECRAN EM BUFFER

GUARDA_ECRA PROC
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

GUARDA_ECRA endp

;########################################################################
; LE UMA TECLA

LE_TECLA	PROC

		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp
;########################################################################
; CRIA UM FICHEIRO

CRIA_FICHEIRO PROC

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

CRIA_FICHEIRO endp

pedeNomeF proc
	mov		ax,0B800h
	mov		es,ax
	call	apaga_ecran
	
		;abre ficheiro
		mov     ah,3dh			    ; vamos abrir ficheiro para leitura
		mov     al,0			      ; tipo de ficheiro
		lea     dx,FichStrg1			    ; nome do ficheiro
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
	
	
	
pedeNomeF endp


;########################################################################


Main  proc
		mov		ax, dseg
		mov		ds,ax
		mov		ax,0B800h
		mov		es,ax

		call		apaga_ecran

		;Obter a posi��o
		dec		POSy		; linha = linha -1
		dec		POSx		; POSx = POSx -1

CICLO:	
		;********************************************************
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
		
	;**********************************************************************************
	goto_xy	POSx,POSy

IMPRIME:
		mov		ah, 02h
		mov		dl, Car
		int		21H ;INT 21h / AH=1 - read character from standard input, with echo,
							;result is stored in AL. if there is no character in the keyboard buffer,
							;the function waits until any key is pressed.
		mov		GChar, al	; Guarda o Caracter que est� na posi��o do Cursor
		goto_xy	POSx,POSy


		call GUARDA_ECRA

		call CRIA_FICHEIRO

		call 		LE_TECLA ;***************************
		cmp		ah, 1
		je		ESTEND
		CMP 		AL, 27		; ESCAPE
		JE		FIM
		
		cmp al, 13  ;enter 
			jne notPNF
		call pedeNomeF 		;vai pedir o nome do labirinto*************
		notPNF:

ZERO:		CMP 		AL, 48		; Tecla 0
		JNE		UM
		mov		Car, 32		;ESPA�O
		jmp		CICLO

UM:		CMP 		AL, 49		; Tecla 1
		JNE		DOIS

		mov		Car, 219		;Caracter CHEIO
		;mov Car, 120 ; x minusculo

		jmp		CICLO

DOIS:		CMP 		AL, 50		; Tecla 2
		JNE		TRES
		mov Car, 73 ; Define Inicio CHAR 'I'
		;mov		Car, 177		;CINZA 177
		jmp		CICLO

TRES:		CMP 		AL, 51		; Tecla 3
		JNE		QUATRO
		mov Car, 70; Define Fim CHAR 'F'
		;mov		Car, 178		;CINZA 178
		jmp		CICLO

QUATRO:	CMP 		AL, 52		; Tecla 4
		JNE		NOVE
		mov		Car, 32		;epaço, serve para apagar
		jmp		CICLO

NOVE:		jmp		CICLO

ESTEND:	cmp 		al,48h
		jne		BAIXO
		dec		POSy		;cima
		jmp		CICLO

BAIXO:	cmp		al,50h
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

fim:

		mov		ah,4CH
		INT		21H
Main	endp
Cseg	ends
end	Main
