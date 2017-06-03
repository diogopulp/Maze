;------------------------------------------------------------------------
;
;	TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;
;	ANO LECTIVO 2016/2017
;
; TRABALHO REALIZADO POR:
;
; DIOGO MIGUEL BRANCO SANTOS - 21210835
; JOÃO FILIPE LOPES GASPAR - 21200069


.8086
.model small
.stack 2048h

dseg    segment para public 'data'

  FichDefaultMaze  db    'maze.txt',0
  fnameptrFich db 'mnamespf.txt',0 ;nome do ficheiro que contem o ponteiro para o ultimo elemento do array com os nomes dos labirintos
  fnamenFich db 'mnamesnf.txt',0 ;nome do ficheiro que contem o n de elementos do array com os nomes dos labirintos
  mazeNamesFich db 'mnamesf.txt',0 ;nome do ficheiro que contem os nomes dos labirintos
  fname db 390 dup(?) ;vetor de strings, 30*13  30strings de 12+1 char
  fnameptr dw 0 ;ponteiro para o fname
  fnameop db 0 ; fname option, começa a 0 que é o default, é a o labirinto a carregar no play
  fnameditop db 0 ; o labirinto a editar
  fnamen db 0	; n elementos do fname
  p db 0 ; ponteiro
  pant db 0
  zeros db 0
  lastzero dw 0
  fnameopen db 13 dup(?)
  fnamedit db 13 dup(?)
  Cor		           db	   7	; Guarda os atributos de cor do caracter
  POSya		         db	   5	; Posi��o anterior de y
  POSxa		         db	   10	; Posi��o anterior de x

  MazeX            db    1
  MazeY            db    1

  ;------------------VARIAVEIS DO MAZE1----------------------
  chIn db 65
  oitoch db 1
  string1 db "Type maze name:", 0
  string2 db "Choose your maze:", 0
  string3 db "Default Maze has been choosen!", 0
  string4 db "Delete Maze:", 0
  string5 db "Edit Maze:", 0

  Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
  Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
  Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
  FichMenu         	  db      'menu.txt',0
  FichMazeConfig db 	'mconfig.txt',0
  HandleFich      dw      0
  car_fich        db      ?
  mazenamesfichErr db 'erro na gravacao dos labirintos$'

  string	db	"Teste pr�tico de T.I",0
  Car		db	32
  POSy		db	18	; a linha pode ir de [1 .. 25]
  POSx		db	33	; POSx pode ir [1..80]

  GChar db 32 ; variavel para guardar o caracter


  fhandle dw	0
  msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$"
  msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$"
  msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$"


  Buffer db 2000 dup(0) ; Inicializa um array de 2000 posições(80*25) a 0 para depois serem gravados no ficheiro

;------------------VARIAVEIS DO RELOGIO----------------------

  STR12	 		DB 		"            "	; String para 12 digitos
  NUMERO		DB		"                    $", 	; String destinada a guardar o número lido

  NUM_SP		db		"                    $" 	; PAra apagar zona de ecran
  DDMMAAAA 		db		"                     "

  Horas			dw		0				; Vai guardar a HORA actual
  Minutos		dw		0				; Vai guardar os minutos actuais
  Segundos		dw		0				; Vai guardar os segundos actuais
  Old_seg		dw		0				; Guarda os últimos segundos que foram lidos

  POSy2	db	10	; a linha pode ir de [1 .. 25]
  POSx2	db	40	; POSx pode ir [1..80]
  NUMDIG	db	0	; controla o numero de digitos do numero lido
  MAXDIG	db	4	; Constante que define o numero MAXIMO de digitos a ser aceite

  segundos1 db 47; contador de segundos
  segundos2 db 48; contador de segundos pos2

  minutos1 db 48; contador de minutos
  minutos2 db 48; contador de inutos pos2

  strsegundos1 db "     $" ;string para ser impressa
  strsegundos2 db "     $" ;string para ser impressa

  strminutos1 db "     $" ;string para ser impressa
  strminutos2 db "     $" ;string para ser impressa

  strzero db "0$"
  strdoispontos db ":$"

dseg    ends

cseg    segment para public 'code'
assume  cs:cseg, ds:dseg

;*******************************INICIO DO PROGRAMA******************************

;MACROS
GOTO_XY MACRO		POSx,POSy
    mov		ah,02h
		mov		bh,0		; numero da p�gina
		mov		dl,POSx
		mov		dh,POSy
		int		10h
ENDM

MOSTRA MACRO STR
  mov ah,09H
  lea dx,STR
  int 21H
ENDM
;MACROS

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

