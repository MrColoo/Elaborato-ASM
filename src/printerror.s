# ###################
# filename: printerror.s
# ###################

.section .text

.global printerror # rende visibile il simbolo printerror al linker

.type printerror, @function   # dichiarazione della funzione printerror
                        # la funzione stampa a schermo una stringa
                        # la stringa da stampare deve essere
                        # stata caricata nel registro eax

find_string_len:
    cmpb $0, (%eax)
    je _ret

    inc %edx             # Incrementa il contatore
    inc %eax             # Passa al carattere successivo
    jmp find_string_len       # Ripete il ciclo

printerror:
    xor %edx, %edx
    mov %eax, %ecx # Buffer di output
    call find_string_len

print:

    # Stampa il contenuto della riga
    mov $4, %eax        # syscall write
    mov %ecx, %ecx
    mov $2, %ebx        # 
    int $0x80           # Interruzione del kernel

_ret:
    ret # fine della funzione printerror
        # l'esecuzione riprende dall'istruzione sucessiva
        # alla call che ha invocato printerror






        