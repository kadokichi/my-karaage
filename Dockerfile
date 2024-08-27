FROM ruby:3.2.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs postgresql-client
RUN mkdir /my-karaage
WORKDIR /my-karaage
ADD Gemfile /my-karaage/Gemfile
ADD Gemfile.lock /my-karaage/Gemfile.lock
RUN bundle install
ADD . /my-karaage

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
