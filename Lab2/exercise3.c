#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[]) {
	int rank, size, x;
	MPI_Status status;
	
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	
	if(rank == 0) {
		int* arr = (int*) calloc(size-1, sizeof(int));
		printf("Enter %d integers: ", size-1);
		for(int i=0; i<size-1; i++) {
			scanf("%d", arr+i);
		}
		
		int buffer_size = (MPI_BSEND_OVERHEAD + sizeof(int)) * (size-1);
		char* buffer = (char*) malloc(buffer_size);
		MPI_Buffer_attach(buffer, buffer_size);
		
		for(int i=0; i<size-1; i++) {
			MPI_Bsend(arr+i, 1, MPI_INT, i+1, 0, MPI_COMM_WORLD);
			fprintf(stdout, "Sent %d to Process %d.\n", arr[i], i+1);
		}
		
		MPI_Buffer_detach(&buffer, &buffer_size);
		free(buffer);
		
		free(arr);
	}
	else {
		MPI_Recv(&x, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, &status);
		if(rank % 2 == 0) {
			fprintf(stdout, "Process %d: Square of %d is %d.\n", rank, x, x*x);
		}
		else {
			fprintf(stdout, "Process %d: Cube of %d is %d.\n", rank, x, x*x*x);
		}
	}
	fflush(stdout);
	
	MPI_Finalize();
	return 0;
}
