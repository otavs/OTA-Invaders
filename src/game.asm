INCLUDE Irvine32.inc
INCLUDE Macros.inc
INCLUDE win32.inc
INCLUDE winmm.inc

includelib Winmm.lib

; Constantes
largura = 100						; Largura da tela
altura = 35							; Altura da tela
tempoDelay = 17						; Tempo em ms entre cada atualizacao da tela
maxTirosOta = 20					; Numero maximo de tiros da nave OTA na tela
maxInimigos = 100					; Numero maximo de inimigos na tela
maxTirosInimigos = 50				; Numero maximo de tiros inimigos na tela
tempoAtaquePlayer = 200				; Tempo minimo em ms entre os tiros da nave OTA
maxVidasPlayer = 25					; Numero de vidas inicial do jogador
tempoIvulnerabilidadePlayer = 1000	; Tempo de invulnerabilidade da nave OTA ser atingida
velocidadeTirosPlayer = 35			; Velocidade dos tiros da nave OTA
velocidadeBracosInimigos = 20		; Velocidade da animacao dos bracos dos inimigos
velocidadeTirosInimigosY = 50		; Velocidade dos tiros inimigos
corBordas = 3						; Cor das bordas do jogo
corTirosPlayer = 187				; Cor dos tiros da nave OTA

PROJETIL STRUCT
	disponivel DWORD 0				; Representa se o projetil existe ou não atualmente
	x DWORD 0						; Coordenada x do projetil
	y DWORD 0						; Coordenada y do projetil
	velocidadeX DWORD 0				; Velocidade x do projetil
	velocidadeY DWORD 0				; Velocidade y do projetil
	dirX DWORD 0					; Direcao da velocidade no eixo x
	dirY DWORD 0					; Direcao da velocidade no eixo y
	contadorTempoMovimentoX DWORD 0	; Contador para limitar o movimento no eixo x baseando-se na velocidade x
	contadorTempoMovimentoY DWORD 0	; Contador para limitar o movimento no eixo y baseando-se na velocidade y
	cor WORD 0
PROJETIL ENDS

INIMIGO STRUCT
	disponivel DWORD 0				 ; Representa se o inimigo existe ou não atualmente
	tipo DWORD 0					 ; Tipo do inimigo, pode ser 0, 1 ou 2
	x DWORD 0						 ; Coordenada x do inimigo
	y DWORD 0						 ; Coordenada y do inimigo
	velocidadeX DWORD 0				 ; Velocidade do inimigo no eixo x
	velocidadeY DWORD 0				 ; Velocidade do inimigo no eixo y
	velocidadeAtaqueMaxima DWORD 0	 ; Velocidade maxima entre os ataques do inimigo
	variacaoVelocidadeAtaque DWORD 0 ; Variacao da velocidade entre os ataques do inimigo
	velocidadeAtaqueAtual DWORD 0	 ; Velocidade atual calculada entre os ataques do inimigo
	vida DWORD 0					 ; Quantidade de vidas do inimigo
	dirX DWORD 0					 ; Direcao da velocidade no eixo x
	dirY DWORD 0					 ; Direcao da velocidade no eixo y
	contadorTempoMovimentoX DWORD 0	 ; Contador para limitar o movimento no eixo x baseando-se na velocidade x
	contadorTempoMovimentoY DWORD 0	 ; Contador para limitar o movimento no eixo y baseando-se na velocidade y
	contadorTempoAtaque DWORD 0		 ; Contador para limitar o tempo entre os ataques do inimigo
	bracoEsquerdo DWORD 0			 ; Contador para limitar o tempo de atualizacao da animacao do braco esquerdo
	bracoDireito DWORD 0			 ; Contador para limitar o tempo de atualizacao da animacao do braco direito
	cor WORD 0						 ; Cor do inimigo
	velocidadeTirosX DWORD 0		 ; Velocidade dos tiros no eixo x
	velocidadeTirosY DWORD 0		 ; Velocidade dos tiros no eixo y
INIMIGO ENDS

; Funcoes utilizadas
InicializaJogo PROTO
AdicionaInimigo PROTO, tipo:DWORD, x:DWORD, y:DWORD, velocidadeX:DWORD, velocidadeY:DWORD, dirX:DWORD, dirY:DWORD, velocidadeAtaqueMaxima:DWORD, variacaoVelocidadeAtaque:DWORD, vida:DWORD, cor:WORD, velocidadeTirosX:DWORD, velocidadeTirosY:DWORD
AdicionaProjetilPlayer PROTO, x:DWORD, y:DWORD, velocidadeX:DWORD, velocidadeY:DWORD, dirX:DWORD, dirY:DWORD, cor:WORD
AdicionaProjetilInimigo PROTO, x:DWORD, y:DWORD, velocidadeX:DWORD, velocidadeY:DWORD, dirX:DWORD, dirY:DWORD, cor:WORD
AtualizaTirosPlayer PROTO
AtualizaTirosInimigos PROTO
AtualizaInimigos PROTO
VerificaColisoesPlayer PROTO
VerificaColisoesInimigos PROTO
VerificaInputInicial PROTO
VerificaInputMain PROTO
VerificaInputGameOver PROTO
DelayJogo PROTO
LimpaTela PROTO
DesenhaPlayer PROTO
DesenhaTirosPlayer PROTO
DesenhaTirosInimigos PROTO
DesenhaInimigos PROTO
DesenhaBracosInimigos PROTO
DesenhaBordas PROTO
AtualizaTela PROTO
DesenhaCaractere PROTO, char:BYTE, x:DWORD, y:DWORD, color:WORD
DesenhaTelaInicial PROTO
DesenhaTelaGameOver PROTO
DesenhaNumero PROTO, numero:DWORD, x:DWORD, y:DWORD, cor:WORD
DesenhaString PROTO, string:DWORD, x:DWORD, y:DWORD, cor:WORD
FinalizaJogo PROTO
AtualizaBufferInimigos PROTO, x:DWORD, y:DWORD
GetBufferInimigos PROTO, x:DWORD, y:DWORD
AtualizaContadoresPlayer PROTO
IniciaNovaPartida PROTO
CriaNovaFase PROTO

.data
	
	SND_FILENAME DWORD 00022001h

	somAtirou BYTE "sons/atirou.wav", 0
	somPerdeu BYTE "sons/perdeu.wav", 0
	somEnter BYTE "sons/coin.wav", 0
	
	buffer CHAR_INFO largura*altura DUP(<<' '>, 0>)
	
	outHandle HANDLE 0
	bufferSize COORD <largura, altura>
	bufferCoord COORD <0, 0>
	region SMALL_RECT <0, 0, largura-1, altura-1>
	
	bufferInimigos BYTE largura*altura DUP(0)
	
	titulo BYTE "OTA Invaders", 0 
	cursorInfo CONSOLE_CURSOR_INFO <0, 0>
	
	corOriginal WORD white+(black*16)
	
	estado DWORD 0;
	
	playerX DWORD 0
	playerY DWORD 0
	cooldownAtaquePlayer DWORD 0
	invulnerabilidadePlayer DWORD 0
	vidaPlayer DWORD 0
	pontos DWORD 0
	recordeNivel DWORD 0
	recordePontos DWORD 0
	
	tempoCount DWORD 0
	tempoAnterior DWORD 0
	
	nivel DWORD 0
	qtdInimigos DWORD 0
	
	quit DWORD 0
	
	; Objetos do jogo
	tirosOta PROJETIL maxTirosOta DUP(<>)
	tirosInimigos PROJETIL maxTirosInimigos DUP(<>)
	inimigos INIMIGO maxInimigos DUP(<>)
	
	; Textos
	txtOtaInvaders BYTE "OTA Invaders v1.0", 0
	txtNivel BYTE "Nivel: ", 0
	txtPontos BYTE "Pontos: ", 0
	txtVidas BYTE "Vidas: ", 0
	txtRecordeNivel BYTE "Recorde Nivel: ", 0
	txtRecordePontos BYTE "Recorde Pontos: ", 0
	txtFimVidas BYTE "-1 (morreu)", 0
	txtWin BYTE "Parabens!!! Voce venceu o jogo!!!", 0
	
	; Buffer auxiliar utilizado na funcao DesenhaNumero
	bufferAux BYTE 20 DUP(0)
	
	;                 0000000000111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999
	;                 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	telaInicial BYTE "                                                                                                    " ; 00
	            BYTE "                                                                                                    " ; 01
				BYTE "                                                                                                    " ; 02
	            BYTE "                                   _______   _________   _______                                    " ; 03
	            BYTE "                                  (  ___  )  \__   __/  (  ___  )                                   " ; 04
	            BYTE "                                  | (   ) |     ) (     | (   ) |                                   " ; 05
	            BYTE "                                  | |   | |     | |     | (___) |                                   " ; 06
	            BYTE "                                  | |   | |     | |     |  ___  |                                   " ; 07
	            BYTE "                                  | |   | |     | |     | (   ) |                                   " ; 08
	            BYTE "                                  | (___) |     | |     | )   ( |                                   " ; 09
	            BYTE "                                  (_______)     )_(     |/     \|                                   " ; 10
	            BYTE "                                                                                                    " ; 11
	            BYTE "       _________   _                     _______    ______     _______    _______    _______        " ; 12
	            BYTE "       \__   __/  ( (    /|  |\     /|  (  ___  )  (  __  \   (  ____ \  (  ____ )  (  ____ \       " ; 13
	            BYTE "          ) (     |  \  ( |  | )   ( |  | (   ) |  | (  \  )  | (    \/  | (    )|  | (    \/       " ; 14
	            BYTE "          | |     |   \ | |  | |   | |  | (___) |  | |   ) |  | (__      | (____)|  | (_____        " ; 15
	            BYTE "          | |     | (\ \) |  ( (   ) )  |  ___  |  | |   | |  |  __)     |     __)  (_____  )       " ; 16
	            BYTE "          | |     | | \   |   \ \_/ /   | (   ) |  | |   ) |  | (        | (\ (           ) |       " ; 17
	            BYTE "       ___) (___  | )  \  |    \   /    | )   ( |  | (__/  )  | (____/\  | ) \ \__  /\____) |       " ; 18
	            BYTE "       \_______/  |/    )_)     \_/     |/     \|  (______/   (_______/  |/   \__/  \_______)       " ; 18
	            BYTE "                                                                                                    " ; 20
	            BYTE "                                                                                                    " ; 21
	            BYTE "                                                                                                    " ; 22
	            BYTE "                                                                                                    " ; 23
	            BYTE "                                                                                                    " ; 24
	            BYTE "                                    Pressione ENTER para jogar!                                     " ; 25
	            BYTE "                                                                                                    " ; 26
	            BYTE "                                                                                                    " ; 27
	            BYTE "                                                                                                    " ; 28
	            BYTE "                                                                                                    " ; 29
	            BYTE "                                                                                                    " ; 30
	            BYTE "                                                                                                    " ; 31
	            BYTE "                                                                                                    " ; 32
	            BYTE "                                                                                                    " ; 33
	            BYTE "                                                                                                    " ; 34
				
	;--------------------------------------------------------------------------------------------------------------------------------------------------
	
	;                  0000000000111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999
	;                  0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	telaGameOver BYTE "                                                                                                    " ; 00
	             BYTE "                                                                                                    " ; 01
	             BYTE "                                                                                                    " ; 02
	             BYTE "                                                                                                    " ; 03
	             BYTE "            _____            __  __  ______        ____ __      __ ______  _____       _            " ; 04
	             BYTE "           / ____|    /\    |  \/  ||  ____|      / __ \\ \    / /|  ____||  __ \     | |           " ; 05
	             BYTE "          | |  __    /  \   | \  / || |__        | |  | |\ \  / / | |__   | |__) |    | |           " ; 06
	             BYTE "          | | |_ |  / /\ \  | |\/| ||  __|       | |  | | \ \/ /  |  __|  |  _  /     | |           " ; 07
	             BYTE "          | |__| | / ____ \ | |  | || |____      | |__| |  \  /   | |____ | | \ \     |_|           " ; 08
	             BYTE "           \_____|/_/    \_\|_|  |_||______|      \____/    \/    |______||_|  \_\    (_)           " ; 09
	             BYTE "                                                                                                    " ; 10
	             BYTE "                                                                                                    " ; 11
	             BYTE "                                                                                                    " ; 12
	             BYTE "                                    Nivel Alcancado:                                                " ; 13
	             BYTE "                                                                                                    " ; 14
	             BYTE "                                    Pontuacao Obtida:                                               " ; 15
	             BYTE "                                                                                                    " ; 16
	             BYTE "                                                                                                    " ; 17
	             BYTE "                                                                                                    " ; 18
	             BYTE "                                                                                                    " ; 19
	             BYTE "                             Pressione ENTER para tentar novamente!                                 " ; 20
	             BYTE "                                                                                                    " ; 21
	             BYTE "                                                                                                    " ; 22
	             BYTE "                                                                                                    " ; 23
	             BYTE "                                                                                                    " ; 24
	             BYTE "                                                                                                    " ; 25
	             BYTE "                                                                                                    " ; 26
	             BYTE "                               ou pressione ESC para desistir...                                    " ; 27
	             BYTE "                                                                                                    " ; 28
	             BYTE "                                                                                                    " ; 29
	             BYTE "                                                                                                    " ; 30
	             BYTE "                                                                                                    " ; 31
	             BYTE "                                                                                                    " ; 32
	             BYTE "                                                                                                    " ; 33
	             BYTE "                                                                                                    " ; 34
				 
