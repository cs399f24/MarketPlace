import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError
from DynamoDB_MarketPlace import DynamoDBMarketPlace

def test_create_users():
    # Create an instance of the DynamoDBMarketPlace class
    marketplace = DynamoDBMarketPlace()

    # Test data
    user_name = "test_user"
    email = "test_user@example.com"
    
    user_name2 = "test_user2"
    email2 = "test_user2@example.com"

    # Call the create_user method
    response = marketplace.create_user(user_name=user_name, email=email)
    response2 = marketplace.create_user(user_name=user_name2, email=email2)

    # Check if the response is not None
    if response is not None:
        print("User created successfully.")
    else:
        print("Failed to create user.")
        
    if response2 is not None:
        print("User2 created successfully.")
    else:
        print("Failed to create user2")

def test_create_products():
    # Create an instance of the DynamoDBMarketPlace class
    marketplace = DynamoDBMarketPlace()

    # Test data
    product_name = "test_product"
    product_price = '100.0'
    product_owner = "test_user"
    
    product_name2 = "test_product2"
    product_price2 = '95.99'
    product_owner2 = "test_user2"

    # Call the create_product method
    response = marketplace.create_product(product_name=product_name, product_price=product_price, product_owner=product_owner)
    response2 = marketplace.create_product(product_name=product_name2, product_price=product_price2, product_owner=product_owner2)

    # Check if the response is not None
    if response is not None:
        print("Product created successfully.")
    else:
        print("Failed to create product.")
        
    if response2 is not None:
        print("Product2 created successfully.")
    else:
        print("Failed to create product2.")
        
def test_get_all_users():
    # Create an instance of the DynamoDBMarketPlace class
    marketplace = DynamoDBMarketPlace()

    # Call the get_all_users method
    users = marketplace.get_all_users()

    # Check if the users list is not None and print the users
    if users is not None:
        print("Users retrieved successfully.")
        for user in users:
            print(user)
    else:
        print("Failed to retrieve users.")

if __name__ == "__main__":
    test_create_users()
    test_create_products()
    test_get_all_users()
    