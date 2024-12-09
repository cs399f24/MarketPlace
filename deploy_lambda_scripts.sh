#!/bin/bash

# Disable AWS CLI pager
export AWS_PAGER=""

# Enable permissions
chmod +x lambda/create_get_all_product_lambda.sh
chmod +x lambda/create_get_product_lambda.sh
chmod +x lambda/create_post_product_lambda.sh
chmod +x lambda/create_post_purchase_lambda.sh
chmod +x lambda/create_post_subscribe_lambda.sh
chmod +x lambda/create_delete_product_lambda.sh

# Launch create scripts
./lambda/create_get_all_product_lambda.sh
./lambda/create_get_product_lambda.sh
./lambda/create_post_product_lambda.sh
./lambda/create_post_purchase_lambda.sh
./lambda/create_post_subscribe_lambda.sh
./lambda/create_delete_product_lambda.sh

echo "Lambda Functions successfully created!" 
#echo "Lambda Functions successfully created!"