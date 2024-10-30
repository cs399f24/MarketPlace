from flask import Flask, request, jsonify
import dotenv
import json
from DynamoDB_MarketPlace import DynamoDBMarketPlace  # Assuming you have a module named market_place_db
from flask_cors import CORS

def create_app(db):
    app = Flask(__name__)
    CORS(app)

    @app.route('/create_user', methods=['POST'])
    def create_user():
        data = json.loads(request.data)
        user_id = data.get('user_id')
        user_name = data.get('user_name')
        email = data.get('email')
        response = db.create_user(user_id, user_name, email)
        return jsonify(response)
    
    @app.route('/create_product', methods=['POST'])
    def create_product():
        data = json.loads(request.data)
        product_id = data.get('product_id')
        product_name = data.get('product_name')
        product_price = data.get('product_price')
        product_owner = data.get('product_owner')
        response = db.create_product(product_id, product_name, product_price, product_owner)
        return jsonify(response)
    
    @app.route('/get_user', methods=['GET'])
    def get_user():
        user_id = request.args.get('user_id')
        response = db.get_user(user_id)
        return jsonify(response)
    
    @app.route('/get_product', methods=['GET'])
    def get_product():
        product_id = request.args.get('product_id')
        response = db.get_product(product_id)
        return jsonify(response)
    
    @app.route('/example_user', methods=['GET'])
    def example_user():
        return jsonify({
            'user_id': '1',
            'user_name': 'JohnDoe11',
            'email': 'JohnGotDatDoe@gmail.com'
        })
    
    @app.route('/example_product', methods=['GET'])
    def example_product():
        return jsonify({
            'product_id': '1',
            'product_name': 'Laptop',
            'product_price': 1000,
            'product_owner': 'JohnDoe11'
        })
    
    return app

def launch_app():
    dotenv.load_dotenv()
    db = DynamoDBMarketPlace()
    return create_app(db)

if __name__ == "__main__":
    app = launch_app()
    app.run(port=80, debug=True)