# ###################
# filename: EDF_file.s
# ###################
# Algoritmo EDF che stampa nel terminale e su file

.section .data

    conclusione_str:
        .ascii "Conclusione: \0"
    penalty_str:
        .ascii "Penalty: \0"
    edf_title_str:
        .ascii "Pianificazione EDF:\n\0"
    due_punti:
        .ascii ":\0"
    LF:
        .ascii "\n\0"

    fd: .int 0
    
    filename: .int 0

    read_error_msg:
        .ascii "Errore nell'apertura del file\nVerifica che esista e che si abbiano i permessi adeguati alla lettura\n\0"
    

.section .bss
    products_pointer: .int 0
    num_products: .int 0


.section .text

.global EDF_file            # rende visibile il simbolo edf al linker

.type EDF_file, @function   # dichiarazione della funzione edf
                                # la funzione scambia due prodotti nell'array

EDF_file:
    pusha
    mov %ecx, filename
    call open_file

    mov %eax, products_pointer  # Salva nella variabile il puntatore al primo elemento dell'array
    mov %ebx, num_products      # Salva nella variabile il numero dei prodotti nel file

    dec %ebx                    # num_products - 1
    xor %edi, %edi              # reset EDI che usero come i
    
external_loop:
    cmp %ebx, %edi              # compara i con numproducts - 1
    jge print_results           # Se i > num_products - 1 stampa i risultati
    xor %esi, %esi              # reset ESI che usero come j
    push %ebx

    sub %edi, %ebx              # num_products - i - 1
    push %eax                   # Salvo nella pila il puntatore al primo indirizzo dell'array
    
internal_loop:
    cmp %ebx, %esi              # compara j con num_products - i -1
    jge end_internal_loop       # se j > num_products - i - 1 salta alla fine del ciclo for

if1:
    xor %ecx, %ecx              # reset ECX che usero come registro temporaneo per i confronti
    mov 6(%eax), %cl            # copia in CL la scadenza dell'elemento j+1
    cmp %cl, 2(%eax)            # compara scadenza elemento j con scadenza elemento j+1
    jle if2                     # se è maggiore o uguale passa alla seconda condizione

    call swapProducts           # altrimenti chiama la funzione che scambia i due prodotti nell'array
    jmp back_internal_loop      # torna al ciclo for interno

if2:
    cmp %cl, 2(%eax)            # compara scadenza elemento j con scadenza elemento j+1
    jne back_internal_loop      # se non sono uguali, torna al ciclo for interno

    mov 7(%eax), %cl            # copia in CL la scadenza dell'elemento j+1
    cmp %cl, 3(%eax)            # compara scadenza elemento j con scadenza elemento j+1
    jge back_internal_loop      # se scadenza j <= scadenza j+1 torna al ciclo for interno

    call swapProducts           # altrimenti chiama la funzione che scambia i due prodotti nell'array

back_internal_loop:
    inc %esi                    # incrementa j
    add $4, %eax              # scorri a elemento j
    
    jmp internal_loop
end_internal_loop:
    pop %eax
    pop %ebx
    inc %edi
    jmp external_loop

print_results:
    xor %ecx, %ecx              # uso ECX come i
    xor %edi, %edi              # uso EDI per salvare time
    xor %esi, %esi              # uso ESI per salvare la penalità totale
    xor %edx, %edx              # uso EDX per scorrere l'array

print_products:
    mov %eax, %edx              # copio il puntatore al primo prodotto nell'array in EDX
    mov num_products, %ebx

    leal edf_title_str, %eax    # carico la stringa da stampare
    call printf                 # stampa
    call printfile

keep_print:
    cmp $0, %ebx                # verifica se num_products == 0
    je print_stats              # se è vero salta a print_stats, altimenti continua

    movzx (%edx), %eax             # copia l'ID del prodotto da stampare in AL
    call itoa                   # converte il valore in ASCII
    call printf                 # stampa il valore
    call printfile

    mov $due_punti, %eax              # carico il codice ASCII di ':'
    call printf                 # stampa ':'
    call printfile

    mov %edi, %eax
    call itoa                   # converte il valore in ASCII
    call printf                 # stampa il valore
    call printfile

    leal LF, %eax               # carico il codice ASCII di '\n'
    call printf                 # stampa '\n'
    call printfile
    
    xor %eax, %eax
    movzx 1(%edx), %eax
    add %eax, %edi              # somma la durata del prodotto
    movzx 2(%edx), %eax
    cmp %eax, %edi              # compara il tempo accumulato con la scadenza del prodotto corrente
    jg update_penalty           # se è maggiore aggiorna la penalita accumulata

    add $4, %edx                # scorre al prossimo prodotto

    dec %ebx                    # decrementa il numero di prodotti
    jmp keep_print          

