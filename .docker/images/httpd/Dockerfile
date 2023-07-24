ARG HTTPD_VERSION
FROM httpd:${HTTPD_VERSION}

# httpd.conf
COPY  ./images/httpd/conf.d/httpd.conf /usr/local/apache2/conf/httpd.conf

ARG APP_CODE_PATH_CONTAINER
ARG APP_HOST
ARG HTTPD_HOST_HTTP_PORT

# httpd-vhosts.conf - default virtual host config
COPY  ./images/httpd/conf.d/httpd-vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf
RUN sed -i "s;__HTTPD_PORT;$HTTPD_HOST_HTTP_PORT;" /usr/local/apache2/conf/extra/httpd-vhosts.conf
RUN sed -i "s;__HTTPD_HOST;$APP_HOST;" /usr/local/apache2/conf/extra/httpd-vhosts.conf
RUN sed -i "s;__APP_CODE_PATH;$APP_CODE_PATH_CONTAINER;" /usr/local/apache2/conf/extra/httpd-vhosts.conf