#!/bin/sh
set -e

source .venv/bin/activate

if [ $1 = "bhapi" ]
then
# Interpret this as a bhapi command and run through Flask
  exec flask --app "$@"
else
  exec "$@"
fi