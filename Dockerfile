FROM ruby:2.5


WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

COPY . .

ENTRYPOINT cd /usr/src/myapp/trac-hub && bash

