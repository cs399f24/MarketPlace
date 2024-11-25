#!/bin/bash

# Set the DynamoDB table name and region
TABLE_NAME="MarketPlaceDatabase"
REGION="us-east-1"

# Function to delete the DynamoDB table
delete_table() {
    # Check if the table exists
    if aws dynamodb describe-table --table-name $TABLE_NAME --region $REGION >/dev/null 2>&1; then
        echo "Deleting DynamoDB table '$TABLE_NAME'..."
        
        # Delete the table using AWS CLI
        aws dynamodb delete-table --table-name $TABLE_NAME --region $REGION
        
        echo "Table '$TABLE_NAME' deletion initiated. Please wait for completion."
    else
        echo "Table '$TABLE_NAME' does not exist."
    fi
}

# Run the function to delete the table
delete_table
