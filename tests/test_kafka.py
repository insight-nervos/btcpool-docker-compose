import sys
import os
from confluent_kafka import Consumer


if __name__ == '__main__':
    conf = {
        'bootstrap.servers': 'localhost:19092',
    }

    c = Consumer(**conf)
    c.subscribe(['CkbShareLog'])
    while True:
        msg = c.poll(timeout=1.0)
        print()