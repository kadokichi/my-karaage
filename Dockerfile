FROM ruby:3.2.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /my-karaage
WORKDIR /my-karaage
ADD Gemfile /my-karaage/Gemfile
ADD Gemfile.lock /my-karaage/Gemfile.lock
RUN bundle install
ADD . /my-karaage