;********************************************************************************
;********************************************************************************
; HORAS  - LE Hora DO SISTEMA E COLOCA em tres variaveis (Horas, Minutos, Segundos)
; CH - Horas, CL - Minutos, DH - Segundos
;********************************************************************************

LER_TEMPO PROC

  push ax
  push bx
  push cx
  push dx
  pushf

	MOV AH, 2CH             ; Buscar a hORAS
	INT 21H

	XOR AX,AX
	MOV AL, DH              ; segundos para al
	mov Segundos, AX		; guarda segundos na variavel correspondente

	XOR AX,AX
	MOV AL, CL              ; Minutos para al
	mov Minutos, AX         ; guarda MINUTOS na variavel correspondente

	XOR AX,AX
	MOV AL, CH              ; Horas para al
	mov Horas,AX			; guarda HORAS na variavel correspondente

	POPF
	POP DX
	POP CX
	POP BX
	POP AX
	RET
LER_TEMPO   ENDP

;********************************************************************************
;********************************************************************************
; Imprime o tempo e a data no monitor

Trata_Horas PROC

    pushf
    push ax
    push bx
    push cx
    push dx

		call 	Ler_TEMPO				; Horas MINUTOS e segundos do Sistema

		mov	ax, segundos
		cmp	ax, Old_seg			; Verifica se os segundos mudaram desde a ultima leitura
		je	fim_horas			; Se a hora não mudou desde a última leitura sai.
		mov	Old_seg, ax			; Se segundos são diferentes actualiza informação do tempo

contasegundos:
    inc segundos1
    cmp segundos1, 58
      je contasegundos2
		mov bl, segundos1
		mov	strsegundos1, bl ; isto está bem
    goto_xy 68,1 ; canto superior direito
		mostra strsegundos1
    jmp fim_horas

contasegundos2:
    inc segundos2
  ;  cmp segundos2, 53
  ;    je contaminutos
    mov segundos1,47
    mov bl, segundos2
		mov	strsegundos2, bl ; isto está bem
    goto_xy 67,1 ; canto superior direito
		mostra strsegundos2
    jmp contasegundos

;contaminutos:
;    inc minutos1
;    mov segundos2, 47
;    mov bl, minutos1
;    mov strminutos1, bl
;    goto_xy 65,1
;    mostra strminutos1
;    jmp contasegundos





fim_horas:
		goto_xy	POSx,POSy			; Volta a colocar o cursor onde estava antes de actualizar as horas

    popf
    pop dx
    pop cx
    pop bx
    pop ax
		ret

Trata_Horas ENDP

teclanum  proc
		mov	ax, dseg
		mov	ds,ax
		mov	ax,0B800h
		mov	es,ax		; es é ponteiro para mem video

NOVON:
		mov		NUMDIG, 0			; inícia leitura de novo número
		mov		cx, 20
		XOR		BX,BX
LIMPA_N:
		mov		NUMERO[bx], ' '
		inc		bx
		loop 	LIMPA_N

		mov		al, 20
		mov		POSx,al
		mov		al, 10
		mov		POSy,al				; (POSx,POSy) é posição do cursor
		goto_xy	POSx,POSy
		;MOSTRA	NUM_SP

CICLO:	goto_xy	POSx,POSy


		call 	LE_TECLA		; lê uma nova tecla
		cmp		ah,1			; verifica se é tecla extendida
		je		ESTEND
		CMP 	AL,27			; caso seja tecla ESCAPE sai do programa
		JE		FIM
		CMP 	AL,13			; Pressionando ENTER vai para OKNUM
		JE		OKNUM
		CMP 	AL,8			; Teste BACK SPACE <- (apagar digito)
		JNE		NOBACK
		mov		bl,NUMDIG		; Se Pressionou BACK SPACE
		CMP		bl,0			; Verifica se não tem digitos no numero
		JE		NOBACK			; se não tem digitos continua então não apaga e salta para NOBACK

		dec		NUMDIG			; Retira um digito (BACK SPACE)
		dec		POSx			; Retira um digito

		xor		bx,bx
		mov		bl, NUMDIG
		mov		NUMERO[bx],' '	; Retira um digito
		goto_xy	POSx,POSy
		mov		ah,02h			; imprime SPACE na possicão do cursor
		mov		dl,32			; que equivale a colocar SPACE
		int		21H

NOBACK:
		CMP		AL,30h			; se for menor que tecla do ZERO
		jb		CICLO
		CMP		AL,39h			; ou se for maior que tecla do NOVE
		ja		CICLO			; é rejeitado e vai buscar nova tecla

		mov		bl,MAXDIG		; se atigido numero máximo de digitos ?
		CMP		bl,NUMDIG
		jbe		CICLO			; não aceita mais digitos
		xor		Bx, Bx			; caso contrario coloca digito na matriz NUMERO
		mov		bl, NUMDIG
		MOV		NUMERO[bx], al
		mov		ah,02h			; imprime digito
		mov		dl,al			; na possicão do cursor
		int		21H

		inc		POSx			; avança o cursor e
		inc		NUMDIG			; incrementa o numero de digitos

