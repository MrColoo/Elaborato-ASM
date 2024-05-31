# filename: readstr.s
#
# Read a string from keyboard and outputs the same string to video

.section .bss
	buffer_read: 
		.string ""

.section .text
.global readstr # rende visibile il simbolo readstr al linker

.type readstr, @function   # dichiarazione della funzione readstr
                        # la funzione legge da tastiera una stringa
                        # e salva il suo indirizzo in eax
readstr:
	push %ebx
    push %ecx
    push %edx

	movl $3, %eax        	# Set system call READ
	xor %ebx, %ebx         	# | <- keyboard
	leal buffer_read, %ecx  # | <- destination
	movl $50, %edx        	# | <- string length
	int $0x80             	# Execute syscall

	leal buffer_read, %eax 		# Restituisce l'indirizzo del buffer in eax
	
	pop %edx
    pop %ecx
    pop %ebx

	ret
