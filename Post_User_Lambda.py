import json
import uuid
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

class DynamoDBMarketPlace:
    def __init__(self):
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        self.table = dynamodb.Table('MarketPlaceDatabase')
    
    # Create a new user in the database
    def create_user(self, user_name, email):
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
            'body': json.dumps({'message': 'User created successfully'})
        }
    else:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Failed to create user'})
        }
