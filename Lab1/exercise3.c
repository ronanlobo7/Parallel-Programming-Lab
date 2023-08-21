#include "mpi.h"
#include <stdio.h>
#include <math.h>

int main(int argc, char *argv[]) {
	int rank, a=20, b=4;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	
	switch(rank) {
		case 0:
			printf("Value of %d+%d = %d (Rank=%d)\n", a, b, a+b, rank);
			break; 
		case 1:
			printf("Value of %d-%d = %d (Rank=%d)\n", a, b, a-b, rank);
			break;
		case 2:
			printf("Value of %d*%d = %d (Rank=%d)\n", a, b, a*b, rank);
			break;
		case 3:
			printf("Value of %d/%d = %.2lf (Rank=%d)\n", a, b, (double) a/b, rank);
			break;
		case 4:
			printf("Value of %d^%d = %.2lf (Rank=%d)\n", a, b, pow(a, b), rank);
			break;
		default:
			printf("Calculator can perform upto 5 functions only (Rank=%d)\n", rank);
	}

	MPI_Finalize();
	return 0;
}