.code

main PROC
	
	
	
	call InicializaJogo
	
	loopMain:
	
		cmp quit, 1
		je fimJogo
	
		mov eax, 1
		call delay
	
		cmp estado, 0
		je estadoInicial
		cmp estado, 1
		je estadoJogo
		cmp estado, 2
		je estadoGameOver
	
	estadoInicial:
	
		call VerificaInputInicial
		
		call LimpaTela
		call DesenhaTelaInicial
		call DesenhaBordas
		INVOKE DesenhaString, OFFSET txtOtaInvaders, 0, 0, 9
		INVOKE DesenhaString, OFFSET txtRecordeNivel, 30, 0, 14
		INVOKE DesenhaNumero, recordeNivel, 45, 0, 15
		INVOKE DesenhaString, OFFSET txtRecordePontos, 60, 0, 14
		INVOKE DesenhaNumero, recordePontos, 76, 0, 15
		
		call AtualizaTela
		
		jmp loopMain
	
	estadoJogo:
	
		call DelayJogo
		cmp ebx, 1
		jne loopMain
		
		cmp qtdInimigos, 0
		jne naoCriaNovaFase
		call CriaNovaFase
	naoCriaNovaFase:
	
		call VerificaInputMain
	
		call AtualizaContadoresPlayer
		
		call AtualizaInimigos
		call AtualizaTirosPlayer
		call AtualizaTirosInimigos
		
		call VerificaColisoesInimigos
		call VerificaColisoesPlayer
		
		call LimpaTela
		INVOKE DesenhaString, OFFSET txtNivel, 0, 0, 14
		INVOKE DesenhaNumero, nivel, 7, 0, 15
		INVOKE DesenhaString, OFFSET txtPontos, 14, 0, 14
		INVOKE DesenhaNumero, pontos, 22, 0, 15
		INVOKE DesenhaString, OFFSET txtVidas, 30, 0, 14
		INVOKE DesenhaNumero, vidaPlayer, 37, 0, 15
		
		INVOKE DesenhaString, OFFSET txtRecordeNivel, 59, 0, 12
		INVOKE DesenhaNumero, recordeNivel, 74, 0, 15
		INVOKE DesenhaString, OFFSET txtRecordePontos, 79, 0, 12
		INVOKE DesenhaNumero, recordePontos, 95, 0, 15
		
		call DesenhaBordas
		call DesenhaBracosInimigos
		call DesenhaInimigos
		call DesenhaPlayer
		call DesenhaTirosPlayer
		call DesenhaTirosInimigos
		cmp nivel, 11
		jne continua
		INVOKE DesenhaString, OFFSET txtWin, 32, 6, 10
	continua:
		call AtualizaTela
	
		jmp loopMain
		
	estadoGameOver:
	
		call VerificaInputGameOver
		
		call LimpaTela
		call DesenhaTelaGameOver
		call DesenhaBordas
		
		INVOKE DesenhaString, OFFSET txtNivel, 0, 0, 14
		INVOKE DesenhaNumero, nivel, 7, 0, 15
		INVOKE DesenhaString, OFFSET txtPontos, 14, 0, 14
		INVOKE DesenhaNumero, pontos, 22, 0, 15
		INVOKE DesenhaString, OFFSET txtVidas, 30, 0, 14
		INVOKE DesenhaString, OFFSET txtFimVidas, 37, 0, 15
		
		INVOKE DesenhaString, OFFSET txtRecordeNivel, 59, 0, 12
		INVOKE DesenhaNumero, recordeNivel, 74, 0, 15
		INVOKE DesenhaString, OFFSET txtRecordePontos, 79, 0, 12
		INVOKE DesenhaNumero, recordePontos, 95, 0, 15
		
		INVOKE DesenhaNumero, nivel, 53, 13, 10
		INVOKE DesenhaNumero, pontos, 54, 15, 10
		
		call AtualizaTela
		
		jmp loopMain
		
	fimJogo:
		call FinalizaJogo
		
		exit
main ENDP

;---------------------------------------------------------
; InicializaJogo
;
; Inicializa as configuracoes da tela do jogo
; 
;---------------------------------------------------------
InicializaJogo PROC
		pushad
		
		; Muda o titulo da janela
		INVOKE SetConsoleTitle, ADDR titulo
		
		; Pega o handle padrao
		INVOKE GetStdHandle, STD_OUTPUT_HANDLE
		mov outHandle, eax
		
		; Muda as dimensoes da janela
		INVOKE SetConsoleWindowInfo, outHandle, TRUE, ADDR region
		
		; Deixa o cursor invisivel
		INVOKE GetConsoleCursorInfo, outHandle, ADDR cursorInfo
		mov cursorInfo.bVisible, 0
		INVOKE SetConsoleCursorInfo, outHandle, ADDR cursorInfo
		
		; Muda a seed do gerador de numeros aleatorios
		call Randomize
		
		popad
		ret
InicializaJogo ENDP

;---------------------------------------------------------
; AdicionaInimigo
;
; Ativa um inimigo desativado do array de inimigos
; Recebe como parametros os atributos do inimigo gerado 
;
;---------------------------------------------------------
AdicionaInimigo PROC, tipo:DWORD, x:DWORD, y:DWORD, velocidadeX:DWORD, velocidadeY:DWORD, dirX:DWORD, dirY:DWORD, velocidadeAtaqueMaxima:DWORD, variacaoVelocidadeAtaque:DWORD, vida:DWORD, cor:WORD, velocidadeTirosX:DWORD, velocidadeTirosY:DWORD
		pushad
		mov ecx, maxInimigos
		mov esi, 0
	procuraInimigoDisponivel:
		cmp inimigos[esi].disponivel, 0
		je criaInimigo
		add esi, TYPE INIMIGO
		loop procuraInimigoDisponivel
		jmp fimAdicionaInimigo
	criaInimigo:
		mov inimigos[esi].disponivel, 1
		mov eax, tipo
		mov inimigos[esi].tipo, eax
		mov eax, x
		mov inimigos[esi].x, eax
		mov eax, y
		mov inimigos[esi].y, eax
		mov eax, velocidadeX
		mov inimigos[esi].velocidadeX, eax
		mov eax, velocidadeY
		mov inimigos[esi].velocidadeY, eax
		mov eax, dirX
		mov inimigos[esi].dirX, eax
		mov eax, dirY
		mov inimigos[esi].dirY, eax
		mov eax, velocidadeAtaqueMaxima
		mov inimigos[esi].velocidadeAtaqueMaxima, eax
		mov eax, variacaoVelocidadeAtaque
		mov inimigos[esi].variacaoVelocidadeAtaque, eax
		call RandomRange
		neg eax
		add eax, velocidadeAtaqueMaxima
		mov inimigos[esi].velocidadeAtaqueAtual, eax
		mov eax, vida
		mov inimigos[esi].vida, eax
		mov ax, cor
		mov inimigos[esi].cor, ax
		mov inimigos[esi].contadorTempoMovimentoX, 0
		mov inimigos[esi].contadorTempoMovimentoY, 0
		mov inimigos[esi].contadorTempoAtaque, 0
		mov eax, velocidadeBracosInimigos
		;call RandomRange
		mov inimigos[esi].bracoEsquerdo, eax
		mov eax, velocidadeBracosInimigos
		;call RandomRange
		mov inimigos[esi].bracoDireito, eax
		mov eax, velocidadeTirosX
		mov inimigos[esi].velocidadeTirosX, eax
		mov eax, velocidadeTirosY
		mov inimigos[esi].velocidadeTirosY, eax
		inc qtdInimigos
	fimAdicionaInimigo:
		popad
		ret
AdicionaInimigo ENDP

;---------------------------------------------------------
; AdicionaProjetilPlayer
;
; Ativa um projetil desativado do array de projeteis do jogador
; Recebe como parametros os atributos do projetil gerado 
;
;---------------------------------------------------------
AdicionaProjetilPlayer PROC, x:DWORD, y:DWORD, velocidadeX:DWORD, velocidadeY:DWORD, dirX:DWORD, dirY:DWORD, cor:WORD
		pushad
		mov ecx, maxTirosOta
		mov esi, 0
	procuraTiroOtaDisponivel:
		cmp tirosOta[esi].disponivel, 0
		je criaTiroOta
		add esi, TYPE PROJETIL
		loop procuraTiroOtaDisponivel
		jmp fimAdicionaProjetilPlayer
	criaTiroOta:
		mov tirosOta[esi].disponivel, 1
		mov eax, x
		mov tirosOta[esi].x, eax
		mov eax, y
		mov tirosOta[esi].y, eax
		mov eax, velocidadeX
		mov tirosOta[esi].velocidadeX, eax
		mov eax, velocidadeY
		mov tirosOta[esi].velocidadeY, eax
		mov eax, dirX
		mov tirosOta[esi].dirX, eax
		mov eax, dirY
		mov tirosOta[esi].dirY, eax
		mov ax, cor
		mov tirosOta[esi].cor, ax
		mov tirosOta[esi].contadorTempoMovimentoX, 0
		mov tirosOta[esi].contadorTempoMovimentoY, 0
	fimAdicionaProjetilPlayer:
		popad
		ret
