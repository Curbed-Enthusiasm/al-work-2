from app import db

class tfModule(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64), nullable=False, unique=True)
    module = db.Column(db.String(800))

    def __repr__(self):
        return '<Module {}>'.format(self.name)

# commands to fire up the db
#
# flask db init
#
# flask db migrate -m (optional) "tfModules table" (this creates script to add table)
#
# flask db upgrade (runs script to add table)