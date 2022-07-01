from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.validators import DataRequired

class CreateProject(FlaskForm):
    projectName = StringField('ProjectName', validators=[DataRequired()])
    submit      = SubmitField('Create!')