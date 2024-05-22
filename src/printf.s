# ###################
# filename: printf.s
# ###################

.section .data
stringa: .ascii ""

.section .text

.global printf # rende visibile il simbolo printf al linker

.type printf, @function   # dichiarazione della funzione printf
                        # la funzione stampa a schermo una stringa
                        # la stringa da stampare deve essere
                        # stata caricato nel registro eax
printf:
    mov %eax, stringa

    # Stampa il contenuto della riga
    mov $4, %eax        # syscall write
    mov $1, %ebx        # File descriptor standard output (stdout)
    mov $stringa, %ecx   # Buffer di output
    int $0x80           # Interruzione del kernel

    ret # fine della funzione itoa
        # l'esecuzione riprende dall'istruzione sucessiva
        # alla call che ha invocato itoa