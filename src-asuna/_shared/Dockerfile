ARG os
FROM buildpack-deps:$os

ARG os
ARG os_cache_date
RUN curl https://yuuki-deb.x86.men/public.key | apt-key add - &&\
    echo "deb http://yuuki-deb.x86.men/ $os main" > /etc/apt/sources.list.d/yuuki-deb.list &&\
    apt-get update &&\
    apt-get upgrade -y &&\
    apt-get install -y debhelper devscripts po-debconf dpkg-dev cmake nasm libnuma-dev avisynthplus-yuuki-dev vapoursynth-yuuki-dev liblsmash-yuuki-dev ruby &&\
    rm -rf /var/lib/apt/lists/*

WORKDIR /build/
SHELL ["/bin/bash", "-c"]
ARG os
ARG git_tag
ARG git_commit
RUN git clone https://github.com/msg7086/x265-Yuuki-Asuna.git x265 -b $git_tag

ARG rev=1
COPY debian x265/debian
RUN cd /build/x265 &&\
    dch --distribution $os -l +$os "Porting to $os" -m -t &&\
    for ((i=1; i<$rev; i++)); do dch --distribution $os -l +$os "Rebuild" -m -t; done &&\
    DEB_BUILD_OPTIONS="parallel=4" debian/rules binary &&\
    mkdir /build/reg &&\
    mv /build/*.deb /build/reg
