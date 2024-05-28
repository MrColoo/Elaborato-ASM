# ###################
# filename: EDFalgorithm.s
# ###################

.section .data
    time: .int 0
    totalPenalty: .int 0
    num_products: .int 0
    processi: .int 0

.section .text 

.global algoritmo_edf   

.type algoritmo_edf, @function   # dichiarazione della funzione itoa
                        
                       


algoritmo_edf: 
    movl %eax, num_products             # sposto il valore di EAX nella variabile num_products

    pushl %ebp                          # salvo il frame pointer  ?
    movl %esp, %ebp                     # Imposto il nuovo frame pointer (salvato in esp) 
    subl $16, %esp                      # alloco spazio per le variabili locali  
 
 
# Ciclo esterno (for i = 0; i < num_products-1; i++) 
sort_loop_esterno: 
    movl num_products, %ebx          # Carica num_products in ebx 
    decl %ebx                        # ebx = num_products - 1 
    cmpl %ecx, %ebx                  # Confronta i con num_products - 1
    jl fine_sort                     # Se ecx < num_products - 1, termina il ciclo di ordinamento 
 
    pushl %ecx                       # Salva ecx (i) nello stack 
    xor %edi, %edi                   # Inizializza j a 0 
 
# Ciclo interno (for j = 0; j < num_products-i-1; j++) 
sort_loop_interno: 
    movl num_products, %ebx          # Carica num_products in ebx 
    subl %ecx, %ebx                  # ebx = num_products - i 
    decl %ebx                        # ebx = num_products - i - 1 
    cmpl %edi, %ebx                  # Confronta j con num_products - i - 1 
    jge fine_ciclo_interno           # Se j >= num_products - i - 1, termina il ciclo interno 
 
    shl $4, %edi                     # Moltiplica j per 16 (dimensione di struct processo) 
 
    # Accesso a processi[j] 
    movl processi(,%edi,1), %eax     # Carica l'indirizzo di processi[j] in eax 
    movl 4(%eax), %ebx               # Carica processi[j].scadenza in ebx 
 
    addl $16, %edi                   # Calcola l'offset per processi[j+1] 
    movl processi(,%edi,1), %edx     # Carica l'indirizzo di processi[j+1] in edx 
    movl 4(%edx), %ecx               # Carica processi[j+1].scadenza in ecx 
 
    cmpl %ebx, %ecx                  # Confronta processi[j].scadenza con processi[j+1].scadenza 
    jg scambio_processi              # Se processi[j].scadenza > processi[j+1].scadenza, scambia 
 
    je cmp_priorita                  # Se processi[j].scadenza == processi[j+1].scadenza, confronta priorità 
 
    jmp incrementa_j                 # Altrimenti, incrementa j 
 
cmp_priorita: 
    movl 12(%eax), %ebx              # Carica processi[j].priorita in ebx 
    movl 12(%edx), %ecx              # Carica processi[j+1].priorita in ecx 
 
    cmpl %ebx, %ecx                  # Confronta processi[j].priorita con processi[j+1].priorita 
    jl scambio_processi              # Se processi[j].priorita < processi[j+1].priorita, scambia 
 
    jmp incrementa_j                 # Altrimenti, incrementa j 
 
scambio_processi: 
    subl $16, %edi                   # Ripristina l'offset di j 
    movl processi(,%edi,1), %eax     # Carica processi[j] in eax 
    addl $16, %edi                   # Incrementa di nuovo l'offset per puntare a processi[j+1] 
    movl processi(,%edi,1), %ebx     # Carica processi[j+1] in ebx 
 
    movl %ebx, processi(,%edi,1)     # Scrive processi[j+1] in processi[j] 
    subl $16, %edi                   # Ripristina l'offset di j 
    movl %eax, processi(,%edi,1)     # Scrive processi[j] in processi[j+1] 
 
incrementa_j: 
    shrl $4, %edi                    # Divide l'indice per 16 per ottenere j originale 
    incl %edi                        # Incrementa j 
    jmp sort_loop_interno            # Ripeti il ciclo interno 
 
fine_ciclo_interno: 
    popl %ecx                        # Ripristina ecx (i) dallo stack 
    incl %ecx                        # i++ 
    jmp sort_loop_esterno            # Ripeti il ciclo esterno 
 
fine_sort: 
 
    movl $0, time                   # inizializzo time a 0 
    movl $0, totalPenalty           # inizializzo totalPenalty a 0 
    movl $0, %edi                   # i a 0  (i=0) 
 
calcolo_penalita: 
    cmpl num_products, %edi         # confronto i con num_products 
    jge fine_penalita               # salto a fine penalita  
 
    shl $4, %edi                    # moltiplico 16 per i (dimensione struct) 
    movl processi(,%edi,1), %eax    # carico processi[i] in eax  
    shrl $4, %edi                   # ripristino l'indice edi  
 
    movl 4(%eax), %ebx              # carico i processi processi[i].identificativo in ebx  
    addl %ebx, time                 # time + processi[i] 
 
    # qui calcolo la penalita se il tempo supera la durata  
 
    movl time, %ebx                 # carico time in ebx
    cmpl 8(%eax), %ebx              # confronto time con processi[i].scadenza  
    jle no_penalita                 # salto a no_penalita 
 
    subl 8(%eax), %ebx              # Calcola il ritardo (time - processi[i].scadenza) 
    imull 12(%eax), %ebx            # Moltiplica il ritardo per processi[i].priorita 
    addl %ebx, totalPenalty         # Aggiungo la penalità totale 
 
 
no_penalita: 
    incl %edi                       # incremento i 
    jmp calcolo_penalita            # salto a calcolo_penalita 
 
fine_penalita: 
    ret