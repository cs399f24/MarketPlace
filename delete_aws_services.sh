# Disable AWS CLI pager
export AWS_PAGER=""

# Enable permissions
# chmod +x delete_scripts/delete_dynamodb_table.sh // uncomment this line if you want to delete the DynamoDB table
# chmod +x delete_scripts/delete_objects_s3_bucket.sh // uncomment this line if you want to delete the objects in the S3 bucket
chmod +x delete_scripts/delete_lambda_functions.sh
chmod +x delete_scripts/delete_cognito_user_pool.sh
chmod +x delete_scripts/delete_api_gateway.sh
chmod +x delete_scripts/delete_sns_topic.sh
# Launch delete scripts
# ./delete_scripts/delete_dynamodb_table.sh
# ./delete_scripts/delete_objects_s3_bucket.sh
./delete_scripts/delete_lambda_functions.sh
./delete_scripts/delete_cognito_user_pool.sh
./delete_scripts/delete_api_gateway.sh
./delete_scripts/delete_sns_topic.sh

echo "AWS Services successfully deleted!"
# echo "AWS Services successfully deleted!"