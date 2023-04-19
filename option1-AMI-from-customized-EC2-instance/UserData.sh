#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install php7.2 -y
sudo yum -y install httpd
sudo yum -y install mc
sudo yum -y install git
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl status amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo sudo ./aws/install
sudo systemctl enable httpd
sudo chmod go+rw /var/www/html
sudo git clone https://github.com/WordPress/WordPress.git /var/www/html
cd /var/www/html/
cp wp-config-sample.php wp-config.php
sudo systemctl start httpd
sudo systemctl restart httpd
TAG_NAME="Environment"
INSTANCE_ID="`wget -qO- http://instance-data/latest/meta-data/instance-id`"
REGION="`wget -qO- http://instance-data/latest/meta-data/placement/availability-zone | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
TAG_VALUE="`aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=$TAG_NAME" --region $REGION --output=text | cut -f5`"
sudo echo "OEC_ENVIRONMENT=$TAG_VALUE" >> /etc/environment
sudo source /etc/environment
sudo aws s3 cp s3://vpakhai-test-configs-bucket/CloudWatchAgentConfig.json  /root/
sudo yum install amazon-cloudwatch-agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/root/CloudWatchAgentConfig.json -s