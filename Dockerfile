# Tag: nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04


# FROM nvidia/cuda@sha256:853e4cbf7c48bbfa04977bc5998d4b60f3310692446184230649d7fdc053fd44

# USER root:root

# ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
# ENV DEBIAN_FRONTEND noninteractive
# ENV LD_LIBRARY_PATH "/usr/local/cuda/extras/CUPTI/lib64:${LD_LIBRARY_PATH}"

# # Install Common Dependencies
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends \
#     # SSH and RDMA
#     libmlx4-1 \
#     libmlx5-1 \
#     librdmacm1 \
#     libibverbs1 \
#     libmthca1 \
#     libdapl2 \
#     dapl2-utils \
#     openssh-client \
#     openssh-server \
#     iproute2 && \
#     # Others
#     apt-get install -y \
#     build-essential \
#     bzip2 \
#     git=1:2.7.4-0ubuntu1.6 \
#     wget \
#     cpio && \
#     apt-get clean -y && \
#     rm -rf /var/lib/apt/lists/*

# # # Conda Environment
# # ENV MINICONDA_VERSION 4.5.11
# # ENV PATH /opt/miniconda/bin:$PATH
# # RUN wget -qO /tmp/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
# #     bash /tmp/miniconda.sh -bf -p /opt/miniconda && \
# #     conda clean -ay && \
# #     rm -rf /opt/miniconda/pkgs && \
# #     rm /tmp/miniconda.sh && \
# #     find / -type d -name __pycache__ | xargs rm -rf

# # Get Conda-ified Python.
# # RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
# RUN wget --quiet https://repo.continuum.io/archive/Anaconda3-5.1.0-Linux-x86_64.sh -O ~/anaconda.sh && \
#     sh ~/anaconda.sh -b -p /opt/conda && \
#     rm ~/anaconda.sh && \
#     ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
#     echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
# #     echo "conda activate base" >> ~/.bashrc
# #     echo "export PATH=/opt/conda/bin:$PATH" >> ~/.bashrc && \
# #     echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh
    
# # RUN /bin/bash -c "source ~/.bashrc"
# ENV PATH /opt/conda/bin:$PATH
# RUN conda update -n base conda


# # Intel MPI installation
# ENV INTEL_MPI_VERSION 2018.3.222
# ENV PATH $PATH:/opt/intel/compilers_and_libraries/linux/mpi/bin64
# RUN cd /tmp && \
#     wget -q "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/13063/l_mpi_${INTEL_MPI_VERSION}.tgz" && \
#     tar zxvf l_mpi_${INTEL_MPI_VERSION}.tgz && \
#     sed -i -e 's/^ACCEPT_EULA=decline/ACCEPT_EULA=accept/g' /tmp/l_mpi_${INTEL_MPI_VERSION}/silent.cfg && \
#     cd /tmp/l_mpi_${INTEL_MPI_VERSION} && \
#     ./install.sh -s silent.cfg --arch=intel64 && \
#     cd / && \
#     rm -rf /tmp/l_mpi_${INTEL_MPI_VERSION}* && \
#     rm -rf /opt/intel/compilers_and_libraries_${INTEL_MPI_VERSION}/linux/mpi/intel64/lib/debug* && \
#     echo "source /opt/intel/compilers_and_libraries_${INTEL_MPI_VERSION}/linux/mpi/intel64/bin/mpivars.sh" >> ~/.bashrc


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
# #     echo "conda activate base" >> ~/.bashrc
# #     echo "export PATH=/opt/conda/bin:$PATH" >> ~/.bashrc && \
# #     echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh
    
# # RUN /bin/bash -c "source ~/.bashrc"
# ENV PATH /opt/conda/bin:$PATH
# RUN conda update -n base conda

# very important!!!!!!!
RUN ln -s /opt/miniconda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/miniconda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "export PATH=/opt/miniconda/bin:$PATH" >> ~/.bashrc
# very important!!!!!!!
ENV PATH /opt/miniconda/bin:$PATH
RUN conda update -n base conda

# Install general libraries
RUN conda install -y python=3.6 numpy pyyaml scipy ipython mkl scikit-learn matplotlib pandas setuptools Cython h5py graphviz
RUN conda clean -ya
RUN conda install -y mkl-include cmake cffi typing cython
RUN conda install -y -c mingfeima mkldnn
RUN pip install boto3 addict tqdm regex pyyaml opencv-python tensorboardX torchsummary azureml_core azureml-sdk
RUN pip install --upgrade pip


# Set CUDA_ROOT
RUN export CUDA_HOME="/usr/local/cuda"

# Install pytorch
# RUN conda install -y pytorch torchvision cudatoolkit=10.0 -c pytorch
RUN conda install -y pytorch=1.3 torchvision=0.4.2 cudatoolkit=10.0 -c pytorch
RUN conda install -y -c conda-forge pillow=6.2.1


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
