#!/bin/bash

EFS_MOUNT="${efs_endpoint}"
EFS_ID="${efs_id}"

DB_NAME="${database_name}"
DB_HOSTNAME="${database_endpoint}"
DB_USERNAME="${database_username}"
DB_PASSWORD="${database_password}"

LB_HOSTNAME="${lb_endpoint}"

sudo systemctl enable amazon-ssm-agent
sudo systemctl restart amazon-ssm-agent

yum update -y
amazon-linux-extras install epel -y
yum install -y htop mysql docker gcc-c++ amazon-efs-utils telnet bind-utils 

mkdir -p /var/www/wordpress
#mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $EFS_MOUNT:/ /var/www/wordpress
mount -t efs -o tls $EFS_ID:/ /var/www/wordpress

systemctl enable docker
systemctl start docker

docker run --name some-wordpress -p 80:80 -e WORDPRESS_DB_HOST="$DB_HOSTNAME" -e WORDPRESS_DB_USER="$DB_USERNAME" -e WORDPRESS_DB_PASSWORD="$DB_PASSWORD" -e WORDPRESS_DB_NAME="$DB_NAME" -e WORDPRESS_TABLE_PREFIX=wp_ -d wordpress