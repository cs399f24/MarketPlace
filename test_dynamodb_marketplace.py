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

if __name__ == "__main__":
    test_create_user()