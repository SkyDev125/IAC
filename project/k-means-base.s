#
# IAC 2023/2024 k-means
# 
# Grupo: 34
# Campus: LEIC-T
#
# Autores:
# 110262, Diogo Santos
# 109480, Joao Conceicao
#
# Tecnico/ULisboa


# ALGUMA INFORMACAO ADICIONAL PARA CADA GRUPO:
# - A "LED matrix" deve ter um tamanho de 32 x 32
# - O input e' definido na seccao .data. 
# - Abaixo propomos alguns inputs possiveis. Para usar um dos inputs propostos, basta descomentar 
#   esse e comentar os restantes.
# - Encorajamos cada grupo a inventar e experimentar outros inputs.
# - Os vetores points e centroids estao na forma x0, y0, x1, y1, ...


# Variaveis em memoria
.data

#Input A - linha inclinada
n_points:    .word 9
points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
#n_points:    .word 5
#points:     .word 4,2, 5,1, 5,2, 5,3 6,2

#Input C
#n_points:    .word 23
#points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
#n_points:    .word 30
#points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10



# Valores de centroids e k a usar na 1a parte do projeto:
centroids:   .word 0,0
k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
#centroids:   .word 0,0, 10,0, 0,10
#k:           .word 3
#L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
clusters: .zero 120

#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff


# Codigo

.text
    jal mainSingleCluster

    # Descomentar na 2a parte do projeto:
    #jal mainKMeans
    
    #Termina o programa
    li a7, 10
    ecall


### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja' e' fornecida pelos docentes
# E' uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor
printPoint:
    li a3, LED_MATRIX_0_HEIGHT
    sub a1, a3, a1
    addi a1, a1, -1
    li a3, LED_MATRIX_0_WIDTH
    mul a3, a3, a1
    add a3, a3, a0
    slli a3, a3, 2
    li a0, LED_MATRIX_0_BASE
    add a3, a3, a0   # addr
    sw a2, 0(a3)
    jr ra


### cleanScreen
# Limpa todos os pontos do ecra
# Argumentos: nenhum
# Retorno: nenhum
cleanScreen:
    # Loads initial values for coordinates, iterators and color.
    li t0 LED_MATRIX_0_WIDTH
    li t1 LED_MATRIX_0_HEIGHT
    li t2 white

    # Calculate addresses with h*w
    mul t0 t0 t1
    la t1 LED_MATRIX_0_BASE

    # loop through the addresses
    cs_loop:
        beq t0 x0 cs_continue
            sw t2 0(t1)
            addi t1 t1 4
            addi t0 t0 -1
        j cs_loop
    cs_continue:
    jr ra


### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum
printClusters:
    lw t0 n_points
    la t1 points
    la t2 clusters

    pc_loop:
        beq t0 x0 pc_continue
            # Load point
            lw a0 0(t1)
            lw a1 4(t1)

            # Calculate colour
            lw a2 0(t2)
            slli a2 a2 2

            # Load colour
            la t3 colors
            add t3 t3 a2
            lw a2 0(t3)

            # Save to stack
            addi sp sp -4
            sw ra 0(sp)

            jal printPoint
            
            # Return from stack
            lw ra 0(sp)
            addi sp sp 4

            # Iterate over the vector
            addi t1 t1 8
            addi t2 t2 4
            addi t0 t0 -1

        j pc_loop
    pc_continue:
    
    jr ra


### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum
printCentroids:
    la t0 centroids
    lw t1 k

    pcen_loop:
        beqz t1 pcen_continue
            
            # Save necessary values to stack
            addi sp sp -12
            sw t0 0(sp)
            sw t1 4(sp) 
            sw ra 8(sp)

            # Load centroid
            lw a0 0(t0)
            lw a1 4(t0)
            li a2 black

            jal printPoint

            # Retrieves the values from stack
            lw t0 0(sp)
            lw t1 4(sp)
            lw ra 8(sp)
            addi sp sp 12

            # Increment position
            addi t0, t0, 8
            addi t1, t1, -1
        j pcen_loop
    pcen_continue:

    jr ra


### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum
calculateCentroids: 
    # POR IMPLEMENTAR (1a e 2a parte)
    li t0 0     # Acc of Xs
    li t1 0     # Acc of Ys
    lw t2 k     # centroids vector size
    lw t3 n_points
    la t4 centroids
    la t5 points

    sum:
        beq t3 x0 cc_continue
            # Sum Xs
            lw t6 0(t5)
            add t0 t0 t6
            
            # Sum Ys
            lw t6 4(t5)
            add t1 t1 t6
            
            # Increment position
            addi t5 t5 8
            addi t3 t3 -1
        j sum
    cc_continue:
    
    # Divide by n_points
    lw t3 n_points
    div t0 t0 t3 # AccX/n_points
    div t1 t1 t3 # AccY/n_points

    # Save the centroid
    sw t0 0(t4)
    sw t1 4(t4)

    jr ra


