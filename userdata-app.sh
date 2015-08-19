#!/bin/bash
yum update -y

# Install web server stuff
yum install -y nginx

# Get basic details of the running instance
EC2_INSTANCE_ID="`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`"
EC2_ZONE="`wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone`"
EC2_REGION="`echo $EC2_ZONE | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"


# Install CodeDeploy Agent

aws s3 cp s3://aws-codedeploy-${EC2_REGION}/latest/install . --region $EC2_REGION
chmod +x ./install
./install auto


# Install iojs

IOJS_VER="$(wget -q https://iojs.org/dist/index.tab -O - | head -2 | tail -1 | cut -f 1)"
IOJS_REMOTE="http://iojs.org/dist/${IOJS_VER}/iojs-${IOJS_VER}-linux-x64.tar.gz"
IOJS_LOCAL="/tmp/iojs-${IOJS_VER}-linux-x64.tar.gz"
IOJS_UNTAR="/tmp/iojs-${IOJS_VER}-linux-x64"

wget --quiet ${IOJS_REMOTE} -O ${IOJS_LOCAL}
tar xf ${IOJS_LOCAL} -C /tmp/
rm ${IOJS_UNTAR}/{LICENSE,CHANGELOG.md,README.md}
rsync -a "${IOJS_UNTAR}/" /usr/local/

# Start nginx

service nginx start

