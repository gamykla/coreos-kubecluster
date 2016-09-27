# coreos-kubecluster

How to run kubernetes on core-os instances on AWS.

Based on: 
    https://coreos.com/kubernetes/docs/latest/kubernetes-on-aws.html

preliminary steps
------------------
* install kubernetes
 * add kubectl to your PATH
* install kube-aws 
 * add kube-aws to your PATH

kube cluster setup steps
--------------------------
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
 * make sure that your VPC has an internet gateway attached to it
* kube-aws status -- get controller IP
* setup DNS to match kubecfg file or edit /etc/hosts
* kubectl --kubeconfig=kubeconfig get nodes


Other tasks
--------------
* shut it down
 * kube-aws destroy
* backing up the cloudformation stack
 * kube-aws up --export

notes
------
* AMI's are core-os instnaces. login with user 'coreos'
* worker nodes scale with ec2 auto scaling rules? (review cloudformation)
* if you don't want to register the dns name kube.jeliskubezone.com for example, add kube.jeliskubezone.com to /etc/hosts and point it to the controller
ip. You can get the controller ip with kube-aws status
* special steps must be taken when setting up certs for production deployments
* a kubernetes config file is written to kubeconfig. It can be used to interact with the cluster like so: kubectl --kubeconfig=kubeconfig get nodes

