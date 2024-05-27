# ###################
# filename: main.s
# ###################

.section .data


menu_prompt: 
    .asciz "[1]: Earliest Deadline First (EDF)\n[2]: Highest Priority First (HPF)\n[3]: Esci dal programma\n> "
product_fmt: 
    .asciz "%d:%d\n"
conclusion_fmt: 
    .asciz "Conclusione: %d\n"
penalty_fmt:
    .asciz "Penalty: %d\n"


format_error:
    .asciz "Alcuni valori indicati nel file non sono corretti\n"


element_size: .word 4       # Ogni prodotto ha 4 byte (1 per ciascun campo)
input_choice: .byte 0       # Scelta dell'algoritmo di pianificazione

.section .bss
products_pointer: .word 0       # Puntatore all'array di prodotti




.section .text
    .global _start
    
_exit:
    mov $1, %eax        # syscall exit
    xor %ebx, %ebx      # Codice di uscita 0
    int $0x80           # Interruzione del kernel

_start:
    call findNumProducts           # Chiama la funzione per aprire il file
    call storeProducts

    # call itoa

    # Fine programma
    jmp _exit
