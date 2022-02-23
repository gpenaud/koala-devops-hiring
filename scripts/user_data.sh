#! /bin/bash

apt update -y
apt install -y nginx ruby-full wget git

# get basic details of the running instance
EC2_INSTANCE_ID="`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`"
EC2_ZONE="`wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone`"
EC2_REGION="`echo $EC2_ZONE | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"

# install CodeDeploy Agent
wget https://aws-codedeploy-${EC2_REGION}.s3.${EC2_REGION}.amazonaws.com/latest/install
chmod +x ./install
./install auto

# default of 5 revisions uses too much disk space
printf ":log_aws_wire: false\n:log_dir: '/var/log/aws/codedeploy-agent/'\n:pid_dir: '/opt/codedeploy-agent/state/.pid/'\n:program_name: codedeploy-agent\n:root_dir: '/opt/codedeploy-agent/deployment-root'\n:verbose: false\n:wait_between_runs: 1\n:proxy_uri:\n:max_revisions: 1\n" | tee /etc/codedeploy-agent/conf/codedeployagent.yml

# install nodejs
curl -silent --location https://deb.nodesource.com/setup_14.x | sudo bash -
apt-get -y install nodejs

# install pm2 module globaly
npm install -g pm2
pm2 update

exit 0
