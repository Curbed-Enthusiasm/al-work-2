FROM python:3.8-slim-buster
RUN mkdir /python-auto
COPY . /python-auto
WORKDIR /opt
RUN mkdir azcliextensions
RUN pip install azure-cli
RUN az extension add --name azure-devops \
    && az extension add --name dev-spaces \
    && az extension add --name resource-graph \
    && az extension add --name managementpartner
WORKDIR /python-auto 
RUN sed -i -E 's/(CipherString\s*=\s*DEFAULT@SECLEVEL=)2/\11/' /etc/ssl/openssl.cnf
RUN apt-get update -y
#RUN cat build_pat.txt.env | az devops login --organization https://arrivelogistics.visualstudio.com/
#RUN pip --no-cache-dir install azure-cli
RUN pip install flask-sqlalchemy
RUN pip install flask-migrate
RUN pip install flask-bootstrap
RUN pip install -r requirements.txt
CMD [ "python3", "-m", "flask", "run", "--host=0.0.0.0"]