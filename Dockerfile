FROM nginx:1.31-alpine

COPY start.sh /usr/local/bin/

RUN apk add --update bash \
	&& rm -rf /var/cache/apk/* \
	&& chmod -R g+w        /var/cache/nginx /var/log/nginx /etc/nginx \
	&& chown -R nginx:root /var/cache/nginx /var/log/nginx /etc/nginx \
	&& chmod g+w /run \
	&& sed -i 's/user  nginx;//g' /etc/nginx/nginx.conf \
    && touch /run/nginx.pid \
    && chown -R nginx:root /run/nginx.pid \
	&& chmod +x /usr/local/bin/start.sh

EXPOSE 8080

USER nginx

CMD ["start.sh"]
