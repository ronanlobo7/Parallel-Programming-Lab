#include <stdio.h>
#include <stdlib.h>

#include <cuda.h>


__device__ int factorial(int n) {
    int fact = 1;

    for(int i=1; i<n+1; i++) 
        fact *= i;

    return fact;
}

__device__ int sumOfDigits(int n) {
    int sum = 0;

    while(n > 0) {
        sum += n % 10;
        n /= 10;
    }

    return sum;
}


__global__ void replace(int* matrix) {
    int n=blockDim.x;
    int row=blockIdx.x, col=threadIdx.x;
    int out;

    if(row == col) 
        out = 0;
    else if(col > row) 
        out = factorial(matrix[row*n+col]);
    else 
        out = sumOfDigits(matrix[row*n+col]);

    matrix[row*n+col] = out;
}


int main(void) {
	int *h_matrix;
    int n, size;

	int *d_matrix;
	
	printf("Enter the value of N for the NxN matrix: ");
    scanf("%d", &n);

    size = sizeof(int) * n * n;
    h_matrix = (int*) malloc(size);
	
	printf("Enter the input matrix: \n");
	for(int i=0; i<n*n; i++) 
		scanf("%d", h_matrix+i);
		
	cudaMalloc((void**) &d_matrix, size);
	
	cudaMemcpy(d_matrix, h_matrix, size, cudaMemcpyHostToDevice);
	
	replace<<<n, n>>>(d_matrix);
	
	cudaMemcpy(h_matrix, d_matrix, size, cudaMemcpyDeviceToHost);
	
	printf("Resultant matrix after replacing values: \n");
	for(int i=0; i<n; i++) {
		for(int j=0; j<n; j++) 
			printf("\t%d", h_matrix[i*n+j]);
		printf("\n");
	}
	
	cudaFree(d_matrix);
	
	free(h_matrix);
	
	return 0;
}