#include <stdio.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void calcSine(double* angles, double* sines, int N) {
	int tid = blockDim.x * blockIdx.x + threadIdx.x;
	if(tid < N)
		sines[tid] = sin(angles[tid]);
}

int main(void) {
	int N, size;
	double *h_angles, *h_sines;
	double *d_angles, *d_sines;
	
	printf("Enter the length of the array, N: ");
	scanf("%d", &N);
	
	size = sizeof(double) * N;
	
	h_angles = (double*) malloc(size);
	h_sines = (double*) malloc(size);
	
	printf("Enter the angles in the array: ");
	for(int i=0; i<N; i++) 
		scanf("%lf", h_angles+i);
	
	cudaMalloc((void**)&d_angles, size);
	cudaMalloc((void**)&d_sines, size);
	
	cudaMemcpy(d_angles, h_angles, size, cudaMemcpyHostToDevice);
	
	calcSine<<<ceil(N/256.0), 256>>>(d_angles, d_sines, N);
	
	cudaMemcpy(h_sines, d_sines, size, cudaMemcpyDeviceToHost);
	
	printf("Sine of elements in the input array: ");
	for(int i=0; i<N; i++) 
		printf("%lf ", h_sines[i]);
	printf("\n");
	
	cudaFree(d_angles);
	cudaFree(d_sines);
	
	free(h_angles);
	free(h_sines);
	
	return 0;
}	
