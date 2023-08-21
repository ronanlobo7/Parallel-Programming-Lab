#include "mpi.h"
#include <stdio.h>
#include <string.h>

int main(int argc, char* argv[]) {
	int rank, size, len;
	char str[100];
	MPI_Status status;
	
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	
	if(rank == 0) {
		printf("Enter a word: ");
		scanf("%s", str);
		len = strlen(str);
		MPI_Ssend(&len, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
		MPI_Ssend(str, len, MPI_CHAR, 1, 1, MPI_COMM_WORLD);
		fprintf(stdout, "Sent \"%s\" to process 1. (Rank=0)\n", str);
		MPI_Recv(str, len, MPI_CHAR, 1, 2, MPI_COMM_WORLD, &status);
		fprintf(stdout, "Received \"%s\" from process 1. (Rank=0)\n", str);
	}
	else {
		MPI_Recv(&len, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, &status);
		MPI_Recv(str, len, MPI_CHAR, 0, 1, MPI_COMM_WORLD, &status);
		fprintf(stdout, "Received \"%s\" from process 0. (Rank=1)\n", str);
		for(int i=0; i<len; i++) {
			if(str[i] >= 'A' && str[i] <= 'Z') {
				str[i] += 32;
			}
			else if(str[i] >= 'a' && str[i] <= 'z') {
				str[i] -= 32;
			}
		}
		MPI_Ssend(str, len, MPI_CHAR, 0, 2, MPI_COMM_WORLD);
		fprintf(stdout, "Sent \"%s\" to process 0. (Rank=1)\n", str);
	}
	fflush(stdout);
	
	MPI_Finalize();
	return 0;
}
			
