# ###################
# filename: atoi.s
# ###################

.section .data

.section .text

.global atoi # rende visibile il simbolo atoi al linker

.type atoi, @function   # dichiarazione della funzione atoi
                        # la funzione converte una stringa in un intero
                        # l'indirizzo della stringa da convertire deve essere
                        # stato caricato nel registro eax
atoi:
    push %ebx           # backup dei registri
    push %ecx
    xor %ecx, %ecx      # reset ECX che usero come accumulatore

loop:
    cmpb $0, (%eax)     # verifica se è arrivato alla fine della stringa
    je fine_atoi

    cmpb $10, (%eax)    # verifica se è arrivato un newline ('\n')
    je fine_atoi
    
    imul $10, %ecx      # moltiplica l'accumulatore per 10
    movzx (%eax), %ebx  # legge il carattere dalla stringa e lo copia in EBX
    sub $'0', %bl       # converte il carattere letto da ASCII a INT
    add %ebx, %ecx      # aggiunge all'accumulatore il numero ottenuto
    inc %eax            # passa al carattere successivo
    xor %ebx, %ebx      # reset EBX
    
    jmp loop

fine_atoi:
    mov %ecx, %eax      # copio il valore convertito in intero in EAX
    pop %ecx            # ripristino i registri
    pop %ebx
    ret # fine della funzione atoi
        # l'esecuzione riprende dall'istruzione sucessiva
        # alla call che ha invocato atoi
