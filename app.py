from flask import Flask, request, jsonify
import dotenv
from DynamoDB_MarketPlace import DynamoDBMarketPlace  # Assuming you have a module named market_place_db

app = Flask(__name__)

@app.route('/get_user', methods=['GET'])
def get_user():
    user_id = request.args.get('user_id')
    response = DynamoDBMarketPlace.get_user(user_id)
    return jsonify(response)

@app.route('/get_product', methods=['GET'])
def get_product():
    product_id = request.args.get('product_id')
    response = DynamoDBMarketPlace.get_product(product_id)
    return jsonify(response)

@app.route('/example_user', methods=['GET'])
def example_user():
    user = [
        {
            "user_id": "1",
            "user_name": "JohnDoe11",
            "email": "JohnnyGotDatDoe@gmail.com"
        }
    ]
    return jsonify(user)

@app.route('/example_product', methods=['GET'])
def example_product():
    product = [
        {
            "product_id": "1",
            "product_name": "Laptop",
            "product_price": "1000",
            "product_owner": "JohnDoe11"
        }
    ]
    return jsonify(product)

def launch_app():
    dotenv.load_dotenv()
    app.run(host='0.0.0.0', port=80)

if __name__ == "__main__":
    launch_app()