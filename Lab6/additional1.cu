#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <cuda.h>

#define MAX_LEN 1024
#define NUM_WORDS 100


__global__ void reverse(char* str, int* start_ind, int* len_words) {
	int tid = threadIdx.x;
	int len = len_words[tid];
    str = &str[start_ind[tid]];
		
	for(int i=0; i<len/2; i++) {
        char tmp = str[i];
        str[i] = str[len-i-1];
        str[len-i-1] = tmp;
    }
}

int main() {
	char h_in[MAX_LEN], h_out[MAX_LEN];
    int h_start_ind[NUM_WORDS], h_len_words[NUM_WORDS];
    int len, size_str, size_ind; 

	char *d_str;
	int *d_start_ind, *d_len_words;

	printf("Enter a string: ");
	scanf(" %[^\n]s", h_in);
	
	len = strlen(h_in);
    size_str = sizeof(char) * len;
	
	int i=0;
	int k=0;
	while(i < len) {
		while(i < len && (h_in[i] == ' ' || h_in[i] == '.'))
			i++;
			
		h_start_ind[k] = i;
		while(i < len && !(h_in[i] == ' ' || h_in[i] == '.')) 
			i++;
		
		h_len_words[k] = i - h_start_ind[k];

		k++;
	}
	
	if(h_len_words[k-1] == 0) 
		k--;

    size_ind = sizeof(int) * k;
	
	cudaMalloc((void**) &d_str, size_str);
	cudaMalloc((void**) &d_start_ind, size_ind);
	cudaMalloc((void**) &d_len_words, size_ind);
	
	cudaMemcpy(d_str, h_in, size_str, cudaMemcpyHostToDevice);
	cudaMemcpy(d_start_ind, h_start_ind, size_ind, cudaMemcpyHostToDevice);
	cudaMemcpy(d_len_words, h_len_words, size_ind, cudaMemcpyHostToDevice);
		
	reverse<<<1, k>>>(d_str, d_start_ind, d_len_words);

	cudaMemcpy(h_out, d_str, size_str, cudaMemcpyDeviceToHost);
	
	printf("Resultant string after reversing each of the found words: %s\n", h_out);
	
	cudaFree(d_str);
    cudaFree(d_start_ind); 
    cudaFree(d_len_words); 

	return 0;
}
