# ###################
# filename: storeProducts.s
# ###################

.section .data
    num_products: .int 0            # Numero di prodotti letti dal file

    filename: .int 0                # Puntatore al nome del file di testo da leggere
    fd: .int 0                      # File descriptor

    buffer: .space 256              # Buffer per la lettura del file
    buffer_size: .int 256           # Dimensione del buffer
    buffer_index: .int 0            # Indice per scorrere il buffer
    bytes_read: .int 0              # Numero di byte letti dal file
    
    newline: .byte 10               # Valore del simbolo di nuova linea
    comma: .byte 44                 # Valore del simbolo di virgola
    
    malloc_size: .int 0             # grandezza in byte da allocare per l'array

    error_read:
        .ascii "Errore nell'apertura del file\nVerifica che esista e che si abbiano i permessi adeguati alla lettura\n\0" # Stringa di errore per apertura file
    error_msg:
        .ascii "Alcuni valori nel file sono errati e non rispettato le richieste\nSono ammessi unicamente caratteri numerici: ID 1-127, Durata 1-10, Scadenza 1-100, Priorità 1-5 \n\0"

    products_pointer:
        .int 0
    

.section .text

.global storeProducts    # rende visibile il simbolo storeProducts al linker

.type storeProducts, @function   # dichiarazione della funzione storeProducts
                        # la funzione legge un file e crea un array di prodotti

storeProducts:

    push %ebx
    push %ecx
    push %edx
    push %esi
    push %edi

    mov %ebx, filename

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
    mov filename, %ebx # Nome del file
    mov $0, %ecx        # Modalità di apertura (O_RDONLY)
    int $0x80           # Interruzione del kernel

    # Se c'è un errore, esce
    cmp $0, %eax
    jle read_error

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

    # Resetta l'indicatore del campo attuale
    xor %ebx, %ebx

parse_buffer:
    # Controlla se abbiamo raggiunto la fine dei dati letti nel buffer
    mov bytes_read, %eax
    cmp %eax, %esi
    jge _read_file   # Se sì, torna a leggere dal file

    # Carica il byte corrente del buffer in AL
    mov buffer(,%esi,1), %al

    cmp %al, newline     # Controlla se è una nuova linea
    je verifica      # Se sì, inizia un nuovo prodotto

    cmp %al, comma       # Controlla se è una virgola
    je verifica       # Se sì, passa al prossimo campo

    cmp $'9', %al # controllo che il numero sia un numero 
    jg error      # se non e un numero

    sub $'0', %al        # Converte il carattere ASCII in valore numerico

    imul $10, %ecx       # Moltiplica l'accumulatore per 10
    add %al, %cl        # Aggiunge il valore numerico all'accumulatore
    jmp increment_index

increment_index:
    inc %esi             # Incrementa l'indice del buffer
    cmp buffer_size, %esi  # Controlla se siamo alla fine del buffer
    jl parse_buffer   # Continua a processare se non siamo alla fine

    call _file_close     # Chiudi il file
    jmp _ret            # Esce dal programma

verifica:
    cmp $0, %ebx
    je verifica_ID

    cmp $1, %ebx
    je verifica_durata

    cmp $2, %ebx
    je verifica_scadenza

    cmp $3, %ebx
    je verifica_priorita

next_field:
    cmp $0, %cl
    jle error
    mov %cl, (%edi)     # Salva l'accumulatore nel campo corrente
    xor %ecx, %ecx       # Resetta l'accumulatore per il prossimo numero
    inc %edi         # Passa al prossimo campo del prodotto
    
    jmp increment_index

verifica_ID:
    cmpb $127, %cl
    jg error
    inc %ebx
    jmp next_field

verifica_durata:
    cmpb $10, %cl
    jg error
    inc %ebx
    jmp next_field

verifica_scadenza:
    cmpb $100, %cl
    jg error
    inc %ebx
    jmp next_field

verifica_priorita:
    cmpb $5, %cl
    jg error
    xor %ebx, %ebx
    jmp next_field

error:
    # Stampa il messaggio di errore
    
    mov $6, %eax        # syscall close
    mov fd, %ecx      # File descriptor
    int $0x80           # Interruzione del kernel

    leal error_msg, %eax     # carico l'indirizzo di $error_msg
    call printerror
    
    jmp _exit

read_error:
    leal error_read, %eax     # carico l'indirizzo di $error_msg
    call printerror

    jmp _exit

# Chiude il file
_file_close:
    mov $6, %eax        # syscall close
    mov fd, %ecx      # File descriptor
    int $0x80           # Interruzione del kernel

    mov products_pointer, %eax

_ret:
    
    pop %edi
    pop %esi
    pop %edx
    pop %ecx
    pop %ebx

    ret

_exit:
    mov $1, %eax        # syscall exit
    xor %ebx, %ebx      # Codice di uscita 0
    int $0x80           # Interruzione del kernel