ESTEND:	jmp	CICLO			; Tecla extendida não é tratada neste programa

OKNUM:	goto_xy	20,16
		;MOSTRA	NUM_SP
		goto_xy	20,16
		xor		bx,bx
		mov		bl, NUMDIG
		inc 	bl
		MOV		NUMERO[bx], '$'
		;MOSTRA	NUMERO
		jmp		NOVON		; Vai ler novo numero

fim:	ret

teclanum ENDP

;APAGA_ECRAN	PROC  ; ------>LIMPA O ECRA<------
  ;push bx
	;push ax
	;push cx
  ;push si
  ;xor bx,bx
	;mov cx,24*80
	;mov bx,160
  ;mov si,bx
;apaga:
	;mov	al,' '
  ;mov byte ptr es:[bx],al
	;mov byte ptr es:[bx+1],7
	;inc bx
	;inc bx
	;inc si
	;loop apaga
	;pop si
	;pop cx
	;pop ax
	;pop bx
	;ret
;APAGA_ECRAN ENDP  ; ------>LIMPA O ECRA<------


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

LE_TECLA_CLOCK	PROC   ; ------>LE UMA TECLA CLOCK<------

  sem_tecla:
  		call Trata_Horas
  		MOV	AH,0BH
  		INT 21h
  		cmp AL,0
  		je	sem_tecla

  		goto_xy	POSx,POSy

  		MOV	AH,08H
  		INT	21H
  		MOV	AH,0
  		CMP	AL,0
  		JNE	SAI_TECLA
  		MOV	AH, 08H
  		INT	21H
  		MOV	AH,1

  sai_tecla:
    ret

LE_TECLA_CLOCK	ENDP   ; ------>LE UMA TECLA<------

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
	mov si, fnameptr
	mov oitoch, 1

	CICLO:
		mov chIn, 65 ;
		call	LE_TECLA
		cmp	ah, 1
			je	ciclo
		cmp al, 13		; enter--------------------------------------
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
		inc si
		mov fnameptr, si
		inc fnamen ; incrementar 1 elemento
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

	mov si, fnameptr ; vamos descrobrir onde começa o ultimo nome inserido -------------------
	dec si
	ciclo:
		dec si
		cmp fname[si], 0
			jne ciclo
	inc si

	lea	dx, fname[si]		; dx contem endereco do nome do ficheiro
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

CRIA_FICHEIRO ENDP  ; ----------->cria um ficheiro<---------------------



fnameptrToFich proc  ; ----------->passa o ptr para o ultimo elemento do array com os labirintos para um ficheiro<---------------------
	mov	ah, 3ch			; abrir ficheiro para escrita
	mov	cx, 00H			; tipo de ficheiro
	lea	dx, fnameptrfich		; dx contem endereco do nome do ficheiro
	int	21h				; abre efectivamente e AX vai ficar com o Handle do ficheiro
	jnc	escreve			; se não acontecer erro vai vamos escrever

	mov	ah, 09h			; Aconteceu erro na leitura
	lea	dx, mazenamesfichErr
	int	21h

	jmp	fim

escreve:
	mov	bx, ax			; para escrever BX deve conter o Handle
	mov	ah, 40h			; indica que vamos escrever

	lea	dx, fnameptr			; Vamos escrever o que estiver no endereço DX
	mov	cx, 2			; vamos escrever multiplos bytes duma vez só
	int	21h				; faz a escrita
	jnc	close				; se não acontecer erro fecha o ficheiro

	mov	ah, 09h
	lea	dx, msgErrorWrite
	int	21h
close:
	mov	ah,3eh			; indica que vamos fechar
	int	21h				; fecha mesmo
	jnc	fim				; se não acontecer erro termina

	mov	ah, 09h
	lea	dx, msgErrorClose
	int	21h
fim:
	ret

fnameptrToFich endp  ; ----------->passa o ptr para o ultimo elemento do array com os labirintos para um ficheiro<---------------------



fnamenToFich proc   ; ----------->passa o nr de elementos do array com os labirintos para um ficheiro<---------------------
	mov	ah, 3ch			; abrir ficheiro para escrita
	mov	cx, 00H			; tipo de ficheiro
	lea	dx, fnamenfich		; dx contem endereco do nome do ficheiro
	int	21h				; abre efectivamente e AX vai ficar com o Handle do ficheiro
	jnc	escreve			; se não acontecer erro vai vamos escrever

	mov	ah, 09h			; Aconteceu erro na leitura
	lea	dx, mazenamesfichErr
	int	21h

	jmp	fim

