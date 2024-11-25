#!/bin/bash

# Define the Lambda function names
LAMBDA_FUNCTIONS=("getAllProducts" "getProduct" "getUser" "createProduct" "createUser")

# Set the AWS region
REGION="us-east-1"

# Function to delete Lambda functions
delete_lambda_functions() {
    for FUNCTION_NAME in "${LAMBDA_FUNCTIONS[@]}"; do
        # Check if the Lambda function exists
        if aws lambda get-function --function-name $FUNCTION_NAME --region $REGION >/dev/null 2>&1; then
            echo "Deleting Lambda function: $FUNCTION_NAME..."
            
            # Delete the Lambda function
            aws lambda delete-function --function-name $FUNCTION_NAME --region $REGION
            
            echo "Lambda function '$FUNCTION_NAME' deleted successfully."
        else
            echo "Lambda function '$FUNCTION_NAME' does not exist."
        fi
    done
}

# Run the function to delete Lambda functions
delete_lambda_functions
