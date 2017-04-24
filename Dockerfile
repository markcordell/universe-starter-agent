FROM ubuntu:latest
#installs all of our requirements
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      cmake \
      curl \
      git \
      htop \
      lsof \
      make \
      tmux \
      wget \
      python3 \
      python3-dev \
      python3-pip \
      python3-setuptools \
      #requirements for opencv
      ibgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev \
      python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev \
      libtiff-dev libjasper-dev libdc1394-22-dev\
      #requirements for universe install
      libjpeg-turbo8-dev && \
      #clean up so we can reduce the size of the image
      rm -rf /var/lib/apt/lists/*
#installs just what we need from gym
RUN pip3 install "gym[atari]"
RUN pip3 install gym
#lets install go for the universe python package
ENV GOLANG_VERSION 1.8
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 53ab94104ee3923e228a2cb2116e5e462ad3ebaeea06ff04463479d7f12d27ca

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
#install the python requirements
RUN git clone https://github.com/openai/universe.git && cd universe && \
    pip3 install -e .
RUN pip3 install six
RUN pip3 install tensorflow
#install opencv here
RUN git clone https://github.com/opencv/opencv.git && \
    cd opencv && \
    git checkout tags/3.2.0 &&\
    mkdir release && cd release && \
    cmake -D CMAKE_BUILLD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local .. && \
    # make and install opencv and clean up afterwards
    make && make install && cd ../.. && rm -rf opencv/
RUN pip3 install --user numpy scipy matplotlib ipython jupyter pandas sympy nose
RUN git clone https://github.com/openai/universe-starter-agent.git
