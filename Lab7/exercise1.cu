#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>

__global__ void addMatA(int* A, int* B, int *C, int n) {
	int i = threadIdx.x, ind;
	for(int j=0; j<n; j++) {
		ind = i * n + j;
		C[ind] = A[ind] + B[ind];
	}
}

__global__ void addMatB(int* A, int* B, int* C, int m) {
	int j = threadIdx.x, n = blockDim.x, ind;
	for(int i=0; i<m; i++) {
		ind = i * n + j;
		C[ind] = A[ind] + B[ind];
	}
}

__global__ void addMatC(int* A, int* B, int* C) {
	int ind = threadIdx.x;
	C[ind] = A[ind] + B[ind];
}	

int main(void) {
	int *A, *B, *C, m, n;
	int *d_A, *d_B, *d_C;
	
	printf("Enter the value of m: ");
	scanf("%d", &m);
	
	printf("Enter the value of n: "); 
	scanf("%d", &n);
	
	int size = sizeof(int) * m * n;
	A = (int*) malloc(size);
	B = (int*) malloc(size);
	C = (int*) malloc(size);
	
	printf("Enter input matrix A: \n");
	for(int i=0; i<m*n; i++) 
		scanf("%d", A+i);
		
	printf("Enter input matrix B: \n");
	for(int i=0; i<m*n; i++) 
		scanf("%d", B+i);
	
	cudaMalloc((void**) &d_A, size);
	cudaMalloc((void**) &d_B, size);
	cudaMalloc((void**) &d_C, size);
	
	cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, B, size, cudaMemcpyHostToDevice);
	
	addMatA<<<1, m>>>(d_A, d_B, d_C, n);
	
	cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost);
	
	printf("Resultant matrix is (Each Row by one Thread): \n");
	for(int i=0; i<m; i++) {
		for(int j=0; j<n; j++) 
			printf("\t%d", C[i*n+j]);
		printf("\n");
	}
	
	addMatB<<<1, n>>>(d_A, d_B, d_C, m);
	
	cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost);
	
	printf("Resultant matrix is (Each Column by one Thread): \n");
	for(int i=0; i<m; i++) {
		for(int j=0; j<n; j++) 
			printf("\t%d", C[i*n+j]);
		printf("\n");
	}
	
	addMatC<<<1, m*n>>>(d_A, d_B, d_C);
	
	cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost);
	
	printf("Resultant matrix is (Each Element by one Thread): \n");
	for(int i=0; i<m; i++) {
		for(int j=0; j<n; j++) 
			printf("\t%d", C[i*n+j]);
		printf("\n");
	}
	
	getchar();
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);
	
	free(A);
	free(B);
	free(C);
	
	return 0;
}
