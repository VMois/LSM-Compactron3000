FROM openjdk:11

ENV SBT_VERSION 1.9.0
RUN curl -L -o sbt-$SBT_VERSION.zip https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/sbt-$SBT_VERSION.zip && unzip sbt-$SBT_VERSION.zip -d ops
ENV PATH="/ops/sbt/bin/:${PATH}"
WORKDIR /design
