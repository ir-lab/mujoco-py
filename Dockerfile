# First part from : https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/dockerfiles/dockerfiles/gpu.Dockerfile
#######################################################################################################
ARG UBUNTU_VERSION=20.04
ARG ARCH=
ARG CUDA=11.2
ARG CUDNN_MAJOR_VERSION=8
FROM nvidia/cuda${ARCH:+-$ARCH}:${CUDA}.1-cudnn${CUDNN_MAJOR_VERSION}-devel-ubuntu${UBUNTU_VERSION} as base
# ARCH and CUDA are specified again because the FROM directive resets ARGs
# (but their default value is retained if set previously)
ARG ARCH
ARG CUDA
ARG CUDNN=8.1.0.77-1
ARG CUDNN_MAJOR_VERSION=8
ARG LIB_DIR_PREFIX=x86_64
ARG LIBNVINFER=7.2.2-1
ARG LIBNVINFER_MAJOR_VERSION=7
ARG TF_PACKAGE=tensorflow
ARG TF_PACKAGE_VERSION=

# Let us install tzdata painlessly
ENV DEBIAN_FRONTEND=noninteractive

# Needed for string substitution
SHELL ["/bin/bash", "-c"]
# Pick up some TF dependencies
# cuda-command-line-tools-${CUDA/./-} \
# libcublas-${CUDA/./-} \
# cuda-nvrtc-${CUDA/./-} \
# libcufft-${CUDA/./-} \
# libcurand-${CUDA/./-} \
# libcusolver-${CUDA/./-} \
# libcusparse-${CUDA/./-} \
# libcudnn8=${CUDNN}+cuda${CUDA} \
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub && \
    apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libzmq3-dev \
        pkg-config \
        software-properties-common \
        unzip

# Install TensorRT if not building for PowerPC
# NOTE: libnvinfer uses cuda11.1 versions
RUN [[ "${ARCH}" = "ppc64le" ]] || { apt-get update && \
        apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub && \
        echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /"  > /etc/apt/sources.list.d/tensorRT.list && \
        apt-get update && \
        apt-get install -y --no-install-recommends libnvinfer${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}+cuda11.0 \
        libnvinfer-plugin${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}+cuda11.0 \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*; }

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda-11.0/targets/x86_64-linux/lib:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Link the libcuda stub to the location where tensorflow is searching for it and reconfigure
# dynamic linker run-time bindings
RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 \
    && echo "/usr/local/cuda/lib64/stubs" > /etc/ld.so.conf.d/z-cuda-stubs.conf \
    && ldconfig

# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip

RUN python3 -m pip --no-cache-dir install --upgrade \
    "pip<20.3" \
    setuptools

# Some TF tools expect a "python" binary
RUN ln -s $(which python3) /usr/local/bin/python

ENV CPATH /usr/local/cuda/targets/x86_64-linux/include:${CPATH}
# ENV LD_LIBRARY_PATH /usr/local/cuda/targets/x86_64-linux/lib:${LD_LIBRARY_PATH}
# ENV PATH /usr/local/cuda/bin:${PATH}

##############################################################################################################
# End First Part
##############################################################################################################

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    libgl1-mesa-dev \
    libgl1-mesa-glx \
    libglew-dev \
    libosmesa6-dev \
    net-tools \
    vim \
    wget \
    xpra \
    xserver-xorg-dev \
    patchelf \
    libglfw3

RUN mkdir -p /home/docker/.mujoco \
    && wget https://mujoco.org/download/mujoco210-linux-x86_64.tar.gz -O mujoco.tar.gz \
    && tar -xf mujoco.tar.gz -C /home/docker/.mujoco \
    && rm mujoco.tar.gz

ENV LD_LIBRARY_PATH /home/docker/.mujoco/mujoco210/bin:${LD_LIBRARY_PATH}