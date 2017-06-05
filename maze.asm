;------------------------------------------------------------------------
;
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2016/2017
;;--------------------------------------------------------------
; Imprime valor da tecla numa posição do ecran na posição linha,coluna
;--------------------------------------------------------------
;	Programa de demostração de várias rotinhas do sistema de 
;	manipulação do ecrãn 
;	Imprime um de vários caracteres na localização do cursor
; 	Caracteres são seleccionadas com as teclas: 1, 2, 3, 4, e SPACE
;
;		arrow keys to move 
;		press ESC to exit
;--------------------------------------------------------------

.8086
.model small
.stack 2048

dseg	segment para public 'data'
		string	db	"Teste prático de T.I",0
		Car		db	32
		POSy		db	5	; a linha pode ir de [1 .. 25]
		POSx		db	10	; POSx pode ir [1..80]	
		POSya		db	?	; a linha pode ir de [1 .. 25]
		POSxa		db	?	; POSx pode ir [1..80]	
	;	p_POSxy dw	40	; ponteiro para posicao de escrita
		Fich         	db      'MAZE.TXT',0
		buffer         	db      22 dup (41 dup (' '))
		msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$"
		msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$"
		msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$"

dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg



;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da página
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

;########################################################################
;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
		xor		bx,bx
		mov		cx,25*80
		
apaga:			mov	byte ptr es:[bx],' '
		mov		byte ptr es:[bx+1],7
		inc		bx
		inc 		bx
		loop		apaga
		ret
apaga_ecran	endp


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



; imprimeI proc
	
; imprimeI endp


; CriarInicio proc

	; MOV POSy, 1
	; MOV POSx, 10
	
	; MOV POSya, 1
	; MOV POSxa, 10

	; CICLO:
		; goto_xy	POSxa,POSya	; Vai para a posição anterior do cursor
		; mov		ah, 02h
		; mov		dl, Car	; Repoe Caracter guardado 
		; int		21H		
		
		; goto_xy	POSx,POSy	; Vai para nova possição
		; mov 	ah, 08h
		; mov		bh,0		; numero da página
		; int		10h		
		; mov		Car, al	; Guarda o Caracter que está na posição do Cursor
		; mov		Cor, ah	; Guarda a cor que está na posição do Cursor
		
		; cmp al, 'X' 
		; je FIM
		; goto_xy	78,0		; Mostra o caractr que estava na posição do AVATAR
		; mov		ah, 02h	; IMPRIME caracter da posição no canto
		; mov		dl, Car	
		; int		21H			
	
		; goto_xy	POSx,POSy	; Vai para posição do cursor
	; IMPRIME:
		; mov		ah, 02h
		; mov		dl, 190	; Coloca AVATAR
		; int		21H	
		; goto_xy	POSx,POSy	; Vai para posição do cursor
		
		; mov		al, POSx	; Guarda a posição do cursor
		; mov		POSxa, al
		; mov		al, POSy	; Guarda a posição do cursor
		; mov 	POSya, al
		
		; call 		LE_TECLA
		; CMP 		AL, 27		; ESCAPE
		; JE		FIM
		

; OK:		cmp		al,20h;SPACE
		; JNE ESQUERDA
		; call imprimeI
		
; ESQUERDA:
		; cmp		al,4Bh
		; jne		DIREITA
		; cmp POSx, 2
		; jnge CICLO
		; dec		POSx		;Esquerda
		; jmp		CICLO

; DIREITA:
		; cmp		al,4Dh
		; jne		CICLO 
		; cmp POSx, 39
		; jnle CICLO
		; inc		POSx		;Direita
		; jmp		CICLO
; FIM: 
	; ret
; CriarInicio endp




Main  proc
		mov		ax, dseg
		mov		ds,ax
		mov		ax,0B800h
		mov		es,ax

		call	apaga_ecran
		
		mov dl, 219
		mov ah, 02h
		mov cx, 40
		preencheCima:
			goto_xy	cl,1
			mov dl, 219
			mov ah, 02h
			int 21h
			goto_xy	cl,19
			mov dl, 219
			mov ah, 02h
			int 21h
			goto_xy	cl,20
			mov dl, 219
			mov ah, 02h
			int 21h
		loop preencheCima
		
		mov cx, 20
		preencheLados:
			goto_xy	0,cl
			mov dl, 219
			mov ah, 02h
			int 21h
			goto_xy	40,cl
			mov dl, 219
			mov ah, 02h
			int 21h
		loop preencheLados
		
		goto_xy	20,1
		mov ah, 02h
		mov dl, 'X'
		int 21h
		
		goto_xy	20,19
		mov ah, 02h
		mov dl, 'I'
		int 21h
		
		;Obter a posição
		dec		POSy
		dec		POSx

CICLO:	goto_xy	POSx,POSy
IMPRIME:	mov		ah, 02h
		mov		dl, Car
		int		21H			
		goto_xy	POSx,POSy
		
		call 		LE_TECLA
		cmp		ah, 1
		je		ESTEND
		CMP 		AL, 27		; ESCAPE
		JE		Guarda

