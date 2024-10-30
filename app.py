from flask import Flask, render_template, request, jsonify
import json
from DynamoDB_MarketPlace import DynamoDBMarketPlace
from flask_cors import CORS
import os
import dotenv

def create_app(MarketPlaceDB):
    app = Flask(__name__)
    CORS(app)
    
    @app.route('/create_user', methods=['POST'])
    def create_user():
        user_id = request.json['user_id']
        user_name = request.json['user_name']
        email = request.json['email']
        response = MarketPlaceDB.create_user(user_id, user_name, email)
        return jsonify(response)
    
    @app.route('/create_product', methods=['POST'])
    def create_product():
        product_id = request.json['product_id']
        product_name = request.json['product_name']
        product_price = request.json['product_price']
        product_owner = request.json['product_owner']
        response = MarketPlaceDB.create_product(product_id, product_name, product_price, product_owner)
        return jsonify(response)
    
    @app.route('/get_user', methods=['GET'])
    def get_user():
        user_id = request.args.get('user_id')
        response = MarketPlaceDB.get_user(user_id)
        return jsonify(response)
    
    @app.route('/get_product', methods=['GET'])
    def get_product():
        product_id = request.args.get('product_id')
        response = MarketPlaceDB.get_product(product_id)
        return jsonify(response)
    
    return app

def launch_app():
    dotenv.load_dotenv()
    MarketPlaceDB = DynamoDBMarketPlace()
    return create_app(MarketPlaceDB)
    


if __name__ == '__main__':
    app = launch_app()
    app.run(host='0.0.0.0', port=80, debug=True)