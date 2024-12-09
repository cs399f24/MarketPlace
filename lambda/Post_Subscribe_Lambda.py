import json
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

class SNSSubscriptionService:
    def __init__(self):
        self.sns_client = boto3.client('sns', region_name='us-east-1')
        self.sts_client = boto3.client('sts')

    def get_account_id(self):
        """
        Retrieves the AWS account ID using the STS client.
        """
        try:
            response = self.sts_client.get_caller_identity()
            account_id = response['Account']
            if not account_id:
                raise ValueError("Account ID is empty.")
            return account_id
        except Exception as e:
            print(f"Error retrieving AWS account ID: {e}")
            return None

    def email_already_subscribed(self, email, topic_arn):
        """
        Checks if the given email is already subscribed to the SNS topic.

        Args:
            email (str): The email address to check.
            topic_arn (str): The ARN of the SNS topic.

        Returns:
            bool: True if the email is already subscribed, False otherwise.
        """
        try:
            paginator = self.sns_client.get_paginator('list_subscriptions_by_topic')
            for page in paginator.paginate(TopicArn=topic_arn):
                for subscription in page['Subscriptions']:
                    if subscription['Endpoint'] == email and subscription['Protocol'] == 'email':
                        return True
            return False
        except Exception as e:
            print(f"Error checking subscription: {e}")
            return False

    def create_email_subscription(self, email):
        """
        Creates an email subscription to an SNS topic if not already subscribed.

        Args:
            email (str): The email address to subscribe.

        Returns:
            dict: The response from SNS if the subscription is created successfully, None otherwise.
        """
        if not email:
            print("Email is missing.")
            return None
        
        try:
            account_id = self.get_account_id()
            if not account_id:
                raise Exception("Could not fetch AWS account ID.")
            
            sns_topic_arn = f'arn:aws:sns:us-east-1:{account_id}:MarketPlaceTopic'

            # Check if the email is already subscribed
            if self.email_already_subscribed(email, sns_topic_arn):
                print(f"Email {email} is already subscribed to the topic.")
                return {'message': 'Already subscribed', 'status': 'ALREADY_SUBSCRIBED'}
            
            # Subscribe the email
            response = self.sns_client.subscribe(
                TopicArn=sns_topic_arn,
                Protocol='email',
                Endpoint=email
            )
            return response
        except (NoCredentialsError, PartialCredentialsError) as e:
            print(f"Credentials error: {e}")
            return None
        except Exception as e:
            print(f"Error creating email subscription: {e}")
            return None

def lambda_handler(event, context):
    """
    Lambda handler for subscribing a user to an SNS topic.

    Args:
        event (dict): The event data passed to the Lambda function.
        context (object): The context object passed to the Lambda function.

    Returns:
        dict: A response containing the status code, message, and headers.
    """
    try:
        # Log the received event
        print("Received event:", json.dumps(event))

        # Extract email from the event
        email = event.get('user_email')
        if not email:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Email is required'}),
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            }

        # Initialize the subscription service
        subscription_service = SNSSubscriptionService()

        # Create an email subscription
        subscription_response = subscription_service.create_email_subscription(email=email)

        if subscription_response and subscription_response.get('status') == 'ALREADY_SUBSCRIBED':
            return {
                'statusCode': 200,
                'body': json.dumps({'message': f'Email {email} is already subscribed to the topic.'}),
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            }

        if subscription_response and 'SubscriptionArn' in subscription_response:
            return {
                'statusCode': 200,
                'body': json.dumps({'message': f'Subscription request sent to {email}. Confirm via email.'}),
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            }
        else:
            return {
                'statusCode': 500,
                'body': json.dumps({'error': 'Failed to create email subscription'}),
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            }

    except Exception as e:
        print(f"Error in lambda_handler: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
