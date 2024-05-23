# ###################
# filename: storeProducts.s
# ###################

.section .data
    num_products: .int 0       # Numero di prodotti letti dal file

    filename:    
        .asciz "Ordini.txt" # Nome del file di testo da leggere
    fd:
        .int 0               # File descriptor
    
    id: .int 0
    durata: .int 0
    scadenza: .int 0
    priorita: .int 0

    buffer: .space 256          # Buffer per la lettura del file
    buffer_width: .int 256      # Dimensione del buffer
    newline: .byte 10        # Valore del simbolo di nuova linea
    bytes_read: .int 0            # Numero di byte letti
    buffer_index: .int 0        # Indice per scorrere il buffer

    comma:
    .byte 44             # Valore del simbolo di virgola

    malloc_size:
    .int 40              # 10 prodotti x 4 byte ciascuno (32 bit per prodotto)

    read_error:
        .asciz "Errore nella apertura del file\n"

.section .text

.global storeProducts    # rende visibile il simbolo findNum al linker

.type storeProducts, @function   # dichiarazione della funzione itoa
                        # la funzione converte un intero in una stringa
                        # il numero da convertire deve esse


_move_ahead:
    # Controlla se abbiamo raggiunto la fine dei dati letti nel buffer
    mov bytes_read, %ecx
    cmp %ecx, %edi
    jge _read_file   # Se sì, torna a leggere dal file

    # Carica il byte corrente del buffer in AL
    mov buffer(,%edi,1), %al

    # Incrementa l'indice del buffer
    inc %edi

    ret

storeProducts:
    # Passo 3: Allocazione della memoria per i prodotti
    mov %eax, num_products
    imul $4, %eax                 # 4 byte per prodotto
    mov %eax, malloc_size
    mov malloc_size, %ebx
    mov $45, %eax                 # syscall brk
    int $0x80
    mov %eax, products_pointer    # Salva il puntatore alla memoria allocata

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
_read_file:
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
    xor %edi, %edi

_find_ID:
    call _move_ahead
    # Ad esempio, controlla se è una nuova linea o un delimitatore
    cmp %al, comma 
    je _find_duration     # Gestisci la nuova linea



    jmp _find_ID

_find_duration:

_find_deadline:

_find_priority:


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
    ret

_ret:
    ret