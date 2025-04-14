#!/bin/bash

# Eingabeparameter prüfen
if [ "$#" -ne 2 ]; then
  echo "Verwendung: $0 <Subdomain> <Domainname>"
  echo "Beispiel: $0 argocd schaefersm.com"
  exit 1
fi

SUBDOMAIN="$1"
DOMAIN_NAME="$2"
DOMAIN_NAME_CRT_PATH="$PWD/ca-cert/$DOMAIN_NAME.crt"
DOMAIN_NAME_KEY_PATH="$PWD/ca-cert/$DOMAIN_NAME.key"


# Überprüfen, ob das CA-Zertifikat existiert
if [ ! -f "$PWD/ca-cert/$DOMAIN_NAME.key" ]; then
  echo "Fehler: CA-Zertifikat '$DOMAIN_NAME' existiert nicht."
  exit 1
fi

# Arbeitsverzeichnis erstellen
WORKDIR="certs_$SUBDOMAIN.$DOMAIN_NAME"
mkdir -p "$WORKDIR"
cd "$WORKDIR" || exit 1

# Privaten Schlüssel für die Domain erstellen
openssl req -out $SUBDOMAIN.$DOMAIN_NAME.csr -newkey rsa:2048 -nodes -keyout $SUBDOMAIN.$DOMAIN_NAME.key -subj "/CN=$SUBDOMAIN.$DOMAIN_NAME/O=$SUBDOMAIN from $DOMAIN_NAME"

# Self-Signed Zertifikat mit dem CA-Zertifikat signieren
openssl x509 -req -days 365 -CA $DOMAIN_NAME_CRT_PATH -CAkey $DOMAIN_NAME_KEY_PATH -set_serial 0 -in $SUBDOMAIN.$DOMAIN_NAME.csr -out $SUBDOMAIN.$DOMAIN_NAME.crt

# Kubernetes Secret erstellen
kubectl create -n istio-system secret tls "$SUBDOMAIN.$DOMAIN_NAME-credential" \
  --key="$SUBDOMAIN.$DOMAIN_NAME.key" \
  --cert="$SUBDOMAIN.$DOMAIN_NAME.crt" --dry-run=client -oyaml | kubectl apply -f -
echo "✅ Zertifikat und Secret für '$DOMAIN_NAME' wurden erfolgreich erstellt."

cd ..
rm -rf "$WORKDIR"
