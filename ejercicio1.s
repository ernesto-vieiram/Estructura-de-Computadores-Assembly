.data 
WordSearch: .byte  'H' , 'O' , 'l' , 'A' , 'K' , 'O' , 'N' , 'X' , 'a' , 'g' , 'h' , 'k' , 'k', 'm' , 'e' , 'E' , 'B' , 'x' , 'O' , 'L' , 'C' , 'c' , 'C' , 'D' ,'I' , 'O' , 'L' , 'X' , 'A' , 'L' , 'O' , 'H' , 'A' , 'L' , 'a' , 's' , 'I' , 'O' , 'u' , 'K' , 'L' , 'B' , 'B' , 'Y' , 'U' , 'J' , 'X' , 'O' , 'O' , 'H', 'O' , 'L' , 'A', 'O', 'H' , 'i' , 'H' , 'J' , 'K' , 'J' , 'T' , 'F' , 'J' , 'c'
Word: .asciiz  "Hola" 
N: .word 8 # dimensión de la sopa de letras

.text
.globl main
main:
	#Paso de parámetros
	la $a0, WordSearch  #$a0 = direccion de la matriz WordSearch
	lw $a1, N           #$a1 = N
	la $a2, Word        #$a2 = direccion de inicio de Word.

	#Guardado de argumentos y puntero de pila actual ($ra) en la pila para no perder valores 
	addi $sp, $sp, -16 
	sw $ra, 16($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)

	#Llamada a la funcion
	jal SearchWords

	#Restablezco los valores guardados en la pila 
	lw $ra, 16($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)

	#Imprimo y cierro el programa
	addi $sp, $sp, 16
	move $a0,$v0
	li $v0,1
	syscall
	jr $ra
			