AdicionaProjetilPlayer ENDP

;---------------------------------------------------------
; AdicionaProjetilInimigo
;
; Ativa um projetil desativado do array de projeteis inimigos
; Recebe como parametros os atributos do projetil gerado 
;
;---------------------------------------------------------
AdicionaProjetilInimigo PROC, x:DWORD, y:DWORD, velocidadeX:DWORD, velocidadeY:DWORD, dirX:DWORD, dirY:DWORD, cor:WORD
		pushad
		mov ecx, maxTirosInimigos
		mov esi, 0
	procuraTiroInimigoDisponivel:
		cmp tirosInimigos[esi].disponivel, 0
		je criaTiroInimigo
		add esi, TYPE PROJETIL
		loop procuraTiroInimigoDisponivel
		jmp fimAdicionaTiroInimigo
	criaTiroInimigo:
		mov tirosInimigos[esi].disponivel, 1
		mov eax, x
		mov tirosInimigos[esi].x, eax
		mov eax, y
		mov tirosInimigos[esi].y, eax
		mov eax, velocidadeX
		mov tirosInimigos[esi].velocidadeX, eax
		mov eax, velocidadeY
		mov tirosInimigos[esi].velocidadeY, eax
		mov eax, dirX
		mov tirosInimigos[esi].dirX, eax
		mov eax, dirY
		mov tirosInimigos[esi].dirY, eax
		mov ax, cor
		mov tirosInimigos[esi].cor, ax
		mov tirosInimigos[esi].contadorTempoMovimentoX, 0
		mov tirosInimigos[esi].contadorTempoMovimentoY, 0
	fimAdicionaTiroInimigo:
		popad
		ret
AdicionaProjetilInimigo ENDP

;---------------------------------------------------------
; AtualizaTirosPlayer
;
; Atualiza os projeteis ativos do array de projeteis do jogador, atualizando seus contadores de movimento e sua posicao atual
; 
;---------------------------------------------------------
AtualizaTirosPlayer PROC
		pushad
		mov ecx, maxTirosOta
		mov esi, 0
	lAtualizaTirosPlayer:
		cmp tirosOta[esi].disponivel, 0
		je fimAtualizaTiroPlayer
		
		add tirosOta[esi].contadorTempoMovimentoX, tempoDelay
		add tirosOta[esi].contadorTempoMovimentoY, tempoDelay
		
		mov eax, tirosOta[esi].velocidadeX
		cmp eax, 0
		jle naoSeMovimentaX_tiroOta
		cmp tirosOta[esi].contadorTempoMovimentoX, eax
		jl naoSeMovimentaX_tiroOta
		cmp tirosOta[esi].dirX, 0
		jg movimentaXPositivo_tiroOta
		cmp tirosOta[esi].dirX, 0
		jl movimentaXNegativo_tiroOta
		jmp fimMovimentaX_tiroOta
		
	movimentaXPositivo_tiroOta:
		inc tirosOta[esi].x
		cmp tirosOta[esi].x, largura-1
		jl naoPassouLargura_tiroOta
		mov tirosOta[esi].disponivel, 0
	naoPassouLargura_tiroOta:
		jmp fimMovimentaX_tiroOta
		
	movimentaXNegativo_tiroOta:
		dec tirosOta[esi].x
		cmp tirosOta[esi].x, 0
		jg naoPassouLargura0_tiroOta
		mov tirosOta[esi].disponivel, 0
	naoPassouLargura0_tiroOta:
		jmp fimMovimentaX_tiroOta
		
	fimMovimentaX_tiroOta:
		sub tirosOta[esi].contadorTempoMovimentoX, eax
		
	naoSeMovimentaX_tiroOta:
	
		mov eax, tirosOta[esi].velocidadeY
		cmp eax, 0
		jle naoSeMovimentaY_tiroOta
		cmp tirosOta[esi].contadorTempoMovimentoY, eax
		jl naoSeMovimentaY_tiroOta
		cmp tirosOta[esi].dirY, 0
		jg movimentaYPositivo_tiroOta
		cmp tirosOta[esi].dirY, 0
		jl movimentaYNegativo_tiroOta
		jmp fimMovimentaY_tiroOta
		
	movimentaYPositivo_tiroOta:
		inc tirosOta[esi].y
		cmp tirosOta[esi].y, altura-1
		jl naoPassouAltura_tiroOta
		mov tirosOta[esi].disponivel, 0
	naoPassouAltura_tiroOta:
		jmp fimMovimentaY_tiroOta
		
	movimentaYNegativo_tiroOta:
		dec tirosOta[esi].y
		cmp tirosOta[esi].y, 1
		jg naoPassouAltura0_tiroOta
		mov tirosOta[esi].disponivel, 0
	naoPassouAltura0_tiroOta:
		jmp fimMovimentaY_tiroOta
		
	fimMovimentaY_tiroOta:
		sub tirosOta[esi].contadorTempoMovimentoY, eax
		
	naoSeMovimentaY_tiroOta:
	
	fimAtualizaTiroPlayer:
		
		add esi, TYPE PROJETIL
		dec ecx
		jne lAtualizaTirosPlayer
		popad
		ret
AtualizaTirosPlayer ENDP

;---------------------------------------------------------
; AtualizaTirosInimigos
;
; Atualiza os projeteis ativos do array de projeteis inimigos, atualizando seus contadores de movimento e sua posicao atual
; 
;---------------------------------------------------------
AtualizaTirosInimigos PROC
		pushad
		mov ecx, maxTirosInimigos
		mov esi, 0
	lAtualizaTirosInimigos:
		cmp tirosInimigos[esi].disponivel, 0
		je fimAtualizaTiroInimigo
		
		add tirosInimigos[esi].contadorTempoMovimentoX, tempoDelay
		add tirosInimigos[esi].contadorTempoMovimentoY, tempoDelay
		
		mov eax, tirosInimigos[esi].velocidadeX
		cmp eax, 0
		jle naoSeMovimentaX_tiroInimigo
		cmp tirosInimigos[esi].contadorTempoMovimentoX, eax
		jl naoSeMovimentaX_tiroInimigo
		cmp tirosInimigos[esi].dirX, 0
		jg movimentaXPositivo_tiroInimigo
		cmp tirosInimigos[esi].dirX, 0
		jl movimentaXNegativo_tiroInimigo
		jmp fimMovimentaX_tiroInimigo
		
	movimentaXPositivo_tiroInimigo:
		inc tirosInimigos[esi].x
		cmp tirosInimigos[esi].x, largura-1
		jl naoPassouLargura_tiroInimigo
		mov tirosInimigos[esi].disponivel, 0
	naoPassouLargura_tiroInimigo:
		jmp fimMovimentaX_tiroInimigo
		
	movimentaXNegativo_tiroInimigo:
		dec tirosInimigos[esi].x
		cmp tirosInimigos[esi].x, 0
		jg naoPassouLargura0_tiroInimigo
		mov tirosInimigos[esi].disponivel, 0
	naoPassouLargura0_tiroInimigo:
		jmp fimMovimentaX_tiroInimigo
		
	fimMovimentaX_tiroInimigo:
		mov tirosInimigos[esi].contadorTempoMovimentoX, 0
		
	naoSeMovimentaX_tiroInimigo:
	
		mov eax, tirosInimigos[esi].velocidadeY
		cmp eax, 0
		jle naoSeMovimentaY_tiroInimigo
		cmp tirosInimigos[esi].contadorTempoMovimentoY, eax
		jl naoSeMovimentaY_tiroInimigo
		cmp tirosInimigos[esi].dirY, 0
		jg movimentaYPositivo_tiroInimigo
		cmp tirosInimigos[esi].dirY, 0
		jl movimentaYNegativo_tiroInimigo
		jmp fimMovimentaY_tiroInimigo
		
	movimentaYPositivo_tiroInimigo:
		inc tirosInimigos[esi].y
		cmp tirosInimigos[esi].y, altura-1
		jl naoPassouAltura_tiroInimigo
		mov tirosInimigos[esi].disponivel, 0
	naoPassouAltura_tiroInimigo:
		jmp fimMovimentaY_tiroInimigo
		
	movimentaYNegativo_tiroInimigo:
		dec tirosInimigos[esi].y
		cmp tirosInimigos[esi].y, 1
		jg naoPassouAltura0_tiroInimigo
		mov tirosInimigos[esi].disponivel, 0
	naoPassouAltura0_tiroInimigo:
		jmp fimMovimentaY_tiroInimigo
		
	fimMovimentaY_tiroInimigo:
		mov tirosInimigos[esi].contadorTempoMovimentoY, 0
		
	naoSeMovimentaY_tiroInimigo:
	
	fimAtualizaTiroInimigo:
		
		add esi, TYPE PROJETIL
		dec ecx
		jne lAtualizaTirosInimigos
		popad
		ret
AtualizaTirosInimigos ENDP