escreve:
	mov	bx, ax			; para escrever BX deve conter o Handle
	mov	ah, 40h			; indica que vamos escrever

	lea	dx, fnamen			; Vamos escrever o que estiver no endereço DX
	mov	cx, 1			; vamos escrever multiplos bytes duma vez só
	int	21h				; faz a escrita
	jnc	close				; se não acontecer erro fecha o ficheiro

	mov	ah, 09h
	lea	dx, msgErrorWrite
	int	21h
close:
	mov	ah,3eh			; indica que vamos fechar
	int	21h				; fecha mesmo
	jnc	fim				; se não acontecer erro termina

	mov	ah, 09h
	lea	dx, msgErrorClose
	int	21h
fim:
	ret

fnamenToFich endp  ; ----------->passa o nr de elementos do array com os labirintos para um ficheiro<---------------------




fnameToFich proc   ; ----------->passa o array com os labirintos para um ficheiro<---------------------
	mov	ah, 3ch			; abrir ficheiro para escrita
	mov	cx, 00H			; tipo de ficheiro
	lea	dx, mazenamesfich		; dx contem endereco do nome do ficheiro
	int	21h				; abre efectivamente e AX vai ficar com o Handle do ficheiro
	jnc	escreve			; se não acontecer erro vai vamos escrever

	mov	ah, 09h			; Aconteceu erro na leitura
	lea	dx, mazenamesfichErr
	int	21h

	jmp	fim

escreve:
	mov	bx, ax			; para escrever BX deve conter o Handle
	mov	ah, 40h			; indica que vamos escrever

	lea	dx, fname			; Vamos escrever o que estiver no endereço DX
	mov	cx, 390			; vamos escrever multiplos bytes duma vez só
	int	21h				; faz a escrita
	jnc	close				; se não acontecer erro fecha o ficheiro

	mov	ah, 09h
	lea	dx, msgErrorWrite
	int	21h
close:
	mov	ah,3eh			; indica que vamos fechar
	int	21h				; fecha mesmo
	jnc	fim				; se não acontecer erro termina

	mov	ah, 09h
	lea	dx, msgErrorClose
	int	21h
fim:
	ret

fnameToFich endp	; ----------->passa o array com os labirintos para um ficheiro<---------------------



fichTofname proc ; ----------->passa o array com os labirintos do ficheiro para o array<---------------------
;abre ficheiro

        mov     ah,3dh			; vamos abrir ficheiro para leitura
        mov     al,0			; tipo de ficheiro
        lea     dx, mazenamesfich		; nome do ficheiro
        int     21h			; abre para leitura
        jc      erro_abrir		; pode aconter erro a abrir o ficheiro
        mov     HandleFich,ax		; ax devolve o Handle para o ficheiro
        jmp     ler		; depois de abero vamos ler o ficheiro

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai

ler:
        mov     ah,3fh			; indica que vai ser lido um ficheiro
        mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto
        mov     cx, 390			; numero de bytes a ler
        lea     dx, fname		; vai ler para o local de memoria apontado por dx (car_fich)
        int     21h				; faz efectivamente a leitura
		jc	    erro_ler		; se carry é porque aconteceu um erro
        mov     ah,3eh  ; vamos fechar o ficheiro
        mov     bx,HandleFich
        int     21h
        jnc     sai
		mov     ah,09h			; o ficheiro pode não fechar correctamente
        lea     dx,Erro_Close
        Int     21h

		erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

sai:
        ret
fichTofname endp ; ----------->passa o array com os labirintos do ficheiro para o array<---------------------



fichTofnamen proc ; ----------->passa o nr de elementos do array com os nomes dos mazes para o fnamen<---------------------
;abre ficheiro

        mov     ah,3dh			; vamos abrir ficheiro para leitura
        mov     al,0			; tipo de ficheiro
        lea     dx, fnamenfich		; nome do ficheiro
        int     21h			; abre para leitura
        jc      erro_abrir		; pode aconter erro a abrir o ficheiro
        mov     HandleFich,ax		; ax devolve o Handle para o ficheiro
        jmp     ler		; depois de abero vamos ler o ficheiro

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai

ler:
        mov     ah,3fh			; indica que vai ser lido um ficheiro
        mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto
        mov     cx, 1			; numero de bytes a ler
        lea     dx, fnamen		; vai ler para o local de memoria apontado por dx (car_fich)
        int     21h				; faz efectivamente a leitura
			jc	    erro_ler		; se carry é porque aconteceu um erro
        mov     ah,3eh  ; vamos fechar o ficheiro
        mov     bx,HandleFich
        int     21h
			jnc     sai
		mov     ah,09h			; o ficheiro pode não fechar correctamente
        lea     dx,Erro_Close
        Int     21h

		erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

