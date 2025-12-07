#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <cuda_runtime.h>
#include <iostream>

#define N 10000000 // Vector size = 10 million
#define BLOCK_SIZE_1D 1024 // 1024 threads per block
#define BLOCK_SIZE_3D_X 16
#define BLOCK_SIZE_3D_Y 8
#define BLOCK_SIZE_3D_Z 8
// 16 * 16 * 8 = 1024 threads per block

// CPU Vector Addition
void vector_add_cpu(float* a, float* b, float* c, int n) {
    for (int i = 0; i < n; i++) {
        c[i] = a[i] + b[i];
    }
}

// CUDA Kernel for 1D Vector Addition
__global__ void vector_add_gpu_1d(float* a, float* b, float* c, int n) {
    // Calculate global thread ID (current block * size of a block (threads per block) + current thread in that block)
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) {
        c[i] = a[i] + b[i];
    }
}

// CUDA Kernel for 3D Vector Addition
__global__ void vector_add_gpu_3d(float* a, float* b, float* c, int nx, int ny, int nz) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;
    int k = blockIdx.z * blockDim.z + threadIdx.z;

    if (i < nx && j < ny && k < nz) {
        int idx = i + j * nx + k * nx * ny; // Flatten 3D index to 1D
        if (idx < nx * ny * nz) {
            c[idx] = a[idx] + b[idx];
        }
    }
}

// Initialize a vector with random values
void init_vector(float* vec, int n) {
    for (int i = 0; i < n; i++) {
        vec[i] = (float) rand() / RAND_MAX;
    }
}

// Measure execution time
double get_time() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec * 1e-9;
}

