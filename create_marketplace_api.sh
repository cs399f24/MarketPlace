#!/bin/bash

# Set API Gateway and Lambda function names
API_NAME="MarketPlaceAPI"
LAMBDA_CREATE_USER="createUser"
LAMBDA_GET_USER="getUser"
LAMBDA_CREATE_PRODUCT="createProduct"
LAMBDA_GET_PRODUCT="getProduct"
LAMBDA_GET_ALL_PRODUCTS="getAllProducts"
LAMBDA_DELETE_PRODUCT="deleteProduct"

# Set the region
REGION="us-east-1"

# Get the AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Define the lab role ARN (replace with the actual ARN of your "lab role")
LAB_ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/LabRole"

# Get Cognito User Pool ARN
COGNITO_USER_POOL_ARN=$(aws cognito-idp describe-user-pool \
  --user-pool-id marketplace-userpool \
  --region $REGION \
  --query "UserPool.Arn" --output text)

# Create the API Gateway
echo "Creating API Gateway: $API_NAME"
API_ID=$(aws apigateway create-rest-api \
  --name $API_NAME \
  --region $REGION \
  --query "id" --output text)

echo "API Gateway '$API_NAME' created with ID: $API_ID"

# Get the root resource ID
ROOT_RESOURCE_ID=$(aws apigateway get-resources \
  --rest-api-id $API_ID \
  --region $REGION \
  --query "items[?path=='/'].id" --output text)

# Create '/users' resource for createUser and getUser
# echo "Creating '/users' resource"
# USERS_RESOURCE_ID=$(aws apigateway create-resource \
#   --rest-api-id $API_ID \
#   --region $REGION \
#   --parent-id $ROOT_RESOURCE_ID \
#   --path-part "users" \
#   --query "id" --output text)

# # Create POST method for createUser
# echo "Creating POST method for '/users' to create a user (createUser Lambda)"
# aws apigateway put-method \
#   --rest-api-id $API_ID \
#   --region $REGION \
#   --resource-id $USERS_RESOURCE_ID \
#   --http-method POST \
#   --authorization-type NONE

# # Add Method Response for 200 status code
# aws apigateway put-method-response \
#   --rest-api-id $API_ID \
#   --region $REGION \
#   --resource-id $USERS_RESOURCE_ID \
#   --http-method POST \
#   --status-code 200

# # Integrate POST method with createUser Lambda function (Non-Proxy) and set execution role
# aws apigateway put-integration \
#   --rest-api-id $API_ID \
#   --region $REGION \
#   --resource-id $USERS_RESOURCE_ID \
#   --http-method POST \
#   --integration-http-method POST \
#   --type AWS \
#   --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$LAMBDA_CREATE_USER/invocations \
#   --credentials $LAB_ROLE_ARN  # Specify the lab role ARN

# # Add Integration Response for 200 status code
# aws apigateway put-integration-response \
#   --rest-api-id $API_ID \
#   --region $REGION \
#   --resource-id $USERS_RESOURCE_ID \
#   --http-method POST \
#   --status-code 200 \
#   --selection-pattern ""

# # Add resource-based permission for API Gateway to invoke the createUser Lambda function
# echo "Adding permission for API Gateway to invoke createUser Lambda"
# aws lambda add-permission \
#   --function-name $LAMBDA_CREATE_USER \
#   --principal apigateway.amazonaws.com \
#   --statement-id "api-gateway-access-createUser" \
#   --action "lambda:InvokeFunction" \
#   --source-arn arn:aws:execute-api:$REGION:$ACCOUNT_ID:$API_ID/*/POST/users

# # Create GET method for getUser
# echo "Creating GET method for '/users' to get user (getUser Lambda)"
# aws apigateway put-method \
#   --rest-api-id $API_ID \
#   --region $REGION \
#   --resource-id $USERS_RESOURCE_ID \
#   --http-method GET \
#   --authorization-type NONE \
#   --request-parameters "method.request.path.user_name=true"

# # Add Method Response for 200 status code
# aws apigateway put-method-response \
#   --rest-api-id $API_ID \
#   --region $REGION \
#   --resource-id $USERS_RESOURCE_ID \
#   --http-method GET \
#   --status-code 200

