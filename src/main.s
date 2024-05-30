# ###################
# filename: main.s
# ###################

.section .data


    menu_prompt: 
        .ascii "Indicare l'algoritmo di pianificazione che si vuole utilizzare:\n[1]: Earliest Deadline First (EDF)\n[2]: Highest Priority First (HPF)\n[3]: Esci dal programma\n> \0"
    invalid_option: 
        .ascii "Il valore inserito non è valido \n\0"

    format_error:
        .ascii "Alcuni valori indicati nel file non sono corretti\n"

    products_pointer: .int 0       # Puntatore all'array di prodotti
    num_products: .int 0        # contatore numero di prodotti presenti nel file

.section .text
    .global _start

_start:
    call findNumProducts            # Chiama la funzione per trovare il numero di prodotti nel file
    mov %eax, num_products          # Salva il numero di prodotti nella variabile    
    call storeProducts              # Chiama la funzione per salvare i prodotti nell'array
    mov %eax, products_pointer      # Salva il puntatore all'array di prodotti nella variabile
    
display_menu:
    leal menu_prompt, %eax          # carica l'indirizzo della stringa del menu in EAX
    call printf                     # stampa la stringa
    call readstr                    # legge l'input da tastiera e carica in EAX l'indirizzo della stringa
    call atoi
    call verifica_menu
    jmp display_menu

verifica_menu:
    cmp $1, %eax
    je EDF

    cmp $2, %eax
    je HPF

    cmp $3, %eax
    je _exit

    leal invalid_option, %eax
    call printerror
    ret

# Fine programma
_exit:
    mov $1, %eax        # syscall exit
    xor %ebx, %ebx      # Codice di uscita 0
    int $0x80           # Interruzione del kernel

EDF:
    mov products_pointer, %eax
    mov num_products, %ebx
    call EDFalgorithm
    jmp _start

HPF:
    mov products_pointer, %eax
    mov num_products, %ebx
    call HPFalgorithm
    jmp _start