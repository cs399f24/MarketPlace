#!/bin/bash

# Disable AWS CLI pager
export AWS_PAGER=""

# Set AWS Region
REGION="us-east-1"  # Modify if needed

# Variables
USER_POOL_NAME="FinalMarketPlace"
APP_CLIENT_NAME="MarketWebApp"
DOMAIN_NAME="finalmarketplaceauth"  # Managed Cognito domain with branding.
AMPLIFY_APP_ID="<Amplify-ID>"  # Replace with your actual Amplify App ID

# Ensure AWS credentials are configured
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "Error: AWS credentials are not configured properly or missing."
    exit 1
fi

echo "Using Amplify App ID: $AMPLIFY_APP_ID"

# Create Cognito User Pool
USER_POOL_ID=$(aws cognito-idp create-user-pool \
  --pool-name "$USER_POOL_NAME" \
  --auto-verified-attributes email \
  --username-attributes email \
  --mfa-configuration OFF \
  --account-recovery-setting "RecoveryMechanisms=[{Name=verified_email,Priority=1}]" \
  --user-pool-tags Key=Environment,Value=Production \
  --region "$REGION" \
  --query 'UserPool.Id' \
  --output text)

if [ -z "$USER_POOL_ID" ]; then
  echo "Error: Unable to create User Pool."
  exit 1
fi

echo "User Pool created with ID: $USER_POOL_ID"

# Set up Cognito Hosted UI with Managed Branding
echo "Setting up Cognito Hosted UI Domain with Managed Branding"
aws cognito-idp create-user-pool-domain \
    --domain "$DOMAIN_NAME" \
    --user-pool-id "$USER_POOL_ID" \
    --region "$REGION"

if [ $? -ne 0 ]; then
  echo "Error: Unable to create Cognito Hosted UI domain with managed branding."
  exit 1
fi

echo "Cognito Hosted UI domain created with name: $DOMAIN_NAME"

# Create App Client with valid and well-formatted OIDC scopes
echo "Creating App Client: $APP_CLIENT_NAME"
APP_CLIENT_ID=$(aws cognito-idp create-user-pool-client \
    --user-pool-id "$USER_POOL_ID" \
    --client-name "$APP_CLIENT_NAME" \
    --no-generate-secret \
    --allowed-o-auth-flows 'implicit' \
    --allowed-o-auth-scopes 'openid' 'email' \
    --callback-url 'https://staging.${AMPLIFY_APP_ID}.amplifyapp.com/callback.html' \
    --logout-urls 'https://staging.${AMPLIFY_APP_ID}.amplifyapp.com/logout.html' \
    --supported-identity-providers 'COGNITO' \
    --region "$REGION" \
    --query 'UserPoolClient.ClientId' \
    --output text)

if [ -z "$APP_CLIENT_ID" ]; then
  echo "Error: Unable to create App Client."
  exit 1
fi

echo "App Client created with ID: $APP_CLIENT_ID"

# Update authentication flows for the App Client
echo "Configuring authentication flows for App Client"
aws cognito-idp update-user-pool-client \
    --user-pool-id "$USER_POOL_ID" \
    --client-id "$APP_CLIENT_ID" \
    --explicit-auth-flows "ALLOW_USER_SRP_AUTH" "ALLOW_REFRESH_TOKEN_AUTH" "ALLOW_USER_PASSWORD_AUTH" \
    --region "$REGION"

if [ $? -ne 0 ]; then
  echo "Error: Unable to configure App Client authentication flows."
  exit 1
fi

echo "Authentication flows configured for App Client"
echo "Cognito User Pool and App Client setup complete!"
echo "User Pool ID: $USER_POOL_ID"
echo "App Client ID: $APP_CLIENT_ID"
echo "Cognito Hosted UI Domain with Managed Branding: https://${DOMAIN_NAME}.auth.${REGION}.amazoncognito.com"
