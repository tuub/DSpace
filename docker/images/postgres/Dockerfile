FROM postgres:9.4

# activate pgcrypto by default
COPY install-pgcrypto.sh /docker-entrypoint-initdb.d/

# install a postgres healthcheck for docker
COPY docker-healthcheck /usr/local/bin/
HEALTHCHECK CMD ["docker-healthcheck"]
