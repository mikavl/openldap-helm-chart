FROM docker.io/library/debian:bookworm-slim

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
      apt-get install --assume-yes --no-install-recommends \
        ldap-utils \
        slapd \
 && rm -rf /etc/ldap/slapd.d \
      /run/slapd \
      /var/lib/apt/lists/* \
      /var/lib/ldap \
 && groupadd --gid 10000 slapd \
 && useradd --home-dir /nonexistent \
      --gid 10000 \
      --no-create-home \
      --no-user-group \
      --shell /bin/bash \
      --uid 10000 \
      slapd

COPY --chmod=0755 --chown=root:root docker-entrypoint.sh /usr/local/bin/
COPY --chmod=0644 --chown=root:root schema /etc/ldap/schema/

VOLUME ["/etc/ldap/init", "/etc/ldap/secret", "/etc/ldap/slapd.d", "/run/slapd", "/var/lib/ldap"]

USER slapd

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/sbin/slapd", "-d", "stats", "-F", "/etc/ldap/slapd.d", "-h", "ldapi:/// ldaps://0.0.0.0:10636/"]
