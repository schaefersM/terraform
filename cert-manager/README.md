# cert-manager
## create CA-Certificate
kubectl create secret tls own-ca --cert=schaefersm.com.crt --key=schaefersm.com.key -n cert-manager --dry-run=client -oyaml > own-ca.yaml
