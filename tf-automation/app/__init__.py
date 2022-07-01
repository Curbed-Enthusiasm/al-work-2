from flask import Flask
from config import Config
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_bootstrap import Bootstrap

app = Flask(__name__)
app.config.from_object(Config)
db = SQLAlchemy(app)
#db.create_all()
migrate = Migrate(app,db)
bootstrap = Bootstrap(app)

from app import routes, models

# class tfModule(db.Model):
#     id = db.Column(db.Integer, primary_key=True)
#     name = db.Column(db.String(64), nullable=False, unique=True)
#     module = db.Column(db.String(800))