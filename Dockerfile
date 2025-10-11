FROM ibm-semeru-runtimes:open-25-jdk-noble AS jdk-base-amd64
FROM ibm-semeru-runtimes:open-25-jdk-noble AS jdk-base-arm64
FROM arm32v7/eclipse-temurin:17-jre-noble AS jdk-base-armv7

ARG TARGETARCH
ARG TARGETVARIANT
FROM jdk-base-${TARGETARCH}${TARGETVARIANT} AS jdk-selected

FROM ubuntu:noble AS jre-builder

ENV JAVA_HOME=/opt/java/openjdk
COPY --from=jdk-selected $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Install latest su-exec
RUN  set -ex; \
     fetch_deps='gcc libc-dev'; \
     apt-get update; \
     apt-get install -y --no-install-recommends binutils ca-certificates curl; \
     apt-get install -y --no-install-recommends $fetch_deps; \
     rm -rf /var/lib/apt/lists/*; \
     curl -o /usr/local/bin/su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c; \
     gcc -Wall \
         /usr/local/bin/su-exec.c -o/usr/local/bin/su-exec; \
     chown root:root /usr/local/bin/su-exec; \
     chmod 0755 /usr/local/bin/su-exec; \
     rm /usr/local/bin/su-exec.c; \
     \
     apt-get purge -y --auto-remove $fetch_deps

# 使用 jlink 创建一个只包含必要模块的自定义 JRE
RUN ARCH=$(dpkg --print-architecture) && \
        if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "arm64" ]; then \
          $JAVA_HOME/bin/jlink \
          --add-modules java.base,java.desktop,java.logging,java.naming,java.net.http,java.sql,java.sql.rowset,java.xml,jdk.httpserver,jdk.naming.dns,jdk.unsupported \
          --strip-debug \
          --no-header-files \
          --no-man-pages \
          --compress=zip-6 \
          --output /openjdk; \
        elif [ "$ARCH" = "armhf" ]; then \
          echo "Copying pre-built JRE for ${ARCH} (jlink is skipped)..." && \
          cp -r $JAVA_HOME /openjdk; \
        fi

FROM ubuntu:noble

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata curl ca-certificates fontconfig locales \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=jre-builder /openjdk /opt/java/openjdk
COPY --from=jre-builder /usr/local/bin/su-exec /usr/local/bin/su-exec

ENV JAVA_TOOL_OPTIONS="-XX:+IgnoreUnrecognizedVMOptions -XX:+IdleTuningGcOnIdle"
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV PUID=0 PGID=0 UMASK=022 TZ=Asia/Shanghai
