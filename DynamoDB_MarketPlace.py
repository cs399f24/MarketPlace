import uuid
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError
from boto3.dynamodb.conditions import Attr

class DynamoDBMarketPlace:
    def __init__(self):
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        self.table = dynamodb.Table('MarketPlaceDatabase')
    
    # Create a new user in the database
    def create_user(self, user_id, user_name, email):
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

    # Get a user from the database
    def get_user(self, user_id):
        try:
            response = self.table.get_item(
                Key={
                    'PK': f'USER#{user_id}',
                    'SK': f'#PROFILE'
                }
            )
            return response.get('Item')
        except (NoCredentialsError, PartialCredentialsError) as e:
            print(f"Credentials error: {e}")
            return None

    # Get a product from the database
    def get_product(self, product_id):
        try:
            response = self.table.get_item(
                Key={
                    'PK': f'PRODUCT#{product_id}',
                    'SK': f'#DETAILS'
                }
            )
            return response.get('Item')
        except (NoCredentialsError, PartialCredentialsError) as e:
            print(f"Credentials error: {e}")
            return None
        
    # Get all users from the database
    def get_all_users(self):
        try:
            response = self.table.scan(
                FilterExpression=Attr('Type').contains('User')
            )
            return response.get('Items')
        except (NoCredentialsError, PartialCredentialsError) as e:
            print(f"Credentials error: {e}")
            return None
        
    # Get all products from the database
    def get_all_products(self):
        try:
            response = self.table.scan(
                FilterExpression=Attr('Type').contains('Product')
            )
            return response.get('Items')
        except (NoCredentialsError, PartialCredentialsError) as e:
            print(f"Credentials error: {e}")
            return None