;---------------------------------------------------------
; AtualizaInimigos
; 
; Atualiza os inimigos ativos do array de inimigos, atualizando seus contadores de movimento e ataque, posicao atual e vida
; 
;---------------------------------------------------------
AtualizaInimigos PROC
		pushad
		
		mov ecx, largura*altura
		mov esi, 0
	limpaBufferInimigos:
		mov bufferInimigos[esi], 0
		inc esi
		loop limpaBufferInimigos
		
		mov ecx, maxInimigos
		mov esi, 0
	lAtualizaInimigos:
		cmp inimigos[esi].disponivel, 0
		je fimAtualizaInimigo
		
		add inimigos[esi].contadorTempoMovimentoX, tempoDelay
		add inimigos[esi].contadorTempoMovimentoY, tempoDelay
		add inimigos[esi].contadorTempoAtaque, tempoDelay
		
		
		mov eax, inimigos[esi].velocidadeX
		cmp eax, 0
		jle naoSeMovimentaX
		cmp inimigos[esi].contadorTempoMovimentoX, eax
		jl naoSeMovimentaX
		cmp inimigos[esi].dirX, 0
		jg movimentaXPositivo
		cmp inimigos[esi].dirX, 0
		jl movimentaXNegativo
		jmp fimMovimentaX
		
	movimentaXPositivo:
		inc inimigos[esi].x
		cmp inimigos[esi].x, largura-5
		jl inimigoNaoPassouLargura
		mov inimigos[esi].x, largura-5
		neg inimigos[esi].dirX
	inimigoNaoPassouLargura:
		jmp fimMovimentaX
		
	movimentaXNegativo:
		dec inimigos[esi].x
		cmp inimigos[esi].x, 1
		jg inimigoNaoPassouLargura0
		mov inimigos[esi].x, 2
		neg inimigos[esi].dirX
	inimigoNaoPassouLargura0:
		jmp fimMovimentaX
		
	fimMovimentaX:
		sub inimigos[esi].contadorTempoMovimentoX, eax
		
	naoSeMovimentaX:
	
		mov eax, inimigos[esi].velocidadeY
		cmp eax, 0
		jle naoSeMovimentaY
		cmp inimigos[esi].contadorTempoMovimentoY, eax
		jl naoSeMovimentaY
		cmp inimigos[esi].dirY, 0
		jg movimentaYPositivo
		cmp inimigos[esi].dirY, 0
		jl movimentaYNegativo
		jmp fimMovimentaY
		
	movimentaYPositivo:
		inc inimigos[esi].y
		cmp inimigos[esi].y, altura-3
		jle inimigoNaoPassouAltura
		mov inimigos[esi].y, altura-3
		neg inimigos[esi].dirY
	inimigoNaoPassouAltura:
		jmp fimMovimentaY
		
	movimentaYNegativo:
		dec inimigos[esi].y
		cmp inimigos[esi].y, 2
		jge inimigoNaoPassouAltura0
		mov inimigos[esi].y, 2
		neg inimigos[esi].dirY
	inimigoNaoPassouAltura0:
		jmp fimMovimentaY
		
	fimMovimentaY:
		sub inimigos[esi].contadorTempoMovimentoY, eax
		
	naoSeMovimentaY:
	
		inc inimigos[esi].bracoEsquerdo
		cmp inimigos[esi].bracoEsquerdo, velocidadeBracosInimigos
		jl naoAtualizaBracoEsquerdo
			mov inimigos[esi].bracoEsquerdo, 0
		
		naoAtualizaBracoEsquerdo:
		inc inimigos[esi].bracoDireito
		cmp inimigos[esi].bracoDireito, velocidadeBracosInimigos
		jl naoAtualizaBracoDireito
			mov inimigos[esi].bracoDireito, 0
			
		naoAtualizaBracoDireito:
		
		mov eax, inimigos[esi].x
		mov ebx, inimigos[esi].y
		INVOKE AtualizaBufferInimigos, eax, ebx
		inc eax
		INVOKE AtualizaBufferInimigos, eax, ebx
		inc eax
		INVOKE AtualizaBufferInimigos, eax, ebx
		mov eax, inimigos[esi].x
		inc ebx
		INVOKE AtualizaBufferInimigos, eax, ebx
		inc eax
		INVOKE AtualizaBufferInimigos, eax, ebx
		inc eax
		INVOKE AtualizaBufferInimigos, eax, ebx
		
		mov eax, inimigos[esi].velocidadeAtaqueAtual
		cmp inimigos[esi].contadorTempoAtaque, eax
		jl fimAtaque_inimigo
		
		mov inimigos[esi].contadorTempoAtaque, 0
		
		mov eax, inimigos[esi].variacaoVelocidadeAtaque
		call RandomRange
		neg eax
		add eax, inimigos[esi].velocidadeAtaqueMaxima
		mov inimigos[esi].velocidadeAtaqueAtual, eax 
		
		cmp inimigos[esi].tipo, 0
		je ataqueInimigo0
		cmp inimigos[esi].tipo, 1
		je ataqueInimigo1
		cmp inimigos[esi].tipo, 2
		je ataqueInimigo2
	ataqueInimigo0:
		mov eax, inimigos[esi].x
		inc eax
		mov ebx, inimigos[esi].y
		mov edx, 0
		mov dx, inimigos[esi].cor
		shr dx, 4
		INVOKE AdicionaProjetilInimigo, eax, ebx, 100, inimigos[esi].velocidadeTirosY, 0, 1, dx
		jmp fimAtaque_inimigo
	ataqueInimigo1:
		mov eax, inimigos[esi].x
		inc eax
		mov ebx, inimigos[esi].y
		mov edx, 0
		mov dx, inimigos[esi].cor
		shr dx, 4
		INVOKE AdicionaProjetilInimigo, eax, ebx, 100, inimigos[esi].velocidadeTirosY, 0, 1, dx
		jmp fimAtaque_inimigo
	ataqueInimigo2:
		mov eax, inimigos[esi].x
		inc eax
		mov ebx, inimigos[esi].y
		mov dx, inimigos[esi].cor
		INVOKE AdicionaProjetilInimigo, eax, ebx, inimigos[esi].velocidadeTirosX, inimigos[esi].velocidadeTirosY, -1, 1, dx
		INVOKE AdicionaProjetilInimigo, eax, ebx, 0, inimigos[esi].velocidadeTirosY, 1, 1, dx
		INVOKE AdicionaProjetilInimigo, eax, ebx, inimigos[esi].velocidadeTirosX, inimigos[esi].velocidadeTirosY, 1, 1, dx
		jmp fimAtaque_inimigo	
		
	fimAtaque_inimigo:
	
	fimAtualizaInimigo:
		
		add esi, TYPE INIMIGO
		dec ecx
		jne lAtualizaInimigos
		
		popad
		ret
AtualizaInimigos ENDP

;---------------------------------------------------------
; VerificaColisoesPlayer
; 
; Verifica se ha colisao entre o jogador e os inimigos
; No caso de uma colisao com um inimigo, o jogador perde uma vida
; No caso de uma colisao com um projetil inimigo, o jogador perde uma vida e o projetil e desativado
; Se o player perder todas as vidas entao o estado e mudado para 2, que significa GameOver
;
;---------------------------------------------------------
VerificaColisoesPlayer PROC
		pushad
		cmp invulnerabilidadePlayer, tempoIvulnerabilidadePlayer
		jl fimColisaoPlayer
		mov eax, playerX
		mov ebx, playerY
		inc eax
		INVOKE GetBufferInimigos, playerX, playerY
		cmp dl, 1
		je colisaoPlayer
		
		inc eax
		INVOKE GetBufferInimigos, eax, ebx
		cmp dl, 1
		je colisaoPlayer
		
		inc eax
		INVOKE GetBufferInimigos, eax, ebx
		cmp dl, 1
		je colisaoPlayer
		
		mov eax, playerX
		inc ebx
		INVOKE GetBufferInimigos, eax, ebx
		cmp dl, 1
		je colisaoPlayer
		
		inc eax
		INVOKE GetBufferInimigos, eax, ebx
		cmp dl, 1
		je colisaoPlayer
		
		inc eax
		INVOKE GetBufferInimigos, eax, ebx
		cmp dl, 1
		je colisaoPlayer
		
		inc eax
		INVOKE GetBufferInimigos, eax, ebx
		cmp dl, 1
		je colisaoPlayer
		
		inc eax
		INVOKE GetBufferInimigos, eax, ebx
		cmp dl, 1
		je colisaoPlayer
		
		mov ecx, maxTirosInimigos
		mov esi, 0
	loopColisaoPlayerTiros:
		cmp invulnerabilidadePlayer, tempoIvulnerabilidadePlayer
		jl fimColisaoPlayer
		cmp tirosInimigos[esi].disponivel, 1
		jne fimVerificaColisaoPlayerTiro
		mov eax, playerX
		inc eax
		mov ebx, playerY
		cmp tirosInimigos[esi].x, eax
		jne verificaProximaParte0
		cmp tirosInimigos[esi].y, ebx
		jne verificaProximaParte0
		mov tirosInimigos[esi].disponivel, 0
		jmp colisaoPlayer
	verificaProximaParte0:
		inc eax
		cmp tirosInimigos[esi].x, eax
		jne verificaProximaParte1
		cmp tirosInimigos[esi].y, ebx
		jne verificaProximaParte1
		mov tirosInimigos[esi].disponivel, 0
		jmp colisaoPlayer
	verificaProximaParte1:
		inc eax
		cmp tirosInimigos[esi].x, eax
		jne verificaProximaParte2
		cmp tirosInimigos[esi].y, ebx
		jne verificaProximaParte2
		mov tirosInimigos[esi].disponivel, 0
		jmp colisaoPlayer
	verificaProximaParte2:
		mov eax, playerX
		inc ebx
		cmp tirosInimigos[esi].x, eax
		jne verificaProximaParte3
		cmp tirosInimigos[esi].y, ebx
		jne verificaProximaParte3
		mov tirosInimigos[esi].disponivel, 0
		jmp colisaoPlayer
	verificaProximaParte3:
		inc eax
		cmp tirosInimigos[esi].x, eax
		jne verificaProximaParte4
		cmp tirosInimigos[esi].y, ebx
		jne verificaProximaParte4
		mov tirosInimigos[esi].disponivel, 0
		jmp colisaoPlayer
	verificaProximaParte4:
		inc eax
		cmp tirosInimigos[esi].x, eax
		jne verificaProximaParte5
		cmp tirosInimigos[esi].y, ebx
		jne verificaProximaParte5
		mov tirosInimigos[esi].disponivel, 0
		jmp colisaoPlayer
	verificaProximaParte5:
		inc eax
		cmp tirosInimigos[esi].x, eax
		jne verificaProximaParte6
		cmp tirosInimigos[esi].y, ebx
		jne verificaProximaParte6
		mov tirosInimigos[esi].disponivel, 0
		jmp colisaoPlayer
	verificaProximaParte6:
		inc eax
		cmp tirosInimigos[esi].x, eax
		jne fimVerificaColisaoPlayerTiro
		cmp tirosInimigos[esi].y, ebx
		jne fimVerificaColisaoPlayerTiro
		mov tirosInimigos[esi].disponivel, 0
		jmp colisaoPlayer
	fimVerificaColisaoPlayerTiro:
	
		add esi, TYPE PROJETIL
		dec ecx
		jne loopColisaoPlayerTiros
		
		jmp fimColisaoPlayer
	colisaoPlayer:
		dec vidaPlayer
		INVOKE PlaySound, OFFSET somPerdeu, NULL, SND_FILENAME
		mov invulnerabilidadePlayer, 0
		cmp vidaPlayer, -1
		jne fimColisaoPlayer
		
		mov estado, 2
		
		mov eax, nivel
		cmp eax, recordeNivel
		jle naoMudaRecordeNivel
		mov recordeNivel, eax
	naoMudaRecordeNivel:
		mov eax, pontos
		cmp eax, recordePontos
		jle naoMudaRecordePontos
		mov recordePontos, eax
	naoMudaRecordePontos:
	
	fimColisaoPlayer:
		popad
		ret
VerificaColisoesPlayer ENDP

