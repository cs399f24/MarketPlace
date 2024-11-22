import json
import uuid
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

class DynamoDBMarketPlace:
    def __init__(self):
        """
        Initializes the DynamoDBMarketPlace class and sets up the DynamoDB table resource.
        """
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        self.table = dynamodb.Table('MarketPlaceDatabase')
    
    def create_user(self, user_name, email):
        """
        Creates a new user in the DynamoDB table 'MarketPlaceDatabase'.

        Args:
            user_name (str): The name of the user.
            email (str): The email of the user.

        Returns:
            dict: The response from DynamoDB if the user is created successfully, None otherwise.
        """
        user_id = str(uuid.uuid4())  # Generate a unique user ID
        try:
            response = self.table.put_item(
                Item={
                    'PK': f'USER#{user_id}',
                    'SK': f'#PROFILE',
                    'Type': 'User',
                    'UserName': user_name,
                    'Email': email
                }
            )
            return response
        except (NoCredentialsError, PartialCredentialsError) as e:
            print(f"Credentials error: {e}")
            return None

def lambda_handler(event, context):
    """
    AWS Lambda handler function to create a new user.

    Args:
        event (dict): The event data passed to the Lambda function.
        context (object): The context object passed to the Lambda function.

    Returns:
        dict: A dictionary containing the status code, response body, and headers.
    """
    # Extract user data from the event
    user_name = event.get('user_name')
    email = event.get('email')

    if not user_name or not email:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Missing user data'})
        }

    # Create an instance of the DynamoDBMarketPlace class
    marketplace = DynamoDBMarketPlace()

    # Call the create_user method
    response = marketplace.create_user(user_name=user_name, email=email)

    if response is not None:
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'User created successfully'}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
    else:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Failed to create user'}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }