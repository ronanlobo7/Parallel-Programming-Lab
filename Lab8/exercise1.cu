#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>

__global__ void matMul(float* data, int* col_ind, int* row_ptr, float* vec, float* out) {
    int rid=threadIdx.x;
    int start=row_ptr[rid], end=row_ptr[rid+1];
    float sum=0;
    for(int i=start; i<end; i++) 
        sum += data[i] * vec[col_ind[i]];
    out[rid] = sum;
}

void readmat(float* mat, int m, int n) {
    for(int i=0; i<m*n; i++)
        scanf("%f", mat+i);
}

void readvec(float* mat, int n) {
    for(int i=0; i<n; i++)
        scanf("%f", mat+i);
}

void printmat(float* mat, int m, int n) {
    for(int i=0; i<m; i++) {
        for(int j=0; j<n; j++) 
            printf("\t%.2f", mat[i*n+j]);
        printf("\n");
    }
}

void printvec(float* mat, int n) {
    for(int i=0; i<n; i++)
        printf("\t%.2f\n", mat[i]);
}

void convtosparse(float* mat, int m, int n, float** data, int** col_ind, int** row_ptr, int* count) {
    *count = 0;
    for(int i=0; i<m*n; i++) 
        if(mat[i] != 0.) 
            (*count)++; 

    *data = (float*) malloc(*count * sizeof(float));
    *col_ind = (int*) malloc(*count * sizeof(int));
    *row_ptr = (int*) malloc((m+1) * sizeof(int));

    int k = 0;
    for(int i=0; i<m; i++) {
        (*row_ptr)[i] = k;
        for(int j=0; j<n; j++)
            if(mat[i*n+j] != 0.) {
                (*data)[k] = mat[i*n+j];
                (*col_ind)[k] = j;
                k++;
            }
    }
    (*row_ptr)[m] = *count;
}

int main() {
    float *mat, *vec, *out;
    int l, m, n, sizemat, sizevec, sizeout;

    float *data;
    int *col_index, *row_ptr;
    int count;

    float *d_data, *d_vec, *d_out;
    int *d_col_index, *d_row_ptr;
    int sizedata, sizecolindex, sizerowptr;

    printf("Enter the dimensions of the matrix: ");
    scanf("%d %d", &m ,&n);
    
    printf("Enter the length of the vector: ");
    scanf("%d", &l);

    if(l != n) {
        printf("Number of columns in matrix and the length of the vector must be equal for matrix-vector multiplication to be defined...");
        exit(1);
    }

    sizemat = m * n * sizeof(float);
    sizevec = l * sizeof(float);
    sizeout = m * sizeof(float);

    mat = (float*) malloc(sizemat);
    vec = (float*) malloc(sizevec);
    out = (float*) malloc(sizeout);

    printf("\nEnter the matrix elements:\n");
    readmat(mat, m, n);

    printf("\nEnter the vector elements:\n");
    readvec(vec, l);

    convtosparse(mat, m, n, &data, &col_index, &row_ptr, &count);

    sizedata = count * sizeof(float);
    sizecolindex = count * sizeof(int);
    sizerowptr = (m+1) * sizeof(int);

    cudaMalloc((void**) &d_data, sizedata);
    cudaMalloc((void**) &d_col_index, sizecolindex);
    cudaMalloc((void**) &d_row_ptr, sizerowptr);
    cudaMalloc((void**) &d_vec, sizevec);
    cudaMalloc((void**) &d_out, sizeout);

    cudaMemcpy(d_data, data, sizedata, cudaMemcpyHostToDevice);
    cudaMemcpy(d_col_index, col_index, sizecolindex, cudaMemcpyHostToDevice);
    cudaMemcpy(d_row_ptr, row_ptr, sizerowptr, cudaMemcpyHostToDevice);
    cudaMemcpy(d_vec, vec, sizevec, cudaMemcpyHostToDevice);

    matMul<<<1, m>>>(d_data, d_col_index, d_row_ptr, d_vec, d_out);

    cudaMemcpy(out, d_out, sizeout, cudaMemcpyDeviceToHost);

    printf("\nResultant Vector after Matrix-Vector Multiplication:\n");
    printvec(out, m);

    cudaFree(d_data);
    cudaFree(d_col_index);
    cudaFree(d_row_ptr);
    cudaFree(d_vec);
    cudaFree(d_out);

    free(data);
    free(col_index);
    free(row_ptr);
    free(mat);
    free(vec);
    free(out);

    return 0;
}