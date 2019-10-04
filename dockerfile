FROM alpine:3.10

LABEL maintainer="Yuki git@48763 <future.starshine@gmail.com>"

ENV NETATALK_VERSION 3.1.12

RUN set -x \
    && tempDir="$(mktemp -d)" \
    && netatalkPackages=" \
        db \
        libacl \
        tdb-libs \
        libattr \
        libevent \
        libgcrypt \
    " \
    && cd ${tempDir} \
    && wget https://nchc.dl.sourceforge.net/project/netatalk/netatalk/${NETATALK_VERSION}/netatalk-${NETATALK_VERSION}.tar.gz \
    && tar xf netatalk-${NETATALK_VERSION}.tar.gz \
    && cd netatalk-${NETATALK_VERSION} \
    && apk add --no-cache --virtual .build-deps \
        make \
        gcc \
        libc-dev \
        acl-dev \
        attr-dev \
        db-dev \
        libevent-dev \
        libgcrypt-dev \
        tdb-dev \
        file \
    && ./configure \
        --build=$CBUILD \
        --host=$CHOST \
        --prefix=/usr \
        --sysconfdir=/etc \
        --mandir=/usr/share/man \
        --localstatedir=/var \
        --disable-silent-rules \
        --disable-zeroconf \
        --disable-tcp-wrappers \
        --enable-overwrite \
        --without-libiconv \
        --without-pam \
        --with-shadow \
        --without-kerberos \
        --without-ldap \
        --with-acls \
        --without-libevent \
        --with-libevent-header=/usr/include \
        --with-libevent-lib=/usr/lib \
        --with-bdb=/usr \
        --without-tdb \
        --without-dtrace \
        --without-afpstats \
        --with-lockfile=/var/lock/netatalk \
    && make \
    && make install \
    && cd ${tempDir}/.. \
    && rm -rf ${tempDir} \
    && apk del .build-deps \
    && apk add --no-cache $netatalkPackages \ 
    && mkdir -p \
        /data/share-folder \
        /data/time-machine \
    && chmod 770 $(find /data/ -type d) \
    && chgrp -R 1000 /data

COPY ["afp.conf", "/etc/afp.conf"] 
COPY ["entrypoint.sh", "/etc/entrypoint.sh"]

EXPOSE 548 4700

CMD ["sh", "/etc/entrypoint.sh", "netatalk", "-d"]