from app import app












# beyond here lives the old code

# from flask import Flask
# from flask import request
# import sys
# import os

# app = Flask(__name__)

# @app.route("/")
# def index():
#     projectName = request.args.get("projectName", "")
#     if projectName:
#       projectName = startProject(projectName)
#     else:
#       projectName = "Please Submit Valid Name"
#     return  (
#       """<form action="" method="get">
#                 <input type="text" name="projectName">
#                 <input type="submit" value="create">
#               </form>"""
#             + projectName
#     )

# @app.route("/<projectName>")
# def startProject(projectName):
#     repoName = projectName
#     print(repoName)
#     try:

# repoName = answers.get('repo-name')
#     # log in here
#     azLogin = "cat ../build_pat.txt.env | az devops login --organization https://arrivelogistics.visualstudio.com/"
#     os.system(azLogin)

#     # using subprocess here for better output
#     azRepoList = sp.getoutput("az repos list --query \"[?contains(name, \'" + repoName + "\')].[name]\" --organization https://arrivelogistics.visualstudio.com/ --project Accelerate  -o tsv")
#     # checking whether repo exists or not and then creating one if not
#     if azRepoList:
#         print("There is already a repository with that name.")
#     else:
#         print("There are no matching repositorys in the Accelerate project")
#         azPipeRun = " az pipelines run --organization https://arrivelogistics.visualstudio.com/ --project Accelerate --branch main --name terraform-cli --variables project-name=" + repoName
#         os.system(azPipeRun)
#         print("Your repo: " + str(repoName) + " is being created.")
#     except:
#         return "something broke"