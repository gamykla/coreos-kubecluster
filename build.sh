#!/bin/bash

rm -fr credentials stack-template.json  userdata

kube-aws render
kube-aws validate


