FROM debian:bookworm

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential automake autoconf git unzip \
      libodbc1 libsctp1 libwxgtk3.2-1 libwxgtk-webview3.2 \
      unixodbc-dev libsctp-dev libwxgtk-webview3.2-dev \
      libncurses5-dev openssl libssl-dev ca-certificates \
      libarchive-dev libconfuse-dev libtool \
      squashfs-tools ssh-askpass pkg-config curl libmnl-dev && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.11.0
RUN echo -e '\n. $HOME/.asdf/asdf.sh' >> $HOME/.bashrc && source $HOME/.bashrc

ENV KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac"

RUN source ~/.bashrc && \
    asdf plugin-add erlang && \
    asdf plugin-add elixir && \
    asdf install erlang 26.0.2 && \
    asdf install elixir 1.15.4-otp-26 && \
    asdf global erlang 26.0.2 && \
    asdf global elixir 1.15.4-otp-26

ENV FWUP_VERSION="1.10.1"

RUN cd /usr/src && \
    git clone https://github.com/fwup-home/fwup.git && \
    cd fwup && \
    git checkout v${FWUP_VERSION}

WORKDIR /usr/src/fwup

RUN ./scripts/download_deps.sh && \
    ./scripts/build_deps.sh && \
    ./autogen.sh
ENV PKG_CONFIG_PATH=/usr/src/fwup/build/host/deps/usr/lib/pkgconfig
RUN ./configure --enable-shared=no && \
    make && \
    make install

RUN source ~/.bashrc && mix local.hex
RUN source ~/.bashrc && mix local.rebar

RUN source ~/.bashrc && mix archive.install hex nerves_bootstrap

ENV MIX_TARGET=rpi0
WORKDIR /usr/src/blinker

COPY . .
CMD ["bash"]
