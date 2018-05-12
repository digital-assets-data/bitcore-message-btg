FROM ubuntu:trusty

RUN apt-get update && apt-get install -y \
  g++ \
  libzmq3-dev \
  libzmq3-dbg \
  libzmq3 \
  make \
  python \
  software-properties-common \
  curl \
  build-essential \
  libssl-dev

RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
RUN apt-get install -y nodejs

RUN apt-get install -y \
  libtool \
  autotools-dev \
  automake \
  pkg-config \
  libssl-dev \
  libevent-dev \
  bsdmainutils \
  git

RUN add-apt-repository ppa:bitcoin/bitcoin -y
RUN apt-get update
RUN apt-get install -y libdb4.8-dev libdb4.8++-dev

RUN apt-get install -y \
  libboost-system-dev \
  libboost-filesystem-dev \
  libboost-chrono-dev \
  libboost-program-options-dev \
  libboost-test-dev \
  libboost-thread-dev

RUN git clone https://github.com/digital-assets-data/dash.git dashcore && \
  cd dashcore && \
  ./autogen.sh && \
  ./configure --without-gui && make

#PORT 3001 is for the api, 9998 is for dashd
EXPOSE 3001 9998

RUN npm config set package-lock false && npm install bitcore-node-dash

RUN ./node_modules/.bin/bitcore-node-dash create dash-node && \
  cd dash-node && \
  ./node_modules/.bin/bitcore-node-dash install insight-api-dash

RUN apt-get purge -y \
  g++ make python gcc && \
  apt-get autoclean && \
  apt-get autoremove -y

WORKDIR /dash-node
COPY bitcore-node-dash.json ./bitcore-node-dash.json

HEALTHCHECK --interval=120s --timeout=30s --retries=10 CMD curl -f http://localhost:3001/insight-api-dash/sync

ENTRYPOINT ["./node_modules/.bin/bitcore-node-dash", "start"]
