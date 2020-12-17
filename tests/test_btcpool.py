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


# def test_kafka_topic_ckb_share_log(function_scoped_container_getter):
#     # TODO: This is still having issues but this is the main test
#     # if a miner is connected to the pool, you can expect to see
#     # messages come up here.
#     consumer = KafkaConsumer(bootstrap_servers=['localhost:19092'])
#     topics = consumer.topics()
#     consumer.subscribe(['CkbShareLog'])
#
#     output = []
#     for msg in consumer:
#         output.append(msg)
#         assert msg
#         sys.exit(0)