# # Integrate GET method with getUser Lambda function (Non-Proxy) and set execution role
# aws apigateway put-integration \
#   --rest-api-id $API_ID \
#   --region $REGION \
#   --resource-id $USERS_RESOURCE_ID \
#   --http-method GET \
#   --integration-http-method GET \
#   --type AWS \
#   --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$LAMBDA_GET_USER/invocations \
#   --credentials $LAB_ROLE_ARN  # Specify the lab role ARN

# # Add Integration Response for 200 status code
# aws apigateway put-integration-response \
#   --rest-api-id $API_ID \
#   --region $REGION \
#   --resource-id $USERS_RESOURCE_ID \
#   --http-method GET \
#   --status-code 200 \
#   --selection-pattern ""

# # Add resource-based permission for API Gateway to invoke the getUser Lambda function
# echo "Adding permission for API Gateway to invoke getUser Lambda"
# aws lambda add-permission \
#   --function-name $LAMBDA_GET_USER \
#   --principal apigateway.amazonaws.com \
#   --statement-id "api-gateway-access-getUser" \
#   --action "lambda:InvokeFunction" \
#   --source-arn arn:aws:execute-api:$REGION:$ACCOUNT_ID:$API_ID/*/GET/users

# Create a Cognito Authorizer
echo "Creating Cognito Authorizer: CognitoAuth"
AUTHORIZER_ID=$(aws apigateway create-authorizer \
  --rest-api-id $API_ID \
  --name "CognitoAuth" \
  --type COGNITO_USER_POOLS \
  --provider-arns $COGNITO_USER_POOL_ARN \
  --identity-source "method.request.header.Authorization" \
  --query "id" --output text)

echo "Cognito Authorizer created with ID: $AUTHORIZER_ID"

# Create '/products' resource for createProduct, getProduct, and getAllProducts
echo "Creating '/products' resource"
PRODUCTS_RESOURCE_ID=$(aws apigateway create-resource \
  --rest-api-id $API_ID \
  --region $REGION \
  --parent-id $ROOT_RESOURCE_ID \
  --path-part "products" \
  --query "id" --output text)

# Create POST method for createProduct
echo "Creating POST method for '/products' to create a product (createProduct Lambda)"
aws apigateway put-method \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --authorization-type COGNITO_USER_POOLS \
  --authorizer-id $AUTHORIZER_ID

# Add Method Response for 200 status code
aws apigateway put-method-response \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method POST \
  --status-code 200

# Integrate POST method with createProduct Lambda function (Non-Proxy) and set execution role
aws apigateway put-integration \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method POST \
  --integration-http-method POST \
  --type AWS \
  --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$LAMBDA_CREATE_PRODUCT/invocations \
  --credentials $LAB_ROLE_ARN  # Specify the lab role ARN

# Add Integration Response for 200 status code
aws apigateway put-integration-response \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method POST \
  --status-code 200 \
  --selection-pattern ""

# Add resource-based permission for API Gateway to invoke the createProduct Lambda function
echo "Adding permission for API Gateway to invoke createProduct Lambda"
aws lambda add-permission \
  --function-name $LAMBDA_CREATE_PRODUCT \
  --principal apigateway.amazonaws.com \
  --statement-id "api-gateway-access-createProduct" \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:execute-api:$REGION:$ACCOUNT_ID:$API_ID/*/POST/products

# Create GET method for getProduct
echo "Creating GET method for '/products' to get a product (getProduct Lambda)"
aws apigateway put-method \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method GET \
  --authorization-type COGNITO_USER_POOLS \
  --authorizer-id $AUTHORIZER_ID

# Add Method Response for 200 status code
aws apigateway put-method-response \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method GET \
  --status-code 200

# Integrate GET method with getProduct Lambda function (Non-Proxy) and set execution role
aws apigateway put-integration \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method GET \
  --integration-http-method GET \
  --type AWS \
  --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$LAMBDA_GET_PRODUCT/invocations \
  --credentials $LAB_ROLE_ARN  # Specify the lab role ARN

# Add Integration Response for 200 status code
aws apigateway put-integration-response \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method GET \
  --status-code 200 \
  --selection-pattern ""

# Add resource-based permission for API Gateway to invoke the getProduct Lambda function
echo "Adding permission for API Gateway to invoke getProduct Lambda"
aws lambda add-permission \
  --function-name $LAMBDA_GET_PRODUCT \
  --principal apigateway.amazonaws.com \
  --statement-id "api-gateway-access-getProduct" \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:execute-api:$REGION:$ACCOUNT_ID:$API_ID/*/GET/products

