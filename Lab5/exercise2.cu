#include <stdio.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void vectAdd(int* A, int* B, int* C, int N) {
	int tid = blockDim.x * blockIdx.x + threadIdx.x;
	if(tid < N)
		C[tid] = A[tid] + B[tid];
}

int main(void) {
	int *h_C, *h_B, *h_A, N, size;
	int *d_A, *d_B, *d_C;
	
	printf("Enter the length of the vectors, N: ");
	scanf("%d", &N);
	
	size = sizeof(int) * N;
	
	h_A = (int*) malloc(size);
	h_B = (int*) malloc(size);
	h_C = (int*) malloc(size);
	
	printf("Enter the vector A: ");
	for(int i=0; i<N; i++) 
		scanf("%d", h_A+i);
	
	printf("Enter the vector B: ");
	for(int i=0; i<N; i++) 
		scanf("%d", h_B+i);
	
	cudaMalloc((void**)&d_A, size);
	cudaMalloc((void**)&d_B, size);
	cudaMalloc((void**)&d_C, size);
	
	cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);
	
	vectAdd<<<ceil(N/256.0), 256>>>(d_A, d_B, d_C, N);
	
	cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);
	
	printf("Result of vector addition, A+B: ");
	for(int i=0; i<N; i++) 
		printf("%d ", h_C[i]);
	printf("\n");
	
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);
	
	free(h_A);
	free(h_B);
	free(h_C);
	
	return 0;
}	
