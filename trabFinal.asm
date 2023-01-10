
.text

.globl main

main:
        jal print_jogo
        jal jogada
        j   verifica

print_jogo:
        la $s2, vetTabuleiro #vetor com o tabuleiro
        la $s0, linha #carrega a linha em s0
        li $s1, 1     # carrega o index em s1
desenho:
        lw   $t1, ($s2)       # posicao inicial de vetTabuleiro
        bltz $t1, desenha_vazio # vazio     if t1 <  0
        bgtz $t1, desenha_o     # desenha_o if t1 >  0
        bgez $t1, desenha_x     # desenha_x if t1 >= 0
desenha_o:
        lb  $t2, jogador2  #'o'
        j next
desenha_x:
        lb  $t2, jogador1  #'x'
        j next
desenha_vazio:
        lb  $t2, vazio    #' '
        j next
next:
        add $t1, $s0, $s1          # t1 = *linha[index]     - posicao onde iremos inserir o caracter
        sb  $t2, ($t1)             # linha[index] = caracter   - inserindo o caracter que foi armazenado em $t2 anteriormente
        addi $s2, $s2, 4           # i++			- avancamos 4 bytes para pegarmos o proximo -15 do vetTabuleiro que eh a proxima casa
        addi $s1, $s1, 4           # index += 4			- atualizamos o endereco de onde sera inserido o proximo caracter
        li   $t1, 13               # t1 = 13 (index 13 nao existe em linha)
        beq  $t1, $s1, print_linha # reset linha if s1 == 13 
        j desenho
print_linha:
	li   $v0, 4                        
        la   $a0, linha                   
        syscall                     
        
        li   $s1, 1                        # index = 1
        li   $t2, 36                       # vetTabuleiro.length 9x4
        la   $t3, vetTabuleiro                    # t3  = vetTabuleiro
        add  $t2, $t2, $t3                 # endereco vetTabuleiro + 36 (9 words)    
        beq  $s2, $t2, exit_print_desenho  # se o index $s2 for do tamanho total do vetor, sai do laco
        
        li   $v0, 4                        
        la   $a0, separador          
        syscall                            
        
        j desenho
        
exit_print_desenho:
        jr $ra			#volta para jogada

jogada:
	li $v0, 4
        la $a0, insira_linha	
        syscall
        
        li $v0, 5
        syscall       			#le a linha
        move $s1, $v0
        
        li $v0, 4
        la $a0, insira_coluna	
        syscall
        
        li $v0, 5
        syscall       			#le a coluna
        move $s2, $v0

#calculo de onde iremos inserir no vetTabuleiroor
        li   $t3, 3        # t3 = 3 (tamanho_da_linha) cada linha possui tres caracteres
        mult $s1, $t3      # linha * 3 (offset_da_linha) iremos ou para a posicao 0 ou 3 ou 6
        mflo $s3           # s3 = offset_da_linha
        add  $s4, $s3, $s2 # s4 = offset_da_linha + coluna (posicao_vetTabuleiroor) 
        #se estivermos em $s3 = 0, acessareoms ou 0 ou 1 ou 2. Se estivermos em $s3 = 3 acessaremos ou 3 ou 4 ou 5.  Se estivermos em $s3 = 6, acessaremos ou 6 ou 7 ou 8
      
        la   $t0, vetTabuleiro    # t0 = carrega endereco de vetTabuleiro[0]
        
        li   $t5, 4        # t1 = 4 (tamanho da word no vetTabuleiro) 4 bytes para cada inteiro
        mult $s4, $t5      # 4 * posicao_vetTabuleiroor
        mflo $s1           # s1 = 4 * posicao_vetTabuleiroor	- precisamos pular de 4 em 4 para acessar a posicao correta a cada 4 bytes
        add  $t1, $t0, $s1 # t1 = endereco vetTabuleiro[0] + posicao calculada em s1  guardará a posicao efetiva de onde sera inserido no vetTabuleiro
        
        lw   $t3, turno    # t3 = turno
        li   $t2, 2        # t2 = 2
        div  $t3, $t2      # turno / 2
        mfhi $t2           # t2 = turno % 2
        li   $t6, 1        # t6 = 1
        add  $t3, $t3, $t6 # t3 += 1
        beq  $t2, $zero, jogada_player_1 # se turno par jogador1 se impar jogador2 
        li   $t5, 1 # jogador2
        j verifica_jogada
