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

# Delete domain associated with the User Pool (if any)
DOMAIN=$(aws cognito-idp describe-user-pool --user-pool-id "$USER_POOL_ID" --region $REGION \
    --query "UserPool.Domain" --output text)

if [ "$DOMAIN" != "None" ] && [ -n "$DOMAIN" ]; then
    echo "Found domain: $DOMAIN"
    echo "Deleting domain..."
    aws cognito-idp delete-user-pool-domain --user-pool-id "$USER_POOL_ID" --domain "$DOMAIN" --region $REGION
    if [ $? -eq 0 ]; then
        echo "Domain deleted successfully."
    else
        echo "Failed to delete domain. Exiting."
        exit 1
    fi
else
    echo "No domain associated with the User Pool."
fi

# Disable delete protection for the User Pool
echo "Disabling delete protection for User Pool..."
aws cognito-idp update-user-pool --user-pool-id "$USER_POOL_ID" --deletion-protection INACTIVE --region $REGION

# Check if disabling delete protection was successful
if [ $? -eq 0 ]; then
    echo "Delete protection disabled successfully."
else
    echo "Failed to disable delete protection. Exiting."
    exit 1
fi

# Delete the User Pool
echo "Deleting User Pool '$USER_POOL_NAME'..."
aws cognito-idp delete-user-pool --user-pool-id "$USER_POOL_ID" --region $REGION
if [ $? -eq 0 ]; then
    echo "User Pool deleted."
else
    echo "Failed to delete User Pool."
    exit 1
fi

echo "Cognito resources cleanup completed!"
