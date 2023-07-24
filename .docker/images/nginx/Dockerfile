ARG NGINX_VERSION
FROM nginx:${NGINX_VERSION}

ARG APP_CODE_PATH_CONTAINER
ARG CONTAINER_NAME

COPY  ./images/nginx/conf.d/site.conf /etc/nginx/conf.d/default.conf
RUN sed -i "s;__ROOT_PATH;$APP_CODE_PATH_CONTAINER;" /etc/nginx/conf.d/default.conf
RUN sed -i "s;__CONTAINER_NAME;$CONTAINER_NAME;" /etc/nginx/conf.d/default.conf
