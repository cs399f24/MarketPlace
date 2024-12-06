import json
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

class SNSNotificationService:
    def __init__(self):
        """
        Initializes the SNSNotificationService class and sets up the SNS client.
        """
        self.sns_client = boto3.client('sns', region_name='us-east-1')
        self.sts_client = boto3.client('sts')  # STS client to get account ID

    def get_account_id(self):
        """
        Fetches the AWS account ID from the STS service.
        
        Returns:
            str: The AWS account ID.
        """
        try:
            response = self.sts_client.get_caller_identity()
            account_id = response['Account']
            return account_id
        except Exception as e:
            print(f"Error retrieving AWS account ID: {e}")
            return None

    def send_notification(self, recipient, product_name, product_price):
        """
        Sends a purchase confirmation notification using Amazon SNS.

        Args:
            recipient (str): The recipient's email or phone number.
            product_name (str): The name of the purchased product.
            product_price (str): The price of the purchased product.

        Returns:
            dict: The response from Amazon SNS if the notification is sent successfully, None otherwise.
        """
        message = f"Thank you for purchasing {product_name} for ${product_price}. Your purchase has been confirmed."
        subject = f"Purchase Confirmation for {product_name}"

        try:
            # Fetch account ID dynamically
            account_id = self.get_account_id()
            if not account_id:
                raise Exception("Could not fetch AWS account ID.")
            
            # Construct SNS Topic ARN dynamically
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

def lambda_handler(event, context):
    """
    AWS Lambda handler function to handle the purchase process and send a confirmation notification.

    Args:
        event (dict): The event data passed to the Lambda function.
        context (object): The context object passed to the Lambda function.

    Returns:
        dict: A dictionary containing the status code, response body, and headers.
    """
    # Extract product data and user contact (email/phone) from the event
    try:
        body = json.loads(event['body'])
        product_name = body.get('product_name')
        product_price = body.get('product_price')
        user_email = body.get('user_email')  # This should be the user's email or phone number
    except (KeyError, ValueError):
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid input format. Expected JSON payload.'}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }

    if not product_name or not product_price or not user_email:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Missing required data: product_name, product_price, or user_email'}),
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
