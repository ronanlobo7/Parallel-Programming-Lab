#include "mpi.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char* argv[]) {
	int rank, size, c, N, len;
	int* arr;
	char str1[100], str2[100], split1[100], split2[100], merged[200], final[200];
	
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	
	if(rank == 0) {
		N = size;
		
		fprintf(stdout, "Enter a string(length divisible by %d): ", N);
		fflush(stdout);
		scanf(" %[^\n]s", str1);
		
		len = strlen(str1);
		
		fprintf(stdout, "Enter another string(length as prev string, i.e. %d): ", len);
		fflush(stdout);
		scanf(" %[^\n]s", str2);
		
		c = len / N;	
	}

	MPI_Bcast(&c, 1, MPI_INT, 0, MPI_COMM_WORLD); 
	
	MPI_Scatter(str1, c, MPI_CHAR, split1, c, MPI_CHAR, 0, MPI_COMM_WORLD);
	
	MPI_Scatter(str2, c, MPI_CHAR, split2, c, MPI_CHAR, 0, MPI_COMM_WORLD);
	
	split1[c] = split2[c] = '\0';
	
	fprintf(stdout, "Received %s and %s in process %d\n", split1, split2, rank);
	fflush(stdout);
	
	for(int i=0; i<c; i++) {
		merged[2*i] = split1[i];
		merged[2*i + 1] = split2[i];
	}
	
	MPI_Gather(merged, 2*c, MPI_CHAR, final, 2*c, MPI_CHAR, 0, MPI_COMM_WORLD);
	
	if(rank == 0) {
		fprint                                                                                                                                                                                                                                                                                                                                                                         f(stdout, "The results gathered in the root: %s\n", final);
		fflush(stdout);
	}
	
	MPI_Finalize();
	return 0;
}	
