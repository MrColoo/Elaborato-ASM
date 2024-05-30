# ###################
# filename: swapProducts.s
# ###################

.section .text

.global swapProducts # rende visibile il simbolo swapProducts al linker

.type swapProducts, @function   # dichiarazione della funzione swapProducts
                        # la funzione scambia due prodotti nell'array

swapProducts:
    push %eax
    push %ebx
    push %ecx
    push %edx
    push %esi

    mov %eax, %esi

    xor %eax, %eax
    xor %ebx, %ebx
    xor %ecx, %ecx
    xor %edx, %edx

    # Salva il primo prodotto nei registri temporanei
    movb (%esi), %al
    movb 1(%esi), %bl
    movb 2(%esi), %cl
    movb 3(%esi), %dl

    push %eax
    # Sposta il secondo prodotto al posto del primo
    mov 4(%esi), %al
    movb %al, (%esi)

    mov 5(%esi), %al
    movb %al, 1(%esi)

    mov 6(%esi), %al
    movb %al, 2(%esi)

    mov 7(%esi), %al
    movb %al, 3(%esi)

    pop %eax

    #Sposta il primo prodotto al posto del secondo
    movb %al, 4(%esi)
    movb %bl, 5(%esi) 
    movb %cl, 6(%esi)
    movb %dl, 7(%esi)

    pop %esi
    pop %edx
    pop %ecx
    pop %ebx
    pop %eax
  