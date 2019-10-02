if [ ! -z "${AFP_USER}" ]; then
  deluser yuki
  adduser -D -H -u 101 -s /sbin/nologin -G tm -g tm ${AFP_USER}
  sed -i'' -e "s,%USER%,${AFP_USER:-},g" /etc/afp.conf
    if [ ! -z "${AFP_PASSWORD}" ]; then
      echo "${AFP_USER}:${AFP_PASSWORD}" | chpasswd
    fi
fi

find="find /data/ -type d -group 101 -name"

if [ -n $(${find} share-folder) ]; then 
  chgrp -R tm /data/share-folder
  chmod 770 $(find /data/share-folder -type d)
fi

if [ -n $(${find} time-machine) ]; then 
  chgrp -R tm /data/time-machine
  chmod 770 $(find /data/time-machine -type d)
fi

exec "$@"