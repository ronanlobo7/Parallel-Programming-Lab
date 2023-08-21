#include "mpi.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int isVowel(char c) {
	if(c >= 'A' && c <= 'Z') {
		c += 32;
	}
	return c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u';
}

int main(int argc, char* argv[]) {
	int rank, size, c, N, sum, len, notvowel;
	int* arr;
	char str[100], split[100];
	
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	
	if(rank == 0) {
		N = size;
		
		fprintf(stdout, "Enter a string(length divisible by %d): ", N);
		fflush(stdout);
		
		scanf("%[^\n]s", str);
		len = strlen(str);
		
		c = len / N;	
		
		arr = (int*) calloc(sizeof(int), N);	
	}

	MPI_Bcast(&c, 1, MPI_INT, 0, MPI_COMM_WORLD); 
	
	MPI_Scatter(str, c, MPI_CHAR, split, c, MPI_CHAR, 0, MPI_COMM_WORLD);
	
	split[c] = '\0';
	
	fprintf(stdout, "Received %s in process %d\n", split, rank);
	fflush(stdout);
	
	notvowel = 0;
	for(int i=0; i<c; i++) {
		if(!isVowel(split[i])) {
			notvowel++;
		}
	}
	
	MPI_Gather(&notvowel, 1, MPI_INT, arr, 1, MPI_INT, 0, MPI_COMM_WORLD);
	
	if(rank == 0) {
		fprintf(stdout, "The results gathered in the root: ");
		fflush(stdout);
		
		sum = 0;
		for(int i=0; i<N; i++) {
			fprintf(stdout, "%d\t", arr[i]);
			sum += arr[i];
		}
		fprintf(stdout, "\n");
		fflush(stdout);
		
		fprintf(stdout, "Sum of non vowels: %d\n", sum);
		fflush(stdout);
	}
	
	MPI_Finalize();
	return 0;
}	
