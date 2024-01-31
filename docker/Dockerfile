## First stage (base)
FROM ruby:2.7.5 AS base

RUN apt-get clean && apt-get update && apt-get upgrade -y
RUN apt-get install -y imagemagick libpng-dev libpq-dev libmagickwand-dev ntpdate nodejs

COPY . /opt/weby
WORKDIR /opt/weby

# Install bundler, dependency resolver
RUN gem install bundler -v '2.4.20'
# Bundle install
RUN bundle install --jobs 4 --retry 3 --without development test

## Second stage
FROM ruby:2.7.5-slim-bullseye

MAINTAINER DevOps Team "bd-sistemas.cercomp@ufg.br"

RUN apt-get clean && apt-get update && apt-get upgrade -y
RUN apt-get install -y tzdata imagemagick libpng-dev libpq-dev libmagickwand-dev ntpdate nodejs
#RUN apt-get install -y git imagemagick libpng-dev libpq-dev libncurses5-dev libffi-dev curl build-essential libssl-dev libreadline6-dev zlib1g-dev zlib1g libsqlite3-dev libmagickwand-dev libreadline-dev libxslt-dev ghostscript ntpdate apt-utils nodejs

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

WORKDIR /opt/weby

# Files to logs and tmp
RUN mkdir tmp
RUN mkdir log
RUN touch log/error.log
RUN touch log/production.log
RUN ln -sf /dev/stderr log/error.log

# Copy files from first stage
COPY . /opt/weby
COPY --from=base /usr/local/bundle/ /usr/local/bundle/

# Env to system
ENV PATH=/opt/weby/bin:/opt/weby/vendor/bundle/ruby/2.7.0/bin:$PATH

EXPOSE 3000:3000

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]
