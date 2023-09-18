#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>

__global__ void mulMatA(int* A, int* B, int *C, int n1, int n2) {
	int i=threadIdx.x, sum;
	for(int j=0; j<n2; j++) {
		sum = 0;
		for(int k=0; k<n1; k++) 
			sum += A[i*n1+k] * B[k*n2+j];
		C[i*n2+j] = sum;
	}
}

__global__ void mulMatB(int* A, int* B, int* C, int m1, int n1) {
	int j=threadIdx.x, n2=blockDim.x, sum;
	for(int i=0; i<m1; i++) {
		sum = 0;
		for(int k=0; k<n1; k++)
			sum += A[i*n1+k] * B[k*n2+j];
		C[i*n2+j] = sum;
	}
}

__global__ void mulMatC(int* A, int* B, int* C, int n1, int n2) {
	int tid=threadIdx.x;
	int i=tid/n2, j=tid%n2;
	int sum=0;
	for(int k=0; k<n1; k++)
		sum += A[i*n1+k] * B[k*n2+j];
	C[i*n2+j] = sum;
}	

int main(void) {
	int *A, *B, *C, m1, n1, m2, n2, sizeA, sizeB, sizeC;
	int *d_A, *d_B, *d_C;
	
	printf("Enter the size of matrix, A: ");
	scanf("%d %d", &m1, &n1);
	
	printf("Enter the size of matrix, B: ");
	scanf("%d %d", &m2, &n2);
	
	sizeA = sizeof(int) * m1 * n1;
	sizeB = sizeof(int) * m2 * n2;
	sizeC = sizeof(int) * m1 * n2;
	
	A = (int*) malloc(sizeA);
	B = (int*) malloc(sizeB);
	C = (int*) malloc(sizeC);
	
	printf("Enter input matrix A: \n");
	for(int i=0; i<m1*n1; i++) 
		scanf("%d", A+i);
		
	printf("Enter input matrix B: \n");
	for(int i=0; i<m2*n2; i++) 
		scanf("%d", B+i);
	
	cudaMalloc((void**) &d_A, sizeA);
	cudaMalloc((void**) &d_B, sizeB);
	cudaMalloc((void**) &d_C, sizeC);
	
	cudaMemcpy(d_A, A, sizeA, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, B, sizeB, cudaMemcpyHostToDevice);
	
	mulMatA<<<1, m1>>>(d_A, d_B, d_C, n1, n2);
	
	cudaMemcpy(C, d_C, sizeC, cudaMemcpyDeviceToHost);
	
	printf("Resultant matrix is (Each Row by one Thread): \n");
	for(int i=0; i<m1; i++) {
		for(int j=0; j<n2; j++) 
			printf("\t%d", C[i*n2+j]);
		printf("\n");
	}
	
	mulMatB<<<1, n2>>>(d_A, d_B, d_C, m1, n1);
	
	cudaMemcpy(C, d_C, sizeC, cudaMemcpyDeviceToHost);
	
	printf("Resultant matrix is (Each Column by one Thread): \n");
	for(int i=0; i<m1; i++) {
		for(int j=0; j<n2; j++) 
			printf("\t%d", C[i*n2+j]);
		printf("\n");
	}
	
	mulMatC<<<1, m1*n2>>>(d_A, d_B, d_C, n1, n2);
	
	cudaMemcpy(C, d_C, sizeC, cudaMemcpyDeviceToHost);
	
	printf("Resultant matrix is (Each Element by one Thread): \n");
	for(int i=0; i<m1; i++) {
		for(int j=0; j<n2; j++) 
			printf("\t%d", C[i*n2+j]);
		printf("\n");
	}
	
	getchar();
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);
	
	free(A);
	free(B);
	free(C);
	
	return 0;
}
