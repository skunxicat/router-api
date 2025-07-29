FROM rust:latest AS htmlq-builder

RUN cargo install htmlq

FROM public.ecr.aws/lambda/provided:al2023 AS installer
RUN dnf install -y pcre2-tools && \
    cp /usr/bin/pcre2grep /tmp/pcre2grep

FROM public.ecr.aws/lambda/provided:al2023 AS qrencode-builder

RUN dnf install -y \
    autoconf \
    automake \
    libtool \
    m4 \
    gettext \
    gcc \
    make \
    glibc-static \
    perl \
    wget \
    tar \
    pkgconfig

WORKDIR /build

# Download and extract source
RUN wget https://github.com/fukuchi/libqrencode/archive/refs/tags/v4.1.1.tar.gz && \
    tar xzf v4.1.1.tar.gz

WORKDIR /build/libqrencode-4.1.1

# Regenerate configure script (autotools)
RUN autoreconf -fiv && \
    ./configure LDFLAGS="-static -static-libgcc" CFLAGS="-static" --enable-static --disable-shared --disable-dependency-tracking && \
    make && \
    strip qrencode


# FROM ghcr.io/ql4b/lambda-shell-runtime:0.1.0-develop.18-tiny
# FROM public.ecr.aws/j5r7n1v7/lambda-shell-runtime:develop-tiny
FROM ghcr.io/ql4b/lambda-shell-runtime:tiny

WORKDIR /var/task

# needed by lambda runtime
ENV HOME=/tmp

# Copy htmlq from the builder stage
COPY --from=htmlq-builder /usr/local/cargo/bin/htmlq /var/task/bin/htmlq
COPY --from=installer /tmp/pcre2grep /usr/bin/pcre2grep
# Optionally 
COPY --from=qrencode-builder /build/libqrencode-4.1.1/qrencode /usr/local/bin/qrencode

COPY ./src/router.sh router.sh
COPY ./src/functions.sh handler.sh