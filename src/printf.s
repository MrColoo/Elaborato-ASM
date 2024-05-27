# ###################
# filename: printf.s
# ###################

.section .text

.global printf # rende visibile il simbolo printf al linker

.type printf, @function   # dichiarazione della funzione printf
                        # la funzione stampa a schermo una stringa
                        # la stringa da stampare deve essere
                        # stata caricata nel registro eax

find_string_len:
    cmpb $0, (%eax)
    je _ret

    inc %edx             # Incrementa il contatore
    inc %eax             # Passa al carattere successivo
    jmp find_string_len       # Ripete il ciclo

printf:
    xor %edx, %edx
    mov %eax, %ecx # Buffer di output
    call find_string_len

print:

    # Stampa il contenuto della riga
    mov $4, %eax        # syscall write
    mov %ecx, %ecx
    # mov $1, %ebx        # File descriptor standard output (stdout)
    int $0x80           # Interruzione del kernel

_ret:
    ret # fine della funzione printf
        # l'esecuzione riprende dall'istruzione sucessiva
        # alla call che ha invocato printf






        