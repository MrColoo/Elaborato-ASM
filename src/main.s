# ###################
# filename: main.s
# ###################

.section .data
filename:    
    .asciz "Ordini.txt" # Nome del file di testo da leggere
fd:
    .int 0               # File descriptor
# buffer: .string ""       # Spazio per il buffer di input
buffer: .space 256          # Buffer per la lettura del file
buffer_width: .int 256      # Dimensione del buffer
newline: .byte 10        # Valore del simbolo di nuova linea
bytes_read: .int 0            # Numero di byte letti
buffer_index: .int 0        # Indice per scorrere il buffer

menu_prompt: 
    .asciz "[1]: Earliest Deadline First (EDF)\n[2]: Highest Priority First (HPF)\n[3]: Esci dal programma\n> "
product_fmt: 
    .asciz "%d:%d\n"
conclusion_fmt: 
    .asciz "Conclusione: %d\n"
penalty_fmt:
    .asciz "Penalty: %d\n"

read_error:
    .asciz "Errore nella apertura del file\n"
format_error:
    .asciz "Alcuni valori indicati nel file non sono corretti\n"




num_products: .int 0       # Numero di prodotti letti dal file
element_size: .word 4       # Ogni prodotto ha 4 byte (1 per ciascun campo)
input_choice: .byte 0       # Scelta dell'algoritmo di pianificazione

.section .bss
products_pointer: .word 0       # Puntatore all'array di prodotti




.section .text
    .global _start


# Apre il file

_file_open:
    mov $5, %eax        # syscall open
    mov $filename, %ebx # Nome del file
    mov $0, %ecx        # Modalità di apertura (O_RDONLY)
    int $0x80           # Interruzione del kernel

    # Se c'è un errore, esce
    cmp $0, %eax
    jl _exit

    mov %eax, fd      # Salva il file descriptor da %eax a fd

# Legge il file riga per riga
_find_num_products:
    mov $3, %eax        # syscall read
    mov fd, %ebx        # File descriptor
    mov $buffer, %ecx   # Buffer di input
    mov buffer_width, %edx      # Lunghezza massima
    int $0x80           # Interruzione del kernel

    # Salva il numero di byte letti
    mov %eax, bytes_read

    cmp $0, %eax        # Controllo se ci sono errori o EOF
    jle _file_close     # Se ci sono errori o EOF, chiudo il file

    # Resetta l'indice del buffer
    movl $0, buffer_index

_process_buffer:
    # Controlla se abbiamo raggiunto la fine dei dati letti nel buffer
    mov bytes_read, %ecx
    cmp %ecx, buffer_index
    jge _find_num_products   # Se sì, torna a leggere dal file

    # Carica il byte corrente del buffer in AL
    mov buffer_index, %ecx
    mov buffer(,%ecx,1), %al

    # Incrementa l'indice del buffer
    incl buffer_index

    # Ad esempio, controlla se è una nuova linea o un delimitatore
    cmp %al, newline
    je _newline_found     # Gestisci la nuova linea

    # Torna a processare il prossimo byte nel buffer
    jmp _process_buffer

_newline_found:
    incw num_products          # incremento il numero di prodotti

    # Torna a processare il prossimo byte nel buffer
    jmp _process_buffer

# Chiude il file
_file_close:
    mov $6, %eax        # syscall close
    mov %ebx, %ecx      # File descriptor
    int $0x80           # Interruzione del kernel
    ret
    
_exit:
    mov $1, %eax        # syscall exit
    xor %ebx, %ebx      # Codice di uscita 0
    int $0x80           # Interruzione del kernel

_start:
    call _file_open           # Chiama la funzione per aprire il file

    mov num_products, %eax
    call itoa

    # Fine programma
    jmp _exit





