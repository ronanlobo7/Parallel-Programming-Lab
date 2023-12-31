#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>

__global__ void transpose(int* a, int* t) {
	int n = threadIdx.x, m = blockIdx.x, size = blockDim.x, size1 = gridDim.x;
	t[n*size1+m] = a[m*size+n];
}

int main(void) {
	int *a, *t, m, n, i, j;
	int *d_a, *d_t;
	
	printf("Enter the value of m: ");
	scanf("%d", &m);
	
	printf("Enter the value of n: "); 
	scanf("%d", &n);
	
	int size = sizeof(int) * m * n;
	a = (int*) malloc(size);
	t = (int*) malloc(size);
	
	printf("Enter input matrix: \n");
	for(i=0; i<m*n; i++) 
		scanf("%d", a+i);
	
	cudaMalloc((void**) &d_a, size);
	cudaMalloc((void**) &d_t, size);
	
	cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
	
	transpose<<<m, n>>>(d_a, d_t);
	
	cudaMemcpy(t, d_t, size, cudaMemcpyDeviceToHost);
	
	printf("Resultant matrix is: \n");
	for(i=0; i<m; i++) {
		for(j=0; j<n; j++) 
			printf("\t%d", t[i*n+j]);
		printf("\n");
	}
	
	getchar();
	cudaFree(d_a);
	cudaFree(d_t);
	
	free(a);
	free(t);
	
	return 0;
}