sai:
        ret

fichTofnamen endp ; ----------->passa o nr de elementos do array com os nomes dos mazes para o fnamen<---------------------




fichTofnameptr proc ; ----------->passa o ptr para o ultimo elemento do array com os nomes dos mazes para o fnamen<---------------------
;abre ficheiro

        mov     ah,3dh			; vamos abrir ficheiro para leitura
        mov     al,0			; tipo de ficheiro
        lea     dx, fnameptrfich		; nome do ficheiro
        int     21h			; abre para leitura
        jc      erro_abrir		; pode aconter erro a abrir o ficheiro
        mov     HandleFich,ax		; ax devolve o Handle para o ficheiro
        jmp     ler		; depois de abero vamos ler o ficheiro

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai

ler:
        mov     ah,3fh			; indica que vai ser lido um ficheiro
        mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto
        mov     cx, 2			; numero de bytes a ler
        lea     dx, fnameptr		; vai ler para o local de memoria apontado por dx (car_fich)
        int     21h				; faz efectivamente a leitura
			jc	    erro_ler		; se carry é porque aconteceu um erro
        mov     ah,3eh  ; vamos fechar o ficheiro
        mov     bx,HandleFich
        int     21h
			jnc     sai
		mov     ah,09h			; o ficheiro pode não fechar correctamente
        lea     dx,Erro_Close
        Int     21h

		erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

sai:
        ret

fichTofnameptr endp ; ----------->passa o ptr para o ultimo elemento do array com os nomes dos mazes para o fnamen<---------------------



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

	call GUARDA_ECRA

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



menuEditMaze proc ;##########################----Editar LABIRINTO---####################################
	mov		ax,0B800h
	mov		es,ax
	call apaga_ecran
	mov posy, 2
	mov posx, 10
	goto_xy	POSx,POSy
	xor si, si ;si=0
	mov ax, fnameptr
	mov lastzero, ax
	dec lastzero
	titulo:
		cmp string5[si], 0
			je checkelements
		mov ah, 02h
		mov dl, string5[si]
		int 21h
		inc si
		jmp titulo

	checkelements:
		cmp fnamen, 0
			jne mazesinic
		mov posy, 2
		mov posx, 20
		goto_xy	POSx,POSy
		jmp lerop

	mazesinic:
		mov posy, 3
		mov posx, 20
		goto_xy	POSx,POSy
		mov ah, 02h
		mov dl, 91 ;[
		int 21h
		mov ah, 02h
		mov dl, 32 ; espaco
		int 21h
		mov ah, 02h
		mov dl, 93 ;]
		int 21h
		xor si, si ;si=0
	mazes:

		cmp fname[si], 0
			jne notnline
		cmp lastzero, si
			je lerOp
		inc posy
		goto_xy	POSx,POSy
		inc si
		mov ah, 02h
		mov dl, 91 ;[
		int 21h
		mov ah, 02h
		mov dl, 32 ; espaco
		int 21h
		mov ah, 02h
		mov dl, 93 ;]
		int 21h
		jmp mazes
		notnline:
			mov ah, 02h
			mov dl, fname[si]
			int 21h
			inc si
			jmp mazes

	lerOp:
		inc posy
		goto_xy	POSx,POSy
		mov ah, 02h
		mov dl, 91 ;[
		int 21h
		mov ah, 02h
		mov dl, 32 ; espaco
		int 21h
		mov ah, 02h
		mov dl, 93 ;]
		int 21h
		mov ah, 02h
		mov dl, 66 ; b
		int 21h
		mov ah, 02h
		mov dl, 65 ; a
		int 21h
		mov ah, 02h
		mov dl, 67 ; c
		int 21h
		mov ah, 02h
		mov dl, 75 ; k
		int 21h
		mov posy, 3
		mov posx, 21  ;meter o x dentro do []
		goto_xy	POSx,POSy

		CICLO:
			mov al, fnamen
			add al, 4  ;
			cmp posy, al
				jne snake
			mov posy, 3 ;posicao inicial

			snake:					;manter o 'x' dentro dos limites
				cmp posy, 2
					jne fimsnake
				dec al
				mov posy, al

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
				cmp al, 13		 ;enter--------------------------------------
					jne estend
				mov al, fnamen
				add al, 3	; +3 onde começa
				cmp posy, al   ; se o 'x' estiver no back
					jne qualmaze
				ret
				qualmaze:
						mov al, posy
						mov fnameditop, al
						sub fnameditop, 2  ;-2 porque o 0 é o default
						jmp guessMaze

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


	guessMaze:
		;descobrir fnamedit -------------------
		mov cx, 13
		xor si, si
		xor di, di
	inicializa:  ;colocar fnamedit toda a zeros
		mov fnamedit[si], 0
		inc si
			loop inicializa

		mov p, 0 ;p e um ponteiro
		xor si, si
	pset:  ;vamos descobrir onde esta o nome do ficheiro correspondente á opçao
		mov al, fnameditop
		dec al ;pq 0 é o mazedefault
		cmp p, al ;p é o n de zeros
			je strcpy
		srchzero:
			cmp fname[si], 0
				je incp
			inc si
			jmp srchzero
		incp:
			inc p
			inc si
			jmp pset
	strcpy:
		cmp fname[si], 0
			je openmaze
		mov al, fname[si]
		mov fnamedit[di], al
		inc si
		inc di
		jmp strcpy

	openmaze:
		; imprime ficheiro-----------
				;abre ficheiro

		  mov     ah,3dh			; vamos abrir ficheiro para leitura
		  mov     al,0			; tipo de ficheiro
		  lea     dx, fnamedit			; nome do ficheiro
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

		 ;--------------------

	getchar:
		call 	le_tecla
		cmp 	al, 13	 ; enter
			ret
	jmp getchar

