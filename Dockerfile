FROM ruby:2.7

WORKDIR /app

ADD Gemfile Gemfile.lock /app/

RUN bundle install

ADD . /app/
