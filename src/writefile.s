.section .data
    num_products: .int 0          # Numero di prodotti letti dal file
    msg_conclusione: .asciz "Conclusione: "
    msg_penalty: .asciz "Penalty: "
    filename: .asciz "Pianificazione.txt" # Nome del file di testo da leggere
    fd: .int 0                    # File descriptor
    buffer: .space 256            # Buffer per la lettura del file
    buffer_width: .int 256        # Dimensione del buffer
    newline: .byte 10             # Valore del simbolo di nuova linea
    bytes_read: .int 0            # Numero di byte letti
    buffer_index: .int 0          # Indice per scorrere il buffer
    read_error: .asciz "Errore nell'apertura del file\n"

.section .text
.global writefile

writefile:
    # Apri il file per scrittura (crea se non esiste)
    movl $5, %eax                # sys_open
    movl $filename, %ebx         # Nome del file
    movl $0101, %ecx             # flags (O_WRONLY | O_CREAT)
    movl $0644, %edx             # mode (rw-r--r--)
    int $0x80
    testl %eax, %eax             # Controlla se ci sono errori
    js error                     # Se errore, gestisce l'errore
    movl %eax, %edi              # Salva il file descriptor in %edi

    movl $msg_conclusione, %ecx  # Scrivi "Conclusione: "
    call write_string
    movl time, %eax              # Metti il tempo in %eax
    call itoa                    # Call a itoa
    movb newline, buffer(%eax)   # Aggiungi newline alla fine della stringa
    call write_buffer            # Call a scrittura_buffer

    # Chiudi il file
    movl $6, %eax                # sys_close
    movl %edi, %ebx              # file descriptor
    int $0x80

    # Esci dal programma
    movl $1, %eax                # sys_exit
    xorl %ebx, %ebx              # exit code 0
    int $0x80

error:
    movl $1, %eax                # sys_exit
    movl $1, %ebx                # codice uscita 1
    int $0x80

write_string:
    # Calcola la lunghezza della stringa
    pushl %ecx                   # Salva %ecx
    movl %ecx, %esi              # Sposta l'indirizzo della stringa in %esi
    xorl %edx, %edx              # Azzera %edx
find_strlen:
    cmpb $0, (%esi, %edx, 1)     # Confronta il byte corrente con 0
    je write_now                 # Se è 0, termina
    incl %edx                    # Incrementa l'indice
    jmp find_strlen              # Continua a cercare

write_now:
    # Scrivi la stringa
    movl $4, %eax                # sys_write
    movl %edi, %ebx              # file descriptor
    movl %esi, %ecx              # buffer
    movl %edx, %edx              # length
    int $0x80
    popl %ecx                    # Ripristina %ecx
    ret

write_buffer:
    # Scrivi il buffer
    movl $4, %eax                # sys_write
    movl %edi, %ebx              # file descriptor
    leal buffer, %ecx            # carico l'indirizzo effettivo del buffer in %ecx
    movl $13, %edx               # imposto la lunghezza del buffer a 13 per evitare overflow
    int $0x80
    ret

itoa:
    pushl %edi                   # Salva %edi
    movl $10, %ebx               # Divisore per la conversione in decimale
    leal buffer(%eax), %edi      # Punta all'inizio della stringa nel buffer

convert_loop:
    xorl %edx, %edx              # Azzera il registro %edx (resto della divisione)
    divl %ebx                    # Divide %eax per %ebx, risultato in %eax e resto in %edx
    addb $'0', %dl               # Aggiunge il valore ASCII di '0' al registro %dl (resto della divisione)
    decl %edi                    # Decrementa %edi per costruire la stringa al contrario
    movb %dl, (%edi)             # Salva il carattere ASCII nella posizione puntata da %edi
    testl %eax, %eax             # Controlla se il quoziente (contenuto di %eax) è zero
    jnz convert_loop             # Salta a convert_loop se il quoziente non è zero, altrimenti esce dal ciclo

    movl %edi, %eax              # Memorizza l'indirizzo del primo carattere della stringa convertita in %eax (ritorno)
    popl %edi                    # Ripristina %edi
    ret
