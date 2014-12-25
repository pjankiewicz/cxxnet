# set LD_LIBRARY_PATH
export CC  = gcc
export CXX = g++
export NVCC = /usr/local/cuda-6.5/bin/nvcc

export CFLAGS = -Wall -g -O3 -msse3 -Wno-unknown-pragmas -funroll-loops -I./mshadow/ -I/home/pawel/intel/mkl/include/ -I/usr/local/cuda-6.5/targets/x86_64-linux/include/

ifeq ($(blas),1)
 LDFLAGS= -lm -lcudart -lcublas -lcurand -lz `pkg-config --libs opencv` -lblas -lpthread
 CFLAGS+= -DMSHADOW_USE_MKL=0 -DMSHADOW_USE_CBLAS=1
else
 #-lmkl_intel 
 LDFLAGS= -L/usr/local/cuda-6.5/targets/x86_64-linux/lib -L/home/pawel/intel/mkl/lib/intel64 -L/home/pawel/intel/composer_xe_2015.1.133/compiler/lib/intel64 -lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core -liomp5 -lpthread -lm -lcudart -lcublas -lcurand -lz `pkg-config --libs opencv` 
 #-liomp5 -lpthread -lmkl_core -lmkl_intel_lp64 -lmkl_intel_thread -L/usr/local/cuda-6.5/targets/x86_64-linux/lib -L/usr/local/cuda-6.5/targets/x86_64-linux/lib  -lm
endif

export NVCCFLAGS = --use_fast_math -g -O3 -ccbin $(CXX)

# specify tensor path
BIN = bin/cxxnet
OBJ = cxxnet_data.o cxxnet_nnet_cpu.o
CUOBJ = cxxnet_nnet_gpu.o
CUBIN =
.PHONY: clean all

all: $(BIN) $(OBJ) $(CUBIN) $(CUOBJ)

cxxnet_nnet_gpu.o: cxxnet/nnet/cxxnet_nnet.cu cxxnet/core/*.hpp cxxnet/core/*.h cxxnet/nnet/*.hpp cxxnet/nnet/*.h
cxxnet_nnet_cpu.o: cxxnet/nnet/cxxnet_nnet.cpp cxxnet/core/*.hpp cxxnet/core/*.h cxxnet/nnet/*.hpp cxxnet/nnet/*.h
cxxnet_data.o: cxxnet/io/cxxnet_data.cpp cxxnet/io/*.hpp cxxnet/utils/cxxnet_io_utils.h
bin/cxxnet: cxxnet/cxxnet_main.cpp cxxnet_data.o cxxnet_nnet_cpu.o cxxnet_nnet_gpu.o
$(BIN) :
	$(CXX) $(CFLAGS)  -o $@ $(filter %.cpp %.o %.c, $^) $(LDFLAGS)

$(OBJ) :
	$(CXX) -c $(CFLAGS) -o $@ $(firstword $(filter %.cpp %.c, $^) )

$(CUOBJ) :
	$(NVCC) -c -o $@ $(NVCCFLAGS) -Xcompiler "$(CFLAGS)" $(filter %.cu, $^)
$(CUBIN) :
	$(NVCC) -o $@ $(NVCCFLAGS) -Xcompiler "$(CFLAGS)" -Xlinker "$(LDFLAGS)" $(filter %.cu %.cpp %.o, $^)

clean:
	$(RM) $(OBJ) $(BIN) $(CUBIN) $(CUOBJ) *~


