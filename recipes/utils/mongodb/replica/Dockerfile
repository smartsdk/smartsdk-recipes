FROM python:3.5

RUN mkdir /src
WORKDIR /src

COPY scripts/replica_ctrl.py /src/replica_ctrl.py

RUN pip install docker
RUN pip install pymongo
