# If check arguments of user and uid not null, it delete default user.
if [ -n "${USER}" -o -n "${UID}" ]; then

  if [ -z "${USER}" ]; then 
    echo "tmp error message: USER"
    exit 1
  fi

  deluser yuki

fi

# If check arguments of group and gid not null, it delete default group.
if [ -n "${GROUP}" -o -n "${GID}" ]; then

  if [ -z "${GROUP}" ]; then 
    echo "tmp error message: GROUP"
    exit 1
  fi
    
  delgroup tm

fi

# If check arguments of group not null, it create group.
if [ -n "${GROUP}" ]; then 

  if [ -n "${GID}" ]; then
    addgroup -g ${GID} ${GROUP}
  else
    addgroup -g 1000 ${GROUP}
  fi

fi

# If check arguments of user not null, it create user.
if [ -n "${USER}" ]; then

  if [ -n "${UID}" ]; then

    if [ -n "${GROUP}" ]; then 
      adduser -D -u ${UID} -s /sbin/nologin -G ${GROUP} -g ${GROUP} ${USER}
    else
      adduser -D -u ${UID} -s /sbin/nologin -G tm -g tm ${USER}
    fi

  else 
    adduser -D -u 1000 -s /sbin/nologin -G tm -g tm ${USER}
  fi

  if [ -n "${PASSWORD}" ]; then
    echo "${USER}:${PASSWORD}" | chpasswd
  else
    echo "${USER}:P@ssw0rd" | chpasswd
  fi

fi

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
  
  chmod -R g+rwx /data/share-folder
  
fi

if [ -z $(${FIND} time-machine) ]; then 

  if [ -n "${GID}" ]; then
    chgrp -R ${GID} /data/time-machine
  else
    chgrp -R 1000 /data/time-machine
  fi

  chmod g+rwx /data/time-machine

fi

exec "$@"