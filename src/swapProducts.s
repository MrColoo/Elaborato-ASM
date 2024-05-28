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

    # Salva il primo prodotto nei registri
    movb (%eax), %cl
    movb 1(%eax), %ch
    movb 2(%eax), %dl
    movb 3(%eax), %dh

    # Sposta il secondo prodotto al posto del primo
    mov 4(%eax), %bl
    movb %bl, (%eax)

    mov 5(%eax), %bl
    movb %bl, 1(%eax)

    mov 6(%eax), %bl
    movb %bl, 2(%eax)

    mov 7(%eax), %bl
    movb %bl, 3(%eax)

    #Sposta il primo prodotto al posto del secondo
    movb %cl, 4(%eax)
    movb %ch, 5(%eax) 
    movb %dl, 6(%eax)
    movb %dh, 7(%eax)

    pop %edx
    pop %ecx
    pop %ebx
    pop %eax
  