;---------------------------------------------------------
; VerificaColisoesInimigos
; 
; Verifica se ha colisao entre cada inimigo ativo e cada projetil ativo do jogador
; No caso de uma colisao, o inimigo perde uma vida e o projetil e desativado
; Se a vida do inimigo ficar menor ou igual a 0 entao ele e desativado
;
;---------------------------------------------------------
VerificaColisoesInimigos PROC
		pushad
		
		mov ecx, maxInimigos
		mov esi, 0
	lVerificaColisoesInimigos:
		cmp inimigos[esi].disponivel, 0
		je fimVerificaColisoesInimigos
		push ecx
		mov ecx, maxTirosOta
		mov ebx, 0
	lVerificaColisoesInimigos_Tiros:

		cmp inimigos[esi].disponivel, 0
		je fimVerificaColisoesInimigos_Tiros
	
		cmp tirosOta[ebx].disponivel, 0
		je fimVerificaColisoesInimigos_Tiros
		
		mov eax, inimigos[esi].x
		dec eax
		cmp tirosOta[ebx].x, eax
		jl fimVerificaColisoesInimigos_Tiros
		add eax, 4
		cmp tirosOta[ebx].x, eax
		jg fimVerificaColisoesInimigos_Tiros
		
		mov eax, inimigos[esi].y
		cmp tirosOta[ebx].y, eax
		jl fimVerificaColisoesInimigos_Tiros
		add eax, 1
		cmp tirosOta[ebx].y, eax
		jg fimVerificaColisoesInimigos_Tiros
		
		dec inimigos[esi].vida
		mov tirosOta[ebx].disponivel, 0
		
		cmp nivel, 11
		jne naoEstaNoNivel11
		inc pontos
	naoEstaNoNivel11:
		
		cmp inimigos[esi].vida, 0
		jg inimigoNaoMorreu
		mov inimigos[esi].disponivel, 0
		dec qtdInimigos
		inc pontos
		
	inimigoNaoMorreu:
		jg fimVerificaColisoesInimigos_Tiros
		
	fimVerificaColisoesInimigos_Tiros:
		add ebx, TYPE PROJETIL
		dec ecx
		jne lVerificaColisoesInimigos_Tiros
		pop ecx
	fimVerificaColisoesInimigos:
		add esi, TYPE INIMIGO
		dec ecx
		jne lVerificaColisoesInimigos
		
		popad
		ret
VerificaColisoesInimigos ENDP

;---------------------------------------------------------
; VerificaInputMain
;
; Verifica e trata os inputs recebidos do teclado na tela inicial do jogo
; 
;---------------------------------------------------------
VerificaInputInicial PROC
		pushad
		
		call ReadKey
		jz fimInputInicial
		
		cmp dx, VK_RETURN
		je key_enter_inicial
		cmp dx, VK_ESCAPE
		je key_esc_inicial
		
		jmp fimInputInicial
		
	key_enter_inicial:
		INVOKE PlaySound, OFFSET somEnter, NULL, SND_FILENAME
		call IniciaNovaPartida
		jmp fimInputInicial
	key_esc_inicial:
		mov quit, 1
		jmp fimInputInicial
		
	fimInputInicial:
	
		popad
		ret
VerificaInputInicial ENDP

;---------------------------------------------------------
; VerificaInputMain
;
; Verifica e trata os inputs recebidos do teclado na tela do jogo em execucao
; 
;---------------------------------------------------------
VerificaInputMain PROC
		pushad
		
		call ReadKey
		jz fimInputMain
		
		cmp dx, VK_RIGHT
		je key_direita
		cmp dx, VK_LEFT
		je key_esquerda
		cmp dx, VK_UP
		je key_cima
		cmp dx, VK_DOWN
		je key_baixo
		cmp dx, VK_SPACE
		je key_espaco
		cmp dx, VK_RETURN
		je key_enter
		cmp dx, VK_ESCAPE
		je key_esc
		
		jmp fimInputMain
		
	key_direita:
		add playerX, 2
		cmp playerX, largura-6
		jl naoPassouLargura
		mov playerX, largura-6
	naoPassouLargura:
		jmp fimInputMain
		
	key_esquerda:
		sub playerX, 2
		cmp playerX, 0
		jg naoPassouLargura0
		mov playerX, 1
	naoPassouLargura0:
		jmp fimInputMain
		
	key_cima:
		sub playerY, 1
		cmp playerY, 1
		jg naoPassouAltura0
		mov playerY, 2
	naoPassouAltura0:
		jmp fimInputMain
	
	key_baixo:
		add playerY, 1
		cmp playerY, altura-3
		jl naoPassouAltura
		mov playerY, altura-3
	naoPassouAltura:
		jmp fimInputMain
		
	key_espaco:
		mov eax, tempoAtaquePlayer
		cmp cooldownAtaquePlayer, eax
		jl naoAtaca
		mov cooldownAtaquePlayer, 0
		INVOKE PlaySound, OFFSET somAtirou, NULL, SND_FILENAME
		mov eax, playerX
		add eax, 2
		mov ebx, playerY
		push eax
		INVOKE AdicionaProjetilPlayer, eax, ebx, 0, velocidadeTirosPlayer, 1, -1, corTirosPlayer
		pop eax
	naoAtaca:
		jmp fimInputMain
		
	key_enter:
		call clrscr
		jmp fimInputMain
	key_esc:
		mov quit, 1
		jmp fimInputMain
		
	fimInputMain:

		popad
		ret
VerificaInputMain ENDP

;---------------------------------------------------------
; VerificaInputGameOver
;
; Verifica e trata os inputs recebidos do teclado na tela de GameOver
; 
;---------------------------------------------------------
VerificaInputGameOver PROC
		pushad
		
		call ReadKey
		jz fimInputGameOver
		
		cmp dx, VK_RETURN
		je key_enter_gameover
		cmp dx, VK_ESCAPE
		je key_esc_gameover
		
		jmp fimInputGameOver
		
	key_enter_gameover:
		mov estado, 0
		INVOKE PlaySound, OFFSET somEnter, NULL, SND_FILENAME
		jmp fimInputGameOver
	key_esc_gameover:
		mov quit, 1
		jmp fimInputGameOver
		
	fimInputGameOver:
	
		popad
		ret
VerificaInputGameOver ENDP

;---------------------------------------------------------
; DelayJogo
;
; Verifica a diferenca de tempo entre a chamada atual e a ultima chamada na qual a funcao retornou 1
; Utilizada para controlar o fps do jogo
; Retorna: 	0 em ebx se a diferenca for menor que a constante tempoDelay
;			1 em ebx se a diferenca for maior ou igual que a constante tempoDelay
;
;---------------------------------------------------------
DelayJogo PROC
		push ecx
		push eax
		call GetMseconds
		sub eax, tempoAnterior
		cmp eax, tempoDelay
		jl retornaFalso
		mov ebx, 1
		add tempoAnterior, tempoDelay
		jmp fimDelayJogo
	retornaFalso:
		mov ebx, 0
	fimDelayJogo:
		pop eax
		pop ecx
		ret
DelayJogo ENDP

;---------------------------------------------------------
; LimpaTela
;
; Limpa o buffer da matriz da tela
; 
;---------------------------------------------------------
LimpaTela PROC
		pushad
		mov ecx, 0
	loopLimpaTela:
		mov buffer[ecx * type CHAR_INFO].Char, ' '
		mov ax, corOriginal
		mov buffer[ecx * type CHAR_INFO].Attributes, ax
		inc ecx
		cmp ecx, largura*altura
		jne loopLimpaTela
		popad
		ret
LimpaTela ENDP

;---------------------------------------------------------
; DesenhaPlayer
;
; Atualiza o desenho do player no buffer da tela baseado nas suas coordenadas atuais
;
;---------------------------------------------------------
DesenhaPlayer PROC
		pushad
		mov eax, playerX
		mov ebx, playerY
		add eax, 1
		INVOKE DesenhaCaractere, 220, eax, ebx, red+(black*16)
		inc eax
		INVOKE DesenhaCaractere, 219, eax, ebx, blue+(black*16)
		inc eax
		INVOKE DesenhaCaractere, 220, eax, ebx, red+(black*16)
		mov eax, playerX
		inc ebx
		INVOKE DesenhaCaractere, 219, eax, ebx, blue+(black*16)
		inc eax
		INVOKE DesenhaCaractere, 'O', eax, ebx, 144
		inc eax
		INVOKE DesenhaCaractere, 'T', eax, ebx, 144
		inc eax
		INVOKE DesenhaCaractere, 'A', eax, ebx, 144
		inc eax
		INVOKE DesenhaCaractere, 219, eax, ebx, blue+(black*16)
		
		popad
		ret
DesenhaPlayer ENDP

;---------------------------------------------------------
; DesenhaTirosPlayer
;
; Atualiza o desenho dos tiros do player no buffer da tela baseado nas coordenadas atuais deles
;
;---------------------------------------------------------
DesenhaTirosPlayer PROC
		pushad
		mov ecx, maxTirosOta
		mov esi, 0
	loopDesenhaTirosPlayer:
		cmp tirosOta[esi].disponivel, 0
		je naoDesenhaTiroPlayer
		INVOKE DesenhaCaractere, 219, tirosOta[esi].x, tirosOta[esi].y, tirosOta[esi].cor
	naoDesenhaTiroPlayer:
		add esi, TYPE PROJETIL
		loop loopDesenhaTirosPlayer
		popad
		ret
DesenhaTirosPlayer ENDP

;---------------------------------------------------------
; DesenhaTirosInimigos
;
; Atualiza o desenho dos tiros inimigos no buffer da tela baseado nas coordenadas atuais deles
;
;---------------------------------------------------------
DesenhaTirosInimigos PROC
		pushad
		mov ecx, maxTirosInimigos
		mov esi, 0
	lDesenhaTirosInimigos:
		cmp tirosInimigos[esi].disponivel, 0
		je naoDesenhaTiroInimigo
		INVOKE DesenhaCaractere, 219, tirosInimigos[esi].x, tirosInimigos[esi].y, tirosInimigos[esi].cor
	naoDesenhaTiroInimigo:
		add esi, TYPE PROJETIL
		loop lDesenhaTirosInimigos
		popad
		ret
DesenhaTirosInimigos ENDP

;---------------------------------------------------------
; DesenhaInimigos
;
; Atualiza o desenho dos inimigos no buffer da tela baseado nas coordenadas atuais deles
; 
;---------------------------------------------------------
DesenhaInimigos PROC
		pushad
		mov ecx, maxInimigos
		mov esi, 0
	loopDesenhaInimigos:
		cmp inimigos[esi].disponivel, 0
		je fimDesenhaInimigo
		mov dx, inimigos[esi].cor
		cmp inimigos[esi].tipo, 0
		je desenhaInimigoTipo0
		cmp inimigos[esi].tipo, 1
		je desenhaInimigoTipo1
		cmp inimigos[esi].tipo, 2
		je desenhaInimigoTipo2
	desenhaInimigoTipo0:
		mov eax, inimigos[esi].x
		mov ebx, inimigos[esi].y
		INVOKE DesenhaCaractere, '|', eax, ebx, dx
		inc eax
		INVOKE DesenhaCaractere, ' ', eax, ebx, dx
		inc eax
		INVOKE DesenhaCaractere, '|', eax, ebx, dx
		mov eax, inimigos[esi].x
		inc ebx
		INVOKE DesenhaCaractere, ' ', eax, ebx, dx
		add eax, 1
		INVOKE DesenhaCaractere, '^', eax, ebx, dx
		add eax, 1
		INVOKE DesenhaCaractere, ' ', eax, ebx, dx
		jmp fimDesenhaInimigo
		
	desenhaInimigoTipo1:
		mov eax, inimigos[esi].x
		mov ebx, inimigos[esi].y
		INVOKE DesenhaCaractere, ';', eax, ebx, dx
		inc eax
		INVOKE DesenhaCaractere, ' ', eax, ebx, dx
		inc eax
		INVOKE DesenhaCaractere, ';', eax, ebx, dx
		mov eax, inimigos[esi].x
		inc ebx
		INVOKE DesenhaCaractere, ' ', eax, ebx, dx
		add eax, 1
		INVOKE DesenhaCaractere, '~', eax, ebx, dx
		add eax, 1
		INVOKE DesenhaCaractere, ' ', eax, ebx, dx
		jmp fimDesenhaInimigo
		
	desenhaInimigoTipo2:
		and dx, 000Fh
		mov eax, inimigos[esi].x
		mov ebx, inimigos[esi].y
		INVOKE DesenhaCaractere, '\', eax, ebx, dx
		inc eax
		INVOKE DesenhaCaractere, ' ', eax, ebx, dx
		inc eax
		INVOKE DesenhaCaractere, '/', eax, ebx, dx
		mov eax, inimigos[esi].x
		inc ebx
		INVOKE DesenhaCaractere, ' ', eax, ebx, dx
		add eax, 1
		INVOKE DesenhaCaractere, 238, eax, ebx, dx
		add eax, 1
		INVOKE DesenhaCaractere, ' ', eax, ebx, dx
		jmp fimDesenhaInimigo
		
	fimDesenhaInimigo:
		add esi, TYPE INIMIGO
		dec ecx
		jne loopDesenhaInimigos
		popad
		ret
