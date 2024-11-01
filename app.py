from flask import Flask, request, jsonify
import dotenv
from DynamoDB_MarketPlace import DynamoDBMarketPlace
from flask_cors import CORS

def create_app(db):
    app = Flask(__name__)
    CORS(app)

    @app.route('/create_user', methods=['POST'])
    def create_user():
        data = request.get_json()
        user_id = data.get('user_id')
        user_name = data.get('user_name')
        email = data.get('email')
        
        if not user_id or not user_name or not email:
            return jsonify({'error': 'Missing user data'}), 400

        response = db.create_user(user_id, user_name, email)
        return jsonify(response)

    @app.route('/create_product', methods=['POST'])
    def create_product():
        data = request.get_json()
        product_id = data.get('product_id')
        product_name = data.get('product_name')
        product_price = data.get('product_price')
        product_owner = data.get('product_owner')

        if not product_id or not product_name or not product_price or not product_owner:
            return jsonify({'error': 'Missing product data'}), 400

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
