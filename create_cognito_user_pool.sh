#!/bin/bash

# Variables
USER_POOL_NAME="MarketPlace-UserPool"
APP_CLIENT_NAME="marketplace-app-client"
DOMAIN_PREFIX="marketplace-domain"  # Change this to your desired domain prefix
REGION="us-east-1"  # Modify if necessary

# Retrieve the Amplify App ID automatically (assuming the app name is known)
AMPLIFY_APP_NAME="marketplace-app"  # Replace with your actual Amplify app name
AMPLIFY_APP_ID=$(aws amplify list-apps --query "apps[?name=='$AMPLIFY_APP_NAME'].appId" --output text)

# Check if the App ID was found
if [ "$AMPLIFY_APP_ID" == "None" ]; then
  echo "Error: Amplify app '$AMPLIFY_APP_NAME' not found in the AWS account."
  exit 1
fi

echo "Found Amplify App ID: $AMPLIFY_APP_ID"

# Create Cognito User Pool with the specified configurations
echo "Creating Cognito User Pool: $USER_POOL_NAME"
USER_POOL_ID=$(aws cognito-idp create-user-pool \
    --pool-name "$USER_POOL_NAME" \
    --auto-verified-attributes email \
    --username-attributes username \
    --policies PasswordPolicy={MinimumLength=8,RequireUppercase=false,RequireLowercase=false,RequireNumbers=false,RequireSymbols=false} \
    --mfa-configuration OFF \
    --account-recovery-setting "RecoveryMechanisms=[{Name=LOCAL,Priority=1}]" \
    --user-pool-tags Key=Environment,Value=Production \
    --region $REGION \
    --query 'UserPool.Id' \
    --output text)

echo "User Pool created with ID: $USER_POOL_ID"

# Create Cognito Hosted UI Domain
echo "Creating Cognito Hosted UI domain"
aws cognito-idp create-user-pool-domain \
    --domain "$DOMAIN_PREFIX" \
    --user-pool-id "$USER_POOL_ID" \
    --region $REGION

echo "Hosted UI domain created with prefix: $DOMAIN_PREFIX"

# Create App Client
echo "Creating App Client: $APP_CLIENT_NAME"
APP_CLIENT_ID=$(aws cognito-idp create-user-pool-client \
    --user-pool-id "$USER_POOL_ID" \
    --client-name "$APP_CLIENT_NAME" \
    --generate-secret "false" \
    --allowed-o-auth-flows "implicit" \
    --allowed-o-auth-scopes "openid,email" \
    --allowed-callback-urls "https://$AMPLIFY_APP_ID.amplifyapp.com/callback.html" \
    --allowed-logout-urls "https://$AMPLIFY_APP_ID.amplifyapp.com/logout.html" \
    --supported-o-auth-flows-user-pool-client \
    --allowed-o-auth-grant-types "implicit" \
    --region $REGION \
    --query 'UserPoolClient.ClientId' \
    --output text)

echo "App Client created with ID: $APP_CLIENT_ID"

# Configure App Client Authentication Flows
echo "Configuring authentication flows for App Client"
aws cognito-idp update-user-pool-client \
    --user-pool-id "$USER_POOL_ID" \
    --client-id "$APP_CLIENT_ID" \
    --supported-identity-providers "COGNITO" \
    --explicit-auth-flows "ALLOW_REFRESH_TOKEN_AUTH" "ALLOW_USER_SRP_AUTH" "ALLOW_CUSTOM_AUTH" "ALLOW_USER_PASSWORD_AUTH" \
    --region $REGION

echo "Authentication flows configured for App Client"

# Output final information
echo "Cognito User Pool and App Client setup complete!"
echo "User Pool ID: $USER_POOL_ID"
echo "App Client ID: $APP_CLIENT_ID"
echo "Cognito Hosted UI Domain: https://$DOMAIN_PREFIX.auth.$REGION.amazoncognito.com"
