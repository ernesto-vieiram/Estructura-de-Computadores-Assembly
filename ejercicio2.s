.data
	A: .float 5.0, 2.9
    B: .word 0, 0
    N: .word  2
    M: .word  1
	X: .word 127
.globl main
.text
	main:
	#Paso de parámetros
	la $a0, A 							#$a0 = direccion de inicio de A
	lw $a1, N 							#$a1 = dimension_N de la matriz
	lw $a2, M 							#$a2 = dimension_M de la matriz
	la $a3, B							#$a3 = direccion de inicio de B
	lw $t6, X 							#$t6 = numero para comparar (para pasarlo a la pila)

	#Guardado de valores en la pila
	addi $sp, $sp, -24
	sw $ra, 20($sp)
	sw $a0, 16($sp)
	sw $a1, 12($sp)
	sw $a2, 8($sp)
	sw $a3, 4($sp)
	sw $t6, ($sp)	

	#Llamada a la función
	jal ExtractExponents

	#Recuperamos los valores de la pila
	lw $ra, 20($sp)
	lw $a0, 16($sp)
	lw $a1, 12($sp)
	lw $a2, 8($sp)
	lw $a3, 4($sp)
	lw $t6, ($sp)
	addi $sp, $sp, 24

	Imprimirexponente:					#imprimir cuantos exponentes son menores que X
		li $v0, 1
		move $a0, $v1		
		syscall
		li $a0, 10						#10 es el valor ASCII del (salto de linea)
		li $v0,11						#Imprimimos un char
		syscall

	Imprimirarray: 						#Imprimir B
		move $t2,$zero
		li $t0,1
		li $t3,1						#t3 sire para hacer nueva linea y para no imprimir una coma en la ultima		
		for: bgt $t0,$t1,cerrar
			add $t4, $a3, $t2
			lw $a0, ($t4)
			sll $t2, $t0,2
			li $v0,1
			syscall
			beq $t3, $a2, intro
			li $a0, 32                  #32 es el valor ASCII del (espacio)
			li $v0,11					#Imprimimos un char
			syscall
			li $a0, 44                  #44 es el valor ASCII de (coma)
			li $v0,11					#Imprimimos un char
			syscall
			li $a0, 32                  #32 es el valor ASCII del (espacio)
			li $v0,11					#Imprimimos un char
			syscall
			addi $t0,$t0,1
			addi $t3, $t3, 1
			b for
			intro:
				li $a0, 10				#10 es el valor ASCII del (salto de linea)
				li $v0,11				#Imprimimos un char
				syscall
				addi $t0,$t0,1
				li $t3,1
				b for
		cerrar:
		jr $ra

	ExtractExponents:
	mul $t1, $a1, $a2 					#$t1 contiene el tamaño de la matriz
	move $t0, $zero						#Contador de elementos.
	move $v1, $zero 					#Contador de elementos que cumplan la condicion y return de la funcion.
	lw $t6, ($sp)
		loop:
		bge $t0, $t1, final 			#Salimos del bucle cuando el contador supere la longitud del array
		sll $t2, $t0, 2					#Contador de posiciones en memoria
		add $t4, $a0, $t2			
		lw $t3, ($t4)					#Metemos en t3 el numero correspondiente del array A

			calcularExponente:
			beqz $t3,caso0				#Especial para el 0
			li $t7,0x0FF				#Creacion de mascara
			srl $t3, $t3, 23 			#1.Eliminamos los numeros de la mantisa
			and $t3, $t3, $t7 			#2.Hacemos mascara y nos quedamos con los 8 bits del exponente
			addi $t3, $t3, -127 		#3.Restamos el sesgo y nos quedamos con el valor real del exponente
			#$t3 tiene el valor del exponente
			bge $t3, $t6, casoB
			casoA: #Exponente < X
				add $t4, $a3, $t2
				sw $t3, ($t4)
				addi $v1, $v1, 1
				j reCount
			casoB: #Exponente >= X
				add $t4, $a3, $t2
				li $t5, 99999
				sw $t5, ($t4)
				j reCount
			caso0: #Numero no normalizado
				add $t4, $a3, $t2
				li $t5, -126
				sw $t5, ($t4)
				addi $v1, $v1, 1
				j reCount
			reCount:					#Actualizamos i += 1
				addi $t0, $t0, 1
				j loop
		final:
			jr $ra