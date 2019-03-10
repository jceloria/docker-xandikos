FROM python:3-alpine

ENV DEBIAN_FRONTEND noninteractive
ENV PUID="nobody"
ENV PGID="nobody"
ENV autocreate="defaults"
ENV current_user_principal="/user1"

RUN apk --no-cache add gcc git linux-headers libc-dev && \
    pip3 install uwsgi xandikos && mkdir /data && \
    apk --no-cache del *-dev linux-headers gcc && rm -rf /var/cache/apk/*

EXPOSE 8000

VOLUME ["/data"]

CMD chown -R ${PUID}:${PGID} /data && \
    uwsgi --http-socket=:8000 \
    --umask=022 \
    --master \
    --cheaper=2 \
    --processes=4 \
    --plugin=python3 \
    --uid=$(getent passwd ${PUID}|cut -d: -f1) \
    --gid=$(getent group ${PGID}|cut -d: -f1) \
    --module=xandikos.wsgi:app \
    --env=XANDIKOSPATH=/data \
    --env=CURRENT_USER_PRINCIPAL=${current_user_principal} \
    --env=AUTOCREATE=${autocreate}
