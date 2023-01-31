FROM ruby:3.1.3-slim

RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
  build-essential \
  gnupg2 \
  less \
  git \
  libpq-dev \
  postgresql-client \
  libvips \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3

RUN gem install bundler

WORKDIR /usr/src/app

ENTRYPOINT ["./entrypoint.sh"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]