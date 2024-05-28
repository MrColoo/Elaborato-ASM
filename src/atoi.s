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
    xor %ecx, %ecx

loop:
    cmp $0, (%eax)
    je fine_atoi
    
    imul $10, %ecx
    mov (%eax), %ebx
    sub $'0', %ebx
    addl %ebx, %ecx
    inc %eax
    
    jmp loop

fine_atoi:
    mov %ecx, %eax

    ret # fine della funzione atoi
        # l'esecuzione riprende dall'istruzione sucessiva
        # alla call che ha invocato atoi
