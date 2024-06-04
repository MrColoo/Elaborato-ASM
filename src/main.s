# ###################
# filename: main.s
# ###################

.section .data

    menu_prompt: 
        .ascii "Indicare l'algoritmo di pianificazione che si vuole utilizzare:\n[1]: Earliest Deadline First (EDF)\n[2]: Highest Priority First (HPF)\n[3]: Esci dal programma\n> \0"
    invalid_option: 
        .ascii "Il valore inserito non è valido, riprova \n\0"
    no_filename: 
        .ascii "Non hai inserito nessun file, inserisci almeno il nome del file con gli ordini per eseguire il programma\n\0"

    file_input:
        .int 0
    file_output:
        .int 0

    products_pointer: .int 0        # Puntatore all'array di prodotti
    num_products: .int 0            # contatore numero di prodotti presenti nel file

.section .text
    .global _start

_start:
    mov (%esp), %eax                # Carica il numero di argomenti in eax
    cmp $2, %eax                    # Controlla se il numero di argomenti è inferiore a 2
    jl error_no_filename            # Se sì, salta a error_no_filename
    jg read_output_filename         # Se sì, salta a read_output_filename

    # Se il numero di argomenti è esattamente 2, esegue solo read_input_filename
    mov 8(%esp), %eax               # Carica il nome del file di input in eax
    mov %eax, file_input            # Salva il nome del file di input in file_input
    jmp continue_execution          # Salta alla continuazione del programma

read_output_filename:
    # Se il numero di argomenti è maggiore di 3, esegue sia read_input_filename che read_output_filename
    mov 8(%esp), %eax               # Carica il nome del file di input in eax
    mov %eax, file_input            # Salva il nome del file di input in file_input
    mov 12(%esp), %eax              # Carica il nome del file di output in eax
    mov %eax, file_output           # Salva il nome del file di output in file_output

continue_execution:
    mov file_input, %ebx            # Copia il nome del file di input in EBX
    call findNumProducts            # Chiama la funzione per trovare il numero di prodotti nel file
    mov %eax, num_products          # Salva il numero di prodotti presenti nel file nella variabile    
    call storeProducts              # Chiama la funzione per salvare i prodotti nell'array
    mov %eax, products_pointer      # Salva il puntatore all'array di prodotti nella variabile
    
display_menu:
    leal menu_prompt, %eax          # carica l'indirizzo della stringa del menu in EAX
    call printf                     # stampa il menu
    call readstr                    # legge l'input da tastiera e carica in EAX l'indirizzo della stringa
    call atoi                       # converte in INT la stringa letta
    call verifica_menu              # chiama la funzione che verifica l'input dell'utente
    jmp display_menu

verifica_menu:
    cmp $1, %eax                    # verifica se l'utente ha selezionato l'opzione [1]
    je EDFconsole

    cmp $2, %eax                    # verifica se l'utente ha selezionato l'opzione [2]
    je HPFconsole

    cmp $3, %eax                    # verifica se l'utente ha selezionato l'opzione [3]
    je _exit

    leal invalid_option, %eax       # carica la stringa di errore in EAX
    call printerror                 # stampa la stringa nell'output di errore standard
    ret

# Fine programma
_exit:
    mov $1, %eax        # syscall exit
    xor %ebx, %ebx      # Codice di uscita 0
    int $0x80           # Interruzione del kernel

EDFconsole:
    cmp $0, file_output             # controlla se è stato passato come parametro il file di output
    jne EDFfile                     # in caso affermativo invoca la funzione che stampa i risultati anche su file
    mov products_pointer, %eax      # copia in EAX il puntatore al primo elemento dell'array di prodotti
    mov num_products, %ebx          # copia in EBX il numero di prodotti presenti nel file
    call EDF_console                # invoca la funzione che implementa l'algoritmo EDF
    jmp continue_execution

EDFfile:
    mov products_pointer, %eax      # copia in EAX il puntatore al primo elemento dell'array di prodotti
    mov num_products, %ebx          # copia in EBX il numero di prodotti presenti nel file
    mov file_output, %ecx 
    call EDF_file                   # invoca la funzione che implementa l'algoritmo EDF
    jmp continue_execution

HPFconsole:
    cmp $0, file_output             # controlla se è stato passato come parametro il file di output
    jne HPFfile                     # in caso affermativo invoca la funzione che stampa i risultati anche su file
    mov products_pointer, %eax      # copia in EAX il puntatore al primo elemento dell'array di prodotti
    mov num_products, %ebx          # copia in EBX il numero di prodotti presenti nel file
    call HPF_console                # invoca la funzione che implementa l'algoritmo HPF
    jmp continue_execution

HPFfile:
    mov products_pointer, %eax      # copia in EAX il puntatore al primo elemento dell'array di prodotti
    mov num_products, %ebx          # copia in EBX il numero di prodotti presenti nel file
    mov file_output, %ecx 
    call HPF_file                   # invoca la funzione che implementa l'algoritmo EDF
    jmp continue_execution

error_no_filename:
    leal no_filename, %eax          # copia indirizzo di memoria stringa errore in %eax
    call printerror                 # stampa l'errore nell'output error standard
    jmp _exit
