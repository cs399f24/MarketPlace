import json
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError
from boto3.dynamodb.conditions import Attr

def get_all_products():
    """
    Retrieves all products from the DynamoDB table 'MarketPlaceDatabase'.

    Returns:
        list: A list of product items if successful, None otherwise.
    """
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.Table('MarketPlaceDatabase')
    
    try:
        response = table.scan(
            FilterExpression=Attr('Type').contains('Product')
        )
        return response.get('Items')
    except (NoCredentialsError, PartialCredentialsError) as e:
        print(f"Credentials error: {e}")
        return None

def lambda_handler(event, context):
    """
    AWS Lambda handler function to retrieve all products.

    Args:
        event (dict): The event data passed to the Lambda function.
        context (object): The context object passed to the Lambda function.

    Returns:
        dict: A dictionary containing the status code, response body, and headers.
    """
    # Call the get_all_products function
    products = get_all_products()

    if products is not None:
        return {
            'statusCode': 200,
            'body': json.dumps(products),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
    else:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Failed to retrieve products'}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }