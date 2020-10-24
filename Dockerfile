FROM coredevorg/stretch-sysutils
LABEL maintainer CoreDev IT
ARG ONLYOFFICE_VALUE=onlyoffice

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d && \
    apt-get -y update && apt-get -yq install \
        bomstrip libasound2 libboost-regex-dev libcairo2 libgconf2-4 libgtk-3-0 libnspr4 libnss3 \
        libstdc++6 libxss1 libxtst6 \
        mysql-client nginx-extras postgresql postgresql-client rabbitmq-server redis-server \
        software-properties-common supervisor xvfb zlib1g

RUN echo "SERVER_ADDITIONAL_ERL_ARGS=\"+S 1:1\"" | tee -a /etc/rabbitmq/rabbitmq-env.conf && \
    sed -i "s/bind .*/bind 127.0.0.1/g" /etc/redis/redis.conf && \
    sed 's|\(application\/zip.*\)|\1\n    application\/wasm wasm;|' -i /etc/nginx/mime.types && \
    # pg_conftool 10 main set listen_addresses 'localhost' && \
    service postgresql restart && \
    sudo -u postgres psql -c "CREATE DATABASE $ONLYOFFICE_VALUE;" && \
    sudo -u postgres psql -c "CREATE USER $ONLYOFFICE_VALUE WITH password '$ONLYOFFICE_VALUE';" && \
    sudo -u postgres psql -c "GRANT ALL privileges ON DATABASE $ONLYOFFICE_VALUE TO $ONLYOFFICE_VALUE;" && \ 
    service postgresql stop && \
    service redis-server stop && \
    service rabbitmq-server stop && \
    service supervisor stop && \
    service nginx stop && \
    rm -rf /var/lib/apt/lists/*

COPY config /app/ds/setup/config/
COPY run-document-server.sh /app/ds/run-document-server.sh

ARG REPO_URL="deb http://download.onlyoffice.com/repo/debian squeeze main"
ARG COMPANY_NAME=onlyoffice
ARG PRODUCT_NAME=documentserver

ENV COMPANY_NAME=$COMPANY_NAME \
    PRODUCT_NAME=$PRODUCT_NAME \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x8320ca65cb2de8e5 && \
    echo "$REPO_URL" | tee /etc/apt/sources.list.d/ds.list && \
    apt-get -y update && \
    service postgresql start && \
    apt-get -yq install $COMPANY_NAME-$PRODUCT_NAME && \
    service postgresql stop && \
    chmod 755 /app/ds/*.sh && \
    rm -rf /var/log/$COMPANY_NAME && \
    rm -rf /var/lib/apt/lists/*

VOLUME /var/log/$COMPANY_NAME /var/lib/$COMPANY_NAME /var/www/$COMPANY_NAME/Data /var/lib/postgresql /var/lib/rabbitmq /var/lib/redis /usr/share/fonts/truetype/custom
EXPOSE 80 443
ENTRYPOINT [ "/app/ds/run-document-server.sh" ]