SearchWords:
	move $t1,$zero #Contador for
	move $t2,$zero #Irá teniendo los caracteres de WordSearch
	move $t5,$zero #Irá teniendo los caracteres de Word
	move $v0,$zero #Solucion y return de la función

	for:
		mul $t7,$a1,$a1 #para ver cuantos valores tiene el array elevo al cuadrado n ya que siempre se tratara de una matriz cuadrada
		bge $t1, $t7, return
		add $t0, $a2, $zero #PRIMERA LETRA DE Word
		lb $t0 ($t0)#la almacenamos en t0
		add $t4, $t1, $a0 #con esto iremos yendo letra por letra de WordSearch y la iremos comparando con la primera letra de word
		lb $t4, ($t4) 
		#comparamos valores de la primera letra de word con la letra de WordSearch correspondiente
		beq $t0, $t4, igual 
		#con las siguientes operaciones comprobaremos la mayuscula y la minuscula mirando valores en la tabla ascii podemos ver que la diferencia entre una mayuscula y una minuscula es 32 
		addi $t4, $t4, 32 
		beq $t0, $t4, igual
		addi $t4, $t4, -64
		#Si encuentra un caracter igual al primer elemento de la palabra, vamos a "igual"
		beq $t0, $t4, igual 
		#En caso contrario, pasamos al siguiente elemento de la sopa de letras
		loopmasuno: 
		addi $t1, $t1, 1
		b for
			igual:
			#Dividiremos igual en 4 secciones derecha izquierda abajo y arriba 	
			move $t7,$zero #servira como contador dentro de cada seccion
			move $t3,$zero #lo usaremos para hacer un switch en la seccion cambio para que si cumple por ejemplo derecha tambien compruebe el resto
				Derecha:
					li $t3,1 #Codigo para el switch
					addi $t7, $t7, 1
					add $t4, $a2, $t7 #Avanzamos posiciones para ser el contador de word
					lb $t5, ($t4) #cargamos el caracter indicado por t4(word) en t5
					beq $t5,$zero, igualdef #como word sera un asciiz terminara siempre en un caracter nulo si ha llegado asta alli es que ha encontrado la palabra
					add $t2, $t1, $t7#siguiente posicion para WordSearch
					rem $t2,$t2,$a1 #Asi veo si es el  ultimo elemento de la fila mirando si el elemento de WordSearch tiene resto 0 con N eso significara que es una nueva fila y por lo tanto se ha cortado la palabra y no vale
					beqz $t2,cambio
					add $t2, $t1, $t7#se habia perdido el valor en la anterior linea
					add $t2, $a0, $t2
					lb $t2, ($t2) #Acaboamos de cargar en t2 el caracter numero t2 de WordSearch
					#Comprobamos si es igual comprobando mayusculas y minusculas tambien
					beq $t5, $t2, Derecha
					addi $t2, $t2, 32
					beq $t5, $t2, Derecha
					addi $t2, $t2, -64
					beq $t5, $t2, Derecha 
					
					b cambio
				
				izquierda:
					li $t3, 2 #Codigo para switch
					addi $t7, $t7, 1
					sub $t2, $t1, $t7 #calculamos la siguiente posicion como va hacia la izquierda tendra que retroceder en WordSearch
					
					add $t4, $a2, $t7
					lb $t5, ($t4)#cargamos el caracter indicado por t4(word) en t5
					beq $t5,$zero, igualdef#como word sera un asciiz terminara siempre en un caracter nulo si ha llegado asta alli es que ha encontrado la palabra
					addi $t2, $t2, 1
					rem $t2,$t2,$a1 #asi vemos si que la posicion anterior a donde voy a poner el numero es decir +1 en el array es resto 0 con n por que si es asi diria que se habia cambiado de fila y el caracter que voy a coger ahora esta en otra fila rompiendo la palabra
					beqz $t2,cambio
					sub $t2, $t1, $t7#se habia perdido el valor en la anterior linea
					add $t2, $a0, $t2
					lb $t2, ($t2)#Acabamos de cargar en t2 el caracter numero t2 de WordSearch
					#Comprobamos si es igual comprobando mayusculas y minusculas tambien
					beq $t5, $t2, izquierda
					addi $t2, $t2, 32
					beq $t5, $t2, izquierda
					addi $t2, $t2, -64
					beq $t5, $t2, izquierda
					
					b cambio

				abajo:
					li $t3, 3 #Codigo para switch
					addi $t7, $t7, 1
					
					
					add $t4, $a2, $t7
					lb $t5, ($t4)#cargamos el caracter indicado por t4(word) en t5
					beq $t5,$zero, igualdef #como word sera un asciiz terminara siempre en un caracter nulo si ha llegado asta alli es que ha encontrado la palabra
					mul $t6,$a1,$a1
					mul $t4,$a1,$t7 #calculamos el elemento de abajo dependiendo de cuanto 
					add $t2, $t1, $t4
					bge $t2,$t6,cambio
					add $t2, $t2, $a0
					lb $t2, ($t2)#Acabamos de cargar en t2 el caracter numero t2 de WordSearch
					#Comprobamos si es igual comprobando mayusculas y minusculas tambien
					beq $t5, $t2, abajo
					addi $t2, $t2, 32
					beq $t5, $t2, abajo
					addi $t2, $t2, -64
					beq $t5, $t2, abajo
					
					b cambio

				arriba:
					li $t3, 4
					addi $t7, $t7, 1
					
					
					add $t4, $a2, $t7
					lb $t5, ($t4)#letras de word
					beq $t5,$zero, igualdef
					mul $t2,$a1,$t7							#arriba sigue la misma estrategia que abajo pero al reves y ademas si t2 alguna vez es negativo es que estabamos en la primera fila con lo que no nos serviria seguir
					sub $t2, $t1, $t2
					bgt $zero,$t2,loopmasuno
					add $t2, $t2, $a0
					lb $t2, ($t2)#Acabamos de cargar en t2 el caracter numero t2 de WordSearch
					#Comprobamos si es igual comprobando mayusculas y minusculas tambien
					beq $t5, $t2, arriba
					addi $t2, $t2, 32
					beq $t5, $t2, arriba
					addi $t2, $t2, -64
					beq $t5, $t2, arriba
					
					b loopmasuno

				igualdef:
					#sumamos uno al resultado y vamos a cambio para seguir en la siguiente seccion de donde lo habiamos detectado 
					addi $v0, $v0, 1

					b cambio
				cambio:
					move $t7,$zero
					 #switch
					beq $t3, 1, izquierda
					beq $t3, 2, abajo
					beq $t3, 3, arriba
					beq $t3, 4, loopmasuno
					b loopmasuno
	return:
	jr $ra