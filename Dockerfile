FROM alpine:latest
RUN apk -U upgrade && apk add nginx && echo "daemon off;" >> /etc/nginx/nginx.conf && mkdir -p /usr/share/nginx/html && chown -R nginx:nginx /usr/share/nginx/html
COPY index.html /usr/share/nginx/html/index.html
COPY test.conf /etc/nginx/http.d/test.conf
EXPOSE 8080
CMD [ "nginx" ]