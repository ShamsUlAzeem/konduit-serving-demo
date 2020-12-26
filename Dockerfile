ARG IMAGE

FROM ${IMAGE:-ubuntu:20.04}

ARG CONDA_CHIP_INSTALLS

ENV PATH "/root/miniconda/bin:/root/konduit/bin:$PATH"

RUN mkdir /root/konduit

ADD build /root/konduit/build
ADD demos /root/konduit/demos
ADD conf /root/konduit/conf
ADD bin /root/konduit/bin
ADD konduit.jar /root/konduit/konduit.jar

RUN apt clean && \
    apt update --fix-missing && \
    DEBIAN_FRONTEND=noninteractive && \
    apt install -y --no-install-recommends libglib2.0-0 && \
    apt install -y build-essential htop procps curl tree wget less libgl1-mesa-glx vim nano && \
    wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p $HOME/miniconda && \
    conda install -y -c conda-forge $CONDA_CHIP_INSTALLS python=3.7 openjdk=8 jupyterlab=1.2 beakerx keras pillow nodejs=10 && \
    pip install onnx onnxruntime opencv-python gpustat && \
    conda clean --all -y && \
    rm -rf /root/miniconda/pkgs

RUN NODE_OPTIONS=--max_old_space_size=4096 && \
    jupyter labextension install --minimize=False @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install --minimize=False beakerx-jupyterlab

CMD ["/bin/bash", "-c", "jupyter lab --notebook-dir=/root/konduit --ip='*' --port=8889 --no-browser --allow-root --LabApp.token='' --LabApp.terminado_settings='{\"shell_command\": [\"/bin/bash\"]}'"]

