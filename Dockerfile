# Tag: nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04
FROM mcr.microsoft.com/azureml/base-gpu:latest 
ENV STAGE_DIR=/root/gpu/install 
RUN mkdir -p $STAGE_DIR

# Install basic dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        --allow-change-held-packages \
        build-essential \
        autotools-dev \
        rsync \
        curl \
        cmake \
        wget \
        vim \
        tmux \
        htop \
        git \
        unzip \
        libnccl2 \
        libnccl-dev \
        ca-certificates \
        libjpeg-dev \
        htop \ 
        sudo \
        g++ \
        gcc \
        apt-utils \
        libosmesa6-dev \
        net-tools

# Install lib for video
RUN apt-get update && apt-get install -y software-properties-common
# RUN add-apt-repository -y ppa:jonathonf/ffmpeg-3
RUN add-apt-repository -y ppa:jonathonf/ffmpeg-4
RUN apt update && apt-get install -y libavformat-dev libavcodec-dev libswscale-dev libavutil-dev libswresample-dev libsm6 
RUN apt-get install -y ffmpeg
RUN export LIBRARY_PATH=/usr/local/lib:$LIBRARY_PATH

# Set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# # Get Conda-ified Python.
# # RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
# RUN wget --quiet https://repo.continuum.io/archive/Anaconda3-5.1.0-Linux-x86_64.sh -O ~/anaconda.sh && \
#     sh ~/anaconda.sh -b -p /opt/conda && \
#     rm ~/anaconda.sh && \
#     ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
#     echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
#     echo "conda activate base" >> ~/.bashrc
# #     echo "export PATH=/opt/conda/bin:$PATH" >> ~/.bashrc && \
# #     echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh
    
# RUN /bin/bash -c "source ~/.bashrc"
# ENV PATH /opt/conda/bin:$PATH
# RUN conda update -n base conda

ENV PATH /opt/miniconda/bin:$PATH

# Install general libraries
RUN conda install -y python=3.6 numpy pyyaml scipy ipython mkl scikit-learn matplotlib pandas setuptools Cython h5py graphviz
RUN conda clean -ya
RUN conda install -y mkl-include cmake cffi typing cython
RUN conda install -y -c mingfeima mkldnn
RUN pip install boto3 addict tqdm regex pyyaml opencv-python tensorboardX torchsummary
RUN pip install --upgrade pip


# Set CUDA_ROOT
RUN export CUDA_HOME="/usr/local/cuda"

# Install pytorch
# RUN conda install -y pytorch torchvision=0.4.2 cudatoolkit=10.0 -c pytorch
# RUN conda install -y -c conda-forge pillow=6.2.1
RUN conda install -y pytorch torchvision cudatoolkit=10.0 -c pytorch


# Install horovod
RUN HOROVOD_GPU_ALLREDUCE=NCCL pip install --no-cache-dir horovod==0.18.2
# RUN HOROVOD_GPU_ALLREDUCE=MPI HOROVOD_GPU_ALLGATHER=MPI HOROVOD_GPU_BROADCAST=MPI pip install --no-cache-dir horovod
# RUN ldconfig /usr/local/cuda/targets/x86_64-linux/lib/stubs && \
#     HOROVOD_GPU_ALLREDUCE=NCCL HOROVOD_GPU_BROADCAST=NCCL pip install --no-cache-dir horovod && \
#     ldconfig


# Install apex
WORKDIR $STAGE_DIR
RUN pip uninstall -y apex || :
# SHA is something the user can touch to force recreation of this Docker layer,
# and therefore force cloning of the latest version of Apex
# RUN SHA=ToUcHMe git clone https://github.com/NVIDIA/apex.git
RUN git clone https://github.com/NVIDIA/apex
WORKDIR $STAGE_DIR/apex
RUN python setup.py install --cuda_ext --cpp_ext
WORKDIR $STAGE_DIR
RUN rm -rf apex

RUN git clone https://github.com/dukebw/lintel.git && \
    cd lintel && pip install . && \
    cd .. && rm -rf lintel
# https://github.com/xvjiarui/lintel.git && \

#RUN git clone https://github.com/v-wewei/Pytorch-Correlation-extension.git && \
#    cd Pytorch-Correlation-extension && python setup.py install && \
#    cd .. && rm -rf Pytorch-Correlation-extension
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod/ xenial main" > azure.list && \
    cp ./azure.list /etc/apt/sources.list.d/ && \
    apt-key adv --keyserver packages.microsoft.com --recv-keys EB3E94ADBE1229CF && \
    apt-get update && apt-get install azcopy
