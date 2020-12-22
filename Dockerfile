FROM ruby:2.7

COPY ./sources.list /etc/apt/sources.list
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
RUN bundle install

COPY . /app

EXPOSE 9000

ENTRYPOINT [ "/app/wait-for-postgres.sh" ]
CMD ["rake run:server"]
