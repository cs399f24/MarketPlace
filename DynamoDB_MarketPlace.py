import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

class DynamoDBMarketPlace:
    def __init__(self):
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        self.table = dynamodb.Table('MarketPlaceDatabase')
    
    # Create a new user in the database
    def create_user(self, user_id, user_name, email):
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
    def create_product(self, product_id, product_name, product_price, product_owner):
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


