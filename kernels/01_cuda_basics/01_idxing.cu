#include <stdio.h>

// __global__ is visible globally, meaning the CPU or host can call this global function.
// Typically don't return anything but just do really fast operations to a variable passed in
// This is a cuda kernel which runs on the GPU instead of the CPU
__global__ void whoami(void) {
    /*
    1. Kernel executes in a thread
    2. Threads grouped into Thread Blocks
    3. Blocks are grouped into a Grid
    4. Kernel executed as a Grid of Blocks of Threads

    Grid - Represents the entire set of threads launched for a single invocation of a kernel (Collection of thread blocks)

    Block - Group of threads that can cooperate on tasks, share data, and synchronize with each other quickly through shared memory (L1 cache). It can be 1D, 2D, or 3D
    If processing an image, a block might handle a 16x16 pixel region

    Threads - Smallest unit of execution in CUDA which executes the kernel code independently
    Within a block, threads have a unique thread ID which allows for access to specific data

    Warps - Set of parallelized threads (maximum of 32 threads) inside of a block.
    Instructions are issued to warps that then tell the threads what to do
    The warp scheduler makes warps run

    
    gridDim: 3-component vector that specifies the dimensions of the grid
    blockIdx: 3-component vector that gives the block's position in the grid
    blockDim: 3-component vector that specifies the dimensions of the blocm
    threadIdx: 3-component vector that gives the thread's position in its block
    */

    int block_id = 
        blockIdx.x + // offset for x dimension
        blockIdx.y * gridDim.x + // offset for y dimension
        blockIdx.z * gridDim.x * gridDim.y; // offset for z dimension

    int block_offset = 
        block_id * // which block
        blockDim.x * blockDim.y * blockDim.z; // total threads per block

    int thread_offset =
        threadIdx.x + // offset for x dimension
        threadIdx.y * blockDim.x + // offset for y dimension
        threadIdx.z * blockDim.x * blockDim.y; // offset for z dimension

    int id = block_offset + thread_offset; // global thread id

    printf("%04d | Block(%d %d %d) = %3d | Thread(%d %d %d) = %3d\n",
        id,
        blockIdx.x, blockIdx.y, blockIdx.z, block_id,
        threadIdx.x, threadIdx.y, threadIdx.z, thread_offset);
}

int main() {
    const int b_x = 2, b_y = 3, b_z = 4; // grid dimensions
    const int t_x = 4, t_y = 4, t_z = 4; // block dimensions
    // We will have 2 warps of 32 threads in each block (64 threads per block)

    int blocks_per_grid = b_x * b_y * b_z;
    int threads_per_block = t_x * t_y * t_z;

    printf("%d blocks per grid\n", blocks_per_grid);
    printf("%d threads per block\n", threads_per_block);
    printf("%d total threads\n", blocks_per_grid * threads_per_block);

    // dim3 is used to specify 3D dimensions
    dim3 blocksPerGrid(b_x, b_y, b_z); // 3D cube of shape 2 x 3 x 4 = 24 blocks in a grid
    dim3 threadsPerBlock(t_x, t_y, t_z); // 3D cube of shape 4 x 4 x 4 = 64 threads per block

    // <<<>>> is used to configure and launch kernels on the GPU
    // It defines the grid and block dimensions, shared memory size, and stream for kernel execution
    whoami<<<blocksPerGrid, threadsPerBlock>>>();

    // By default CPU and GPU work together to minimize time
    // Sometimes we need to make CPU wait until all GPU operations are complete, which is done with cudaDeviceSynchronize()
    // Useful when you need results before continuing
    cudaDeviceSynchronize(); // wait for the kernel to finish
}