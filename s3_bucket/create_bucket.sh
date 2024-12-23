#!/bin/bash

# Define S3 bucket name and region
BUCKET_NAME="marketplace399-fuentes"  # Unique bucket name of your choice
REGION="us-east-1"

# Create the S3 bucket
echo "Creating S3 bucket: $BUCKET_NAME"
aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION --create-bucket-configuration LocationConstraint=$REGION

# Ensure that "Block all public access" is disabled
echo "Disabling 'Block all public access' for the bucket"
aws s3api put-bucket-public-access-block --bucket $BUCKET_NAME --public-access-block-configuration \
    "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

# Enable static website hosting on the bucket
echo "Enabling static website hosting on the bucket"
aws s3 website s3://$BUCKET_NAME/ --index-document index.html

# Upload the index.html and style.css files (make sure these files exist in the current directory)
echo "Uploading index.html and style.css to the bucket"
aws s3 cp index.html s3://$BUCKET_NAME/index.html
aws s3 cp style.css s3://$BUCKET_NAME/style.css

# Set the proper bucket policy to allow public access to the files
echo "Setting bucket policy to allow public read access"
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::'$BUCKET_NAME'/*",
      "Principal": "*"
    }
  ]
}'

# Output the URL of the static website
echo "Your website is live at: http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
