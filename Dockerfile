FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

ENV apt_update="apt-get update"
ENV apt_upgrade="apt-get upgrade -y"
ENV apt_install="apt-get install -y --no-install-recommends --no-install-suggests"
ENV pip_install="pip3 install --no-input"
ENV pip_upgrade="pip3 install --upgrade --no-input"

RUN $apt_update
RUN $apt_install apt-utils --no-install-recommends --no-install-suggests

RUN $apt_upgrade

# Install python
RUN $apt_install python3
RUN $apt_install python3-pip
RUN $pip_upgrade pip

# Install clang format and lld (lld is faster than ld)...
RUN $apt_install \
	clang-format \
	lld

RUN $apt_install \
	gcc \
	g++ \
	gdb \
	build-essential

RUN mv /usr/bin/ld /usr/bin/ld.unused
RUN ln -s /usr/bin/lld /usr/bin/ld

# Install build tools...
RUN $apt_install \
	cmake \
	ninja-build
	
# Install code analysis, testing, logging, and performance tools...
RUN $apt_install \
	valgrind \
	libgtest-dev \
	libgoogle-glog-dev \
	libbenchmark-dev \
	google-mock \
	lcov \
	gcovr

# Install additional high level libraries
RUN $apt_install \
	libboost-all-dev

# Install comm layers
RUN $apt_install \
	libzmq3-dev \
	libmosquitto-dev \
	mosquitto \
	mosquitto-clients \
	libmosquitto-dev \
    libasio-dev \
    libtinyxml2-dev \
    libssl-dev \
    libp11-dev \
    libengine-pkcs11-openssl \
    softhsm2 \
    libpython3-dev \
    default-jdk \
    default-jre \
    swig \
    wget \
    unzip \
    git
    

RUN usermod -aG softhsm root

WORKDIR /
RUN mkdir Fast-DDS
WORKDIR Fast-DDS

RUN mkdir foonathan
WORKDIR foonathan
RUN git clone https://github.com/eProsima/foonathan_memory_vendor.git ./
RUN mkdir -p build
WORKDIR build
RUN cmake ../ -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_SHARED_LIBS=ON
RUN make -j18
RUN make install

WORKDIR /Fast-DDS
RUN mkdir cdr
WORKDIR cdr
RUN git clone https://github.com/eProsima/Fast-CDR.git ./
RUN mkdir build
WORKDIR build
RUN cmake ../ -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_SHARED_LIBS=ON
RUN make -j18
RUN make install

WORKDIR /Fast-DDS
RUN mkdir dds
WORKDIR dds
RUN git clone https://github.com/eProsima/Fast-DDS.git ./
RUN mkdir build
WORKDIR build
RUN cmake ../ -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_SHARED_LIBS=ON
RUN make -j18
RUN make install

WORKDIR /Fast-DDS
RUN mkdir ddsp
WORKDIR ddsp
RUN git clone https://github.com/eProsima/Fast-DDS-python.git ./
RUN mkdir build
WORKDIR build
RUN cmake ../fastdds_python -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_SHARED_LIBS=ON
RUN make -j18
RUN make install

WORKDIR /Fast-DDS
RUN mkdir ddsgen
WORKDIR ddsgen
RUN git clone --recursive https://github.com/eProsima/Fast-DDS-Gen.git ./
RUN ./gradlew assemble
RUN ./gradlew install

WORKDIR /
RUN rm -rf Fast-DDS
RUN echo "export LD_LIBRARY_PATH=/usr/local/lib" >> /root/.bashrc

# Install some command-line tools
RUN $apt_install \
    wget \
	git \
	vim \
	htop \
	atop \
	iotop \
	tmux \
	socat \
	jpnevulator \
	net-tools \
	tcpdump \
	linux-tools-common \
	linux-tools-generic \
	strace \
	ltrace \
	xxd

# Set some convenience options
RUN echo "set -g mouse on" >> /root/.tmux.conf
RUN echo "set -o vi" >> /root/.bashrc
RUN echo ":set tabstop=4" >> /root/.vimrc
RUN echo ":set expandtab" >> /root/.vimrc
RUN echo ":set shiftwidth=4" >> /root/.vimrc
RUN echo ":set autoindent" >> /root/.vimrc
RUN echo ":set smartindent" >> /root/.vimrc
RUN echo ":set mouse=a" >> /root/.vimrc
RUN echo ":set number" >> /root/.vimrc
RUN echo ":set ruler" >> /root/.vimrc

