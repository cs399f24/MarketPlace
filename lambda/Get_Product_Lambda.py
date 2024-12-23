import json
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

def get_product(product_name):
    """
    Retrieves a product from the DynamoDB table 'MarketPlaceDatabase' based on the product name.

    Args:
        product_name (str): The name of the product to retrieve.

    Returns:
        dict: A dictionary containing the product details if found, None otherwise.
    """
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.Table('MarketPlaceDatabase')
    
    try:
        response = table.scan(
            FilterExpression=boto3.dynamodb.conditions.Attr('ProductName').eq(product_name)
        )
        items = response.get('Items')
        if items:
            return items[0]  # Assuming product names are unique and returning the first match
        else:
            return None
    except (NoCredentialsError, PartialCredentialsError) as e:
        print(f"Credentials error: {e}")
        return None

def lambda_handler(event, context):
    """
    AWS Lambda handler function to retrieve a product based on the product name.

    Args:
        event (dict): The event data passed to the Lambda function.
        context (object): The context object passed to the Lambda function.

    Returns:
        dict: A dictionary containing the status code, response body, and headers.
    """
    # Extract product_name from the event
    product_name = event.get('product_name')

    if not product_name:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Missing product_name'})
        }

    # Call the get_product function
    product = get_product(product_name)

    if product is not None:
        return {
            'statusCode': 200,
            'body': json.dumps(product),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
    else:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Failed to retrieve product'}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }