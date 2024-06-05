EXE = bin/pianificatore
AS_FLAGS = --32 
DEBUG =
LD_FLAGS = -m elf_i386
OBJ = obj/main.o obj/printf.o obj/printerror.o obj/itoa.o obj/atoi.o obj/findNumProducts.o obj/HPF_console.o obj/EDF_console.o obj/HPF_file.o obj/EDF_file.o obj/storeProducts.o obj/readstr.o obj/swapProducts.o

all: $(EXE)

$(EXE): $(OBJ)
	$(LD) $(LD_FLAGS) -o $(EXE) $(OBJ) 

obj/main.o: src/main.s
	as $(AS_FLAGS) $(DEBUG) src/main.s -o obj/main.o

obj/printf.o: src/printf.s
	as $(AS_FLAGS) $(DEBUG) src/printf.s -o obj/printf.o

obj/printerror.o: src/printerror.s
	as $(AS_FLAGS) $(DEBUG) src/printerror.s -o obj/printerror.o

obj/itoa.o: src/itoa.s
	as $(AS_FLAGS) $(DEBUG) src/itoa.s -o obj/itoa.o

obj/atoi.o: src/atoi.s
	as $(AS_FLAGS) $(DEBUG) src/atoi.s -o obj/atoi.o

obj/findNumProducts.o: src/findNumProducts.s
	as $(AS_FLAGS) $(DEBUG) src/findNumProducts.s -o obj/findNumProducts.o

obj/storeProducts.o: src/storeProducts.s
	as $(AS_FLAGS) $(DEBUG) src/storeProducts.s -o obj/storeProducts.o

obj/HPF_console.o: src/HPF_console.s
	as $(AS_FLAGS) $(DEBUG) src/HPF_console.s -o obj/HPF_console.o

obj/EDF_console.o: src/EDF_console.s
	as $(AS_FLAGS) $(DEBUG) src/EDF_console.s -o obj/EDF_console.o

obj/HPF_file.o: src/HPF_file.s
	as $(AS_FLAGS) $(DEBUG) src/HPF_file.s -o obj/HPF_file.o

obj/EDF_file.o: src/EDF_file.s
	as $(AS_FLAGS) $(DEBUG) src/EDF_file.s -o obj/EDF_file.o

obj/readstr.o: src/readstr.s
	as $(AS_FLAGS) $(DEBUG) src/readstr.s -o obj/readstr.o

obj/swapProducts.o: src/swapProducts.s
	as $(AS_FLAGS) $(DEBUG) src/swapProducts.s -o obj/swapProducts.o


clean:
	rm -f obj/*.o $(EXE)
