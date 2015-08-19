#!/bin/bash
yum update -y

# Install nfs server stuff
yum install -y nfs-utils nfs-utils-lib rpcbind

# Get basic details of the running instance
EC2_INSTANCE_ID="`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`"
EC2_REGION="`wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"


GIT_VOLUME="`ec2-describe-volumes --region $EC2_REGION -F tag:Name=Git | grep available | awk '{print $2}'`"

ec2-attach-volume --region $EC2_REGION $GIT_VOLUME -i $EC2_INSTANCE_ID -d xvdg

mkdir /githost
mount /dev/xvdg /githost


printf "/githost *(rw,sync,no_root_squash,no_subtree_check,fsid=0)\n" > /etc/exports
exportfs -ar

service rpcbind start
service nfs start
