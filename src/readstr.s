# filename: readstr.s
#
# Read a string from keyboard and outputs the same string to video

.section .data

.section .bss
	str: .string ""

.section .text
.global readstr # rende visibile il simbolo readstr al linker

.type readstr, @function   # dichiarazione della funzione readstr
                        # la funzione legge da tastiera una stringa
                        # e salva il suo indirizzo in eax
readstr:
	movl $3, %eax         # Set system call READ
	movl $0, %ebx         # | <- keyboard
	leal str, %ecx        # | <- destination
	movl $1, %edx        # | <- string length
	int $0x80             # Execute syscall

	leal str, %eax
	ret
