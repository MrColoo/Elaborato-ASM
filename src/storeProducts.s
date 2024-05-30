# ###################
# filename: storeProducts.s
# ###################

.section .data
    num_products: .int 0        # Numero di prodotti letti dal file
    num_products_saved: .int 0        # Numero di prodotti salvati in array

    filename:    
        .ascii "Ordini.txt"     # Nome del file di testo da leggere
    fd:
        .int 0                  # File descriptor

    buffer: .space 256          # Buffer per la lettura del file
    buffer_size: .int 256      # Dimensione del buffer
    buffer_index: .int 0        # Indice per scorrere il buffer
    newline: .byte 10           # Valore del simbolo di nuova linea
    comma: .byte 44             # Valore del simbolo di virgola
    bytes_read: .int 0          # Numero di byte letti dal file

    malloc_size:
    .int 0                     # 10 prodotti x 4 byte ciascuno (32 bit per prodotto)

    read_error:
        .ascii "Errore nella apertura del file\n\0" # Stringa di errore per apertura file
    error_msg:
        .ascii "Errore nel file\n\0"

    products_pointer:
        .int 0
    

.section .text

.global storeProducts    # rende visibile il simbolo storeProducts al linker

.type storeProducts, @function   # dichiarazione della funzione storeProducts
                        # la funzione legge un file e crea un array di prodotti

storeProducts:
    mov %eax, num_products        # Legge parametro funzione caricato prima in eax e lo salva nella variabile num_products
    imul $4, %eax                 # 4 byte per prodotto
    mov %eax, malloc_size         # calcola spazio necessario nello heap nella variabile malloc_size

     # Ottiene l'attuale fine dell'heap (program break)
    movl $45, %eax        # Syscall number for brk
    xor %ebx, %ebx         # Argomento: 0 per ottenere l'attuale break
    int $0x80             # Effettua la syscall
    movl %eax, products_pointer       # Salva l'attuale break in %edi

    # Allocazione della memoria per i prodotti
    movl products_pointer, %ebx
    addl malloc_size, %ebx      # Aumenta il break dei byte necessari a contenere tutti i prodotti
    movl $45, %eax        # Syscall number for brk
    int $0x80             # Effettua la syscall

    # Verifica se la syscall ha avuto successo
    cmpl %ebx, %eax       # Confronta il valore di ritorno con il valore richiesto
    jne _ret             # Se non è uguale, salta a error

    mov products_pointer, %edi

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
    mov buffer_size, %edx      # Lunghezza massima
    int $0x80           # Interruzione del kernel

    # Salva il numero di byte letti
    mov %eax, bytes_read

    cmp $0, %eax        # Controllo se ci sono errori o EOF
    jle _file_close     # Se ci sono errori o EOF, chiudo il file

    # Resetta l'indice del buffer
    xor %esi, %esi 

    # Resetta l'accumulatore per il numero corrente
    xor %ecx, %ecx

parse_buffer:
    # Controlla se abbiamo raggiunto la fine dei dati letti nel buffer
    mov bytes_read, %eax
    cmp %eax, %esi
    jge _read_file   # Se sì, torna a leggere dal file

    # Carica il byte corrente del buffer in AL
    mov buffer(,%esi,1), %al

    cmp %al, newline     # Controlla se è una nuova linea
    je next_field      # Se sì, inizia un nuovo prodotto

    cmp %al, comma       # Controlla se è una virgola
    je next_field       # Se sì, passa al prossimo campo

    sub $'0', %al        # Converte il carattere ASCII in valore numerico
    
    cmp $'9', %al # controllo che il numero sia un numero 
    jg error      # se non e un numero

    imul $10, %ecx       # Moltiplica l'accumulatore per 10
    add %al, %cl        # Aggiunge il valore numerico all'accumulatore
    jmp increment_index

increment_index:
    inc %esi             # Incrementa l'indice del buffer
    cmp buffer_size, %esi  # Controlla se siamo alla fine del buffer
    jl parse_buffer   # Continua a processare se non siamo alla fine

    call _file_close     # Chiudi il file
    jmp _ret            # Esce dal programma

next_field:
    mov %cl, (%edi)     # Salva l'accumulatore nel campo corrente
    xor %ecx, %ecx       # Resetta l'accumulatore per il prossimo numero
    inc %edi         # Passa al prossimo campo del prodotto

    mov products_pointer, %edx #######
    mov (%edx), %cl #####
    xor %ecx, %ecx  ########     # Resetta l'accumulatore per il prossimo numero
    xor %edx, %edx  #########     # Resetta l'accumulatore per il prossimo numero
    
    jmp increment_index

error:
    # Stampiamo il messaggio di errore
    
    mov $6, %eax        # syscall close
    mov fd, %ecx      # File descriptor
    int $0x80           # Interruzione del kernel

    leal error_msg, %eax     # carico l'indirizzo di $error_msg
    call printf

    ret

# Chiude il file
_file_close:
    mov $6, %eax        # syscall close
    mov fd, %ecx      # File descriptor
    int $0x80           # Interruzione del kernel

_ret:
    mov products_pointer, %eax
    mov num_products, %ebx
    ret
