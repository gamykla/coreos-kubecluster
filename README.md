# coreos-kubecluster

How to run kubernetes on core-os instances on AWS.

preliminary steps: install kubectl and kube-aws
------------------
* install kubernetes
 * add kubectl to your PATH. Download kubernetes, extract kubectl. https://github.com/kubernetes/kubernetes/releases
* install kube-aws 
 * https://github.com/coreos/coreos-kubernetes/releases
 * add kube-aws to your PATH

kube cluster setup steps
--------------------------
* find your aws keypair or create one. https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#KeyPairs:sort=keyName You will use these keys to access core-os instances making up your cluster. login with user core.
* create KMS keys. get the arn - https://console.aws.amazon.com/iam/home?region=us-east-1#encryptionKeys/us-east-1 
* create the kube-aws cluster.yaml configuration file by running kube-aws init 
```
kube-aws init \
 --cluster-name=my-cluster-name \
 --external-dns-name=my-cluster-endpoint \
 --region=us-west-1 \
 --availability-zone=us-west-1c \
 --key-name=$YOUR_KEYPAIR_NAME \
 --kms-key-arn="$YOUR_KMS_ARN"
```
* edit cluster.yaml
* build.sh
* kube-aws up
 * if you provide your own VPC make sure it has an internet gateway attached to it
 * the Kube VPC is provisioned with AWS Cloud formation. After you run kube-aws up, you can watch its progress in the cloud formation console: https://console.aws.amazon.com/cloudformation/ 
 
Once you're running
-------------------
* You may want to edit the kubeconfig file to add fully qualified paths to the certificate referencs. This may come in handy!
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

other
* get kube system pods:
 * kubectl --kubeconfig=kubeconfig get pods --namespace=kube-system
* When getting logs for kube system pod, you must also include --namespace=kube-system

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
* core-os kube versions: https://quay.io/repository/coreos/hyperkube?tab=tags
