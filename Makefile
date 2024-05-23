EXE = bin/pianificatore
AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386
OBJ = obj/main.o obj/printf.o obj/itoa.o obj/findNumProducts.o

all: $(EXE)

$(EXE): $(OBJ)
	$(LD) $(LD_FLAGS) -o $(EXE) $(OBJ) 

obj/main.o: src/main.s
	as $(AS_FLAGS) $(DEBUG) src/main.s -o obj/main.o

obj/printf.o: src/printf.s
	as $(AS_FLAGS) $(DEBUG) src/printf.s -o obj/printf.o

obj/itoa.o: src/itoa.s
	as $(AS_FLAGS) $(DEBUG) src/itoa.s -o obj/itoa.o

obj/findNumProducts.o: src/findNumProducts.s
	as $(AS_FLAGS) $(DEBUG) src/findNumProducts.s -o obj/findNumProducts.o


clean:
	rm -f obj/*.o $(EXE)
