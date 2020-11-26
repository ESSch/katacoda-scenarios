FROM pytorch/pytorch AS dev
WORKDIR /workspace
ADD https://raw.githubusercontent.com/pytorch/tutorials/master/beginner_source/blitz/cifar10_tutorial.py /workspace
RUN pip install ipywidgets matplotlib
CMD ["/opt/conda/bin/python3", "/workspace/cifar10_tutorial.py"]