DesenhaInimigos ENDP

;---------------------------------------------------------
; DesenhaInimigos
;
; Atualiza o desenho dos bracos dos inimigos no buffer da tela baseado nas coordenadas atuais deles
; 
;---------------------------------------------------------
DesenhaBracosInimigos PROC
		pushad
		mov ecx, maxInimigos
		mov esi, 0
	loopDesenhaBracosInimigos:
		cmp inimigos[esi].disponivel, 0
		je fimDesenhaBracoInimigo
		xor edx, edx
		mov dx, inimigos[esi].cor
		cmp inimigos[esi].tipo, 0
		je desenhaBracoInimigoTipo0
		cmp inimigos[esi].tipo, 1
		je desenhaBracoInimigoTipo1
		cmp inimigos[esi].tipo, 2
		je desenhaBracoInimigoTipo2
	desenhaBracoInimigoTipo0:
		shr dx, 4
		mov eax, inimigos[esi].x
		mov ebx, inimigos[esi].y
		dec eax
		cmp inimigos[esi].bracoEsquerdo, velocidadeBracosInimigos/2
		jl pulaBracoEsquerdoCima0
		INVOKE DesenhaCaractere, '\', eax, ebx, dx
	pulaBracoEsquerdoCima0:
		add eax, 4
		cmp inimigos[esi].bracoDireito, velocidadeBracosInimigos/2
		jl pulaBracoDireitoCima0
		INVOKE DesenhaCaractere, '/', eax, ebx, dx
	pulaBracoDireitoCima0:
		mov eax, inimigos[esi].x
		inc ebx
		dec eax
		cmp inimigos[esi].bracoEsquerdo, velocidadeBracosInimigos/2
		jge pulaBracoEsquerdoBaixo0 
		INVOKE DesenhaCaractere, '/', eax, ebx, dx
	pulaBracoEsquerdoBaixo0:
		add eax, 4
		cmp inimigos[esi].bracoDireito, velocidadeBracosInimigos/2
		jge pulaBracoDireitoBaixo0
		INVOKE DesenhaCaractere, '\', eax, ebx, dx
	pulaBracoDireitoBaixo0:
		jmp fimDesenhaBracoInimigo
		
	desenhaBracoInimigoTipo1:
		shr dx, 4
		mov eax, inimigos[esi].x
		mov ebx, inimigos[esi].y
		dec eax
		cmp inimigos[esi].bracoEsquerdo, velocidadeBracosInimigos/2
		jl pulaBracoEsquerdoCima1
		INVOKE DesenhaCaractere, '~', eax, ebx, dx
	pulaBracoEsquerdoCima1:
		add eax, 4
		cmp inimigos[esi].bracoDireito, velocidadeBracosInimigos/2
		jl pulaBracoDireitoCima1
		INVOKE DesenhaCaractere, '~', eax, ebx, dx
	pulaBracoDireitoCima1:
		mov eax, inimigos[esi].x
		inc ebx
		dec eax
		cmp inimigos[esi].bracoEsquerdo, velocidadeBracosInimigos/2
		jge pulaBracoEsquerdoBaixo1
		INVOKE DesenhaCaractere, '~', eax, ebx, dx
	pulaBracoEsquerdoBaixo1:
		add eax, 4
		cmp inimigos[esi].bracoDireito, velocidadeBracosInimigos/2
		jge pulaBracoDireitoBaixo1
		INVOKE DesenhaCaractere, '~', eax, ebx, dx
	pulaBracoDireitoBaixo1:
		jmp fimDesenhaBracoInimigo
		
	desenhaBracoInimigoTipo2:
		and dx, 000Fh
		mov eax, inimigos[esi].x
		mov ebx, inimigos[esi].y
		dec eax
		cmp inimigos[esi].bracoEsquerdo, velocidadeBracosInimigos/2
		jl pulaBracoEsquerdoCima2
		INVOKE DesenhaCaractere, '~', eax, ebx, dx
	pulaBracoEsquerdoCima2:
		add eax, 4
		cmp inimigos[esi].bracoDireito, velocidadeBracosInimigos/2
		jl pulaBracoDireitoCima2
		INVOKE DesenhaCaractere, '~', eax, ebx, dx
	pulaBracoDireitoCima2:
		mov eax, inimigos[esi].x
		inc ebx
		dec eax
		cmp inimigos[esi].bracoEsquerdo, velocidadeBracosInimigos/2
		jge pulaBracoEsquerdoBaixo2
		INVOKE DesenhaCaractere, '~', eax, ebx, dx
	pulaBracoEsquerdoBaixo2:
		add eax, 4
		cmp inimigos[esi].bracoDireito, velocidadeBracosInimigos/2
		jge pulaBracoDireitoBaixo2
		INVOKE DesenhaCaractere, '~', eax, ebx, dx
	pulaBracoDireitoBaixo2:
		jmp fimDesenhaBracoInimigo
		
	fimDesenhaBracoInimigo:
		add esi, TYPE INIMIGO
		dec ecx
		jne loopDesenhaBracosInimigos
		popad
		ret
DesenhaBracosInimigos ENDP

;---------------------------------------------------------
; DesenhaBordas
;
; Atualiza o desenho das bordas do jogo no buffer da tela 
;
;---------------------------------------------------------
DesenhaBordas PROC
		pushad
		
		mov ecx, 0
	loopBordasHorizontais:
		INVOKE DesenhaCaractere, 223, ecx, 1, corBordas
		INVOKE DesenhaCaractere, 223, ecx, altura-1, corBordas
		inc ecx
		cmp ecx, largura
		jne loopBordasHorizontais
		
		mov ecx, 1
	loopBordasVerticais:
		INVOKE DesenhaCaractere, 219, 0, ecx, corBordas
		INVOKE DesenhaCaractere, 219, largura-1, ecx, corBordas
		inc ecx
		cmp ecx, altura-1
		jne loopBordasVerticais
		popad
		ret
DesenhaBordas ENDP

;---------------------------------------------------------
; AtualizaTela
;
; Imprime no console o buffer da matriz da tela atual
;
;---------------------------------------------------------
AtualizaTela PROC
		pushad
		INVOKE WriteConsoleOutput, outHandle, ADDR buffer, bufferSize, bufferCoord, ADDR region
		popad
		ret
AtualizaTela ENDP

;---------------------------------------------------------
; DesenhaCaractere
;
; Atualiza um caractere especifico no buffer da tela
; Recebe: o codigo ascii do caractere, suas coordenadas (x, y) e a cor
;
;---------------------------------------------------------
DesenhaCaractere PROC, char:BYTE, x:DWORD, y:DWORD, color:WORD
		pushad
		mov eax, y
		mov ebx, largura
		mul ebx
		add eax, x
		mov bx, WORD PTR char
		mov buffer[eax * TYPE CHAR_INFO].Char, bx
		mov bx, color
		mov buffer[eax * TYPE CHAR_INFO].Attributes, bx
		popad
		ret
DesenhaCaractere ENDP

;---------------------------------------------------------
; DesenhaTelaInicial
;
; Atualiza o desenho da tela inicial do jogo no buffer da tela 
;
;---------------------------------------------------------
DesenhaTelaInicial PROC
		pushad
		mov ecx, largura*altura
		mov esi, 0
	loopDesenhaTelaIncial:
		mov ax, WORD PTR telaInicial[esi]
		mov buffer[esi * TYPE CHAR_INFO].Char, ax
		mov buffer[esi * TYPE CHAR_INFO].Attributes, 11
		inc esi
		loop loopDesenhaTelaIncial
		popad
		ret
DesenhaTelaInicial ENDP

;---------------------------------------------------------
; DesenhaNumero
; 
; Escreve um numero no buffer da matriz da tela, comecando na coordenada (x, y)
; Recebe: o numero a ser escrito, as coordenadas x, y e a cor da fonte
; 
;---------------------------------------------------------
DesenhaNumero PROC, numero:DWORD, x:DWORD, y:DWORD, cor:WORD
		pushad
		mov esi, -1
		mov eax, numero
		mov ebx, 10
	loopGeraNumero:
		inc esi
		mov edx, 0
		div ebx
		add dl, 48
		mov bufferAux[esi], dl
		cmp eax, 0
		jg loopGeraNumero 
			
		mov eax, x
		mov ebx, y
		mov cx, cor
	loopDesenhaNumero:
		mov dl, bufferAux[esi]
		push eax
		INVOKE DesenhaCaractere, dl, eax, ebx, cx
		pop eax
		dec esi
		inc eax
		cmp esi, 0
		jge loopDesenhaNumero
		
		popad
		ret
DesenhaNumero ENDP

;---------------------------------------------------------
; DesenhaString
; 
; Escreve uma string no buffer da matriz da tela, comecando na coordenada (x, y)
; Recebe: o endereco da string a ser escrita, as coordenadas x, y e a cor da fonte
; 
;---------------------------------------------------------
DesenhaString PROC, string:DWORD, x:DWORD, y:DWORD, cor:WORD
		pushad
		mov esi, string
	loopDesenhaString:
		cmp BYTE PTR [esi], 0
		jle fimDesenhaString
		INVOKE DesenhaCaractere, [esi], x, y, cor
		inc esi
		inc x
		jmp loopDesenhaString
	fimDesenhaString:
		popad
		ret
DesenhaString ENDP

;---------------------------------------------------------
; DesenhaTelaGameOver
;
; Atualiza o desenho da tela de GameOver no buffer da tela 
;
;---------------------------------------------------------
DesenhaTelaGameOver PROC
		pushad
		mov ecx, largura*altura
		mov esi, 0
	loopDesenhaTelaGameOver:
		mov ax, WORD PTR telaGameOver[esi]
		mov buffer[esi * TYPE CHAR_INFO].Char, ax
		mov buffer[esi * TYPE CHAR_INFO].Attributes, 11
		inc esi
		loop loopDesenhaTelaGameOver
		popad
		ret
