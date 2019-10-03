if [ -n "${GROUP}" -o -n "${GID}" ]; then

  if [ -z "${GROUP}" ]; then 
    echo "tmp error message: GROUP"
    exit 1
  fi

  if [ -n "${GID}" ]; then
    addgroup -g ${GID} ${GROUP}
  else
    addgroup -g 1000 ${GROUP}
  fi
  
else 
  addgroup -g 1000 tm
fi

if [ -n "${USER}" -o -n "${UID}" ]; then

  if [ -z "${USER}" ]; then 
    echo "tmp error message: USER"
    exit 1
  fi

  if [ -n "${UID}" ]; then

    if [ -n "${GROUP}" ]; then 
      adduser -D -u ${UID} -s /sbin/nologin -G ${GROUP} -g ${GROUP} ${USER}
    else
      adduser -D -u ${UID} -s /sbin/nologin -G tm -g tm ${USER}
    fi

  else 
      adduser -D -u 1000 -s /sbin/nologin -G tm -g tm ${USER}
  fi

else 
  adduser -D -u 1000 -s /sbin/nologin -G tm -g tm yuki
fi

if [ -n "${PASSWORD}" ]; then
  if [ -n "{USER}" ]; then 
    echo "${USER}:${PASSWORD}" | chpasswd
  else
    echo "yuki:${PASSWORD}" | chpasswd
else
  echo "yuki:P@ssw0rd" | chpasswd
fi

if [ -z DISABLED]; then 

  if [ ! -e /data/share-folder ]; then
    mkdir /data/share-folder
  fi

  if [ ! -e /data/time-machine ]; then
    mkdir /data/share-folder
  fi

  FIND="find /data/ -type d -group 1000 -name"
  if [ -n "${GID}" ]; then
    FIND="find /data/ -type d -group ${GID} -name"
  fi

  if [ -z $(${FIND} share-folder) ]; then 
    if [ -n "${GID}" ]; then
      chgrp -R ${GID} /data/share-folder
    else
      chgrp -R 1000 /data/share-folder
    fi
  fi
  chmod -R g+rwx /data/share-folder

  if [ -z $(${FIND} time-machine) ]; then 
    if [ -n "${GID}" ]; then
      chgrp -R ${GID} /data/time-machine
    else
      chgrp -R 1000 /data/time-machine
    fi
  fi
  chmod g+rwx /data/time-machine

fi

exec "$@"