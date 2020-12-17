import pytest

import sys
import requests
import os
import time
from kafka import KafkaConsumer

pytest_plugins = ["docker_compose"]

os.chdir(os.path.join(os.path.dirname(__file__), '..'))


def test_ckb_get_block_template(function_scoped_container_getter):
    """The Api is now verified good to go and tests can interact with it"""
    payload = {
        "id": 2,
        "jsonrpc": "2.0",
        "method": "get_block_template",
        "params": []
    }
    url = 'http://127.0.0.1:8114'
    response = requests.post(url, json=payload).json()

    assert response['result']['version']


def test_kafka_topic_ckb_share_log(function_scoped_container_getter):
    time.sleep(30)
    bootstrap_servers = ['localhost:9092']
    topicName = 'CkbShareLog'

    # Initialize consumer variable
    consumer = KafkaConsumer (topicName, group_id ='group1',bootstrap_servers =
    bootstrap_servers)

    # Read and print message from consumer
    for msg in consumer:
        print("Topic Name=%s,Message=%s"%(msg.topic,msg.value))

    # Terminate the script
    sys.exit()


def test_scratch():
    consumer = KafkaConsumer(bootstrap_servers=['localhost:19092'])

    topics = consumer.topics()
    consumer.subscribe(['CkbShareLog'])

    output = []
    msg = consumer.poll()

    for msg in consumer:
        output.append(msg)
        assert msg
        sys.exit(0)
