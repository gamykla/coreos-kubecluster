#!/bin/bash

rm -fr kubeconfig credentials stack-template.json  userdata

kube-aws render
kube-aws validate

echo 'start with: kube-aws up'

