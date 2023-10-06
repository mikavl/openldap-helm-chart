#!/bin/bash

set -e
set -u

secret_dir="/etc/ldap/secret"

pod="$(hostname)"

if [[ "${pod#*-}" == "0" ]]; then
    role="provider"
else
    role="consumer"
fi

mkdir -p /var/lib/ldap/accesslog

manager="$(cat "$secret_dir/manager")"
manager_credentials="$(cat "$secret_dir/manager_credentials")"
replicator="$(cat "$secret_dir/replicator")"
replicator_credentials="$(cat "$secret_dir/replicator_credentials")"
suffix="$(cat "$secret_dir/suffix")"

sed --regexp-extended \
  --expression="s/@GID@/$(id -g)/" \
  --expression="s/@MANAGER@/$manager/" \
  --expression="s/@MANAGER CREDENTIALS@/$manager_credentials/" \
  --expression="s/@REPLICATOR@/$replicator/" \
  --expression="s/@REPLICATOR CREDENTIALS@/$replicator_credentials/" \
  --expression="s/@SUFFIX@/$suffix/" \
  --expression="s/@UID@/$(id -u)/" \
  "/etc/ldap/init/slapd.init.ldif" "/etc/ldap/init/slapd.$role.init.ldif" \
  | slapadd -F /etc/ldap/slapd.d -n 0

ulimit -n 1024
exec "$@"
