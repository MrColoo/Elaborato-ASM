# ###################
# filename: findNumProducts.s
# ###################

.section .data
    num_products: .int 0       # Numero di prodotti letti dal file

    filename:    
        .ascii "Ordini.txt\0" # Nome del file di testo da leggere
    fd:
        .int 0               # File descriptor

    buffer: .space 256          # Buffer per la lettura del file
    buffer_width: .int 256      # Dimensione del buffer

    newline: .byte 10        # Valore del simbolo di nuova linea

    bytes_read: .int 0            # Numero di byte letti
    buffer_index: .int 0        # Indice per scorrere il buffer

    read_error:
        .ascii "Errore nella apertura del file\n"

.section .text

.global findNumProducts    # rende visibile il simbolo findNum al linker

.type findNumProducts, @function   # dichiarazione della funzione itoa
                        # la funzione converte un intero in una stringa
                        # il numero da convertire deve esse

findNumProducts:
    push %ebx
    push %ecx
    push %edx
    
# Apre il file
_file_open:
    mov $5, %eax        # syscall open
    mov $filename, %ebx # Nome del file
    mov $0, %ecx        # Modalità di apertura (O_RDONLY)
    int $0x80           # Interruzione del kernel

    # Se c'è un errore, esce
    cmp $0, %eax
    jle _ret

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
    
    mov num_products, %eax

    pop %edx
    pop %ecx
    pop %ebx

    ret

_ret:
    ret
