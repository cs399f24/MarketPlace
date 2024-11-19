import json
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError
from boto3.dynamodb.conditions import Attr

def get_all_products():
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
            'body': json.dumps({'error': 'Failed to retrieve products'})
        }
    