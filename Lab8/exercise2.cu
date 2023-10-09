#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>

__global__ void replace(float* mat, int n) {
    int rid = threadIdx.x;
    for(int i=0; i<n; i++)
        mat[rid*n+i] = pow(mat[rid*n+i], rid+1);
}

void readmat(float* mat, int m, int n) {
    for(int i=0; i<m*n; i++)
        scanf("%f", mat+i);
}

void printmat(float* mat, int m, int n) {
    for(int i=0; i<m; i++) {
        for(int j=0; j<n; j++) 
            printf("\t%.2f", mat[i*n+j]);
        printf("\n");
    }
}

int main() {
    float *mat;
    int m, n, sizemat;

    float *d_mat;

    printf("Enter the dimensions of the matrix: ");
    scanf("%d %d", &m ,&n);

    sizemat = m * n * sizeof(float);
    mat = (float*) malloc(sizemat);

    printf("\nEnter the matrix elements:\n");
    readmat(mat, m, n);

    cudaMalloc((void**) &d_mat, sizemat);

    cudaMemcpy(d_mat, mat, sizemat, cudaMemcpyHostToDevice);

    replace<<<1, m>>>(d_mat, n);

    cudaMemcpy(mat, d_mat, sizemat, cudaMemcpyDeviceToHost);

    printf("Resultant Matrix:\n");
    printmat(mat, m, n);

    cudaFree(d_mat);
    free(mat);

    return 0;
}