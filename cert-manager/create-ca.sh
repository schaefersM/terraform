#!/bin/bash

DOMAIN_NAME="$1"

openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj "/O=$DOMAIN_NAME Inc./CN=$DOMAIN_NAME" -keyout ca-cert/$DOMAIN_NAME.key -out ca-cert/$DOMAIN_NAME.crt

