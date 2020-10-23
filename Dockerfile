FROM continuumio/anaconda3:latest

RUN mkdir /root/konduit

ADD demos /root/konduit/demos
ADD conf /root/konduit/conf
ADD bin /root/konduit/bin
ADD konduit.jar /root/konduit/konduit.jar
ADD docs.md /root/konduit/docs.md

RUN . /opt/conda/bin/activate base

RUN conda config --env --add pinned_packages 'openjdk<8.0.265' && \
    conda config --env --add pinned_packages 'nodejs>=10.0.0' && \
    conda install -y -c conda-forge ipywidgets beakerx && \
    pip install onnx onnxruntime

RUN apt update && apt install -y procps curl && ps -ef && curl --help

CMD ["/bin/bash"]

