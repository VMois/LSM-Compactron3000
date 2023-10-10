FROM openjdk:11

# Install SBT tool
ENV SBT_VERSION 1.9.0
RUN curl -L -o sbt-$SBT_VERSION.zip https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/sbt-$SBT_VERSION.zip && unzip sbt-$SBT_VERSION.zip -d ops
ENV PATH="/ops/sbt/bin/:${PATH}"

# Install Verilator
RUN apt-get update && apt-get install git make autoconf g++ flex bison -y
RUN git clone https://github.com/verilator/verilator /opt/verilator && cd /opt/verilator \
&& git pull && git checkout v4.226 
RUN cd /opt/verilator && unset VERILATOR_ROOT && autoconf && ./configure && make && make install

WORKDIR /design
