#include<stdio.h>
#include<stdlib.h>
#define D 10

typedef struct processo
{
    int identificativo;
    int durata;
    int scadenza;
    int priorita;
} processo;

int readFile(processo *, FILE *);
void writeFile();
void printResults(int, processo *, int);
void edfAlgorithm(processo *, int);    // si pianificano per primi i prodotti la cui scadenza è più vicina, in
                        // caso di parità nella scadenza, si pianifica il prodotto con la priorità più alta.
void hpfAlgorithm(processo *, int);    // si pianificano per primi i prodotti con priorità più alta, in caso di
                        // parità di priorità, si pianifica il prodotto con la scadenza più vicina

void scambia(processo *, processo *);

int main(){

    int penale = 0, car, num;

    FILE * ordiniF;
    processo processi[D];
    

    ordiniF = fopen("Ordini.txt", "r");
    num = readFile(processi, ordiniF);

    do
    {
        printf("Quale algoritmo di pianificazione si desidera utilizzare?\n[1] EDF - Earliest scadenza First\n[2] HPF - Highest priorita First\n");
        scanf("%d", &car);
        
        printResults(car, processi, num);
    } while (car != 0);
    

    return 0;
}



int readFile(processo p[], FILE *f){
    int i;
    if(f != NULL){
        for (i = 0; !feof(f); i++){
            fscanf(f, "%d,%d,%d,%d", &p[i].identificativo, &p[i].durata, &p[i].scadenza, &p[i].priorita);
        }
        fclose(f);
    }else
        printf("Errore in apertura");
    return i;
}

void writeFile(processo p[], FILE *f){

}

void printResults(int car, processo p[], int num){
    if(car == 1){
        printf("Pianificazione EDF:\n");
        edfAlgorithm(p, num);
    }
    else if(car == 2){
        printf("Pianificazione HPF:\n");
        hpfAlgorithm(p, num);
    }

}

void edfAlgorithm(processo processi[], int num){
    for (int i = 0; i < num-1; i++) {
        for (int j = 0; j < num-i-1; j++) {
            if (processi[j].scadenza > processi[j+1].scadenza || (processi[j].scadenza == processi[j+1].scadenza && processi[j].priorita < processi[j+1].priorita)) {
                scambia(&processi[j], &processi[j+1]);
            }
        }
    }

    int time = 0, totalPenalty = 0;
    for (int i = 0; i < num; i++)
    {
        printf("%d:%d\n", processi[i].identificativo, time);
        time += processi[i].durata;
        if (time > processi[i].scadenza) {
            totalPenalty += (time - processi[i].scadenza) * processi[i].priorita;
        }
    }

    printf("Conclusione: %d\n", time);
    printf("Penalty: %d\n", totalPenalty);
}

void hpfAlgorithm(processo processi[], int num){
    for (int i = 0; i < num-1; i++) {
        for (int j = 0; j < num-i-1; j++) {
            if (processi[j].priorita < processi[j+1].priorita || (processi[j].priorita == processi[j+1].priorita && processi[j].scadenza > processi[j+1].scadenza)) {
                scambia(&processi[j], &processi[j+1]);
            }
        }
    }

    int time = 0, totalPenalty = 0;
    for (int i = 0; i < num; i++)
    {
        printf("%d:%d\n", processi[i].identificativo, time);
        time += processi[i].durata;
        if (time > processi[i].scadenza) {
            totalPenalty += (time - processi[i].scadenza) * processi[i].priorita;
        }
    }

    printf("Conclusione: %d\n", time);
    printf("Penalty: %d\n", totalPenalty);

}

void scambia(processo *xp, processo *yp) {
    processo temp = *xp;
    *xp = *yp;
    *yp = temp;
}