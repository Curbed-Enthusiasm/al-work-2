import os
basedir = os.path.abspath(os.path.dirname(__file__))

class Config(object):
    DEV_SUB = os.environ.get('DEV_SUB_ID')
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'secret_key_tbd'
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
        'sqlite:///' + os.path.join(basedir, 'app.db')
    SQLALCHEMY_TRACK_MODIFICATIONS = False


