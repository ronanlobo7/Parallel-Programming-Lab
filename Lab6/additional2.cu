#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda.h>

#define MAX_LEN 100


__global__ void kernel(char* in, char* out, int N) {
    int tid = threadIdx.x;
    int len = blockDim.x;
    int ind = tid;
    char c = in[tid];

    for(int i=0; i<N; i++) {
        out[ind] = c;
        ind += len;
    }
}


int main() {
    char h_in[MAX_LEN], *h_out;
    int N, len, size_in, size_out;

    char *d_in, *d_out;

    printf("Enter the string, Sin: ");
    scanf("%s", h_in);

    printf("Enter the integer, N: ");
    scanf("%d", &N);

    len = strlen(h_in);
    size_in = sizeof(char) * (len + 1);
    size_out = sizeof(char) * (len * N + 1);

    h_out = (char*) malloc(size_out);

    cudaMalloc((void**) &d_in, size_in);
    cudaMalloc((void**) &d_out, size_out);

    cudaMemcpy(d_in, h_in, size_in, cudaMemcpyHostToDevice);

    kernel<<<1, len>>>(d_in, d_out, N);

    cudaMemcpy(h_out, d_out, size_out, cudaMemcpyDeviceToHost);

    printf("Resultant output string, Sout: %s\n", h_out);

    cudaFree(d_in);
    cudaFree(d_out);

    free(h_out);

    return 0;
}