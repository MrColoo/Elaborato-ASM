# ###################
# filename: itoa.s
# ###################

.section .data

car:
    .byte 0 # la variabile car è dichiarata di tipo byte

buffer:
    .byte 255

.section .text

.global itoa # rende visibile il simbolo itoa al linker

.type itoa, @function   # dichiarazione della funzione itoa
                        # la funzione converte un intero in una stringa
                        # il numero da convertire deve essere
                        # stato caricato nel registro eax
itoa:
    mov $0, %ecx # carica il numero 0 in ecx

    xor %edi, %edi
    mov $buffer, %esi

continua_a_dividere:
    cmp $10, %eax   # confronta 10 con il contenuto di eax
    jge dividi  # salta all'etichetta dividi se eax è
                # maggiore o uguale di 10
    pushl %eax  # salva nello stack il contenuto di eax
    inc %ecx    # incrementa di 1 il valore di ecx per
                # contare quante push eseguo
                # ad ogni push salvo nello stack una cifra del
                # numero (a partire da quella meno significativa)
    jmp salva_in_stringa  # salta all'etichetta stampa

dividi:
    movl $0, %edx   # carica 0 in edx
    movl $10, %ebx  # carica 10 in ebx
    divl %ebx   # divide per ebx (10) il numero ottenuto
                # concatenando il contenuto di dx e ax (notare che
                # in questo caso dx=0)
                # il quoziente viene messo in eax, il resto in dx
    pushl %edx # salva il resto nello stack
    inc %ecx # incrementa il contatore delle cifre da stampare
    jmp continua_a_dividere

salva_in_stringa:
    
    cmp %ecx, %edi    # controlla se ci sono (ancora) caratteri da
                    # stampare
    je fine_itoa    # se ebx=0 ho stampato tutto, quindi salto alla fine
    popl %eax   # preleva l'elemento da stampare dallo stack
    
    addb $48, %al   # somma al valore car il codice ascii del carattere
                    # '0' (zero)

    mov %eax, (%esi)
    inc %esi
    inc %edi

    jmp salva_in_stringa  # ritorna all'etichetta stampa per stampare il
                # prossimo carattere. Notare che il blocco di
                # istruzioni compreso tra l'etichetta stampa
                # e l'istruzione jmp stampa e' un classico
                # esempio di come creare un ciclo while in assembly
fine_itoa:
    mov $buffer, %eax

    ret # fine della funzione itoa
        # l'esecuzione riprende dall'istruzione sucessiva
        # alla call che ha invocato itoa
