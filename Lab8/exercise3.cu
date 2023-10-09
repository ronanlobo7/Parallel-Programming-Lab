#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>

__global__ void replace(int* mat, int* out) {
    int m=blockDim.y, n=blockDim.x;
    int rid=threadIdx.y, cid=threadIdx.x;
    int binary=0, val=mat[rid*n+cid], bitcount=0, rev=0;

    if(rid == 0 || rid == m-1 || cid == 0 || cid == n-1) {
        rev = val;
    }
    else {
        while(val > 0) {
            binary *= 10;
            if(val%2 == 0) 
                binary += 1;
            val >>= 1;
            bitcount++;
        }

        while(bitcount--) {
            rev = rev*10 + binary%10;
            binary /= 10;
        }

    }

    out[rid*n+cid] = rev;
}

void readmat(int* mat, int m, int n) {
    for(int i=0; i<m*n; i++)
        scanf("%d", mat+i);
}

void printmat(int* mat, int m, int n) {
    for(int i=0; i<m; i++) {
        for(int j=0; j<n; j++) 
            printf("\t%d", mat[i*n+j]);
        printf("\n");
    }
}

int main() {
    int *mat, *out;
    int m, n, sizemat;

    int *d_mat, *d_out;

    printf("Enter the dimensions of the matrix: ");
    scanf("%d %d", &m ,&n);

    sizemat = m * n * sizeof(int);
    mat = (int*) malloc(sizemat);
    out = (int*) malloc(sizemat);

    printf("\nEnter the matrix elements:\n");
    readmat(mat, m, n);

    cudaMalloc((void**) &d_mat, sizemat);
    cudaMalloc((void**) &d_out, sizemat);

    cudaMemcpy(d_mat, mat, sizemat, cudaMemcpyHostToDevice);
    cudaMemcpy(d_out, out, sizemat, cudaMemcpyHostToDevice);

    dim3 gridDim(1, 1);
    dim3 blockDim(n, m);

    replace<<<gridDim, blockDim>>>(d_mat, d_out);

    cudaMemcpy(out, d_out, sizemat, cudaMemcpyDeviceToHost);

    printf("\nResultant Matrix:\n");
    printmat(out, m, n);

    cudaFree(d_mat); cudaFree(d_out);
    free(mat); free(out);

    return 0;
}