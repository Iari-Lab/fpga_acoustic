
TMP_SERVER_PATH := $(TMP_PROJECT_PATH)/server

$(TMP_SERVER_PATH):
	@mkdir -p $@

SERVER_TEMPLATES := $(wildcard $(SERVER_PATH)/templates/*.hpp $(SERVER_PATH)/templates/*.cpp)
SERVER_OBJ := $(subst .cpp,.o, $(addprefix $(TMP_SERVER_PATH)/, $(notdir $(wildcard $(SERVER_PATH)/core/*.cpp))))

DRIVERS := $(shell $(MAKE_PY) --drivers $(CONFIG) $(TMP_SERVER_PATH)/drivers && cat $(TMP_SERVER_PATH)/drivers)
DRIVERS_HPP := $(filter %.hpp,$(DRIVERS))
DRIVERS_CPP := $(filter %.cpp,$(DRIVERS))
DRIVERS_OBJ := $(addprefix $(TMP_SERVER_PATH)/, $(subst .cpp,.o,$(notdir $(filter %.cpp,$(DRIVERS)))))

# Generated source files
###############################################################################
INTERFACE_DRIVERS_HPP := $(addprefix $(TMP_SERVER_PATH)/interface_,$(notdir $(DRIVERS_HPP)))
INTERFACE_DRIVERS_CPP := $(subst .hpp,.cpp,$(INTERFACE_DRIVERS_HPP))
INTERFACE_DRIVERS_OBJ := $(subst .hpp,.o,$(INTERFACE_DRIVERS_HPP))

# Render driver interfaces from templates
###############################################################################

define render_interface
$(TMP_SERVER_PATH)/interface_$(notdir $1) $(TMP_SERVER_PATH)/interface_$(subst .hpp,.cpp,$(notdir $1)): \
		$1 $(SERVER_PATH)/templates/interface_driver.hpp $(SERVER_PATH)/templates/interface_driver.cpp | $(TMP_SERVER_PATH)
	$(MAKE_PY) --render_interface $(CONFIG) $$@ $1
endef
$(foreach driver,$(DRIVERS_HPP),$(eval $(call render_interface,$(driver))))

# Render other templates
###############################################################################

$(TMP_SERVER_PATH)/memory.hpp: $(MEMORY_YML)
	$(MAKE_PY) --memory_hpp $(CONFIG) $@

SERVER_TEMPLATE_LIST := $(addprefix $(TMP_SERVER_PATH)/, drivers_table.hpp drivers_json.hpp context.cpp drivers.hpp interface_drivers.hpp operations.hpp)

define render_template
$1: $(SERVER_PATH)/templates/$(notdir $1) $(DRIVERS_HPP)
	$(MAKE_PY) --render_template $(CONFIG) $$@ $$<
endef
$(foreach template,$(SERVER_TEMPLATE_LIST),$(eval $(call render_template,$(template))))

###############################################################################
# OpenCV 3 Build from Source (Minimal - KalmanFilter only)
###############################################################################
# Use absolute paths based on CURDIR (the directory where make is invoked)
# This ensures paths work correctly regardless of where cmake runs from
OPENCV_VERSION := 3.4.16
OPENCV_BASE_DIR := $(CURDIR)/$(TMP)/opencv
OPENCV_SRC_DIR := $(OPENCV_BASE_DIR)/opencv-$(OPENCV_VERSION)
OPENCV_BUILD_DIR := $(OPENCV_BASE_DIR)/build
OPENCV_INSTALL_DIR := $(OPENCV_BASE_DIR)/install

# Use custom toolchain file located in server directory
OPENCV_TOOLCHAIN_FILE := $(SERVER_PATH)/arm-linux-gnueabihf.toolchain.cmake

# Detect ARM cross-compiler (try versioned first, then unversioned)
ARM_GCC := $(shell which arm-linux-gnueabihf-gcc-$(GCC_VERSION) 2>/dev/null || which arm-linux-gnueabihf-gcc 2>/dev/null || echo "arm-linux-gnueabihf-gcc")
ARM_GXX := $(shell which arm-linux-gnueabihf-g++-$(GCC_VERSION) 2>/dev/null || which arm-linux-gnueabihf-g++ 2>/dev/null || echo "arm-linux-gnueabihf-g++")

# OpenCV source download
$(OPENCV_SRC_DIR)/.downloaded:
	@echo "Downloading OpenCV $(OPENCV_VERSION) source..."
	@mkdir -p $(OPENCV_BASE_DIR)
	@cd $(OPENCV_BASE_DIR) && \
		wget -q --no-check-certificate https://github.com/opencv/opencv/archive/$(OPENCV_VERSION).tar.gz -O opencv-$(OPENCV_VERSION).tar.gz && \
		tar -xzf opencv-$(OPENCV_VERSION).tar.gz
	@touch $@

# OpenCV build configuration and compilation
$(OPENCV_INSTALL_DIR)/lib/libopencv_video.a: $(OPENCV_SRC_DIR)/.downloaded
	@echo "Building OpenCV $(OPENCV_VERSION) for ARM (minimal build with KalmanFilter)..."
	@echo "Using C compiler: $(ARM_GCC)"
	@echo "Using C++ compiler: $(ARM_GXX)"
	@mkdir -p $(OPENCV_BUILD_DIR)
	@cd $(OPENCV_BUILD_DIR) && cmake \
		-DCMAKE_TOOLCHAIN_FILE=$(OPENCV_TOOLCHAIN_FILE) \
		-DCMAKE_C_COMPILER=$(ARM_GCC) \
		-DCMAKE_CXX_COMPILER=$(ARM_GXX) \
		-DCMAKE_MAKE_PROGRAM=$(shell which make) \
		-DCMAKE_INSTALL_PREFIX=$(OPENCV_INSTALL_DIR) \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_CXX_STANDARD=17 \
		-DCMAKE_CXX_FLAGS="-std=c++17 -mcpu=cortex-a9 -mfpu=neon -mfloat-abi=hard" \
		-DCMAKE_C_FLAGS="-mcpu=cortex-a9 -mfpu=neon -mfloat-abi=hard" \
		-DENABLE_NEON=OFF \
		-DENABLE_VFPV3=OFF \
		-DWITH_CAROTENE=OFF \
		-DBUILD_SHARED_LIBS=OFF \
		-DBUILD_opencv_apps=OFF \
		-DBUILD_opencv_calib3d=OFF \
		-DBUILD_opencv_dnn=OFF \
		-DBUILD_opencv_features2d=OFF \
		-DBUILD_opencv_flann=OFF \
		-DBUILD_opencv_gapi=OFF \
		-DBUILD_opencv_highgui=OFF \
		-DBUILD_opencv_imgcodecs=OFF \
		-DBUILD_opencv_imgproc=ON \
		-DBUILD_opencv_java=OFF \
		-DBUILD_opencv_js=OFF \
		-DBUILD_opencv_ml=OFF \
		-DBUILD_opencv_objdetect=OFF \
		-DBUILD_opencv_photo=OFF \
		-DBUILD_opencv_python2=OFF \
		-DBUILD_opencv_python3=OFF \
		-DBUILD_opencv_stitching=OFF \
		-DBUILD_opencv_ts=OFF \
		-DBUILD_opencv_video=ON \
		-DBUILD_opencv_videoio=OFF \
		-DBUILD_opencv_world=OFF \
		-DBUILD_DOCS=OFF \
		-DBUILD_EXAMPLES=OFF \
		-DBUILD_TESTS=OFF \
		-DBUILD_PERF_TESTS=OFF \
		-DBUILD_JAVA=OFF \
		-DBUILD_FAT_JAVA_LIB=OFF \
		-DBUILD_ZLIB=ON \
		-DWITH_1394=OFF \
		-DWITH_CUDA=OFF \
		-DWITH_EIGEN=OFF \
		-DWITH_FFMPEG=OFF \
		-DWITH_GSTREAMER=OFF \
		-DWITH_GTK=OFF \
		-DWITH_IPP=OFF \
		-DWITH_JASPER=OFF \
		-DWITH_JPEG=OFF \
		-DWITH_LAPACK=OFF \
		-DWITH_MATLAB=OFF \
		-DWITH_OPENCL=OFF \
		-DWITH_OPENEXR=OFF \
		-DWITH_OPENGL=OFF \
		-DWITH_PNG=OFF \
		-DWITH_PROTOBUF=OFF \
		-DWITH_QT=OFF \
		-DWITH_TBB=OFF \
		-DWITH_TIFF=OFF \
		-DWITH_V4L=OFF \
		-DWITH_VTK=OFF \
		-DWITH_WEBP=OFF \
		-DWITH_PTHREADS_PF=OFF \
		-DPARALLEL_ENABLE_PLUGINS=OFF \
		-DWITH_ITT=OFF \
		-DBUILD_ITT=OFF \
		-DOPENCV_ENABLE_TRACING=OFF \
		$(OPENCV_SRC_DIR)
	@cd $(OPENCV_BUILD_DIR) && $(MAKE) -j$(N_CPUS)
	@cd $(OPENCV_BUILD_DIR) && $(MAKE) install

.PHONY: opencv
opencv: $(OPENCV_INSTALL_DIR)/lib/libopencv_video.a

.PHONY: clean_opencv
clean_opencv:
	rm -rf $(OPENCV_SRC_DIR) $(OPENCV_BUILD_DIR) $(OPENCV_INSTALL_DIR)

OPENCV_3RDPARTY_DIR := $(OPENCV_BUILD_DIR)/3rdparty/lib

# Link OpenCV libs + bundled 3rdparty libs
OPENCV_LIBS := -L$(OPENCV_INSTALL_DIR)/lib -L$(OPENCV_3RDPARTY_DIR)
OPENCV_ZLIB := $(wildcard $(OPENCV_BUILD_DIR)/3rdparty/lib/libzlib.a)
ifeq ($(OPENCV_ZLIB),)
  OPENCV_ZLIB := $(wildcard $(OPENCV_INSTALL_DIR)/lib/opencv4/3rdparty/libzlib.a)
endif

# OpenCV include and library paths (OpenCV 3.x uses include/opencv2, not include/opencv4)
OPENCV_INCLUDE := -I$(OPENCV_INSTALL_DIR)/include
# Libraries must be in dependency order, with system libs (-lz -lm -ldl -lpthread) at the end
OPENCV_LIBS := -L$(OPENCV_INSTALL_DIR)/lib -Wl,--start-group -lopencv_video -lopencv_imgproc -lopencv_core -Wl,--end-group
OPENCV_SYSLIBS := $(OPENCV_ZLIB) -lm -ldl -lpthread

###############################################################################
# Compile the executable with GCC
###############################################################################
CONTEXT_OBJS := $(TMP_SERVER_PATH)/context.o $(TMP_SERVER_PATH)/spi_dev.o $(TMP_SERVER_PATH)/i2c_dev.o
OBJ := $(SERVER_OBJ) $(INTERFACE_DRIVERS_OBJ) $(DRIVERS_OBJ) $(CONTEXT_OBJS)
DEP := $(subst .o,.d,$(OBJ))
-include $(DEP)

SERVER_CCXX := $(ARM_GXX) 
# SERVER_CCXX := $(ARM_GXX) -flto

# SERVER_CCXXFLAGS := -Wall -Werror -Wextra
# SERVER_CCXXFLAGS += -Wpedantic -Wfloat-equal -Wunused-macros -Wcast-qual -Wuseless-cast
# SERVER_CCXXFLAGS += -Wlogical-op -Wdouble-promotion -Wformat -Wmissing-include-dirs -Wundef
# SERVER_CCXXFLAGS += -Wcast-align -Wpacked -Wredundant-decls -Wvarargs -Wvector-operation-performance -Wswitch-default
# SERVER_CCXXFLAGS += -Wuninitialized -Wshadow -Wzero-as-null-pointer-constant -Wmissing-declarations
# SERVER_CCXXFLAGS += -Wconversion -Wsign-conversion
SERVER_CCXXFLAGS += -I$(TMP_SERVER_PATH) -I$(SERVER_PATH)/core -I$(SDK_PATH) -I. -I$(SERVER_PATH)/context -I$(SERVER_PATH)/drivers -I$(PROJECT_PATH)
SERVER_CCXXFLAGS += -DKOHERON_VERSION=$(KOHERON_VERSION).$(shell git rev-parse --short HEAD)
SERVER_CCXXFLAGS += -MMD -MP -O3 $(GCC_FLAGS)
# Arch flags obtain by running on the Zynq:
# gcc -march=native -Q --help=target
SERVER_CCXXFLAGS += -mcpu=cortex-a9 -mfpu=vfpv3-d16 -mfloat-abi=hard
# SERVER_CCXXFLAGS += -mcpu=cortex-a9 -mfpu=vfpv3-d16 -mvectorize-with-neon-quad -mfloat-abi=hard
SERVER_CCXXFLAGS += -std=c++17 -pthread -lstdc++ -lstdc++fs -static-libstdc++

# Add OpenCV include path
SERVER_CCXXFLAGS += $(OPENCV_INCLUDE)

PHONY: gcc_flags
gcc_flags:
	@echo $(GCC_FLAGS)

$(TMP_SERVER_PATH)/%.o: $(SERVER_PATH)/context/%.cpp
	$(SERVER_CCXX) -c $(SERVER_CCXXFLAGS) -o $@ $<

$(TMP_SERVER_PATH)/%.o: $(SERVER_PATH)/core/%.cpp
	$(SERVER_CCXX) -c $(SERVER_CCXXFLAGS) -o $@ $<

$(TMP_SERVER_PATH)/%.o: $(TMP_SERVER_PATH)/%.cpp
	$(SERVER_CCXX) -c $(SERVER_CCXXFLAGS) -o $@ $<

# Link with OpenCV libraries (system libs must come last)
$(SERVER): $(OBJ) $(OPENCV_INSTALL_DIR)/lib/libopencv_video.a
	$(SERVER_CCXX) -o $@ $(OBJ) $(SERVER_CCXXFLAGS) $(OPENCV_LIBS) $(OPENCV_SYSLIBS)

.PHONY: server
server: $(SERVER_TEMPLATE_LIST) $(INTERFACE_DRIVERS_HPP) $(INTERFACE_DRIVERS_CPP) $(TMP_SERVER_PATH)/memory.hpp opencv | $(KOHERON_SERVER_PATH)
	$(MAKE) --jobs=$(N_CPUS) $(SERVER)

# Clean targets
###############################################################################

.PHONY: clean_server
clean_server:
	rm -rf $(TMP_SERVER_PATH)
