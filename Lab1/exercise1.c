#include "mpi.h"
#include <stdio.h>
#include <math.h>

int main(int argc, char *argv[]) {
	int rank, x=5;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	printf("Value of pow(5, %d): %.0lf (Rank=%d)\n", rank, pow(x, rank), rank);

	MPI_Finalize();
	return 0;
}
	
