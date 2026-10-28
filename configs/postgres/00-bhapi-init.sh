#!/bin/bash
set -e

# Load bhapi password
export BHAPI_PASSWORD=`cat /run/secrets/pg-bhapi-password`

psql -v ON_ERROR_STOP=1 --username="$POSTGRES_USER" --dbname="$POSTGRES_DB" <<-EOSQL
\set bhapipw `cat /run/secrets/pg-bhapi-password`
CREATE ROLE bhapi WITH LOGIN PASSWORD :'bhapipw';
CREATE DATABASE bhapi OWNER bhapi;

EOSQL