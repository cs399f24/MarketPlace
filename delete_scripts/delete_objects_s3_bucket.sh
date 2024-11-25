#!/bin/bash

# Set the S3 bucket name
BUCKET_NAME="your-bucket-name" # Replace with your bucket name

# Function to delete all objects in the bucket
delete_bucket_objects() {
    echo "Deleting all objects from bucket '$BUCKET_NAME'..."

    # List all objects in the bucket and delete them
    aws s3 rm s3://$BUCKET_NAME --recursive

    if [ $? -eq 0 ]; then
        echo "All objects deleted from bucket '$BUCKET_NAME'."
    else
        echo "Failed to delete objects from bucket '$BUCKET_NAME'. Please check the bucket name and permissions."
    fi
}

# Run the function to delete objects
delete_bucket_objects
