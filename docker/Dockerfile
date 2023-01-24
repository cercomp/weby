## First stage (base)
FROM ruby:2.7.5 AS base

RUN apt-get clean && apt-get update && apt-get upgrade -y
RUN apt-get install -y git imagemagick libpng-dev libpq-dev libncurses5-dev libffi-dev curl build-essential libssl-dev libreadline6-dev zlib1g-dev zlib1g libsqlite3-dev libmagickwand-dev libreadline-dev libxslt-dev ghostscript ntpdate apt-utils nodejs

ARG CI_COMMIT_SHORT_SHA
ARG RAILS_ENV
ARG SECRET_KEY_BASE

ENV CI_COMMIT_SHORT_SHA $CI_COMMIT_SHORT_SHA
ENV RAILS_ENV $RAILS_ENV
ENV SECRET_KEY_BASE $SECRET_KEY_BASE

COPY . /opt/weby
WORKDIR /opt/weby

# Files to logs and tmp
RUN mkdir tmp
RUN mkdir log
RUN touch log/error.log
RUN ln -sf /dev/stderr log/error.log

# Install bundler, dependency resolver
RUN gem install bundler
# Bundle install
RUN bundle install --jobs 4 --retry 3

## Second stage (publish)
FROM ruby:2.7.5-slim-bullseye

MAINTAINER DevOps Team "bd-sistemas.cercomp@ufg.br"

RUN apt-get clean && apt-get update && apt-get upgrade -y
RUN apt-get install -y imagemagick libpng-dev libpq-dev libmagickwand-dev ntpdate nodejs

WORKDIR /opt/weby

# Copy files from first stage
COPY --from=base /opt/weby /opt/weby
COPY --from=base /usr/local/bundle/ /usr/local/bundle/

# Env to system
ENV PATH=/opt/weby/bin:/opt/weby/vendor/bundle/ruby/2.7.0/bin:$PATH

EXPOSE 3000:3000

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]
