#include "mpi.h"
#include <stdio.h>

int fact(int x) {
	return x == 0 ? 1 : x * fact(x-1);
}

int fib(int x) {
	return x <= 2 ? x-1 : fib(x-1) + fib(x-2);
}

int main(int argc, char *argv[]) {
	int rank;

	MPI_Init(&argc, &argv);	
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	
	if(rank%2 == 0) {
		printf("Factorial %d! = %d (Rank=%d)\n", rank, fact(rank), rank);
	}
	else {
		printf("Fib %d = %d (Rank=%d)\n", rank, fib(rank), rank);
	}

	MPI_Finalize();
	return 0;
}