DesenhaTelaGameOver ENDP



;---------------------------------------------------------
; FinalizaJogo
; 
; Funcao chamada quando o jogo e desligado
; Limpa a tela e deixa o cursor visivel novamente
; 
;---------------------------------------------------------
FinalizaJogo PROC
		pushad
		call clrscr
		mov cursorInfo.bVisible, 1
		INVOKE SetConsoleCursorInfo, outHandle, ADDR cursorInfo
		popad
		ret
FinalizaJogo ENDP

;---------------------------------------------------------
; AtualizaBufferInimigos
; 
; Atualiza as posicoes de todos os inimigos no bufferInimigos
; Esse buffer de posicoes e necessario para a verificacao de colisao entre o jogador e os inimigos
; 
;---------------------------------------------------------
AtualizaBufferInimigos PROC, x:DWORD, y:DWORD
		pushad
		mov eax, y
		mov ebx, largura
		mul ebx
		add eax, x
		mov bufferInimigos[eax], 1
		popad
		ret
AtualizaBufferInimigos ENDP

;---------------------------------------------------------
; GetBufferInimigos
; 
; Retorna o valor da posicao (x, y) do bufferInimigos para saber se existe um inimigo nessa posicao
; Recebe: as coordenadas x e y
; Retorna: o valor da posicao (x, y) do bufferInimigos em dl
; 
;---------------------------------------------------------
GetBufferInimigos PROC, x:DWORD, y:DWORD
		push eax
		push ebx
		mov eax, y
		mov ebx, largura
		mul ebx
		add eax, x
		mov dl, bufferInimigos[eax]
		pop ebx
		pop eax
		ret
GetBufferInimigos ENDP

;---------------------------------------------------------
; AtualizaContadoresPlayer
; 
; Atualiza os contadores de tempo do player, que controlam o cooldown do ataque e o tempo de invulnerabilidade
; 
;---------------------------------------------------------
AtualizaContadoresPlayer PROC
		push eax
		mov eax, tempoDelay
		add cooldownAtaquePlayer, eax
		add invulnerabilidadePlayer, eax
		pop eax
		ret
AtualizaContadoresPlayer ENDP

;---------------------------------------------------------
; IniciaNovaPartida
; 
; Adiciona os inimigos de um novo nivel baseando-se no nivel atual e incrementa o nivel atual
; 
;---------------------------------------------------------
IniciaNovaPartida PROC
		pushad
		
		mov estado, 1
		
		mov playerX, largura/2
		mov playerY, 25
		
		mov vidaPlayer, maxVidasPlayer
		mov invulnerabilidadePlayer, 0
		mov cooldownAtaquePlayer, 0
		
		mov nivel, 0
		mov qtdInimigos, 0
		mov pontos, 0
		
		mov ecx, maxTirosOta
		mov esi, 0
	inicializaTirosOta:
		mov tirosOta[esi].disponivel, 0
		add esi, TYPE PROJETIL
		loop inicializaTirosOta
		
		mov ecx, maxInimigos
		mov esi, 0
	inicializaInimigos:
		mov inimigos[esi].disponivel, 0
		add esi, TYPE INIMIGO
		loop inicializaInimigos
		
		mov ecx, maxTirosInimigos
		mov esi, 0
	inicializaTirosInimigos:
		mov tirosInimigos[esi].disponivel, 0
		add esi, TYPE PROJETIL
		loop inicializaTirosInimigos
		
		call GetMseconds
		mov tempoAnterior, eax
		mov tempoCount, 0
		popad
		ret
IniciaNovaPartida ENDP

