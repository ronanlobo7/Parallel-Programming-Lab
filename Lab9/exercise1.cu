#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>

#define BLOCK_WIDTH 2

__global__ void mulMat(float* A, float* B, float* C, int m1, int n1, int n2) {
	int rid = blockIdx.y * blockDim.y + threadIdx.y;
    int cid = blockIdx.x * blockDim.x + threadIdx.x;
	if(rid < m1 && cid < n2) {
        float sum = 0;
        for(int k=0; k<n1; k++) 
            sum += A[rid*n1+k] * B[k*n2+cid];
        C[rid*n2+cid] = sum;
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

int main(void) {
	float *A, *B, *C;
    int m1, n1, m2, n2, sizeA, sizeB, sizeC;

	float *d_A, *d_B, *d_C;
	
	printf("Enter the size of matrix, A: ");
	scanf("%d %d", &m1, &n1);
	
	printf("Enter the size of matrix, B: ");
	scanf("%d %d", &m2, &n2);

    if(n1 != m2) {
        printf("Number of columns in matrix A should be equal to the number of rows in matrix B for matrix matrix multiplication to be defined...");
        exit(1);
    }
	
	sizeA = sizeof(float) * m1 * n1;
	sizeB = sizeof(float) * m2 * n2;
	sizeC = sizeof(float) * m1 * n2;
	
	A = (float*) malloc(sizeA);
	B = (float*) malloc(sizeB);
	C = (float*) malloc(sizeC);
	
	printf("Enter input matrix A: \n");
	readmat(A, m1, n1);
		
	printf("Enter input matrix B: \n");
	readmat(B, m2, n2);
	
	cudaMalloc((void**) &d_A, sizeA);
	cudaMalloc((void**) &d_B, sizeB);
	cudaMalloc((void**) &d_C, sizeC);
	
	cudaMemcpy(d_A, A, sizeA, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, B, sizeB, cudaMemcpyHostToDevice);

    dim3 gridDim(ceil((float)n2/BLOCK_WIDTH), ceil((float)m1/BLOCK_WIDTH));
    dim3 blockDim(BLOCK_WIDTH, BLOCK_WIDTH);
	
	mulMat<<<gridDim, blockDim>>>(d_A, d_B, d_C, m1, n1, n2);
	
	cudaMemcpy(C, d_C, sizeC, cudaMemcpyDeviceToHost);
	
	printf("Resultant matrix is: \n");
	printmat(C, m1, n2);
	
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);
	
	free(A);
	free(B);
	free(C);
	
	return 0;
}
