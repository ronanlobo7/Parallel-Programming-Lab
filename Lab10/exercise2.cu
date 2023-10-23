#include <stdio.h>
#include <stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void convolve(float* N, float* M, float* P, int width, int mask_width) {
	int tid = threadIdx.x;
	__shared__ int value;
	int start = tid - mask_width / 2;
	P[tid] = 0.0;
	for(int i=0; i<mask_width; i++) {
		if(tid == 0) 
			value = M[i];

		__syncthreads();

		if(start + i >= 0 && start + i < width)
			P[tid] += N[start + i] * value;
		
		__syncthreads();
	}
}

int main(void) {
	int width, mask_width, size_N, size_M;
	float *h_N, *h_M, *h_P;
	float *d_N, *d_M, *d_P;
	
	printf("Enter the length of the input array N: ");
	scanf("%d", &width);
	
	size_N = sizeof(float) * width;
	h_N = (float*) malloc(size_N);
	
	printf("Enter the input array N: ");
	for(int i=0; i<width; i++) 
		scanf("%f", h_N+i);
	
	printf("Enter the length of the mask array M: ");
	scanf("%d", &mask_width);
	
	if(mask_width % 2 == 0) {
		printf("Mask length should be odd.\n");
		free(h_N);
		exit(1);
	}
	
	size_M = sizeof(float) * mask_width;
	h_M = (float*) malloc(size_M);
	
	printf("Enter the mask array M: ");
	for(int i=0; i<mask_width; i++) 
		scanf("%f", h_M+i);
		
	h_P = (float*) malloc(size_N);
	
	cudaMalloc((void**)&d_N, size_N);
	cudaMalloc((void**)&d_M, size_M);
	cudaMalloc((void**)&d_P, size_N);
	
	cudaMemcpy(d_N, h_N, size_N, cudaMemcpyHostToDevice);
	cudaMemcpy(d_M, h_M, size_M, cudaMemcpyHostToDevice);
	
	convolve<<<1, width>>>(d_N, d_M, d_P, width, mask_width);
	
	cudaMemcpy(h_P, d_P, size_N, cudaMemcpyDeviceToHost);
	
	printf("Result of convolution, output array P: ");
	for(int i=0; i<width; i++) 
		printf("%.2f ", h_P[i]);
	printf("\n");
	
	cudaFree(d_N);
	cudaFree(d_M);
	cudaFree(d_P);
	
	free(h_N);
	free(h_M);
	free(h_P);
	
	return 0;
}	