jogada_player_1:
        li   $t5, 0 # jogador1
verifica_jogada:
        lw   $t6, ($t1)       
        bgez $t6, jogada_invalida # Branch on greater than or equal to zero(0 ou 1 já na posição)
        j store_jogada

jogada_invalida:
        la  $a0, print_jogada_invalida
        li  $v0, 4
        syscall
        j jogada

store_jogada:
        sw   $t3, turno    # turno++
        sw   $t5, ($t1)    # ira inserir o $t5 que sera 0 ou 1 a depender se eh jogador 1 ou 2 no vetTabuleiro($t1) ($t1 guarda a posicao efetiva de onde sera inserido o caractere)
        jr   $ra

verifica:
        la  $s5, vetTabuleiro
        lw  $s0, 4($s5)      # 012      x1x
        lw  $s1, 16($s5)     # 345      x1x
        lw  $s2, 24($s5)     # 678      1x1 1+4+6+7 = 4 || 0
        lw  $s3, 32($s5)
        jal soma_empate
        lw  $s0, 4($s5)      # 012      x1x
        lw  $s1, 12($s5)     # 345      11x
        lw  $s2, 16($s5)     # 678      xx1 1+3+4+8 = 4 || 0
        lw  $s3, 32($s5)
        jal soma_empate
        lw  $s0, 4($s5)      # 012      x1x
        lw  $s1, 16($s5)     # 345      x11
        lw  $s2, 20($s5)     # 678      1xx 1+4+5+6 = 4 || 0
        lw  $s3, 24($s5)
        jal soma_empate
        lw  $s0, 0($s5)      # 012      1xx
        lw  $s1, 16($s5)     # 345      x11
        lw  $s2, 20($s5)     # 678      x1x 0+4+5+7 = 4 || 0
        lw  $s3, 28($s5)
        jal soma_empate
        lw  $s0, 8($s5)      # 012      xx1
        lw  $s1, 12($s5)     # 345      11x
        lw  $s2, 16($s5)     # 678      x1x 2+3+4+7 = 4 || 0
        lw  $s3, 28($s5)
        jal soma_empate
        lw  $s0, 0($s5)      # 012      1x1
        lw  $s1, 8($s5)      # 345      x1x
        lw  $s2, 16($s5)     # 678      x1x 0+2+4+7 = 4 || 0
        lw  $s3, 28($s5)
        jal soma_empate
        lw  $s0, 0($s5)      # 012      1xx
        lw  $s1, 16($s5)     # 345      x11
        lw  $s2, 20($s5)     # 678      1xx 0+4+5+6 = 4 || 0
        lw  $s3, 24($s5)
        jal soma_empate
        lw  $s0, 8($s5)      # 012      xx1
        lw  $s1, 12($s5)     # 345      11x
        lw  $s2, 16($s5)     # 678      xx1 2+3+4+8 = 4 || 0
        lw  $s3, 32($s5)
        jal soma_empate

        lw  $s0, 0($s5)      # 012      111 
        lw  $s1, 4($s5)      # 345      xxx 
        lw  $s2, 8($s5)      # 678      xxx (0 + 1 + 2) = 3 || 0
        jal soma_ganha
        lw  $s0, 12($s5)     # 012      xxx 
        lw  $s1, 16($s5)     # 345      111 
        lw  $s2, 20($s5)     # 678      xxx (3 + 4 + 5) = 3 || 0
        jal soma_ganha
        lw  $s0, 24($s5)     # 012      xxx 
        lw  $s1, 28($s5)     # 345      xxx 
        lw  $s2, 32($s5)     # 678      111 (6 + 7 + 8) = 3 || 0
        jal soma_ganha
        lw  $s0, 0($s5)       # 012     1xx
        lw  $s1, 12($s5)      # 345     1xx
        lw  $s2, 24($s5)      # 678     1xx (0 + 3 + 6) = 3 || 0
        jal soma_ganha
        lw  $s0, 4($s5)       # 012     x1x
        lw  $s1, 16($s5)      # 345     x1x
        lw  $s2, 28($s5)      # 678     x1x (1 + 4 + 7) = 3 || 0
        jal soma_ganha
        lw  $s0, 8($s5)       # 012     xx1 
        lw  $s1, 20($s5)      # 345     xx1 
        lw  $s2, 32($s5)      # 678     xx1 (2 + 5 + 8) = 3 || 0
        jal soma_ganha
        lw  $s0, 0($s5)       # 012     1xx
        lw  $s1, 16($s5)      # 345     x1x
        lw  $s2, 32($s5)      # 678     xx1 (0 + 4 + 8) = 3 || 0
        jal soma_ganha
        lw  $s0, 8($s5)       # 012     xx1
        lw  $s1, 16($s5)      # 345     x1x
        lw  $s2, 24($s5)      # 678     1xx (2 + 4 + 6) = 3 || 0
        jal soma_ganha

        j   main            # se não empatou nem ganhou continua o jogo

