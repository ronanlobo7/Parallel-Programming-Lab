#include <stdio.h>
#include <stdlib.h>
#include "mpi.h"

void handle_error(int errorcode) {
	char string[100];
	int errorclass, resultlen;
	
	if(errorcode != MPI_SUCCESS) {
		MPI_Error_class(errorcode, &errorclass);
		MPI_Error_string(errorcode, string, &resultlen); 
		fprintf(stderr, "Error description: %s\n", string);
		fflush(stderr);
		MPI_Abort(MPI_COMM_WORLD, 1);
	}
}

int main(int argc, char* argv[]) {
	int rank, size, fact=1, factsum, val, error;
	MPI_Comm dup;
	
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	
	MPI_Errhandler_set(MPI_COMM_WORLD, MPI_ERRORS_RETURN);
	
	val = rank + 1;
	
	error = MPI_Scan(&val, &fact, 1, MPI_INT, MPI_PROD, dup);
	handle_error(error);
	
	fprintf(stdout, "%d! = %d (Rank = %d)\n", val, fact, rank);
	fflush(stdout);
		
	error = MPI_Reduce(&fact, &factsum, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);
	handle_error(error);
	
	if(rank == 0) { 
		fprintf(stdout, "Sum of all the factorial = %d\n", factsum);
		fflush(stdout);
	}
	
	MPI_Finalize();
	return 0;
}
