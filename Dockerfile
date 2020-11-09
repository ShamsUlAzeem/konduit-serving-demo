FROM nvidia/cuda:11.0-devel-centos8

RUN mkdir /root/konduit

RUN yum update -y && yum install -y procps curl tree && \
    ps -ef && curl --help && tree --help

RUN curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p /opt/conda

RUN . /opt/conda/bin/activate base && \
    conda config --env --add pinned_packages 'openjdk<8.0.265' && \
    conda config --env --add pinned_packages 'nodejs>=10.0.0' && \
    conda install -y -c conda-forge python=3.7.9 ipywidgets beakerx tensorflow keras pillow && \
    pip install onnx onnxruntime

ADD build /root/konduit/build
ADD demos /root/konduit/demos
ADD conf /root/konduit/conf
ADD bin /root/konduit/bin
ADD konduit.jar /root/konduit/konduit.jar

CMD ["/bin/bash"]

