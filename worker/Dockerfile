FROM ruby:2.4

RUN mkdir /worker
COPY . /worker

RUN FOUND=`find /worker -name "slides" -or -name "exercises" -or -name "learning-path" -or -name "inception" -print` \
  && if [ ! -z "$FOUND" ]; then echo "Found $FOUND" && exit 1; fi

RUN apt-get update && apt-get install -y --no-install-recommends \
    mysql-client

WORKDIR worker

RUN gem install bundler \
  && bundle install

ENTRYPOINT ["bundle", "exec", "ruby", "lib/app.rb"]
