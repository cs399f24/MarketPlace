#!/bin/bash

# Disable AWS CLI pager
export AWS_PAGER=""

# Set Lambda function name, role name, and ZIP file
FUNCTION_NAME="purchaseProduct"
ROLE_NAME="LabRole"
ZIP_FILE="zip_files/Post_Purchase_Lambda.zip"

# Check if the Lambda function already exists
if aws lambda get-function --function-name $FUNCTION_NAME >/dev/null 2>&1; then
    echo "Function '$FUNCTION_NAME' already exists."
    exit 1
fi    

# Get the IAM role ARN
ROLE=$(aws iam get-role --role-name $ROLE_NAME --query "Role.Arn" --output text)

# Check if the role exists
if [ -z "$ROLE" ] || [ "$ROLE" == "None" ]; then
    echo "IAM role '$ROLE_NAME' not found."
    exit 1
fi

# Check if the ZIP file exists
if [ ! -f "$ZIP_FILE" ]; then
    echo "Error: ZIP file '$ZIP_FILE' not found."
    exit 1
fi

# Create the Lambda function
echo "Creating Lambda function '$FUNCTION_NAME'..."
aws lambda create-function \
  --function-name $FUNCTION_NAME \
  --runtime python3.13 \
  --role $ROLE \
  --zip-file fileb://$ZIP_FILE \
  --handler Post_Purchase_Lambda.lambda_handler \
  --region us-east-1

# Wait for the function to be created and active
echo "Waiting for function to be active..."
aws lambda wait function-active --function-name $FUNCTION_NAME

# Update the timeout configuration to 30 seconds
echo "Setting Lambda function timeout to 30 seconds..."
aws lambda update-function-configuration \
  --function-name $FUNCTION_NAME \
  --timeout 30 \
  --region us-east-1

# Publish a new version of the Lambda function
echo "Publishing function version..."
aws lambda publish-version --function-name $FUNCTION_NAME

echo "Lambda function '$FUNCTION_NAME' created and version published successfully!"
