FROM ruby:2.7.4

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -\
  && apt-get update -qq && apt-get install -qq --no-install-recommends \
  nodejs postgresql-client \
  && apt-get upgrade -qq \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*\
  && npm install -g yarn@1

WORKDIR /app

# Ruby deps
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

# Copy all files over.
COPY . /app

# Copy over the build database YAML file.
RUN cp /app/config/database.build.yml /app/config/database.yml

ENV RAILS_ENV="production"

# Asset precompilation will perform `yarn install` first; let's cleanup artifacts immediately afterwards.
RUN YARN_PRODUCTION=false AWS_ACCESS_KEY_ID=build AWS_SECRET_ACCESS_KEY=build AWS_BUCKET=build AWS_REGION=us-east-1 SECRET_KEY_BASE=1 rails assets:precompile \
  && rm -rf /app/node_modules
