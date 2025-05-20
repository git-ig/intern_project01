FROM postgres:16.8-alpine3.20

WORKDIR /db

COPY pgsql_restore.sh /db/
COPY 2024-08-19.dump /db/
COPY db_config.sh /db/
