FROM ruby:2.7.4

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -\
  && apt-get update -qq && apt-get install -qq --no-install-recommends nodejs \
  && apt-get upgrade -qq \
  && npm install -g yarn@1

RUN apt-get install -y postgresql-client

WORKDIR /pupilfirst

# Ruby deps
COPY Gemfile /pupilfirst/Gemfile
COPY Gemfile.lock /pupilfirst/Gemfile.lock
RUN bundle install

# Nodejs deps
COPY package.json /pupilfirst/package.json
COPY yarn.lock /pupilfirst/yarn.lock
RUN NPM_CONFIG_PRODUCTION=false NOYARNPOSTINSTALL=1 yarn install

COPY . /pupilfirst
RUN cp /pupilfirst/config/database.production.yml /pupilfirst/config/database.yml

ENV RAILS_ENV="production"

RUN YARN_PRODUCTION=false AWS_ACCESS_KEY_ID=build AWS_SECRET_ACCESS_KEY=build AWS_BUCKET=build AWS_REGION=us-east-1 SECRET_KEY_BASE=1 rails assets:precompile

# Cleanup
RUN rm -rf /pupilfirst/node_modules
