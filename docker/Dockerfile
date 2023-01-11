## First stage
FROM ruby:2.7.5 AS builder

MAINTAINER DevOps Team "bd-sistemas.cercomp@ufg.br"

RUN apt-get clean && apt-get update && apt-get upgrade -y
RUN apt-get install -y git imagemagick libpng-dev libpq-dev libncurses5-dev libffi-dev curl build-essential libssl-dev libreadline6-dev zlib1g-dev zlib1g libsqlite3-dev libmagickwand-dev libreadline-dev libxslt-dev ghostscript ntpdate apt-utils nodejs

ARG CI_BRANCH_ENV
ARG RAILS_ENV
ARG SECRET_KEY_BASE
ARG STORAGE_BUCKET
ARG STORAGE_ACCESS_KEY
ARG STORAGE_ACCESS_SECRET
ARG STORAGE_HOST
ARG ASSETS_MANUAL_SYNC
ARG GITLAB_URO
ARG GITLAB_UROP
ARG CI_REPOSITORY_URL

ENV CI_BRANCH_ENV $CI_BRANCH_ENV
ENV RAILS_ENV $RAILS_ENV
ENV SECRET_KEY_BASE $SECRET_KEY_BASE
ENV STORAGE_BUCKET $STORAGE_BUCKET
ENV STORAGE_ACCESS_KEY $STORAGE_ACCESS_KEY
ENV STORAGE_ACCESS_SECRET $STORAGE_ACCESS_SECRET
ENV STORAGE_HOST $STORAGE_HOST
ENV ASSETS_MANUAL_SYNC $ASSETS_MANUAL_SYNC
ENV GITLAB_URO $GITLAB_URO
ENV GITLAB_UROP $GITLAB_UROP
ENV CI_REPOSITORY_URL $CI_REPOSITORY_URL

# --depth 1 skip downloading all the history up to that revision.
#RUN git clone --depth 1 --branch $CI_BRANCH_ENV https://$GITLAB_URO:$GITLAB_UROP@git.cercomp.ufg.br/sysadmin/weby.git /opt/weby
RUN git clone --depth 1 --branch $CI_BRANCH_ENV $CI_REPOSITORY_URL /opt/weby

WORKDIR /opt/weby

# Files to logs and tmp
RUN mkdir tmp
RUN mkdir log
RUN touch log/error.log
RUN ln -sf /dev/stderr log/error.log

# Install bundler, dependency resolver
RUN gem install bundler:1.16.3
# Bundle config
RUN bundle config without development:test
RUN bundle config path vendor/bundle
# Bundle install
RUN bundle install --without development test --path vendor/bundle --jobs 4 --retry 3

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

## Second stage
FROM ruby:2.7.5-slim-bullseye

RUN apt-get clean && apt-get update && apt-get upgrade -y
RUN apt-get install -y imagemagick libpng-dev libpq-dev libmagickwand-dev ntpdate nodejs

WORKDIR /opt/weby

COPY --from=builder /opt/weby /opt/weby
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

# Env to system
ENV PATH=/opt/weby/bin:/opt/weby/vendor/bundle/ruby/2.7.0/bin:$PATH

EXPOSE 3000:3000

CMD rails server -b 0.0.0.0 -p 3000
