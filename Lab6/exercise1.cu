#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define N 1024
#define N_W 100

__global__ void CUDACount(char* A, char* W, int* start_ind, int* len_words, unsigned int l_W, unsigned int* d_count) {
	int tid = threadIdx.x;
	if(len_words[tid] != l_W)
		return;
		
	int start = start_ind[tid];
	for(int i=0; i<l_W; i++) 
		if(A[start+i] != W[i]) 
			return;
	atomicAdd(d_count, 1);
}

int main() {
	char A[N], W[N];
	char* d_A, *d_W;
	int start_ind[N_W], len_words[N_W];
	int *d_start_ind, *d_len_words;
	int len; 
	unsigned int count=0, *d_count, result;
	
	printf("Enter a string: ");
	scanf(" %[^\n]s", A);
	
	printf("Enter the word to be searched: ");
	scanf(" %[^\n]s", W);
	
	len = strlen(A);
	
	int i=0;
	int k=0;
	while(i < len) {
		while(i < len && A[i] == ' ')
			i++;
			
		start_ind[k] = i;
		while(i < len && A[i] != ' ') 
			i++;
		
		len_words[k] = i - start_ind[k];
		
		k++;
	}
	
	if(len_words[k-1] == 0) 
		k--;
	
	cudaMalloc((void**) &d_A, strlen(A) * sizeof(char));
	cudaMalloc((void**) &d_W, strlen(W) * sizeof(char));
	cudaMalloc((void**) &d_start_ind, k * sizeof(int));
	cudaMalloc((void**) &d_len_words, k * sizeof(int));
	cudaMalloc((void**) &d_count, sizeof(unsigned int));
	
	cudaMemcpy(d_A, A, strlen(A) * sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(d_W, W, strlen(W) * sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(d_start_ind, start_ind, k * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_len_words, len_words, k * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_count, &count, sizeof(unsigned int), cudaMemcpyHostToDevice);
	
	CUDACount<<<1, k>>>(d_A, d_W, d_start_ind, d_len_words, strlen(W), d_count);

	cudaMemcpy(&result, d_count, sizeof(unsigned int), cudaMemcpyDeviceToHost);
	
	printf("Total occurrences of %s: %u\n", W, result);
	
	cudaFree(d_A); cudaFree(d_W); cudaFree(d_start_ind); cudaFree(d_len_words); cudaFree(d_count);

	return 0;
}
