# syntax=docker/dockerfile:1.3
FROM debian:buster-slim as guacd-builder

# Prefer to use Debian Backports
# https://backports.debian.org/
RUN echo 'deb http://deb.debian.org/debian buster-backports main' > /etc/apt/sources.list.d/backports.list

# Install guacd build dependencies
# https://github.com/apache/guacamole-server/blob/1.3.0/Dockerfile#L54
ARG TARGETPLATFORM
RUN --mount=type=cache,id=${TARGETPLATFORM}/var/cache/apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=${TARGETPLATFORM}/var/lib/apt,target=/var/lib/apt,sharing=private \
    apt-get update \
 && apt-get install -y --no-install-recommends -t buster-backports \
      autoconf            \
      automake            \
      freerdp2-dev        \
      gcc                 \
      libcairo2-dev       \
      libgcrypt-dev       \
      libjpeg62-turbo-dev \
      libossp-uuid-dev    \
      libpango1.0-dev     \
      libpulse-dev        \
      libssh2-1-dev       \
      libssl-dev          \
      libtelnet-dev       \
      libtool             \
      libvncserver-dev    \
      libwebsockets-dev   \
      libwebp-dev         \
      make

# Install packages to download guacamole-server
RUN --mount=type=cache,id=${TARGETPLATFORM}/var/cache/apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=${TARGETPLATFORM}/var/lib/apt,target=/var/lib/apt,sharing=private \
    apt-get update \
 && apt-get install -y --no-install-recommends -t buster-backports \
      ca-certificates \
      curl

# Download guacamole-server
ARG GUACD_VERSION
ARG GUACD_REPOSITORY=apache/guacamole-server
RUN curl -fsSL \ 
      https://github.com/${GUACD_REPOSITORY}/archive/refs/tags/${GUACD_VERSION}.tar.gz \
      -o guacamole-server.tar.gz \
 && mkdir -p /build \
 && tar -zxf guacamole-server.tar.gz -C /build --strip-components 1

# Build guacamole-server
# https://github.com/apache/guacamole-server/blob/1.3.0/Dockerfile#L89
# https://github.com/apache/guacamole-server/blob/1.3.0/Dockerfile#L91
RUN mkdir -p /usr/local/guacamole \
 && cp -r /build/src/guacd-docker/bin /usr/local/guacamole/bin \
 && /usr/local/guacamole/bin/build-guacd.sh /build /usr/local/guacamole \
 && /usr/local/guacamole/bin/list-dependencies.sh \
      /usr/local/guacamole/sbin/guacd \
      /usr/local/guacamole/lib/libguac-client-*.so \
      /usr/local/guacamole/lib/freerdp2/*guac*.so \
    > /usr/local/guacamole/DEPENDENCIES


#------------------------------------------------------------------------------------------------------------
FROM debian:buster-slim as runtime

ARG GUACD_VERSION
LABEL org.opencontainers.image.url https://github.com/orgs/fixpoint/packages/container/package/guacd
LABEL org.opencontainers.image.source https://github.com/fixpoint/guacd-docker
LABEL org.opencontainers.image.version $GUACD_VERSION
LABEL org.opencontainers.image.vendor Fixpoint, Inc.

# Prefer to use Debian Backports
# https://backports.debian.org/
RUN echo 'deb http://deb.debian.org/debian buster-backports main' > /etc/apt/sources.list.d/backports.list

# Runtime environment
ENV LC_ALL=C.UTF-8 \
    LD_LIBRARY_PATH=/usr/local/guacamole/lib \
    GUACD_LOG_LEVEL=info

COPY --from=guacd-builder /usr/local/guacamole /usr/local/guacamole

# Install runtime requirements
# https://github.com/apache/guacamole-server/blob/1.3.0/Dockerfile#L128
# https://github.com/apache/guacamole-server/blob/1.3.0/Dockerfile#L143
ARG TARGETPLATFORM
RUN --mount=type=cache,id=${TARGETPLATFORM}/var/cache/apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=${TARGETPLATFORM}/var/lib/apt,target=/var/lib/apt,sharing=private \
    apt-get update \
 && apt-get install -y --no-install-recommends -t buster-backports \
      netcat-openbsd \
      ca-certificates \
      ghostscript \
      fonts-liberation \
      fonts-dejavu \
      xfonts-terminus \
 && apt-get install -y --no-install-recommends -t buster-backports \
      $(cat /usr/local/guacamole/DEPENDENCIES) \
 && rm -rf /var/lib/apt/lists/*

# Link FreeRDP plugins into proper path
# https://github.com/apache/guacamole-server/blob/1.3.0/Dockerfile#L149
RUN /usr/local/guacamole/bin/link-freerdp-plugins.sh \
    /usr/local/guacamole/lib/freerdp2/libguac*.so

# Checks the operating status every 5 minutes with a timeout of 5 seconds
HEALTHCHECK --interval=5m --timeout=5s CMD nc -z 127.0.0.1 4822 || exit 1

# Create a new user guacd
ARG UID=1000
ARG GID=1000
RUN groupadd --gid $GID guacd \
 && useradd --system --create-home --shell /usr/sbin/nologin --uid $UID --gid $GID guacd

# Run with user guacd
USER guacd

# Expose the default listener port
EXPOSE 4822

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
