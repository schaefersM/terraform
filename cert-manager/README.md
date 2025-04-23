# cert-manager
## create ca-certificate
./create-ca.sh schaefersm.com
## create k8s secret tls that contains the ca-certificate
kubectl create secret tls own-ca --cert=ca-cert/schaefersm.com.crt --key=ca-cert/schaefersm.com.key -n cert-manager --dry-run=client -oyaml > own-ca.yaml
## add ca-certificate to trust anchor
sudo trust anchor ca-cert/schaefersm.com.crt
sudo update-ca-trust
