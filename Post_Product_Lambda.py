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
    
    def create_product(self, product_name, product_price, product_owner):
        """
        Creates a new product in the DynamoDB table 'MarketPlaceDatabase'.

        Args:
            product_name (str): The name of the product.
            product_price (float): The price of the product.
            product_owner (str): The owner of the product.

        Returns:
            dict: The response from DynamoDB if the product is created successfully, None otherwise.
        """
        product_id = str(uuid.uuid4())  # Generate a unique product ID
        try:
            response = self.table.put_item(
                Item={
                    'PK': f'PRODUCT#{product_id}',
                    'SK': f'#DETAILS',
                    'Type': 'Product',
                    'ProductName': product_name,
                    'ProductPrice': product_price,
                    'ProductOwner': product_owner
                }
            )
            return response
        except (NoCredentialsError, PartialCredentialsError) as e:
            print(f"Credentials error: {e}")
            return None

def lambda_handler(event, context):
    """
    AWS Lambda handler function to create a new product.

    Args:
        event (dict): The event data passed to the Lambda function.
        context (object): The context object passed to the Lambda function.

    Returns:
        dict: A dictionary containing the status code, response body, and headers.
    """
    # Extract product data from the event
    product_name = event.get('product_name')
    product_price = event.get('product_price')
    product_owner = event.get('product_owner')

    if not product_name or not product_price or not product_owner:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Missing product data'})
        }

    # Create an instance of the DynamoDBMarketPlace class
    marketplace = DynamoDBMarketPlace()

    # Call the create_product method
    response = marketplace.create_product(product_name=product_name, product_price=product_price, product_owner=product_owner)

    if response is not None:
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Product created successfully'}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
    else:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Failed to create product'}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
    