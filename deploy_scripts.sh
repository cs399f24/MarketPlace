#!/bin/bash

# Disable AWS CLI pager
export AWS_PAGER=""

# Enable permissions
chmod +x create_dynamodb_table.sh
chmod +x create_get_all_product_lambda.sh
chmod +x create_get_product_lambda.sh
chmod +x create_get_user_lambda.sh
chmod +x create_post_product_lambda.sh
chmod +x create_post_user_lambda.sh
#chmod +x create_marketplace_api.sh

# Launch create scripts
./create_dynamodb_table.sh  
./create_get_all_product_lambda.sh
./create_get_product_lambda.sh
./create_get_user_lambda.sh
./create_post_product_lambda.sh
./create_post_user_lambda.sh
#./create_marketplace_api.sh

echo "DynamoDB Table and Lambda Functions successfully created!" 
#echo "DynamoDB Table, Lambda Functions, and API successfully created!"  