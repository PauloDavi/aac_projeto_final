CC = g++
CUCOMP = nvcc
CUFLAGS = -arch=native

run:
	./test.sh

compile_single: main.cpp
	$(CC) main.cpp -o main.o

run_single: compile_single
	multitime -n 5 ./main.o $(ARGS) false

## CUDA
compile_cuda: main.cu
	$(CUCOMP) $(CUFLAGS) main.cu -o main.o -lcurand

run_cuda: compile_cuda
	multitime -n 5 ./main.o $(ARGS)