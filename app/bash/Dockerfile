FROM rust:latest AS htmlq-builder

RUN cargo install htmlq

FROM public.ecr.aws/lambda/provided:al2023 AS installer
RUN dnf install -y pcre2-tools perl && \
    cp /usr/bin/pcre2grep /tmp/pcre2grep && \
    cp /usr/bin/perl /tmp/perl


# FROM ghcr.io/ql4b/lambda-shell-runtime:tiny-latest
FROM lambda-shell-runtime:tiny

WORKDIR /var/task

# needed by lambda runtime
ENV HOME=/tmp

# Copy htmlq from the builder stage
COPY --from=htmlq-builder /usr/local/cargo/bin/htmlq /var/task/bin/htmlq
COPY --from=installer /tmp/pcre2grep /usr/bin/pcre2grep
COPY --from=installer /tmp/perl /usr/bin/perl
# Copy perl runtime dependencies
COPY --from=installer /lib64/libperl.so.5.32 /lib64/
COPY --from=installer /lib64/libc.so.6 /lib64/
COPY --from=installer /lib64/libm.so.6 /lib64/
COPY --from=installer /lib64/libcrypt.so.2 /lib64/
COPY --from=installer /lib/ld-linux-aarch64.so.1 /lib/

COPY ./src/router.sh router.sh
COPY ./src/functions.sh handler.sh