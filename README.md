# coreos-kubecluster

How to run kubernetes on core-os instances on AWS.

preliminary steps
------------------
* install kubernetes
 * add kubectl to your PATH
* install kube-aws 
 * add kube-aws to your PATH

kube cluster setup steps
--------------------------
* find your aws keypair or create one. this will be used to log in to core-os instances. 
* create KMS keys. get arn
* run 
```
kube-aws init \
 --cluster-name=my-cluster-name \
 --external-dns-name=my-cluster-endpoint \
 --region=us-west-1 \
 --availability-zone=us-west-1c \
 --key-name=key-pair-name \
 --kms-key-arn="arn:aws:kms:us-west-1:xxxxxxxxxx:key/xxxxxxxxxxxxxxxxxxx"
```
* edit cluster.yaml
* build.sh
* kube-aws up
 * make sure that your VPC has an internet gateway attached to it
 
Once you're running
-------------------
* kube-aws status -- get controller IP
* kubectl --kubeconfig=kubeconfig get nodes

kube get commands
* kubectl --kubeconfig=kubeconfig get pods
* kubectl --kubeconfig=kubeconfig get nodes
* kubectl --kubeconfig=kubeconfig get deployments
* kubectl --kubeconfig=kubeconfig get events
* kubectl --kubeconfig=kubeconfig get services

other kube commands
* kubectl --kubeconfig=kubeconfig logs <POD-NAME>
* kubectl --kubeconfig=kubeconfig cluster-info

kube delete commands
* kubectl --kubeconfig=kubeconfig delete deployments  --all
* kubectl --kubeconfig=kubeconfig delete deployment $DEPLOYMENT_NAME
* kubectl --kubeconfig=kubeconfig delete pods --all

kube create commands
* kubectl --kubeconfig=kubeconfig create -f ./deployment.yaml

perform an update
* kubectl --kubeconfig=kubeconfig apply -f $YAML_FILE

try running nginx:
* kubectl --kubeconfig=kubeconfig run nginx --image=nginx --port=80
* kubectl --kubeconfig=kubeconfig expose deployment nginx --type="LoadBalancer"
* kubectl --kubeconfig=kubeconfig get services nginx
 * you'll want to get the hostname for the load balancer that was created from the aws console

add more pod instances:
* kubectl --kubeconfig=kubeconfig scale deployment nginx --replicas=4

upgrade to a new version of the nginx image:
* kubectl --kubeconfig=kubeconfig set image deployment/nginx nginx=nginx:1.11-alpine
 * notice the old pods being taken down and new ones being brought up: 
  * kubectl --kubeconfig=kubeconfig get pods
* go back to the latest version
 * kubectl --kubeconfig=kubeconfig set image deployment/nginx nginx=nginx:latest

cleanup: tearing down your pods + services
* delete the deployment (deletes pods) + delete service (deletes lb)
 * kubectl --kubeconfig=kubeconfig kubectl delete service,deployment nginx
* verify pods are gone
 * kubectl --kubeconfig=kubeconfig get pods
* verify services are gone
 * kubectl --kubeconfig=kubeconfig get services

Other tasks
--------------
* shut it down
 * kube-aws destroy
* backing up the cloudformation stack
 * kube-aws up --export

notes
------
* AMI's are core-os instnaces.  login with user 'core'
```
ssh -i MyKey.pem core@Ip
```
* worker nodes scale with ec2 auto scaling rules? (review cloudformation)
* if you don't want to register the dns name kube.jeliskubezone.com for example, add kube.jeliskubezone.com to /etc/hosts and point it to the controller
ip. You can get the controller ip with kube-aws status
* special steps must be taken when setting up certs for production deployments
* a kubernetes config file is written to kubeconfig. It can be used to interact with the cluster like so: kubectl --kubeconfig=kubeconfig get nodes

Todo
-----
* why do all hosts have public iP??
* how does this scale? How are new worker nodes added?

NOTES
------
* If a new image is available in the docker registry, kube isn't necessarily going to pull it! For example, if tag 1.0.0 has been updates, don't expect kube to pull it again when creating the deployment if the 1.0.0 tag is already on the filesystem

References
------------
* kube-aws - https://github.com/coreos/coreos-kubernetes/releases 
* kubernetes & kubectl - https://github.com/kubernetes/kubernetes/releases 
* https://coreos.com/kubernetes/docs/latest/kubernetes-on-aws.html
* http://kubernetes.io/docs/hellonode/ 
* kubernetes services: http://kubernetes.io/docs/user-guide/services/#type-nodeport