# Create '/products/get_all_products' resource for getAllProducts
echo "Creating '/products/get_all_products' resource"
GET_ALL_PRODUCTS_RESOURCE_ID=$(aws apigateway create-resource \
  --rest-api-id $API_ID \
  --region $REGION \
  --parent-id $PRODUCTS_RESOURCE_ID \
  --path-part "get_all_products" \
  --query "id" --output text)

# Create GET method for '/products/get_all_products' to get all products (getAllProducts Lambda)
echo "Creating GET method for '/products/get_all_products' to get all products (getAllProducts Lambda)"
aws apigateway put-method \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $GET_ALL_PRODUCTS_RESOURCE_ID \
  --http-method GET \
  --authorization-type COGNITO_USER_POOLS \
  --authorizer-id $AUTHORIZER_ID

# Add Method Response for 200 status code
aws apigateway put-method-response \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $GET_ALL_PRODUCTS_RESOURCE_ID \
  --http-method GET \
  --status-code 200

# Integrate GET method with getAllProducts Lambda function (Non-Proxy) and set execution role
aws apigateway put-integration \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $GET_ALL_PRODUCTS_RESOURCE_ID \
  --http-method GET \
  --integration-http-method GET \
  --type AWS \
  --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$LAMBDA_GET_ALL_PRODUCTS/invocations \
  --credentials $LAB_ROLE_ARN  # Specify the lab role ARN

# Add Integration Response for 200 status code
aws apigateway put-integration-response \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $GET_ALL_PRODUCTS_RESOURCE_ID \
  --http-method GET \
  --status-code 200 \
  --selection-pattern ""

# Add resource-based permission for API Gateway to invoke the getAllProducts Lambda function
echo "Adding permission for API Gateway to invoke getAllProducts Lambda"
aws lambda add-permission \
  --function-name $LAMBDA_GET_ALL_PRODUCTS \
  --principal apigateway.amazonaws.com \
  --statement-id "api-gateway-access-getAllProducts" \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:execute-api:$REGION:$ACCOUNT_ID:$API_ID/*/GET/products/get_all_products

# Create DELETE method for '/products' to delete a product (deleteProduct Lambda)
echo "Creating DELETE method for '/products' to delete a product (deleteProduct Lambda)"
aws apigateway put-method \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method DELETE \
  --authorization-type COGNITO_USER_POOLS \
  --authorizer-id $AUTHORIZER_ID

# Add Method Response for 200 status code
aws apigateway put-method-response \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method DELETE \
  --status-code 200

# Integrate DELETE method with deleteProduct Lambda function (Non-Proxy) and set execution role
aws apigateway put-integration \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method DELETE \
  --integration-http-method DELETE \
  --type AWS \
  --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$LAMBDA_DELETE_PRODUCT/invocations \
  --credentials $LAB_ROLE_ARN  # Specify the lab role ARN

# Add Integration Response for 200 status code
aws apigateway put-integration-response \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method DELETE \
  --status-code 200 \
  --selection-pattern ""

# Add resource-based permission for API Gateway to invoke the deleteProduct Lambda function
echo "Adding permission for API Gateway to invoke deleteProduct Lambda"
aws lambda add-permission \
  --function-name $LAMBDA_DELETE_PRODUCT \
  --principal apigateway.amazonaws.com \
  --statement-id "api-gateway-access-deleteProduct" \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:execute-api:$REGION:$ACCOUNT_ID:$API_ID/*/DELETE/products

# Deploy the API to a new stage
echo "Deploying API Gateway"
STAGE_NAME="prod"
aws apigateway create-deployment \
  --rest-api-id $API_ID \
  --region $REGION \
  --stage-name $STAGE_NAME

echo "API Gateway setup completed successfully!"
