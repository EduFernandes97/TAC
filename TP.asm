
.8086
.model small
.stack 2048

dseg	segment para public 'data'
	MenuPrincipal	db		'|MENU:| 1 - Jogar | 2 - Top 10 | 3 - Configuracao do labirinto | 0 - Sair| Opcao(0 - 3): ',0
	MenuConfigMaze	db		'|MENU Configuracao do Maze:| 1 - Carregar Labirinto Por Omissao | 2 - Carregar do ficheiro MAZE.TXT| 3 - Criar/Editar | 0 - Sair| Opcao(0 - 3): ',0
	
	Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
	Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
	Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
	Fich         	db      'MAZE.TXT',0
	
	HandleFich      dw      0
	car_fich        db      ?
	car_fich2        dw      ?
	flagFich		db		1
	
	contaColuna		db		0
	contaLinha		db		0
	POSx			db		?
	POSy			db		19
	POSxa			db		?
	POSya			db		19	
	Car				db		32	; Guarda um caracter do Ecran 
	CarN				db		32	; Guarda um caracter do Ecran 
	Cor				db		7	; Guarda os atributos de cor do caracter
	
	Horas			dw		0				; Vai guardar a HORA actual
	Minutos			dw		0				; Vai guardar os minutos actuais
	Segundos			dw		0				; Vai guardar os segundos actuais
	FichTOP			db		'TOP.TXT',0
	msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$"
	msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$"
	msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$"
	stringTempo			db 		'              ';9 digitos para tempo
	
	FlagCompararTempo	dw		0				; Vai guardar a HORA actual
	
	auxConfigMaze	db		1
	
	defaultMaze		db		'000000X00000000000000000000000000000000|'
					db		'000000100000000000000000000000000000000|'
					db		'000000100000000000000000000000000000000|'
					db		'000000100000000000000000000000000000000|'
					db		'000001100000000000000000000000000000000|'
					db		'000011000000000000000000000000000000000|'
					db		'000010000000000000000000000000000000000|'
					db		'000010000000000000000000000000000000000|'
					db		'000010000000000000000000000000000000000|'
					db		'000010000000000000000000000000000000000|'
					db		'000010000000000000000000000000000000000|'
					db		'000010000000000000000000000000000000000|'
					db		'000010000000000000000000000000000000000|'
					db		'000010000000000000000000000000000000000|'
					db		'000010000000000000000000000000000000000|'
					db		'000010000000000000000000000000000000000|'
					db		'000010000000000000000000000000000000000|'
					db		'000010000000000000000000000000000000000|'
					db		'0000I0000000000000000000000000000000000|'
					db		'000000000000000000000000000000000000000|',0
					
					
	bufferTop		db		'                                             ';12 bytes para tempo + 10 bytes para nome + 1 para fim
	NomeUser		db		'          '
					
	
	
dseg	ends

PILHA	SEGMENT PARA STACK 'STACK'
		db 2048 dup(?)
PILHA	ENDS

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg

goto_xy	macro		POSx,POSy
	mov		ah,02h
	mov		bh,0		; numero da página
	mov		dl,POSx
	mov		dh,POSy
	int		10h
endm

APAGA_ECRAN	PROC
		PUSH BX
		PUSH AX
		PUSH CX
		PUSH SI
		XOR	BX,BX
		MOV	CX,100*100
		mov bx,160
		MOV SI,BX
APAGA:	
		MOV	AL,' '
		MOV	BYTE PTR ES:[BX],AL
		MOV	BYTE PTR ES:[BX+1],7
		INC	BX
		INC BX
		INC SI
		LOOP	APAGA
		POP SI
		POP CX
		POP AX
		POP BX
		goto_xy 0, 0
		RET
APAGA_ECRAN	ENDP

GUARDA_TOP proc
	mov	ah, 3ch			; abrir ficheiro para escrita 
	mov	cx, 00H			; tipo de ficheiro
	lea	dx, FichTOP			; dx contem endereco do nome do ficheiro 
	int	21h				; abre efectivamente e AX vai ficar com o Handle do ficheiro 
	jnc	escreve			; se não acontecer erro vai vamos escrever
	
	mov	ah, 09h			; Aconteceu erro na leitura
	lea	dx, msgErrorCreate ;//mete endereco da msg em dx
	int	21h ; //carater lido em AL
	
	ret

escreve:
	mov	bx, ax			; para escrever BX deve conter o Handle 
	mov	ah, 40h			; indica que vamos escrever 
    	
	
		
	lea	dx, bufferTop			; Vamos escrever o que estiver no endereço DX
	mov	cx, 50		; vamos escrever multiplos bytes duma vez só
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

fim:	ret
GUARDA_TOP endp


MostraMenu	proc
	CALL APAGA_ECRAN
	xor di, di
	
	CicloMostraMenu:
		mov ah, MenuPrincipal[di]
		
		
		cmp ah, 0
		je FimMostraMenu; if (fim de MenuPrincipal)
		;else
		
		
		cmp ah, '|'
		je NovaLinhaMostraMenu
		
		mov     ah,02h			; coloca o caracter no ecran
		mov	    dl,MenuPrincipal[di]		; este é o caracter a enviar para o ecran
		int	    21h	
		inc di
	jmp CicloMostraMenu
	
	NovaLinhaMostraMenu:
		mov dl,10
		mov ah,2h
		int 21h
		inc di
		jmp CicloMostraMenu
		
	FimMostraMenu:	
	ret
