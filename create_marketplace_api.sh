#!/bin/bash

# Set API Gateway and Lambda function names
API_NAME="MarketPlaceAPI"
LAMBDA_CREATE_USER="createUser"
LAMBDA_GET_USER="getUser"
LAMBDA_CREATE_PRODUCT="createProduct"
LAMBDA_GET_PRODUCT="getProduct"
LAMBDA_GET_ALL_PRODUCTS="getAllProducts"

# Set the region
REGION="us-east-1"

# Get the AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Set the IAM role for API Gateway
API_GW_ROLE="LabRole"

# Create the API Gateway
echo "Creating API Gateway: $API_NAME"
API_ID=$(aws apigateway create-rest-api \
  --name $API_NAME \
  --region $REGION \
  --query "id" --output text)

echo "API Gateway '$API_NAME' created with ID: $API_ID"

# Set the execution role for API Gateway
echo "Assigning role $API_GW_ROLE to API Gateway"
aws apigateway update-rest-api \
  --rest-api-id $API_ID \
  --region $REGION \
  --patch-operations op=replace,path=/policy,value="arn:aws:iam::$ACCOUNT_ID:role/$API_GW_ROLE"

# Get the root resource ID
ROOT_RESOURCE_ID=$(aws apigateway get-resources \
  --rest-api-id $API_ID \
  --region $REGION \
  --query "items[?path=='/'].id" --output text)

# Create '/users' resource for createUser and getUser
echo "Creating '/users' resource"
USERS_RESOURCE_ID=$(aws apigateway create-resource \
  --rest-api-id $API_ID \
  --region $REGION \
  --parent-id $ROOT_RESOURCE_ID \
  --path-part "users" \
  --query "id" --output text)

# Create POST method for createUser
echo "Creating POST method for '/users' to create a user (createUser Lambda)"
aws apigateway put-method \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $USERS_RESOURCE_ID \
  --http-method POST \
  --authorization-type NONE

# Integrate POST method with createUser Lambda function (Non-Proxy)
aws apigateway put-integration \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $USERS_RESOURCE_ID \
  --http-method POST \
  --integration-http-method POST \
  --type AWS \
  --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$LAMBDA_CREATE_USER/invocations

# Add resource-based permission for API Gateway to invoke the Lambda function
echo "Adding permission for API Gateway to invoke createUser Lambda"
aws lambda add-permission \
  --function-name $LAMBDA_CREATE_USER \
  --principal apigateway.amazonaws.com \
  --statement-id "api-gateway-access-createUser" \
  --action "lambda:InvokeFunction" \
  --condition "StringLike" \
  --source-arn arn:aws:execute-api:$REGION:$ACCOUNT_ID:$API_ID/*/POST/users

# Create GET method for getUser
echo "Creating GET method for '/users/{user_name}' to get user (getUser Lambda)"
aws apigateway put-method \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $USERS_RESOURCE_ID \
  --http-method GET \
  --authorization-type NONE \
  --request-parameters "method.request.path.user_name=true"

# Integrate GET method with getUser Lambda function (Non-Proxy)
aws apigateway put-integration \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $USERS_RESOURCE_ID \
  --http-method GET \
  --integration-http-method GET \
  --type AWS \
  --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$LAMBDA_GET_USER/invocations

# Add resource-based permission for API Gateway to invoke the getUser Lambda function
echo "Adding permission for API Gateway to invoke getUser Lambda"
aws lambda add-permission \
  --function-name $LAMBDA_GET_USER \
  --principal apigateway.amazonaws.com \
  --statement-id "api-gateway-access-getUser" \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:execute-api:$REGION:$ACCOUNT_ID:$API_ID/*/GET/users/{user_name}

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
  --http-method POST \
  --authorization-type NONE

# Integrate POST method with createProduct Lambda function (Non-Proxy)
aws apigateway put-integration \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method POST \
  --integration-http-method POST \
  --type AWS \
  --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$LAMBDA_CREATE_PRODUCT/invocations

# Add resource-based permission for API Gateway to invoke the createProduct Lambda function
echo "Adding permission for API Gateway to invoke createProduct Lambda"
aws lambda add-permission \
  --function-name $LAMBDA_CREATE_PRODUCT \
  --principal apigateway.amazonaws.com \
  --statement-id "api-gateway-access-createProduct" \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:execute-api:$REGION:$ACCOUNT_ID:$API_ID/*/POST/products

# Create GET method for getProduct
echo "Creating GET method for '/products/{product_id}' to get a product (getProduct Lambda)"
aws apigateway put-method \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method GET \
  --authorization-type NONE \
  --request-parameters "method.request.path.product_id=true"

# Integrate GET method with getProduct Lambda function (Non-Proxy)
aws apigateway put-integration \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method GET \
  --integration-http-method GET \
  --type AWS \
  --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$LAMBDA_GET_PRODUCT/invocations

# Add resource-based permission for API Gateway to invoke the getProduct Lambda function
echo "Adding permission for API Gateway to invoke getProduct Lambda"
aws lambda add-permission \
  --function-name $LAMBDA_GET_PRODUCT \
  --principal apigateway.amazonaws.com \
  --statement-id "api-gateway-access-getProduct" \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:execute-api:$REGION:$ACCOUNT_ID:$API_ID/*/GET/products/{product_id}

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
  --authorization-type NONE

# Integrate GET method with getAllProducts Lambda function (Non-Proxy)
aws apigateway put-integration \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $GET_ALL_PRODUCTS_RESOURCE_ID \
  --http-method GET \
  --integration-http-method GET \
  --type AWS \
  --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$LAMBDA_GET_ALL_PRODUCTS/invocations

# Add resource-based permission for API Gateway to invoke the getAllProducts Lambda function
echo "Adding permission for API Gateway to invoke getAllProducts Lambda"
aws lambda add-permission \
  --function-name $LAMBDA_GET_ALL_PRODUCTS \
  --principal apigateway.amazonaws.com \
  --statement-id "api-gateway-access-getAllProducts" \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:execute-api:$REGION:$ACCOUNT_ID:$API_ID/*/GET/products/get_all_products

# Deploy the API to a new stage
echo "Deploying API Gateway"
STAGE_NAME="prod"
aws apigateway create-deployment \
  --rest-api-id $API_ID \
  --region $REGION \
  --stage-name $STAGE_NAME

echo "API Gateway setup completed successfully!"
