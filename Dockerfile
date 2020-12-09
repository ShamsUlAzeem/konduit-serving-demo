FROM ubuntu:20.04

RUN mkdir /root/konduit

ADD build /root/konduit/build
ADD demos /root/konduit/demos
ADD conf /root/konduit/conf
ADD bin /root/konduit/bin
ADD konduit.jar /root/konduit/konduit.jar

ENV PATH "/root/miniconda/bin:/root/konduit/bin:$PATH"

RUN apt update && \
    apt install -y procps curl tree wget less libgl1-mesa-glx libglib2.0-0 && \
    wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p $HOME/miniconda && \
    conda install -y -c conda-forge -c pytorch pytorch torchvision torchaudio cpuonly python=3.7 openjdk=8 jupyterlab=1.2 beakerx tensorflow keras pillow nodejs=10 && \
    pip install onnx onnxruntime opencv-python && \
    conda clean --all -y && \
    rm -rf /root/miniconda/pkgs

RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install beakerx-jupyterlab

CMD ["/bin/bash", "-c", "jupyter lab --notebook-dir=/root/konduit --ip='*' --port=8889 --no-browser --allow-root"]

