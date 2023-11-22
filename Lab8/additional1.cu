#include <stdio.h>
#include <stdlib.h>

#include <cuda.h>


__global__ void replace(int* in, int* out) {
    int m=gridDim.x, n=blockDim.x;
    int row=blockIdx.x, col=threadIdx.x;
    int sum=0;

    for(int i=0; i<m; i++) 
        sum += in[row*n+i];
    
    for(int i=0; i<n; i++) 
        sum += in[i*n+col];

    out[row*n+col] = sum;
}


int main(void) {
	int *h_in, *h_out;
    int m, n, size;

	int *d_in, *d_out;
	
	printf("Enter the size of the matrix: ");
    scanf("%d %d", &m, &n);

    size = sizeof(int) * m * n;
    h_in = (int*) malloc(size);
    h_out = (int*) malloc(size);
	
	printf("Enter the input matrix: \n");
	for(int i=0; i<m*n; i++) 
		scanf("%d", h_in+i);
		
	cudaMalloc((void**) &d_in, size);
    cudaMalloc((void**) &d_out, size);
	
	cudaMemcpy(d_in, h_in, size, cudaMemcpyHostToDevice);
	
	replace<<<n, n>>>(d_in, d_out);
	
	cudaMemcpy(h_out, d_out, size, cudaMemcpyDeviceToHost);
	
	printf("Resultant matrix after replacing values: \n");
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