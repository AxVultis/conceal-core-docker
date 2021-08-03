# conceal-core build

FROM ubuntu:20.04 AS build

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    apt-get install -y \
    gcc \
    g++ \
    git \
    cmake \
    libboost-system1.71-dev \
    libboost-filesystem1.71-dev \
    libboost-thread1.71-dev \
    libboost-date-time1.71-dev \
    libboost-chrono1.71-dev \
    libboost-serialization1.71-dev \
    libboost-regex1.71-dev \
    libboost-program-options1.71-dev

RUN git clone https://github.com/AxVultis/conceal-core -b elastic

WORKDIR /conceal-core/build

RUN cmake .. -DCMAKE_BUILD_TYPE=Release

RUN make -j2

# conceal-core installation

FROM ubuntu:20.04

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    libboost-filesystem1.71.0 \
    libboost-program-options1.71.0

COPY --from=build /conceal-core/build/src/conceald /opt/conceal-core/

EXPOSE 15000

EXPOSE 16000

ENTRYPOINT ["/opt/conceal-core/conceald"]

CMD ["-i", "--rpc-bind-ip", "0.0.0.0", "--log-file", "/dev/stdout"]