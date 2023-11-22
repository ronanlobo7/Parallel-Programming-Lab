// Solution to Batch 2 Lab End Sem Question from what I have understood.
// PLEASE NOTE!!
// The solution might not satisfy all the requirements from the question asked.

#include <stdio.h>
#include <stdlib.h>

#include <cuda.h>

#define MAX_SHARED 10


__device__ void oddEvenTransposition(int* arr, int n, int i, int flag) {
    if(i%2 == flag && i+1 < n) {
        if(arr[i] > arr[i+1]) {
            int tmp = arr[i];
            arr[i] = arr[i+1];
            arr[i+1] = tmp;
        }
    }
}

__global__ void sortRows(int* in, int* out) {
    __shared__ int arr[MAX_SHARED];

    int n=blockDim.x; 
    int row=blockIdx.x, col=threadIdx.x;

    arr[col] = in[row*n+col];
    __syncthreads();

    for(int i=0; i<ceil(n/2.); i++) {
        oddEvenTransposition(arr, n, col, 1);
        __syncthreads();
        oddEvenTransposition(arr, n, col, 0);
        __syncthreads();
    }

    out[row*n+col] = arr[col];
}


int main() {
    int *h_in, *h_out;
    int m, n, size;

    int *d_in, *d_out;

    printf("Enter the size of the input matrix: ");
    scanf("%d %d", &m, &n);

    if(n > MAX_SHARED) {
        printf("The number of columns for this operations is limited to %d...", MAX_SHARED);
        return 0;
    }

    size = sizeof(int) * m * n;
    h_in = (int*) malloc(size);
    h_out = (int*) malloc(size);

    printf("Enter the matrix elements:\n");
    for(int i=0; i<m*n; i++) 
        scanf("%d", h_in+i);

    cudaMalloc((void**) &d_in, size);
    cudaMalloc((void**) &d_out, size);

    cudaMemcpy(d_in, h_in, size, cudaMemcpyHostToDevice);

    sortRows<<<m, n>>>(d_in, d_out);

    cudaMemcpy(h_out, d_out, size, cudaMemcpyDeviceToHost);

    printf("Resultant Matrix after Sorting Rows:\n");
    for(int i=0; i<m; i++) {
        for(int j=0; j<n; j++) 
            printf("\t%d", h_out[i*n+j]);
        printf("\n");
    }

    cudaFree(d_in);
    cudaFree(d_out);

    free(h_in);
    free(h_out);

    return 0;
}