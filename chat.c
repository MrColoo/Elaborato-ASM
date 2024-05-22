#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_PRODUCTS 10
#define MAX_TIME_SLOTS 100

typedef struct {
    int id;
    int duration;
    int deadline;
    int priority;
} Product;

void swap(Product *xp, Product *yp) {
    Product temp = *xp;
    *xp = *yp;
    *yp = temp;
}

void bubbleSort(Product arr[], int n) {
    for (int i = 0; i < n-1; i++) {
        for (int j = 0; j < n-i-1; j++) {
            if (arr[j].deadline > arr[j+1].deadline || 
                (arr[j].deadline == arr[j+1].deadline && arr[j].priority < arr[j+1].priority)) {
                swap(&arr[j], &arr[j+1]);
            }
        }
    }
}

void edf_schedule(Product products[], int n) {
    bubbleSort(products, n);

    int time = 0;
    int total_penalty = 0;

    printf("Pianificazione EDF:\n");
    for (int i = 0; i < n; i++) {
        printf("%d:%d\n", products[i].id, time);
        time += products[i].duration;
        if (time > products[i].deadline) {
            total_penalty += (time - products[i].deadline) * products[i].priority;
        }
    }

    printf("Conclusione: %d\n", time);
    printf("Penalty: %d\n", total_penalty);
}

void hpf_schedule(Product products[], int n) {
    bubbleSort(products, n);

    int time = 0;
    int total_penalty = 0;

    printf("Pianificazione HPF:\n");
    for (int i = 0; i < n; i++) {
        printf("%d:%d\n", products[i].id, time);
        time += products[i].duration;
        if (time > products[i].deadline) {
            total_penalty += (time - products[i].deadline) * products[i].priority;
        }
    }

    printf("Conclusione: %d\n", time);
    printf("Penalty: %d\n", total_penalty);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Utilizzo: %s <percorso del file degli ordini>\n", argv[0]);
        return 1;
    }

    FILE *file = fopen(argv[1], "r");
    if (file == NULL) {
        printf("Impossibile aprire il file %s\n", argv[1]);
        return 1;
    }

    Product products[MAX_PRODUCTS];
    int num_products = 0;

    char line[100];
    while (fgets(line, sizeof(line), file) != NULL) {
        char *token = strtok(line, ",");
        products[num_products].id = atoi(token);

        token = strtok(NULL, ",");
        products[num_products].duration = atoi(token);

        token = strtok(NULL, ",");
        products[num_products].deadline = atoi(token);

        token = strtok(NULL, ",");
        products[num_products].priority = atoi(token);

        num_products++;
    }

    fclose(file);

    int choice;
    do {
        printf("\nSeleziona l'algoritmo di pianificazione:\n");
        printf("1. Earliest Deadline First (EDF)\n");
        printf("2. Highest Priority First (HPF)\n");
        printf("0. Esci\n");
        printf("Scelta: ");
        scanf("%d", &choice);

        switch (choice) {
            case 1:
                edf_schedule(products, num_products);
                break;
            case 2:
                hpf_schedule(products, num_products);
                break;
            case 0:
                printf("Uscita...\n");
                break;
            default:
                printf("Scelta non valida. Riprova.\n");
        }
    } while (choice != 0);

    return 0;
}
