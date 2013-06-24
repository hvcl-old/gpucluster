#include <stdio.h>
#include <cuda.h>
#include <mpi.h>
#include <omp.h>
int main (int argc, char *argv[])
{
	int id, np, i;
	char processor_name[MPI_MAX_PROCESSOR_NAME];
	int processor_name_len;
	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD, &np);
	MPI_Comm_rank(MPI_COMM_WORLD, &id);
	MPI_Get_processor_name(processor_name, &processor_name_len);
	printf("Hello world from process %03d out of %03d, processor name %s\n",
		id, np, processor_name);
	int deviceCount = 0;
	
    cudaError_t error_id = cudaGetDeviceCount(&deviceCount);

    if (error_id != cudaSuccess)
    {
        printf("%s\n", cudaGetErrorString(error_id));
        // exit(EXIT_FAILURE);
    }
    // This function call returns 0 if there are no CUDA capable devices.
    if (deviceCount == 0)
    {
        printf("There are no available device(s) that support CUDA\n");
    }
    else
    {
        printf("Detected %d CUDA Capable device(s)\n", deviceCount);
		#pragma omp parallel num_threads(deviceCount)
		{
			int d = omp_get_thread_num();
			#pragma omp critical
			{
				printf("This is GPU %d of processor name %s\n",
						d, processor_name);
			}
		}
    }

	MPI_Finalize();
	return 0;
}