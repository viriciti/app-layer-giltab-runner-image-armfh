FROM armhf/alpine:3.5

ENV QEMU_EXECVE 1

ARG NPM_USER=xxx
ARG NPM_PASS=xxx
ARG NPM_EMAIL=xxx

ENV NPM_USER=${NPM_USER}
ENV NPM_PASS=${NPM_PASS}
ENV NPM_EMAIL=${NPM_EMAIL}

COPY . /usr/bin

RUN [ "qemu-arm-static", "/bin/sh", "-c", "ln -s resin-xbuild /usr/bin/cross-build-start; ln -s resin-xbuild /usr/bin/cross-build-end; ln /bin/sh /bin/sh.real" ]

RUN [ "cross-build-start" ]

RUN apk add --update \
	autoconf \
	jq \
	docker \
	build-base \
	curl \
	bash \
	ca-certificates \
	findutils \
	tar \
	nano \
	libcrypto1.0 \
	libssl1.0 \
	linux-headers \
	make gcc g++ python \
	&& rm -rf /var/cache/apk/*

ENV TERM xterm

ENV NODE_VERSION 6.10.0

# Install dependencies
RUN apk add --no-cache libgcc libstdc++ libuv

RUN curl -SLO "http://resin-packages.s3.amazonaws.com/node/v$NODE_VERSION/node-v$NODE_VERSION-linux-alpine-armhf.tar.gz" \
	&& echo "aa39e6fa304836c03e3581eda328f8e000edb1925433bb5cc4e8053d9aeb6fbe  node-v6.10.0-linux-alpine-armhf.tar.gz" | sha256sum -c - \
	&& tar -xzf "node-v$NODE_VERSION-linux-alpine-armhf.tar.gz" -C /usr/local --strip-components=1 \
	&& rm "node-v$NODE_VERSION-linux-alpine-armhf.tar.gz" \
	&& npm config set unsafe-perm true -g --unsafe-perm \
	&& rm -rf /tmp/*

RUN npm install -g node-gyp coffee-script npm-cli-login

RUN npm-cli-login -u $NPM_USER -p $NPM_PASS -e $NPM_EMAIL

RUN [ "cross-build-end" ]
