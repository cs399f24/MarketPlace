import json
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

class DynamoDBMarketPlace:
    def __init__(self):
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        self.table = dynamodb.Table('MarketPlaceDatabase')
    
    def delete_product(self, product_name, product_price, product_owner):
        try:
            # Query for the product by ProductName, ProductPrice, and ProductOwner
            response = self.table.scan(
                FilterExpression="ProductName = :name and ProductPrice = :price and ProductOwner = :owner",
                ExpressionAttributeValues={
                    ':name': product_name,
                    ':price': product_price,
                    ':owner': product_owner
                }
            )
            items = response.get('Items', [])
        
            if items:
                # Assuming only one product matches, delete the first one found
                product_to_delete = items[0]
            
                # Extract ProductID from the PK (e.g., "PRODUCT#12345")
                pk = product_to_delete.get('PK')
                if pk and pk.startswith("PRODUCT#"):
                    product_id = pk.split("#")[1]  # Extract the part after "PRODUCT#"
                else:
                    print("Error: PK is not in the expected format")
                    return False

                # Delete the product from DynamoDB
                self.table.delete_item(
                    Key={
                        'PK': pk,  # Use the PK as-is
                        'SK': "#DETAILS"  # The corresponding SK
                    }
                )
                return True
            else:
                print("Error: No matching product found")
                return False
        except (NoCredentialsError, PartialCredentialsError) as e:
            print(f"Credentials error: {e}")
            return False
        except Exception as e:
            print(f"Unhandled error: {e}")
            return False

# Lambda handler function
def lambda_handler(event, context):
    product_name = event.get('product_name')
    product_price = event.get('product_price')
    product_owner = event.get('product_owner')

    if not product_name or not product_price or not product_owner:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Missing product data'})
        }

    marketplace = DynamoDBMarketPlace()
    success = marketplace.delete_product(product_name=product_name, product_price=product_price, product_owner=product_owner)

    if success:
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Product deleted successfully'}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
    else:
        return {
            'statusCode': 403,
            'body': json.dumps({'error': 'Unauthorized or product not found'}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
