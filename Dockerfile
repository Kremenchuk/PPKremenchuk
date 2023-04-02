# Dockerfile.rails
FROM ruby:3.1.2 as stm_industry_toolbox

LABEL maintainer="stm-industry"

# Default directory
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  apt-get update -qq && \
  apt-get install -y vim nodejs sqlite3 libsqlite3-dev yarn && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /app
COPY . /app/
WORKDIR /app

RUN gem install bundler -v 2.3.26 && bundle install

RUN rails assets:precompile --trace

ENV RAILS_ENV production