MostraMenu	endp

Ler_TEMPO PROC	
 
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	PUSHF
	
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
	mov Horas, AX			; guarda HORAS na variavel correspondente
	
	; mov     ah,02h			; coloca o caracter no ecran
	; mov	    dl,al		; este é o caracter a enviar para o ecran
	; int	    21h			; imprime no ecran
	
	; mov ah, 01h
	; int	21h
	
	; mov     ah,02h			; coloca o caracter no ecran
	; mov	    dl,ah		; este é o caracter a enviar para o ecran
	; int	    21h			; imprime no ecran
	
	; mov ah, 01h
	; int	21h
	
	;TODO O QUE VEM PARA BAIXO PASSAR TEMPO PARA STRING
	
	
	POPF
	POP DX
	POP CX
	POP BX
	POP AX	
	RET 
Ler_TEMPO   ENDP 

CALCULA_TEMPO PROC	
 
	
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	PUSHF
	
	MOV AH, 2CH             ; Buscar a hORAS
	INT 21H                 
	
	XOR AX,AX
	MOV AL, DH              ; segundos para al
	sub ax, Segundos		; guarda segundos na variavel correspondente7
	mov Segundos,ax
	
	XOR AX,AX
	MOV AL, CL              ; Minutos para al
	sub AX, Minutos	        ; guarda MINUTOS na variavel correspondente
	mov Minutos,ax
	
	XOR AX,AX
	MOV AL, CH              ; Horas para al
	sub AX, Horas			; guarda HORAS na variavel correspondente
	mov Horas,ax
	
	
	; ---------TEMPO PARA STRING----------------
	
	mov 	ax,Horas
	MOV		bl, 10     
	div 	bl
	add 	al, 30h				; Caracter Correspondente às dezenas
	add		ah,	30h				; Caracter Correspondente às unidades
	MOV 	stringTempo[0],al			; 
	MOV 	stringTempo[1],ah
	MOV 	stringTempo[2],'h'
		
	
	mov 	ax,Minutos
	MOV		bl, 10     
	div 	bl
	add 	al, 30h				; Caracter Correspondente às dezenas
	add		ah,	30h				; Caracter Correspondente às unidades
	MOV 	stringTempo[3],al			; 
	MOV 	stringTempo[4],ah
	MOV 	stringTempo[5],'m'			
	
	mov 	ax,Segundos
	MOV		bl, 10     
	div 	bl
	add 	al, 30h				; Caracter Correspondente às dezenas
	add		ah,	30h				; Caracter Correspondente às unidades
	MOV 	stringTempo[6],al			; 
	MOV 	stringTempo[7],ah
	MOV 	stringTempo[8],'s'		
	MOV 	stringTempo[9],'$'
	
	; lea dx, stringTempo
	; mov ah, 09h
	; int 21h
	
	; -----------------------------------
	
	
	POPF
	POP DX
	POP CX
	POP BX
	POP AX	
	
	RET 
CALCULA_TEMPO   ENDP 

MostraMazeFich proc
	
	mov dl,10
	mov ah,2h
	int 21h
	
	mov     ah,3dh			; vamos abrir ficheiro para leitura 
	mov     al,0			; tipo de ficheiro	
	lea     dx,Fich			; nome do ficheiro
	int     21h			; abre para leitura 
	jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
	mov     HandleFich,ax		; ax devolve o Handle para o ficheiro 
	jmp     ler_ciclo		; depois de abero vamos ler o ficheiro 

	erro_abrir:
		mov     ah,09h
		lea     dx,Erro_Open
		int     21h
		mov 	flagFich, 0
		ret
	mov contaColuna, 0
	ler_ciclo:
		mov     ah,3fh			; indica que vai ser lido um ficheiro 
		mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto 
		mov     cx,1			; numero de bytes a ler 
		lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
		int     21h				; faz efectivamente a leitura
		jc	    erro_ler		; se carry é porque aconteceu um erro
		cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
		je	    fecha_ficheiro	; se EOF fecha o ficheiro 
		
		;alterar os 0 e 1...
		
		cmp car_fich, '0'
		je PAREDE
		cmp car_fich, '1'
		JE NPAREDE
		cmp car_fich, '|'
		JE NOVALINHA
		cmp car_fich, 'X'
		JE FIM_MAZE
		cmp car_fich, 'I'
		JE AVATAR
	PAREDE:
		mov car_fich, 219
		JMP MOSTRA
	NPAREDE:
		mov car_fich, 32
		JMP MOSTRA
	NOVALINHA:
		mov car_fich, 10
		mov contaColuna, 0
		inc contaLinha
		JMP MOSTRA
	FIM_MAZE:
		mov car_fich, 'X'
		JMP MOSTRA
	AVATAR:	
		mov car_fich, 32
		mov ah, contaColuna
		sub ah, 1
		mov POSx, ah
		mov POSxA, ah
		
		JMP MOSTRA
	MOSTRA:	
		mov     ah,02h			; coloca o caracter no ecran
		mov	    dl,car_fich		; este é o caracter a enviar para o ecran
		int	    21h			; imprime no ecran
		inc 	contaColuna
		jmp	    ler_ciclo		; continua a ler o ficheiro

	erro_ler:
		mov     ah,09h
		lea     dx,Erro_Ler_Msg
		int     21h

	fecha_ficheiro:					; vamos fechar o ficheiro 
		mov     ah,3eh
		mov     bx,HandleFich
		int     21h
		; mov 	flagFich, 0
		ret

		mov     ah,09h			; o ficheiro pode não fechar correctamente
		lea     dx,Erro_Close
		Int     21h
	ret
