FROM ruby
RUN gem install jekyll bundler
RUN cd /home && jekyll new site
