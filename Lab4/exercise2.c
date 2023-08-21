#include <stdio.h>
#include "mpi.h"

int main(int argc, char* argv[]) {
	int rank, size, n;
	long double h, f, x, pi, val = 0.0;
	
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	
	if(rank == 0) {
		printf("Enter the number of intervals, n: ");
		scanf("%d", &n);
	}
	
	MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);
	
	h = 1.0 / n; 
	
	for(int i=rank; i<n; i+=size) {
		x = (i + 0.5) * h;
		f = 4.0 / (1 + x * x);
		val += f * h;
	}
	
	MPI_Reduce(&val, &pi, 1, MPI_LONG_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);
	
	if(rank == 0) 
		printf("Value of pi approximated with %d intervals = %Lf\n", n, pi);
	
	MPI_Finalize();
	return 0;
}
