# Fast.ai - Dockerfile

# Inspired by - https://github.com/MattKleinsmith/dockerfiles/blob/master/fastai/Dockerfile
# Run Jupyter script was seen at: Floydhub - dl-docker: https://github.com/floydhub/dl-docker/blob/master/run_jupyter.sh
# Thanks to Seppe De Loore for the initial fastai installation steps when we needed them.

# Base image
FROM nvidia/cuda:9.2-runtime-ubuntu18.04

# Tools
RUN apt-get update --fix-missing && apt-get install -y \
	bzip2 \
	ca-certificates \
	curl \
	git \
	libjpeg-turbo8 \
	p7zip-full \
	software-properties-common \
	sudo \
	unzip \
	vim \
	wget \
&& rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN . /opt/conda/etc/profile.d/conda.sh

ENV PATH /opt/conda/bin:$PATH
ENV CONDA_AUTO_UPDATE_CONDA=false

# Fast.ai
COPY . /code
WORKDIR /code

RUN conda create -n run Python=3.6 -y && conda clean -ya && \
	/bin/bash -c "source activate run" && \
	apt-get install -y libjpeg-turbo8 && \
	pip install --upgrade pip && \
	conda install -c pytorch pytorch-nightly cuda92 -y && conda clean -ya  &&\
	conda install -c fastai torchvision-nightly -y && \
	conda install -c fastai fastai -y && \
	conda install jupyter -y

RUN jupyter notebook --generate-config --allow-root && \
	echo "c.NotebookApp.ip = '*'" >> ~/.jupyter/jupyter_notebook_config.py && \
	echo "c.NotebookApp.open_browser = False" >> ~/.jupyter_notebook_config.py

# Jupyter has issues running directly: https://github.com/ipython/ipython/issues/7062
COPY run_jupyter.sh /root/

# Expose Ports
EXPOSE 8888

ENTRYPOINT ["jupyter", "notebook", "--allow-root"]
