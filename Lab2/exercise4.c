#include "mpi.h"
#include <stdio.h>

int main(int argc, char* argv[]) {
	int rank, size, x;
	MPI_Status status;
	
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	
	if(rank == 0) {
		printf("Enter a number in Process 0: ");
		scanf("%d", &x);
		
		MPI_Send(&x, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
		fprintf(stdout, "Sent %d from Process 0.\n", x);
		
		MPI_Recv(&x, 1, MPI_INT, size-1, 0, MPI_COMM_WORLD, &status);
		fprintf(stdout, "Received %d in Process 0.\n", x);
	}
	else {
		MPI_Recv(&x, 1, MPI_INT, rank-1, 0, MPI_COMM_WORLD, &status);
		fprintf(stdout, "Received %d in Process %d.\n", x, rank);
		x++;
		
		if(rank == size-1) {
			MPI_Send(&x, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
		}
		else {
			MPI_Send(&x, 1, MPI_INT, rank+1, 0, MPI_COMM_WORLD);
		}

		fprintf(stdout, "Sent %d from Process %d.\n", x, rank);
	}
	fflush(stdout);
	
	MPI_Finalize();
	return 0;
}
