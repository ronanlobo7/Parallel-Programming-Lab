#include "mpi.h"
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
	int rank, len;
	char str[] = "HELLO";
	len = strlen(str);

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	
	if(rank >= len) {
		printf("Process rank is greater than the length of the string (Rank=%d)\n", rank);
	}
	else {	
		str[rank] += 32;
		printf("String in process with rank %d is %s\n", rank, str);
	}	

	MPI_Finalize();
	return 0;
}
