# docker-debian-cuda - Debian 9 with CUDA Toolkit

FROM gw000/keras:2.1.1-gpu
MAINTAINER gw0 [http://gw.tnode.com/] <gw.2017@ena.one>

# install py2-tf-cpu/gpu (Python 2, TensorFlow, CPU/GPU)
# (already installed in upstream image)

# install py2-th-cpu (Python 2, Theano, CPU/GPU)
ARG THEANO_VERSION=1.0.0
ENV THEANO_FLAGS='device=cpu,floatX=float32'
RUN pip --no-cache-dir install git+https://github.com/Theano/Theano.git@rel-${THEANO_VERSION}

# install py2-cntk-cpu (Python 2, CNTK, CPU/GPU)
# requirements from old ubuntu repositories for cntk
RUN echo 'deb http://archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse' > /etc/apt/sources.list.d/ubuntu-16.04.list
RUN apt-get update -qq \
 && apt-get install --no-install-recommends -y \
    # other repositories
    ubuntu-archive-keyring \
 && apt-get install --no-install-recommends -y \
    # requirements for cntk
    openmpi-bin=1.10.2-8ubuntu1 \
    openmpi-common=1.10.2-8ubuntu1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
ARG CNTK_VERSION=2.3
ARG CNTK_DEVICE=CPU-Only
RUN pip --no-cache-dir install https://cntk.ai/PythonWheel/${CNTK_DEVICE}/cntk-${CNTK_VERSION}-cp27-cp27mu-linux_x86_64.whl

# install Keras for Python 2
# (already installed in upstream image)


# install py3-tf-cpu/gpu (Python 3, TensorFlow, CPU/GPU)
RUN apt-get update -qq \
 && apt-get install --no-install-recommends -y \
    # install python 3
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-virtualenv \
    python3-wheel \
    pkg-config \
    # requirements for numpy
    libopenblas-base \
    python3-numpy \
    python3-scipy \
    # requirements for keras
    python3-h5py \
    python3-yaml \
    python3-pydot \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ARG TENSORFLOW_VERSION=1.4.0
ARG TENSORFLOW_DEVICE=gpu
ARG TENSORFLOW_APPEND=_gpu
RUN pip3 --no-cache-dir install https://storage.googleapis.com/tensorflow/linux/${TENSORFLOW_DEVICE}/tensorflow${TENSORFLOW_APPEND}-${TENSORFLOW_VERSION}-cp35-cp35m-linux_x86_64.whl

# install py3-th-cpu/gpu (Python 3, Theano, CPU/GPU)
ARG THEANO_VERSION=1.0.0
ENV THEANO_FLAGS='device=cpu,floatX=float32'
RUN pip3 --no-cache-dir install git+https://github.com/Theano/Theano.git@rel-${THEANO_VERSION}

# install py3-cntk-cpu/gpu (Python 3, CNTK, CPU/GPU)
ARG CNTK_VERSION=2.3
ARG CNTK_DEVICE=GPU
RUN pip3 --no-cache-dir install https://cntk.ai/PythonWheel/${CNTK_DEVICE}/cntk-${CNTK_VERSION}-cp35-cp35m-linux_x86_64.whl

# install Keras for Python 3
ARG KERAS_VERSION=2.1.1
ENV KERAS_BACKEND=tensorflow
RUN pip3 --no-cache-dir install --no-dependencies git+https://github.com/fchollet/keras.git@${KERAS_VERSION}


# install additional debian packages
RUN apt-get update -qq \
 && apt-get install --no-install-recommends -y \
    # system tools
    less \
    procps \
    vim-tiny \
    # build dependencies
    build-essential \
    libffi-dev \
    # visualization (Python 2 and 3)
    python-matplotlib \
    python-pillow \
    python3-matplotlib \
    python3-pillow \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# install additional python packages
RUN pip --no-cache-dir install \
    # jupyter notebook and ipython (Python 2)
    ipython \
    ipykernel \
    jupyter \
    # data analysis (Python 2)
    pandas \
    scikit-learn \
    statsmodels \
 && python -m ipykernel.kernelspec \
 && pip3 --no-cache-dir install \
    # jupyter notebook and ipython (Python 3)
    ipython \
    ipykernel \
    # data analysis (Python 3)
    pandas \
    scikit-learn \
    statsmodels \
 && python3 -m ipykernel.kernelspec

# configure console
RUN echo 'alias ll="ls --color=auto -lA"' >> /root/.bashrc \
 && echo '"\e[5~": history-search-backward' >> /root/.inputrc \
 && echo '"\e[6~": history-search-forward' >> /root/.inputrc
# default password: keras
ENV PASSWD='sha1:98b767162d34:8da1bc3c75a0f29145769edc977375a373407824'

# quick test and dump package lists
RUN python -c "import tensorflow; print(tensorflow.__version__)" \
 && python -c "import theano; print(theano.__version__)" \
 && python -c "import cntk; print(cntk.__version__)" \
 && python3 -c "import tensorflow; print(tensorflow.__version__)" \
 && python3 -c "import theano; print(theano.__version__)" \
 && python3 -c "import cntk; print(cntk.__version__)" \
 && dpkg-query -l > /dpkg-query-l.txt \
 && pip2 freeze > /pip2-freeze.txt \
 && pip3 freeze > /pip3-freeze.txt

# for jupyter
EXPOSE 8888
# for tensorboard
EXPOSE 6006

WORKDIR /srv/
CMD /bin/bash -c 'jupyter notebook --no-browser --ip=* --NotebookApp.password="$PASSWD" "$@"'