MostraMazeFich endp

MostraMaze proc
	
	mov dl,10
	mov ah,2h
	int 21h
	
	mov contaColuna, 0
	xor si, si
	ler_ciclo:
		mov ah, defaultMaze[si]
		mov car_fich, ah
		inc si
		
		cmp car_fich, 0
		je FIM
		cmp car_fich, '0'
		je PAREDE
		cmp car_fich, '1'
		JE NPAREDE
		cmp car_fich, '|'
		JE NOVALINHA
		cmp car_fich, 'X'
		JE FIM_MAZE
		cmp car_fich, 'I'
		JE AVATAR
	PAREDE:
		mov car_fich, 219
		JMP MOSTRA
	NPAREDE:
		mov car_fich, 32
		JMP MOSTRA
	NOVALINHA:
		mov car_fich, 10
		mov contaColuna, 0
		inc contaLinha
		JMP MOSTRA
	FIM_MAZE:
		mov car_fich, 'X'
		JMP MOSTRA
	AVATAR:	
		mov car_fich, 32
		mov ah, contaColuna
		sub ah, 1
		mov POSx, ah
		mov POSxA, ah
		
		JMP MOSTRA
	MOSTRA:	
		mov     ah,02h			; coloca o caracter no ecran
		mov	    dl,car_fich		; este é o caracter a enviar para o ecran
		int	    21h			; imprime no ecran
		inc 	contaColuna
		jmp	    ler_ciclo		; continua a ler o ficheiro
FIM:
	ret
MostraMaze endp

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


JOGO proc
	
	goto_xy	POSx,POSy	; Vai para nova possição
	mov 	ah, 08h	; Guarda o Caracter que está na posição do Cursor
	mov		bh,0		; numero da página
	int		10h			
	mov		Car, al	; Guarda o Caracter que está na posição do Cursor
	mov		Cor, ah	; Guarda a cor que está na posição do Cursor	
	

	CICLO:
		goto_xy	POSxa,POSya	; Vai para a posição anterior do cursor
		mov		ah, 02h
		mov		dl, Car	; Repoe Caracter guardado 
		int		21H		
		
		goto_xy	POSx,POSy	; Vai para nova possição
		mov 	ah, 08h
		mov		bh,0		; numero da página
		int		10h		
		mov		Car, al	; Guarda o Caracter que está na posição do Cursor
		mov		Cor, ah	; Guarda a cor que está na posição do Cursor
		
		cmp al, 'X' 
		je FIM
		; goto_xy	78,0		; Mostra o caractr que estava na posição do AVATAR
		; mov		ah, 02h	; IMPRIME caracter da posição no canto
		; mov		dl, Car	
		; int		21H			
	
		goto_xy	POSx,POSy	; Vai para posição do cursor
	IMPRIME:
		mov		ah, 02h
		mov		dl, 190	; Coloca AVATAR
		int		21H	
		goto_xy	POSx,POSy	; Vai para posição do cursor
		
		mov		al, POSx	; Guarda a posição do cursor
		mov		POSxa, al
		mov		al, POSy	; Guarda a posição do cursor
		mov 	POSya, al
		
	LER_SETA:
		call 		LE_TECLA
		cmp		ah, 1
		je		FRENTE
		CMP 		AL, 27	; ESCAPE
		ret
		jmp		LER_SETA
			
	FRENTE:
		cmp 	al,48h
		jne		BAIXO
		
		dec		POSy		;cima
		
		goto_xy POSx, POSy
		mov 	ah, 08h
		mov		bh,0		; numero da página
		int		10h	
		
		cmp al, 219 ;se for parede
		
		jne CICLO
		
		inc POSy	
		jmp		CICLO

	BAIXO:
		cmp		al,50h
		jne		ESQUERDA
		inc 		POSy		;Baixo
		
		goto_xy POSx, POSy
		mov 	ah, 08h
		mov		bh,0		; numero da página
		int		10h	
		
		cmp al, 219
		jne CICLO
		
		dec POSy	
		
		jmp		CICLO

	ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		dec		POSx		;Esquerda
		
		goto_xy POSx, POSy
		mov 	ah, 08h
		mov		bh,0		; numero da página
		int		10h	
		
		cmp al, 219
		jne CICLO
		
		inc POSx	
		jmp		CICLO

	DIREITA:
		cmp		al,4Dh
		jne		LER_SETA 
		inc		POSx		;Direita
		goto_xy POSx, POSy
		mov 	ah, 08h
		mov		bh,0		; numero da página
		int		10h	
		
		cmp al, 219
		jne CICLO
		
		dec POSx	
		jmp		CICLO
	FIM:
		ret
