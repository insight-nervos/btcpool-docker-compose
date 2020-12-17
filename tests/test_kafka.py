import sys
import os
from confluent_kafka import Consumer


def test_kafka_confluent_pkg():
    conf = {
        'bootstrap.servers': 'localhost:19092',
    }

    c = Consumer(**conf)
    c.subscribe(['CkbShareLog'])
    while True:
        msg = c.poll(timeout=1.0)
