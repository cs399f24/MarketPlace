#!/bin/bash

# Disable AWS CLI pager
export AWS_PAGER=""

# Enable permissions
chmod +x lambda/create_get_all_product_lambda.sh
chmod +x lambda/create_get_product_lambda.sh
chmod +x lambda/create_get_user_lambda.sh
chmod +x lambdacreate_post_product_lambda.sh
chmod +x lambda/create_post_user_lambda.sh

# Launch create scripts
./lambda/create_dynamodb_table.sh  
./lambda/create_get_all_product_lambda.sh
./lambda/create_get_product_lambda.sh
./lambda/create_get_user_lambda.sh
./lambda/create_post_product_lambda.sh
./lambda/create_post_user_lambda.sh

echo "Lambda Functions successfully created!" 
#echo "Lambda Functions successfully created!"