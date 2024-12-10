import json
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

class SNSNotificationService:
    def __init__(self):
        """
        Initializes the SNSNotificationService class and sets up the SNS client.
        """
        self.sns_client = boto3.client('sns', region_name='us-east-1')
        self.sts_client = boto3.client('sts')


    """
    Retrieves the AWS account ID associated with the current credentials.
    Returns: The AWS account ID if successful, None otherwise.
    """
    def get_account_id(self):
        try:
            response = self.sts_client.get_caller_identity()
            account_id = response['Account']
            if not account_id:
                raise ValueError("Account ID is empty.")
            return account_id
        except Exception as e:
            print(f"Error retrieving AWS account ID: {e}")
            return None

    """
    Sends a purchase confirmation notification to the recipient.
    Args: recipient (str): The email address of the recipient.
    product_name (str): The name of the purchased product.
    product_price (float): The price of the purchased product.
    Returns: The response from SNS if the notification is sent successfully, None otherwise.
    """
    def send_notification(self, recipient, product_name, product_price):
        if not recipient:
            print("Recipient is missing.")
            return None
        if not product_name or not product_price:
            print("Product information is missing.")
            return None
        
        message = f"Thank you for purchasing {product_name} for ${product_price}. Your purchase has been confirmed."
        subject = f"Purchase Confirmation for {product_name}"

        try:
            account_id = self.get_account_id()
            if not account_id:
                raise Exception("Could not fetch AWS account ID.")
            
            sns_topic_arn = f'arn:aws:sns:us-east-1:{account_id}:MarketPlaceTopic'

            response = self.sns_client.publish(
                TopicArn=sns_topic_arn,
                Message=message,
                Subject=subject
            )
            return response
        except (NoCredentialsError, PartialCredentialsError) as e:
            print(f"Credentials error: {e}")
            return None
        except Exception as e:
            print(f"Error sending notification: {e}")
            return None

"""
AWS Lambda handler function to send a purchase confirmation notification.
Args: event (dict): The event data passed to the Lambda function.
context (object): The context object passed to the Lambda function.
Returns: A dictionary containing the status code, response body, and headers.
"""
def lambda_handler(event, context):
    try:
        # Log the received event
        print("Received event:", json.dumps(event))

        # Extract fields from the event directly (since body is already parsed)
        product_name = event.get('product_name')
        product_price = event.get('product_price')
        user_email = event.get('user_email')

        # Validate that all required fields are present
        if not product_name or not product_price or not user_email:
            missing_fields = []
            if not product_name:
                missing_fields.append('product_name')
            if not product_price:
                missing_fields.append('product_price')
            if not user_email:
                missing_fields.append('user_email')

            return {
                'statusCode': 400,
                'body': json.dumps({'error': f'Missing required data: {", ".join(missing_fields)}'}),
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            }

        # Initialize the notification service
        notification_service = SNSNotificationService()

        # Send a purchase confirmation notification
        notification_response = notification_service.send_notification(
            recipient=user_email,
            product_name=product_name,
            product_price=product_price
        )

        if notification_response:
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'Purchase confirmation notification sent successfully'}),
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            }
        else:
            return {
                'statusCode': 500,
                'body': json.dumps({'error': 'Failed to send confirmation notification'}),
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            }

    except ValueError as e:
        print(f"Error parsing the JSON body: {e}")
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid JSON format in request body.'}),
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