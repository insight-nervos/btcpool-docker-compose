# btcpool-docker-compose

This is a docker-compose stack to setup a Stratum V1 mining pool for Nervos Blockchain.  It sets up the required
infrastructure along with several utilities such as prometheus for operations. It can be deployed independently or via
ansible and / or terraform with it's associated roles. 

## Quick Start

Install [docker](https://docs.docker.com/get-docker/) and [docker-compose](https://docs.docker.com/compose/install/). 

```bash
make start  # Bring up the pool
make ps     # List container status
make stop   # Bring down the pool 
```

To run alternative configurations, prefix with the stack. 

```bash
STACK=testnet make start

STACK=prometheus make start 
```

#### To check your server's health
Check kafka's control center dashboard at port `9021`. If all containers are healthy, the `CkbRawGw` and `CkbJob` topics will recieve messeges. The `CkbShareLog` and `CkbSolvedShare` topics will recieve messeges when miners are connected and working.

### Configurations 

The application can be deployed in several configurations with additional monitoring utilities depending on how the
node is being run. Each configuration involves running associated override files which are facilitated with the
Makefile. To deploy a stack, run `make start` and `make stop` to bring down the containers. For additional
configuration reference the table below. 

| Configuration | Deployment Command | Description | 
| :---- | :-------------------------- | :---- | 
| Base | `make start` | Minimal deployment | 
| Testnet Server | `STACK=testnet make start` | Deploy the base compose in ckb's testnet | 
| Prometheus Server | `STACK=prometheus make start` | Deploy with prometheus, grafana, and exporters | 
| Prometheus Exporters | `STACK=exporters make start` | Deploy with prometheus exporters. To be used with external prometheus server. | 
| Local Miner | `STACK=miner make start` | Deploy with a single local miner for testing | 

### Miner List

BTCPool requires users to name each individual mining unit. Create a JSON file with the path `./miner-list/config/miners.json` and add miner names here. Use these names to connect miners to BTCPool.
```
{
# "miner_name": "unique_id",
  "alice_miner": 0,
  "bob_miner": 1
}
```

### Pool Wallet

BTCpool requires users to import pool's wallet address. The wallet address can be off an online wallet or a ledger
(preferred).  To import your wallet, edit `./ckb-node/ckb.toml`, scroll to the `[block_assembler]` section, and
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

> WIP - Building stratum test miner per []

For testing purposes, we have included a local cpu miner that joins the pool with the default credentials (username
=`alice`).  To run this container:

```shell script
docker-compose -f docker-compose.yml -f docker-compose.override.ckb-miner.yml up -d
```

### Prometheus 

> Note: Grafana dashboards waiting for miner metrics before being finalization per 
>[#471](https://github.com/btccom/btcpool/issues/471) mentioned above. 

A full prometheus stack can be deployed alongside the pool including Grafana, Alertmanager, and the following
 exporters. 

| Exporter | Port | Description | 
| :--- | :--- | :--- | 
| btcpool | 9101 | | 
| ckb-node | 8100 |  | 
| kafkaexporter | 9308 |  | 
| nodeexporter | 9100 |  | 
| cadvisor | 9080 |  | 

##### Grafana

TODO

##### Alertmanager 

TODO

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
| Port | Description | External |
| :--- | :---------- | :------- |
| 1800 | Stratum Server | Yes   |
| 8114 | CKB Node RPC   | Yes   |
| 8115 | CKB Node Blockchain | Yes |
| 2181 | Zookeeper Client | No  |
| 9092 | Kafka Advertised | No  |
| 19092 | Kafka Internal  | No  |
| 8000 | Miner List       | No  |
| 3306 | Mariadb          | No  |
| 6379 | Redis            | No  |

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
| [ckb-node](https://github.com/nervosnetwork/ckb) | Main CKB repo |
