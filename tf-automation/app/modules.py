from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField, SelectField
from wtforms.validators import DataRequired
from flask_sqlalchemy import SQLAlchemy

class DisplayModules(FlaskForm):
    modulesDD = SelectField(u'Modules', choices=[('as','app service'), ('sqldb','SQL DB'), ('pgdb','Postgres DB'), ('cdb','Cosmos DB')], default=1)
    submit      = SubmitField('Download!')