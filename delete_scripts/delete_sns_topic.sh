#!/bin/bash

# Set the SNS topic name
TOPIC_NAME="MarketPlaceTopic"

# Set the region
REGION="us-east-1"

# Get the ARN of the SNS topic
echo "Retrieving ARN for SNS topic: $TOPIC_NAME"
TOPIC_ARN=$(aws sns list-topics \
  --region $REGION \
  --query "Topics[?contains(TopicArn, '$TOPIC_NAME')].TopicArn | [0]" \
  --output text)

if [ "$TOPIC_ARN" == "None" ]; then
  echo "SNS Topic '$TOPIC_NAME' not found in region $REGION."
  exit 1
fi

# Delete the SNS topic
echo "Deleting SNS topic: $TOPIC_NAME with ARN: $TOPIC_ARN"
aws sns delete-topic \
  --topic-arn $TOPIC_ARN \
  --region $REGION

if [ $? -eq 0 ]; then
  echo "SNS Topic '$TOPIC_NAME' deleted successfully."
else
  echo "Failed to delete SNS Topic '$TOPIC_NAME'."
  exit 1
fi

echo "SNS topic deletion completed!"