JOGO endp

; NovoRegTOP proc

	


; NovoRegTOP endp


LeProxCaraterTOP proc
	mov     ah,3fh			; indica que vai ser lido um ficheiro 
	mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto 
	mov     cx,1			; numero de bytes a ler 
	lea     dx,car_fich	; vai ler para o local de memoria apontado por dx (car_fich)
	int     21h				; faz efectivamente a leitura
	
	; mov 	bx, ax;aux
	
	; mov     ah,02h			; coloca o caracter no ecran
	; mov	    dl,car_fich		; este é o caracter a enviar para o ecran
	; int	    21h			; imprime no ecran
	
	; mov ax, bx
	RET
	
LeProxCaraterTOP endp
LeProxCaraterTOP2 proc
	mov     ah,3fh			; indica que vai ser lido um ficheiro 
	mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto 
	mov     cx,1			; numero de bytes a ler 
	lea     dx,car_fich	; vai ler para o local de memoria apontado por dx (car_fich)
	int     21h				; faz efectivamente a leitura
	
	mov 	bx, ax;aux
	
	mov     ah,02h			; coloca o caracter no ecran
	mov	    dl,car_fich		; este é o caracter a enviar para o ecran
	int	    21h			; imprime no ecran
	
	mov ax, bx
	RET
	
LeProxCaraterTOP2 endp


