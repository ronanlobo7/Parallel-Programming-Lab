#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[]) {
	int rank, size, M, N, len;
	double avg, totavg;
	
	int *A, *B;
	double *C;
	
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	
	if(rank == 0) {
		N = size;
		
		fprintf(stdout, "Enter the value for M: ");
		fflush(stdout);
		scanf("%d", &M);
		
		len = M * N;
		
		A = (int*) calloc(sizeof(int), len);
		
		fprintf(stdout, "Enter %d values: ", len);
		fflush(stdout);
		
		for(int i=0; i<len; i++) {
			scanf("%d", A+i);
		}
		
		C = (double*) calloc(sizeof(double), N);
	}
	
	MPI_Bcast(&M, 1, MPI_INT, 0, MPI_COMM_WORLD);
	
	B = (int*) calloc(sizeof(int), M);
	
	MPI_Scatter(A, M, MPI_INT, B, M, MPI_INT, 0, MPI_COMM_WORLD);
	
	avg = 0;
	for(int i=0; i<M; i++) {
		avg += B[i];
	}
	avg /= M;
	
	fprintf(stdout, "Average in process %d is %lf\n", rank, avg);
	fflush(stdout);
	
	MPI_Gather(&avg, 1, MPI_DOUBLE, C, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	
	if(rank == 0) {
		totavg = 0;
		for(int i=0; i<N; i++) {
			totavg += C[i];
		}
		totavg /= N;
		
		fprintf(stdout, "Total Average: %lf\n", totavg);
		fflush(stdout);
	}
	
	MPI_Finalize();
	return 0;
}	
