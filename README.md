# coreos-kubecluster

https://coreos.com/kubernetes/docs/latest/kubernetes-on-aws.html



steps:
 * find your keypair. 
 * create KMS keys. get arn
 * kube-aws init \
 --cluster-name=my-cluster-name \
 --external-dns-name=my-cluster-endpoint \
 --region=us-west-1 \
 --availability-zone=us-west-1c \
 --key-name=key-pair-name \
 --kms-key-arn="arn:aws:kms:us-west-1:xxxxxxxxxx:key/xxxxxxxxxxxxxxxxxxx"
 
 * edit cluster.yaml
 * if credentials or user data exist, delete them
 * kube-aws render
 * kube-aws validate
 * kube-aws up

nb - special steps must be taken when setting up certs for production deployments