CompararTempo proc
	; mov dl,10
	; mov ah,2h
	; int 21h
	
	mov     ah,3dh			; vamos abrir ficheiro para leitura 
	mov     al,0			; tipo de ficheiro	
	lea     dx,FichTOP			; nome do ficheiro
	int     21h			; abre para leitura 
	jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
	mov     HandleFich,ax		; ax devolve o Handle para o ficheiro 
	jmp     Start		; depois de abero vamos ler o ficheiro 

	erro_abrir:
		mov     ah,09h
		lea     dx,Erro_Open
		int     21h
		mov 	flagFich, 0
		ret
	
	;le 1 byte para numero
	;le 2 bytes para horas
	;le 1 byte lixo
	;le 2 bytes para min
	;le 1 byte lixo
	;le 2 byte para seg
	;le 1 byte lixo
	;le ate fim para nome (lixo)
	Start:
		xor si, si
		inc si
		
	Ciclo:	
		CMP SI, 10
		je fecha_ficheiro
		;------------------ LE NUMERO DO TOP ------------------
		call LeProxCaraterTOP
		jc	    erro_ler		; se carry é porque aconteceu um erro
		cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
		je	    fecha_ficheiro	; se EOF fecha o ficheiro 
		;------------------------------------------------------

		;------------------ DESPREZA '-' ------------------
		call LeProxCaraterTOP
		jc	    erro_ler		; se carry é porque aconteceu um erro
		cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
		je	    fecha_ficheiro	; se EOF fecha o ficheiro 
		;------------------------------------------------------
		
		; mov     ah,02h			; coloca o caracter no ecran
		; mov	    dl,car_fich		; este é o caracter a enviar para o ecran
		; int	    21h			; imprime no ecran
		
	
		
		
		; mov ah, 02h
		; mov dl, car_fich2[0]
		; int 21h
		
		; mov ah, 02h
		; mov dl, Horas[1]
		; int 21h
		
		; mov ah, 02h
		; mov dl, '|'
		; int 21h
		
			; mov ah, 02h
			; mov dl, al
			; int 21h
		
		
		
		
		
		; mov     ah,02h			; coloca o caracter no ecran
		; mov	    dl,al		; este é o caracter a enviar para o ecran
		; int	    21h			; imprime no ecran
		
		; mov ah, 01h
		; int	21h
		
		; mov     ah,02h			; coloca o caracter no ecran
		; mov	    dl,ah		; este é o caracter a enviar para o ecran
		; int	    21h			; imprime no ecran
		
		; mov ah, 01h
		; int	21h
		
		call LeProxCaraterTOP
		jc	    erro_ler		; se carry é porque aconteceu um erro
		cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
		je	    fecha_ficheiro	; se EOF fecha o ficheiro 
		
		mov al, stringTempo[0]
		cmp car_fich, al
		jae HorasIgual
		cmp car_fich, al
			jb MelhorTempo
		jmp proxLinha
		
		HorasIgual:
			
			call LeProxCaraterTOP
			jc	    erro_ler		; se carry é porque aconteceu um erro
			cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
			je	    fecha_ficheiro	; se EOF fecha o ficheiro 
		
			mov al, stringTempo[1]
			cmp car_fich, al
			jae HorasIgual2
			cmp car_fich, al
			jb MelhorTempo
			jmp proxLinha
		HorasIgual2:	
			
			;--------DESPREZA O 'h'  -------------------
			call LeProxCaraterTOP
			jc	    erro_ler		; se carry é porque aconteceu um erro
			cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
			je	    fecha_ficheiro	; se EOF fecha o ficheiro 
			;------------------------------------------
			call LeProxCaraterTOP
			jc	    erro_ler		; se carry é porque aconteceu um erro
			cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
			je	    fecha_ficheiro	; se EOF fecha o ficheiro 
			
			mov al, stringTempo[3]
			cmp car_fich, al
			jae MinutosIgual
			cmp car_fich, al
			jb MelhorTempo
			jmp proxLinha
			
		MinutosIgual:
		
			call LeProxCaraterTOP
			jc	    erro_ler		; se carry é porque aconteceu um erro
			cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
			je	    fecha_ficheiro	; se EOF fecha o ficheiro 
		; mov ah, 02h
		; mov dl, car_fich
		; int	21h
		
			mov al, stringTempo[4]
			cmp car_fich, al
			jae MinutosIgual2
			cmp car_fich, al
			jb MelhorTempo
			jmp proxLinha
		MinutosIgual2:
			
		
			;--------DESPREZA O 'm'  -------------------
			call LeProxCaraterTOP
			jc	    erro_ler		; se carry é porque aconteceu um erro
			cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
			je	    fecha_ficheiro	; se EOF fecha o ficheiro 
			;------------------------------------------
			call LeProxCaraterTOP
			jc	    erro_ler		; se carry é porque aconteceu um erro
			cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
			je	    fecha_ficheiro	; se EOF fecha o ficheiro 
			
			mov al, stringTempo[6]
			cmp car_fich, al
			jae SegundosIgual
			cmp car_fich, al
			jb MelhorTempo
			jmp proxLinha
			
		SegundosIgual:
			call LeProxCaraterTOP
			jc	    erro_ler		; se carry é porque aconteceu um erro
			cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
			je	    fecha_ficheiro	; se EOF fecha o ficheiro 
			
			mov al, stringTempo[7]
			cmp car_fich, al
			jae SegundosIgual2
			cmp car_fich, al
			jb MelhorTempo
			jmp proxLinha
		
		SegundosIgual2:		
			jmp MelhorTempo
			jmp proxLinha

		MelhorTempo:
			
			mov FlagCompararTempo, si
			
			; mov ah, 09h
			; lea dx, stringTempo
			; int 21h
			
			; mov ah, 02h
			; MOV DL, '-'
			; INT 21H
				
			; mov ah, 0Ah
			; lea dx, NomeUser
			; xor si, si
			; mov NomeUser[si], 12
			; int	21h
			
			; mov ah, 01h
			; int	21h
			; mov ah, 01h
			; int	21h
			
			jmp MostraResto

		proxLinha:
		; mov ah, 01h
		; int	21h
			call LeProxCaraterTOP
			jc	    erro_ler		; se carry é porque aconteceu um erro
			cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
			je	    fecha_ficheiro	; se EOF fecha o ficheiro 
			
			cmp car_fich, '|'
			jne proxLinha
			inc si
			jmp Ciclo
		
		MostraResto:
			call LeProxCaraterTOP
			jc	    erro_ler		; se carry é porque aconteceu um erro
			cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
			je	    fecha_ficheiro	; se EOF fecha o ficheiro 
			jmp MostraResto
	erro_ler:
		mov ah, 01h
		int	21h
		mov     ah,09h
		lea     dx,Erro_Ler_Msg
		int     21h
		jmp		fecha_ficheiro

	; fim_ficheiro:
		; cmp si, 10
		; jae fecha_ficheiro
		
		;senao
		
		; mov ah, 09h
			; lea dx, stringTempo
			; int 21h
			
			; mov ah, 02h
			; MOV DL, '-'
			; INT 21H
				
			; mov ah, 0Ah
			; lea dx, NomeUser
			; xor si, si
			; mov NomeUser[si], 12
			; int	21h
			
			; mov ah, 01h
			; int	21h
		
		; mov ah, 01h
		; int	21h
	fecha_ficheiro:
		cmp si, 10
		jnbe FIM
		mov FlagCompararTempo, si
		
FIM:	mov     ah,3eh
		mov     bx,HandleFich
		int     21h
		ret

CompararTempo endp

MostraNovoTOP proc
	call APAGA_ECRAN; TODO: COMPARAR TEMPO NAO MOSTRAR
	xor si, si
	inc si
	
	mov ah, 02h
	add dL, 10
	INT 21H
	
	mov     ah,3dh			; vamos abrir ficheiro para leitura 
	mov     al,0			; tipo de ficheiro	
	lea     dx,FichTOP			; nome do ficheiro
	int     21h			; abre para leitura 
	jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
	mov     HandleFich,ax		; ax devolve o Handle para o ficheiro 
	jmp     Ciclo		; depois de abero vamos ler o ficheiro 

	erro_abrir:
		mov     ah,09h
		lea     dx,Erro_Open
		int     21h
		mov 	flagFich, 0
		ret
		
	Ciclo:	
		; mov ah, 01h
		; int	21h
		
		CMP SI, 10
		je FIM
		
		; mov dx, si
		; add dl, 30h
		; mov ah, 02h
		; int 21h
		
		; mov dl, 10
		; mov ah, 02h
		; int 21h
		
		; mov dx, FlagCompararTempo
		; add dl, 30h
		; mov ah, 02h
		; int 21h
		
		; mov dl, 10
		; mov ah, 02h
		; int 21h
		
		mov dx, si
		mov bx, FlagCompararTempo
		cmp dx, bx
		je InserirDados
		cmp dx, bx
		jne Continua
	Continua:	
		call LeProxCaraterTOP2
		jc	    erro_ler		; se carry é porque aconteceu um erro
		cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
		je	    FIM	; se EOF fecha o ficheiro 
		
		CMP car_fich, '|'
		je NOVALINHA
		
		jmp Ciclo
	
	InserirDados:	
		;----NUM TOP-----
		mov ah, 02h
		mov dx, si
		add dx, 30h;PODE NAO DAR
		INT 21H
		
		;----TRAÇO-----
		mov ah, 02h
		MOV DL, '-'
		INT 21H
	
		;----TEMPO DEMORADO-----
		mov ah, 09h
		lea dx, stringTempo
		int 21h
		
		;----TRAÇO-----
		mov ah, 02h
		MOV DL, '-'
		INT 21H
		
		;----PEDE NOME-----		
		mov ah, 0Ah
		lea dx, NomeUser
		xor si, si
		mov NomeUser[si], 12
		int	21h
		
		; mov ah, 01h
		; int	21h
		inc si
		jmp NOVALINHA
		
		
	NOVALINHA:
		mov dl,10
		mov ah,2h
		int 21h
		inc si
		JMP Ciclo
		
		
	erro_ler:
		
		mov     ah,09h
		lea     dx,Erro_Ler_Msg
		int     21h
		; mov ah, 01h
		; int	21h
		jmp		FIM
	
	FIM:
		mov ah, 01h
		int	21h
		mov     ah,3eh
		mov     bx,HandleFich
		int     21h
		ret

MostraNovoTOP endp


; InsereBufferTOP proc
	; mov ax, si
	; add al, 20h;TODO: PODE NAO ESTAR A DAR, TESTAR
	
	; MOV 	bufferTop[di],al
	; inc di
	; inc di
	; MOV 	bufferTop[di],'-'
	; inc di
	
	; mov 	ax,Horas
	; MOV		bl, 10     
	; div 	bl
	; add 	al, 30h				; Caracter Correspondente às dezenas
	; add		ah,	30h				; Caracter Correspondente às unidades
	; MOV 	bufferTop[di],al
	; inc di
	; MOV 	bufferTop[di],ah
	; inc di
	; MOV 	bufferTop[di],'h'
	; inc di
		
	
	; mov 	ax,Minutos
	; MOV		bl, 10     
	; div 	bl
	; add 	al, 30h				; Caracter Correspondente às dezenas
	; add		ah,	30h				; Caracter Correspondente às unidades
	; MOV 	bufferTop[di],al			; 
	; inc di
	; MOV 	bufferTop[di],ah
	; inc di
	; MOV 	bufferTop[di],'m'			
	; inc di
	
	; mov 	ax,Segundos
	; MOV		bl, 10     
	; div 	bl
	; add 	al, 30h				; Caracter Correspondente às dezenas
	; add		ah,	30h				; Caracter Correspondente às unidades
	; MOV 	bufferTop[di],al			; 
	; inc di
	; MOV 	bufferTop[di],ah
	; inc di
	; MOV 	bufferTop[di],'s'		
	; inc di
	
	; mov cl, NomeUser[2]
	; mov ax, si
	; mov si, 2
	; ciclo:
		; mov bh, NomeUser[si]
		; MOV 	bufferTop[di], bh	
		; inc di
		; inc si
	; loop ciclo
	; MOV 	bufferTop[di], '|'
	
	
	; mov si, ax
	
	;call GUARDA_TOP
	
	; ret
	
	;inc di

; InsereBufferTOP endp


