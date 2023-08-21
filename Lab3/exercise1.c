#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>

int factorial(int n) {
	return n == 0 ? 1 : n * factorial(n-1);
}

int main(int argc, char* argv[]) {
	int rank, size, c, N, sum, fact;
	int* arr;
	
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	
	if(rank == 0) {
		N = size;
		arr = (int*) calloc(sizeof(int), N);
		
		fprintf(stdout, "Enter %d values: ", N);
		fflush(stdout);
		
		for(int i=0; i<N; i++) {
			scanf("%d", arr+i);
		}
	}
	
	MPI_Scatter(arr, 1, MPI_INT, &c, 1, MPI_INT, 0, MPI_COMM_WORLD);
	
	fprintf(stdout, "Received %d in process %d\n", c, rank);
	fflush(stdout);
	
	fact = factorial(c);
	
	MPI_Gather(&fact, 1, MPI_INT, arr, 1, MPI_INT, 0, MPI_COMM_WORLD);
	
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
		
		fprintf(stdout, "Sum of values: %d\n", sum);
		fflush(stdout);
	}
	
	MPI_Finalize();
	return 0;
}	
