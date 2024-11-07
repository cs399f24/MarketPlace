import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError
from DynamoDB_MarketPlace import DynamoDBMarketPlace

def test_create_user():
    # Create an instance of the DynamoDBMarketPlace class
    marketplace = DynamoDBMarketPlace()

    # Test data
    user_name = "test_user"
    email = "test_user@example.com"

    # Call the create_user method
    response = marketplace.create_user(user_name=user_name, email=email)

    # Check if the response is not None
    if response is not None:
        print("User created successfully.")
    else:
        print("Failed to create user.")

def test_create_product():
    # Create an instance of the DynamoDBMarketPlace class
    marketplace = DynamoDBMarketPlace()

    # Test data
    product_name = "test_product"
    product_price = '100.0'
    product_owner = "test_user"

    # Call the create_product method
    response = marketplace.create_product(product_name=product_name, product_price=product_price, product_owner=product_owner)

    # Check if the response is not None
    if response is not None:
        print("Product created successfully.")
    else:
        print("Failed to create product.")

if __name__ == "__main__":
    test_create_user()
    test_create_product()