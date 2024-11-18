import json
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError
from boto3.dynamodb.conditions import Attr

def get_user(user_name):
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.Table('MarketPlaceDatabase')
    
    try:
        response = table.scan(
            FilterExpression=Attr('UserName').eq(user_name)
        )
        items = response.get('Items')
        if items:
            return items[0]  # Assuming usernames are unique and returning the first match
        else:
            return None
    except (NoCredentialsError, PartialCredentialsError) as e:
        print(f"Credentials error: {e}")
        return None

def lambda_handler(event, context):
    # Extract user_name from the event
    user_name = event.get('user_name')

    if not user_name:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Missing user_name'})
        }

    # Call the get_user_by_username function
    user = get_user(user_name)

    if user is not None:
        return {
            'statusCode': 200,
            'body': json.dumps(user)
        }
    else:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Failed to retrieve user'})
        }