; InsereTOP proc
	; mov dl,10
	; mov ah,2h
	; int 21h
	
	; mov     ah,3dh			; vamos abrir ficheiro para leitura 
	; mov     al,0			; tipo de ficheiro	
	; lea     dx,FichTOP			; nome do ficheiro
	; int     21h			; abre para leitura 
	; jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
	; mov     HandleFich,ax		; ax devolve o Handle para o ficheiro 
	; jmp     Start		; depois de abero vamos ler o ficheiro 

	; erro_abrir:
		; mov     ah,09h
		; lea     dx,Erro_Open
		; int     21h
		; mov 	flagFich, 0
		; ret
	
	; le 1 byte para numero
	; le 2 bytes para horas
	; le 1 byte lixo
	; le 2 bytes para min
	; le 1 byte lixo
	; le 2 byte para seg
	; le 1 byte lixo
	; le ate fim para nome (lixo)
	; Start:
		; xor si, si
		; xor di, di
		; inc si
	
	; Ciclo:
		; mov     ah,3fh			; indica que vai ser lido um ficheiro 
		; mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto 
		; mov     cx,2			; numero de bytes a ler 
		; lea     dx,car_fich2		; vai ler para o local de memoria apontado por dx (car_fich)
		; int     21h				; faz efectivamente a leitura
		; jc	    erro_ler		; se carry é porque aconteceu um erro
		; cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
		; je	    fecha_ficheiro	; se EOF fecha o ficheiro 
		
		; mov ax, car_fich2
		; mov bufferTop[di],al;talvez trocar ordem
		; inc di
		; mov bufferTop[di],ah;talvez trocar
		; inc di
		
		; mov ax, Horas
		; cmp car_fich2, ax
		; jbe HorasIgual
		; jmp proxLinha
		
		; HorasIgual:
			; --------DESPREZA O '-'  -------------------
			; mov     ah,3fh			; indica que vai ser lido um ficheiro 
			; mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto 
			; mov     cx,1			; numero de bytes a ler 
			; lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
			; int     21h				; faz efectivamente a leitura
			; jc	    erro_ler		; se carry é porque aconteceu um erro
			; cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
			; je	    fecha_ficheiro	; se EOF fecha o ficheiro 
			
			; mov ah, car_fich
			; mov bufferTop[di],ah
			; inc di
			; ------------------------------------------
			; mov     ah,3fh			; indica que vai ser lido um ficheiro 
			; mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto 
			; mov     cx,2			; numero de bytes a ler 
			; lea     dx,car_fich2		; vai ler para o local de memoria apontado por dx (car_fich)
			; int     21h				; faz efectivamente a leitura
			; jc	    erro_ler		; se carry é porque aconteceu um erro
			; cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
			; je	    fecha_ficheiro	; se EOF fecha o ficheiro 
			
			; mov ax, car_fich2
			; mov bufferTop[di],al
			; inc di
			; mov bufferTop[di],ah
			; inc di
			
			; mov ax, Minutos
			; cmp car_fich2, ax
			; jbe MinutosIgual
			; jmp proxLinha
			
		; MinutosIgual:
			; --------DESPREZA O '-'  -------------------
			; mov     ah,3fh			; indica que vai ser lido um ficheiro 
			; mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto 
			; mov     cx,1			; numero de bytes a ler 
			; lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
			; int     21h				; faz efectivamente a leitura
			; jc	    erro_ler		; se carry é porque aconteceu um erro
			; cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
			; je	    fecha_ficheiro	; se EOF fecha o ficheiro 
			
			; mov ah, car_fich
			; mov bufferTop[di],ah
			; inc di
			; ------------------------------------------
			; mov     ah,3fh			; indica que vai ser lido um ficheiro 
			; mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto 
			; mov     cx,2			; numero de bytes a ler 
			; lea     dx,car_fich2		; vai ler para o local de memoria apontado por dx (car_fich)
			; int     21h				; faz efectivamente a leitura
			; jc	    erro_ler		; se carry é porque aconteceu um erro
			; cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
			; je	    fecha_ficheiro	; se EOF fecha o ficheiro 
			
			; mov ax, car_fich2
			; mov bufferTop[di],al
			; inc di
			; mov bufferTop[di],ah
			; inc di
			
			; mov ax, Segundos
			; cmp car_fich2, ax
			; jbe SegundosIgual
			; jmp proxLinha
			
		; SegundosIgual:
			; mov ax, Segundos
			; cmp car_fich2, ax
			; jb MelhorTempo
			; cmp si, 10
			; jbe MelhorTempo
			; jmp proxLinha

		; MelhorTempo:
			; call InsereBufferTOP
			; jmp proxLinha

		; proxLinha:
			; mov     ah,3fh			; indica que vai ser lido um ficheiro 
			; mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto 
			; mov     cx,1			; numero de bytes a ler 
			; lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
			; int     21h				; faz efectivamente a leitura
			; jc	    erro_ler		; se carry é porque aconteceu um erro
			; cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
			; je	    fecha_ficheiro	; se EOF fecha o ficheiro 
			
			; mov ah, car_fich
			; mov bufferTop[di],ah
			; inc di
			
			; cmp car_fich, '|'
			; jne proxLinha
			; inc si
			; cmp si, 11
			; je fecha_ficheiro
			; jmp Ciclo
		
		
	; erro_ler:
		; mov     ah,09h
		; lea     dx,Erro_Ler_Msg
		; int     21h

	; fecha_ficheiro:					; vamos fechar o ficheiro 
		; mov     ah,3eh
		; mov     bx,HandleFich
		; int     21h
	; FIM: ret
; InsereTOP endp


