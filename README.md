# coreos-kubecluster step by step

How to run kubernetes on core-os instances on AWS.

preliminary steps: install kubectl and kube-aws
------------------
* install kubernetes
 * add kubectl to your PATH. Download kubernetes, extract kubectl. https://github.com/kubernetes/kubernetes/releases
 * We're using 1.5.0 https://github.com/kubernetes/kubernetes/releases/tag/v1.5.0
* install kube-aws 
 * https://github.com/coreos/coreos-kubernetes/releases
 * add kube-aws to your PATH
 * We're using 0.8.3 https://github.com/coreos/coreos-kubernetes/releases/tag/v0.8.3

kube cluster setup steps
--------------------------
* [Step 1: create keypair] find your aws keypair or create one. https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#KeyPairs:sort=keyName You will use these keys to access core-os instances making up your cluster. login with user core.
* [Step 2: create encrpytion keys] create KMS keys. get the arn - https://console.aws.amazon.com/iam/home?region=us-east-1#encryptionKeys/us-east-1 
 * Go to "Encryption keys"
 * Create a key
 * record the ARN 
* [Step 3] create the kube-aws cluster.yaml configuration file by running kube-aws init 
```
kube-aws init \
 --cluster-name=my-cluster-name \
 --external-dns-name=kube.myhostname.com \
 --region=us-west-1 \
 --availability-zone=us-west-1c \
 --key-name=$YOUR_KEYPAIR_NAME (from step 1 above)  \
 --kms-key-arn="$YOUR_KMS_ARN" (from step 2 above)
```
* [Step 4] edit cluster.yaml - set config values that suit you. the next steps will validate your config.
* [Step 5] run build.sh
 * this step will run validations. 
* [Step 6] run 'kube-aws up' to start the cluster.
 * nb: if you provide your own VPC make sure it has an internet gateway attached to it
 * the Kube VPC is provisioned with AWS Cloud formation. After you run kube-aws up, you can watch its progress in the cloud formation console: https://console.aws.amazon.com/cloudformation/ 
 
Once you're running
-------------------
* You may want to edit the kubeconfig file to add fully qualified paths to the certificate referencs. This may come in handy!

useful stuff
----------------
```
# get stuff
kubectl --kubeconfig=kubeconfig get pods
kubectl --kubeconfig=kubeconfig get nodes
kubectl --kubeconfig=kubeconfig get deployments
kubectl --kubeconfig=kubeconfig get events
kubectl --kubeconfig=kubeconfig get services
kubectl --kubeconfig=kubeconfig logs <POD-NAME>
kubectl --kubeconfig=kubeconfig cluster-info

# deleting stuff
kubectl --kubeconfig=kubeconfig delete deployments  --all
kubectl --kubeconfig=kubeconfig delete deployment $DEPLOYMENT_NAME
kubectl --kubeconfig=kubeconfig delete pods --all

# create something from a descriptor
kubectl --kubeconfig=kubeconfig create -f ./deployment.yaml

# update something
kubectl --kubeconfig=kubeconfig apply -f $YAML_FILE

# describe things
kubectl --kubeconfig=kubeconfig describe service $SERVICE_NAME
kubectl --kubeconfig=kubeconfig describe pod $POD_NAME
kubectl --kubeconfig=kubeconfig describe deployment $DEPLOYMENT_NAME
```

nginx hello-world
------------------
```
kubectl --kubeconfig=kubeconfig run nginx --image=nginx --port=80
kubectl --kubeconfig=kubeconfig expose deployment nginx --type="LoadBalancer"
kubectl --kubeconfig=kubeconfig get services nginx  #you'll want to get the hostname for the load balancer that was created from the aws console

# add some more instances
kubectl --kubeconfig=kubeconfig scale deployment nginx --replicas=4

#upgrade to a new version of the nginx image
kubectl --kubeconfig=kubeconfig set image deployment/nginx nginx=nginx:1.11-alpine
# notice the old pods being taken down and new ones being brought up: 
kubectl --kubeconfig=kubeconfig get pods
# go back to the latest version
kubectl --kubeconfig=kubeconfig set image deployment/nginx nginx=nginx:latest

# cleaning up
kubectl --kubeconfig=kubeconfig kubectl delete service,deployment nginx
# verify pods are gone
kubectl --kubeconfig=kubeconfig get pods
# verify services are gone
kubectl --kubeconfig=kubeconfig get services

# shut it all down with kube-aws
# nb: be sure to delete your service FIRST! The stack teardown will fail miserably if you still have an ELB associated with your VPC.
kube-aws destroy  
```

misc system stuff:
```
# get kube system pods:
kubectl --kubeconfig=kubeconfig get pods --namespace=kube-system
# nb: When getting logs for kube system pod, you must also include --namespace=kube-system

# back up your cloudformation stack
kube-aws up --export
```


notes
------
* AMI's are core-os instnaces.  login with user 'core'
```
ssh -i MyKey.pem core@Ip
```
* if you don't want to register the controller dns name kube.jeliskubezone.com for example, add kube.jeliskubezone.com to /etc/hosts and point it to the controller
ip. You can get the controller ip with kube-aws status
* special steps must be taken when setting up certs for production deployments
* If a new image is available in the docker registry, kube isn't necessarily going to pull it! For example, if tag 1.0.0 has been updates, don't expect kube to pull it again when creating the deployment if the 1.0.0 tag is already on the filesystem

References
------------
* kube-aws - https://github.com/coreos/coreos-kubernetes/releases 
* kubernetes & kubectl - https://github.com/kubernetes/kubernetes/releases 
* https://coreos.com/kubernetes/docs/latest/kubernetes-on-aws.html
* http://kubernetes.io/docs/hellonode/ 
* kubernetes services: http://kubernetes.io/docs/user-guide/services/#type-nodeport
* core-os kube versions: https://quay.io/repository/coreos/hyperkube?tab=tags