### mainSingleCluster
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum
mainSingleCluster:
    # k = 1
    la s0 k
    li s1 1
    sw s1 0(s0)

    # Save ra to stack
    addi sp sp -4
    sw ra 0(sp)

    jal cleanScreen
    jal printClusters
    jal calculateCentroids
    jal printCentroids

    # Recover ra from stack
    lw ra 0(sp)
    addi sp sp 4

    jr ra


### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance
manhattanDistance:
    # Subtract y to x
    sub t0, a0, a1
    sub t1, a2, a3
    
    # Calculate the absolute value
    bgez t0 man_continue
        neg t0 t0
    bgez t1 man_continue
        neg t1 t1
    man_continue:
    
    # Return distance
    add a0 t0 t1
    jr ra


### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index
nearestCluster:
    # POR IMPLEMENTAR (2a parte)
    # a0 e a1 -> ponto dado
    # a2 e a3 -> centroid
    la t0 k
    la t1 centroids
    li t2 0 #distance
    
    # Set k to a valid cluster value 0-(k-1)
    addi t0 t0 -1
    mv t3 t0
    slli t3 t3 2
    add t1 t1 t2 #ponteiro passa para o fim


    nc_loop:
        blt t0 x0 nc_continue

        # Save necessary values to stack
        addi sp sp -20
        sw ra 0(sp)
        sw a0 4(sp)
        sw a1 8(sp)
        sw a2 12(sp)
        sw a3 16(sp)


        # Load centroid
        lw a2 0(t1) 
        lw a3 4(t1)

        # Calculate Distance
        jal manhattanDistance

        # Checks if the distance is greater
        bgt t3 a0 nc_continue_in_loop
        add t3 a0 x0 #register the new close distance
        

        nc_continue_in_loop:

        # Retrieve the values from stack
        lw ra 0(sp)
        lw a0 4(sp)
        lw a1 8(sp)
        lw a2 12(sp)
        lw a3 16(sp)
        addi sp sp 20
    nc_continue:
    add a0 t0 x0
    
    jr ra


### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhu
mainKMeans:  
    # POR IMPLEMENTAR (2a parte)
    jr ra


### initializeCentroids
# Pseudo-Aleatoriamente seleciona pontos para centroids
# Argumentos: nenhum
# Retorno: nenhum
initializeCentroids:
    lw t0 k
    la t1 centroids
    
    ic_loop:
        beq t0 x0 ic_continue
            # Save values to stack
            addi sp sp -12
            sw ra 0(sp)
            sw t0 4(sp)
            sw t1 8(sp)
            
            # Generate and Save centroid
            jal generateCentroid
            sw a0 0(t1)
            sw a1 0(t1)
            
            # Return values from stack
            lw ra 0(sp)
            lw t0 4(sp)
            lw t1 8(sp)
            addi sp sp 12
            
            # Iterate over the vectors
            addi t1 t1 8
            addi t0 t0 -1
        j ic_loop
    ic_continue:
        
    jr ra


### generateCentroid
# Randomly selects a centroid
#
# Design choice: To augment the randomness of the values generated we decided to
# use the values in the array as an extra seeding factor, inside the loop, and
# run the LCG algorithm multiple times over. (as we add the values of x and y)
#
# Argumentos: nenhum
# Retorno:
# a0: x centroid
# a1: y centroid
generateCentroid:
    # Get seed value
    li a7 30
    ecall       # a0 = current low time bits
    mv a1 a0    # a1 = current low time bits
    
    # Constants for LCG
    li a2, 1103515245  # multiplier
    li a3, 12345       # increment
    li a4, 2147483648  # modulus (2^31)
    
    # Loop values
    lw t2 n_points
    la t3 points

    # Sum loop
    gc_loop:
        beq t2 x0 gc_continue
            # Load Xs & Ys
            lw t0 0(t3)
            lw t1 4(t3)
        
            # LCG algorithm
            mul a0, a0, a2
            add a0, a0, a3
            rem a0, a0, a4
            mul a1, a1, a2
            add a1, a1, a3
            rem a1, a1, a4

            # Sum Xs & Ys
            add a0 a0 t0
            sub a1 a1 t1
            
            # Iterate the vectors
            addi t3 t3 8
            addi t2 t2 -1
        j gc_loop
    gc_continue:
    
    # Generate final x, y pair
    li t0 32
    rem a0 a0 t0
    rem a1 a1 t0
    
    # Get only positive values
    add a0 a0 t0
    add a1 a1 t0
    rem a0 a0 t0
    rem a1 a1 t0
    
    jr ra