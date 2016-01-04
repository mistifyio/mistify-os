FROM ubuntu:trusty

ENTRYPOINT ["/build.sh"]

RUN apt-get update -y && \
	apt-get install -y \
		autoconf \
		bc \
		bison \
		flex \
		g++ \
		gawk \
		gcc \
		gcc-multilib \
		git \
		gperf \
		libtool \
		make \
		mercurial \
		ncurses-dev \
		openssh-server \
		pv \
		subversion \
		texinfo \
		unzip \
		xz-utils \
		&& \
	apt-get autoremove -y && apt-get autoclean -y

VOLUME ["/downloads"]
VOLUME ["/mistify-os"]
VOLUME ["/toolchains"]

RUN useradd -mU builder
RUN echo 'builder:builder' | chpasswd
RUN mkdir /build
RUN chgrp builder /build /downloads /toolchains
RUN chmod g+w /build

WORKDIR /build
USER builder

ADD build.sh /
