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

# default of 5 revisions uses too much disk space
printf ":log_aws_wire: false\n:log_dir: '/var/log/aws/codedeploy-agent/'\n:pid_dir: '/opt/codedeploy-agent/state/.pid/'\n:program_name: codedeploy-agent\n:root_dir: '/opt/codedeploy-agent/deployment-root'\n:verbose: false\n:wait_between_runs: 1\n:proxy_uri:\n:max_revisions: 1\n" | tee /etc/codedeploy-agent/conf/codedeployagent.yml
# Install nodejs

curl --silent --location https://rpm.nodesource.com/setup_6.x | bash -
yum install -y nodejs

# Install git

yum install -y git

# Start nginx

service nginx start

