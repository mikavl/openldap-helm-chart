#!/bin/bash

set -e
set -u

secrets_dir="/etc/ldap/secrets"

pod="$(hostname)"

if [[ "${pod#*-}" == "0" ]]; then
    role="provider"
else
    role="consumer"
fi

mkdir -p /var/lib/ldap/accesslog

credentials="$(cat "$secrets_dir/credentials")"
replicator="$(cat "$secrets_dir/replicator")"
suffix="$(cat "$secrets_dir/suffix")"

sed --regexp-extended \
  --expression="s/@CREDENTIALS@/$credentials/" \
  --expression="s/@REPLICATOR@/$replicator/" \
  --expression="s/@SUFFIX@/$suffix/" \
  "/etc/ldap/init/slapd.init.ldif" "/etc/ldap/init/slapd.$role.init.ldif" \
  | slapadd -F /etc/ldap/slapd.d -n 0

ulimit -n 1024
exec "$@"
