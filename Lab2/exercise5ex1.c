#include "mpi.h"
#include <stdio.h>

int main(int argc, char *argv[]) {
	int rank, size, val;
	MPI_Status status;
	
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	
	if(rank == 0) {
		MPI_Recv(&val, 1, MPI_INT, 1, 0, MPI_COMM_WORLD, &status);
	}
	else {
		MPI_Recv(&val,1, MPI_INT, 0, 0, MPI_COMM_WORLD, &status);
	}
	
	MPI_Finalize();
	return 0;
}
