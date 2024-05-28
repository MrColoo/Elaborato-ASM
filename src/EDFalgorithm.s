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

.global EDFalgorithm # rende visibile il simbolo edf al linker

.type EDFalgorithm, @function   # dichiarazione della funzione edf
                        # la funzione scambia due prodotti nell'array

EDFalgorithm:
    mov %eax, products_pointer
    mov %ebx, num_products

    dec %ebx            # num_products - 1
    xor %ecx, %ecx      # reset ECX che usero come i
    
external_loop:
    cmp %ecx, %ebx      # compara i con numproducts - 1
    jge print_results
    xor %edx, %edx      # reset EDX che usero come j
    push %ebx

    sub %ecx, %ebx      # num_products - i - 1
    push %eax
    
internal_loop:
    cmp %edx, %ebx      # compara j con num_products - i -1
    jge end_internal_loop
    
    add %edx, %eax      # scorri a elemento j

if1:
    mov 7(%eax), %esi
    cmp 3(%eax), %esi # compara priorita elemento j con priorita elemento j+1
    jge if2  # se è maggiore o uguale torna al loop

    call swapProducts
    inc %edx
    jmp back_internal_loop

if2:
    cmp 3(%eax), %esi # compara priorita elemento j con priorita elemento j+1
    jne back_internal_loop

    mov 6(%eax), %esi
    cmp 2(%eax), %esi # compara scadenza elemento j con scadenza elemento j+1
    jle back_internal_loop

    call swapProducts

back_internal_loop:
    inc %edx
    jmp internal_loop
end_internal_loop:
    pop %eax
    pop %ebx
    inc %ecx
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
    cmp %edi, 2(%eax)
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



