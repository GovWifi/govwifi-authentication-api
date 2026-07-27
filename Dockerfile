FROM ruby:3.4.10-alpine3.24
ARG BUNDLE_INSTALL_CMD
ENV RACK_ENV=development
ENV MARIADB_TLS_DISABLE_PEER_VERIFICATION=1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock .ruby-version ./

RUN apk --no-cache add --virtual .build-deps build-base && \
  apk --no-cache add mysql-dev && \
  ${BUNDLE_INSTALL_CMD} && \
  apk del .build-deps

COPY . .

CMD ["bundle", "exec", "puma", "-p", "8080", "--quiet", "--threads", "8:32"]
