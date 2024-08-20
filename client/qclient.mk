# Makefile 
# author: tucanae47

CONFIG ?= ../projects/lockin/config.yml

PROJECT_PATH := $(dir $(CONFIG))
$(MEMORY_YML): $(CONFIG)
	$(MAKE_PY) --memory_yml $(CONFIG) $@

TMP_SERVER_PATH ?= ./
SDK_PATH ?= .

PYTHON := python3

MAKE_PY := $(PYTHON) make.py

TMP_PROJECT_PATH := .
GCC_VERSION := 9
CCXX := /usr/bin/arm-linux-gnueabihf-g++-$(GCC_VERSION) -flto

# CCXXFLAGS := -Wall -Werror -Wextra
CCXXFLAGS += -Wpedantic -Wfloat-equal -Wunused-macros -Wcast-qual -Wuseless-cast
CCXXFLAGS += -Wlogical-op -Wdouble-promotion -Wformat -Wmissing-include-dirs -Wundef
CCXXFLAGS += -Wcast-align -Wpacked -Wredundant-decls -Wvarargs -Wvector-operation-performance -Wswitch-default
CCXXFLAGS += -Wuninitialized -Wshadow -Wzero-as-null-pointer-constant -Wmissing-declarations
CCXXFLAGS += -Wconversion -Wsign-conversion
CCXXFLAGS += -MMD -MP -O3 $(GCC_FLAGS)
CCXXFLAGS += -mcpu=cortex-a9 -mfpu=vfpv3-d16 -mvectorize-with-neon-quad -mfloat-abi=hard
CCXXFLAGS += -std=c++17 -pthread -lstdc++ -lstdc++fs -static-libstdc++


# Include directories
INCLUDES = -I. -I ../projects/lockin

# Define any libraries to link into executable:
# if you need to link against libraries (e.g., libm.so for the math library), use the -l option, e.g., -lm
LIBS = 

# Define the source files
SOURCES = main.cpp i2c_dev.cpp spi_dev.cpp

# Define the object files
OBJECTS = $(SOURCES:.cpp=.o)


# Define the executable file 
EXECUTABLE = sesenta

all: $(TMP_SERVER_PATH)/memory.hpp $(EXECUTABLE)

$(TMP_SERVER_PATH)/memory.hpp: $(MEMORY_YML)
	$(MAKE_PY) --memory_hpp $(CONFIG) $@

$(EXECUTABLE): $(OBJECTS)
	$(CCXX) $(CCXXFLAGS) $(INCLUDES) -o $@ $(OBJECTS) $(LIBS)

.cpp.o:
	$(CCXX) $(CCXXFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -f $(OBJECTS) $(EXECUTABLE) memory.hpp

.PHONY: all clean

