#################### See link below for changes if First Part of container does not build ####################
# https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/dockerfiles/dockerfiles/gpu.Dockerfile
##############################################################################################################
# Begin First Part
##############################################################################################################
ARG UBUNTU_VERSION=20.04
ARG CUDA=11.2.0
ARG CUDNN_MAJOR_VERSION=8
FROM nvidia/cuda:${CUDA}-cudnn${CUDNN_MAJOR_VERSION}-devel-ubuntu${UBUNTU_VERSION}
ARG GIT_PROJECT_NAME=my_project

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8

RUN apt-get update && \ 
    apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    software-properties-common \
    unzip \
    python3 \
    python3-pip

RUN python3 -m pip --no-cache-dir install --upgrade \
   pip \
   setuptools

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