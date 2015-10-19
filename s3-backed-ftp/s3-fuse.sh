#!/bin/bash

if [ -z $BUCKET ]; then
  echo "You need to set BUCKET environment variable"
  exit 1
fi

# Grab access key and secret access key from EC2 instances meta-data
# This only works if the EC2 instance has been configured with attached IAM role

instance_profile='curl http://169.254.169.254/latest/meta-data/iam/security-credentials/'

AWS_ACCESS_KEY_ID="curl http://169.254.169.254/latest/meta-data/iam/security-credentials/${instance_profile} | grep AccessKeyId | cut -d':' -f2 | sed 's/[^0-9A-Z]*//g'"
AWS_SECRET_ACCESS_KEY="curl http://169.254.169.254/latest/meta-data/iam/security-credentials/${instance_profile} | grep SecretAccessKey | cut -d':' -f2 | sed 's/[^0-9A-Za-z/+=]*//g'"

# If they are still not set here, there was an error retreiving the keys from the instances meta-data
# Or the instance was not configured with the appropriate IAM role account
if [ -z $AWS_ACCESS_KEY_ID ]; then
  echo "You need to set AWS_ACCESS_KEY_ID environment variable"
  exit 1
fi

if [ -z $AWS_SECRET_ACCESS_KEY ]; then
  echo "You need to set AWS_SECRET_ACCESS_KEY environment variable"
  exit 1
fi

#set the aws access credentials from environment variables
echo $AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY > ~/.passwd-s3fs
chmod 600 ~/.passwd-s3fs

#start s3 fuse

/usr/local/bin/s3fs $BUCKET /home/aws/s3bucket -o allow_other -o mp_umask="0022" #-d -d -f -o f2 -o curldbg