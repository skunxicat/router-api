FROM rust:latest AS htmlq-builder

RUN cargo install htmlq

FROM public.ecr.aws/lambda/provided:al2023 AS installer
RUN dnf install -y pcre2-tools && \
    cp /usr/bin/pcre2grep /tmp/pcre2grep

FROM ghcr.io/ql4b/lambda-shell-runtime:0.1.0-develop.18-tiny

WORKDIR /var/task

# needed by lambda runtime
ENV HOME=/tmp

# Copy htmlq from the builder stage
COPY --from=htmlq-builder /usr/local/cargo/bin/htmlq /var/task/bin/htmlq
COPY --from=installer /tmp/pcre2grep /usr/bin/pcre2grep

COPY ./src/router.sh router.sh
COPY ./src/functions.sh handler.sh