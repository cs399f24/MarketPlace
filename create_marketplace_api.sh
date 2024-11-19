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
  --query "items[?parentId=='null'].id" --output text)

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

# Integrate POST method with createUser Lambda function
aws apigateway put-integration \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $USERS_RESOURCE_ID \
  --http-method POST \
  --integration-http-method POST \
  --type AWS_PROXY \
  --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$(aws lambda get-function --function-name $LAMBDA_CREATE_USER --query 'Configuration.FunctionArn' --output text)/invocations

# Create GET method for getUser
echo "Creating GET method for '/users/{user_name}' to get user (getUser Lambda)"
aws apigateway put-method \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $USERS_RESOURCE_ID \
  --http-method GET \
  --authorization-type NONE \
  --request-parameters "method.request.path.user_name=true"

# Integrate GET method with getUser Lambda function
aws apigateway put-integration \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $USERS_RESOURCE_ID \
  --http-method GET \
  --integration-http-method GET \
  --type AWS_PROXY \
  --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$(aws lambda get-function --function-name $LAMBDA_GET_USER --query 'Configuration.FunctionArn' --output text)/invocations

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

# Integrate POST method with createProduct Lambda function
aws apigateway put-integration \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method POST \
  --integration-http-method POST \
  --type AWS_PROXY \
  --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$(aws lambda get-function --function-name $LAMBDA_CREATE_PRODUCT --query 'Configuration.FunctionArn' --output text)/invocations

# Create GET method for getProduct
echo "Creating GET method for '/products/{product_id}' to get a product (getProduct Lambda)"
aws apigateway put-method \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method GET \
  --authorization-type NONE \
  --request-parameters "method.request.path.product_id=true"

# Integrate GET method with getProduct Lambda function
aws apigateway put-integration \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method GET \
  --integration-http-method GET \
  --type AWS_PROXY \
  --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$(aws lambda get-function --function-name $LAMBDA_GET_PRODUCT --query 'Configuration.FunctionArn' --output text)/invocations

# Create GET method for getAllProducts
echo "Creating GET method for '/products' to get all products (getAllProducts Lambda)"
aws apigateway put-method \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method GET \
  --authorization-type NONE

# Integrate GET method with getAllProducts Lambda function
aws apigateway put-integration \
  --rest-api-id $API_ID \
  --region $REGION \
  --resource-id $PRODUCTS_RESOURCE_ID \
  --http-method GET \
  --integration-http-method GET \
  --type AWS_PROXY \
  --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$(aws lambda get-function --function-name $LAMBDA_GET_ALL_PRODUCTS --query 'Configuration.FunctionArn' --output text)/invocations

# Deploy the API to a new stage
echo "Deploying API Gateway"
STAGE_NAME="prod"
aws apigateway create-deployment \
  --rest-api-id $API_ID \
  --region $REGION \
  --stage-name $STAGE_NAME

# Grant the API Gateway permission to invoke the Lambda functions
echo "Granting API Gateway permissions to invoke Lambda functions"
aws lambda add-permission \
  --function-name $LAMBDA_CREATE_USER \
  --principal apigateway.amazonaws.com \
  --statement-id "CreateUserPermission" \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:execute-api:$REGION:$(aws sts get-caller-identity --query Account --output text):$API_ID/*/POST/users

aws lambda add-permission \
  --function-name $LAMBDA_GET_USER \
  --principal apigateway.amazonaws.com \
  --statement-id "GetUserPermission" \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:execute-api:$REGION:$(aws sts get-caller-identity --query Account --output text):$API_ID/*/GET/users/{user_name}

aws lambda add-permission \
  --function-name $LAMBDA_CREATE_PRODUCT \
  --principal apigateway.amazonaws.com \
  --statement-id "CreateProductPermission" \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:execute-api:$REGION:$(aws sts get-caller-identity --query Account --output text):$API_ID/*/POST/products

aws lambda add-permission \
  --function-name $LAMBDA_GET_PRODUCT \
  --principal apigateway.amazonaws.com \
  --statement-id "GetProductPermission" \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:execute-api:$REGION:$(aws sts get-caller-identity --query Account --output text):$API_ID/*/GET/products/{product_id}

aws lambda add-permission \
  --function-name $LAMBDA_GET_ALL_PRODUCTS \
  --principal apigateway.amazonaws.com \
  --statement-id "GetAllProductsPermission" \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:execute-api:$REGION:$(aws sts get-caller-identity --query Account --output text):$API_ID/*/GET/products

echo "API Gateway setup completed successfully!"
