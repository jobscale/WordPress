FROM nginx
WORKDIR /usr/share/nginx
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y tzdata \
 ghostscript exif libmagickwand-dev \
 $(apt-cache search php | grep ^php7.3 | awk '{print $1}')  \
 lsb-release curl git vim zip unzip
RUN rm -fr /var/lib/apt/lists/*
RUN { \
  echo 'opcache.memory_consumption=128'; \
  echo 'opcache.interned_strings_buffer=8'; \
  echo 'opcache.max_accelerated_files=4000'; \
  echo 'opcache.revalidate_freq=2'; \
  echo 'opcache.fast_shutdown=1'; \
 } >> /etc/php/7.3/fpm/conf.d/10-opcache.ini
RUN { \
	echo 'error_reporting = E_ERROR | E_WARNING | E_PARSE | E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_COMPILE_WARNING | E_RECOVERABLE_ERROR'; \
	echo 'display_errors = Off'; \
	echo 'display_startup_errors = Off'; \
	echo 'log_errors = On'; \
	echo 'error_log = /dev/stderr'; \
	echo 'log_errors_max_len = 1024'; \
	echo 'ignore_repeated_errors = On'; \
	echo 'ignore_repeated_source = Off'; \
	echo 'html_errors = Off'; \
 } > /etc/php/7.3/fpm/conf.d/90-error-logging.ini
RUN echo | pecl install imagick
RUN echo 'extension=imagick.so' > /etc/php/7.3/fpm/conf.d/40-imagick.ini
COPY default.conf /etc/nginx/conf.d/default.conf
COPY . public
RUN rm -fr html && ln -sfn public html && chown -R nginx. .
RUN sed -i -e 's/www-data/nginx/' /etc/php/7.3/fpm/pool.d/www.conf
EXPOSE 80
CMD ["bash", "-c", "/etc/init.d/php7.3-fpm start && /etc/init.d/nginx start && tail -f /var/log/php7.3-fpm.log"]
