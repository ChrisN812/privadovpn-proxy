FROM alpine:3.15.0
LABEL MAINTAINER "Christopher Nallye"

ENV OVPN_FILES="https://privadovpn.com/apps/ovpn_configs.zip" \
    OVPN_CONFIG_DIR="/app/ovpn/config" \
    CRON="*/15 * * * *" \
    CRON_OVPN_FILES="@daily"\
    PROTOCOL="tcp"\
    USERNAME="" \
    PASSWORD="" \
    COUNTRY="" \
    LOAD=75 \
    RANDOM_TOP="" \
    LOCAL_NETWORK="" \
    REFRESH_TIME="120"

COPY app /app
EXPOSE 8118

RUN \
    echo "####### Installing packages #######" && \
    apk --update --no-cache add \
      privoxy \
      openvpn \
      runit \
      bash \
      jq \
      ncurses \
      curl \
      unzip \
      && \
    echo "####### Changing permissions #######" && \
      find /app -name run | xargs chmod u+x && \
      find /app -name *.sh | xargs chmod u+x \
      && \
    echo "####### Removing cache #######" && \
      rm -rf /var/cache/apk/*

CMD ["runsvdir", "/app"]

HEALTHCHECK --interval=1m --timeout=10s \
  CMD if [[ $( curl -x localhost:8118 https://www.privadovpn.com | jq -r '.["status"]' ) = "Protected" ]] ; then exit 0; else exit 1; fi
