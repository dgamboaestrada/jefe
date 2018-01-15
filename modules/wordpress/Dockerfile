FROM wordpress

# Install wp-cli
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x /usr/local/bin/wp
RUN echo 'alias wp="wp --allow-root"' >>  ~/.bashrc
