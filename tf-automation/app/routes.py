from app.models import tfModule
from flask import render_template, flash, redirect, request, jsonify
from flask.helpers import url_for
from flask_sqlalchemy import SQLAlchemy
from app import app
from app.forms import LoginForm
from app.newproj import CreateProject
from app.modules import DisplayModules

import sys
import os
import subprocess as sp

@app.route('/')
@app.route('/index')
def index():
    user = {'username': 'Matts'}
    posts = [
        {
            'author': {'username': 'john'},
            'body': 'Beautiful day in the neighborhood'
        },
        {
            'author': {'username': 'nancy'},
            'body': 'Bezos is da debble'
        }
    ]
    return render_template('index.html', title='Home',user=user) #, posts=posts

# login section #################################

@app.route('/login', methods=['GET','POST'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        flash('Login requested for user {}, remember_me={}'.format(form.username.data, form.remember_me.data))
        return redirect(url_for('index'))
    return render_template('login.html', title='Sign In', form=form)

@app.route('/project', methods=['GET','POST'])
def createProject():
    form = CreateProject()
    if form.validate_on_submit():
        repoName = form.projectName.data
        # log in here
        #azLogin = "cat ../build_pat.txt.env | az devops login --organization https://arrivelogistics.visualstudio.com/"
        #os.system(azLogin)

        # using subprocess here for better output
        azRepoList = sp.getoutput("az repos list --query \"[?contains(name, \'" + repoName + "\')].[name]\" --organization https://arrivelogistics.visualstudio.com/ --project Accelerate  -o tsv")
        # checking whether repo exists or not and then creating one if not
        if azRepoList:
            flash('There is already a repository with the name: {}'.format(form.projectName.data))
            return redirect(url_for('index'))
        else:
            flash('New project being created (5 min wait time), named: {}'.format(form.projectName.data))
            azPipeRun = " az pipelines run --organization https://arrivelogistics.visualstudio.com/ --project Accelerate --branch main --name terraform-cli --variables project-name=" + repoName
            os.system(azPipeRun)
            return redirect(url_for('index'))
    return render_template('project.html', title='Create', form=form)

@app.route('/modules', methods=['GET','POST'])
def displayMods():
    form = DisplayModules()
    return render_template('modules.html', title='Show Mods', form=form)

@app.route('/modulelist/<module>')
def module(module):
    tfmod = tfModule.query.filter_by(name=module).all()

    modArray = []
    for mod in tfmod:
        modObj = {}
        modObj['id'] = mod.id
        modObj['name'] = mod.name
        modObj['module'] = mod.module
        modArray.append(modObj)

    return jsonify({'tfmod' : modArray})