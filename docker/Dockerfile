## First stage (base)
FROM ruby:3.3.14-slim-bookworm AS base

RUN apt-get update && \
    apt-get install -y --no-install-recommends imagemagick libpng-dev libpq-dev libncurses-dev libffi-dev curl build-essential libssl-dev libreadline-dev zlib1g-dev zlib1g libsqlite3-dev libmagickwand-dev libxslt-dev ghostscript ntpdate nodejs file git && \
    rm -rf /var/lib/apt/lists/*

COPY . /opt/weby
WORKDIR /opt/weby

# Install bundler, dependency resolver
RUN gem install bundler -v '2.4.20'
# Bundle install
RUN bundle install --jobs 4 --retry 3 --without development test

## Second stage
FROM ruby:3.3.14-slim-bookworm

MAINTAINER DevOps Team "bd-sistemas.cercomp@ufg.br"

RUN apt-get update && \
    apt-get install -y --no-install-recommends tzdata imagemagick libpng-dev libpq-dev libmagickwand-dev ntpdate nodejs file && \
    rm -rf /var/lib/apt/lists/*

# Config time zones
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG CI_PROJECT_ENV
ARG CI_VERSION_ENV
ARG CI_COMMIT_SHORT_SHA
ARG RAILS_ENV
ARG SECRET_KEY_BASE

ENV CI_PROJECT_ENV $CI_PROJECT_ENV
ENV CI_VERSION_ENV $CI_VERSION_ENV
ENV CI_COMMIT_SHORT_SHA $CI_COMMIT_SHORT_SHA
ENV RAILS_ENV $RAILS_ENV
ENV SECRET_KEY_BASE $SECRET_KEY_BASE

COPY . /opt/weby
WORKDIR /opt/weby

# Files to logs and tmp
RUN mkdir -p tmp log
RUN touch log/error.log
RUN touch log/production.log
RUN ln -sf /dev/stderr log/error.log

# Copy files from first stage
COPY . /opt/weby
COPY --from=base /usr/local/bundle/ /usr/local/bundle/

# Env to system
ENV PATH=/opt/weby/bin:$PATH

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]