print_stats:
    leal conclusione_str, %eax  # carica in EAX l'indirizzo della stringa da stampare
    call printf                 # stampa la stringa
    call printfile

    mov %edi, %eax              # carica il tempo totale in EAX
    call itoa                   # lo converte in ASCII
    call printf                 # stampa il tempo totale
    call printfile

    leal LF, %eax               # carico il codice ASCII di '\n'
    call printf                 # stampa '\n'
    call printfile

    leal penalty_str, %eax      # carica in EAX l'indirizzo della stringa da stampare
    call printf                 # stampa la stringa 
    call printfile

    mov %esi, %eax              # carica la penalita totale in EAX
    call itoa                   # la converte in ASCII
    call printf                 # stampa la penalita totale
    call printfile

    leal LF, %eax               # carico il codice ASCII di '\n'
    call printf                 # stampa '\n'
    call printfile

    # Dealloca la memoria dell'array
    mov products_pointer, %ebx
    mov $45, %eax               # syscall brk
    int $0x80                   # Chiamata al kernel

    call close_file

    popa

    ret

update_penalty:
    call calcola_penalty        # chiama la funzione che calcola la penalita
    add $4, %edx                # scorre al prossimo prodotto

    dec %ebx                    # decrementa il numero di prodotti
    jmp keep_print
    
calcola_penalty:
    push %edi                   # salva nella pila TIME
    push %eax
    xor %eax, %eax
    movzx 2(%edx), %eax
    sub %eax, %edi              # sottrae a TIME la scadenza del prodotto corrente
    movzx 3(%edx), %eax
    imul %eax, %edi             # al risultato, moltiplica la priorita del prodotto corrente
    add %edi, %esi              # somma alla penalita il risultato
    pop %eax
    pop %edi                    # recupera TIME dalla pila

    ret

read_error:
    leal read_error_msg, %eax
    call printerror

_exit:
    mov $1, %eax        # syscall exit
    xor %ebx, %ebx      # Codice di uscita 0
    int $0x80           # Interruzione del kernel

open_file:
    push %eax
    push %ebx
    push %ecx
    push %edx

    # Apertura del file
    mov $5, %eax         # syscall: open
    mov filename, %ebx  # nome del file
    mov $0101, %ecx      # flag: O_WRONLY | O_CREAT (crea il file se non esiste)
    mov $0644, %edx      # permessi: rw-r--r--
    int $0x80            # chiamata al kernel

    # Controllo se l'apertura del file è avvenuta con successo
    cmp $0, %eax
    js read_error        # se %eax < 0, c'è stato un errore
    mov %eax, fd       # salviamo il file descriptor in %edi

    pop %edx
    pop %ecx
    pop %ebx
    pop %eax

    ret

close_file:
    push %eax
    push %ebx

    mov $6, %eax         # syscall: close
    mov fd, %ebx         # file descriptor
    int $0x80            # chiamata al kernel

    pop %ebx
    pop %eax

    ret

find_string_len:
    cmpb $0, (%eax)
    je _ret

    inc %edx             # Incrementa il contatore
    inc %eax             # Passa al carattere successivo
    jmp find_string_len       # Ripete il ciclo

printfile:
    push %eax
    push %ebx
    push %ecx
    push %edx

    xor %edx, %edx
    mov %eax, %ecx # Buffer di output
    call find_string_len

print:
    # Stampa il contenuto della riga
    mov $4, %eax        # syscall write
    mov fd, %ebx        # File descriptor standard output (stdout) 
    int $0x80           # Interruzione del kernel

    pop %edx
    pop %ecx
    pop %ebx
    pop %eax

_ret:
    ret # fine della funzione printfile
        # l'esecuzione riprende dall'istruzione sucessiva
        # alla call che ha invocato printfile
