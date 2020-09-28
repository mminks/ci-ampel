FROM ruby:latest

WORKDIR /app

ADD Gemfile Gemfile.lock /app/

RUN bundle install

ADD . /app/
