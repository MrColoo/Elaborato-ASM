.global hpfAlgorithm    # rende visibile il simbolo findNum al linker

.type hpfAlgorithm, @function   # dichiarazione della funzione itoa
                        # la funzione converte un intero in una stringa
                        # il numero da convertire deve esse

hpfAlgorithm:
    pushl %ebp
    movl %esp, %ebp
    subl $16, %esp  # Alloca spazio per variabili locali

    movl 8(%ebp), %esi   # Carica processi in %esi
    movl 12(%ebp), %ecx  # Carica num in %ecx

    decl %ecx            # Decrementa num (num - 1)

sort_loop_esterno:
    cmpl $0, %ecx        # Confronta ecx con 0
    jl fine_sort         # Se ecx < 0, termina il ciclo di ordinamento

    pushl %ecx           # Salva ecx (i) nello stack
    movl $0, %edi        # Inizializza j a 0

sort_loop_interno:
    movl 12(%ebp), %ebx  # Carica num in ebx
    subl %ecx, %ebx      # ebx = num - i
    decl %ebx            # ebx = num - i - 1
    cmp %edi, %ebx      # Confronta j con num - i - 1
    jge fine_ciclo_interno # Se j >= num - i - 1, termina il ciclo interno

    sal $4, %edi         # Moltiplica j per 16 (dimensione di struct processo)

    # Accesso a processi[j]
    movl (%esi, %edi, 1), %eax  # Carica l'indirizzo di processi[j] in eax
    movl 12(%eax), %ebx         # Carica processi[j].priorita in ebx

    add $16, %edi              # Calcola l'offset per processi[j+1]
    movl (%esi, %edi, 1), %edx  # Carica l'indirizzo di processi[j+1] in edx
    movl 12(%edx), %ecx         # Carica processi[j+1].priorita in ecx

    cmp %ebx, %ecx             # Confronta processi[j].priorita con processi[j+1].priorita
    jg scambio_processi         # Se processi[j].priorita > processi[j+1].priorita, scambia

    cmp %ecx, %ebx             # Se processi[j].priorita == processi[j+1].priorita
    jne incrementa_j

    movl 8(%eax), %ebx          # Carica processi[j].scadenza in ebx
    movl 8(%edx), %ecx          # Carica processi[j+1].scadenza in ecx
    cmp %ecx, %ebx             # Confronta processi[j].scadenza con processi[j+1].scadenza
    jg scambio_processi         # Se processi[j].scadenza > processi[j+1].scadenza, scambia

incrementa_j:
    sar $4, %edi               # Divide l'indice per 16 per ottenere j originale
    inc %edi                   # Incrementa j
    jmp sort_loop_interno       # Ripeti il ciclo interno

scambio_processi:
    subl $16, %edi              # Ripristina l'offset di j
    movl (%esi, %edi, 1), %eax  # Carica processi[j] in eax
    add $16, %edi              # Incrementa di nuovo l'offset per puntare a processi[j+1]
    movl (%esi, %edi, 1), %ebx  # Carica processi[j+1] in ebx

    movl %ebx, (%esi, %edi, 1)  # Scrive processi[j+1] in processi[j]
    subl $16, %edi              # Ripristina l'offset di j
    movl %eax, (%esi, %edi, 1)  # Scrive processi[j] in processi[j+1]

    jmp incrementa_j            # Salta a incrementa_j

fine_ciclo_interno:
    popl %ecx                   # Ripristina ecx (i) dallo stack
    decl %ecx                   # i++
    jmp sort_loop_esterno       # Ripeti il ciclo esterno

fine_sort:
    movl $0, time               # Inizializza time a 0
    movl $0, totalPenalty       # Inizializza totalPenalty a 0
    movl $0, %edi               #

    calcolo_penalita:
    cmpl num,%edi                   # confronto i con num
    jge fine_penalita               # salto a fine penalita 

    sal $4, %edi                    # moltiplico 16 per i (dimensione struct)
    movl processi(,%edi,1), %eax    # carico processi[i] in eax 
    sarl $4, %edi                   # ripristino l'indice edi 

    movl 4(%eax), %ebx              # carico i processi processi[i].identidicativo in ebx 
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

    call printf
