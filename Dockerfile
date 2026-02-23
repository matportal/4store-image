FROM debian:bullseye-slim AS build

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git build-essential autoconf automake libtool pkg-config \
    bison flex gperf perl python3 \
    libglib2.0-dev libpcre3-dev libxml2-dev libcurl4-gnutls-dev \
    libraptor2-dev librasqal3-dev uuid-dev zlib1g-dev libncurses-dev libreadline-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth 1 https://github.com/4store/4store.git .

RUN ./autogen.sh \
 && CFLAGS="-fcommon" ./configure --prefix=/opt/4store \
 && make -j"$(nproc)" \
 && make install

FROM debian:bullseye-slim

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates bash procps \
    libglib2.0-0 libpcre3 libxml2 libcurl4 \
    libraptor2-0 librasqal3 uuid-runtime libreadline8 \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/4store /opt/4store
ENV PATH="/opt/4store/bin:${PATH}"

RUN mkdir -p /var/lib/4store /var/log/4store
WORKDIR /var/lib/4store

CMD ["bash", "-lc", "4s-backend-setup ontologies_api && 4s-backend ontologies_api && tail -f /dev/null"]
