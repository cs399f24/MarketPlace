#!/bin/bash

# Variables
USER_POOL_NAME="FinalMarketPlace"
APP_CLIENT_NAME="MarketWebApp"
REGION="us-east-1"  # Modify if necessary

# Get the User Pool ID by name
USER_POOL_ID=$(aws cognito-idp list-user-pools --max-results 10 --region $REGION \
    --query "UserPools[?Name=='$USER_POOL_NAME'].Id" --output text)

if [ -z "$USER_POOL_ID" ]; then
    echo "Error: User Pool '$USER_POOL_NAME' not found."
    exit 1
else
    echo "Found User Pool ID: $USER_POOL_ID"
fi

# Get the App Client ID by name
APP_CLIENT_ID=$(aws cognito-idp list-user-pool-clients --user-pool-id "$USER_POOL_ID" --region $REGION \
    --query "UserPoolClients[?ClientName=='$APP_CLIENT_NAME'].ClientId" --output text)

if [ -z "$APP_CLIENT_ID" ]; then
    echo "Error: App Client '$APP_CLIENT_NAME' not found."
else
    echo "Found App Client ID: $APP_CLIENT_ID"
    echo "Deleting App Client..."
    aws cognito-idp delete-user-pool-client --user-pool-id "$USER_POOL_ID" --client-id "$APP_CLIENT_ID" --region $REGION
    echo "App Client deleted."
fi

# Delete the User Pool
echo "Deleting User Pool '$USER_POOL_NAME'..."
aws cognito-idp delete-user-pool --user-pool-id "$USER_POOL_ID" --region $REGION
echo "User Pool deleted."

echo "Cognito resources cleanup completed!"
