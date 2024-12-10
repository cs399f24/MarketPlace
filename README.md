# MarketPlace
## Overview
An online web application that allows users to interact with each other in a virtual marketplace to buy and sell products.

## System Architecture
![System Diagram](https://github.com/cs399f24/MarketPlace/blob/main/MarketPlaceFinalArchitecture.png)

## AWS Deployment:

### Cloud9
* Create Cloud9 Environment
     * Set the environment name (eg. MarketPlace Serve)
     * Under **New EC2 Instance**, select **Additional Instance Types** and choose **t3.medium**
     * Under **Network Settings**, choose **SSH**
     * Hit create and tap the **open** button next to the name of your created instance

* Git clone the repo in the AWS CLI: `https://github.com/cs399f24/MarketPlace.git`

### DynamoDB
* Create Dynamo Table (Only if needed)
     * Go to the dynamodb Directory using `cd MarketPlace/dynamodb`
     * Grant permissions to create_dynamodb_table.sh: `chmod +x create_dynamodb_table.sh`
     * Run the script: `./create_dynamodb_table.sh`

### SNS
* Create SNS Topic
     * Grant permissions to create_sns_topic.sh: `chmod +x create_sns_topic.sh`
     * Run the script: `./create_sns_topic.sh`

### Lambda
* Create Lambda Functions
     * Make sure you are in the `MarketPlace` directory
     * Grant permissions to deploy_lambda_scripts.sh: `chmod +x deploy_lambda_scripts.sh`
     * Run the script: `./deploy_lambda_scripts.sh`

### S3
* Make sure you have an S3 bucket in which you would like to place necessary files
     * Create S3 bucket (if needed)
          * Navigate to s3_bucket folder
          * In the `create_bucket.sh` script, replace the <bucket-name> field with a unique bucket name
          * Grant permissions: `chmod +x create_bucket.sh`
          * Run the script: `./create_bucket.sh`

### Amplify
* Create Amplify Instance: 
     * Navigate to the Amplify console, and select **Deploy App**
     * Select **Deploy Without Git** and hit Next
     * Enter **marketplaceapp** in the name field
     * Under *method*, select **Amazon S3** and choose your bucket with **Choose Prefix**
     * Hit **Save and Deploy**

### Cognito
* Create Cognito User Pool
     * Grant permissions: `chmod +x create_cognito_user_pool.sh`
     * Run the script: `./create_cognito_user_pool.sh`
     * Enter the **Cognito Console** on AWS and go to **user pools**
     * Go to the user pool you created
     * Under **Applications**, select **App Clients**
     * Select newly created **App Client**
     * Go to **login pages** section and edit the login configuration
     * Add **callback url** and **signout url**
     * Change **Oauth Grant Type** to **Implicit Grant**
     * OpenID Connect Scopes must be **email** and **OpenID**

### API Gateway
* Create API 
     * Grant permissions to create_marketplace_api.sh: `chmod +x create_marketplace_api.sh`
     * Run the script: `./create_marketplace_api.sh`
     * Navigate to the **API Gateway Console** and go to the newly created API Gateway, *MarketPlaceAPI*
     * Enable **CORS** for each individual resource and redeploy the API once done

* Modify index.html
     * Replace **const server** field with your **API invoke url**
          * Navigate to **stages** in the API Gateway console and copy the **invoke url** under stage details
     * Replace **const login_server** field with **Cognito Login url**
          * Navigate to Cognito console > Your User Pool > App Integration
          * Select your App Client Name (bottom of page)
          * Click on **View Hosted UI** and copy the entire url

* Modify logout.html
     * Edit **clientID** using by copying the clientID section of the string in the **login_server** variable
     * Edit **cognitoDomain** field with the section of the **login_server** variable
     * Replace the <amplify-id> with *your Amplify ID* in the **RedirectUri** variable

> Create user in cognito user pool to test login functionality

### Update S3 bucket files
* Copy the html and css files to the S3 Bucket with the following AWS CLI Commands (nagivate to `frontend` folder):
     * `aws s3 cp index.html s3://<your_bucket_name>`
     * `aws s3 cp logout.html s3://<your_bucket_name>`
     * `aws s3 cp callback.html s3://<your_bucket_name>`
     * `aws s3 cp style.css s3://<your_bucket_name>`

* Redeploy Update in Amplify App to reflect changes

* Test login functionality

## Tear Down

> Statements to delete DynamoDB Table and S3 bucket are commented out so that they aren't removed unless the user chooses to

* Delete the AWS Services
     * Grant permissions to delete_aws_services.sh: `chmod +x delete_aws_services.sh`
     * Run the script: `./delete_aws_services.sh`
