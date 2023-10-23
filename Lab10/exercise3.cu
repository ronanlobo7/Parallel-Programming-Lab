#include <stdio.h>
#include <stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void oddEvenTransposition(int* arr, int n, int flag) {
    int tid = blockDim.x * blockIdx.x + threadIdx.x;
    if(tid%2 == flag) {
        if(tid+1 < n && arr[tid] > arr[tid+1]) {
            int tmp = arr[tid];
            arr[tid] = arr[tid+1];
            arr[tid+1] = tmp;
        }
    }
}

int main() {
    int *arr, n, sizearr;
    int *d_arr;

    printf("Enter the size of the array: ");
    scanf("%d", &n);

    sizearr = sizeof(int) * n;
    arr = (int*) malloc(sizearr);

    printf("Enter the array elements: ");
    for(int i=0; i<n; i++) 
        scanf("%d", arr+i);

    cudaMalloc((void**) &d_arr, sizearr);
    cudaMemcpy(d_arr, arr, sizearr, cudaMemcpyHostToDevice);

    for(int i=0; i<n/2; i++) {
        oddEvenTransposition<<<ceil(n/256.0), 256>>>(d_arr, n, 0);
        oddEvenTransposition<<<ceil(n/256.0), 256>>>(d_arr, n, 1);
    }

    cudaMemcpy(arr, d_arr, sizearr, cudaMemcpyDeviceToHost);

    printf("Resultant Array after Odd Even Transposition Sorting:\n");
    for(int i=0; i<n; i++) 
        printf("%4d", arr[i]);
    printf("\n");

    cudaFree(d_arr);
    free(arr);
    
    return 0;
}


