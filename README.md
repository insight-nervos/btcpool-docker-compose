# btcpool-docker-compose

This is a docker-compose stack to setup a Stratum V1 mining pool for Nervos Blockchain.  It sets up the required infrastructure along with several utilities such as prometheus for operations. It can be deployed independently or via ansible and / or terraform with it's associated roles. 


## Quick Start

Install [docker](https://docs.docker.com/get-docker/) and [docker-compose](https://docs.docker.com/compose/install/). 

```bash
make start  # Bring up the pool
make ps     # List container status
make stop   # Bring down the pool 
```

To run alternative configurations, prefix with the stack. 

```bash
STACK=prometheus make start 
```

### Configurations 

The application can be deployed in several configurations with additional monitoring utilities depending on how the node is being run. Each configuration involves running associated override files which are facilitated with the Makefile. To deploy a stack, run `make start` and `make stop` to bring down the containers. For additional configuration reference the table below. 

| Configuration | Deployment Command | Description | 
| :---- | :-------------------------- | :---- | 
| Base | `make start` | Minimal deployment | 
| Prometheus Server | `STACK=prometheus make start` | Deploy with prometheus, grafana, and exporters | 
| Prometheus Exporters | `STACK=exporters make start` | Deploy with prometheus exporters. To be used with external prometheus server. | 
| Local Miner | `STACK=miner make start` | Deploy with a single local miner for testing | 

### Miners

BTCPool requires users to name each individual mining unit or proxy if running a large . Create a JSON file with the path `./miner-list/config/miners.json` and add miner names here. Use these names to connect miners to BTCPool.
```
{
# "miner_name": "unique_id",
  "alice_miner": 0,
  "bob_miner": 1
}
```

### Initializing CKB

To initialize ckb, you will need to initialize the config files for ckb. They can be modified by either, 

1. Starting the stack, editing the `ckb-node/ckb.toml`, then restarting the container. 
1. Running ```docker run -v `pwd`/ckb-node:/var/lib/ckb nervos/ckb init --chain mainnet``` before deploying the stack
 and edit the files as needed. 

For more information, consult the docs [here](https://github.com/nervosnetwork/ckb/blob/develop/docs/configure.md). 

### Pool Wallet

BTCpool requires users to import pool's wallet address. The wallet address can be off an online wallet or a ledger (preferred).  To import your wallet edit `./ckb-node/ckb.toml`, scroll to the `[block_assembler]` section, and
  change the `[args]` parameter to your pool's wallet address.
```
[block_assembler]
code_hash = "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8"
args = "0xYOUR_POOL_WALLET_HERE"   # test addr
hash_type = "type"
message = "0x"
```

##### Miner Initialization 

The miner-list service is required by BTCpool to provide miner names and IDs. The service simply responds with a json
object with all the users (or requested IDs) on the '/miner-list' endpoint. See this 
[issue](https://github.com/btccom/btcpool/issues/16#issuecomment-278245381) for more information.

##### Node Bridge

The nodebridge service is required by BTCpool to retrieve mining jobs from ckb-node and send them to Kafka under the
CkbRawGw topic. This replaces blkmaker and gwmaker required by btcpool for other blockchains. See this 
[issue](https://github.com/btccom/btcpool/issues/378) for more information.

##### Local Miner 

> Note: This is not quite working as it is related to [#471](https://github.com/btccom/btcpool/issues/471) with the
> miner not able to communicate with the pool properly. 

For testing purposes, we have included a local cpu miner that joins the pool with the default credentials (username
=`alice`).  To run this container:

```shell script
docker-compose -f docker-compose.yml -f docker-compose.override.ckb-miner.yml up -d
```

The miner will wait 20 seconds to start to allow for the pool to initialize. 

```shell script
docker-compose -f docker-compose.yml -f docker-compose.override.ckb-miner.yml logs ckb-miner 
# These logs show the miner authing to the pool but don't receive a job 
docker-compose -f docker-compose.yml -f docker-compose.override.ckb-miner.yml logs btcpool 
# On the pool side, we see the errors shown below.
```

```shell script
btcpool_1         | I1209 00:55:36.412292     1 StratumSession.cc:248] authorize success, userId: 1, wokerHashId: 8113131267054106046, workerName: alice.__default__, password: X, clientAgent: ckbminer-v1.0.0, clientIp: 172.22.0.10, chain: default
btcpool_1         | W1209 00:55:36.412325     1 StratumServer.cc:185] getLatestStratumJobEx fail
btcpool_1         | E1209 00:55:36.412328     1 StratumSessionCkb.cc:62] sendMiningNotify failed, state = 3
```

To bring down the containers 
```shell script
docker-compose -f docker-compose.yml -f docker-compose.override.ckb-miner.yml stop
```

### Prometheus 

A full prometheus stack can be deployed alongside the pool including Grafana, Alertmanager, and the following exporters. 

| Exporter | Port | Description | 
| :--- | :--- | :--- | 
| btcpool | 9101 | Connection metrics and indicators of steady operation | 
| ckb-node | 8100 | Chain metrics | 
| kafkaexporter | 9308 | Kafka metrics such as number of topics | 
| nodeexporter | 9100 | Node metrics such as CPU/RAM | 
| cadvisor | 9080 | Container metrics | 

To verify prometheus is working, visit `pool-ip:9090/targets` to verify all the exporters came up properly. 

##### Grafana

To see metrics coming from the operation of the pool, you can visit `<your IP/localhost>:3000` to view grafana dashboards. Dashboards will initialize on node startup.  

##### Alertmanager 

To send alerts when adverse situations arise, you can configure receivers to forward alert messages to.  Alerts have two basic components, rules and receivers. To setup new rules, modify the `prometheus/alert_rules.yaml` [per examples](https://awesome-prometheus-alerts.grep.to/rules.html) and restart prometheus. To add new receivers for things like SMS messages and emails, modify the `alertmanager/config.yml` and consult [the docs](https://prometheus.io/docs/alerting/latest/configuration/#receiver) to configure these channels. For instance, to configure a slack alert, you will need to insert a webhook token as seen in [this guide](https://grafana.com/blog/2020/02/25/step-by-step-guide-to-setting-up-prometheus-alertmanager-with-slack-pagerduty-and-gmail/).

### Containers

The following containers are run with this application. 

| Container | Stack | Description | 
| :--- | :--- | :--- | 
| btcpool | Base | Main btcpool node | 
| ckb-node | Base | Main Nervos runtime | 
| nodebridge | Base | Connects btcpool with Nervos | 
| kafka | Base | Required for running btcpool | 
| zookeeper | Base | For running kafka | 
| miner-list | Base | Service to provide miner authentication |
| mysql | Base | For btcpool management data | 
| redis | Base | For caching btcpool data | 
| prometheus | Prometheus | Prometheus server | 
| alertmanager | Prometheus | Send alerts from prometheus | 
| grafana | Prometheus | Visualize metrics from pool | 
| caddy | Prometheus | Reverse proxy for prometheus and grafana | 
| kafka-exporter | Exporters | Kafka exporter | 
| nodeexporter | Exporters | Node data exporter | 
| cadvisor | Exporters | Container data exporter | 

### Ports 

TODO: Pranav 

| Ports | Description | 
| :--- | :--- | 
| 2181 | Zookeeper | 


### Environment Variables

Environment variables can be set or populated in the .env file. 

| Variables | Default | Description |
| :--- | :--- | :--- | 
| DOCKER_IMAGE_BTCPOOL | btccom/btcpool | The btcpool docker image to use. |
| TAG_BTCPOOL | 2019.09.26-17-support-ckb-mining_bch-0.18.5 | The docker tag to use for btcpool. |
| DOCKER_IMAGE_CKB_NODE | nervos/ckb | The image for ckb | 
| TAG_CKB_NODE | v0.38.1 | The image tag for ckb | 

### Related Repositories 

| Repo | Description | 
| :--- | :--- |
| [ansible-role-btcpool](https://github.com/insight-stratum/ansible-role-btcpool) | Ansible role that wraps this repository | 
| [terraform-btcpool-aws-node](https://github.com/insight-stratum/terraform-btcpool-aws-node) | Terraform module that sets up node on AWS with Ansible role |
| [terraform-btcpool-alibaba-node](https://github.com/insight-stratum/terraform-btcpool-alibaba-node) | Terraform module that sets up node on Alibaba with Ansible role |
| [btcpool](https://github.com/btccom/btcpool) | Main btcpool repo |
