# cert-manager
## install cert-manager
helm install cert-manager jetstack/cert-manager -n cert-manager --set installCRDs=true --create-namespace
## create ca-certificate (optional)
./create-ca.sh schaefersm.com
## create k8s secret tls that contains the ca-certificate
kubectl create secret tls own-ca --cert=ca-cert/schaefersm.com.crt --key=ca-cert/schaefersm.com.key -n cert-manager --dry-run=client -oyaml | kubectl apply -f -
## create cluster-issuer
kubectl apply -f ca-cluster-issuer.yaml
## create wildcard-certificate
kubectl apply -f wildcard-certificate.yaml
## add ca-certificate to trust anchor
sudo trust anchor ca-cert/schaefersm.com.crt
sudo update-ca-trust
