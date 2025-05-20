#!/bin/sh
su postgres -c "initdb -D /var/lib/postgresql/data"
echo "host    schedule  postgres  172.16.0.0/12    md5" >> /var/lib/postgresql/data/pg_hba.conf
chown -R postgres: /db
su postgres -c"pg_ctl -D /var/lib/postgresql/data -l logfile start"
su postgres -c"psql -U postgres <<EOF
ALTER USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PASSWORD}';
CREATE DATABASE ${POSTGRES_DB} OWNER ${POSTGRES_USER};
EOF"
su ${POSTGRES_USER} -c"/bin/sh pgsql_restore.sh *.dump"
#su postgres -c "psql -U postgres -d ${POSTGRES_DB} -c 'DROP TABLE public.databasechangeloglock;'"
su postgres -c "psql -U postgres -d ${POSTGRES_DB} -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${POSTGRES_USER};'"
su postgres -c "psql -U postgres -d ${POSTGRES_DB} -c 'GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_USER};'"
su postgres -c "psql -U postgres -d ${POSTGRES_DB} -c 'UPDATE users SET token = NULL WHERE email = 'kotvtapochkax@mail.com';'"

