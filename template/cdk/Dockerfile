FROM python:3

RUN apt-get update
RUN apt-get install -y less net-tools socat awscli

RUN apt-get update
RUN apt-get install -y npm
RUN npm install -g aws-cdk

COPY ./requirements.txt /root/requirements.txt
RUN pip install -r /root/requirements.txt