soma_ganha:
        add $t1, $s0, $s1
        add $t1, $t1, $s2
        li  $t2, 3
        beq $t1, $t2,   jogador2_ganhou
        beq $t1, $zero, jogador1_ganhou
        jr  $ra
soma_empate:
        add $t1, $s0, $s1
        add $t1, $t1, $s2
        add $t1, $t1, $s3
        li  $t2, 4
        beq $t2, $t1, empate
        jr  $ra

jogador1_ganhou:
        jal print_jogo
        la  $a0, print_jogador1_ganhou
        li  $v0, 4
        syscall
        
        addi $t8, $t8, 1
        
        li $v0, 4
        la $a0, placar
        syscall
        
        li $v0, 1
        move $a0, $t8
        syscall
        
        li $v0, 4
        la $a0, vs
        syscall
        
        li $v0, 1
        move $a0, $t9
        syscall
        
        j   exit
jogador2_ganhou:
        jal print_jogo
        la  $a0, print_jogador2_ganhou
        li  $v0, 4
        syscall
        
        addi $t9, $t9, 1
        
        li $v0, 4
        la $a0, placar
        syscall
        
        li $v0, 1
        move $a0, $t8
        syscall
        
        li $v0, 4
        la $a0, vs
        syscall
        
        li $v0, 1
        move $a0, $t9
        syscall
        
        j   exit
empate:
        la $a0, print_empate
        li $v0, 4
        syscall
        
        li $v0, 4
        la $a0, placar
        syscall
        
        li $v0, 1
        move $a0, $t8
        syscall
        
        li $v0, 4
        la $a0, vs
        syscall
        
        li $v0, 1
        move $a0, $t9
        syscall
        
        j exit

exit:
    
    	li $v0, 4
    	la $a0, pergunta
    	syscall
    	
    	li $v0, 5
    	syscall
    	move $t0, $v0
    	
    	beqz $t0, renovar_jogo
    	
        li  $v0, 10
        syscall

renovar_jogo:
 	
 	li $t2, 36
 	
 	li $t0, -15
 	li $t1, 0
loop:
 	beq $t1, $t2, main
 	 
 	sw $t0, vetTabuleiro($t1)	#renovando as casas do tabuleiro
 	
 	addi $t1, $t1, 4
 	
 	j loop
 	 
 .data
turno:                 .word 0 #identifica se eh o jogador 1 ou 2
vetTabuleiro:                   .word -15, -15, -15, -15, -15, -15, -15, -15, -15
linha:                 .asciiz  "   |   |   \n"  # index 1, 5, 9 sao modificados 
separador:             .asciiz "-----------\n"
jogador1:               .byte  'X'
jogador2:               .byte  'O'
vazio:                 .byte  ' '
placar:		       .asciiz "\nPlacar:\nJogador 1         Jogador 2\n    "
vs:		       .asciiz "        x        "
insira_linha:          .asciiz  "\n\nInsira a linha:"
insira_coluna:         .asciiz  "Insira a coluna:"
print_jogador1_ganhou: .asciiz  "\nJogador 1 (X) venceu!\n"
print_jogador2_ganhou: .asciiz  "\nJogador 2 (O) venceu!\n"
print_empate:          .asciiz  "Deu velha!\n"
print_jogada_invalida: .asciiz  "\nJogada invalida! Jogue novamente...\n"
pergunta:	       .asciiz "\n\nJogar novamente? [0 - Sim] [1 - Não]\n"

 	  