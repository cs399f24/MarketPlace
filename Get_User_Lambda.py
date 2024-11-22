import json
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError
from boto3.dynamodb.conditions import Attr

def get_user(user_name):
    """
    Retrieves a user from the DynamoDB table 'MarketPlaceDatabase' based on the username.

    Args:
        user_name (str): The username of the user to retrieve.

    Returns:
        dict: A dictionary containing the user details if found, None otherwise.
    """
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
    """
    AWS Lambda handler function to retrieve a user based on the username.

    Args:
        event (dict): The event data passed to the Lambda function.
        context (object): The context object passed to the Lambda function.

    Returns:
        dict: A dictionary containing the status code, response body, and headers.
    """
    # Extract user_name from the event
    user_name = event.get('user_name')

    if not user_name:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Missing user_name'})
        }

    # Call the get_user function
    user = get_user(user_name)

    if user is not None:
        return {
            'statusCode': 200,
            'body': json.dumps(user),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
    else:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Failed to retrieve user'}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
    