menuEditMaze endp ;##########################----Editar LABIRINTO---####################################




menuLoadUmaze proc   ;##########################----carregar labirinto---####################################

	call apaga_ecran
	mov posy, 2
	mov posx, 3
	goto_xy	POSx,POSy
	xor si, si ;si=0
	mov ax, fnameptr
	mov lastzero, ax
	dec lastzero
	titulo:
		cmp string2[si], 0
			je checkelements
		mov ah, 02h
		mov dl, string2[si]
		int 21h
		inc si
		jmp titulo

	checkelements:
		cmp fnamen, 0
			jne mazesinic
		mov posy, 2
		mov posx, 20
		goto_xy	POSx,POSy
		jmp lerop

	mazesinic:
		mov posy, 3
		mov posx, 20
		goto_xy	POSx,POSy
		mov ah, 02h
		mov dl, 91 ;[
		int 21h
		mov ah, 02h
		mov dl, 32 ; espaco
		int 21h
		mov ah, 02h
		mov dl, 93 ;]
		int 21h
		xor si, si ;si=0
	mazes:

		cmp fname[si], 0
			jne notnline
		cmp lastzero, si
			je lerOp
		inc posy
		goto_xy	POSx,POSy
		inc si
		mov ah, 02h
		mov dl, 91 ;[
		int 21h
		mov ah, 02h
		mov dl, 32 ; espaco
		int 21h
		mov ah, 02h
		mov dl, 93 ;]
		int 21h
		jmp mazes
		notnline:
			mov ah, 02h
			mov dl, fname[si]
			int 21h
			inc si
			jmp mazes

	lerOp:
		inc posy
		goto_xy	POSx,POSy
		mov ah, 02h
		mov dl, 91 ;[
		int 21h
		mov ah, 02h
		mov dl, 32 ; espaco
		int 21h
		mov ah, 02h
		mov dl, 93 ;]
		int 21h
		mov ah, 02h
		mov dl, 66 ; b
		int 21h
		mov ah, 02h
		mov dl, 65 ; a
		int 21h
		mov ah, 02h
		mov dl, 67 ; c
		int 21h
		mov ah, 02h
		mov dl, 75 ; k
		int 21h
		mov posy, 3
		mov posx, 21  ;meter o x dentro do []
		goto_xy	POSx,POSy

		CICLO:
			mov al, fnamen
			add al, 4  ;
			cmp posy, al
				jne snake
			mov posy, 3 ;posicao inicial

			snake:					;manter o 'x' dentro dos limites
				cmp posy, 2
					jne fimsnake
				dec al
				mov posy, al

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
				cmp al, 13		 ;enter--------------------------------------
					jne estend
				mov al, fnamen
				add al, 3	; +3 onde começa
				cmp posy, al   ; se o 'x' estiver no back
					jne qualmaze
				ret
				qualmaze:
						mov al, posy
						mov fnameop, al
						sub fnameop, 2  ;-2 porque o 0 é o default
						ret

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



menuLoadUmaze endp   ;##########################----carregar labirinto---####################################



menuDeleteMaze proc   ;##########################----apagar labirintos---####################################
	inicio:
	call apaga_ecran
	mov posy, 2
	mov posx, 8
	goto_xy	POSx,POSy
	xor si, si ;si=0
	mov ax, fnameptr
	mov lastzero, ax
	dec lastzero

	titulo:
		cmp string4[si], 0
			je checkelements
		mov ah, 02h
		mov dl, string4[si]
		int 21h
		inc si
		jmp titulo

	checkelements:
	cmp fnamen, 0
		jne mazesinic
	mov posy, 2
	mov posx, 20
	goto_xy	POSx,POSy
	jmp lerop

	mazesinic:
		mov posy, 3
		mov posx, 20
		goto_xy	POSx,POSy
		mov ah, 02h
		mov dl, 91 ;[
		int 21h
		mov ah, 02h
		mov dl, 32 ; espaco
		int 21h
		mov ah, 02h
		mov dl, 93 ;]
		int 21h
		xor si, si ;si=0
	mazes:

		cmp fname[si], 0
			jne notnline
		cmp lastzero, si
			je lerOp
		inc posy
		goto_xy	POSx,POSy
		inc si
		mov ah, 02h
		mov dl, 91 ;[
		int 21h
		mov ah, 02h
		mov dl, 32 ; espaco
		int 21h
		mov ah, 02h
		mov dl, 93 ;]
		int 21h
		jmp mazes
		notnline:
			mov ah, 02h
			mov dl, fname[si]
			int 21h
			inc si
			jmp mazes

	lerOp:
		inc posy
		goto_xy	POSx,POSy
		mov ah, 02h
		mov dl, 91 ;[
		int 21h
		mov ah, 02h
		mov dl, 32 ; espaco
		int 21h
		mov ah, 02h
		mov dl, 93 ;]
		int 21h
		mov ah, 02h
		mov dl, 66 ; b
		int 21h
		mov ah, 02h
		mov dl, 65 ; a
		int 21h
		mov ah, 02h
		mov dl, 67 ; c
		int 21h
		mov ah, 02h
		mov dl, 75 ; k
		int 21h
		mov posy, 3
		mov posx, 21  ;meter o x dentro do []
		goto_xy	POSx,POSy


		CICLO:
			mov al, fnamen
			add al, 4  ;
			cmp posy, al
				jne snake
			mov posy, 3 ;posicao inicial

			snake:					;manter o 'x' dentro dos limites
				cmp posy, 2
					jne fimsnake
				dec al
				mov posy, al

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
				cmp al, 13		 ;enter--------------------------------------
					jne estend
				mov al, fnamen
				add al, 3	; +3 onde começa
				cmp posy, al   ; se o 'x' estiver no back
					jne qualmaze
				ret

				qualmaze:

					mov zeros, 0
					mov al, posy
					sub al, 3
					xor si, si
					xor di, di

					incsidi:
						cmp zeros, al
							je incsi
						inc si
						inc di
						cmp fname[si], 0
							jne notzero
						inc zeros
						notzero:
						jmp incsidi

					incsi:
						cmp al, 0  ;caso especial, se for o primeiro elemento do vetor
							je first
						inc di
						mov ah, fnamen
						dec ah
						cmp al, ah  ;caso especial, se for o ultimo elemento do vetor
							je last
						first:
							cmp fnamen, 1  ;caso especial, se for o unico elemento do vetor
								je last
							inc si
							cmp fname[si], 0
								jne first
						inc si
					strcpy:
						mov ah, fname[si]
						mov fname[di], ah
						inc si
						inc di
						cmp si, fnameptr
							jne strcpy
					last:
						mov fnameptr, di
						dec fnamen
						jmp inicio


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


menuDeleteMaze endp   ;##########################----apagar labirintos---####################################



MENUCONFIG PROC  ;##########################----MENU DE CONFIGURACAO---####################################
inicio:
	mov posx, 25 ;colocar o x no sitio onde vai aparece os menus
	mov posy, 6
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
    jmp     fim

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

;**************************************
CICLO:
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
	cmp al, 13		 ;enter
	jne estend
	cmp posy, 11   ; se o 'x' estiver no back
	jne createmaze
	mov posx, 33
	mov posy, 18
	ret

createmaze:
  cmp posy, 8  ; se o 'x' estiver no create maze
	jne loadUserMaze
  call menuDesenhar ; Call MenuDesenhar PROC
  jmp inicio

loadUserMaze:
	cmp posy, 7 ;se o x estiver no load user maze
		jne loadDefaultMaze
	call menuLoadUmaze
	jmp inicio

loadDefaultMaze:
	cmp posy, 6 ;se o x estiver no load default maze
		jne deletemaze
	mov fnameop, 0
	call apaga_ecran
	mov posy, 2
	mov posx, 4
	goto_xy	POSx,POSy
	xor si, si
	puts:
		cmp string3[si], 0
			je getchar
		mov ah, 02h
		mov dl, string3[si]
		int 21h
		inc si
		jmp puts
	getchar:
		call 	le_tecla
		cmp 	al, 13	 ; enter
			je		inicio
	jmp getchar

