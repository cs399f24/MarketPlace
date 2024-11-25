# Disable AWS CLI pager
export AWS_PAGER=""

# Enable permissions
chmod +x delete_dynamodb_table.sh
chmod +x delete_objects_s3_bucket.sh
chmod +x delete_lambda_functions.sh
chmod +x delete_cognito_user_pool.sh
chmod +x delete_api_gateway.sh

# Launch delete scripts
./delete_dynamodb_table.sh
./delete_objects_s3_bucket.sh
./delete_lambda_functions.sh
./delete_cognito_user_pool.sh
./delete_api_gateway.sh

echo "AWS Services successfully deleted!"
# echo "AWS Services successfully deleted!"