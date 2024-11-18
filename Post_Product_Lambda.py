import json
import uuid
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

class DynamoDBMarketPlace:
    def __init__(self):
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        self.table = dynamodb.Table('MarketPlaceDatabase')
    
    # Create a new product in the database
    def create_product(self, product_name, product_price, product_owner):
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
            'body': json.dumps({'message': 'Product created successfully'})
        }
    else:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Failed to create product'})
        }