;---------------------------------------------------------
; CriaNovaFase
;
; Gera um novo nivel baseando-se no nivel atual, adicionando os inimigos e incrementando a variavel de nivel
;
;---------------------------------------------------------
CriaNovaFase PROC
		pushad
		
		mov ecx, maxTirosInimigos
		mov esi, 0
	limpaTirosInimigos:
		mov tirosInimigos[esi].disponivel, 0
		add esi, TYPE PROJETIL
		loop limpaTirosInimigos
		
		mov ecx, maxTirosOta
		mov esi, 0
	limpaTirosOta:
		mov tirosOta[esi].disponivel, 0
		add esi, TYPE PROJETIL
		loop limpaTirosOta
		
		mov eax, 800
		call delay
		
		call GetMseconds
		mov tempoAnterior, eax
		mov tempoCount, 0
		
		mov playerX, largura/2
		sub playerX, 2
		mov playerY, 30
		
		cmp nivel, 0
		je criaFase1
		cmp nivel, 1
		je criaFase2
		cmp nivel, 2
		je criaFase3
		cmp nivel, 3
		je criaFase4
		cmp nivel, 4
		je criaFase5
		cmp nivel, 5
		je criaFase6
		cmp nivel, 6
		je criaFase7
		cmp nivel, 7
		je criaFase8
		cmp nivel, 8
		je criaFase9
		cmp nivel, 9
		je criaFase10
		cmp nivel, 10
		je criaFase11
		cmp nivel, 11
		je criaFase12
		jmp endFases
	criaFase1:
	   ;INVOKE adicionaInimigo, t, x,  y,  vX,  vY,  dX, dY, vAtk,  varAtk, vida, cor 
		INVOKE AdicionaInimigo, 0, 2,  2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 9,  2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 23, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 37, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 51, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 66, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 80, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 87, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 94, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		
		INVOKE AdicionaInimigo, 0, 2,  6 , 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 9,  6 , 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 6 , 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 23, 6 , 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 6 , 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 37, 6 , 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 6 , 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 51, 6 , 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 6 , 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 66, 6 , 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 6 , 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 80, 6 , 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 87, 6 , 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 94, 6 , 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		
		INVOKE AdicionaInimigo, 0, 2,  10, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 9,  10, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 10, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 23, 10, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 10, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 37, 10, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 10, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 51, 10, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 10, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 66, 10, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 10, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 80, 10, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 87, 10, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 94, 10, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		
		jmp endFases
		
	criaFase2:
	   ;INVOKE adicionaInimigo, t, x,  y,  vX,  vY,  dX, dY, vAtk,  varAtk, vida, cor
		INVOKE AdicionaInimigo, 1, 2,  2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 9,  2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 16, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 23, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 30, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 37, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 44, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 51, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 58, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 66, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 73, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 80, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 87, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 94, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		
		INVOKE AdicionaInimigo, 0, 2,  7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 9,  7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 23, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 37, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 51, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 66, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 80, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 87, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 94, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		
		INVOKE AdicionaInimigo, 0, 2,  11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 9,  11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 23, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 37, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 51, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 66, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 80, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 87, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 94, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
	
		jmp endFases
	
	criaFase3:
	   ;INVOKE adicionaInimigo, t, x,  y,  vX,  vY,  dX, dY, vAtk,  varAtk, vida, cor
		INVOKE AdicionaInimigo, 1, 2,  2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 1, 9,  2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 16, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 1, 23, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 30, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 1, 37, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 44, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 1, 51, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 58, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 1, 66, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 73, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 1, 80, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 87, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 1, 94, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		
		INVOKE AdicionaInimigo, 0, 2,  7 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 9,  7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 23, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 37, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 51, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 66, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 80, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 87, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 94, 7 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		
		INVOKE AdicionaInimigo, 0, 2,  11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 9,  11, 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 23, 11, 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 37, 11, 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 51, 11, 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 66, 11, 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 80, 11, 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 87, 11, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 94, 11, 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		
		jmp endFases
		
	criaFase4:
	   ;INVOKE adicionaInimigo, t, x,  y,  vX,  vY,  dX, dY, vAtk,  varAtk, vida, cor
		INVOKE AdicionaInimigo, 2, 49, 7 , 0  , 0  , 1 , 1 , 3000 , 2000 ,  30,   13, 50, 50
		
		INVOKE AdicionaInimigo, 1, 2,  2 , 000, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 9,  2 , 000, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 16, 2 , 000, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 23, 2 , 000, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 30, 2 , 000, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 37, 2 , 000, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 44, 2 , 000, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 51, 2 , 000, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 58, 2 , 000, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 66, 2 , 000, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 73, 2 , 000, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 80, 2 , 000, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 87, 2 , 000, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 94, 2 , 000, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		
		INVOKE AdicionaInimigo, 0, 2,  12, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 9,  12, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 12, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 23, 12, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 12, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 37, 12, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 12, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 51, 12, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 12, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 66, 12, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 12, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 80, 12, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 87, 12, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 94, 12, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		
		INVOKE AdicionaInimigo, 0, 2,  12, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 9,  12, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 12, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 23, 12, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 12, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 37, 12, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 12, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 51, 12, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 12, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 66, 12, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 12, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 80, 12, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 87, 12, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 94, 12, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		
		INVOKE AdicionaInimigo, 0, 2,  15, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 9,  15, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 15, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 23, 15, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 15, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 37, 15, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 15, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 51, 15, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 15, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 66, 15, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 15, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 80, 15, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 87, 15, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 94, 15, 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		
		INVOKE AdicionaInimigo, 0, 2,  15, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 9,  15, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 15, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 23, 15, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 15, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 37, 15, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 15, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 51, 15, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 15, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 66, 15, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 15, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 80, 15, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 87, 15, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 94, 15, 100, 0  , -1, 0 , 6000 , 4000,   1 ,   192, 0, 50
		
		jmp endFases
		
	criaFase5:
	   ;INVOKE adicionaInimigo, t, x,  y,  vX,  vY,  dX, dY, vAtk,  varAtk, vida, cor
		INVOKE AdicionaInimigo, 2, 08, 03, 000, 000, 01, 01, 6000,  2000,   10,   14, 40, 50
		INVOKE AdicionaInimigo, 2, 23, 03, 000, 000, 01, 01, 6000,  2000,   10,   14, 40, 50
		INVOKE AdicionaInimigo, 2, 38, 03, 000, 000, 01, 01, 6000,  2000,   10,   14, 40, 50
		INVOKE AdicionaInimigo, 2, 53, 03, 000, 000, 01, 01, 6000,  2000,   10,   14, 40, 50
		INVOKE AdicionaInimigo, 2, 68, 03, 000, 000, 01, 01, 6000,  2000,   10,   14, 40, 50
		INVOKE AdicionaInimigo, 2, 83, 03, 000, 000, 01, 01, 6000,  2000,   10,   14, 40, 50
		
		INVOKE AdicionaInimigo, 1, 2,  14 , 150, 140, 1 ,  1 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 9,  14 , 150, 140, 1 , -1 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 16, 14 , 150, 140, 1 ,  1 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 23, 14 , 150, 140, 1 , -1 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 30, 14 , 150, 140, 1 ,  1 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 37, 14 , 150, 140, 1 , -1 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 44, 14,  150, 140, 1 ,  1 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 51, 14 , 150, 140, 1 , -1 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 58, 14 , 150, 140, 1 ,  1 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 66, 14 , 150, 140, 1 , -1 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 73, 14 , 150, 140, 1 ,  1 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 80, 14 , 150, 140, 1 , -1 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 87, 14 , 150, 140, 1 ,  1 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 94, 14 , 150, 140, 1 , -1 , 6000 , 4000,   2 ,   144, 0, 50
		
		jmp endFases
		
	criaFase6:
	
		;INVOKE adicionaInimigo, t, x,  y,  vX,  vY,  dX, dY, vAtk,  varAtk, vida, cor 
		INVOKE AdicionaInimigo, 2, 2,  2, 100, 0  , 1 , 0 , 10000 , 7000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 16, 2, 100, 0  , -1 , 0 , 10000 , 7000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 30, 2, 100, 0  , 1 , 0 , 10000 , 7000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 44, 2, 100, 0  , -1 , 0 , 10000 , 7000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 58, 2, 100, 0  , 1 , 0 , 10000 , 7000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 73, 2, 100, 0  , -1 , 0 , 10000 , 7000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 87, 2, 100, 0  , 1 , 0 , 10000 , 7000,   10 ,   14, 50, 50
		
		
		INVOKE AdicionaInimigo, 1, 2,  6 , 100, 0  , -1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 9,  6 , 100, 0  , -1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 16, 6 , 100, 0  , -1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 23, 6 , 100, 0  , -1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 30, 6 , 100, 0  , -1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 37, 6 , 100, 0  , -1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 44, 6 , 100, 0  , -1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 51, 6 , 100, 0  , -1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 58, 6 , 100, 0  , -1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 66, 6 , 100, 0  , -1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 73, 6 , 100, 0  , -1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 80, 6 , 100, 0  , -1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 87, 6 , 100, 0  , -1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 94, 6 , 100, 0  , -1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		
		INVOKE AdicionaInimigo, 1, 2,  6 , 100, 0  , 1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 9,  6 , 100, 0  , 1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 16, 6 , 100, 0  , 1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 23, 6 , 100, 0  , 1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 30, 6 , 100, 0  , 1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 37, 6 , 100, 0  , 1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 44, 6 , 100, 0  , 1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 51, 6 , 100, 0  , 1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 58, 6 , 100, 0  , 1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 66, 6 , 100, 0  , 1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 73, 6 , 100, 0  , 1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 80, 6 , 100, 0  , 1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 87, 6 , 100, 0  , 1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 94, 6 , 100, 0  , 1, 0 , 10000 , 7000,   2 ,   144, 0, 50
		
		INVOKE AdicionaInimigo, 0, 2,  10 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 9,  10 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 10 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 23, 10 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 10 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 37, 10 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 10 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 51, 10 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 10 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 66, 10 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 10 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 80, 10 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 87, 10 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 94, 10 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		
		INVOKE AdicionaInimigo, 0, 2,  10 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 9,  10 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 10 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 23, 10 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 10 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 37, 10 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 10 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 51, 10 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 10 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 66, 10 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 10 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 80, 10 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 87, 10 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 94, 10 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		
		INVOKE AdicionaInimigo, 0, 2,  14 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 9,  14 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 14 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 23, 14 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 14 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 37, 14 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 14 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 51, 14 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 14 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 66, 14 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 14 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 80, 14 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 87, 14 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 94, 14 , 100, 0  , 1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		
		INVOKE AdicionaInimigo, 0, 2,  14 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 9,  14 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 14 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 23, 14 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 14 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 37, 14 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 14 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 51, 14 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 14 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 66, 14 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 14 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 80, 14 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 87, 14 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 94, 14 , 100, 0  , -1 , 0 , 10000 , 7000,   1 ,   192, 0, 50
	
		jmp endFases
		
	criaFase7:
		mov playerX, 4
	   ;INVOKE adicionaInimigo, t, x,  y,  vX,  vY,  dX, dY, vAtk,  varAtk, vida, cor, vAtkX, vAtkY
		INVOKE AdicionaInimigo, 0, 2 , 2 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 4 , 3 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 6 , 4 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 8 , 5 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 10, 6 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 12, 7 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 14, 8,  120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 9 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 18, 10 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 20, 11 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 22, 12 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 24, 13 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 26, 14 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 28, 15 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 16 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 32, 17 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 34, 18 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 36, 19 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 38, 20 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 40, 21 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 42, 22 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 23 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 46, 24 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 48, 25 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 50, 26 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 52, 27 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 54, 28 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 56, 29 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 30 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 60, 31 , 120, 120, 1 , 1 , 6000 , 4500,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 0, 62, 32 , 120, 120, 1 , 1 , 6000 , 4500,   32 ,  160, 0, 50
	
		jmp endFases
		
	criaFase8:
		mov playerX, 4
		;INVOKE adicionaInimigo, t, x,  y,  vX,  vY,  dX, dY, vAtk,  varAtk, vida, cor, vAtkX, vAtkY
		INVOKE AdicionaInimigo, 0, 10, 3 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 13, 5 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 7 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 13, 9 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 10, 11, 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 7 , 9 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 4 , 7 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 7 , 5 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 10, 3 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		
		INVOKE AdicionaInimigo, 0, 40, 3 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 43, 5 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 46, 7 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 43, 9 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 40, 11, 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 37 , 9 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 34 , 7, 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 37 , 5 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 40, 3 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		
		INVOKE AdicionaInimigo, 0, 70, 3 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 5 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 76, 7 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 9 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 70, 11, 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 67 , 9 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 64 , 7, 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 67 , 5 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
		INVOKE AdicionaInimigo, 0, 70, 3 , 120, 120, 1 , 1 , 6000 , 4000,   6 ,  160, 0, 50
	
		jmp endFases
		
	criaFase9:
	   ;INVOKE adicionaInimigo, t, x,  y,  vX,  vY,  dX, dY, vAtk,  varAtk, vida, cor, vAtkX, vAtkY
		INVOKE AdicionaInimigo, 0, 2,  2 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   160, 0, 50
		INVOKE AdicionaInimigo, 0, 9,  2 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   160, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   160, 0, 50
		INVOKE AdicionaInimigo, 0, 23, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   160, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   160, 0, 50
		INVOKE AdicionaInimigo, 0, 37, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   160, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   160, 0, 50
		INVOKE AdicionaInimigo, 0, 51, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   160, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   160, 0, 50
		INVOKE AdicionaInimigo, 0, 66, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   160, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   160, 0, 50
		INVOKE AdicionaInimigo, 0, 80, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   160, 0, 50
		INVOKE AdicionaInimigo, 0, 87, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   160, 0, 50
		INVOKE AdicionaInimigo, 0, 94, 2 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   160, 0, 50
		
		INVOKE AdicionaInimigo, 2, 2,  6 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 9,  6 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 16, 6 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 23, 6 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 30, 6 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 37, 6 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 44, 6 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 51, 6 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 58, 6 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 66, 6 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 73, 6 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 80, 6 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 87, 6 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   14, 50, 50
		INVOKE AdicionaInimigo, 2, 94, 6 , 100, 0  , 1 , 0 , 6000 , 4000,   10 ,   14, 50, 50
		
		INVOKE AdicionaInimigo, 1, 2,  10 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 9,  10 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 16, 10 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 23, 10 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 30, 10 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 37, 10 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 44, 10 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 51, 10 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 58, 10 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 66, 10 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 73, 10 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 80, 10 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 87, 10 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		INVOKE AdicionaInimigo, 1, 94, 10 , 100, 0  , 1 , 0 , 6000 , 4000,   2 ,   144, 0, 50
		
		INVOKE AdicionaInimigo, 0, 2,  14 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 9,  14 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 16, 14 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 23, 14 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 30, 14 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 37, 14 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 44, 14 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 51, 14 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 58, 14 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 66, 14 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 73, 14 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 80, 14 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 87, 14 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
		INVOKE AdicionaInimigo, 0, 94, 14 , 100, 0  , 1 , 0 , 6000 , 4000,   1 ,   192, 0, 50
	
		jmp endFases
		
	criaFase10:
	   ;INVOKE adicionaInimigo, t, x,  y,  vX,  vY,  dX, dY, vAtk,  varAtk, vida, cor, vAtkX, vAtkY
		INVOKE AdicionaInimigo, 2, 49, 7 , 80 , 100 , 1, -1, 10000 , 6000 ,  100,  15, 50, 50
		
		INVOKE AdicionaInimigo, 2, 49, 7 , 80 , 100 , 1, -1, 10000 , 6000 ,  1,   1, 60, 50
		INVOKE AdicionaInimigo, 2, 49, 7 , 80 , 100 , 1, -1, 10000 , 6000 ,  1,   2, 70, 45
		INVOKE AdicionaInimigo, 2, 49, 7 , 80 , 100 , 1, -1, 10000 , 6000 ,  1,   3, 90, 40
		INVOKE AdicionaInimigo, 2, 49, 7 , 80 , 100 , 1, -1, 10000 , 6000 ,  1,   4, 100, 35
		INVOKE AdicionaInimigo, 2, 49, 7 , 80 , 100 , 1, -1, 10000 , 6000 ,  1,   5, 110, 30
		INVOKE AdicionaInimigo, 2, 49, 7 , 80 , 100 , 1, -1, 10000 , 6000 ,  1,   6, 120, 35
		INVOKE AdicionaInimigo, 2, 49, 7 , 80 , 100 , 1, -1, 10000 , 6000 ,  1,   7, 130, 30
		INVOKE AdicionaInimigo, 2, 49, 7 , 80 , 100 , 1, -1, 10000 , 6000 ,  1,   8, 140, 25
		INVOKE AdicionaInimigo, 2, 49, 7 , 80 , 100 , 1, -1, 10000 , 6000 ,  1,   9, 150, 20
		INVOKE AdicionaInimigo, 2, 49, 7 , 80 , 100 , 1, -1, 10000 , 6000 ,  1,   10, 160, 30
		INVOKE AdicionaInimigo, 2, 49, 7 , 80 , 100 , 1, -1, 10000 , 6000 ,  1,   11, 170, 34
		INVOKE AdicionaInimigo, 2, 49, 7 , 80 , 100 , 1, -1, 10000 , 6000 ,  1,   12, 180, 60
		INVOKE AdicionaInimigo, 2, 49, 7 , 80 , 100 , 1, -1, 10000 , 6000 ,  1,   13, 190, 200
		INVOKE AdicionaInimigo, 2, 49, 7 , 80 , 100 , 1, -1, 10000 , 6000 ,  1,   14, 200, 23
		
		INVOKE AdicionaInimigo, 2, 49, 7 , 80 , 100 , 1, -1, 10000 , 6000 ,  1,   15, 20, 20
		
	
		jmp endFases
		
	criaFase11:
		INVOKE AdicionaInimigo, 0, 47, 11 , 0 , 0 , 1, 1, 999999999 , 1 , 999999999,  176, 50, 50 
		jmp endFases
		
	criaFase12:
		mov estado, 0
		mov eax, pontos
		mov recordePontos, eax
		mov eax, nivel
		mov recordeNivel, eax
		
	endFases:
		inc nivel
		popad
		ret
CriaNovaFase ENDP

END main































;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;2500!