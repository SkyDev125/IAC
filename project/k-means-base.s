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
L:           .word 10

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
#
#OPTIMIZATION
#
# We optimized our initial design, which printed each point from 
# 0,0 to 31,31 using the printPoint Function, to using consecutive memory addresses 
# for faster screen cleaning. 
#
# We considered further optimization by tracking printed points for efficient clearing, 
# but found our current method faster for larger data sets.
#
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

            # Iterate over the vectors
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
# Calcula os k centroides, a partir da distribuicao atual de pontos associados 
# a cada agrupamento (cluster)
#
#OPTIMIZATION
#
# We optimized our k-means algorithm by dynamically allocating space for each centroid
# calculation on the stack. This allows our code to be flexible and efficient,
# running through the points vector only once, instead of n*K times. This approach is
# most effective except for very small K values.
#
# Argumentos: nenhum
# Retorno: nenhum
calculateCentroids: 
    li t0 0     # Acc of Xs
    li t1 0     # Acc of Ys
    lw t2 k     # centroids vector size
    lw t3 n_points
    la t4 points
    la t5 clusters

    # Allocate stack size needed for cluster aux values (3 words * k)
    # 0 -> Acc of Xs
    # 4 -> Acc of Ys
    # 8 -> cluster_point_counter
    clean_stack_loop:
        beq t2 t0 clean_stack_continue
            addi sp sp -12
            sw x0 0(sp)
            sw x0 4(sp)
            sw x0 8(sp)    
            addi t2 t2 -1
        j clean_stack_loop
    clean_stack_continue:

    cc_sum_loop:
        beq t3 x0 cc_sum_continue
            # Load point & cluster
            lw a0 0(t4)
            lw a1 4(t4)
            lw a2 0(t5)

            # Calculate Stack offset
            li t6 12
            mul t6 a2 t6
            add t6 sp t6
            
            # Load values from stack
            lw t0 0(t6)
            lw t1 4(t6)
            lw a3 8(t6)

            # Add to Accs of Xs & Ys & cluster_point_counter
            add t0 t0 a0
            add t1 t1 a1
            addi a3 a3 1

            # Save values on stack
            sw t0 0(t6)
            sw t1 4(t6)
            sw a3 8(t6)
            
            # Iterate over the vectors
            addi t5 t5 4
            addi t4 t4 8
            addi t3 t3 -1
        j cc_sum_loop
    cc_sum_continue:

    # Load values for division
    lw t2 k
    la t3 centroids

    # Decrease K for indexing
    addi t2 t2 -1

    # Go to the end of centroids vector
    slli t4 t2 3
    add t3 t3 t4

    cc_div_loop:
        blt t2 x0 cc_div_continue
            # Calculate Stack offset
            li t4 12
            mul t4 t2 t4
            add t4 sp t4

            # Load from stack        
            lw t0 0(t4)
            lw t1 4(t4)
            lw a3 8(t4)

            # If there are no points in the cluster
            bne a3 x0 continue_points
                
                j continue_no_points

            # Calculate Centroid
            continue_points:
            div t0 t0 a3
            div t1 t1 a3
            
            # Save the centroid
            sw t0 0(t3)
            sw t1 4(t3)

            # Iterate over centroids vector
            continue_no_points:
            addi t3 t3 -8
            addi t2 t2 -1
        j cc_div_loop
    cc_div_continue:

    # De-allocate stack size needed for cluster aux values (3 words * k)
    lw t2 k
    li t6 12
    mul t6 t2 t6
    add sp sp t6

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
    # Subtract Xs and Ys
    sub t0, a0, a2
    sub t1, a1, a3
    
    # Calculate the absolute value
    bge t0, x0, t0_continue
        neg t0, t0
    t0_continue:
    bge t1, x0, t1_continue
        neg t1, t1
    t1_continue:
    
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
    lw t0 k
    la t1 centroids
    li t2 0x0fffffff #distance (Set to max int for first comparison)
    li t3 0 #index

    # Decrement for index value.
    addi t0 t0 -1
    
    # Start from the end of the cluster vector 
    slli t4 t0 3
    add t1 t1 t4
    nc_loop:
        blt t0 x0 nc_continue
            
            # Save necessary values
            addi sp sp -28
            sw t0 24(sp)
            sw t1 20(sp)
            sw t2 16(sp)
            sw t3 12(sp)
            sw ra 8(sp)
            sw a0 4(sp)
            sw a1 0(sp)

            # Load centroid
            lw a2 0(t1)
            lw a3 4(t1)

            jal manhattanDistance
            mv t4 a0 # Save value from return
            
            # Retrieves the values from stack
            lw t0 24(sp)
            lw t1 20(sp)
            lw t2 16(sp)
            lw t3 12(sp)
            lw ra 8(sp)
            lw a0 4(sp)
            lw a1 0(sp)
            addi sp sp 28

            # Save new value if smaller
            bge t4 t2 nc_j_loop
                mv t2 t4
                mv t3 t0
            nc_j_loop:
            
            # Iterating over the vector
            addi t1 t1 -8
            addi t0 t0 -1
        j nc_loop
    nc_continue:

    # Return Value
    mv a0 t3
    jr ra


### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhu
mainKMeans:  
    # Save ra to stack
    addi sp sp -4
    sw ra 0(sp)

    # Initialize Centroids
    jal initializeCentroids

    # Load loop necessary stuff
    lw t0 L

    # main loop
    mk_loop:
        beq t0 x0 mk_continue
            # Save to stack
            addi sp sp -4
            sw t0 0(sp)
        
            jal cleanScreen

            # Update clusters
            lw t1 n_points
            la t2 points
            la t3 clusters
            cluster_update:
                beq t1 x0 cluster_continue
                    # Save values to stack
                    addi sp sp -12
                    sw t1 0(sp)
                    sw t2 4(sp)
                    sw t3 8(sp)
                    
                    # Load point
                    lw a0 0(t2)
                    lw a1 4(t2)

                    # Find nearest cluster
                    jal nearestCluster
                    
                    # Return values from stack
                    lw t1 0(sp)
                    lw t2 4(sp)
                    lw t3 8(sp)
                    addi sp sp 12

                    # Update cluster
                    sw a0 0(t3)

                    # Increment the vectors
                    addi t3 t3 4
                    addi t2 t2 8
                    addi t1 t1 -1
                j cluster_update
            cluster_continue:

            # Save all centroids in stack
            lw t1 k
            la t2 centroids
            centroid_loop:
                beq t1 x0 centroid_continue
                    # Load centroid
                    lw t3 0(t2) # X
                    lw t4 4(t2) # Y

                    # Save to stack
                    addi sp sp -8
                    sw t3 0(sp) # X
                    sw t4 4(sp) # Y

                    # Iterate over the vector
                    addi t1 t1 -1
                    addi t2 t2 8
                j centroid_loop
            centroid_continue:

            # Update centroids
            jal printClusters
            jal printCentroids
            jal calculateCentroids

            # Go to the end of the centroids vector to compare
            lw t1 k
            la t2 centroids
            addi t1 t1 -1
            slli t1 t1 3
            add t2 t2 t1
            
            # Start the comparison loop
            lw t1 k
            li a0 0 # Comparison checker
            centroid_comp_loop:
                beq t1 x0 centroid_comp_continue
                    # Load centroid
                    lw t3 0(t2) # X
                    lw t4 4(t2) # Y

                    # Load old centroid from stack
                    lw t5 0(sp) # X
                    lw t6 4(sp) # Y
                    addi sp sp 8

                    # Count the equals
                    bne t3 t5 comp_continue
                    bne t4 t6 comp_continue
                        addi a0 a0 1
                    comp_continue:
                    
                    # Iterate over the vector
                    addi t2 t2 -8
                    addi t1 t1 -1
                j centroid_comp_loop
            centroid_comp_continue:
            
            # Return from Stack
            lw t0 0(sp)
            addi sp sp 4

            # Verify if centroids changed
            lw t1 k
            beq a0 t1 mk_continue

            # Continue iterating
            addi t0 t0 -1
        j mk_loop
    mk_continue:

    # Recover ra from stack
    lw ra 0(sp)
    addi sp sp 4
    
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
            
            # Return values from stack
            lw ra 0(sp)
            lw t0 4(sp)
            lw t1 8(sp)
            addi sp sp 12
            
            # Save Centroid
            sw a0 0(t1)
            sw a1 4(t1)
            
            # Iterate over the vectors
            addi t1 t1 8
            addi t0 t0 -1
        j ic_loop
    ic_continue:
        
    jr ra


### generateCentroid
# Randomly selects a centroid
#
# Design: We started by using the points given to help generate the seed for the algorithm
# however, it seemed to not be random enough, and less efficient. So we changed to a more 
# standard approach which seemed to provide better results.
#
# https://en.wikipedia.org/wiki/Linear_congruential_generator
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
    
    # Constants for LCG for x coordinate
    li a2, 1103515245  # multiplier
    li a3, 12345       # increment
    li a4, 2147483648  # modulus (2^31)

    # LCG algorithm for x coordinate
    mul a0, a0, a2
    add a0, a0, a3
    rem a0, a0, a4

    # Constants for LCG for y coordinate
    li a2, 134775813  # different multiplier
    li a3, 1          # different increment
    li a4, 2147483648  # same modulus (2^31)

    # LCG algorithm for y coordinate
    mul a1, a1, a2
    add a1, a1, a3
    rem a1, a1, a4
    
    # Discard lower 16 bits
    srai a0, a0, 16
    srai a1, a1, 16
    
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