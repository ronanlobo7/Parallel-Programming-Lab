#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define N 1024

__global__ void CUDACount(char* A, char* W, unsigned int l_W, unsigned int* d_count) {
	int tid = threadIdx.x;
	for(int i=0; i<l_W; i++) 
		if(A[tid+i] != W[i]) 
			return;
	atomicAdd(d_count, 1);
}

int main() {
	char A[N], W[N];
	char* d_A, *d_W;
	unsigned int count=0, *d_count, result;
	
	printf("Enter a string: ");
	scanf(" %[^\n]s", A);
	
	printf("Enter the word to be searched: ");
	scanf(" %[^\n]s", W);
	
	cudaMalloc((void**) &d_A, strlen(A) * sizeof(char));
	cudaMalloc((void**) &d_W, strlen(W) * sizeof(char));
	cudaMalloc((void**) &d_count, sizeof(unsigned int));
	cudaMemcpy(d_A, A, strlen(A) * sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(d_W, W, strlen(W) * sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(d_count, &count, sizeof(unsigned int), cudaMemcpyHostToDevice);
	
	CUDACount<<<1, strlen(A)-strlen(W)+1>>>(d_A, d_W, strlen(W), d_count);

	cudaMemcpy(&result, d_count, sizeof(unsigned int), cudaMemcpyDeviceToHost);
	
	printf("Total occurrences of %s: %u\n", W, result);
	
	cudaFree(d_A); cudaFree(d_W); cudaFree(d_count);

	return 0;
}