; MostraTOP proc
	; mov dl,10
	; mov ah,2h
	; int 21h
	
	; mov     ah,3dh			; vamos abrir ficheiro para leitura 
	; mov     al,0			; tipo de ficheiro	
	; lea     dx,FichTOP			; nome do ficheiro
	; int     21h			; abre para leitura 
	; jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
	; mov     HandleFich,ax		; ax devolve o Handle para o ficheiro 
	; jmp     ler_ciclo		; depois de abero vamos ler o ficheiro 

	; erro_abrir:
		; mov     ah,09h
		; lea     dx,Erro_Open
		; int     21h
		; mov 	flagFich, 0
		; ret
	
	; ler_ciclo:
		; mov     ah,3fh			; indica que vai ser lido um ficheiro 
		; mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto 
		; mov     cx,1			; numero de bytes a ler 
		; lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
		; int     21h				; faz efectivamente a leitura
		; jc	    erro_ler		; se carry é porque aconteceu um erro
		; cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
		; je	    fecha_ficheiro	; se EOF fecha o ficheiro 
		
		; cmp car_fich, '|'
		; jne MOSTRA
		
		; mov dl,10
		; mov ah,2h
		; int 21h
		; int 21h
		; jmp ler_ciclo
		
		
	; MOSTRA:	
		; mov     ah,02h			; coloca o caracter no ecran
		; mov	    dl,car_fich		; este é o caracter a enviar para o ecran
		; int	    21h			; imprime no ecran
		; jmp	    ler_ciclo		; continua a ler o ficheiro

	; erro_ler:
		; mov     ah,09h
		; lea     dx,Erro_Ler_Msg
		; int     21h

	; fecha_ficheiro:					; vamos fechar o ficheiro 
		; mov     ah,3eh
		; mov     bx,HandleFich
		; int     21h
	
	
		; cmp FlagCompararTempo, 1
		; je AdicionarTOP
	; AdicionarTOP:	
		; mov ah, 0Ah
		; lea dx, NomeUser
		; xor si, si
		; mov NomeUser[si], 12
		; int	21h
		; call InsereTOP

	; ret
	
		; mov     ah,09h			; o ficheiro pode não fechar correctamente
		; lea     dx,Erro_Close
		; Int     21h
	; ret

; MostraTOP endp



FimJogo proc
	call APAGA_ECRAN
	call CALCULA_TEMPO
	call CompararTempo
	call MostraNovoTOP
	;call MostraTOP
	
	;call GUARDA_TOP
	;calcular tempo
	;ler ficheiro e comparar com o tempo
	;se horas <= + se min <= + s <= + se linha a ler <= 10
	ret
FimJogo endp


opJogar	proc
	call APAGA_ECRAN
	
	cmp auxConfigMaze, 1
	je Maze
	cmp auxConfigMaze, 2
	je MazeFich
	cmp auxConfigMaze, 3
	je CriaMaze
Maze:
	call MostraMaze
	jmp JOGAR
	
MazeFich:
	call MostraMazeFich
	; cmp flagFich, 0
	; je FimOpJogar
	jmp JOGAR
	
	
CriaMaze:
	;call criaMaze;TODO
	;call MostraMazeCriado;TODO
	cmp flagFich, 0
	je FimOpJogar
	jmp JOGAR
	
	
JOGAR:
	MOV POSy, 19
	MOV POSya, 19
	call Ler_TEMPO
	call JOGO
	call FimJogo
	;call CALCULA_TEMPO
	;call GUARDA_TOP
	
FimOpJogar:	ret
opJogar	endp





opTop	proc
	mov     ah,02h;testar			
	mov	    dl,'T'
	int	    21h
	ret
opTop	endp

MostraMenuConfig	proc
	xor di, di
	
	mov ah, 0
	int 10h
	
	
	CicloMostraMenu:
		mov ah, MenuConfigMaze[di]
		
		
		cmp ah, 0
		je FimMostraMenu; if (fim de MenuConfigMaze)
		;else
		
		
		cmp ah, '|'
		je NovaLinhaMostraMenu
		
		mov     ah,02h			; coloca o caracter no ecran
		mov	    dl,MenuConfigMaze[di]		; este é o caracter a enviar para o ecran
		int	    21h	
		inc di
	jmp CicloMostraMenu
	
	NovaLinhaMostraMenu:
		mov dl,10
		mov ah,2h
		int 21h
		inc di
		jmp CicloMostraMenu
		
	FimMostraMenu:	
	ret
MostraMenuConfig	endp

opMazeConfig	proc
	call	MostraMenuConfig
	
	mov 	ah,1h
	int		21h
	
	cmp		al,'0'
	je FIM
	cmp		al,'1'
	je OP1
	cmp		al,'2'
	je OP2
	cmp		al,'3'
	je OP3
	
	OP1:
		mov auxConfigMaze, 1
		jmp FIM
	OP2:
		mov auxConfigMaze, 2
		jmp FIM
	OP3:
		mov auxConfigMaze, 3
		jmp FIM
	
	
	
FIM:	ret
opMazeConfig	endp


Main  proc

	mov		ax, dseg
	mov		ds,ax
	mov		ax,0B800h
	mov		es,ax
	
	CICLO:	
		call	MostraMenu
		mov 	ah,01h
		int		21h
		
		cmp		al,'0'
		je FIM
		cmp		al,'1'
		je JOGAR
		cmp		al,'2'
		je TOP
		cmp		al,'3'
		je CONF_MAZE
	jmp CICLO
	
	JOGAR:
		call	opJogar
		jmp CICLO
	TOP:
		call	opTop
		jmp CICLO
	CONF_MAZE:
		call	opMazeConfig
		jmp CICLO
	FIM:	
		mov		ah,4CH
		INT		21H
Main	endp
Cseg	ends
end	Main