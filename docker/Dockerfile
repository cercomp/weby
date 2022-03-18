## First stage
FROM ruby:2.7.5 AS builder

MAINTAINER DevOps Team "bd-sistemas.cercomp@ufg.br"

RUN apt-get clean
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y git imagemagick curl build-essential ghostscript ntpdate apt-utils zlib1g zlib1g-dev libpq-dev \
libncurses5-dev libffi-dev libssl-dev libreadline6-dev libsqlite3-dev libmagickwand-dev libreadline-dev libxslt-dev 

# 2021-03-17
RUN git clone https://github.com/cercomp/weby /opt/weby # 2

WORKDIR /opt/weby

RUN git checkout develop 

# Files to logs and tmp
RUN mkdir tmp
RUN mkdir log
RUN touch log/error.log
RUN ln -sf /dev/stderr log/error.log

# Install bundler, dependency resolver
RUN gem install bundler:1.16.3
RUN bundle install --without development test --path vendor/bundle --jobs 4 --retry 3


## Second stage
from ruby:2.7.5-slim-bullseye
ARG RAILS_ENV
ARG SECRET_KEY_BASE
ARG STORAGE_BUCKET
ARG STORAGE_ACCESS_KEY
ARG STORAGE_ACCESS_SECRET
ARG STORAGE_HOST

RUN apt-get clean
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y imagemagick libpq-dev
RUN apt-get clean

WORKDIR /opt/weby

COPY --from=builder /opt/weby /opt/weby
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

ENV RAILS_ENV $RAILS_ENV
ENV SECRET_KEY_BASE $SECRET_KEY_BASE
ENV STORAGE_BUCKET $STORAGE_BUCKET
ENV STORAGE_ACCESS_KEY $STORAGE_ACCESS_KEY
ENV STORAGE_ACCESS_SECRET $STORAGE_ACCESS_SECRET
ENV STORAGE_HOST $STORAGE_HOST

# Env to system
ENV PATH=/opt/weby/bin:/opt/weby/vendor/bundle/ruby/2.7.0/bin:$PATH

# Move file to not acess db
RUN mv config/initializers/email.rb config/

# Assets precompile
RUN bundle exec rake assets:precompile --trace
RUN bundle exec rake assets:clean

# Cleanup
RUN cp public/assets/.sprockets-manifest-*.json .
RUN bundle exec rake assets:clobber
RUN mkdir public/assets
RUN cp .sprockets-manifest-*.json public/assets/

# Init before system up
RUN mv config/email.rb config/initializers/

# Bundle config
RUN bundle config without development:test:assets
RUN bundle config path vendor/bundle

EXPOSE 3000:3000

CMD rails server -b 0.0.0.0 -p 3000