int main () {
    float *h_a, *h_b, *h_c_cpu, *h_c_gpu_1d, *h_c_gpu_3d;
    float *d_a, *d_b, *d_c_1d, *d_c_3d;
    size_t size = N * sizeof(float);

    // Allocate host memory
    h_a = (float*) malloc(size); // malloc returns a void*
    h_b = (float*) malloc(size);
    h_c_cpu = (float*) malloc(size);
    h_c_gpu_1d = (float*) malloc(size);
    h_c_gpu_3d = (float*) malloc(size);

    // Initialize the vectors
    srand(time(NULL));
    init_vector(h_a, N);
    init_vector(h_b, N);

    // Allocate device memory (GPU VRAM)
    cudaMalloc(&d_a, size); // Allocate memory at VRAM location of d_a
    cudaMalloc(&d_b, size);
    cudaMalloc(&d_c_1d, size);
    cudaMalloc(&d_c_3d, size);

    // Copy data to device (GPU) from the host (CPU)
    cudaMemcpy(d_a, h_a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, size, cudaMemcpyHostToDevice);

    // Define the grid and block dimensions for 1D
    int num_blocks_1d = (N + BLOCK_SIZE _1D- 1) / BLOCK_SIZE_1D;

    // Define the grid and block dimensions for 3D
    int nx = 100, ny = 100, nz = 1000; // N = 100 * 100 * 1000 = 10 million
    dim3 block_size_3d(BLOCK_SIZE_3D_X, BLOCK_SIZE_3D_Y, BLOCK_SIZE_3D_Z);
    dim3 num_blocks_3d(
        (nx + block_size_3d.x - 1) / block_size_3d.x,
        (ny + block_size_3d.y - 1) / block_size_3d.y,
        (nz + block_size_3d.z - 1) / block_size_3d.z,
    );

    // Warm-up Runs
    printf("Performing warm-up runs...\n");
    for (int i = 0; i < 3; i++) {
        vector_add_cpu(h_a, h_b, h_c_cpu, N);
        vector_add_gpu_1d<<<num_blocks_1d, BLOCK_SIZE_1D>>>(d_a, d_b, d_c_1d, N);
        vector_add_gpu_3d<<<num_blocks_3d, BLOCK_SIZE_3D>>>(d_a, d_b, d_c_3d, nx, ny, nz);
        cudaDeviceSynchronize();
    }

    // Benchmark CPU implementation
    printf("Benchmarking CPU implementation...\n");
    double cpu_total_time = 0.0;

    for (int i = 0; i < 5; i++) {
        double start_time = get_time();

        vector_add_cpu(h_a, h_b, h_c_cpu, N);

        double end_time = get_time();
        cpu_total_time += end_time - start_time;
    }

    double cpu_avg_time = cpu_total_time / 5.0;

    // Benchmark GPU 1D implementation
    printf("Benchmarking GPU 1D implementation...\n");
    double gpu_1d_total_time = 0.0;

    for (int i = 0; i < 100; i++) {
        cudaMemset(d_c_1d, 0, size); // Clear previous results from device memory

        double start_time = get_time();

        vector_add_gpu_1d<<<num_blocks_1d, BLOCK_SIZE_1D>>>(d_a, d_b, d_c_1d, N);
        cudaDeviceSynchronize();

        double end_time = get_time();
        gpu_1d_total_time += end_time - start_time;
    }

    double gpu_1d_avg_time = gpu_1d_total_time / 100.0;

    // Verify 1D results immediately
    cudaMemcpy(h_c_gpu_1d, d_c_1d, size, cudaMemcpyDeviceToHost);
    bool correct_1d = true;

    for (int i = 0; i < N; i++) {
        if (fabs(h_c_cpu[i] - h_c_gpu_1d[i]) > 1e-4) {
            correct_1d = false;
            std::cout << i << " cpu: " << h_c_cpu[i] << " != " << h_c_gpu_1d[i] << std::endl;
            break;
        }
    }

    printf("1D Results are %s\n", correct_1d ? "correct" : "incorrect");

    // Benchmark GPU 3D implementation
    printf("Benchmarking GPU 3D implementation...\n");
    double gpu_3d_total_time = 0.0;

    for (int i = 0; i < 100; i++) {
        cudaMemset(d_c_3d, 0, size);  // Clear previous results from device memory

        double start_time = get_time();

        vector_add_gpu_3d<<<num_blocks_3d, block_size_3d>>>(d_a, d_b, d_c_3d, nx, ny, nz);
        cudaDeviceSynchronize();

        double end_time = get_time();
        gpu_3d_total_time += end_time - start_time;
    }

    double gpu_3d_avg_time = gpu_3d_total_time / 100.0;

    // Verify 3D results immediately
    cudaMemcpy(h_c_gpu_3d, d_c_3d, size, cudaMemcpyDeviceToHost);
    bool correct_3d = true;

    for (int i = 0; i < N; i++) {
        if (fabs(h_c_cpu[i] - h_c_gpu_3d[i]) > 1e-4) {
            correct_3d = false;
            std::cout << i << " cpu: " << h_c_cpu[i] << " != " << h_c_gpu_3d[i] << std::endl;
            break;
        }
    }
    
    printf("3D Results are %s\n", correct_3d ? "correct" : "incorrect");

    // Print results
    printf("CPU average time: %f milliseconds\n", cpu_avg_time * 1000);
    printf("GPU 1D average time: %f milliseconds\n", gpu_1d_avg_time * 1000);
    printf("GPU 3D average time: %f milliseconds\n", gpu_3d_avg_time * 1000);
    printf("Speedup (CPU vs GPU 1D): %fx\n", cpu_avg_time / gpu_1d_avg_time);
    printf("Speedup (CPU vs GPU 3D): %fx\n", cpu_avg_time / gpu_3d_avg_time);
    printf("Speedup (GPU 1D vs GPU 3D): %fx\n", gpu_1d_avg_time / gpu_3d_avg_time);

    // Free memory
    free(h_a);
    free(h_b);
    free(h_c_cpu);
    free(h_c_gpu_1d);
    free(h_c_gpu_3d);
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c_1d);
    cudaFree(d_c_3d);

    return 0;
}