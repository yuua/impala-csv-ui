FROM ruby:2.3.6

USER root

RUN gem install bundler

WORKDIR /app

COPY . ./

RUN mkdir csvs
RUN bundle install --path vendor/bundle

ENTRYPOINT ["bundle","exec","rackup","-o","0.0.0.0"]
