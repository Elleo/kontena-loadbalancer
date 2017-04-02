FROM haproxy:1.5-alpine
MAINTAINER Kontena, Inc. <info@kontena.io>

ENV STATS_PASSWORD=secret \
    TINI_VERSION=v0.14.0 \
    PATH="/app/bin:${PATH}"

RUN apk update && apk --update add curl bash tzdata ruby ruby-irb ruby-bigdecimal \
    ruby-io-console ruby-json ruby-rake ca-certificates libssl1.0 openssl libstdc++ && \
    curl -sL -o /bin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-amd64 && \
    chmod +x /bin/tini

ADD Gemfile Gemfile.lock /app/

RUN apk --update add --virtual build-dependencies ruby-dev build-base openssl-dev && \
    gem install bundler --no-ri --no-rdoc && \
    cd /app ; bundle install --without development test && \
    apk del build-dependencies

ADD . /app
ADD errors/* /etc/haproxy/errors/
EXPOSE 80 443
WORKDIR /app

ENTRYPOINT ["/bin/tini", "--", "/app/entrypoint.sh"]
