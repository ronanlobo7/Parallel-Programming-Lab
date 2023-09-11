#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define N 1024

__global__ void CUDACopy(char* d_inp, char* d_out, int len_inp, int len_out) {
	int tid = threadIdx.x;
	int diff = len_inp - tid;
	int start = len_out - (diff * (diff + 1)) / 2;
	for(int i=0; i<len_inp-tid; i++)
		d_out[start+i] = d_inp[i];
}


int main() {
	char inp[N], out[N];
	char* d_inp, *d_out;
	unsigned int size, len;
	
	printf("Enter a string: ");
	scanf(" %[^\n]s", inp);
	
	len = strlen(inp);
	len = (len * (len + 1)) / 2;
	size = len * sizeof(char);
	
	cudaMalloc((void**) &d_inp, strlen(inp) * sizeof(char));
	cudaMalloc((void**) &d_out, size);
	cudaMemcpy(d_inp, inp, strlen(inp) * sizeof(char), cudaMemcpyHostToDevice);
	
	CUDACopy<<<1, strlen(inp)>>>(d_inp, d_out, strlen(inp), len);

	cudaMemcpy(out, d_out, size, cudaMemcpyDeviceToHost);
	out[len] = '\0';
	
	printf("Output String: %s\n", out);
	
	cudaFree(d_inp); cudaFree(d_out);

	return 0;
}
