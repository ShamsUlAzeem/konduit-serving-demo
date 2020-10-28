FROM continuumio/anaconda3:latest

RUN mkdir /root/konduit

ADD build /root/konduit/build
ADD demos /root/konduit/demos
ADD conf /root/konduit/conf
ADD bin /root/konduit/bin
ADD konduit.jar /root/konduit/konduit.jar

RUN . /opt/conda/bin/activate base

RUN conda config --env --add pinned_packages 'openjdk<8.0.265' && \
    conda config --env --add pinned_packages 'nodejs>=10.0.0' && \
    conda install -y -c conda-forge ipywidgets beakerx tensorflow keras pillow && \
    pip install onnx onnxruntime

RUN apt update && apt install -y procps curl tree && ps -ef && curl --help && tree --help

CMD ["/bin/bash"]

