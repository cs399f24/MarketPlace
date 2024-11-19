#!/bin/bash

# Set the DynamoDB table name and region
TABLE_NAME="MarketPlaceDatabase"
REGION="us-east-1"

# Create the DynamoDB table
create_table() {
    # Check if the table already exists
    if aws dynamodb describe-table --table-name $TABLE_NAME --region $REGION >/dev/null 2>&1; then
        echo "Table '$TABLE_NAME' already exists."
    else
        echo "Creating DynamoDB table '$TABLE_NAME'..."
        
        # Create table using AWS CLI
        aws dynamodb create-table \
            --table-name $TABLE_NAME \
            --attribute-definitions \
                AttributeName=PK,AttributeType=S \
                AttributeName=SK,AttributeType=S \
            --key-schema \
                AttributeName=PK,KeyType=HASH \
                AttributeName=SK,KeyType=RANGE \
            --provisioned-throughput \
                ReadCapacityUnits=5,WriteCapacityUnits=5 \
            --region $REGION
        
        echo "Table '$TABLE_NAME' created successfully!"
    fi
}

# Run the function to create the table
create_table
