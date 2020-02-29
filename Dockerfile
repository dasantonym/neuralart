FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04

# Install basic deps
RUN apt-get update && apt-get install -y sudo wget build-essential cmake curl gfortran git \
  libatlas-dev libavcodec-dev libavformat-dev libboost-all-dev libgtk2.0-dev libjpeg-dev \
  liblapack-dev libswscale-dev pkg-config python-dev python-pip software-properties-common \
  graphicsmagick libgraphicsmagick1-dev python-numpy zip

RUN git clone https://github.com/torch/distro.git /root/torch --recursive
RUN cd /root/torch && bash install-deps

RUN cd /root/torch && ./install.sh
RUN ln -s /root/torch/install/bin/* /usr/local/bin

RUN luarocks install cutorch
RUN luarocks install cunn
RUN luarocks install cudnn
RUN luarocks install inn

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# suppress message `tput: No value for $TERM and no -T specified`
ENV TERM xterm

COPY . /root/neuralart
WORKDIR /root/neuralart

RUN bash download_models.sh

ENTRYPOINT ["/usr/local/bin/qlua", "main.lua"]
CMD ["--style", "style.png", "--content", "content.png"]
