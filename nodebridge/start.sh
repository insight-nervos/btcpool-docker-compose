#!/usr/bin/env bash

/usr/bin/nodebridge ckb --db_url mysql://root:root@mysql:3306/BTCPOOL_CKB --job_topic CkbRawGw --kafka_brokers "kafka:9092" --rpc_addr http://ckb-node:8114 --rpc_interval "2000" --solved_share_topic CkbSolvedShare
