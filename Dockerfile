FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04

# Install basic deps
RUN apt-get update && apt-get install -y sudo wget build-essential cmake curl gfortran git \
  libatlas-dev libjpeg-dev \
  liblapack-dev libswscale-dev pkg-config python-dev python-pip software-properties-common \
  graphicsmagick libgraphicsmagick1-dev python-numpy zip \
  && apt-get autoremove -y && apt clean

RUN git clone https://github.com/torch/distro.git /root/torch --recursive
RUN cd /root/torch && bash install-deps && apt-get autoremove -y && apt clean

RUN cd /root/torch && ./install.sh && rm -rf ./build /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN ln -s /root/torch/install/bin/* /usr/local/bin

RUN luarocks install cutorch
RUN luarocks install cunn
RUN luarocks install cudnn
RUN luarocks install inn

# suppress message `tput: No value for $TERM and no -T specified`
ENV TERM xterm

COPY . /root/neuralart
WORKDIR /root/neuralart

RUN bash download_models.sh

ENTRYPOINT ["/usr/local/bin/qlua", "main.lua", "--display_interval", "0"]
CMD ["--style", "/root/neuralart/style.png", "--content", "/root/neuralart/content.png"]
