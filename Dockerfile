FROM ubuntu:18.04

COPY . .
RUN apt-get update && apt-get install -y \
   ruby-full ruby-dev mysql-client libmysqlclient-dev \
   unzip wget build-essential subversion ruby-bundler git libxml2-dev libxslt1-dev

RUN bundle install

EXPOSE 3000

CMD ["/bin/bash"]
