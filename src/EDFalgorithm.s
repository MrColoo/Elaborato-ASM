# ###################
# filename: EDFalgorithm.s
# ###################

.section .data

    conclusione_str:
        .ascii "Conclusione: \0"
    penalty_str:
        .ascii "Penalty: \0"
    

.section .bss
    products_pointer: .int 0
    num_products: .int 0


.section .text

.global EDFalgorithm            # rende visibile il simbolo edf al linker

.type EDFalgorithm, @function   # dichiarazione della funzione edf
                                # la funzione scambia due prodotti nell'array

EDFalgorithm:
    mov %eax, products_pointer  # Salva nella variabile il puntatore al primo elemento dell'array
    mov %ebx, num_products      # Salva nella variabile il numero dei prodotti nel file

    dec %ebx                    # num_products - 1
    xor %edi, %edi              # reset EDI che usero come i
    
external_loop:
    cmp %ebx, %edi              # compara i con numproducts - 1
    jge print_results           # Se i > num_products - 1 stampa i risultati
    xor %esi, %esi              # reset ESI che usero come j
    push %ebx

    sub %edi, %ebx              # num_products - i - 1
    push %eax                   # Salvo nella pila il puntatore al primo indirizzo dell'array
    
internal_loop:
    cmp %ebx, %esi              # compara j con num_products - i -1
    jge end_internal_loop       # se j > num_products - i - 1 salta alla fine del ciclo for
    
    add %esi, %eax              # scorri a elemento j

if1:
    xor %ecx, %ecx              # reset ECX che usero come registro temporaneo per i confronti
    mov 7(%eax), %cl            # copia in CL la priorita dell'elemento j+1
    cmp %cl, 3(%eax)            # compara priorita elemento j con priorita elemento j+1
    jge if2                     # se è maggiore o uguale passa alla seconda condizione

    call swapProducts           # chiama la funzione che scambia i prodotti nell'array
    inc %esi                    # incrementa j
    jmp back_internal_loop      # torna al ciclo for interno

if2:
    cmp %cl, 3(%eax)            # compara priorita elemento j con priorita elemento j+1
    jne back_internal_loop      # se non sono uguali, torna al ciclo for interno

    mov 6(%eax), %cl            # copia in CL la scadenza dell'elemento j+1
    cmp %cl, 2(%eax)            # compara scadenza elemento j con scadenza elemento j+1
    jle back_internal_loop      # se scadenza j <=  torna al ciclo for interno

    call swapProducts

back_internal_loop:
    inc %esi
    jmp internal_loop
end_internal_loop:
    pop %eax
    pop %ebx
    inc %edi
    jmp external_loop

print_results:
    xor %ecx, %ecx   # uso ECX come i
    xor %edi, %edi  # uso EDI per salvare time
    xor %esi, %esi  # uso ESI per salvare la penalità totale

print_products:
    cmp $0, %ebx
    je print_stats
    push %eax
    mov (%eax), %eax
    call itoa
    call printf

    mov $':', %eax
    call printf

    pop %eax
    push %eax
    mov 2(%eax), %eax
    call itoa
    call printf
    pop %eax

    add 1(%eax), %edi
    cmp 2(%eax), %edi
    jg update_penalty

    add $4, %eax

    dec %ebx
    jmp print_products

print_stats:
    leal conclusione_str, %eax
    call printf
    mov %edi, %eax
    call itoa
    call printf

    leal penalty_str, %eax
    call printf
    mov %esi, %eax
    call itoa
    call printf

    ret

update_penalty:
    call calcola_penalty
    add $4, %eax

    dec %ebx
    jmp print_products
    
calcola_penalty:
    push %edi
    sub 2(%eax), %edi
    imul 3(%eax), %edi
    add %edi, %esi
    pop %edi
    ret



