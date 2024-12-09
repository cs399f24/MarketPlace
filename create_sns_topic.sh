#!/bin/bash

# Set the SNS topic name
TOPIC_NAME="MarketPlaceTopic"

# Set the region
REGION="us-east-1"

# Create the SNS topic
echo "Creating SNS topic: $TOPIC_NAME"
TOPIC_ARN=$(aws sns create-topic \
  --name $TOPIC_NAME \
  --region $REGION \
  --query "TopicArn" \
  --output text)

if [ $? -eq 0 ]; then
  echo "SNS Topic '$TOPIC_NAME' created successfully with ARN: $TOPIC_ARN"
else
  echo "Failed to create SNS Topic '$TOPIC_NAME'"
  exit 1
fi

# Output the ARN of the created topic
echo "SNS Topic ARN: $TOPIC_ARN"

# (Optional) Add a policy to allow specific actions on this topic
# Uncomment the block below to customize permissions
# echo "Adding policy to SNS topic..."
# POLICY=$(cat <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Principal": "*",
#             "Action": "sns:Publish",
#             "Resource": "$TOPIC_ARN"
#         }
#     ]
# }
# EOF
# )
# aws sns set-topic-attributes \
#   --topic-arn $TOPIC_ARN \
#   --attribute-name Policy \
#   --attribute-value "$POLICY"

echo "SNS topic setup completed successfully!"
