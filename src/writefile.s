.section .data
    num_products: .int 0       # Numero di prodotti letti dal file
    msg_conclusione: .asciz "Conclsuione: "
    msg_penalty: .asciz "Penalty: "

    filename:    
        .asciz "Pianificazione.txt" # Nome del file di testo da leggere
    fd:
        .int 0               # File descriptor

    buffer: .space 256          # Buffer per la lettura del file
    buffer_width: .int 256      # Dimensione del buffer
    newline: .byte 10        # Valore del simbolo di nuova linea
    bytes_read: .int 0            # Numero di byte letti
    buffer_index: .int 0        # Indice per scorrere il buffer
 

    read_error:
        .asciz "Errore nella apertura del file\n"

.section .text

.global writefile    # rende visibile il simbolo findNum al linker

.type writefile, @function   # dichiarazione della funzione itoa
                        # la funzione converte un intero in una stringa
                        # il numero da convertire deve esse


writefile:


_file_open_write:
   # Apri il file per scrittura (crea se non esiste)
    movl $5, %eax            # sys_open
    movl $filename, %ebx     # Nome del file
    movl $0101, %ecx         # flags (O_WRONLY | O_CREAT)
    movl $0644, %edx         # mode (rw-r--r--)
    int $0x80
    cmpl $0, %eax            # comparo se uguale a 0 
    js error                 # Se errore, gestisce l'errore

    movl %eax, %edi          # Salva il file descriptor in %edi

    movl $msg_conclusione, %ecx         # scrivo Conclusione: in ecx 
    call lettura_stringa
    movl $time, %eax                    # metto time in eax 
    call itoa                           # call a itoa 
    



error:
    movl $1, %eax               # sys_exit
    movl $1, %ebx           # codice uscita 1
    int $0x80


    