ZERO:	CMP 		AL, 48		; Tecla 0
		JNE		UM
		mov		Car, 32		;ESPAÇO
		jmp		CICLO					
		
UM:		CMP 		AL, 49		; Tecla 1
		JNE		ESTEND
		mov		Car, 219		;Caracter CHEIO
		jmp		CICLO		
; I:	CMP 		AL, 49h
	; JNE		I2
	; CALL CriarInicio
	; jmp CICLO
	
; I2:	CMP 		AL, 69h
	; JNE		X
	; CALL CriarInicio
	; jmp CICLO
; X:	CMP 		AL, 58h
	; JNE		X2
	; CALL CriarFim
	; jmp CICLO
; X2:	CMP 		AL, 78h
	; JNE		CICLO
	; CALL CriarFim
	; jmp CICLO
	
ESTEND:	cmp 		al,48h
		jne		BAIXO
		cmp POSy, 3
		jnge CICLO
		dec		POSy		;cima
		
		jmp		CICLO

BAIXO:	cmp		al,50h
		jne		ESQUERDA
		cmp POSy, 17
		jnle CICLO
		inc 		POSy		;Baixo
		jmp		CICLO

ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		cmp POSx, 3
		jnge CICLO
		dec		POSx		;Esquerda
		jmp		CICLO

DIREITA:
		cmp		al,4Dh
		jne		CICLO 
		cmp POSx, 38
		jnle CICLO
		inc		POSx		;Direita
		jmp		CICLO

Guarda:	

	xor si, si
	xor bl, bl
	xor cl, cl
	
	i:
		cmp bl, 20
		je sai
		
		xor cl, cl
		j:
			cmp cl, 41
			je avancaI
			
			; mov ah, 01h
		; int	21h
			
			goto_xy cl, bl
			mov 	ah, 08h
			mov		bh,0		; numero da página
			int		10h		
			
			; mov ah, 01h
		; int	21h
			
			
			
			cmp al, 219
			je parede
			
			cmp al, ' '
			je vazio
			
			cmp al, 'I'
			je moveBuffer
			
			cmp al, 'X'
			je moveBuffer
			
			parede:
				mov al, 31h
				jmp moveBuffer
				
			vazio:
				mov al, 30h
				jmp moveBuffer
			
			
			
			moveBuffer:
			
				mov buffer[si], al
				inc si
				inc cl
		jmp j

	avancaI:
		inc bl
		mov al, '|'
		mov buffer[si], al
		INC SI
	
		mov al, 10
		mov buffer[si], al
		INC SI
		
		jmp i


	sai:
	; mov		ah,4CH
	; INT		21H
	
			; mov ah, 01h
		; int	21h







	; XOR	BX,BX
	; XOR	si,si
	; mov cx, 25*80
	; for1:
		; MOV	al, BYTE PTR ES:[BX]
		; INC	BX
		; INC BX
		
		; mov dl, al;auxiliar
		; mov ax, si
		; mov dh, bl
		; mov bl, 41
		; div bl
		; mov bl, dh
		; mov al, dl
		; cmp ah, 0
		; je novaLinha
		
		
		
		
		
		; cmp al, 219
		; je parede
		
		; cmp al, ' '
		; je vazio
		
		; cmp al, 'I'
		; je moveBuffer
		
		; cmp al, 'X'
		; je moveBuffer
		
		; parede:
			; mov al, 31h
			; jmp moveBuffer
			
		; vazio:
			; mov al, 30h
			; jmp moveBuffer
		
		; prox:
			; inc si
			; loop for1
		
		; novaLinha:
			; dec bx
			; dec bx
			; add bx, 41
			
			mov al, '|'
			mov buffer[si], al
			INC SI
		
			mov al, 10
			
			
		; moveBuffer:
			; mov ax, dx
			; mov buffer[si], al
			; INC SI
	; loop for1
	


	
	mov	ah, 3ch			; abrir ficheiro para escrita 
	mov	cx, 00H			; tipo de ficheiro
	lea	dx, Fich			; dx contem endereco do nome do ficheiro 
	int	21h				; abre efectivamente e AX vai ficar com o Handle do ficheiro 
	jnc	escreve			; se não acontecer erro vai vamos escrever
	
	mov	ah, 09h			; Aconteceu erro na leitura
	lea	dx, msgErrorCreate ;//mete endereco da msg em dx
	int	21h ; //carater lido em AL
	
	jmp	fim

escreve:
	mov	bx, ax			; para escrever BX deve conter o Handle 
	mov	ah, 40h			; indica que vamos escrever 
    	
	lea	dx, buffer			; Vamos escrever o que estiver no endereço DX
	mov	cx, si			; vamos escrever multiplos bytes duma vez só
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
	mov		ah,4CH
	INT		21H
Main	endp
Cseg	ends
end	Main


		
