############################################################################
# <summary> CMakeLists.txt for MPI, OPENMP and CUDA.	</summary>
# <date>    2013-06-24									</date>
# <author>  Quan Tran Minh.								</author>
# <email>   quantm@unist.ac.kr							</email>
############################################################################
cmake_minimum_required(VERSION 2.6 FATAL_ERROR)
project(hello)

find_package(CUDA REQUIRED)
find_package(MPI REQUIRED)
find_package(OpenMP REQUIRED)
# set(EXECUTABLE_OUTPUT_PATH "${CMAKE_SOURCE_DIR}/bin/")
############################################################################
if(MPI_FOUND)
    message("MPI is found on this system.")
else(MPI_FOUND)
    message("MPI is not installed on this system.")
endif()
if(CUDA_FOUND)
	message("CUDA is found on this system.")
else(CUDA_FOUND)
	message("CUDA is not installed on this system.")
endif()
if(OPENMP_FOUND)
	message("OPENMP is found on this system.")
else(OPENMP_FOUND)
	message("OPENMP is not installed on this system.")
endif()
############################################################################
include_directories(${MPI_INCLUDE_PATH})
list(APPEND CUDA_NVCC_FLAGS 
	-Xcompiler;
	-Wall; 
	-gencode;arch=compute_20,code=sm_20;
	--disable-warnings)
list(APPEND CUDA_NVCC_FLAGS 
	-Xcompiler; 
	-fopenmp;
	-lgomp)
list(APPEND CUDA_NVCC_FLAGS 
	-Xcompiler; 
	-lmpi)	
############################################################################
# Link to CUDA
CUDA_ADD_EXECUTABLE(hello main.cu)
CUDA_ADD_CUFFT_TO_TARGET(hello)
CUDA_ADD_CUBLAS_TO_TARGET(hello)

# Link to MPI
target_link_libraries(hello ${MPI_LIBRARIES})
# set_target_properties(hello PROPERTIES LINK_FLAGS ${MPI_LINK_FLAGS})
set(HOST mpirun.hosts.ib_mvapich)

# Link to OPENMP
target_link_libraries(hello ${OpenMP_CXX_FLAGS})	
############################################################################
# Add a test:
enable_testing()
add_test(Test ${MPIEXEC} 
	${MPIEXEC_NUMPROC_FLAG} 3 
	${MPIEXEC_PREFLAGS} -machinefile mpirun.hosts.ib_mvapich
	# ${MPIEXEC_PREFLAGS} -nolocal #Nolocal should be passed at the last
	${CMAKE_CURRENT_BINARY_DIR}/hello)
############################################################################