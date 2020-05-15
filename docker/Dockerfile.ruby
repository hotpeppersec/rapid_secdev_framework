FROM alpine:3.11
LABEL maintainer "Franklin Diaz <franklin@bitsmasher.net>"

ENV APP_ROOT /home/secdevops
WORKDIR ${APP_ROOT}
ENV BUILD_PACKAGES bash curl-dev ruby-dev build-base
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler

RUN apk update && \
    apk upgrade && \
    apk add $BUILD_PACKAGES && \
    apk add $RUBY_PACKAGES && \
    rm -rf /var/cache/apk/*

RUN gem install bundler ;\
cd ${APP_ROOT}/ruby && bundle install --without development test 
#apk del build-dependencies
#RUN chown -R nobody:nogroup /app
#USER nobody

