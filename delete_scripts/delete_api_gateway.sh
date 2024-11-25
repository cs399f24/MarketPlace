#!/bin/bash

# Variables
API_NAME="MarketPlaceAPI"
REGION="us-east-1"

# Get the AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Fetch API Gateway ID
API_ID=$(aws apigateway get-rest-apis --query "items[?name=='$API_NAME'].id" --output text --region $REGION)

if [ -z "$API_ID" ]; then
    echo "Error: API Gateway '$API_NAME' not found."
else
    echo "Found API Gateway with ID: $API_ID"
    echo "Deleting API Gateway..."
    aws apigateway delete-rest-api --rest-api-id $API_ID --region $REGION
    echo "API Gateway '$API_NAME' deleted successfully."
fi
