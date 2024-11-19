#!/bin/bash

# Set Lambda function name and role name
FUNCTION_NAME="getUser"
ROLE_NAME="labRole"
ZIP_FILE=".Get_User_Lambda.zip"
PYTHON_FILE="Get_User_Lambda.py"

# Check if the Lambda function already exists
if aws lambda get-function --function-name $FUNCTION_NAME >/dev/null 2>&1; then
    echo "Function '$FUNCTION_NAME' already exists."
    exit 1
fi    

# Get the IAM role ARN
ROLE=$(aws iam get-role --role-name $ROLE_NAME --query "Role.Arn" --output text)

# Check if the role exists
if [ "$ROLE" == "None" ]; then
    echo "IAM role '$ROLE_NAME' not found."
    exit 1
fi

# Create a ZIP file with the Python code
zip $ZIP_FILE $PYTHON_FILE

# Create the Lambda function
echo "Creating Lambda function '$FUNCTION_NAME'..."
aws lambda create-function \
  --function-name $FUNCTION_NAME \
  --runtime python3.9 \
  --role $ROLE \
  --zip-file fileb://$ZIP_FILE \
  --handler Get_User_Lambda.lambda_handler \
  --region us-east-1

# Wait for the function to be created and active
aws lambda wait function-active --function-name $FUNCTION_NAME

# Publish a new version of the Lambda function
aws lambda publish-version --function-name $FUNCTION_NAME

echo "Lambda function '$FUNCTION_NAME' created and version published successfully!"
