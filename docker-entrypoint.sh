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

credentials="$(cat "$secret_dir/credentials")"
replicator="$(cat "$secret_dir/replicator")"
suffix="$(cat "$secret_dir/suffix")"

sed --regexp-extended \
  --expression="s/@CREDENTIALS@/$credentials/" \
  --expression="s/@GID@/$(id -g)/" \
  --expression="s/@REPLICATOR@/$replicator/" \
  --expression="s/@SUFFIX@/$suffix/" \
  --expression="s/@UID@/$(id -u)/" \
  "/etc/ldap/init/slapd.init.ldif" "/etc/ldap/init/slapd.$role.init.ldif" \
  | slapadd -F /etc/ldap/slapd.d -n 0

ulimit -n 1024
exec "$@"
