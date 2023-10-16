#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>

#define BLOCK_WIDTH 2 

__global__ void conv2D(float* A, float* M, float* R, 
                        int mA, int nA, int mM, int nM) {
    int rid = blockIdx.y * blockDim.y + threadIdx.y;
    int cid = blockIdx.x * blockDim.x + threadIdx.x;

    if(rid < mA && cid < nA) {
        float sum = 0;
        int startx = rid - mM / 2, starty = cid - nM / 2;
        for(int i=0; i<mM; i++) 
            for(int j=0; j<nM; j++) 
                if(startx + i >= 0 && startx + i < mA && starty + j >= 0 && starty + j < nA) 
                    sum += A[(startx+i)*nA+(starty+j)] * M[i*nM+j];
        R[rid*nA+cid] = sum;
    }
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
    float *A, *M, *R;
    int mA, nA, mM, nM, sizeA, sizeM;

    float *d_A, *d_M, *d_R;


    printf("Enter the size of 2D input array, A: ");
	scanf("%d %d", &mA, &nA);
	
	printf("Enter the size of mask, M: ");
	scanf("%d %d", &mM, &nM);

    sizeA = sizeof(float) * mA * nA;
	sizeM = sizeof(float) * mM * nM;

    A = (float*) malloc(sizeA);
    M = (float*) malloc(sizeM);
    R = (float*) malloc(sizeA);

    printf("Enter elements of array A:\n");
    readmat(A, mA, nA);

    printf("Enter elements of mask, M:\n");
    readmat(M, mM, nM);

    cudaMalloc((void**) &d_A, sizeA);
    cudaMalloc((void**) &d_M, sizeM);
    cudaMalloc((void**) &d_R, sizeA);

    cudaMemcpy(d_A, A, sizeA, cudaMemcpyHostToDevice);
	cudaMemcpy(d_M, M, sizeM, cudaMemcpyHostToDevice);

    dim3 gridDim(ceil((float)nA/BLOCK_WIDTH), ceil((float)mA/BLOCK_WIDTH));
    dim3 blockDim(BLOCK_WIDTH, BLOCK_WIDTH);

    conv2D<<<gridDim, blockDim>>>(d_A, d_M, d_R, mA, nA, mM, nM);

    cudaMemcpy(R, d_R, sizeA, cudaMemcpyDeviceToHost);
	
	printf("Resultant array after 2D convolution is: \n");
	printmat(R, mA, nA);
	
	cudaFree(d_A);
	cudaFree(d_M);
	cudaFree(d_R);
	
	free(A);
	free(M);
	free(R);
	
	return 0;
}