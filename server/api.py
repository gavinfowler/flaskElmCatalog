from flask import Flask, jsonify, abort, make_response
from flask_restful import Api, Resource, reqparse, fields, marshal
from flask_httpauth import HTTPBasicAuth
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from elasticsearch import Elasticsearch
from elasticsearch_dsl import Search
import os
basedir = os.path.abspath(os.path.dirname(__file__))
es = Elasticsearch()

class Config(object):
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'this-is-some-random-stuff-here'
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
        'sqlite:///' + os.path.join(basedir, 'app.db')
    SQLALCHEMY_TRACK_MODIFICATIONS = False

app = Flask(__name__)
app.config.from_object(Config)
api = Api(app)
auth = HTTPBasicAuth()
CORS(app)
db = SQLAlchemy(app)
migrate = Migrate(app, db)


@auth.get_password
def get_password(username):
    if username == 'gavin':
        return 'test'
    return None


@auth.error_handler
def unauthorized():
    # return 403 instead of 401 to prevent browsers from displaying the default
    # auth dialog
    return make_response(jsonify({'message': 'Unauthorized access'}), 403)

# class User(db.Model):
#     id = db.Column(db.Integer, primary_key=True)
#     username = db.Column(db.String(64), index=True, unique=True)
#     email = db.Column(db.String(120), index=True, unique=True)
#     password_hash = db.Column(db.String(128))
#     posts = db.relationship('Post', backref='author', lazy='dynamic')

#     def __repr__(self):
#         return '<User {}>'.format(self.username)

#     def set_password(self, password):
#         self.password_hash = generate_password_hash(password)

#     def check_password(self, password):
#         return check_password_hash(self.password_hash, password)


class Product(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    body = db.Column(db.String(140))
    name = db.Column(db.String(140))
    timestamp = db.Column(db.DateTime, index=True, default=datetime.utcnow)
    # user_id = db.Column(db.Integer, db.ForeignKey('user.id'))

    def __repr__(self):
        return '<Product {}>'.format(self.id)

    def serialize(self):
        return {
            'id': self.id,
            'body': self.body,
            'name': self.name,
            'timestamp': self.timestamp,
        }
class Search(Resource):
    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('query', type=str, location='json')
        super(Search, self).__init__()

    def get(self):
        args = self.reqparse.parse_args()
        print(args['query'])
        res = es.search(index="products", body={
            'query': {
                'bool': {
                    'should': [
                        {'match': {'name': args['query']}},
                        {'match': {'body': args['query']}},
                    ]
                }
            }
        })
        hits = res['hits']['hits']
        print('-----ES Hits------')
        for i in hits:
            print(i)
        print('------------------')

class Products(Resource):
    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('body', type=str, location='json')
        self.reqparse.add_argument('name', type=str, location='json')
        super(Products, self).__init__()

    def post(self):
        args = self.reqparse.parse_args()
        p = Product(name=args.name,body=args.body,timestamp=datetime.now())
        db.session.add(p)
        db.session.commit()
        doc = {
            'id': p.id,
            'body': p.body,
            'name': p.name,
            'timestamp': p.timestamp,
        }
        print(doc)
        res = es.index(index="products", doc_type='product', id=p.id, body=doc)
        print(res['result'])

    def get(self):
        products = Product.query.all()
        res = es.search(index="products", body={
            'query':{
                'match_all':{}
            }
        })
        hits = res['hits']['hits']
        print('-----ES Hits------')
        for i in hits:
            print(i)
        print('------------------')
        print(products)
        return jsonify(products=[e.serialize() for e in products])

class Login(Resource):

    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('username', type=str, location='json')
        self.reqparse.add_argument('email', type=str, location='json')
        super(Login, self).__init__()

    def post(self):
        args = self.reqparse.parse_args()
        print(args)


api.add_resource(Products, '/products', endpoint='products')
# api.add_resource(Product, '/product/<int:id>', endpoint='product')
api.add_resource(Login, '/login', endpoint='login')
api.add_resource(Search, '/search', endpoint='search')


if __name__ == '__main__':
    app.run(debug=True)