#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <cuda.h>

#define MAX_LEN 1024


__global__ void kernel(char* in, char* out) {
    int tid = threadIdx.x;
    int start = (tid * (tid+1)) / 2;
    char c = in[tid];

    for(int i=0; i<tid+1; i++) 
        out[start+i] = c;
}


int main() {
    char h_in[MAX_LEN], *h_out;
    int len_in, len_out, size_in, size_out;

    char *d_in, *d_out;

    printf("Enter the string Sin: ");
    scanf("%s", h_in);

    len_in = strlen(h_in);
    size_in = sizeof(char) * len_in;

    len_out = (len_in * (len_in + 1)) / 2;
    size_out = sizeof(char) * len_out;

    h_out = (char*) malloc(size_out + sizeof(char));

    cudaMalloc((void**) &d_in, size_in);
    cudaMalloc((void**) &d_out, size_out);

    cudaMemcpy(d_in, h_in, size_in, cudaMemcpyHostToDevice);

    kernel<<<1, len_in>>>(d_in, d_out);

    cudaMemcpy(h_out, d_out, size_out, cudaMemcpyDeviceToHost);
    h_out[len_out] = '\0';

    printf("Output string T: %s", h_out);

    cudaFree(d_in);
    cudaFree(d_out);

    free(h_out);

    return 0;
}