deletemaze:
	cmp posy, 10 ;se o x estiver no delete maze
		jne editmaze
	call menudeletemaze
	jmp inicio

editmaze:
	call menueditmaze
	jmp inicio

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



  ; ate aqui esta igual ao MENU

	;mov cx, 13
	;xor si, si
	;inicializa:  ;colocar fnameopen toda a zeros
		;mov fnameopen[si], 0
		;inc si
		;loop inicializa

	;mov p, 0
	;xor si, si
	;cmp fnameop, 0
		;jne notdefault  ;vamos descobrir onde esta o nome do ficheiro correspondente á opçao
	;strcpy:
		;cmp fichdefaultmaze, 0
			;je openmaze
		;mov al, fichdefaultmaze[si]
		;mov fnameopen[si], al
		;inc si
		;jmp strcpy
	;notdefault:
		;mov al, fnameop
		;dec al ;pq 0 é o mazedefault
		;cmp p, al ;pe é o n de zeros
			;je prepstrcpy2
		;srchzero:
			;cmp fname[si], 0
				;je incp
			;inc si
			;jmp srchzero
		;incp:
			;inc p
			;inc si
			;jmp notdefault
	;prepstrcpy2:
		;xor di, di
	;strcpy2:
		;cmp fname[si], 0
			;je openmaze
		;mov al, fname[si]
		;mov fnameopen[di], al
		;inc si
		;inc di
		;jmp strcpy2

openmaze:
  mov     ah,3dh			; vamos abrir ficheiro para leitura
  mov     al,0			; tipo de ficheiro
  ;lea     dx, fnameopen			; nome do ficheiro
  lea     dx, FichDefaultMaze
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

  goto_xy	MazeX,MazeY	; Vai para nova posi��o
  mov 		ah, 08h	; Guarda o Caracter que est� na posi��o do Cursor
  mov		bh,0		; numero da p�gina
  int		10h
  mov		Car, al	; Guarda o Caracter que est� na posi��o do Cursor
  mov		Cor, ah	; Guarda a cor que est� na posi��o do Cursor

  ; monta o cornometro

  goto_xy 68,1
  mostra strzero

  goto_xy 67,1
  mostra strzero

  goto_xy 66,1
  mostra strdoispontos

  goto_xy 65,1
  mostra strzero

  goto_xy 64,1
  mostra strzero


CICLO:

  goto_xy	POSxa,POSya	; Vai para a posi��o anterior do cursor
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

IMPRIME:

  mov		ah, 02h
  mov		dl, 233	; Coloca AVATAR
  int		21H
  goto_xy	MazeX,MazeY	; Vai para posi��o do cursor

  mov		al, MazeX	; Guarda a posi��o do cursor
  mov		POSxa, al
  mov		al, MazeY	; Guarda a posi��o do cursor
  mov 		POSya, al

LER_SETA:
  call 		LE_TECLA_CLOCK
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
  ;call menu
  ret

PAREDEBAIXO:
  dec MazeY
  ;call menu
  ret

PAREDEESQUERDA:
  inc MazeX
  ;call menu
  ret

PAREDEDIREITA:
  dec MazeX
  ;call menu
  ret

fim:
	mov		ah,4CH
	int		21H

PLAY ENDP ;##########################----INICIA O JOGO---#####################################

MENU PROC ;##########################----MENU PRINCIPAL---####################################
  inicio:
  	mov		ax,0B800h           ; Apaga
  	mov		es,ax				;	o
  	call		apaga_ecran		; Ecran

  	mov POSy,			18
  	mov POSx,			33
  	goto_xy posx, posy

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
    jmp     fim

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
  	call 	LE_TECLA
  	cmp		ah, 1
  	je		ESTEND
  	cmp 	al, 27	; ESCAPE
		jne lerop
	call fnameToFich
	call fnamenToFich
	call fnameptrToFich
	jmp fim
	lerop:
  ;*************************************
  ; 						ler opcao

  	cmp al, 13					;enter
  		jne estend
  	cmp posy, 18 ; se o 'x' estiver no play
  		jne exit
  	call play
  	jmp inicio
  	exit:
  		cmp posy, 21  ; se o 'x' estiver no exit
  			jne mazeconfig
		call fnameToFich
		call fnamenToFich
		call fnameptrToFich
		jmp fim
		jmp fim
	mazeconfig:
  	cmp posy, 20 ; se o 'x' estiver no maze config
  		jne estend
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
	call fichTofname
	call fichTofnamen
	call fichTofnameptr
	call MENU
  ;;call teclanum

MAIN  ENDP ;###############################----MAIN---########################################
CSEG ENDS
END MAIN
